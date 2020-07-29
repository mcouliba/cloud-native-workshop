##########################
# Health Probes Solution #
##########################

DIRECTORY=`dirname $0`

oc project my-project${CHE_WORKSPACE_NAMESPACE#user}
oc policy add-role-to-user view -z default

oc set probe dc/catalog-coolstore  --liveness --readiness --initial-delay-seconds=30 --failure-threshold=3 --get-url=http://:8080/actuator/health

cp $DIRECTORY/pom.xml $DIRECTORY/../../inventory-quarkus
cd /projects/workshop/labs/inventory-quarkus
mvn clean package -DskipTests
odo push
oc label dc inventory-coolstore app.openshift.io/runtime=quarkus --overwrite

oc rollout pause dc/inventory-coolstore
oc set probe dc/inventory-coolstore --readiness --initial-delay-seconds=10 --failure-threshold=3 --get-url=http://:8080/health/ready
oc set probe dc/inventory-coolstore --liveness --initial-delay-seconds=180 --failure-threshold=3 --get-url=http://:8080/health/live
oc rollout resume dc/inventory-coolstore

oc set probe dc/gateway-coolstore  --liveness --readiness --initial-delay-seconds=30 --failure-threshold=3 --get-url=http://:8080/health

oc rollout pause dc/web-coolstore
oc set probe dc/web-coolstore --readiness --initial-delay-seconds=10 --timeout-seconds=1 --get-url=http://:8080/
oc set probe dc/web-coolstore --liveness --initial-delay-seconds=180 --timeout-seconds=1 --get-url=http://:8080/
oc rollout resume dc/web-coolstore

echo "Health Probes Done"