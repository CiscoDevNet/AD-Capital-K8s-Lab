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

_make_appd_controller_service_file() {
  OUTPUT_FILE_NAME="$1.service"

# Note indentation is critical between cat and EOF
cat << EOF > $OUTPUT_FILE_NAME
[Unit]
Description=AppDynamics Controller
After=multi-user.target

[Service]
User=centos
Type=oneshot
RemainAfterExit=yes
TimeoutSec=300
ExecStart=/usr/bin/appd-controller.sh  start
ExecStop=/usr/bin/appd-controller.sh   stop

[Install]
WantedBy=multi-user.target
EOF
#####

echo "Created the file $OUTPUT_FILE_NAME"
#cat $SECRET_FILE_NAME
}

_installService() {
    SERVICE_NAME=$1
    echo "Installing $SERVICE_NAME"
    sudo systemctl disable $SERVICE_NAME

    sudo cp $SERVICE_NAME.service /etc/systemd/system
    sudo systemctl enable $SERVICE_NAME
}

_appd_StartController() {
  $PADMIN start-platform-admin
  $PADMIN login --user-name $PADMIN_USER --password $PADMIN_PWD
  $PADMIN list-platforms
  $PADMIN start-controller-db
  $PADMIN start-controller-appserver
  $PADMIN submit-job --platform-name MyPlatform --service events-service --job start
}

_appd_StopController() {
  $PADMIN login --user-name $PADMIN_USER --password $PADMIN_PWD
  $PADMIN list-platforms
  $PADMIN submit-job --platform-name MyPlatform --service events-service --job stop
  $PADMIN stop-controller-appserver
  $PADMIN stop-controller-db
}

CMD_LIST=${1:-"start"}
case "$CMD_LIST" in
  test)
    echo "Test"
    ;;
  start)
    _appd_StartController
    ;;
  stop)
    _appd_StopController
    ;;
  restart)
    _appd_StopController
    sleep 5
    _appd_StartController
    ;;
  install)
    _make_appd_controller_service_file "appd-controller"
    _installService "appd-controller"
    sudo cp appd-controller.sh  /usr/bin
    sudo chmod +x /usr/bin/appd-controller.sh
    ;;
  make-service)
    _make_appd_controller_service_file "appd-controller"
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
