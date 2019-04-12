import os
import multiprocessing

workers = multiprocessing.cpu_count() * 2 + 1
worker_class = 'gevent'

loglevel = os.getenv("GUNICORN_LOG_LEVEL", "debug")

accesslog = os.getenv("GUNICORN_ACCESS_LOG", "-")

errorlog = os.getenv("GUNICORN_ERROR_LOG", "-")

timeout = int(os.getenv("GUNICORN_TIMEOUT", "360"))

keep_alive = int(os.getenv("GUNICORN_KEEP_ALIVE", "5"))

envvars = [
  "APP_TITLE",
  "APP_SECRET_KEY",
  "APP_DEBUG",
  "ALLOWED_HOSTS",
  "DB_NAME",
  "DB_USER",
  "DB_PASSWORD",
  "DB_HOST",
  "DB_PORT",
  "MAP_CENTER",
  "MAP_COLOR"
]

raw_env = [x+"="+os.environ.get(x) for x in envvars if os.environ.get(x) is not None]
