#!/usr/bin/env bash
set -eo pipefail

if ! humctl get application 5min-idp; then
  humctl create application 5min-idp
  echo "App created"
fi

echo "Deploying workload"

humctl score deploy --app 5min-idp --env development -f ./score.yaml

echo "Waiting for deployment"

sleep 1

DEPLOYMENT_ID=$(humctl get deployment . -o json \
    --app 5min-idp \
    --env development \
    | jq -r .metadata.id)

IS_DONE=false
CURRENT_STATUS=""

while [ "$IS_DONE" = false ]; do
  CURRENT_STATUS=$(humctl get deployment "${DEPLOYMENT_ID}" -o json \
    --app 5min-idp \
    --env development \
    | jq -r .status.status)

  if [ "$CURRENT_STATUS" = "in progress" ]; then
    echo "Deployment still in progress..."
    sleep 2
  elif [ "$CURRENT_STATUS" = "failed" ]; then
    echo "Deployment failed!"
    IS_DONE=true
  else
    echo "Deployment complete!"
    IS_DONE=true
  fi
done
if [ "$CURRENT_STATUS" = "failed" ]; then
  humctl get deployment-error --app 5min-idp --env development
  exit 1
fi

workload_host=$(humctl get active-resources --app 5min-idp --env development -o yaml | yq '.[] | select(.metadata.type == "route") | .status.resource.host')

echo "Waiting for workload to be available"

# manually change the host here as the workload host resolves to localhost, which is not reachable from the container
curl -I --retry 20 --retry-delay 3 --retry-all-errors --fail \
  --connect-to "$workload_host:30080:5min-idp-control-plane:30080" \
  "http://$workload_host:30080"

echo "Workload available at: http://$workload_host:30080"
