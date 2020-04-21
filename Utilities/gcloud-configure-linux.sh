#!/bin/bash
#
#
export GCLOUD_PROJECT_NAME="ddr-adc-5"
export GCLOUD_CLUSTER_NAME="k1"
export GCLOUD_ZONE="us-west3-a"

# Regions
# us-west1	a, b, c	The Dalles, Oregon, USA
# us-west2	a, b, c	Los Angeles, California, USA
# us-west3	a, b, c	Salt Lake City, Utah, USA
# us-west4	a, b, c	Las Vegas, Nevada, USA

CMD_LIST=${1:-"start"}
case "$CMD_LIST" in
  test)
    echo "Test"
    ;;
  project-create)
    gcloud projects create $GCLOUD_PROJECT_NAME --set-as-default --enable-cloud-apis
    gcloud projects list
    gcloud services list --available | grep container
    ;;
  billing)
    #gcloud beta billing accounts list
    # This may install additional SDK capabiliites (select Y)
    gcloud beta billing accounts list
    ACCOUNT_ID=`gcloud beta billing accounts list --format="value(ACCOUNT_ID)"`
    echo "Using Account ID ($ACCOUNT_ID)"
    gcloud alpha billing accounts projects link $GCLOUD_PROJECT_NAME --account-id=$ACCOUNT_ID
    # Takes a few minutes
    gcloud services enable container.googleapis.com
    ;;
  cluster-create)
    gcloud container clusters create $GCLOUD_CLUSTER_NAME --zone $GCLOUD_ZONE --project $GCLOUD_PROJECT_NAME
    ;;
  cluster-delete)
    gcloud container clusters delete $GCLOUD_CLUSTER_NAME
    ;;
  install-gcloud-ubuntu)
    sudo snap install kubectl --classic
    sudo snap install google-cloud-sdk --classic
    gcloud init
    sudo chown ubuntu:ubuntu ~/.kube
    #gcloud container clusters get-credentials adcap1 --zone=us-west1-a
    ;;
  help)
    echo "Commands: "
    echo ""
    echo "cluster-create"
    echo "cluster-delete"
    echo "project-create"
    echo "install-gcloud"
    echo "billing"
    ;;
  *)
    echo "Not Found " "$@"
    ;;
esac
