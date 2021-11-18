#!/bin/bash

need() {
        which "$1" &>/dev/null || exit "Binary '$1' is missing but required"
}

need "kubectl"
need "helm"
need "argocd"

message() {
      echo -e "\n######################################################################"
      echo "# $1"
      echo "######################################################################"
}

message "installing argocd"

installArgocd() {
  helm repo add argo-cd https://argoproj.github.io/argo-helm
  helm repo update
  kubectl create ns argocd
  kubectl config set-context argo --namespace=argocd --cluster=default --user=default
  helm install argo-cd argo-cd/argo-cd -f argocd-values.yaml
}

configureArgocd(){
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
    argocd repo add git@gitlab.com:resnostyle/helm-charts.git --ssh-private-key-path ~/.ssh/id_ed25519
    argocd repo add git@github.com:resnostyle/k8s-gitops.git --ssh-private-key-path ~/.ssh/id_ed25519 --insecure-skip-server-verification
}

deployArgoSets(){
argocd app create init --repo git@github.com:resnostyle/k8s-gitops.git --path applications/bootstrap --dest-server https://kubernetes.default.svc --directory-recurse --auto-prune --self-heal --sync-policy auto
argocd app create services --repo git@github.com:resnostyle/k8s-gitops.git --path applications/services --dest-server https://kubernetes.default.svc --directory-recurse --auto-prune --self-heal --sync-policy auto
}

configureArgocd() {
  message "configure argocd"
  sleep 45s
  message "waiting for argocd"
  #actually do a smart wait instead of just a sleep
  argocd login --core
}


installArgocd
configureArgocd
deployArgoSets
message "argocd installed"
