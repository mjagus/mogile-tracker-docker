#!/bin/sh
set -x

domain=$1
classes=$2

sleep 5 #wait for node to start

sudo -u mogile mogilefsd --daemon -c /etc/mogilefs/mogilefsd.conf

mogadm --trackers=127.0.0.1:7001 host add mogilestorage --ip=mogile-node --port=7500 --status=alive
mogadm --trackers=127.0.0.1:7001 device add mogilestorage 1

if [ "$domain" != "" ]
then
  mogadm --trackers=127.0.0.1:7001 domain add $domain

  # Add all given classes
  if [ "$classes" != "" ]
  then
    for class in $classes
    do
      mogadm --trackers=127.0.0.1:7001 class add $domain $class
    done
  fi
fi

mogadm check

pkill mogilefsd

sudo -u mogile mogilefsd -c /etc/mogilefs/mogilefsd.conf
