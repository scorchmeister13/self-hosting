#!/bin/bash

NTFY_TOPIC="check-docker-containers"

docker events --filter 'event=die' --format '{{.Actor.Attributes.name}}' | while read container
do
    # Check every 10 seconds for 1 minute (6 checks total)
    still_down=true
    for i in {1..6}; do
        sleep 10
        # Check if container is running again
        if docker ps --format '{{.Names}}' | grep -q "^${container}$"; then
            # Container came back up, don't send notification
            still_down=false
            break
        fi
    done
    
    # If container is still down after 1 minute, send notification
    if [ "$still_down" = true ]; then
        curl -H "Title: Docker Alert" \
             -H "Priority: high" \
             -d "Container $container stopped on $(hostname) at $(date)" \
             https://ntfy.scorch13.com/$NTFY_TOPIC
    fi
done