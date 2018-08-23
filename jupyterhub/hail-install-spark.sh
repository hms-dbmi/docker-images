#!/bin/sh

cd /tmp
wget http://d3kbcqa49mib13.cloudfront.net/spark-2.2.0-bin-hadoop2.7.tgz
tar -xvf spark-2.2.0-bin-hadoop2.7.tgz && rm -f spark-2.2.0-bin-hadoop2.7.tgz
ln -s /tmp/spark-2.2.0-bin-hadoop2.7/ /usr/lib/spark
rm -f /tmp/spark-2.2.0-bin-hadoop2.7.tgz
