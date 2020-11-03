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


    cp $DIRECTORY/pom.xml $DIRECTORY/../../inventory-quarkus
    cp $DIRECTORY/application.properties $DIRECTORY/../../inventory-quarkus/src/main/resources
    cd /projects/inventory/labs/inventory-quarkus
    mvn clean package -DskipTests
    odo push
    oc label dc inventory-coolstore app.openshift.io/runtime=quarkus --overwrite
    
    cat <<EOF > /projects/inventory-openshift-application.properties
quarkus.datasource.url=jdbc:mariadb://inventory-mariadb.my-project${CHE_WORKSPACE_NAMESPACE#user}.svc:3306/inventorydb
quarkus.datasource.username=inventory
quarkus.datasource.password=inventory
EOF

    oc create configmap inventory --from-file=application.properties=/projects/inventory-openshift-application.properties
    oc label configmap inventory app=coolstore app.kubernetes.io/instance=inventory
    oc set volume dc/inventory-coolstore --add --configmap-name=inventory --mount-path=/deployments/config

    cat <<EOF > /projects/catalog-openshift-application.properties
spring.datasource.url=jdbc:postgresql://catalog-postgresql.my-project${CHE_WORKSPACE_NAMESPACE#user}.svc:5432/catalogdb
spring.datasource.username=catalog
spring.datasource.password=catalog
spring.datasource.driver-class-name=org.postgresql.Driver
spring.jpa.hibernate.ddl-auto=create
spring.jpa.properties.hibernate.jdbc.lob.non_contextual_creation=true
EOF

    oc create configmap catalog --from-file=application.properties=/projects/catalog-openshift-application.properties
    oc label configmap catalog app=coolstore app.kubernetes.io/instance=catalog

    oc delete pod -l deploymentconfig=catalog-coolstore

    oc annotate --overwrite dc/catalog-coolstore app.openshift.io/connects-to='catalog-postgresql'
    oc annotate --overwrite dc/inventory-coolstore app.openshift.io/connects-to='inventory-mariadb'
fi

echo "Application Configuration Externalization Done"