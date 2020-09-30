##############################
# inventory-quarkus Solution #
##############################

DIRECTORY=`dirname $0`

$DIRECTORY/solve.sh

cd /projects/workshop/labs/inventory-quarkus
mvn clean package -DskipTests

odo delete --all --force
odo project set my-project${CHE_WORKSPACE_NAMESPACE#user}
odo create java:11 inventory --context /projects/workshop/labs/inventory-quarkus/ --binary target/inventory-quarkus-1.0.0-SNAPSHOT-runner.jar --app coolstore
odo push
odo url create inventory --port 8080
odo push

oc label dc inventory-coolstore app.openshift.io/runtime=quarkus --overwrite

echo "Inventory Quarkus Deployed"