# Notes — exercice 00

## Environnement observé

Le cluster Kubernetes a été créé avec kind et s’exécute dans Docker.

Il comporte trois nœuds : un control plane nommé kube-labs-control-plane et deux workers nommés kube-labs-worker et kube-labs-worker2.
Les trois nœuds utilisent Kubernetes 1.37.0 et sont dans l’état Ready.

Les images des nœuds reposent sur Debian 13 (Trixie), avec une architecture ARM64.
Les conteneurs partagent le noyau LinuxKit 6.12.76 fourni par la VM Docker Desktop.
Les nœuds possèdent des adresses internes au réseau Docker.

L’API Kubernetes est accessible depuis le Mac sur 127.0.0.1:50039 (50039 est le port attribué dynamiquement par kind), mais aucune application du cluster n’est encore exposée.

Le namespace kube-system contient les composants nécessaires au fonctionnement du cluster :

- CoreDNS pour la résolution DNS
- kindnet pour le réseau des Pods et kube-proxy pour l’accès aux Services.
- kube-proxy pour l’accès aux Services.

Le nœud control plane héberge également etcd, kube-apiserver, kube-controller-manager et kube-scheduler.

Aucune application utilisateur n’a encore été déployée.

## Rôle du control plane

Le control plane supervise le cluster et maintient son état souhaité.
Il détermine sur quels nœuds workers les Pods doivent être placés en fonction des ressources disponibles et des contraintes définies. Les workers exécutent ensuite ces Pods.

## Rôle des workers

Les workers exécutent les Pods qui leur sont attribués par le control plane.

Sur chaque worker, le kubelet veille à leur bon fonctionnement, le runtime lance les conteneurs et kube-proxy assure la connectivité avec les Services.

## Ce que contient `kube-system`

Le namespace kube-system regroupe les Pods système nécessaires au fonctionnement du cluster.
On y retrouve notamment CoreDNS, kindnet, kube-proxy et les composants du control plane. La commande d’observation indique le nœud sur lequel chaque Pod s’exécute ainsi que son état.

## Difficulté rencontrée et résolution

La principale difficulté a été de m’approprier les termes techniques propres à Kubernetes.
J’ai également rencontré une erreur `403 Forbidden` en ouvrant l’adresse de l’API du control plane dans un navigateur.

Il ne s’agit pas d’une interface web : le navigateur contacte l’API sans authentification. `kubectl` fonctionne, car il utilise les informations d’authentification présentes dans le `kubeconfig`.