#!/bin/bash

url=http://istio-ingressgateway.istio-system.svc/cn-project${CHE_WORKSPACE_NAMESPACE#user}/api/products

while true; do 
    if curl -s ${url} | grep -q OFFICIAL
    then
        echo -e "\e[96mGateway => Catalog GoLang (v2)\e[0m";
    else
        echo -e "\e[92mGateway => Catalog Spring Boot (v1)\e[0m";
    fi
    sleep 1
done