# AD-Capital-K8s-Harness

This is a fully instrumented version of the AD-Capital application. It combines the deployment resources from AD-Capital-K8s-V1 and AD-Capital-K8s-Approval

AD-Capital-K8s/AD-Capital-K8s-V1 instruments the Pods using the Agent embedded in each container

AD-Capital-K8s/AD-Capital-K8s-Approval instruments the Approval Pods using the Init Container method

Configure the environment variables in the file `AD-Capital-K8s/envvars.appdynamics.NNN.sh`

Run the command:
`./ctl.sh appd-harness-configure-env`

This will configMaps needed to deploy the application:
````
secret.yaml
env-configmap.yaml
appdynamics-secrets.yaml
appdynamics-common-configmap.yaml
````

Deploy the application to the cluster using the command:
`kubectl create -f AD-Capital-K8s-Harness`

Validate the Pods are running:
`kubectl --all-namespaces=true get pod`
