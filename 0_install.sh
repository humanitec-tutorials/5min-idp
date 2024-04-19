#!/usr/bin/env bash
set -eo pipefail

mkdir -p /state/kube

if [ ! -f /state/kube/config.yaml ]; then
  kind create cluster -n 5min-idp --kubeconfig /state/kube/config.yaml --config ./setup/kind/cluster.yaml
fi

# connect current container to the kind network
container_name="5min-idp"
if [ "$(docker inspect -f='{{json .NetworkSettings.Networks.kind}}' "${container_name}")" = 'null' ]; then
  docker network connect "kind" "${container_name}"
fi

# used by humanitec-agent / inside docker to reach the cluster
kubeconfig_docker=/state/kube/config-internal.yaml
kind export kubeconfig --internal  -n 5min-idp --kubeconfig "$kubeconfig_docker"

humctl_token=$(yq .token /root/.humctl)

export HUMANITEC_TOKEN=$humctl_token
export TF_VAR_humanitec_org=$HUMANITEC_ORG
export TF_VAR_kubeconfig=$kubeconfig_docker

terraform -chdir=setup/terraform init -upgrade
terraform -chdir=setup/terraform apply -auto-approve

echo ""
echo ">>>> Everything prepared, ready to deploy application."
