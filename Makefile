SHELL := /bin/bash

CLUSTER_NAME ?= kube-labs
KIND_IMAGE ?= kindest/node:v1.37.0@sha256:a1ed56cfb0e7b93589bdf97c8cd566405a265939e3620fc4f5de89adff580ae5
KIND_CONFIG ?= cluster/kind-config.yaml

.PHONY: help prerequisites cluster-create cluster-delete verify verify-01 verify-02

help:
	@printf '%s\n' \
	  'make prerequisites  Vérifier les outils locaux sans créer de cluster' \
	  'make cluster-create Créer le cluster kind kube-labs' \
	  'make verify         Vérifier la topologie et la santé du cluster' \
	  'make verify-01      Valider le Pod de l’exercice 01' \
	  'make verify-02      Valider le Deployment de l’exercice 02' \
	  'make cluster-delete Supprimer uniquement le cluster kube-labs'

prerequisites:
	@./scripts/check-prerequisites.sh

cluster-create: prerequisites
	@if kind get clusters | grep -qx '$(CLUSTER_NAME)'; then \
	  echo "[FAIL] Le cluster $(CLUSTER_NAME) existe déjà."; \
	  exit 1; \
	fi
	kind create cluster \
	  --name '$(CLUSTER_NAME)' \
	  --image '$(KIND_IMAGE)' \
	  --config '$(KIND_CONFIG)' \
	  --wait 180s

verify:
	@CLUSTER_NAME='$(CLUSTER_NAME)' ./scripts/verify-cluster.sh

verify-01:
	@CLUSTER_NAME='$(CLUSTER_NAME)' ./scripts/verify-exercise-01.sh

verify-02:
	@CLUSTER_NAME='$(CLUSTER_NAME)' ./scripts/verify-exercise-02.sh

cluster-delete:
	kind delete cluster --name '$(CLUSTER_NAME)'
