#!/bin/bash
set -x

DOMAIN_NAME=$1
CLASS_NAMES=$2

if [ "`echo ${NODE_HOST}`" == "" ]
then
  NODE_HOST="mogile-node"
fi

if [ "`echo ${NODE_PORT}`" == "" ]
then
  NODE_PORT="7500"
fi

# Start mysql database
mysqld &

# wait for node to start
sleep 5

sudo -u mogile mogilefsd --daemon -c /etc/mogilefs/mogilefsd.conf

mogadm --trackers=127.0.0.1:7001 host add mogilestorage --ip=${NODE_HOST} --port=${NODE_PORT} --status=alive
mogadm --trackers=127.0.0.1:7001 device add mogilestorage 1
mogadm --trackers=127.0.0.1:7001 device add mogilestorage 2

if [ "`echo ${DOMAIN_NAME}`" != "" ]
then
  mogadm --trackers=127.0.0.1:7001 domain add ${DOMAIN_NAME}
  mogadm class modify sbf default --replpolicy='MultipleDevices()'

  # Add all given classes
  if [ "`echo ${CLASS_NAMES}`" != "" ]
  then
    for class in ${CLASS_NAMES}
    do
      mogadm --trackers=127.0.0.1:7001 class add ${DOMAIN_NAME} $class --replpolicy="MultipleDevices()"
    done
  fi
fi

mogadm check

pkill mogilefsd

sudo -u mogile mogilefsd -c /etc/mogilefs/mogilefsd.conf
