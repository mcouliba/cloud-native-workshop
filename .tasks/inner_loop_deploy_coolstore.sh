####################################
# Coolstore Application Deployment #
####################################

DIRECTORY=`dirname $0`

#Starting from scratch
oc new-project my-project${CHE_WORKSPACE_NAMESPACE#user}
if [ $? -ne 0 ]
then
    echo -e "\033[0;31mPlease delete the 'my-project${CHE_WORKSPACE_NAMESPACE#user}' project\033[0m"
    exit 1
fi

$DIRECTORY/solutions/catalog-spring-boot/solve_deploy.sh
$DIRECTORY/solutions/inventory-quarkus/solve_deploy.sh
$DIRECTORY/solutions/gateway-vertx/solve_deploy.sh
$DIRECTORY/solutions/web-nodejs/deploy.sh
$DIRECTORY/solutions/health-probes/deploy.sh
$DIRECTORY/solutions/app-config/deploy.sh

echo -e "\033[0;32mThe deployment of the Coolstore Application by Inner Loop has succeeded\033[0m"