####################################
# Coolstore Application Deployment #
####################################

DIRECTORY=`dirname $0`

#Starting from scratch
oc delete project my-project${CHE_WORKSPACE_NAMESPACE#user} 2> /dev/null
until [ $? -ne 0 ]
do
    sleep 1
    oc get project my-project${CHE_WORKSPACE_NAMESPACE#user} 2> /dev/null
done

oc new-project my-project${CHE_WORKSPACE_NAMESPACE#user}

$DIRECTORY/../labs/solutions/catalog-spring-boot/solve_deploy.sh
$DIRECTORY/../labs/solutions/inventory-quarkus/solve_deploy.sh
$DIRECTORY/../labs/solutions/gateway-vertx/solve_deploy.sh
$DIRECTORY/../labs/solutions/web-nodejs/deploy.sh
$DIRECTORY/../labs/solutions/health-probes/deploy.sh
$DIRECTORY/../labs/solutions/app-config/deploy.sh

echo -e "\033[0;32mThe deployment of the Coolstore Application by Inner Loop has succeeded\033[0m"