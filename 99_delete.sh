export VAULT_ADDR=$(cat creds.json | jq -r '.vault_addr')
export VAULT_TOKEN=$(cat creds.json | jq -r '.vaulttoken')
export VAULT_NAMESPACE=admin


vault secrets disable azure
vault policy delete read-azure-credentials
vault policy delete read-secret-id

