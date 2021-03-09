#!/bin/sh
cp /etc/munge/munge.key.tmp/MUNGE_KEY /etc/munge/munge.key
chown munge:munge /etc/munge/munge.key
chmod 0700 /etc/munge/munge.key
service ssh start
service rpcbind start
service nfs-common start
service munge start
service slurmd start
exec su - jovyan -c sleep infinity
