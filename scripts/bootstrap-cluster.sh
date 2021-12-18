#!/bin/bash

need() {
        which "$1" &>/dev/null || exit "Binary '$1' is missing but required"
}

need "kubectl"
need "helm"
need "argocd"
need "kubens"

message() {
      echo -e "\n######################################################################"
      echo "# $1"
      echo "######################################################################"
}

installArgocd() {
  kubectl create ns argocd
#  kubectl apply -k ../argo-cd/
#  kubectl delete -k ../argo-cd/
   helm install argo-cd argoproj/ --namespace argocd
}

configureArgocd(){
  kubens argocd
#  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
  argocd repo add git@gitlab.com:resnostyle/helm-charts.git --ssh-private-key-path ~/.ssh/id_ed25519
  argocd repo add git@github.com:resnostyle/k8s-gitops.git --ssh-private-key-path ~/.ssh/id_ed25519 --insecure-skip-server-verification
  kubens -
}

deployArgoSets(){
  kubens argocd
  argocd app create init --repo git@github.com:resnostyle/k8s-gitops.git --path argoproj/system --dest-server https://kubernetes.default.svc --self-heal --sync-policy auto
  argocd app create cluster-apps --repo git@github.com:resnostyle/k8s-gitops.git --path argoproj/projects --dest-server https://kubernetes.default.svc --directory-recurse --auto-prune --self-heal --sync-policy auto
  #argocd app create services --repo git@github.com:resnostyle/k8s-gitops.git --path applications/services --dest-server https://kubernetes.default.svc --directory-recurse --auto-prune --self-heal --sync-policy auto
  kubens -
}

#configureArgocd() {
#  message "configure argocd"
##  sleep 45s
#  message "waiting for argocd"
#  #actually do a smart wait instead of just a sleep
#  argocd login --core
#}

message "installing argocd"
installArgocd
#sleep 45s
configureArgocd
deployArgoSets
message "argocd installed"
