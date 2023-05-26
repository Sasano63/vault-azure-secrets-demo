#!/bin/sh

# Note: It is required to set the following variables VAULT_ADDR, VAULT_TOKEN and VAULT_NAMESPACE (if applicable)
# Example:
export VAULT_ADDR=$(cat creds.json | jq -r '.vault_addr')
export VAULT_TOKEN=$(cat creds.json | jq -r '.vaulttoken')
export VAULT_NAMESPACE=admin

# get new Service Principal credentials
vault read azure/creds/vault-managed-principal

# view current leases
vault list sys/leases/lookup/azure/creds/vault-managed-principal

# get secret ID for existing principal
vault read azure/creds/existing-sp

# view current leases for existing principal
vault list sys/leases/lookup/azure/creds/existing-sp