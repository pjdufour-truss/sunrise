from django.http import HttpResponse

from sunrise import settings


def home(request):
    html = """
        <!doctype html>
        <html lang="en">
            <head>
                <link
                    rel="stylesheet"
                    href="https://cdn.rawgit.com/openlayers/openlayers.github.io/master/en/v5.3.0/css/ol.css"
                    type="text/css">
                <style>
                    .map { height: 100%x; width: 100%; }
                    #info {
                        z-index: 1;
                        opacity: 0;
                        position: absolute;
                        bottom: 0;
                        left: 0;
                        margin: 0;
                        background: rgba(0,60,136,0.7);
                        color: white;
                        border: 0;
                        transition: opacity 100ms ease-in;
                    }
                </style>
                <script
                    src="https://cdn.rawgit.com/openlayers/openlayers.github.io/master/en/v5.3.0/build/ol.js">
                </script>
                <title>"""+settings.TITLE+"""</title>

                <script>
                    window.addEventListener("load", (event) => {
                        var layers = [new ol.layer.Tile({source: new ol.source.OSM()})];
                        var center = ["""+str(settings.MAP_CENTER[0])+","+str(settings.MAP_CENTER[1])+"""];
                        var view = new ol.View({
                          center: ol.proj.fromLonLat(center),
                          zoom: 3
                        });
                        var map = new ol.Map({target: 'map', layers: layers, view: view});
                        map.on('pointermove', showInfo);

                        var info = document.getElementById('info');
                        function showInfo(event) {
                            var features = map.getFeaturesAtPixel(event.pixel);
                            if (!features) {
                                info.innerText = '';
                                info.style.opacity = 0;
                                return;
                            }
                            var feature = features[0];
                            var properties = {};
                            feature.getKeys().filter(k => k != "geometry").forEach(k => {
                                let v = feature.get(k);
                                if (v != null) {
                                    properties[k] = v;
                                }
                            })
                            info.innerText = JSON.stringify(properties, null, 2);
                            info.style.opacity = 1;
                        }

                        var url = "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_month.geojson";
                        var format = new ol.format.GeoJSON({
                            featureProjection: view.getProjection(),
                            dataProjection: "EPSG:4326"
                        });
                        async function loadEarthquakes() {
                            let response = await fetch(url);
                            let data = await response.json();
                            let features = data.features
                                .filter(({properties}) => {
                                    return (
                                        properties.place.includes("California") ||
                                        properties.place.includes("Mexico")
                                    );
                                })
                                .map((f) => { return format.readFeature(f) });
                            console.log("Features:", features);
                            let sum = features.reduce((acc, f) => {
                                const e = f.getGeometry().getExtent();
                                const c = [(e[0] + e[2]) / 2.0, (e[1] + e[3]) / 2.0];
                                return [acc[0] + c[0], acc[1] + c[1]];
                            }, [0, 0]);
                            let center = ol.proj.toLonLat([sum[0] / features.length, sum[1] / features.length]);
                            console.log("Center:", center);
                            let styleFunction = (feature) => {
                                return new ol.style.Style({
                                    image: new ol.style.Circle({
                                        radius: 10,
                                        fill: new ol.style.Fill({
                                          color: '"""+settings.MAP_COLOR+"""'
                                        }),
                                        stroke: new ol.style.Stroke({
                                          color: '#000000',
                                          width: 2
                                        })
                                    })
                                })
                            };
                            let fl = new ol.layer.Vector({
                                source: new ol.source.Vector({features: features}),
                                style: styleFunction
                            });
                            map.addLayer(fl);
                            view.animate({center: ol.proj.fromLonLat(center, view.getProjection())}, {zoom: 4});
                        }
                        loadEarthquakes();
                    });
                </script>
            </head>
            <body>
                <div id="map" class="map">
                    <pre id="info"></pre>
                </div>
            </body>
        </html>
    """
    return HttpResponse(html)
