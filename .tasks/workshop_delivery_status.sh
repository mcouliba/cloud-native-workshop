#!/bin/bash

echo "--- Current Progress ---"                                                                                                               ─╯
echo $(oc get project | grep 'my-project'  | wc -l) projects created
echo $(oc get pods -l deploymentconfig=inventory-coolstore --all-namespaces | grep -i running | wc -l) Inventory Service deployed
echo $(oc get pods -l deploymentconfig=catalog-coolstore --all-namespaces | grep -i running | wc -l) Catalog Service deployed
echo $(oc get pods -l deploymentconfig=gateway-coolstore --all-namespaces | grep -i running | wc -l) Gateway Service deployed
echo $(oc get pods -l deploymentconfig=web-coolstore --all-namespaces | grep -i running | wc -l) Web Service deployed
echo "------------------------"