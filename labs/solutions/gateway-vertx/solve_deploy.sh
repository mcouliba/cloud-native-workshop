##########################
# gateway-vertx Solution #
##########################

DIRECTORY=`dirname $0`

$DIRECTORY/solve.sh

cd /projects/workshop/labs/gateway-vertx
mvn clean package -DskipTests

odo create java:11 gateway --context /projects/workshop/labs/gateway-vertx/ --binary target/gateway-1.0-SNAPSHOT.jar --app coolstore
odo push

odo url create gateway --port 8080
odo push

odo link inventory --component gateway --port 8080
odo link catalog --component gateway --port 8080