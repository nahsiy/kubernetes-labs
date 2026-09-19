# Exercice 02 — Maintenir une application avec un Deployment

## Objectif

Créer un Deployment nginx, observer la relation entre Deployment, ReplicaSet
et Pods, puis vérifier l’auto-réparation, le changement du nombre de réplicas
et une mise à jour progressive.

Tu dois comprendre que Kubernetes ne conserve pas un Pod précis : le
Deployment maintient un état souhaité et remplace les Pods qui disparaissent.

## Livrables

Crée toi-même les fichiers suivants :

```text
exercises/02-deployment-basics/manifests/namespace.yaml
exercises/02-deployment-basics/manifests/deployment.yaml
```

Complète ensuite [`NOTES.md`](NOTES.md). Aucun manifeste de solution n’est
fourni dans le dépôt.

## Contraintes du manifeste

Le résultat initial doit respecter les critères suivants :

- namespace nommé `lab-02` ;
- Deployment nommé `web` dans ce namespace ;
- trois réplicas ;
- sélecteur et label de template `app: web` ;
- un seul conteneur nommé `nginx` ;
- image initiale `nginx:1.29.0-alpine` ;
- port `80` déclaré dans le conteneur ;
- stratégie `RollingUpdate` avec `maxUnavailable: 1` et `maxSurge: 1`.

Utilise la documentation intégrée pour construire le manifeste :

```bash
kubectl explain deployment
kubectl explain deployment.spec
kubectl explain deployment.spec.selector
kubectl explain deployment.spec.strategy
kubectl explain deployment.spec.template
kubectl explain deployment.spec.template.spec.containers
```

## Étape 1 — Construire et appliquer

Crée le dossier `manifests`, écris les deux fichiers YAML puis applique-les
dans l’ordre logique.

Observe ensuite les trois niveaux de ressources :

```bash
kubectl --context kind-kube-labs get deployments,replicasets,pods -n lab-02
kubectl --context kind-kube-labs describe deployment web -n lab-02
kubectl --context kind-kube-labs get pods -n lab-02 -l app=web -o wide
```

Identifie le propriétaire d’un Pod et celui du ReplicaSet avec `kubectl get`
et une sortie YAML ou JSONPath.

## Étape 2 — Observer l’auto-réparation

Liste les noms et UID des Pods :

```bash
kubectl --context kind-kube-labs get pods -n lab-02 -l app=web \
  -o custom-columns=NAME:.metadata.name,UID:.metadata.uid,NODE:.spec.nodeName
```

Supprime l’un des trois Pods, puis observe immédiatement les Pods du namespace :

```bash
kubectl --context kind-kube-labs delete pod <nom-du-pod> -n lab-02
kubectl --context kind-kube-labs get pods -n lab-02 -l app=web -w
```

Arrête l’observation avec `Ctrl+C`, puis compare les noms et UID avant et après
la suppression.

## Étape 3 — Modifier temporairement le nombre de réplicas

Demande cinq réplicas sans modifier le manifeste :

```bash
kubectl --context kind-kube-labs scale deployment web --replicas=5 -n lab-02
kubectl --context kind-kube-labs get deployment,pods -n lab-02
```

Réapplique ensuite ton manifeste, qui demande toujours trois réplicas, et
observe l’état choisi par Kubernetes. Explique le résultat dans `NOTES.md`.

## Étape 4 — Effectuer une mise à jour progressive

Dans `deployment.yaml`, remplace l’image initiale par l’image finale
`nginx:1.29.1-alpine`, puis applique le manifeste.

Observe la mise à jour :

```bash
kubectl --context kind-kube-labs rollout status deployment/web -n lab-02
kubectl --context kind-kube-labs rollout history deployment/web -n lab-02
kubectl --context kind-kube-labs get replicasets,pods -n lab-02
```

Le manifeste enregistré dans Git doit conserver l’image finale
`nginx:1.29.1-alpine` et trois réplicas.

## Validation

Lorsque le Deployment est stable :

```bash
make verify-02
```

Le validateur contrôle les manifests, le namespace, le Deployment, sa
stratégie, ses trois Pods, leur image, leur label, leur port et leur relation
avec le ReplicaSet.

Ne committe pas encore ton travail : fais-moi d’abord relire tes manifests et
tes observations.
