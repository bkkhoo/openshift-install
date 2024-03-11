#!/usr/bin/env bash
#
# this script delete namespace that are stuck in terminating state

NAMESPACE=$1

if [ -z "${NAMESPACE}" ]; then
  echo "please provide the namespace"
  exit 1
fi

oc get ns ${NAMESPACE} -o json > /tmp/ns.json

jq '.spec.finalizers = []' /tmp/ns.json > /tmp/new-ns.json

curl -k -X PUT -d @/tmp/new-ns.json \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $(oc whoami -t)"  \
  $(oc whoami --show-server)/api/v1/namespaces/${NAMESPACE}/finalize

rm -f /tmp/ns.json /tmp/new-ns.json
