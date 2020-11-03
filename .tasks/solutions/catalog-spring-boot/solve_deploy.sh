################################
# catalog-spring-boot Solution #
################################

DIRECTORY=`dirname $0`

$DIRECTORY/solve.sh

cd $DIRECTORY/../../../labs/catalog-spring-boot
mvn clean package -DskipTests

odo delete --all --force
odo project set my-project${CHE_WORKSPACE_NAMESPACE#user}
odo create java:11 catalog --context $DIRECTORY/../../../labs/catalog-spring-boot --binary target/catalog-1.0-SNAPSHOT.jar --s2i --app coolstore
odo push
odo url create catalog --port 8080
odo push

oc label dc catalog-coolstore app.openshift.io/runtime=spring --overwrite

echo "Catalog Spring-Boot Deployed"