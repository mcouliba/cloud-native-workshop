################################
# catalog-spring-boot Solution #
################################

DIRECTORY=`dirname $0`

$DIRECTORY/solve.sh
mvn clean fabric8:deploy -f $DIRECTORY/../../catalog-spring-boot
oc label bc/catalog-s2i app.kubernetes.io/instance=catalog