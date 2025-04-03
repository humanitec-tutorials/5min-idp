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

export OPERATOR_NS=humanitec-operator-system

export TF_VAR_humanitec_org=$HUMANITEC_ORG
export TF_VAR_kubeconfig=$kubeconfig_docker
export TF_VAR_operator_ns=$OPERATOR_NS

terraform -chdir=setup/terraform init -upgrade
terraform -chdir=setup/terraform apply -auto-approve

# SecretStore must be created after the TF plan, because of CRD validation: https://github.com/hashicorp/terraform-provider-kubernetes/issues/2597
kubectl apply -f setup/secretstore/secretstore.yaml -n $OPERATOR_NS

echo ""
echo ">>>> Everything prepared, ready to deploy application."
