#!/bin/bash

nodes=$(vagrant global-status | grep k8s | awk '{ print $2 }')
for node in $nodes; do
    vagrant ssh $node -c "sudo  sysctl -w vm.max_map_count=262144"
    vagrant ssh $node -c "echo 'sysctl vm.max_map_count=262144' | sudo tee -a /etc/rc.local"
    vagrant ssh $node -c "echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf"
done

# install local-path-storage from rancher to mount local folder in kubernetes
kubectl apply -f manifests/local-path-storage.yaml

# install helm charts
helm repo add istio https://istio-release.storage.googleapis.com/charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# install cert-manager
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.6.3/cert-manager.yaml

# install elasticsearch
kubectl config set-context --current --namespace=kube-system
kubectl create -f https://download.elastic.co/downloads/eck/1.9.1/crds.yaml
kubectl apply -f https://download.elastic.co/downloads/eck/1.9.1/operator.yaml
kubectl apply -f ./manifests/monitoring/elasticsearch_cluster.yml
kubectl apply -f ./manifests/monitoring/filebeat.yml
#export ES_PASSWD=$(kubectl get secret quickstart-es-elastic-user -o go-template='{{.data.elastic | base64decode}}')

read -p "check manually if elasticsearch is running 'kubectl get elasticsearch', then press enter to continue"

## check if prometheus is running
# TODO

# create observability namespace
kubectl create namespace observability # <1>
kubectl config set-context --current --namespace=observability

# install elasticsearch secret in observability namespace
kubectl config set-context --current --namespace=observability
secrets=`kubectl get secrets -n kube-system | grep quick | awk '{print $1}'`
for secret in "${secrets[@]}":
do
	echo "installing $secret\n"
	kubectl get secret $secret -n kube-system -o json \
	 | jq 'del(.metadata["namespace","creationTimestamp","resourceVersion","selfLink","uid"])' \
         | sed s/"\"namespace\": \"kube-system\""/"\"namespace\": \"istio-system\""/\
	 | grep -v '^\s*namespace:\s' \
	 | kubectl apply -n istio-system -f -

done

# install prometheus-stack
helm install prometheus-stack prometheus-community/kube-prometheus-stack --values ./manifests/monitoring/prom-config.yml -n observability

read -p "check manually if prometheus is running, then press enter to continue"
## kubectl --namespace observability get pods -l "release=prometheus-stack"

# install jaeger
kubectl apply -f ./manifests/monitoring/jaeger_es.yml

read -p "check manually if jaeger is running, then press enter to continue"

# install istio
kubectl create namespace istio-system
helm install istio-base istio/base --namespace istio-system --create-namespace --wait
helm install istiod istio/istiod -n istio-system --wait
kubectl create namespace istio-ingress
kubectl label namespace istio-ingress istio-injection=enabled
helm install istio-ingress istio/gateway -n istio-ingress --wait
helm install istio-egress istio/egressgateway -n istio-system --wait
kubectl get deployments -n istio-system --output wide
kubectl -n istio-system apply -f ./manifests/monitoring/kiali.yml

read -p "check manually if istio is running, then press enter to continue"



