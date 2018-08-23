#!/bin/sh
#
# This script will start a spark job, using the specified Python script. Modified to
# run Python3, which is expected to be installed on the machine.
#

export SPARK_HOME=/usr/lib/spark
export PATH=$PATH:$SPARK_HOME/bin
export HAILPROXY_HOME=/opt/hail/HailProxy
export PYTHONPATH="/home/hadoop/hail-python.zip:$SPARK_HOME/python:$(echo ${SPARK_HOME}/python/lib/py4j-*-src.zip | tr '\n' ':')"
export PYSPARK_PYTHON=python3
JAR_PATH="/home/hadoop/hail-all-spark.jar:/usr/share/aws/emr/emrfs/lib/emrfs-hadoop-assembly-2.20.0.jar"
export PYSPARK_SUBMIT_ARGS="--conf spark.driver.extraClassPath='$JAR_PATH' --conf spark.executor.extraClassPath='$JAR_PATH' pyspark-shell"

spark_core_jars=${SPARK_HOME}/jars/spark-core*.jar
if [ ${#spark_core_jars[@]} -eq 0 ]
then
    echo "Could not find a spark-core jar in ${SPARK_HOME}/jars, are you sure SPARK_HOME is set correctly?" >&2
    exit -1
fi

# This script will submit a Python script as a Spark job on the cluster.
spark-submit \
	--jars /home/hadoop/hail-all-spark.jar,/tmp/emrfs-hadoop-assembly-2.20.0.jar \
	--py-files /home/hadoop/hail-python.zip \
	$@
