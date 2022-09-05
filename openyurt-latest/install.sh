#!/bin/bash

echo "[INFO] Start to install OpenYurt"

echo "[INFO] Setup flannel"
kubectl apply -f manifests/kube-flannel.yaml

echo "[INFO] Adjust kube-controller-manager"
./kube-controller-manager.sh
echo "kube-controller-manager adjustment completed"

echo "[INFO] Setup yurt-tunnel-dns"
kubectl apply -f manifests/yurt-tunnel-dns.yaml

echo "[INFO] Adjust kube-apiserver"
./kube-apiserver.sh

echo "[INFO] Adjust coreDNS"
kubectl apply -f manifests/coredns.yaml
kubectl scale --replicas=0 deployment/coredns -n kube-system
kubectl annotate svc kube-dns -n kube-system openyurt.io/topologyKeys='openyurt.io/nodepool'

echo "[INFO] Adjust kube-proxy"
kubectl get cm -n kube-system kube-proxy -oyaml | sed 's|kubeconfig: \/var\/lib\/kube-proxy\/kubeconfig.conf|#kubeconfig: \/var\/lib\/kube-proxy\/kubeconfig.conf|g' - | kubectl apply -f -

echo "[INFO] Setup yurt-controller-manager"
kubectl apply -f manifests/yurt-controller-manager.yaml

echo "[INFO] Setup yurt-tunnel"
kubectl apply -f manifests/yurt-tunnel-server.yaml
kubectl apply -f manifests/yurt-tunnel-agent.yaml

echo "[INFO] Setup Yurthub Settings"
kubectl apply -f manifests/yurthub-cfg.yaml

echo "[INFO] Install helm"
tar -zxvf helm-v3.9.4-linux-amd64.tar.gz && cp linux-amd64/helm /usr/bin && chmod +x /usr/bin/helm

echo "[INFO] Setup yurt-app-manager"
helm repo add openyurt https://openyurtio.github.io/openyurt-helm \
  && helm repo update \
  && helm upgrade --install yurt-app-manager openyurt/yurt-app-manager -n kube-system -f ./set-values.yaml

echo "[INFO] OpenYurt is successfully installed"