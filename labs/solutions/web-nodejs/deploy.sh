##########################
# web-nodejs Solution #
##########################

DIRECTORY=`dirname $0`

oc project my-project${CHE_WORKSPACE_NAMESPACE#user}
oc new-app nodejs~https://github.com/mcouliba/cloud-native-workshop#3.0 \
        --context-dir=labs/web-nodejs \
        --name=web-coolstore \
        --labels=app=coolstore,app.kubernetes.io/instance=web,app.kubernetes.io/part-of=coolstore,app.kubernetes.io/name=nodejs

oc expose svc/web-coolstore
oc annotate --overwrite dc/web-coolstore app.kubernetes.io/component-source-type=git
oc annotate --overwrite dc/web-coolstore app.openshift.io/connects-to=gateway