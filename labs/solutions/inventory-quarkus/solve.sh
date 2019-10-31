##########################
# gateway-vertx Solution #
##########################

DIRECTORY=`dirname $0`

#mkdir $DIRECTORY/../../inventory-quarkus
cp $DIRECTORY/pom.xml $DIRECTORY/../../inventory-quarkus
cp -R $DIRECTORY/src $DIRECTORY/../../inventory-quarkus
