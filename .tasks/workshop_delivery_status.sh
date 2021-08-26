#!/bin/bash

echo "--- Current Progress of the Inner Loop Part at $(date) ---"                                                                                                               ─╯
echo $(oc get project | grep 'my-project'  | wc -l) projects created
echo $(oc get pods -l deploymentconfig=inventory-coolstore --all-namespaces 2> /dev/null | grep -i my-project | grep -i running | wc -l) Inventory Service deployed
echo $(oc get pods -l deploymentconfig=catalog-coolstore --all-namespaces 2> /dev/null | grep -i my-project | grep -i running | wc -l) Catalog Service deployed
echo $(oc get pods -l deploymentconfig=gateway-coolstore --all-namespaces 2> /dev/null | grep -i my-project | grep -i running | wc -l) Gateway Service deployed
echo $(($(oc get pods -l deploymentconfig=web-coolstore --all-namespaces 2> /dev/null | grep -i my-project | grep -i running | wc -l)+$(oc get pods -l deployment=web-coolstore --all-namespaces 2> /dev/null | grep -i running | wc -l))) Web Service deployed
echo "------------------------"
echo
echo "--- Current Progress of the Outer Loop Part at $(date) ---"
echo "--- Get your developer environment"
echo "  $(oc get pods -l deploymentconfig=inventory-coolstore --all-namespaces 2> /dev/null | grep ".*my-project.*" | grep -i running | wc -l) Inventory Service(s)"
echo "  $(oc get pods -l deploymentconfig=catalog-coolstore --all-namespaces 2> /dev/null | grep ".*my-project.*" | grep -i running | wc -l) Catalog Service(s)"
echo "  $(oc get pods -l deploymentconfig=gateway-coolstore --all-namespaces 2> /dev/null | grep ".*my-project.*" | grep -i running | wc -l) Gateway Service(s)"
echo "  $(($(oc get pods -l deploymentconfig=web-coolstore --all-namespaces 2> /dev/null | grep '.*my-project.*' | grep -i running | wc -l)+$(oc get pods -l deployment=web-coolstore --all-namespaces 2> /dev/null | grep '.*my-project.*' | grep -i running | wc -l))) Web Service deployed(s)"
echo
echo "--- Set up Continuous Integration"
echo "  $(oc get imagestream --all-namespaces | grep "cn-project.*inventory-coolstore" | wc -l) Inventory ImageStream(s)"
echo "  $(oc get pvc --all-namespaces | grep "cn-project.*inventory-pipeline-pvc.*" | wc -l) Inventory Tekton Workspace(s)"
echo "  $(oc get pipelines --all-namespaces | grep "inventory-pipeline" | wc -l) Inventory Pipeline(s)"
echo
echo "--- Apply GitOps Workflow"
echo "  $(oc get application --all-namespaces | grep inventory | wc -l) Inventory Application(s)"
echo "  $(oc get application --all-namespaces | grep catalog | wc -l) Catalog Application(s)"
echo "  $(oc get application --all-namespaces | grep gateway | wc -l) Gateway Application(s)"
echo "  $(oc get application --all-namespaces | grep web | wc -l) Web Application(s)"
echo
echo "--- Set up Continuous Deployment"
echo "  $(oc get tasks --all-namespaces | grep "argocd-task-sync-and-wait" | wc -l) ArgoCD Task(s)"
echo "  $(oc get configmap --all-namespaces | grep "argocd-env-configmap" | wc -l) ArgoCD ConfigMap(s)"
echo "  $(oc get secret --all-namespaces | grep "argocd-env-secret" | wc -l) ArgoCD Secret(s)"
echo "  $(oc get pipelines --all-namespaces | grep "coolstore-java-pipeline" | wc -l) Java Pipeline(s)"
echo "  $(oc get pipelines --all-namespaces | grep "coolstore-nodejs-pipeline" | wc -l) NodeJS Pipeline (s)"
echo
echo "--- Connect and Monitor your Application"
echo "        $(($(oc get pods -l deployment=catalog-coolstore-v2 --all-namespaces 2> /dev/null | grep -i running | wc -l)+$(oc get pods -l deploymentconfig=catalog-coolstore-v2 --all-namespaces 2> /dev/null | grep -i running | wc -l))) Catalog v2 Service(s)"
echo "------------------------"