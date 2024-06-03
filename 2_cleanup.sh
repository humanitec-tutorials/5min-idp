#!/usr/bin/env bash
set -eo pipefail

# connect current container to the kind network
container_name="5min-idp"
if [ "$(docker inspect -f='{{json .NetworkSettings.Networks.kind}}' "${container_name}")" = 'null' ]; then
  docker network connect "kind" "${container_name}"
fi

kubeconfig_docker=/state/kube/config-internal.yaml

export TF_VAR_humanitec_org=$HUMANITEC_ORG
export TF_VAR_kubeconfig=$kubeconfig_docker

terraform -chdir=setup/terraform init -upgrade
terraform -chdir=setup/terraform destroy -auto-approve

kind delete cluster -n 5min-idp

rm -rf /state/kube
