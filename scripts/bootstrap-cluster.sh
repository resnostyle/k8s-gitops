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

deployArgoSets(){
  kubens argocd
  argocd app create kube-system --repo git@github.com:resnostyle/k8s-gitops.git --path argoproj/system --dest-server https://kubernetes.default.svc --self-heal --sync-policy auto
  argocd app create apps --repo git@github.com:resnostyle/k8s-gitops.git --path argoproj/applications --dest-server https://kubernetes.default.svc --directory-recurse --auto-prune --self-heal --sync-policy auto


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
