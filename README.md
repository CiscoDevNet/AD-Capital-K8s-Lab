# AD-Capital-K8s-Lab

This repository contains all of files to complete the AD-Capital K8s labs. The following directories are relevant:

`AD-Capital-K8s-V1`
Contains all of the K8s Resource Definition files to deploy Version 1 of AD-Capital application to a K8s cluster

`AD-Capital-K8s-V2`
Contains the tooling to automate the configuration of K8s Resource Definition files in `AD-Capital-K8s-V1`

`AD-Capital-K8s-Harness`
This is a fully instrumented independent version of the AD-Capital application. It combines the deployment resources from `AD-Capital-K8s-V1` and `AD-Capital-K8s-Approval` in readiness for the Harness section of this labs

`Rookout`
This is a fully instrumented independent version of the AD-Capital application in readiness for the Rookout section of this lab.

`AD-Capital-K8s-Approval`
Contains fully instrumented version of the AD-Capital Approval Pod

`envvars.appdynamics.NNN.sh`
Configure the environment variables in this file to capture all of the parameters to deploy: the AD-Capital Application, the AppDynamics Cluster Agent to an AppDynamics Controller and a K8s Cluster. 
Used by `ctl.sh`

`ctl.sh`
Helper script that automates many of the tasks to configure and deploy the AD-Capital application to a K8s Cluster. 
Uses `envvars.appdynamics.NNN.sh`

`Utilities`
Other useful scripts
