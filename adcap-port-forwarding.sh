#!/bin/bash
#
# AppDynamics AD-Capital Port Forwarding
#
# Maintainer: David Ryder
#
# Ref:
# https://github.com/Appdynamics/AD-Capital-Docker/blob/master/ADCapital-Load/Dockerfile
#
_configureKubernetesPortForwrding() {
  K8S_RESOURCE=$1
  NAME_SPACE=$2
  IP_ADDR=$3
  SRC_PORT=$4
  DST_PORT=$5
  # netstat -ltnp
  echo "Forwarding $SRC_PORT to $DST_PORT on $IP_ADDR for $NAME_SPACE - $K8S_RESOURCE"
  nohup microk8s.kubectl port-forward --address $IP_ADDR --namespace $NAME_SPACE $K8S_RESOURCE $SRC_PORT:$DST_PORT &
  ps -ef | grep port-forward
}

_stopKubernetesPortForwarding() {
    pkill -f 'kubectl port-forward'
}


# Localhost or external IP of Cloud Machine Host
IP_ADDR=`hostname -i`

microk8s.kubectl --all-namespaces=true get pod
# NAMESPACE     NAME                           READY   STATUS    RESTARTS   AGE
# ....
# default       portal-5847b9976-5ntff         1/1     Running   0          100m
# default       processor-6d5b4b8775-nzk64     1/1     Running   0          100m
# ....

# Processor node on port 9001
_configureKubernetesPortForwrding "deployment/processsor" "default" $IP_ADDR 9001 8080

# Portal node on port 9002
_configureKubernetesPortForwrding "deployment/portal"     "default" $IP_ADDR 9002 8080


# Generate some load to test the port forwarding from an external host
CM_STATIC_DNS="controller6-ubuntu1804-qngmdjhr.appd-sales.com"

# Processor Node BTs
curl http://$CM_STATIC_DNS:9001/processor/Underwrite
curl http://$CM_STATIC_DNS:9001/processor/CreditCheck

# Portal Node BTs
curl http://$CM_STATIC_DNS:9002/portal/CustomerLogin
curl http://$CM_STATIC_DNS:9002/portal/SubmitApplication

exit 0
