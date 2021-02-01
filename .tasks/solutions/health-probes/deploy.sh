##########################
# Health Probes Solution #
##########################

DIRECTORY=`dirname $0`
PROJECT_NAME=$1

oc project ${PROJECT_NAME}
oc policy add-role-to-user view -z default

oc set probe dc/catalog-coolstore  --liveness --readiness --initial-delay-seconds=30 --failure-threshold=3 --get-url=http://:8080/actuator/health

echo "Catalog Service Health Probes Done"

cp $DIRECTORY/pom.xml $DIRECTORY/../../../labs/inventory-quarkus
cd $DIRECTORY/../../../labs/inventory-quarkus
mvn clean package -DskipTests

odo push
oc label dc inventory-coolstore app.openshift.io/runtime=quarkus --overwrite

oc rollout pause dc/inventory-coolstore
oc set probe dc/inventory-coolstore --readiness --initial-delay-seconds=10 --failure-threshold=3 --get-url=http://:8080/health/ready
oc set probe dc/inventory-coolstore --liveness --initial-delay-seconds=180 --failure-threshold=3 --get-url=http://:8080/health/live
oc rollout resume dc/inventory-coolstore

echo "Inventory Service Health Probes Done"

oc set probe dc/gateway-coolstore  --liveness --readiness --period-seconds=5 --get-url=http://:8080/health

echo "Gateway Service Health Probes Done"

oc set probe deployment/web-coolstore --readiness --liveness --period-seconds=5 --get-url=http://:8080/

echo "Web Service Health Probes Done"