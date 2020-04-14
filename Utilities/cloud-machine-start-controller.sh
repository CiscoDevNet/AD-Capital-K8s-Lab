#!/bin/bash
#
# Start the AppDynamics Controller and Events Service running from the Cloud Machine Image 20.3.3-NoSSH-Controller
#
# Location of the AppDynamics Platform Admin Command
PADMIN=~/appdynamics/platform/platform-admin/bin/platform-admin.sh
#
PADMIN_USER="admin"
PADMIN_PWD="appd"
#
$PADMIN start-platform-admin
$PADMIN login --user-name $PADMIN_USER --password $PADMIN_PWD
$PADMIN list-platforms
$PADMIN start-controller-db
$PADMIN start-controller-appserver
$PADMIN submit-job --platform-name MyPlatform --service events-service --job start
