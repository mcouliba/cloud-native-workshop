##########################
# web-nodejs Solution #
##########################

DIRECTORY=`dirname $0`

oc new-app nodejs~https://github.com/mcouliba/cloud-native-workshop#3.0 \
        --context-dir=labs/web-nodejs \
        --name=web-coolstore \
        --labels=app=coolstore,app.kubernetes.io/instance=web

oc expose svc/web-coolstore 