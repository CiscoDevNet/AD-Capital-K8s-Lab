#!/bin/bash
#
# Automates many of the tasks to configure and deploy the AD-Capital applicaiton to A K8s Cluster
#
#
CMD_LIST=${1:-"help"}

# Check docker: Linux or Ubuntu snap
DOCKER_CMD=`which docker`
DOCKER_CMD=${DOCKER_CMD:-"/snap/bin/microk8s.docker"}
echo "Using: $DOCKER_CMD"
if [ -d $DOCKER_CMD ]; then
    echo "Docker is missing: "$DOCKER_CMD
    exit 1
fi

# Check docker: Linux or Ubuntu snap
KUBECTL_CMD=`which kubectl`
KUBECTL_CMD=${KUBECTL_CMD:-"/snap/bin/microk8s.kubectl"}
echo "Using: $KUBECTL_CMD"
if [ -d $KUBECTL_CMD ]; then
    echo "Kubectl is missing: ($KUBECTL_CMD)"
    exit 1
fi

# Directories relative to AD-Capital-K8s-Lab
DIR_CLUSTER_AGENT="cluster-agent"
DIR_ADCAP_APRROVAL="AD-Capital-K8s-Approval"

# Output file names
FILENAME_APPD_SECRETS="appdynamics-secrets.yaml"
FILENAME_APPD_CONFIGMAP="appdynamics-common-configmap.yaml"
FILENAME_ADCAP_APPROVALS_APPD="adcap-approvals-appdynamics-configmap.yaml"
FILENAME_APPD_CLUSTER_AGENT_RESOURCE_FILE="cluster-agent.yaml"

# Originbal Configmaps from AD-Capital-Kube Kubernetes Directory
FILENAME_ORIGINAL_SECRETS="secret.yaml"
FILENAME_ORIGINAL_ENVMAP="env-configmap.yaml"

_validateEnvironmentVars() {
  echo "Validating environment variables for $1"
  shift 1
  VAR_LIST=("$@") # rebuild using all args
  #echo $VAR_LIST
  for i in "${VAR_LIST[@]}"; do
    echo "  $i=${!i}"
    if [ -z "${!i}" ] || [[ "${!i}" == REQUIRED_* ]]; then
       echo "Please set the Environment variable: $i"; ERROR="1";
    fi
  done
  [ "$ERROR" == "1" ] && { echo "Exiting"; exit 1; }
}


_makeAppD_makeConfigMap_appdynamics_secrets() {
  OUTPUT_FILE_NAME=$1
  _validateEnvironmentVars "AppDynamics Controller $OUTPUT_FILE_NAME" \
                           "APPDYNAMICS_AGENT_ACCOUNT_NAME" "APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY"

# Note indentation is critical between cat and EOF
cat << EOF > $OUTPUT_FILE_NAME
# Environment varibales requried for ADCAP approvals - Secret Base64 Encoded
---
apiVersion: v1
kind: Secret
metadata:
  name: appdynamics-secrets
type: Opaque
data:
  APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY: "`echo -n $APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY | base64`"
  APPDYNAMICS_AGENT_ACCOUNT_NAME: "`echo -n $APPDYNAMICS_AGENT_ACCOUNT_NAME | base64`"
EOF
#####

echo "Created the file $OUTPUT_FILE_NAME"
#cat $SECRET_FILE_NAME
}

_makeAppD_makeConfigMap_original_secrets() {
  OUTPUT_FILE_NAME=$1
  _validateEnvironmentVars "AppDynamics Controller $OUTPUT_FILE_NAME"  \
                           "APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY" "APPDYNAMICS_AGENT_ACCOUNT_NAME"

# Note indentation is critical between cat and EOF
cat << EOF > $OUTPUT_FILE_NAME
# Environment varibales requried for ADCAP approvals - Secret Base64 Encoded
---
apiVersion: v1
kind: Secret
metadata:
  name: mysecret
type: Opaque
data:
  accesskey: "`echo -n $APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY | base64`"
  accountname: "`echo -n $APPDYNAMICS_AGENT_ACCOUNT_NAME | base64`"
EOF
#####
}


