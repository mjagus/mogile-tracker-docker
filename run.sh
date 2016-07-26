#!/bin/bash
set -x

domain=$1
classes=$2

node=$3
if [ "`echo $node`" == "" ]
then
  node="mogile-node"
fi

port=$4
if [ "`echo $port`" == "" ]
then
  port="7500"
fi

# Start mysql database
mysqld &

# wait for node to start
sleep 5

sudo -u mogile mogilefsd --daemon -c /etc/mogilefs/mogilefsd.conf

mogadm --trackers=127.0.0.1:7001 host add mogilestorage --ip=$node --port=$port --status=alive
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
