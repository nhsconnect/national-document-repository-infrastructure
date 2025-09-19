#!/bin/bash

# This is for generating certs for the NHS Digital API Management Platform. They are used during mTLS authentication.
# Taken from https://github.com/NHSDigital/api-management-cert-generation/blob/master/README.md
# This script is likely needed if certificates need to be regenerated due to expiry or if new environments are added etc.
# Run create_csrs.sh to generate keys into keys/ and CSRs into csrs/ to send to a trusted CA.
# Usage:
# ./create_csrs.sh

set -euo pipefail

mkdir -p csrs
mkdir -p keys

openssl req -new -newkey rsa:4096 -nodes -sha256 -keyout keys/dev.api.service.nhs.uk.key -out csrs/dev.api.service.nhs.uk.csr -config confs/dev.conf -extensions v3_req
openssl req -new -newkey rsa:4096 -nodes -sha256 -keyout keys/test.api.service.nhs.uk.key -out csrs/test.api.service.nhs.uk.csr -config confs/test.conf -extensions v3_req
openssl req -new -newkey rsa:4096 -nodes -sha256 -keyout keys/preprod.api.service.nhs.uk.key -out csrs/preprod.api.service.nhs.uk.csr -config confs/preprod.conf -extensions v3_req
openssl req -new -newkey rsa:4096 -nodes -sha256 -keyout keys/api.service.nhs.uk.key -out csrs/api.service.nhs.uk.csr -config confs/prod.conf -extensions v3_req
