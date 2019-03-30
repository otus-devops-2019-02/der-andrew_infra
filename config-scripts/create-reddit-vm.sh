#!/bin/bash
set -e

echo "---=== Creating reddit VM... ===---"
gcloud compute --project=infra-451193 instances create reddit-app-full \
--zone=europe-west1-d --machine-type=g1-small \
--subnet=default --network-tier=PREMIUM --maintenance-policy=MIGRATE \
--service-account=735155033088-compute@developer.gserviceaccount.com \
--scopes=https://www.googleapis.com/auth/devstorage.read_only,\
https://www.googleapis.com/auth/logging.write,\
https://www.googleapis.com/auth/monitoring.write,\
https://www.googleapis.com/auth/servicecontrol,\
https://www.googleapis.com/auth/service.management.readonly,\
https://www.googleapis.com/auth/trace.append \
--tags=puma-server --image=reddit-full-1553980024 --image-project=infra-451193 \
--boot-disk-size=11GB --boot-disk-type=pd-standard --boot-disk-device-name=reddit-app-full
