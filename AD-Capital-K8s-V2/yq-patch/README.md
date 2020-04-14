# yq-patch

Necessary files to use yq tool to update and redeploy yaml files

## Apply patch to approval-deployment
- View the results of patch:

  >`yq -CP  m -x ../../AD-Capital-K8s-V1/approval-deployment.yaml yq-patch-approval.yaml`

- Apply patch and redeploy directly:

  >`kubectl apply -f appd-env-script-config.yaml`

  >`yq  m -x ../../AD-Capital-K8s-V1/approval-deployment.yaml yp-patch-approval.yaml | kubectl apply -f -`


