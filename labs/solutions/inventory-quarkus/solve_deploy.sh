##########################
# gateway-vertx Solution #
##########################

DIRECTORY=`dirname $0`

$DIRECTORY/solve.sh
mvn clean package -DskipTests
oc new-build --name=inventory java --binary=true --labels=app.kubernetes.io/instance=inventory
oc start-build inventory --from-file=target/inventory-quarkus-1.0.0-SNAPSHOT-runner.jar --follow
oc new-app inventory
oc label dc/inventory app.kubernetes.io/part-of=coolstore app.kubernetes.io/name=java app.kubernetes.io/instance=inventory
oc expose svc inventory