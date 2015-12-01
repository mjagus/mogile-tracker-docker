#!/bin/bash
set -x

if [ "`basename $1`" == "bash" ]
then
  exec "$@"
  exit $?
fi

domain=$1
classes=$2

sleep 5 #wait for node to start

sudo -u mogile mogilefsd --daemon -c /etc/mogilefs/mogilefsd.conf

mogadm --trackers=127.0.0.1:7001 host add mogilestorage --ip=mogile-node --port=7500 --status=alive
mogadm --trackers=127.0.0.1:7001 device add mogilestorage 1
mogadm --trackers=127.0.0.1:7001 device add mogilestorage 2

if [ "$domain" != "" ]
then
  mogadm --trackers=127.0.0.1:7001 domain add $domain
  mogadm class modify sbf default --replpolicy='MultipleDevices()'

  # Add all given classes
  if [ "$classes" != "" ]
  then
    for class in $classes
    do
      mogadm --trackers=127.0.0.1:7001 class add $domain $class --replpolicy="MultipleDevices()"
    done
  fi
fi

mogadm check

pkill mogilefsd

sudo -u mogile mogilefsd -c /etc/mogilefs/mogilefsd.conf
