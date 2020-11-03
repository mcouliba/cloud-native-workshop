##########################
# gateway-vertx Solution #
##########################

DIRECTORY=`dirname $0`
CONTEXT_FOLDER=/projects/workshop/labs/gateway-vertx
$DIRECTORY/solve.sh

cd ${CONTEXT_FOLDER}
mvn clean package -DskipTests

odo delete --all --force
odo project set my-project${CHE_WORKSPACE_NAMESPACE#user}
odo create java:11 gateway --context ${CONTEXT_FOLDER} --binary target/gateway-1.0-SNAPSHOT.jar --s2i --app coolstore
odo push 
odo url create gateway --port 8080
odo push
odo link inventory --component gateway --port 8080
odo link catalog --component gateway --port 8080

oc annotate --overwrite dc/gateway-coolstore app.openshift.io/connects-to='catalog,inventory'
oc label dc gateway-coolstore app.openshift.io/runtime=vertx --overwrite

echo "Gateway Vertx Deployed"