# Exercice 01 — Créer et observer un Pod

## Objectif

Écrire ton premier manifeste Kubernetes, déployer un Pod nginx, observer son
cycle de vie et diagnostiquer une erreur d’image volontaire.

Tu dois comprendre la différence entre le manifeste enregistré dans Git, l’état
demandé à Kubernetes et l’état réellement observé dans le cluster.

## Livrables

Crée toi-même les fichiers suivants :

```text
exercises/01-pod-basics/manifests/namespace.yaml
exercises/01-pod-basics/manifests/pod.yaml
```

Complète ensuite [`NOTES.md`](NOTES.md). Aucun manifeste de solution n’est
fourni dans le dépôt.

## Contraintes du manifeste

Le résultat final doit respecter les critères suivants :

- namespace nommé `lab-01` ;
- Pod nommé `web` dans ce namespace ;
- label `app: web` ;
- un seul conteneur nommé `nginx` ;
- image `nginx:1.29.1-alpine` ;
- port `80` déclaré dans le conteneur ;
- aucun Deployment ou autre contrôleur pour le moment.

Utilise la documentation intégrée plutôt que de copier un manifeste :

```bash
kubectl explain namespace
kubectl explain pod
kubectl explain pod.metadata
kubectl explain pod.spec
kubectl explain pod.spec.containers
```

## Étape 1 — Construire et appliquer

Crée le dossier `manifests`, écris les deux fichiers YAML puis applique-les dans
l’ordre logique.

Vérifie ensuite le Pod avec :

```bash
kubectl --context kind-kube-labs get pod web -n lab-01 -o wide
kubectl --context kind-kube-labs describe pod web -n lab-01
kubectl --context kind-kube-labs logs web -n lab-01
```

## Étape 2 — Accéder à nginx

Dans un premier terminal :

```bash
kubectl --context kind-kube-labs port-forward pod/web 8080:80 -n lab-01
```

Dans un second terminal :

```bash
curl -I http://127.0.0.1:8080
```

Relève le code HTTP obtenu puis arrête le port-forward avec `Ctrl+C`.

## Étape 3 — Provoquer et diagnostiquer une panne

Remplace temporairement l’image du Pod actif par une image inexistante :

```bash
kubectl --context kind-kube-labs set image \
  pod/web nginx=nginx:image-inexistante \
  -n lab-01
```

Observe l’évolution du Pod et identifie dans `describe` l’événement qui explique
la panne. Ne conserve pas cette mauvaise image dans ton manifeste Git.

Restaure ensuite l’état correct en réappliquant ton fichier `pod.yaml`.

## Étape 4 — Observer l’absence de contrôleur

Supprime le Pod, attends quelques secondes et vérifie s’il revient tout seul :

```bash
kubectl --context kind-kube-labs delete pod web -n lab-01
kubectl --context kind-kube-labs get pods -n lab-01
```

Explique le résultat dans `NOTES.md`, puis réapplique `pod.yaml` pour retrouver
l’état final attendu.

## Validation

Lorsque le Pod est de nouveau fonctionnel :

```bash
make verify-01
```

Le validateur contrôle les manifests, le namespace, le Pod actif, son image,
son label, son port, sa santé et l’absence de contrôleur.

Ne committe pas encore ton travail : fais-moi d’abord relire tes manifests et
tes observations.

