#!/usr/bin/dumb-init /bin/bash

set -x

if [ "`echo ${NODE_HOST}`" == "" ]
then
  NODE_HOST=$(getent hosts mogile-node | awk '{ print $1 }')
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

mogadm host add mogilestorage --ip=${NODE_HOST} --port=${NODE_PORT} --status=alive
mogadm device add mogilestorage 1
mogadm device add mogilestorage 2

# Add all given domains
if [ "`echo ${DOMAIN_NAMES}`" != "" ]
then
    for domain in ${DOMAIN_NAMES}
    do
      mogadm domain add $domain

      # Add all given classes
      if [ "`echo ${CLASS_NAMES}`" != "" ]
      then
        for class in ${CLASS_NAMES}
        do
          mogadm --trackers=127.0.0.1:7001 class add $domain $class --replpolicy="MultipleDevices()"
        done
      fi
    done
fi

mogadm check

pkill mogilefsd

sudo -u mogile mogilefsd -c /etc/mogilefs/mogilefsd.conf
