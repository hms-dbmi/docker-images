#!/bin/sh

cp /etc/hadoop/conf/yarn-site.xml ./
cp /etc/hadoop/conf/core-site.xml ./
cp /home/hadoop/hail-* ./
cp /usr/share/aws/emr/emrfs/lib/emrfs-hadoop-assembly-2.20.0.jar ./

docker build . \
  --build-arg GITHUB_USERNAME=<YOUR_GITHUB_USERNAME> \
  --build-arg GITHUB_PASSWORD="<YOUR_GITHUB_PASSWORD>" \
  --file Dockerfile.jupyternotebook \
  --rm \
  --tag "avillachlab/jupyter-notebook"
RC=$!
RRC=$?
echo "Building new image: ${RC} and RRC: ${RRC}"
exit

docker stop "jupyter-notebook_1"
RC=$?
echo "Stopping previous container: ${RC}"

docker rm "jupyter-notebook_1"
RC=$?
echo "Removing previous container: ${RC}"

docker run --name "jupyter-notebook_1" --detach "avillachlab/jupyter-notebook"
RC=$?
echo "Running container: ${RC}"

docker exec -it "jupyter-notebook_1" bash
RC=$?
echo "Logging into the container: ${RC}"
