# Kubernetes Labs — plan de construction

## Objectif

Construire un laboratoire Kubernetes public, progressif et reproductible qui
serve à la fois d'environnement d'apprentissage et de preuve technique sur
GitHub.

Le dépôt doit montrer ce qui a réellement été réalisé et vérifié. Les solutions
ne sont ajoutées qu'après réalisation des exercices.

## Principes pédagogiques

- un objectif concret par exercice ;
- un scénario proche d'un besoin d'exploitation réel ;
- des critères de réussite observables ;
- une validation automatisée quand elle est pertinente ;
- une section de retour d'expérience rédigée après chaque exercice ;
- aucun secret, nom de client ou contenu issu d'un dépôt professionnel.

## Phases

| Phase | Contenu | Statut |
| --- | --- | --- |
| 0 | README, prérequis, environnement local et exercice de vérification | En cours |
| 1 | Pods, Deployments, Services et découverte DNS | À faire |
| 2 | Configuration, Secrets, probes et ressources | À faire |
| 3 | Stockage, Ingress et exposition HTTP | À faire |
| 4 | ServiceAccounts, RBAC et NetworkPolicies | À faire |
| 5 | Kustomize, Helm et organisation multi-environnements | À faire |
| 6 | Observabilité et diagnostic d'incidents | À faire |
| 7 | Projet final documenté et démontrable | À faire |

## Premier lot

- [x] Créer le README avec une section Prérequis et des commandes de contrôle.
- [x] Ajouter une configuration `kind` minimale et explicite.
- [x] Ajouter l'exercice 00 sans sa solution.
- [x] Ajouter un validateur local lisible.
- [x] Ajouter une CI qui vérifie le dépôt sans prétendre valider un cluster live.
- [x] Vérifier la confidentialité et la qualité du diff.
- [ ] Créer un commit local de référence.
- [ ] Publier le dépôt public après validation locale.

## Validation du premier lot

- Markdown et scripts sans erreurs évidentes ;
- aucune donnée personnelle ou professionnelle confidentielle ;
- distinction claire entre contrôles statiques et preuve sur cluster réel ;
- historique Git propre et ciblé ;
- visibilité GitHub vérifiée après publication.
