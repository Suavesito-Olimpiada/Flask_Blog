FROM python:3.8-slim-buster

RUN mkdir /portfolio
COPY requirements.txt /portfolio
WORKDIR /portfolio
RUN pip3 install -r requirements.txt

COPY . /portfolio

ENTRYPOINT ["sh", "entrypoint.sh"]
