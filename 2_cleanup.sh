#!/usr/bin/env bash
set -eo pipefail

humctl_token=$(yq .token /root/.humctl)
kubeconfig_docker=$(pwd)/kube/config-internal.yaml

export HUMANITEC_TOKEN=$humctl_token
export TF_VAR_humanitec_org=$HUMANITEC_ORG
export TF_VAR_kubeconfig=$kubeconfig_docker


if humctl get application 5min-idp; then
  humctl delete application 5min-idp
fi

terraform -chdir=setup/terraform destroy -auto-approve

kind delete cluster -n 5min-idp

rm -rf ./kube
