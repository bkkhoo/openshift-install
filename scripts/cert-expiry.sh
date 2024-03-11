#!/usr/bin/env bash

echo -e "NAMESPACE\tNAME\tEXPIRY"
oc get secrets -A -o go-template='{{range .items}}{{if eq .type "kubernetes.io/tls"}}{{.metadata.namespace}}{{" "}}{{.metadata.name}}{{" "}}{{index .data "tls.crt"}}{{"\n"}}{{end}}{{end}}' |
while read namespace name cert; do
  echo -en "$namespace\t$name\t"
  echo $cert | base64 -d | openssl x509 -noout -enddate
done | column -t
