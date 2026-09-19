# Glossaire Kubernetes

Ce glossaire rassemble les notions rencontrées pendant les exercices. Il sera
complété au fur et à mesure de l’apprentissage.

## kind

kind signifie *Kubernetes IN Docker*. Il permet de créer un cluster Kubernetes
local dont les nœuds s’exécutent sous forme de conteneurs Docker.

Dans ce laboratoire, kind crée un control plane et deux workers. Il sert à
construire et supprimer le cluster, mais ne permet pas de le piloter au
quotidien.

## Helm

Helm est un gestionnaire de paquets pour Kubernetes. Il utilise des *charts*
pour regrouper et paramétrer les manifests nécessaires au déploiement d’une
application.

Il permet notamment d’installer, mettre à jour ou revenir à une version
précédente d’une application. Il sera utilisé dans un exercice ultérieur.

## kubectl

`kubectl` est le client en ligne de commande de Kubernetes. Il communique avec
l’API du cluster en utilisant les informations de connexion et
d’authentification présentes dans le `kubeconfig`.

Il permet d’appliquer des manifests, consulter les ressources, lire les logs et
diagnostiquer le cluster. Il ne crée pas le cluster : dans ce laboratoire,
c’est le rôle de kind.

## GitHub CLI (`gh`)

`gh` est le client en ligne de commande officiel de GitHub. Il permet de gérer
les dépôts, pull requests, issues, workflows GitHub Actions et releases depuis
le terminal.

Git et `gh` n’ont pas le même rôle : Git gère l’historique, les branches et les
commits, tandis que `gh` donne accès aux fonctionnalités propres à GitHub.

## kubelet

Le kubelet est l’agent Kubernetes présent sur chaque nœud. Il surveille les Pods
attribués à son nœud et demande au runtime de conteneurs de lancer ou arrêter
les conteneurs nécessaires.

Il exécute également les contrôles de santé et remonte l’état du nœud et des
Pods au control plane. Il ne choisit pas leur emplacement : cette décision
revient au kube-scheduler.

## Pod

Un Pod est la plus petite unité déployable dans Kubernetes. Il contient un ou
plusieurs conteneurs qui doivent fonctionner étroitement ensemble sur le même
nœud.

Les conteneurs d’un même Pod partagent notamment la même adresse IP, certains
volumes et le même cycle de vie. La plupart des Pods contiennent un seul
conteneur principal ; des conteneurs auxiliaires peuvent être ajoutés lorsque
leur cycle de vie doit rester lié à celui de l’application.

## Namespace

Un namespace est un espace logique qui organise les ressources d’un même
cluster. Il permet de séparer des applications ou des environnements, d’éviter
les conflits de noms et d’appliquer des permissions, quotas ou politiques à un
périmètre donné.

Deux namespaces peuvent contenir des ressources portant le même nom. Un
namespace n’est toutefois ni une machine ni une isolation de sécurité complète.
Certaines ressources, comme les nœuds, appartiennent au cluster entier.

## `metadata.name` et `metadata.labels`

`metadata.name` est le nom unique d’une ressource dans son namespace. Il permet
de désigner directement cette ressource, par exemple avec `kubectl get pod web`.

`metadata.labels` contient des étiquettes sous forme de paires clé-valeur. Elles
servent à classer et sélectionner plusieurs ressources qui partagent une même
fonction. Le label `app: web` peut par exemple être utilisé avec
`kubectl get pods -l app=web`.

Plusieurs Pods peuvent donc partager le label `app: web`, mais un seul Pod peut
porter le nom `web` dans un namespace donné.

## Port-forward

`kubectl port-forward` crée un tunnel temporaire entre un port de la machine
locale et un port d’une ressource du cluster.

La commande `kubectl port-forward pod/web 8080:80 -n lab-01` écoute sur le port
`8080` du Mac et transmet le trafic vers le port `80` du Pod `web`. Le tunnel
reste actif uniquement tant que la commande s’exécute. Il sert surtout au test
et au diagnostic ; une exposition durable passe généralement par un Service,
puis éventuellement un Ingress ou la Gateway API.

## `kubectl describe`

`kubectl describe` affiche un résumé détaillé et lisible d’une ressource
Kubernetes : configuration utile, état courant, conditions et événements
récents. Il sert principalement au diagnostic.

Il ressemble donc à `docker inspect`, mais les sorties ne sont pas équivalentes.
`docker inspect` retourne la configuration et l’état complets d’un objet Docker,
généralement en JSON. Pour obtenir l’équivalent le plus proche côté Kubernetes,
on utilise plutôt `kubectl get <ressource> <nom> -o yaml`. `kubectl describe` est
une vue synthétique enrichie avec les événements associés à la ressource.

## Deployment

Un Deployment est un contrôleur Kubernetes qui décrit et maintient l’état
souhaité d’une application. Il indique notamment l’image à utiliser et le
nombre de Pods qui doivent fonctionner.

Le Deployment crée un ReplicaSet, qui crée et surveille les Pods. Si l’un
d’eux est supprimé ou tombe en panne, un nouveau Pod est automatiquement créé
pour conserver le nombre de réplicas demandé. Il permet également d’effectuer
des mises à jour progressives et de revenir à une version précédente.

À l’inverse, un Pod créé directement n’est surveillé par aucun contrôleur :
s’il est supprimé, Kubernetes ne le recrée pas.
