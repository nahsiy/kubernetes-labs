#!/usr/bin/env bash
set -euo pipefail

cluster_name="${CLUSTER_NAME:-kube-labs}"
context="kind-${cluster_name}"

if ! kind get clusters | grep -qx "$cluster_name"; then
  printf '[FAIL] Cluster %s introuvable.\n' "$cluster_name"
  exit 1
fi

if ! kubectl --context "$context" wait \
  --for=condition=Ready node \
  --all \
  --timeout=180s; then
  printf '[FAIL] Tous les nœuds ne sont pas devenus Ready dans le délai imparti.\n'
  kubectl --context "$context" get nodes -o wide
  exit 1
fi

node_count="$(kubectl --context "$context" get nodes --no-headers | wc -l | tr -d ' ')"
control_plane_count="$(kubectl --context "$context" get nodes \
  -l node-role.kubernetes.io/control-plane --no-headers | wc -l | tr -d ' ')"
ready_count="$(kubectl --context "$context" get nodes --no-headers | awk '$2 == "Ready" {count++} END {print count+0}')"
worker_count=$((node_count - control_plane_count))

if [[ "$node_count" -ne 3 ]]; then
  printf '[FAIL] 3 nœuds attendus, %s observé(s).\n' "$node_count"
  exit 1
fi

if [[ "$control_plane_count" -ne 1 || "$worker_count" -ne 2 ]]; then
  printf '[FAIL] Topologie attendue : 1 control plane et 2 workers.\n'
  exit 1
fi

if [[ "$ready_count" -ne "$node_count" ]]; then
  printf '[FAIL] Seulement %s nœud(s) Ready sur %s.\n' "$ready_count" "$node_count"
  kubectl --context "$context" get nodes
  exit 1
fi

kubectl --context "$context" wait \
  --namespace kube-system \
  --for=condition=Ready pod \
  --all \
  --timeout=180s >/dev/null

printf '[PASS] Cluster %s : 1 control plane, 2 workers, tous Ready.\n' "$cluster_name"
kubectl --context "$context" get nodes -o wide
