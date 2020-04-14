#!/bin/bash
# Requires yq (https://mikefarah.gitbook.io/yq/)
kubectl apply -f appd-env-script-config.yaml
yq m -x ../../AD-Capital-K8s-V1/approval-deployment.yaml yq-patch-approval.yaml | kubectl apply -f -
yq m -x ../../AD-Capital-K8s-V1/processor-deployment.yaml yq-patch-others.yaml | kubectl apply -f -
yq m -x ../../AD-Capital-K8s-V1/portal-deployment.yaml yq-patch-others.yaml | kubectl apply -f -
yq m -x ../../AD-Capital-K8s-V1/rest-deployment.yaml yq-patch-others.yaml | kubectl apply -f -
yq m -x ../../AD-Capital-K8s-V1/verification-deployment.yaml yq-patch-others.yaml | kubectl apply -f -
