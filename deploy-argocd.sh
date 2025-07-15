#!/bin/bash
set -e

echo "Instalando Helm local"
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

echo "🔄 Adicionando repositório ArgoCD ao Helm..."
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

echo "📦 Criando namespace 'argocd' (ignora erro se já existir)..."
kubectl create namespace argocd || true

echo "🚀 Instalando (ou atualizando) o ArgoCD via Helm..."
helm upgrade --install argocd argo/argo-cd --namespace argocd

echo "⏳ Aguardando pods do ArgoCD ficarem prontos..."
kubectl get pods -n argocd

echo "✅ Instalação do ArgoCD concluída! Todos os pods:"
kubectl get pods -n argocd