##########################
# gateway-vertx Solution #
##########################

DIRECTORY=`dirname $0`

$DIRECTORY/solve.sh

cd /projects/workshop/labs/gateway-vertx
mvn clean package -DskipTests

odo delete --all --force
odo project set my-project${CHE_WORKSPACE_NAMESPACE#user}

odo create java:11 gateway --context /projects/workshop/labs/gateway-vertx/ --binary target/gateway-1.0-SNAPSHOT.jar --app coolstore
odo push

odo url create gateway --port 8080
odo push

odo link inventory --component gateway --port 8080
odo link catalog --component gateway --port 8080

oc annotate --overwrite dc/gateway-coolstore app.openshift.io/connects-to='catalog,inventory'
oc label dc gateway-coolstore app.openshift.io/runtime=vertx --overwrite

echo "Gateway Vertx Deployed"