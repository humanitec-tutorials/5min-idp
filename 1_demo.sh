#!/usr/bin/env bash
set -eo pipefail

if ! humctl get application 5min-idp; then
  humctl create application 5min-idp
fi

humctl score deploy --app 5min-idp --env development -f ./score.yaml

echo "Waiting for deploy"

# TODO Use humctl to wait for deploy to finish once GA
sleep 20

workload_host=$(humctl get active-resources --app 5min-idp --env development -o yaml | yq '.[] | select(.metadata.type == "route") | .status.resource.host')

echo "Workload available at: http://$workload_host:30080"
