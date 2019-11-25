################################
# catalog-spring-boot Solution #
################################

DIRECTORY=`dirname $0`

$DIRECTORY/solve.sh

cd /projects/workshop/labs/catalog-spring-boot
mvn clean package -DskipTests

odo create java:11 catalog --context /projects/workshop/labs/catalog-spring-boot/ --binary target/catalog-1.0-SNAPSHOT.jar --app coolstore
odo push
odo url create catalog --port 8080
odo push