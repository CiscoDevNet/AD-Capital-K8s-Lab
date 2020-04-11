#!/bin/bash
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


# Output file names
FILENAME_APPD_SECRETS="appdynamics-secrets.yaml"
FILENAME_APPD_CONFIGMAP="appdynamics-common-configmap.yaml"
FILENAME_ADCAP_APPROVALS_APPD="adcap-approvals-appdynamics-configmap.yaml"

_validateEnvironmentVars() {
  echo "Validating environment variables for $1"
  shift 1
  VAR_LIST=("$@") # rebuild using all args
  #echo $VAR_LIST
  for i in "${VAR_LIST[@]}"; do
    echo "$i=${!i}"
    if [ -z ${!i} ] || [[ "${!i}" == REQUIRED_* ]]; then
       echo "Please set the Environment variable: $i"; ERROR="1";
    fi
  done
  [ "$ERROR" == "1" ] && { echo "Exiting"; exit 1; }
}


_makeAppD_K8s_Secret_file() {
  _validateEnvironmentVars "AppDynamics Controller" "APPDYNAMICS_AGENT_ACCOUNT_NAME" "APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY"
OUTPUT_FILE_NAME=$FILENAME_APPD_SECRETS

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

echo "Create the file $OUTPUT_FILE_NAME"
#cat $SECRET_FILE_NAME
}


_makeAppD_K8s_Envvars_file() {
  _validateEnvironmentVars "AppDynamics Controller" "APPDYNAMICS_AGENT_APPLICATION_NAME" "APPDYNAMICS_CONTROLLER_HOST_NAME" \
                           "APPDYNAMICS_CONTROLLER_PORT" "APPDYNAMICS_CONTROLLER_SSL_ENABLED"
OUTPUT_FILE_NAME=$FILENAME_APPD_CONFIGMAP

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

echo "Create the file $OUTPUT_FILE_NAME"
#cat $SECRET_FILE_NAME
}



_AppDynamics_Install_ClusterAgent() {
  #!/bin/bash
  #
  # Create AppDynamics namespace
  $KUBECTL_CMD create namespace appdynamics
  $KUBECTL_CMD config set-context --current --namespace=appdynamics

  # Deploy the AppDynamics Cluster Agent Operator
  $KUBECTL_CMD create -f cluster-agent-operator.yaml

  # Delete the secret to make sure
  $KUBECTL_CMD --namespace=appdynamics delete secret cluster-agent-secret

  # Create the secret
  $KUBECTL_CMD -n appdynamics create secret generic cluster-agent-secret --from-literal=controller-key="$APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY"
  sleep 5 - allow time for secret to create

  # Validate the secret has been created
  $KUBECTL_CMD get secret --namespace=appdynamics

  # Deploy the AppDynamics Cluster Agent
  $KUBECTL_CMD create -f cluster-agent.yaml

  # Validate the Cluster Agent Pod has been created and is running, allow 1 minute for this to happen
  $KUBECTL_CMD -n appdynamics get pods

}

case "$CMD_LIST" in
  test)
    echo "Test"
    ;;
  appd-secrets-create)
    _makeAppD_K8s_Secret_file
    ;;
  appd-envvars-create)
    _makeAppD_K8s_Envvars_file
    ;;
  appd-create-cluster-agent)
    _AppDynamics_Install_ClusterAgent
    ;;
  adcap-approval)
    K8S_OP=${2:-"create"} # create | delete | apply
    $KUBECTL_CMD $K8S_OP -f adcap-approval-deployment.yaml
    $KUBECTL_CMD $K8S_OP -f adcap-approval-configmap.yaml
    $KUBECTL_CMD $K8S_OP -f $FILENAME_APPD_SECRETS
    $KUBECTL_CMD $K8S_OP -f $FILENAME_APPD_CONFIGMAP
    $KUBECTL_CMD $K8S_OP -f adcap-approval-appdynamics-configmap.yaml
    ;;
  adcap-v1)
    K8S_OP=${2:-"create"} # create | delete | apply
    $KUBECTL_CMD $K8S_OP -f AD-Capital-K8s-V1/secret.yaml
    $KUBECTL_CMD $K8S_OP -f AD-Capital-K8s-V1/env-configmap.yaml
    $KUBECTL_CMD $K8S_OP -f AD-Capital-K8s-V1/rabbitmq-deployment.yaml
    $KUBECTL_CMD $K8S_OP -f AD-Capital-K8s-V1/rest-deployment.yaml
    $KUBECTL_CMD $K8S_OP -f AD-Capital-K8s-V1/adcapitaldb-deployment.yaml
    $KUBECTL_CMD $K8S_OP -f AD-Capital-K8s-V1/portal-deployment.yaml
    $KUBECTL_CMD $K8S_OP -f AD-Capital-K8s-V1/processor-deployment.yaml
    $KUBECTL_CMD $K8S_OP -f AD-Capital-K8s-V1/verification-deployment.yaml
    $KUBECTL_CMD $K8S_OP -f AD-Capital-K8s-V1/approval-deployment.yaml
    $KUBECTL_CMD $K8S_OP -f AD-Capital-K8s-V1/load-deployment.yaml
     ;;
  obsfuscate)
    . envvars.appdynamics.NNN.sh
    _makeAppD_K8s_Secret_file
    _makeAppD_K8s_Envvars_file
    ;;
  help)
    echo "Commands: "
    echo "appd-secrets-create -  create the AppD K8s secret environment variables resource file"
    echo "appd-envvars-create -  create the AppD K8s environment variables resource file"
    echo "appd-create-cluster-agent - deploy the AppDyamics Cluster Agent"
    echo "adcap-v1 [create | delete ] - create/delete AD-Capital applications version 1 - all nodes"
    echo "adcap-approval [create | delete ] - create/delete AD-Capital Approval node version 2"
    ;;
  *)
    echo "Not Found " "$@"
    ;;
esac
