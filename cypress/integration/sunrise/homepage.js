/* global cy */

describe('The Home Page', function() {

  beforeEach(function() {
    cy.visit('/');
  })

  it('map exists', function() {
    cy.get('#map');
    cy.get("#map").get('#info');
  });

  it('info exists', function() {
    cy.get("#map").get('#info');
  });


  it('viewport exists', function() {
    cy.get("#map").get(".ol-viewport")
  });

  it('zoom control exists', function() {
    cy.get("#map").get(".ol-viewport").get(".ol-zoom")
  });

});
