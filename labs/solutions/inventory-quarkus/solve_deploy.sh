##########################
# gateway-vertx Solution #
##########################

DIRECTORY=`dirname $0`

$DIRECTORY/solve.sh

cd /projects/workshop/labs/inventory-quarkus
mvn clean package -DskipTests

odo create java:11 inventory --context /projects/workshop/labs/inventory-quarkus/ --binary target/inventory-quarkus-1.0.0-SNAPSHOT-runner.jar --app coolstore
odo push
odo url create inventory --port 8080
odo push