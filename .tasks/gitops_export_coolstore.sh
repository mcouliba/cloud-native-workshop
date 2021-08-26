#!/bin/bash

DIRECTORY=`dirname $0`
GITOPS_DIR=/projects/workshop/labs/gitops
DEV_PROJECT=$1
PROJECT=$2

declare -a COMPONENTS=("inventory-coolstore" "catalog-coolstore" "gateway-coolstore" "web-coolstore")

echo "--- Export Kubernetes resources for GitOps from ${DEV_PROJECT} to ${PROJECT} ---"

mkdir -p ${GITOPS_DIR} 2> /dev/null

for COMPONENT_NAME in "${COMPONENTS[@]}"
do
    echo "Exporting resources for ${COMPONENT_NAME}..."

    COMPONENT_DIR=${GITOPS_DIR}/${COMPONENT_NAME}

    mkdir ${COMPONENT_DIR} 2> /dev/null

    SECRET_YAML=${COMPONENT_DIR}/secret.yaml
    SERVICE_YAML=${COMPONENT_DIR}/service.yaml
    ROUTE_YAML=${COMPONENT_DIR}/route.yaml
    CONFIGMAP_YAML=${COMPONENT_DIR}/configmap.yaml
    DEPLOYMENTCONFIG_YAML=${COMPONENT_DIR}/deploymentconfig.yaml
    DEPLOYMENT_YAML=${COMPONENT_DIR}/deployment.yaml

    ## Secret
    oc get secret -n ${DEV_PROJECT} -lapp.kubernetes.io/instance=${COMPONENT_NAME%-coolstore} -o yaml --ignore-not-found > ${SECRET_YAML}

    if [ -s ${SECRET_YAML} ]
    then
        yq delete --inplace  ${SECRET_YAML} items[*].metadata.namespace
        yq delete --inplace  ${SECRET_YAML} items[*].metadata.uid
        yq delete --inplace  ${SECRET_YAML} items[*].metadata.selfLink
        yq delete --inplace  ${SECRET_YAML} items[*].metadata.creationTimestamp
        yq delete --inplace  ${SECRET_YAML} items[*].metadata.resourceVersion
        yq delete --inplace  ${SECRET_YAML} items[*].metadata.ownerReferences
        yq delete --inplace  ${SECRET_YAML} items[*].metadata.managedFields
    fi

    ## Service
    oc get service -n ${DEV_PROJECT} -lapp.kubernetes.io/instance=${COMPONENT_NAME%-coolstore} -o yaml --ignore-not-found > ${SERVICE_YAML}

    if [ -s ${SERVICE_YAML} ]
    then
        yq delete --inplace  ${SERVICE_YAML} items[*].metadata.namespace
        yq delete --inplace  ${SERVICE_YAML} items[*].metadata.uid
        yq delete --inplace  ${SERVICE_YAML} items[*].metadata.selfLink
        yq delete --inplace  ${SERVICE_YAML} items[*].metadata.creationTimestamp
        yq delete --inplace  ${SERVICE_YAML} items[*].metadata.resourceVersion
        yq delete --inplace  ${SERVICE_YAML} items[*].metadata.ownerReferences
        yq delete --inplace  ${SERVICE_YAML} items[*].metadata.managedFields
        yq delete --inplace  ${SERVICE_YAML} items[*].spec.clusterIP
        yq delete --inplace  ${SERVICE_YAML} items[*].spec.clusterIPs

        # Specific changes for Staging Environment with Istio
        yq delete --inplace  ${SERVICE_YAML} items[*].spec.selector
        yq write --inplace ${SERVICE_YAML} items[*].spec.selector.app ${COMPONENT_NAME%-coolstore}
        yq write --inplace ${SERVICE_YAML} items[*].metadata.labels.app ${COMPONENT_NAME%-coolstore}
        
        sed -i "s/8080-tcp/http/g" ${SERVICE_YAML}
    fi 
    ## Route
    oc get route -n ${DEV_PROJECT} -lapp.kubernetes.io/instance=${COMPONENT_NAME%-coolstore} -o yaml --ignore-not-found > ${ROUTE_YAML}

    if [ -s ${ROUTE_YAML} ]
    then
        yq delete --inplace  ${ROUTE_YAML} items[*].metadata.namespace
        yq delete --inplace  ${ROUTE_YAML} items[*].metadata.uid
        yq delete --inplace  ${ROUTE_YAML} items[*].metadata.selfLink
        yq delete --inplace  ${ROUTE_YAML} items[*].metadata.creationTimestamp
        yq delete --inplace  ${ROUTE_YAML} items[*].metadata.resourceVersion
        yq delete --inplace  ${ROUTE_YAML} items[*].metadata.ownerReferences
        yq delete --inplace  ${ROUTE_YAML} items[*].metadata.managedFields
        yq delete --inplace  ${ROUTE_YAML} items[*].spec.host
        yq delete --inplace  ${ROUTE_YAML} items[*].status.ingress[*].conditions[*].lastTransitionTime
        yq delete --inplace  ${ROUTE_YAML} items[*].status.ingress[*].host
        yq delete --inplace  ${ROUTE_YAML} items[*].status.ingress[*].routerCanonicalHostname
        yq delete --inplace  ${ROUTE_YAML} items[*].status.ingress[*].routerName
        yq delete --inplace  ${ROUTE_YAML} items[*].status.ingress[*].wildcardPolicy
        sed -i "s/${DEV_PROJECT}/${PROJECT}/g" ${ROUTE_YAML}
        sed -i "s/8080-tcp/http/g" ${ROUTE_YAML}
    fi
    ## ConfigMap
    oc get configmap -n ${DEV_PROJECT} -lapp.kubernetes.io/instance=${COMPONENT_NAME%-coolstore} -o yaml --ignore-not-found > ${CONFIGMAP_YAML}

    if [ -s ${CONFIGMAP_YAML} ]
    then
        yq delete --inplace  ${CONFIGMAP_YAML} items[*].metadata.namespace
        yq delete --inplace  ${CONFIGMAP_YAML} items[*].metadata.uid
        yq delete --inplace  ${CONFIGMAP_YAML} items[*].metadata.selfLink
        yq delete --inplace  ${CONFIGMAP_YAML} items[*].metadata.creationTimestamp
        yq delete --inplace  ${CONFIGMAP_YAML} items[*].metadata.resourceVersion
        yq delete --inplace  ${CONFIGMAP_YAML} items[*].metadata.managedFields
    fi

    ## Deployment Config
    oc get deploymentconfig -n ${DEV_PROJECT} -lapp.kubernetes.io/instance=${COMPONENT_NAME%-coolstore} -o yaml --ignore-not-found > ${DEPLOYMENTCONFIG_YAML}

    if [ -s ${DEPLOYMENTCONFIG_YAML} ]
    then
        yq delete --inplace  ${DEPLOYMENTCONFIG_YAML} items[*].metadata.namespace
        yq delete --inplace  ${DEPLOYMENTCONFIG_YAML} items[*].metadata.uid
        yq delete --inplace  ${DEPLOYMENTCONFIG_YAML} items[*].metadata.selfLink
        yq delete --inplace  ${DEPLOYMENTCONFIG_YAML} items[*].metadata.creationTimestamp
        yq delete --inplace  ${DEPLOYMENTCONFIG_YAML} items[*].metadata.resourceVersion
        yq delete --inplace  ${DEPLOYMENTCONFIG_YAML} items[*].metadata.generation
        yq delete --inplace  ${DEPLOYMENTCONFIG_YAML} items[*].metadata.managedFields
        yq delete --inplace  ${DEPLOYMENTCONFIG_YAML} items[*].spec.template.spec.initContainers
        yq delete --inplace  ${DEPLOYMENTCONFIG_YAML} items[*].spec.template.spec.containers[0].command
        yq delete --inplace  ${DEPLOYMENTCONFIG_YAML} items[*].spec.template.spec.containers[0].args
        yq delete --inplace  ${DEPLOYMENTCONFIG_YAML} items[*].spec.template.spec.containers[0].volumeMounts[0]
        yq delete --inplace  ${DEPLOYMENTCONFIG_YAML} items[*].spec.template.spec.containers[0].volumeMounts[0]
        yq delete --inplace  ${DEPLOYMENTCONFIG_YAML} items[*].spec.template.spec.containers[0].volumeMounts[0]
        yq delete --inplace  ${DEPLOYMENTCONFIG_YAML} items[*].spec.template.spec.containers[0].env[0]
        yq delete --inplace  ${DEPLOYMENTCONFIG_YAML} items[*].spec.template.spec.containers[0].env[0]
        yq delete --inplace  ${DEPLOYMENTCONFIG_YAML} items[*].spec.template.spec.containers[0].env[0]
        yq delete --inplace  ${DEPLOYMENTCONFIG_YAML} items[*].spec.template.spec.containers[0].env[0]
        yq delete --inplace  ${DEPLOYMENTCONFIG_YAML} items[*].spec.template.spec.containers[0].env[0]
        yq delete --inplace  ${DEPLOYMENTCONFIG_YAML} items[*].spec.template.spec.containers[0].env[0]
        yq delete --inplace  ${DEPLOYMENTCONFIG_YAML} items[*].spec.template.spec.containers[0].env[0]
        yq delete --inplace  ${DEPLOYMENTCONFIG_YAML} items[*].spec.template.spec.volumes[0]
        yq delete --inplace  ${DEPLOYMENTCONFIG_YAML} items[*].spec.template.spec.volumes[0]
        yq delete --inplace  ${DEPLOYMENTCONFIG_YAML} items[*].status
        yq write --inplace ${DEPLOYMENTCONFIG_YAML} items[*].spec.triggers null

        # Specific changes for Staging Environment with Istio
        yq write --inplace ${DEPLOYMENTCONFIG_YAML} items[*].metadata.labels.app ${COMPONENT_NAME%-coolstore}
        yq write --inplace ${DEPLOYMENTCONFIG_YAML} items[*].spec.selector.app ${COMPONENT_NAME%-coolstore}
        yq write --inplace ${DEPLOYMENTCONFIG_YAML} items[*].spec.template.metadata.labels.app ${COMPONENT_NAME%-coolstore}
        yq write --inplace ${DEPLOYMENTCONFIG_YAML} items[*].spec.template.metadata.labels.[app.kubernetes.io/instance] ${COMPONENT_NAME%-coolstore}
        yq write --inplace ${DEPLOYMENTCONFIG_YAML} items[*].spec.template.metadata.labels.[maistra.io/expose-route] '"true"'

        sed -i "s/  envFrom:/- envFrom:/g"  ${DEPLOYMENTCONFIG_YAML}
        grep '\- envFrom:' ${DEPLOYMENTCONFIG_YAML} &> /dev/null || sed -i "s/  image:/- image:/g"  ${DEPLOYMENTCONFIG_YAML}
        sed -i "/^.*: \[\]$/d"  ${DEPLOYMENTCONFIG_YAML}
        sed -i "s/triggers: .*/triggers: []/g"  ${DEPLOYMENTCONFIG_YAML}
        sed -i "s/image: .*$/image: image-registry.openshift-image-registry.svc:5000\/${PROJECT}\/${COMPONENT_NAME}:latest/g" ${DEPLOYMENTCONFIG_YAML}
        sed -i "s/8080-tcp/http/g" ${DEPLOYMENTCONFIG_YAML}
    fi

    ## Deployment
    oc get deployment -n ${DEV_PROJECT} -lapp.kubernetes.io/instance=${COMPONENT_NAME%-coolstore} -o yaml --ignore-not-found > ${DEPLOYMENT_YAML}

    if [ -s ${DEPLOYMENT_YAML} ]
    then
        yq delete --inplace  ${DEPLOYMENT_YAML} items[*].metadata.namespace
        yq delete --inplace  ${DEPLOYMENT_YAML} items[*].metadata.uid
        yq delete --inplace  ${DEPLOYMENT_YAML} items[*].metadata.selfLink
        yq delete --inplace  ${DEPLOYMENT_YAML} items[*].metadata.creationTimestamp
        yq delete --inplace  ${DEPLOYMENT_YAML} items[*].metadata.resourceVersion
        yq delete --inplace  ${DEPLOYMENT_YAML} items[*].metadata.generation
        yq delete --inplace  ${DEPLOYMENT_YAML} items[*].metadata.managedFields
        yq delete --inplace  ${DEPLOYMENT_YAML} items[*].metadata.annotations.[deployment.kubernetes.io/revision]
        yq delete --inplace  ${DEPLOYMENT_YAML} items[*].metadata.annotations.[image.openshift.io/triggers]
        yq delete --inplace  ${DEPLOYMENT_YAML} items[*].spec.template.spec.initContainers
        yq delete --inplace  ${DEPLOYMENT_YAML} items[*].spec.template.spec.containers[0].command
        yq delete --inplace  ${DEPLOYMENT_YAML} items[*].spec.template.spec.containers[0].args
        yq delete --inplace  ${DEPLOYMENT_YAML} items[*].spec.template.spec.containers[0].volumeMounts[0]
        yq delete --inplace  ${DEPLOYMENT_YAML} items[*].spec.template.spec.containers[0].volumeMounts[0]
        yq delete --inplace  ${DEPLOYMENT_YAML} items[*].spec.template.spec.containers[0].volumeMounts[0]
        yq delete --inplace  ${DEPLOYMENT_YAML} items[*].spec.template.spec.containers[0].env[0]
        yq delete --inplace  ${DEPLOYMENT_YAML} items[*].spec.template.spec.containers[0].env[0]
        yq delete --inplace  ${DEPLOYMENT_YAML} items[*].spec.template.spec.containers[0].env[0]
        yq delete --inplace  ${DEPLOYMENT_YAML} items[*].spec.template.spec.containers[0].env[0]
        yq delete --inplace  ${DEPLOYMENT_YAML} items[*].spec.template.spec.containers[0].env[0]
        yq delete --inplace  ${DEPLOYMENT_YAML} items[*].spec.template.spec.containers[0].env[0]
        yq delete --inplace  ${DEPLOYMENT_YAML} items[*].spec.template.spec.containers[0].env[0]
        yq delete --inplace  ${DEPLOYMENT_YAML} items[*].spec.template.spec.volumes[0]
        yq delete --inplace  ${DEPLOYMENT_YAML} items[*].spec.template.spec.volumes[0]
        yq delete --inplace  ${DEPLOYMENT_YAML} items[*].status

        # Specific changes for Staging Environment with Istio
        yq write --inplace ${DEPLOYMENT_YAML} items[*].metadata.labels.app ${COMPONENT_NAME%-coolstore}
        yq write --inplace ${DEPLOYMENT_YAML} items[*].spec.selector.matchLabels.app ${COMPONENT_NAME%-coolstore}
        yq write --inplace ${DEPLOYMENT_YAML} items[*].spec.template.metadata.labels.app ${COMPONENT_NAME%-coolstore}
        yq write --inplace ${DEPLOYMENT_YAML} items[*].spec.template.metadata.labels.[app.kubernetes.io/instance] ${COMPONENT_NAME%-coolstore}
        yq write --inplace ${DEPLOYMENT_YAML} items[*].spec.template.metadata.labels.[maistra.io/expose-route] '"true"'

        sed -i "s/  envFrom:/- envFrom:/g"  ${DEPLOYMENT_YAML}
        grep '\- envFrom:' ${DEPLOYMENT_YAML} &> /dev/null || sed -i "s/  image:/- image:/g"  ${DEPLOYMENT_YAML}
        sed -i "/^.*: \[\]$/d"  ${DEPLOYMENT_YAML}
        sed -i "s/image: .*$/image: image-registry.openshift-image-registry.svc:5000\/${PROJECT}\/${COMPONENT_NAME}:latest/g" ${DEPLOYMENT_YAML}
        sed -i "s/8080-tcp/http/g" ${DEPLOYMENT_YAML}
    fi
done

# Specific to WebNodejs
WEB_COMPONENT_DIR=${GITOPS_DIR}/web-coolstore
oc patch -n ${DEV_PROJECT} -f ${WEB_COMPONENT_DIR}/deployment.yaml \
    -p '{"spec": {"template" : {"spec":  {"containers":[{"name":"web-coolstore", "env" : [{"name": "OPENSHIFT_BUILD_NAMESPACE", "valueFrom": {"fieldRef": {"fieldPath": "metadata.namespace"}}}]}]}}}}' \
    --local -o yaml > ${WEB_COMPONENT_DIR}/deployment.yaml.tmp \
    && mv ${WEB_COMPONENT_DIR}/deployment.yaml.tmp ${WEB_COMPONENT_DIR}/deployment.yaml


echo "--- Kubernetes resources has been exported! ---"