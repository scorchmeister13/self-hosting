#!/bin/bash

NTFY_TOPIC="check-docker-containers"

docker events --filter 'event=die' --format '{{.Actor.Attributes.name}}' | while read container
do
    curl -H "Title: Docker Alert" \
         -H "Priority: high" \
         -d "Container $container stopped on $(hostname) at $(date)" \
         https://ntfy.scorch13.com/$NTFY_TOPIC
done