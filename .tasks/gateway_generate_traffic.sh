#!/bin/bash

url=http://istio-ingressgateway.istio-system.svc/cn-project${CHE_WORKSPACE_NAMESPACE#user}/api/products

while true; do 
    if curl -s ${url} | grep -q OFFICIAL
    then
        echo "Gateway => Catalog GoLang (v2)";
    else
        echo "Gateway => Catalog Spring Boot (v1)";
    fi
    sleep 1
done