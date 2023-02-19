
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )


if [[ $1 = "install" ]]
then
	kubectl create namespace social-network 
	kubectl label namespace social-network istio-injection=enabled --overwrite
	helm install social-network --create-namespace  --namespace social-network  $SCRIPT_DIR/../third_party/DeathStarBench/socialNetwork/helm-chart/socialnetwork/ --timeout 10m0s --values $SCRIPT_DIR/config.yaml
fi

if [[ $1 == "init" ]]
then
	port=`kubectl -n social-network get svc nginx-thrift | tail -n 1| awk '{print $5}'|grep -Po '([0-9]+)'|tail -n1`
	fwdport=`lsof -i -P -n | grep LISTEN | grep 7827`
	if [[ -z $fwdport ]]
	then
		kubectl port-forward -n social-network svc/nginx-thrift 7827:$port &
		sleep 5
	fi

	cd $SCRIPT_DIR/../third_party/DeathStarBench/socialNetwork/
	python3 ./scripts/init_social_graph.py --ip localhost --port 7827
	kill -9 `sudo lsof -t -i:7827`
fi
if [[ $1 == "test" ]]
then
	port=`kubectl -n social-network get svc nginx-thrift | tail -n 1| awk '{print $5}'|grep -Po '([0-9]+)'|tail -n1`
	fwdport=`lsof -i -P -n | grep LISTEN | grep 7827`
	if [[ -z $fwdport ]]
	then
		kubectl port-forward -n social-network svc/nginx-thrift 7827:$port &
		sleep 5
	fi
	cd $SCRIPT_DIR/../third_party/DeathStarBench/wrk2/
	make -j
	./wrk -D exp -t 8 -c 100 -R 1600 -d 1m -L -s $SCRIPT_DIR/../third_party/DeathStarBench/socialNetwork/wrk2/scripts/social-network/mixed-workload.lua http://localhost:7827
	cd $SCRIPT_DIR
fi

if [[ $1 == "uninstall" ]]
then
	helm uninstall social-network -n social-network 
fi
