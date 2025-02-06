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

if [[ $1 == 'mark' ]]; then
  govc vm.markastemplate "ubuntu-2404-kube-v1.32.0"
fi

if [[ $1 == 'pool' ]]; then
  govc pool.info */Resources
fi

# https://github.com/kubernetes-sigs/cluster-api-provider-vsphere?tab=readme-ov-file#kubernetes-versions-with-published-ovas
if [[ $1 == 'ova' ]]; then

# Create your cloud-init YAML (user-data.yaml):
cat > user-data.yaml << EOF
users:
  - default
  - name: me
    passwd: $2
    shell: /bin/bash
    lock-passwd: false
    ssh_pwauth: True
    chpasswd: { expire: False }
    sudo: ALL=(ALL) NOPASSWD:ALL
    groups: users, admin
    ssh_authorized_keys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHOnIDzIGmPPufF1B7B8BupYx6JqkyLtYdu5lYr5DXoh
EOF

# Base64-encode the cloud-init data:
USER_DATA_B64=$(base64 < user-data.yaml | tr -d '\n')

# Create the options JSON file (options.json):
cat > spec.json << EOF
{
  "DiskProvisioning": "thin",
  "IPAllocationPolicy": "dhcpPolicy",
  "IPProtocol": "IPv4",
  "NetworkMapping": [
    {
      "Name": "nic0",
      "Network": "LAN"
    }
  ],
  "guestinfo.userdata": "$USER_DATA_B64",
  "guestinfo.userdata.encoding": "base64"
}
EOF

govc import.ova -options=spec.json ~/Downloads/ubuntu-2404-kube-v1.32.0.ova

fi