#!/bin/bash
#
#
_AppDynamics_Install_ClusterAgent() {
  # Create AppDynamics namespace
  kubectl create namespace appdynamics

  # Deploy the AppDynamics Cluster Agent Operator
  kubectl create -f cluster-agent-operator.yaml

  # Delete the secret to make sure
  kubectl --namespace=appdynamics delete secret cluster-agent-secret

  # Create the secret
  kubectl -n appdynamics create secret generic cluster-agent-secret --from-literal=controller-key="$APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY"
  sleep 5 # Allow time for secret to create

  # Validate the secret has been created
  kubectl get secret --namespace=appdynamics

  # Deploy the AppDynamics Cluster Agent
  kubectl create -f cluster-agent.yaml

  # Validate the Cluster Agent Pod has been created and is running, allow 1 minute for this to happen
  kubectl -n appdynamics get pods
}

if [ "$APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY" != "" ]; then
  echo "Installing AppDynamics Cluster Agent using Access Key: ($APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY)"
  _AppDynamics_Install_ClusterAgent
else
  echo "AppDynamics Cluster Agent Access Key not set: APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY"
fi
