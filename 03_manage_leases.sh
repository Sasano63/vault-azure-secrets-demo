#!/bin/sh

# Note: It is required to set the following variables VAULT_ADDR, VAULT_TOKEN and VAULT_NAMESPACE (if applicable)
# Example:
export VAULT_ADDR=$(cat creds.json | jq -r '.vault_addr')
export VAULT_TOKEN=$(cat creds.json | jq -r '.vaulttoken')
export VAULT_NAMESPACE=admin

# lookup leases and manage one lease
LEASE_ID=$(vault list -format=json sys/leases/lookup/azure/creds/vault-managed-principal | jq -r ".[0]")
vault lease renew azure/creds/vault-managed-principal/$LEASE_ID
vault lease revoke azure/creds/vault-managed-principal/$LEASE_ID

# view current leases
# vault list sys/leases/lookup/azure/creds/vault-managed-principal
vault list sys/leases/lookup/azure/creds/existing-sp

# revoke all leases for this role
# vault lease revoke -prefix azure/creds/vault-managed-principal
vault lease revoke -prefix azure/creds/existing-sp


