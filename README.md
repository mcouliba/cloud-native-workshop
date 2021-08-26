# Cloud Native Workshop

## Overview

This one day hands-on cloud-native workshops provides developers and introduction to cloud-natives applications
and gives them an experience of building cloud-native applications using OpenShift, CodeReady Workspaces, Spring Boot,
Quarkus, Vert.x and more.

## Agenda

* Introduction
* Get your Developer Workspace
* Create Inventory Service as an Enterprise Microservice with Quarkus
* Create Catalog Service as a Microservice with Spring Boot
* Create Gateway Service as a Reactive Microservice with Eclipse Vert.x
* Deploy Web UI as a Microservice with with Node.js and AngularJS
* Monitor Application Health
* Service Resilience and Fault Tolerance
* Externalize Application Configuration
* GitOps Continuous Delivery with Argo CD
* Continuous Delivery with Openshift Pipelines
* Microservice Tracing with Service Mesh

## Deploy the Workshop on RHPDS

An [Operator](https://docs.openshift.com/container-platform/4.2/operators/olm-what-operators-are.html)
is provided for deploying the workshop infrastructure (lab instructions, Nexus, Gitea, Eclipse Che, etc)
on OpenShift.

Please follow the instructions from [OpenShift Workshop Operator](https://github.com/mcouliba/openshift-workshop-operator/tree/3.0)
and deploy the following **Workshop** custom resource [cloud_native_workshop_cr.yaml](https://github.com/mcouliba/openshift-workshop-operator/blob/3.0/deploy/crds/cloud_native_workshop_cr.yaml)

## Run locally the lab instructions

In order to run the guide locally, please follow the instructions below:

```
$ git clone
$ cd cloud-native-workshop/guide
$ docker run -it --rm -p 8080:8080 \
      -v $(pwd):/app-data \
      -e LOG_TO_STDOUT=true \
      -e CONTENT_URL_PREFIX="file:///app-data" \
      -e WORKSHOPS_URLS="file:///app-data/_workshop.yml" \
      quay.io/osevg/workshopper:latest
```
