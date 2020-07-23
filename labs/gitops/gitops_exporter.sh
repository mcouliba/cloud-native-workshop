#!/bin/bash

DIRECTORY=`dirname $0`
DEV_PROJECT=$1
PROJECT=$2

declare -a COMPONENTS=("inventory-coolstore" "catalog-coolstore" "gateway-coolstore" "web-coolstore")

echo "--- Export Kubernetes resources for GitOps from ${DEV_PROJECT} to ${PROJECT} ---"

for COMPONENT_NAME in "${COMPONENTS[@]}"
do
    echo "Exporting resources for ${COMPONENT_NAME}..."

    SECRET_YAML=${DIRECTORY}/${COMPONENT_NAME}-secret.yaml
    SERVICE_YAML=${DIRECTORY}/${COMPONENT_NAME}-service.yaml
    ROUTE_YAML=${DIRECTORY}/${COMPONENT_NAME}-route.yaml
    CONFIGMAP_YAML=${DIRECTORY}/${COMPONENT_NAME}-configmap.yaml
    IMAGESTREAM_YAML=${DIRECTORY}/${COMPONENT_NAME}-imagestream.yaml
    BUILDCONFIG_YAML=${DIRECTORY}/${COMPONENT_NAME}-buildconfig.yaml
    DEPLOYMENTCONFIG_YAML=${DIRECTORY}/${COMPONENT_NAME}-deploymentconfig.yaml

    ## Secret
    oc get secret -n ${DEV_PROJECT} -lapp.kubernetes.io/instance=${COMPONENT_NAME%-coolstore} -o yaml > ${SECRET_YAML}

    yq delete --inplace  ${SECRET_YAML} items[*].metadata.namespace
    yq delete --inplace  ${SECRET_YAML} items[*].metadata.uid
    yq delete --inplace  ${SECRET_YAML} items[*].metadata.selfLink
    yq delete --inplace  ${SECRET_YAML} items[*].metadata.creationTimestamp
    yq delete --inplace  ${SECRET_YAML} items[*].metadata.resourceVersion
    yq delete --inplace  ${SECRET_YAML} items[*].metadata.ownerReferences

    ## Service
    oc get service -n ${DEV_PROJECT} -lapp.kubernetes.io/instance=${COMPONENT_NAME%-coolstore} -o yaml > ${SERVICE_YAML}

    yq delete --inplace  ${SERVICE_YAML} items[*].metadata.namespace
    yq delete --inplace  ${SERVICE_YAML} items[*].metadata.uid
    yq delete --inplace  ${SERVICE_YAML} items[*].metadata.selfLink
    yq delete --inplace  ${SERVICE_YAML} items[*].metadata.creationTimestamp
    yq delete --inplace  ${SERVICE_YAML} items[*].metadata.resourceVersion
    yq delete --inplace  ${SERVICE_YAML} items[*].spec.clusterIP
    yq delete --inplace  ${SERVICE_YAML} items[*].metadata.ownerReferences

    # Specific changes for Staging Environment with Istio
    yq delete --inplace  ${SERVICE_YAML} items[*].spec.selector
    yq write --inplace ${SERVICE_YAML} items[*].spec.selector.app ${COMPONENT_NAME%-coolstore}
    yq write --inplace ${SERVICE_YAML} items[*].metadata.labels.app ${COMPONENT_NAME%-coolstore}
    
    sed -i "s/8080-tcp/http/g" ${SERVICE_YAML}

    ## Route
    oc get route -n ${DEV_PROJECT} -lapp.kubernetes.io/instance=${COMPONENT_NAME%-coolstore} -o yaml > ${ROUTE_YAML}

    yq delete --inplace  ${ROUTE_YAML} items[*].metadata.namespace
    yq delete --inplace  ${ROUTE_YAML} items[*].metadata.uid
    yq delete --inplace  ${ROUTE_YAML} items[*].metadata.selfLink
    yq delete --inplace  ${ROUTE_YAML} items[*].metadata.creationTimestamp
    yq delete --inplace  ${ROUTE_YAML} items[*].metadata.resourceVersion
    yq delete --inplace  ${ROUTE_YAML} items[*].metadata.ownerReferences
    yq delete --inplace  ${ROUTE_YAML} items[*].status.ingress[*].conditions[*].lastTransitionTime
    yq delete --inplace  ${ROUTE_YAML} items[*].status.ingress[*].host
    yq delete --inplace  ${ROUTE_YAML} items[*].status.ingress[*].routerCanonicalHostname
    yq delete --inplace  ${ROUTE_YAML} items[*].status.ingress[*].routerName
    yq delete --inplace  ${ROUTE_YAML} items[*].status.ingress[*].wildcardPolicy
    sed -i "s/${DEV_PROJECT}/${PROJECT}/g" ${ROUTE_YAML}
    sed -i "s/8080-tcp/http/g" ${ROUTE_YAML}

    ## ConfigMap
    oc get configmap -n ${DEV_PROJECT} -lapp.kubernetes.io/instance=${COMPONENT_NAME%-coolstore} -o yaml > ${CONFIGMAP_YAML}

    yq delete --inplace  ${CONFIGMAP_YAML} items[*].metadata.namespace
    yq delete --inplace  ${CONFIGMAP_YAML} items[*].metadata.uid
    yq delete --inplace  ${CONFIGMAP_YAML} items[*].metadata.selfLink
    yq delete --inplace  ${CONFIGMAP_YAML} items[*].metadata.creationTimestamp
    yq delete --inplace  ${CONFIGMAP_YAML} items[*].metadata.resourceVersion

    ## Imagestream
    oc get imagestream -n ${DEV_PROJECT} -lapp.kubernetes.io/instance=${COMPONENT_NAME%-coolstore} -o yaml > ${IMAGESTREAM_YAML}

    yq delete --inplace  ${IMAGESTREAM_YAML} items[*].metadata.namespace
    yq delete --inplace  ${IMAGESTREAM_YAML} items[*].metadata.uid
    yq delete --inplace  ${IMAGESTREAM_YAML} items[*].metadata.selfLink
    yq delete --inplace  ${IMAGESTREAM_YAML} items[*].metadata.creationTimestamp
    yq delete --inplace  ${IMAGESTREAM_YAML} items[*].metadata.resourceVersion
    yq delete --inplace  ${IMAGESTREAM_YAML} items[*].metadata.generation
    yq delete --inplace  ${IMAGESTREAM_YAML} items[*].status.tags
    sed -i "s/${DEV_PROJECT}/${PROJECT}/g" ${IMAGESTREAM_YAML}

    ## Build Config
    oc get buildconfig -n ${DEV_PROJECT} -lapp.kubernetes.io/instance=${COMPONENT_NAME%-coolstore} -o yaml > ${BUILDCONFIG_YAML}

    yq delete --inplace  ${BUILDCONFIG_YAML} items[*].metadata.namespace
    yq delete --inplace  ${BUILDCONFIG_YAML} items[*].metadata.uid
    yq delete --inplace  ${BUILDCONFIG_YAML} items[*].metadata.selfLink
    yq delete --inplace  ${BUILDCONFIG_YAML} items[*].metadata.creationTimestamp
    yq delete --inplace  ${BUILDCONFIG_YAML} items[*].metadata.resourceVersion
    yq delete --inplace  ${BUILDCONFIG_YAML} items[*].status
    
    sed -i "s/nodeSelector: .*/nodeSelector: {}/g" ${BUILDCONFIG_YAML}
    sed -i "s/${DEV_PROJECT}/${PROJECT}/g" ${BUILDCONFIG_YAML}

    ## Deployment Config
    oc get deploymentconfig -n ${DEV_PROJECT} -lapp.kubernetes.io/instance=${COMPONENT_NAME%-coolstore} -o yaml > ${DEPLOYMENTCONFIG_YAML}

    yq delete --inplace  ${DEPLOYMENTCONFIG_YAML} items[*].metadata.namespace
    yq delete --inplace  ${DEPLOYMENTCONFIG_YAML} items[*].metadata.uid
    yq delete --inplace  ${DEPLOYMENTCONFIG_YAML} items[*].metadata.selfLink
    yq delete --inplace  ${DEPLOYMENTCONFIG_YAML} items[*].metadata.creationTimestamp
    yq delete --inplace  ${DEPLOYMENTCONFIG_YAML} items[*].metadata.resourceVersion
    yq delete --inplace  ${DEPLOYMENTCONFIG_YAML} items[*].metadata.generation
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
done

echo "--- Kubernetes resources has been exported! ---"