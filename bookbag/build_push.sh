#!/bin/bash

FORMAT="both"
IMAGE_URL="quay.io/mcouliba/cloud-native-workshop-bookbag"
USAGE="
Usage: ./buildImage.sh [OPTIONS]
Options:
    --help
        Print this message.
    --tag, -t [TAG]
        Container image tag to be used for image
    --format [inner|outer|both]
        Format of workshop; default: 'both'
"

function print_usage() {
    echo -e "$USAGE"
}

function parse_arguments() {
    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
            -t|--tag)
            TAG="$2"
            shift; shift;
            ;;
            --format)
            FORMAT="$2"
            shift; shift;
            ;;
            *)
            print_usage
            exit 0
        esac
    done
}

function build_push() {
    TAG_IMAGE=${TAG}_${1}_loop
    echo "Build and Push ${IMAGE_URL}:${TAG_IMAGE}"
    cp ./workshop/workshop_${1}_loop.yaml ./workshop/workshop.yaml 
    docker build -t ${IMAGE_URL}:${TAG_IMAGE} .
    cp ./workshop/workshop_full.yaml ./workshop/workshop.yaml 
    docker push ${IMAGE_URL}:${TAG_IMAGE}
}

parse_arguments "$@"

if [ -z "${TAG}" ]
then
    print_usage
    exit 1
fi

case ${FORMAT} in
    inner)
        build_push "inner"
        ;;
    outer)
        build_push "outer"
        ;;
    both)
        build_push "inner"
        build_push "outer"
        ;;
    *)
        print_usage
        exit 1
        ;;
esac