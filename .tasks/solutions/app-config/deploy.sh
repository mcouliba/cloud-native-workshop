######################################
# Application Configuration Solution #
######################################

DIRECTORY=`dirname $0`


oc project my-project${CHE_WORKSPACE_NAMESPACE#user}

if [ $? -eq 0 ]
then
    oc policy add-role-to-user view -z default

    oc new-app postgresql-ephemeral \
        --param=DATABASE_SERVICE_NAME=catalog-postgresql \
        --param=POSTGRESQL_DATABASE=catalogdb \
        --param=POSTGRESQL_USER=catalog \
        --param=POSTGRESQL_PASSWORD=catalog \
        --labels=app=coolstore,app.kubernetes.io/instance=catalog-postgresql,app.kubernetes.io/name=postgresql,app.kubernetes.io/part-of=coolstore,app.openshift.io/runtime=postgresql

    oc new-app mariadb-ephemeral \
        --param=DATABASE_SERVICE_NAME=inventory-mariadb \
        --param=MYSQL_DATABASE=inventorydb \
        --param=MYSQL_USER=inventory \
        --param=MYSQL_PASSWORD=inventory \
        --param=MYSQL_ROOT_PASSWORD=inventoryadmin \
        --labels=app=coolstore,app.kubernetes.io/instance=inventory-mariadb,app.kubernetes.io/name=mariadb,app.kubernetes.io/part-of=coolstore,app.openshift.io/runtime=mariadb


    cp $DIRECTORY/pom.xml $DIRECTORY/../../../labs/inventory-quarkus
    cp $DIRECTORY/application.properties $DIRECTORY/../../../labs/inventory-quarkus/src/main/resources
    cd $DIRECTORY/../../../labs/inventory-quarkus
    mvn clean package -DskipTests
    odo push
    oc label dc inventory-coolstore app.openshift.io/runtime=quarkus --overwrite

    oc create configmap inventory --from-file=application.properties=/projects/workshop/.tasks/solutions/app-config/inventory-openshift-application.properties
    oc label configmap inventory app=coolstore app.kubernetes.io/instance=inventory
    oc set volume dc/inventory-coolstore --add --configmap-name=inventory --mount-path=/deployments/config

    oc create configmap catalog --from-file=application.properties=/projects/workshop/.tasks/solutions/app-config/catalog-openshift-application.properties
    oc label configmap catalog app=coolstore app.kubernetes.io/instance=catalog

    oc delete pod -l deploymentconfig=catalog-coolstore

    oc annotate --overwrite dc/catalog-coolstore app.openshift.io/connects-to='catalog-postgresql'
    oc annotate --overwrite dc/inventory-coolstore app.openshift.io/connects-to='inventory-mariadb'
fi

echo "Application Configuration Externalization Done"