#!/bin/bash

DIRECTORY=`dirname $0`
PROJECT=$1

echo "------ START DEPLOYMENT COOLSTORE ------"

oc new-build java \
  --name=catalog-coolstore \
  --labels=app=coolstore,app.kubernetes.io/instance=catalog \
  --namespace=${PROJECT} \
  --context-dir=/labs/catalog-spring-boot \
  https://github.com/mcouliba/cloud-native-workshop#completed

oc new-build java \
  --name=gateway-coolstore \
  --labels=app=coolstore,app.kubernetes.io/instance=gateway \
  --namespace=${PROJECT} \
  --context-dir=/labs/gateway-vertx \
  https://github.com/mcouliba/cloud-native-workshop#completed

oc create --namespace=${PROJECT} -f ${DIRECTORY}/oc-start-build-git-task.yaml

oc create --namespace=${PROJECT} -f ${DIRECTORY}/git-pipeline.yaml

tkn pipeline start git-pipeline \
    --param componentName=catalog-coolstore \
    --serviceaccount pipeline \
    --namespace ${PROJECT}

tkn pipeline start git-pipeline \
    --param componentName=gateway-coolstore \
    --serviceaccount pipeline \
    --namespace ${PROJECT}

tkn pipeline start git-pipeline \
    --param componentName=web-coolstore \
    --serviceaccount pipeline \
    --namespace ${PROJECT}

echo "------  END DEPLOYMENT COOLSTORE  ------"