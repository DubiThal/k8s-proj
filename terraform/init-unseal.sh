#!/bin/bash

NAMESPACE="vault"

echo "[*] Initializing Vault..."

# Wait for the pod to be available and give it a few seconds to start up
echo "[*] Waiting for Vault pod to be ready..."
kubectl wait --for=jsonpath='{.status.phase}'=Running pod -l app.kubernetes.io/name=vault -n $NAMESPACE --timeout=60s
VAULT_POD=$(kubectl get pods -n $NAMESPACE -l app.kubernetes.io/name=vault -o jsonpath="{.items[0].metadata.name}")

# Check if Vault is already initialized
INITIALIZED_STATUS=$(kubectl exec -n $NAMESPACE $VAULT_POD -c vault -- vault status -format=json)
if ! echo "$INITIALIZED_STATUS" | jq -e '.initialized'; then
  echo "[*] Vault not initialized. Initializing now..."
  # Capture output to a variable first to avoid redirection issues
  INIT_OUTPUT=$(kubectl exec -n $NAMESPACE $VAULT_POD -c vault -- vault operator init -key-shares=3 -key-threshold=2 -format=json)
  echo "$INIT_OUTPUT" > vault-init.json

  echo "[*] Unsealing Vault..."
  UNSEAL_KEYS=$(jq -r '.unseal_keys_b64[]' vault-init.json | head -n 2)

  for key in $UNSEAL_KEYS; do
    kubectl exec -n $NAMESPACE $VAULT_POD -c vault -- vault operator unseal $key
  done

  ROOT_TOKEN=$(jq -r .root_token vault-init.json)
  echo "[*] Vault initialized and unsealed."
  echo "[*] Root Token (save this!): $ROOT_TOKEN"

  echo "[*] Logging in to Vault..."
  echo "$ROOT_TOKEN" | kubectl exec -i -n $NAMESPACE $VAULT_POD -c vault -- vault login -
else
  echo "[*] Vault is already initialized. Skipping initialization."
  echo "[*] If you need to re-initialize, delete the PVC and the vault-0 pod and run this script again."
fi
