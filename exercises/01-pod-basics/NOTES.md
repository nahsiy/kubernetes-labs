# Notes — exercice 01

## Manifeste créé

Le namespace crée un espace logique distinct qui permet d’organiser et de séparer les ressources du cluster.

Le label ajoute une paire clé-valeur à la ressource. Il permet ensuite de rechercher, filtrer ou sélectionner toutes les ressources qui portent le même label.

L’image contient les fichiers et les composants nécessaires au démarrage du conteneur.
Dans cet exercice, l’image nginx est récupérée depuis Docker Hub.

Le champ `containerPort: 80` indique que nginx écoute sur le port 80 à l’intérieur du conteneur.

Il n’expose pas directement l’application sur le Mac : le port-forward est nécessaire pour y accéder temporairement depuis le port local 8080.

## État observé

La commande `curl -I http://127.0.0.1:8080` retourne un code HTTP `200 OK`. Cela confirme que nginx répond correctement à travers le tunnel créé par `kubectl port-forward`.

L’ouverture de la même adresse dans le navigateur affiche également la page d’accueil par défaut de nginx.
Cette seconde observation confirme visuellement la réponse, mais elle utilise le même tunnel réseau que `curl`.

## Incident d’image

Pour provoquer la panne, j’ai remplacé l’image nginx par une image inexistante :

```bash
kubectl --context kind-kube-labs set image pod/web nginx=nginx:image-inexistante -n lab-01
```

Avec la commande suivante, j’ai observé le Pod passer dans l’état `ErrImagePull`, puis `ImagePullBackOff` :

```bash
kubectl get pod/web -n lab-01 -w
```

J’ai ensuite utilisé `kubectl describe` pour analyser les événements du Pod et identifier l’erreur exacte : l’image `nginx:image-inexistante` était introuvable dans le registre.

```bash
kubectl describe pod/web -n lab-01
```

Pour résoudre la panne, j’ai réappliqué le manifeste `pod.yaml` :

```bash
kubectl apply -f exercises/01-pod-basics/manifests/pod.yaml
```

J’ai ensuite vérifié avec les commandes précédentes que le Pod était revenu dans l’état `1/1 Running`. La commande suivante m’a permis de confirmer que nginx avait bien redémarré et produisait de nouveau des logs :

```bash
kubectl logs -f pod/web -n lab-01
```

## Suppression du Pod

Après sa suppression, le Pod n’a pas été recréé automatiquement. Il avait été créé directement et n’était pas géré par un contrôleur Kubernetes, comme un Deployment.
Un Deployment aurait détecté sa disparition et créé un nouveau Pod pour maintenir l’état souhaité.

## Ce que j’ai compris

Dans cet exercice, le Pod contient le conteneur qui exécute le serveur nginx. La déclaration `containerPort: 80` indique le port utilisé par l’application, mais ne l’expose pas à elle seule : j’ai utilisé un port-forward pour y accéder depuis mon Mac.

Pour diagnostiquer la panne d’image, j’ai d’abord observé l’état du Pod avec `kubectl get pods`, puis analysé ses événements avec `kubectl describe`. La commande `kubectl logs` est surtout utile lorsque le conteneur a réussi à démarrer.

Après sa suppression, le Pod n’a pas été recréé, car aucun contrôleur ne le gérait. Un Deployment aurait maintenu le nombre de réplicas demandé et créé un nouveau Pod pour remplacer celui qui avait été supprimé.