_makeAppD_makeConfigMap_appdynamics_common() {
  OUTPUT_FILE_NAME=$1
  _validateEnvironmentVars "AppDynamics Controller $OUTPUT_FILE_NAME"  \
                           "APPDYNAMICS_AGENT_APPLICATION_NAME" "APPDYNAMICS_CONTROLLER_HOST_NAME" \
                           "APPDYNAMICS_CONTROLLER_PORT" "APPDYNAMICS_CONTROLLER_SSL_ENABLED"

# Note indentation is critical between cat and EOF
cat << EOF > $OUTPUT_FILE_NAME
# Environment variables common across all AppDynamics Agents -  Clear Text
---
apiVersion: v1
kind: ConfigMap
metadata:
  creationTimestamp: null
  name: appdynamics-common
data:
  APPD_DIR: "/appdynamics"
  APPD_ES_HOST: ""
  APPD_ES_PORT: "9080"
  APPD_ES_SSL: "false"
  APPD_EVENT_ACCOUNT_NAME: "XXX"
  APPDYNAMICS_AGENT_APPLICATION_NAME: "$APPDYNAMICS_AGENT_APPLICATION_NAME"
  APPDYNAMICS_CONTROLLER_HOST_NAME: "$APPDYNAMICS_CONTROLLER_HOST_NAME"
  APPDYNAMICS_CONTROLLER_PORT: "$APPDYNAMICS_CONTROLLER_PORT"
  APPDYNAMICS_CONTROLLER_SSL_ENABLED: "$APPDYNAMICS_CONTROLLER_SSL_ENABLED"
  APPD_JAVAAGENT: "-javaagent:/opt/appdynamics-agents/java/javaagent.jar"
  APPDYNAMICS_NETVIZ_AGENT_PORT: "3892"
EOF
#####
}


_makeAppD_makeConfigMap_original_env_map() {
  OUTPUT_FILE_NAME=$1
  _validateEnvironmentVars "AppDynamics Controller $OUTPUT_FILE_NAME"  \
                           "APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY" "APPDYNAMICS_AGENT_ACCOUNT_NAME" \
                           "APPDYNAMICS_AGENT_APPLICATION_NAME" "APPDYNAMICS_CONTROLLER_HOST_NAME" \
                           "APPDYNAMICS_CONTROLLER_PORT" "APPDYNAMICS_CONTROLLER_SSL_ENABLED"

# Note indentation is critical between cat and EOF
cat << EOF > $OUTPUT_FILE_NAME
# Environment variables common across all AppDynamics Agents -  Clear Text
---
apiVersion: v1
kind: ConfigMap
metadata:
  creationTimestamp: null
  name: env-map
data:
  APPD_DIR: "/appdynamics"
  APPD_ES_HOST: ""
  APPD_ES_PORT: "9080"
  APPD_ES_SSL: "false"
  APPD_EVENT_ACCOUNT_NAME: "XXX"
  APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY: "$APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY"
  APPDYNAMICS_AGENT_ACCOUNT_NAME: "$APPDYNAMICS_AGENT_ACCOUNT_NAME"
  APPDYNAMICS_AGENT_APPLICATION_NAME: "$APPDYNAMICS_AGENT_APPLICATION_NAME"
  APPDYNAMICS_CONTROLLER_HOST_NAME: "$APPDYNAMICS_CONTROLLER_HOST_NAME"
  APPDYNAMICS_CONTROLLER_PORT: "$APPDYNAMICS_CONTROLLER_PORT"
  APPDYNAMICS_CONTROLLER_SSL_ENABLED: "$APPDYNAMICS_CONTROLLER_SSL_ENABLED"
  APPDYNAMICS_NETVIZ_AGENT_PORT: "3892"
  RETRY: 10s
  TIMEOUT: 300s
EOF
#####
}

#APPD_JAVAAGENT: "-javaagent:/opt/appdynamics-agents/java/javaagent.jar"

_makeAppD_makeConfigMap_Cluster_Agent() {
  OUTPUT_FILE_NAME=$1
  _validateEnvironmentVars "AppDynamics Cluster Agent $OUTPUT_FILE_NAME"  \
                           "APPDYNAMICS_CLUSTER_AGENT_APP_NAME" "APPDYNAMICS_CONTROLLER_HOST_NAME" \
                           "APPDYNAMICS_AGENT_ACCOUNT_NAME"

# Note indentation is critical between cat and EOF
cat << EOF > $OUTPUT_FILE_NAME
apiVersion: appdynamics.com/v1alpha1
kind: Clusteragent
metadata:
  name: k8s-cluster-agent
  namespace: appdynamics
spec:
  appName: "$APPDYNAMICS_CLUSTER_AGENT_APP_NAME"
  controllerUrl: "http://$APPDYNAMICS_CONTROLLER_HOST_NAME:8090"
  account: "$APPDYNAMICS_AGENT_ACCOUNT_NAME"
  # Use the AppDynamics Published Image
  image: "appdynamics/cluster-agent:20.3.0"
  # image: "<your-docker-registry>/appdynamics/cluster-agent:tag"
  serviceAccountName: appdynamics-cluster-agent
  ### Uncomment the following two lines if you need pull secrets
  #imagePullSecrets:
  #  name: "<your-docker-pull-secret-name>
  nsToMonitor:
    - se-days
EOF
#####
}

