#/bin/bash

#### REQUIRES ###


# istio 1.12

#################

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=$SCRIPT_DIR/..

########################## START CONFIG PARAMS ################

NS="bookinfo"
APP_DIR=${ROOT_DIR}/apps/bookinfo
APP_INSTALL_DIR=${APP_DIR}/platform/kube/
AID=${APP_INSTALL_DIR}

########################## END CONFIG PARAMS ###################

#todo check if kube-env.sh exist else ask user to add istioctl in path
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
ROOT_DIR=$SCRIPT_DIR/..


if [[ $1 = "install" ]]
then
	# namespace in which we will create the app
	kubectl create namespace $NS

	# kubectl activate namespace
	kubectl config set-context --current --namespace=$NS

	# inject istio into the created namespace
	kubectl label namespace $NS istio-injection=enabled

	# install app
	cd $AID
	kubectl apply -f bookinfo.yaml
	kubectl apply -f bookinfo-ratings-v2.yaml
	kubectl apply -f bookinfo-db.yaml
	kubectl apply -f load-generator.yaml
	kubectl apply -f $APP_DIR/networking/destination-rule-all.yaml

	read -p "wait for pods to get deployed. First use may take several minutes. press enter to continue"

	kubectl apply -f $APP_DIR/networking/virtual-service-ratings-db.yaml

	kubectl apply -f $APP_DIR/networking/bookinfo-gateway.yaml

	cd $SCRIPT_DIR
	# open gateway to outside traffic
	# kubectl port-forward --address 0.0.0.0 service/productpage 9080
	exit
fi

if [[ $1 = "uninstall" ]]
then
	# uninstall app
	kubectl config set-context --current --namespace=$NS

	kubectl delete -f $APP_DIR/networking/bookinfo-gateway.yaml
	kubectl delete -f $APP_DIR/networking/virtual-service-ratings-db.yaml
	kubectl delete -f $APP_DIR/networking/destination-rule-all.yaml
	cd $AID
	kubectl delete -f bookinfo-db.yaml
	kubectl delete -f bookinfo-ratings-v2.yaml

	cd $SCRIPT_DIR
	exit
fi

echo "No valid option selected"
