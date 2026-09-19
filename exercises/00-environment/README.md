# Exercice 00 — Comprendre son environnement

## Objectif

Créer le cluster local puis démontrer que tu sais identifier ses composants,
son contexte `kubectl` et l'état de ses nœuds.

## Contraintes

- ne pas modifier la configuration fournie ;
- ne pas utiliser l'interface graphique de Docker Desktop comme unique preuve ;
- expliquer les observations avec tes mots dans `NOTES.md` ;
- conserver uniquement des sorties non sensibles et utiles.

## Travail demandé

1. Vérifie les prérequis :

   ```bash
   make prerequisites
   ```

2. Crée le cluster :

   ```bash
   make cluster-create
   ```

3. Inspecte les contextes, les nœuds et les Pods système :

   ```bash
   kubectl config get-contexts
   kubectl --context kind-kube-labs get nodes -o wide
   kubectl --context kind-kube-labs get pods --namespace kube-system
   ```

4. Exécute le validateur :

   ```bash
   make verify
   ```

5. Complète `NOTES.md`, puis relis ton diff Git avant de committer.

## Critères de réussite

- le cluster se nomme `kube-labs` ;
- il possède un control plane et deux workers ;
- les trois nœuds sont `Ready` ;
- les Pods du namespace `kube-system` sont expliqués sans copier une définition ;
- `NOTES.md` distingue ce que tu as observé de ce que tu en déduis.

## Nettoyage

Après avoir conservé les preuves nécessaires :

```bash
make cluster-delete
```

