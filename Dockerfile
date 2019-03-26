FROM python:3
ENV PYTHONUNBUFFERED 1
RUN mkdir /sunrise
WORKDIR /sunrise
COPY requirements.txt /sunrise/
RUN pip install -r requirements.txt
COPY . /sunrise/
