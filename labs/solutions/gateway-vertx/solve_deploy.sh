##########################
# gateway-vertx Solution #
##########################

DIRECTORY=`dirname $0`

$DIRECTORY/solve.sh
mvn clean fabric8:deploy -f $DIRECTORY/../../gateway-vertx
oc label bc/gateway-s2i app.kubernetes.io/instance=gateway
oc annotate dc/gateway "app.openshift.io/connects-to"="inventory,catalog"