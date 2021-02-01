#!/bin/bash

echo "--- Current Progress of the Inner Loop Part ---"                                                                                                               ─╯
echo $(oc get project | grep 'my-project'  | wc -l) projects created
echo $(oc get pods -l deploymentconfig=inventory-coolstore --all-namespaces 2> /dev/null | grep -i running | wc -l) Inventory Service deployed
echo $(oc get pods -l deploymentconfig=catalog-coolstore --all-namespaces 2> /dev/null | grep -i running | wc -l) Catalog Service deployed
echo $(oc get pods -l deploymentconfig=gateway-coolstore --all-namespaces 2> /dev/null | grep -i running | wc -l) Gateway Service deployed
echo $(($(oc get pods -l deploymentconfig=web-coolstore --all-namespaces 2> /dev/null | grep -i running | wc -l)+$(oc get pods -l deployment=web-coolstore --all-namespaces 2> /dev/null | grep -i running | wc -l))) Web Service deployed
echo "------------------------"

echo "--- Current Progress of the Outer Loop Part ---"
echo $(oc get pods -l deploymentconfig=inventory-coolstore --all-namespaces 2> /dev/null | grep -i running | wc -l) Inventory Service deployed
echo $(oc get pods -l deploymentconfig=catalog-coolstore --all-namespaces 2> /dev/null | grep -i running | wc -l) Catalog Service deployed
echo $(oc get pods -l deploymentconfig=gateway-coolstore --all-namespaces 2> /dev/null | grep -i running | wc -l) Gateway Service deployed
echo $(($(oc get pods -l deploymentconfig=web-coolstore --all-namespaces 2> /dev/null | grep -i running | wc -l)+$(oc get pods -l deployment=web-coolstore --all-namespaces 2> /dev/null | grep -i running | wc -l))) Web Service deployed                                                                                                        ─╯
echo $(oc get imagestream --all-namespaces | grep "cn-project.*inventory-coolstore" | wc -l) Inventory ImageStream Created
echo $(oc get pvc --all-namespaces | grep "cn-project.*inventory-pipeline-pvc.*" | wc -l) Inventory Tekton Workspace Created
echo $(oc get pipelines --all-namespaces | grep "inventory-pipeline" | wc -l) Inventory Pipeline Created
echo $(oc get tasks --all-namespaces | grep "argocd-task-sync-and-wait" | wc -l) ArgoCD Task Created
echo $(oc get configmap --all-namespaces | grep "argocd-env-configmap" | wc -l) ArgoCD ComfigMap Created
echo $(oc get secret --all-namespaces | grep "argocd-env-secret" | wc -l) ArgoCD Secret Created
echo $(oc get pipelines --all-namespaces | grep "coolstore-java-pipeline" | wc -l) Java Pipeline Created
echo $(oc get pipelines --all-namespaces | grep "coolstore-nodejs-pipeline" | wc -l) NodeJS Pipeline Created
echo "------------------------"