_checkDirExists() {
  DIR_DESCRIPTION=$1
  DIR_TO_CHECK=$2
  if [ ! -d "$DIR_TO_CHECK" ]; then
    echo "Directory for $DIR_DESCRIPTION does not exist, expected $DIR_TO_CHECK"
    echo "Exiting"; exit 1;
  fi
}

_AppDynamics_Install_ClusterAgent() {
  _checkDirExists "Cluster Agent Install" $DIR_CLUSTER_AGENT
  #
  # Create AppDynamics namespace
  $KUBECTL_CMD create namespace appdynamics

  # Deploy the AppDynamics Cluster Agent Operator
  $KUBECTL_CMD create -f $DIR_CLUSTER_AGENT/cluster-agent-operator.yaml

  # Delete the secret to make sure
  $KUBECTL_CMD --namespace=appdynamics delete secret cluster-agent-secret

  # Create the secret
  $KUBECTL_CMD -n appdynamics create secret generic cluster-agent-secret --from-literal=controller-key="$APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY"
  sleep 5 # Allow time for secret to create

  # Validate the secret has been created
  $KUBECTL_CMD get secret --namespace=appdynamics

  # Deploy the AppDynamics Cluster Agent
  $KUBECTL_CMD create -f $DIR_CLUSTER_AGENT/cluster-agent.yaml

  # Validate the Cluster Agent Pod has been created and is running, allow 1 minute for this to happen
  $KUBECTL_CMD -n appdynamics get pods
}

_AppDynamics_ClusterAgent_Check_AccessKey() {
  kubectl get secrets/cluster-agent-secret -o jsonpath="{.data.controller-key}" | base64 --decode
}

_AppDynamics_Delete_ClusterAgent() {
  _checkDirExists "Cluster Agent Install" $DIR_CLUSTER_AGENT
  $KUBECTL_CMD delete -f $DIR_CLUSTER_AGENT/cluster-agent.yaml
  $KUBECTL_CMD delete -f $DIR_CLUSTER_AGENT/cluster-agent-operator.yaml
  $KUBECTL_CMD --namespace=appdynamics delete secret cluster-agent-secret
  $KUBECTL_CMD delete namespace appdynamics
}


