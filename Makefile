GIT_COMMIT=$(shell git rev-list -1 HEAD)

prereqs:
	scripts/prereqs.sh

bin:
	@mkdir -p bin

bin_linux:
	@mkdir -p bin_linux

bin_linux/chamber: bin_linux
	curl -LsSo bin_linux/chamber https://github.com/segmentio/chamber/releases/download/v2.3.2/chamber-v2.3.2-linux-amd64
	chmod 755 bin_linux/chamber

rds-combined-ca-bundle.pem:
	curl -sSo rds-combined-ca-bundle.pem https://s3.amazonaws.com/rds-downloads/rds-combined-ca-bundle.pem

up: rds-combined-ca-bundle.pem bin_linux/chamber
ifndef CIRCLECI
	@echo "Stopping system postgresql"
	which brew && brew services stop postgresql 2> /dev/null || true
endif
	mkdir -p ./mnt/postgresql
	docker-compose up -d db
	@echo Sleeping for 5 seconds
	sleep 5
	docker-compose up --build web

shell:
	docker-compose exec web bash

down:
	docker-compose down

build_gunicorn:
	docker build -f Dockerfile.gunicorn -t sunrise:web .

migrate:
	docker-compose exec web python manage.py migrate

unit_tests:
	@docker-compose exec \
	-e APP_DEBUG -e ALLOWED_HOSTS -e APP_SECRET_KEY \
	-e DB_NAME -e DB_USER -e DB_PASSWORD -e DB_HOST web \
	python -m unittest -v sunrise.tests

server_tests:
	@docker-compose exec web python manage.py test

build_cypress:
	@docker build -t sunrise/cypress:$(GIT_COMMIT) -f Dockerfile.cypress .

e2e_tests: build_cypress
	docker run --rm -it -e "CYPRESS_baseUrl=http://localhost:$$APP_PORT" --net=host -v $(PWD)/cypress:/cypress sunrise/cypress

define SUPERUSER_BODY
from django.contrib.auth import get_user_model
User = get_user_model()
try:
  User.objects.get(username='$$ADMIN_USER')
except User.DoesNotExist:
  User.objects.create_superuser('$$ADMIN_USER', '$$ADMIN_EMAIL', '$$ADMIN_PASSWORD')
endef

export SUPERUSER_BODY
superuser: migrate
	@echo "$$SUPERUSER_BODY" | docker-compose exec -T web python manage.py shell

secretkey:
	@openssl rand -hex 64

init: superuser
	@echo "Sunrise initialized"

psql:
	psql -d $$DB_NAME -U $$DB_USER -h localhost -p $$DB_PORT

clean:
	rm -rf ./bin
	rm -rf ./mnt
	rm -f Pipfile
	rm -f Pipfile.lock
	docker-compose rm -f

.PHONY: clean up down migrate psql superuser secretkey build_deployed build_cypress e2e_tests
