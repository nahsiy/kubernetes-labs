# Kubernetes Labs

Un parcours pratique pour apprendre Kubernetes en construisant, observant et
dépannant de vrais clusters locaux.

Ce dépôt est volontairement progressif : chaque exercice part d'un objectif,
impose des critères de réussite et se termine par une vérification. Les
solutions ne sont ajoutées qu'après réalisation afin que l'historique Git
reflète le travail réellement effectué.

## Prérequis

Le laboratoire est conçu pour macOS Apple Silicon ou Linux. Sous macOS, il
utilise Docker Desktop comme moteur de conteneurs.

| Outil | Version de référence | Utilité |
| --- | --- | --- |
| Git | 2.x | Versionner les exercices et les retours d'expérience |
| Docker Desktop | version maintenue | Exécuter les nœuds `kind` |
| kubectl | 1.36 ou 1.37 | Administrer le cluster Kubernetes 1.37 |
| kind | 0.33.0 | Créer le cluster local reproductible |
| Helm | 4.3.0 | Utilisé à partir des exercices de packaging |
| GitHub CLI | 2.x | Publier et suivre le dépôt depuis le terminal |
| Make | 3.81 ou ultérieur | Exécuter les commandes du laboratoire |

### Installation sous macOS

Docker Desktop doit être installé puis démarré. Les autres outils peuvent être
installés avec Homebrew :

```bash
brew install kubectl kind helm gh
```

Si une ancienne version de `kubectl` existe déjà, vérifier quel binaire est
réellement utilisé avant de continuer :

```bash
which kubectl
kubectl version --client
```

### Vérification

Depuis la racine du dépôt :

```bash
make prerequisites
```

Ce contrôle doit être entièrement vert. Il vérifie la présence des outils et
confirme que le moteur Docker répond ; il ne crée aucun cluster.

## Démarrage rapide

```bash
make prerequisites
make cluster-create
make verify
```

Le cluster comporte un control plane et deux workers. L'image des nœuds est
épinglée par digest pour rendre les exécutions reproductibles.

Pour supprimer uniquement ce cluster local :

```bash
make cluster-delete
```

## Premier exercice

Commencer par [`exercises/00-environment`](exercises/00-environment/README.md).
L'objectif n'est pas seulement de lancer les commandes : il faut expliquer ce
que montre chaque résultat dans le fichier `NOTES.md` de l'exercice.

## Progression

Le parcours complet est décrit dans [Plan.md](Plan.md) :

1. environnement et lecture du cluster ;
2. Pods, Deployments, Services et DNS ;
3. configuration, santé et ressources ;
4. stockage et exposition HTTP ;
5. identité, RBAC et politiques réseau ;
6. packaging et environnements ;
7. observabilité, incidents et projet final.

## Ce que valide la CI

GitHub Actions crée un cluster `kind` éphémère et exécute les validateurs du
dépôt. Cela prouve que la configuration versionnée fonctionne sur le runner CI.
Cela ne prouve pas que l'exercice a été réalisé sur une machine personnelle :
les observations et explications de chaque exercice apportent cette preuve.

## Licence

Aucune licence n'est accordée pour le moment. Le contenu reste soumis au droit
d'auteur de son propriétaire.
