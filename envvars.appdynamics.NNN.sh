# Environment variables - Use this file to capture all of the parameters to deploy
# the AppDynamics Cluster Agent

# Please fill in value for <place holders>

# AppDynamics Controller Environment Varibales
export APPDYNAMICS_CONTROLLER_HOST_NAME="<controller host name>"
export APPDYNAMICS_AGENT_ACCOUNT_ACCESS_KEY="<controller access key>"
export APPDYNAMICS_AGENT_ACCOUNT_NAME="<controller account name - short name>"
export APPDYNAMICS_GLOBAL_ACCOUNT_NAME="<controller global account name - long name>"

export APPDYNAMICS_CONTROLLER_PORT="8090"
export APPDYNAMICS_CONTROLLER_SSL_ENABLED="FALSE"

# AppDynamics Agent Configuration
export APPDYNAMICS_AGENT_APPLICATION_NAME="ADCAP_A1"

# Deployment directory for the Approval Node Init Container
export APPD_AGENT_BASE_DIR="/opt/appdynamics-agents"
export APPD_JAVA_AGENT_DIR="/opt/appdynamics-agents/java/javaagent.jar"

# AD-Capital Environment variables
export CONTAINER_IMAGE_ADCAP_APPROVALS="lincharles/adcapital-tomcat:v01"

# Cluster Agent Application Name
export APPDYNAMICS_CLUSTER_AGENT_APP_NAME="ADCAP_C1"

echo "The following environmnent variables have been set:"
env | grep APPD
