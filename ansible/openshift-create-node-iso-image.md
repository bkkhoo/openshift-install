# Overview

The [openshift-create-node-iso-image.yaml](openshift-create-node-iso-image.yaml) ansible playbook creates custom ISO image for adding new nodes to an existing OpenShift cluster. THe ISO image boots with the configured static IP address and install RHCOS on the node.

The following are required:
- file containing SSH public key
- Red Hat CoreOS Live boot ISO image; use the following command to get the URL to download the ISO image: (make sure to use teh correct version of `openshift-install` binary):
  ```
  openshift-install coreos print-stream-json | jq -r .architectures[].artifacts.metal.formats.iso.disk.location
  ```
- [coreos-installer](https://coreos.github.io/coreos-installer/getting-started/) utility
- OpenShift target cluster login with credential that can get secret from `openshift-machine-api` namespace

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

### Login to target OpenShift cluster

```
oc login -u <username>
```

### Run the playbook

```
ansible-playbook openshift-create-node-iso-image.yaml -e cluster_config=cluster-config.yaml
```
