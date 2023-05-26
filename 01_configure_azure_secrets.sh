#!/bin/sh

# Note: It is required to set the following variables VAULT_ADDR, VAULT_TOKEN and VAULT_NAMESPACE (if applicable)
# Example:
export VAULT_ADDR=$(cat creds.json | jq -r '.vault_addr')
export VAULT_TOKEN=$(cat creds.json | jq -r '.vaulttoken')
export VAULT_NAMESPACE=admin
# In addition the following Azure specific env variables need to be set
export SUBSCRIPTION_ID=$(cat creds.json | jq -r '.subscription_id')
export TENANT_ID=$(cat creds.json | jq -r '.tenant_id')
export CLIENT_ID=$(cat creds.json | jq -r '.client_id')
export CLIENT_SECRET=$(cat creds.json | jq -r '.client_secret')
export RESOURCE_GROUP=$(cat creds.json | jq -r '.rg')
export APP_OBJECT_ID=$(cat creds.json | jq -r '.object_id')

vault secrets enable azure 

# Configure the azure secrets engine 
vault write azure/config  \
    subscription_id=$SUBSCRIPTION_ID \
    tenant_id=$TENANT_ID \
    client_id=$CLIENT_ID \
    client_secret=$CLIENT_SECRET


# Create a role with a ttl that generates a service principal and password
# role_name refers to the role the newly created principal has in Azure, for custom roles, use the UUID of the custom role: "role_id": "/subscriptions/<uuid>/providers/Microsoft.Authorization/roleDefinitions/<uuid>" 
# optionally azure_groups can be added to the role as well
vault write azure/roles/vault-managed-principal ttl=1h azure_roles=-<<EOF
    [
      {
        "role_name": "Contributor",
        "scope": "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP"
      }
    ]
EOF

# write policy that applications need to generate (=read) Azure credentials
vault policy write read-azure-credentials - <<EOF
path "azure/creds/vault-managed-principal" {
  capabilities = [ "read" ]
}
EOF


echo "Azure secret engine for Service Principals with the role "Contributor" the resource group $RESOURCE_GROUP configured "

# for existing applications where only the secret-id is to be managed by Vault the Role configuration would look like this:
vault write azure/roles/existing-sp \
  application_object_id=$APP_OBJECT_ID \
  ttl=1h

vault policy write read-secret-id - <<EOF
path "azure/creds/existing-sp" {
  capabilities = [ "read" ]
}
EOF

echo "Azure secret engine for the Service Principals $APP_OBJECT_ID configured "


