#!/bin/bash
set -eo pipefail

export GOVC_DATACENTER=''
export GOVC_URL='192.168.1.51'
export GOVC_HOST='esxi2.cikli.com'
export GOVC_DATASTORE='datastore1'
export GOVC_NETWORK='LAN'
export GOVC_USERNAME='root'
export GOVC_PASSWORD="$2"
export GOVC_INSECURE=true

if [[ $1 == 'mark' ]]
then
  govc vm.markastemplate "ubuntu-2404-kube-v1.32.0"
fi

if [[ $1 == 'pool' ]]
then
  govc pool.info */Resources
fi

# https://github.com/kubernetes-sigs/cluster-api-provider-vsphere?tab=readme-ov-file#kubernetes-versions-with-published-ovas
if [[ $1 == 'ova' ]]
then
  govc import.ova -options=spec.json ~/Downloads/ubuntu-2404-kube-v1.32.0.ova
fi