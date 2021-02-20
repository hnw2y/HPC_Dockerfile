#!/bin/sh

service ssh start
service rpcbind start
service nfs-common start
service munge start
service slurmd start
exec su - jovyan -c sleep infinity