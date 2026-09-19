#!/usr/bin/env bash
set -euo pipefail

cluster_name="${CLUSTER_NAME:-kube-labs}"
context="kind-${cluster_name}"
namespace="lab-01"
pod="web"
manifest_dir="exercises/01-pod-basics/manifests"

fail() {
  printf '[FAIL] %s\n' "$1"
  exit 1
}

for manifest in namespace.yaml pod.yaml; do
  [[ -f "${manifest_dir}/${manifest}" ]] || \
    fail "Manifeste manquant : ${manifest_dir}/${manifest}"
done

kubectl --context "$context" apply \
  --dry-run=server \
  --filename "$manifest_dir" >/dev/null || \
  fail "Les manifests ne passent pas la validation serveur."

kubectl --context "$context" get namespace "$namespace" >/dev/null 2>&1 || \
  fail "Namespace ${namespace} introuvable."

kubectl --context "$context" get pod "$pod" --namespace "$namespace" >/dev/null 2>&1 || \
  fail "Pod ${namespace}/${pod} introuvable."

kubectl --context "$context" wait \
  --namespace "$namespace" \
  --for=condition=Ready "pod/${pod}" \
  --timeout=120s >/dev/null || \
  fail "Le Pod ${namespace}/${pod} n’est pas Ready."

container_name="$(kubectl --context "$context" get pod "$pod" \
  --namespace "$namespace" \
  --output=jsonpath='{.spec.containers[0].name}')"
image="$(kubectl --context "$context" get pod "$pod" \
  --namespace "$namespace" \
  --output=jsonpath='{.spec.containers[0].image}')"
label="$(kubectl --context "$context" get pod "$pod" \
  --namespace "$namespace" \
  --output=jsonpath='{.metadata.labels.app}')"
port="$(kubectl --context "$context" get pod "$pod" \
  --namespace "$namespace" \
  --output=jsonpath='{.spec.containers[0].ports[0].containerPort}')"
owner="$(kubectl --context "$context" get pod "$pod" \
  --namespace "$namespace" \
  --output=jsonpath='{.metadata.ownerReferences[0].kind}')"

[[ "$container_name" == "nginx" ]] || fail "Le conteneur doit se nommer nginx."
[[ "$image" == "nginx:1.29.1-alpine" ]] || fail "Image inattendue : ${image}."
[[ "$label" == "web" ]] || fail "Le label app=web est absent."
[[ "$port" == "80" ]] || fail "Le port 80 n’est pas déclaré."
[[ -z "$owner" ]] || fail "Le Pod ne doit pas appartenir à un contrôleur (${owner})."

printf '[PASS] Exercice 01 : Pod %s/%s valide et Ready.\n' "$namespace" "$pod"
