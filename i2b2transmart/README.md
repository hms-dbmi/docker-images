# i2b2/tranSMART

### Build a docker image

To build a new docker image, issue the following command:

```
read -p "Please enter the tag for the new image:" DOCKER_IMAGE_TAG
docker build --rm \
	--build-arg version=${DOCKER_IMAGE_TAG}\
	--tag dbmi/i2b2transmart:${DOCKER_IMAGE_TAG} .


```

This command will build a new local image, initially. It will download 

### Deploy the new image to the Docker Hub

Ensure that the UNIX environment variable `DOCKER_IMAGE_TAG` is as intended.

```
docker login 
docker push dbmi/i2b2transmart:${DOCKER_IMAGE_TAG}


```