case "$CMD_LIST" in
  test)
    echo "Test"
    ;;
  appd-harness-configure-env)
    _makeAppD_makeConfigMap_appdynamics_secrets AD-Capital-K8s-Harness/$FILENAME_APPD_SECRETS
    _makeAppD_makeConfigMap_appdynamics_common AD-Capital-K8s-Harness/$FILENAME_APPD_CONFIGMAP
    _makeAppD_makeConfigMap_original_secrets AD-Capital-K8s-Harness/$FILENAME_ORIGINAL_SECRETS
    _makeAppD_makeConfigMap_original_env_map AD-Capital-K8s-Harness/$FILENAME_ORIGINAL_ENVMAP
    ;;
  appd-cluster-agent-configure-env)
    _checkDirExists "Cluster Agent Install" $DIR_CLUSTER_AGENT
    _makeAppD_makeConfigMap_Cluster_Agent $DIR_CLUSTER_AGENT/$FILENAME_APPD_CLUSTER_AGENT_RESOURCE_FILE
    ;;
  appd-cluster-agent-deploy)
    _AppDynamics_Install_ClusterAgent
    ;;
  appd-cluster-agent-delete)
    _AppDynamics_Delete_ClusterAgent
    ;;
  appd_cluster-agent-check-access-key)
    _AppDynamics_ClusterAgent_Check_AccessKey
    ;;
  adcap-approval-configure-env)
    _makeAppD_makeConfigMap_appdynamics_secrets   "AD-Capital-K8s-Approval/$FILENAME_APPD_SECRETS"
    _makeAppD_makeConfigMap_appdynamics_common "AD-Capital-K8s-Approval/$FILENAME_APPD_CONFIGMAP"
    ;;
  adcap-approval)
    K8S_OP=${2:-"create"} # create | delete | apply
    #$KUBECTL_CMD config set-context --current --namespace=$ADCAP_K8S_NAMESPACE
    $KUBECTL_CMD config view --minify | grep namespace
    $KUBECTL_CMD $K8S_OP --namespace=$ADCAP_K8S_NAMESPACE -f "$DIR_ADCAP_APRROVAL/adcap-approval-deployment.yaml"
    $KUBECTL_CMD $K8S_OP --namespace=$ADCAP_K8S_NAMESPACE -f "$DIR_ADCAP_APRROVAL/adcap-approval-configmap.yaml"
    $KUBECTL_CMD $K8S_OP --namespace=$ADCAP_K8S_NAMESPACE -f "$DIR_ADCAP_APRROVAL/$FILENAME_APPD_SECRETS"
    $KUBECTL_CMD $K8S_OP --namespace=$ADCAP_K8S_NAMESPACE -f "$DIR_ADCAP_APRROVAL/$FILENAME_APPD_CONFIGMAP"
    $KUBECTL_CMD $K8S_OP --namespace=$ADCAP_K8S_NAMESPACE -f "$DIR_ADCAP_APRROVAL/adcap-approval-appdynamics-configmap.yaml"
    ;;
  adcap-v1-configure-env)
    _makeAppD_makeConfigMap_original_env_map "AD-Capital-K8s-V1/$FILENAME_ORIGINAL_ENVMAP"
    _makeAppD_makeConfigMap_original_secrets "AD-Capital-K8s-V1/$FILENAME_ORIGINAL_SECRETS"
    ;;
  adcap-v1)
    K8S_OP=${2:-"create"} # create | delete | apply
    #$KUBECTL_CMD config set-context --current --namespace=$ADCAP_K8S_NAMESPACE
    $KUBECTL_CMD config view --minify | grep namespace
    $KUBECTL_CMD $K8S_OP --namespace=$ADCAP_K8S_NAMESPACE -f AD-Capital-K8s-V1/secret.yaml
    $KUBECTL_CMD $K8S_OP --namespace=$ADCAP_K8S_NAMESPACE -f AD-Capital-K8s-V1/env-configmap.yaml
    $KUBECTL_CMD $K8S_OP --namespace=$ADCAP_K8S_NAMESPACE -f AD-Capital-K8s-V1/rabbitmq-deployment.yaml
    $KUBECTL_CMD $K8S_OP --namespace=$ADCAP_K8S_NAMESPACE -f AD-Capital-K8s-V1/rest-deployment.yaml
    $KUBECTL_CMD $K8S_OP --namespace=$ADCAP_K8S_NAMESPACE -f AD-Capital-K8s-V1/adcapitaldb-deployment.yaml
    $KUBECTL_CMD $K8S_OP --namespace=$ADCAP_K8S_NAMESPACE -f AD-Capital-K8s-V1/portal-deployment.yaml
    $KUBECTL_CMD $K8S_OP --namespace=$ADCAP_K8S_NAMESPACE -f AD-Capital-K8s-V1/processor-deployment.yaml
    $KUBECTL_CMD $K8S_OP --namespace=$ADCAP_K8S_NAMESPACE -f AD-Capital-K8s-V1/verification-deployment.yaml
    $KUBECTL_CMD $K8S_OP --namespace=$ADCAP_K8S_NAMESPACE -f AD-Capital-K8s-V1/approval-deployment.yaml
    $KUBECTL_CMD $K8S_OP --namespace=$ADCAP_K8S_NAMESPACE -f AD-Capital-K8s-V1/load-deployment.yaml
    ;;
  help)
    echo "Commands: "
    echo ""
    echo "adcap-v1-configure-env            - Configure the configMaps in AD-Capital-K8s-V1"
    echo "adcap-v1 [create | delete ]       - create/delete AD-Capital applications version 1 - all nodes"
    echo ""
    echo "adcap-approval-configure-env      - Configure the configMaps in AD-Capital-K8s-Approval"
    echo "adcap-approval [create | delete ] - create/delete AD-Capital Approvals Deployment"
    echo ""
    echo "appd-cluster-agent-configure-env - create the Cluster Agent resource file"
    echo "appd-cluster-agent-deploy        - deploy the AppDyamics Cluster Agent"
    echo "appd-cluster-agent-delete        - delete the AppDyamics Cluster Agent"
    echo ""
    echo "appd-harness-configure-env   - Configure the configMaps in AD-Capital-K8s-Harness"
    ;;
  *)
    echo "Not Found " "$@"
    ;;
esac
