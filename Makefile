bin:
	@mkdir -p bin

up:
ifndef CIRCLECI
	@echo "Stopping system postgresql"
	which brew && brew services stop postgresql 2> /dev/null || true
endif
	mkdir -p ./mnt/postgresql
	docker-compose up -d db
	@echo Sleeping for 5 seconds
	sleep 5
	docker-compose up web

down:
	docker-compose down

migrate:
	docker-compose exec web python manage.py migrate

test:
	docker-compose exec web python manage.py test


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
	openssl rand -hex 64

init: superuser
	@echo "Sunrise initialized"

psql:
	psql -d $$DB_NAME -U $$DB_USER -h localhost -p $$DB_PORT

clean:
	rm -rf ./bin
	rm -rf ./mnt
	rm -f Pipfile
	rm -f Pipfile.lock

.PHONY: clean up down migrate psql superuser secretkey
