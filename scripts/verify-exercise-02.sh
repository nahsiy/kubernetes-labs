#!/usr/bin/env bash
set -euo pipefail

cluster_name="${CLUSTER_NAME:-kube-labs}"
context="kind-${cluster_name}"
namespace="lab-02"
deployment="web"
manifest_dir="exercises/02-deployment-basics/manifests"

fail() {
  printf '[FAIL] %s\n' "$1"
  exit 1
}

for manifest in namespace.yaml deployment.yaml; do
  [[ -f "${manifest_dir}/${manifest}" ]] || \
    fail "Manifeste manquant : ${manifest_dir}/${manifest}"
done

kubectl --context "$context" apply \
  --dry-run=server \
  --filename "$manifest_dir" >/dev/null || \
  fail "Les manifests ne passent pas la validation serveur."

kubectl --context "$context" get namespace "$namespace" >/dev/null 2>&1 || \
  fail "Namespace ${namespace} introuvable."

kubectl --context "$context" get deployment "$deployment" \
  --namespace "$namespace" >/dev/null 2>&1 || \
  fail "Deployment ${namespace}/${deployment} introuvable."

kubectl --context "$context" rollout status "deployment/${deployment}" \
  --namespace "$namespace" \
  --timeout=180s >/dev/null || \
  fail "Le Deployment ${namespace}/${deployment} n’est pas disponible."

replicas="$(kubectl --context "$context" get deployment "$deployment" \
  --namespace "$namespace" \
  --output=jsonpath='{.spec.replicas}')"
ready_replicas="$(kubectl --context "$context" get deployment "$deployment" \
  --namespace "$namespace" \
  --output=jsonpath='{.status.readyReplicas}')"
selector="$(kubectl --context "$context" get deployment "$deployment" \
  --namespace "$namespace" \
  --output=jsonpath='{.spec.selector.matchLabels.app}')"
template_label="$(kubectl --context "$context" get deployment "$deployment" \
  --namespace "$namespace" \
  --output=jsonpath='{.spec.template.metadata.labels.app}')"
container_name="$(kubectl --context "$context" get deployment "$deployment" \
  --namespace "$namespace" \
  --output=jsonpath='{.spec.template.spec.containers[0].name}')"
image="$(kubectl --context "$context" get deployment "$deployment" \
  --namespace "$namespace" \
  --output=jsonpath='{.spec.template.spec.containers[0].image}')"
port="$(kubectl --context "$context" get deployment "$deployment" \
  --namespace "$namespace" \
  --output=jsonpath='{.spec.template.spec.containers[0].ports[0].containerPort}')"
strategy="$(kubectl --context "$context" get deployment "$deployment" \
  --namespace "$namespace" \
  --output=jsonpath='{.spec.strategy.type}')"
max_unavailable="$(kubectl --context "$context" get deployment "$deployment" \
  --namespace "$namespace" \
  --output=jsonpath='{.spec.strategy.rollingUpdate.maxUnavailable}')"
max_surge="$(kubectl --context "$context" get deployment "$deployment" \
  --namespace "$namespace" \
  --output=jsonpath='{.spec.strategy.rollingUpdate.maxSurge}')"

[[ "$replicas" == "3" ]] || fail "Le Deployment doit demander trois réplicas."
[[ "$ready_replicas" == "3" ]] || fail "Trois Pods doivent être Ready."
[[ "$selector" == "web" ]] || fail "Le sélecteur app=web est absent."
[[ "$template_label" == "web" ]] || fail "Le template doit porter le label app=web."
[[ "$container_name" == "nginx" ]] || fail "Le conteneur doit se nommer nginx."
[[ "$image" == "nginx:1.29.1-alpine" ]] || fail "Image finale inattendue : ${image}."
[[ "$port" == "80" ]] || fail "Le port 80 n’est pas déclaré."
[[ "$strategy" == "RollingUpdate" ]] || fail "La stratégie doit être RollingUpdate."
[[ "$max_unavailable" == "1" ]] || fail "maxUnavailable doit valoir 1."
[[ "$max_surge" == "1" ]] || fail "maxSurge doit valoir 1."

pod_count="$(kubectl --context "$context" get pods \
  --namespace "$namespace" \
  --selector app=web \
  --output=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}' | \
  sed '/^$/d' | wc -l | tr -d ' ')"
[[ "$pod_count" == "3" ]] || fail "Trois Pods app=web sont attendus, ${pod_count} trouvés."

while IFS= read -r pod; do
  [[ -n "$pod" ]] || continue
  owner_kind="$(kubectl --context "$context" get pod "$pod" \
    --namespace "$namespace" \
    --output=jsonpath='{.metadata.ownerReferences[0].kind}')"
  [[ "$owner_kind" == "ReplicaSet" ]] || \
    fail "Le Pod ${pod} doit appartenir à un ReplicaSet."
done < <(kubectl --context "$context" get pods \
  --namespace "$namespace" \
  --selector app=web \
  --output=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')

while IFS= read -r replica_set; do
  [[ -n "$replica_set" ]] || continue
  owner_kind="$(kubectl --context "$context" get replicaset "$replica_set" \
    --namespace "$namespace" \
    --output=jsonpath='{.metadata.ownerReferences[0].kind}')"
  owner_name="$(kubectl --context "$context" get replicaset "$replica_set" \
    --namespace "$namespace" \
    --output=jsonpath='{.metadata.ownerReferences[0].name}')"
  [[ "$owner_kind" == "Deployment" && "$owner_name" == "$deployment" ]] || \
    fail "Le ReplicaSet ${replica_set} doit appartenir au Deployment ${deployment}."
done < <(kubectl --context "$context" get replicasets \
  --namespace "$namespace" \
  --selector app=web \
  --output=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}')

printf '[PASS] Exercice 02 : Deployment %s/%s valide avec trois Pods Ready.\n' \
  "$namespace" "$deployment"
