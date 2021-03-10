#!/bin/bash

DIRECTORY=`dirname $0`
NAMESPACE=$1

oc apply -f ${DIRECTORY}/../labs/pipelines -n ${NAMESPACE}

tkn pipeline start coolstore-java-pipeline -n ${NAMESPACE} \
    --prefix-name catalog \
    --workspace name=shared-workspace,claimName=catalog-pipeline-pvc \
    --param APP_NAME=catalog \
    --param APP_GIT_URL=https://github.com/mcouliba/cloud-native-workshop.git \
    --param APP_GIT_CONTEXT=labs/catalog-spring-boot \
    --param NAMESPACE=${NAMESPACE}

tkn pipeline start coolstore-java-pipeline -n ${NAMESPACE} \
    --prefix-name gateway \
    --workspace name=shared-workspace,claimName=gateway-pipeline-pvc \
    --param APP_NAME=gateway \
    --param APP_GIT_URL=https://github.com/mcouliba/cloud-native-workshop.git \
    --param APP_GIT_CONTEXT=labs/gateway-vertx \
    --param NAMESPACE=${NAMESPACE}

tkn pipeline start coolstore-nodejs-pipeline -n ${NAMESPACE} \
    --prefix-name web \
    --workspace name=shared-workspace,claimName=web-pipeline-pvc \
    --param APP_NAME=web \
    --param APP_GIT_URL=https://github.com/mcouliba/cloud-native-workshop.git \
    --param APP_GIT_CONTEXT=labs/web-nodejs \
    --param NAMESPACE=${NAMESPACE}

echo -e "\033[0;32mThe deployment of the Coolstore Application by OpenShift Pipeline has succeeded\033[0m"