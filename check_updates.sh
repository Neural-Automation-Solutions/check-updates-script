#!/bin/bash

# Image and container names
IMAGE_NAME="yiannisha/vdc-1-image:latest"
CONTAINER_NAME="my_container"

# Pull the latest image from the local registry
docker pull $IMAGE_NAME

# Check if the container already exists
if [ "$(docker ps -aq -f name=^${CONTAINER_NAME}$)" ]; then
    # Container exists
    echo "Container exists. Checking if it needs an update or restart..."
    # Check if the container is running
    if [ "$(docker inspect -f '{{.State.Running}}' $CONTAINER_NAME)" == "true" ]; then
        # Get ID of the currently running image
        running_image=$(docker inspect --format='{{.Image}}' $CONTAINER_NAME)
        # Get ID of the latest image
        latest_image=$(docker inspect --format='{{.Id}}' $IMAGE_NAME)
        # Update container if the images do not match
        if [ "$running_image" != "$latest_image" ]; then
            echo "Updating container..."
            docker stop $CONTAINER_NAME
            docker rm $CONTAINER_NAME
            docker run -d --network host --name $CONTAINER_NAME $IMAGE_NAME
        else
            echo "Container is already up to date."
        fi
    else
        # Container exists but is not running, recreate it with the latest image and correct network settings
        echo "Container exists but is stopped. Recreating with the correct network settings..."
        docker rm $CONTAINER_NAME
        docker run -d --network host --name $CONTAINER_NAME $IMAGE_NAME
    fi
else
    # Container does not exist, create and start a new one
    echo "Creating and starting a new container..."
    docker run -d --network host --name $CONTAINER_NAME $IMAGE_NAME
fi

