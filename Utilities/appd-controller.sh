#!/bin/bash
#
# Start | Stop the AppDynamics Controller and Events Service running from
# the Cloud Machine Image 20.3.3-NoSSH-Controller (centos)
#
# Location of the AppDynamics Platform Admin Command
PADMIN=/home/centos/appdynamics/platform/platform-admin/bin/platform-admin.sh
#
# Platform Admin user/pwd
PADMIN_USER="admin"
PADMIN_PWD="appd"
#

_installService() {
    SERVICE_NAME=$1
    echo "Installing $SERVICE_NAME"
    sudo systemctl disable $SERVICE_NAME

    sudo cp $SERVICE_NAME.service /etc/systemd/system
    sudo systemctl enable $SERVICE_NAME
}

CMD_LIST=${1:-"start"}
case "$CMD_LIST" in
  test)
    echo "Test"
    ;;
  start)
    sudo su - centos
    $PADMIN start-platform-admin
    $PADMIN login --user-name $PADMIN_USER --password $PADMIN_PWD
    $PADMIN list-platforms
    $PADMIN start-controller-db
    $PADMIN start-controller-appserver
    $PADMIN submit-job --platform-name MyPlatform --service events-service --job start
    ;;
  stop)
    sudo su - centos
    $PADMIN login --user-name $PADMIN_USER --password $PADMIN_PWD
    $PADMIN list-platforms
    $PADMIN submit-job --platform-name MyPlatform --service events-service --job stop
    $PADMIN stop-controller-db
    $PADMIN stop-controller-appserver
    ;;
  install)
    _installService "appd-controller"
    sudo cp appd-controller.sh  /usr/bin
    sudo chmod +x /usr/bin/appd-controller.sh
    ;;
  help)
    echo "Commands: "
    echo ""
    echo "start"
    echo "stop"
    echo "install"
    ;;
  *)
    echo "Not Found " "$@"
    ;;
esac
