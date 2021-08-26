##############################
# inventory-quarkus Solution #
##############################

DIRECTORY=`dirname $0`
CONTEXT_FOLDER=/projects/workshop/labs/inventory-quarkus
PROJECT_NAME=$1

$DIRECTORY/solve.sh

cd ${CONTEXT_FOLDER}
mvn clean package -DskipTests

odo delete --all --force
odo project set ${PROJECT_NAME}
odo create java:11 inventory --context ${CONTEXT_FOLDER} --binary target/inventory-quarkus-1.0.0-SNAPSHOT-runner.jar --s2i --app coolstore
odo url create inventory --port 8080
odo push

oc label dc inventory-coolstore app.openshift.io/runtime=quarkus --overwrite

echo "Inventory Quarkus Deployed"