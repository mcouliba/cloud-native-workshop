################################
# catalog-spring-boot Solution #
################################

DIRECTORY=`dirname $0`
CONTEXT_FOLDER=/projects/workshop/labs/catalog-spring-boot
PROJECT_NAME=$1

$DIRECTORY/solve.sh

cd ${CONTEXT_FOLDER}
mvn clean package -DskipTests

odo delete --all --force
odo project set ${PROJECT_NAME}
odo create java:11 catalog --context ${CONTEXT_FOLDER} --binary target/catalog-1.0-SNAPSHOT.jar --s2i --app coolstore
odo url create catalog --port 8080
odo push

oc label dc catalog-coolstore app.openshift.io/runtime=spring --overwrite

echo "Catalog Spring-Boot Deployed"