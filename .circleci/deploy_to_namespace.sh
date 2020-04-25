#!/bin/bash -Eeu

readonly NAMESPACE="${1}" # beta|prod

# misc env-vars are in ci context

echo ${GCP_K8S_CREDENTIALS} > /gcp/gcp-credentials.json

gcloud auth activate-service-account \
  "${SERVICE_ACCOUNT}" \
  --key-file=/gcp/gcp-credentials.json
gcloud container clusters get-credentials \
  "${CLUSTER}" \
  --zone "${ZONE}" \
  --project "${PROJECT}"

helm init --client-only
helm repo add praqma https://praqma-helm-repo.s3.amazonaws.com/
helm upgrade \
  --install \
  --namespace=${NAMESPACE} \
  --set-string containers[0].tag=${CIRCLE_SHA1:0:7} \
  --values .circleci/saver-values.yml \
  --values .circleci/saver-pvc-${NAMESPACE}.yml \
  ${NAMESPACE}-saver \
  praqma/cyber-dojo-service \
  --version 0.2.5
