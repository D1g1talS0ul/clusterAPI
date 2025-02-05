#!/bin/bash
set -eo pipefail

command=$1
cluster_name=$2
cluster_version=$3

if [[ -z "$1" || -z "$2" || -z "$3" ]]; then
  echo "All 3 options must be set: command, cluster name, and cluster version must be set."
  echo "For example: ./capv.sh init my-cluster 1.30.0"
  exit 1
fi

if [[ "$command" == 'init' ]]; then
  #clusterctl init --infrastructure vsphere:v1.12.0 --wait-providers --target-namespace ${cluster_name} --ipam in-cluster --config clusterctl-ipam.yaml
  clusterctl init --infrastructure vsphere:v1.12.0 --wait-providers --target-namespace ${cluster_name} --config clusterctl.yaml
fi


if [[ "$command" == 'create' ]]; then
#   kubectl apply -f sc.yaml
#   kubectl apply -f pvc.yaml
#   kubectl apply -f ipam.yaml

  #clusterctl generate cluster ${cluster_name} --config clusterctl.yaml --infrastructure vsphere:v1.12.0 --flavor node-ipam --kubernetes-version v${cluster_version} --control-plane-machine-count 1 --worker-machine-count 3 > vsphere-cluster-${cluster_name}.yaml
  clusterctl generate cluster ${cluster_name} --config clusterctl.yaml --infrastructure vsphere:v1.12.0 --kubernetes-version v${cluster_version} --control-plane-machine-count 1 --worker-machine-count 3 > vsphere-cluster-${cluster_name}.yaml

  # This apply will actually create the cluster
  kubectl apply -f vsphere-cluster-${cluster_name}.yaml
fi

if [[ "$command" == 'info' ]]; then
  clusterctl describe cluster ${cluster_name} --echo --grouping=false
fi

if [[ "$command" == 'delete' ]]; then
  kubectl delete cluster ${cluster_name}
fi