# Overview

The [openshift-agent-install-config.yaml](openshift-agent-install-config.yaml) ansible playbook creates the preferred configuration inputs used by [Installing an OpenShift Container Platform cluster with the Agent-based Installer](https://docs.openshift.com/container-platform/latest/installing/installing_with_agent_based_installer/installing-with-agent-based-installer.html):
- install-config.yaml
- agent-config.yaml

The following are required:
- file containing Red Hat image pull secret
- file containing SSH public key
- optionally file containing private CA in PEM format

The playbook assumes that all OpenShift nodes in the cluster to install has the same disk and network adapter layout.

## Usage

### Create cluster config

Create a yaml file like the following (filename in this example is `cluster-config.yaml`)

```
baseDomain: example.com
clusterName: cluster01

clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
serviceNetwork:
  - 172.30.0.0/16
machineNetwork:
  - cidr: 172.16.186.0/24

# optional; comment the four lines below if no proxy is in use
proxy:
  httpsProxy: http://proxy.example.com:8080
  httpProxy: http://proxy.examle.com:8080
  noProxy: example.com,10.128.0.0/14,172.30.0.0/16,172.16.186.0/24

# path to private ca bundle in PEM format
additionalTrustBundle: ~/private-ca.crt

# path to redhat image pull secret file
pullSecret: ~/pull-secret.json

# path to ssh public key file
sshKey: ~/.ssh/id_rsa.pub

# the disk device to install rhcos
installDevice: /dev/sda

# get the urls to download rhcos image from:
# openshift-install coreos print-stream-json | jq -r .architectures[].artifacts.metal.formats.iso.disk.location
rhcosLiveIso: /iso-images/rhcos-414.92.202310210434-0-live.x86_64.iso

# directory to store custom iso files
customISODir: /tmp/iso-images

# dns servers
dnsServers:
  - 172.16.200.8
  - 172.16.200.9

# static routes
routes:
  - destination: 0.0.0.0/0
    next-hop-address: 172.16.187.254
    next-hop-interface: ens160

# list of nodes
hosts:
  - role: master
    interfaces:         # interfaces of the worker node
      - name: ens192    # this must be the actual interface name
        mac-address: 00:50:56:AA:BB:11
        dhcp: false
        ip: 172.16.187.11
        prefix-length: 24
  - role: master
    interfaces:
      - name: ens192
        mac-address: 00:50:56:AA:BB:12
        dhcp: false
        ip: 172.16.187.12
        prefix-length: 24
  - role: master
    interfaces:
      - name: ens192
        mac-address: 00:50:56:AA:BB:13
        dhcp: false
        ip: 172.16.187.13
        prefix-length: 24
  - role: worker
    interfaces:
      - name: ens192
        mac-address: 00:50:56:AA:BB:21
        dhcp: false
        ip: 172.16.187.21
        prefix-length: 24
  - role: worker
    interfaces:
      - name: ens192
        mac-address: 00:50:56:AA:BB:22
        dhcp: false
        ip: 172.16.187.22
        prefix-length: 24
  - role: worker
    interfaces:
      - name: ens192
        mac-address: 00:50:56:AA:BB:23
        dhcp: false
        ip: 172.16.187.23
        prefix-length: 24
```

### Run the playbook

```
ansible-playbook openshift-agent-install-config.yaml -e cluster_config=cluster-config.yaml
```

The `install-config.yaml` and `agent-config.yaml` files are created in the current working directory.
