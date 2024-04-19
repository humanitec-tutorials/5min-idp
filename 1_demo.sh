#!/usr/bin/env bash
set -eo pipefail

echo "Deploying workload"

humanitec_app=$(terraform -chdir=setup/terraform output -raw humanitec_app)

humctl score deploy --app "$humanitec_app" --env development -f ./score.yaml

echo "Waiting for deployment"

sleep 1

DEPLOYMENT_ID=$(humctl get deployment . -o json \
    --app "$humanitec_app" \
    --env development \
    | jq -r .metadata.id)

IS_DONE=false
CURRENT_STATUS=""

while [ "$IS_DONE" = false ]; do
  CURRENT_STATUS=$(humctl get deployment "${DEPLOYMENT_ID}" -o json \
    --app "$humanitec_app" \
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
  humctl get deployment-error --app "$humanitec_app" --env development
  exit 1
fi

workload_host=$(humctl get active-resources --app "$humanitec_app" --env development -o yaml | yq '.[] | select(.metadata.type == "route") | .status.resource.host')

echo "Waiting for workload to be available"

# manually change the host here as the workload host resolves to localhost, which is not reachable from the container
if curl -I --retry 20 --retry-delay 3 --retry-all-errors --fail \
  --connect-to "$workload_host:30080:5min-idp-control-plane:30080" \
  "http://$workload_host:30080"; then
  echo "Workload available at: http://$workload_host:30080"
else
  echo "Workload not available"
  kubectl get pods --all-namespaces
  kubectl -n "$humanitec_app-development" logs deployment/hello-world
  exit 1
fi
