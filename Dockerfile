FROM ubuntu:trusty
MAINTAINER Jeffery Utter "jeff.utter@firespring.com"

RUN apt-get update \
  && apt-get install -y cpanminus build-essential supervisor libdbd-mysql-perl sysstat \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /etc/mogilefs \
  && mkdir -p /var/mogdata/

RUN cpanm install --force MogileFS::Server \
  && cpanm install DBD::SQLite \
  && cpanm install MogileFS::Utils

RUN mogdbsetup --type=SQLite --yes --dbname=/var/mogdata/mogilefs.sqlite3

ADD mogilefsd.conf /etc/mogilefs/mogilefsd.conf
ADD mogilefs.conf /root/.mogilefs.conf
ADD run.sh /run.sh

RUN adduser mogile --system --disabled-password \
  && chown mogile -R /var/mogdata

EXPOSE 7001

ENTRYPOINT ["/run.sh"]
