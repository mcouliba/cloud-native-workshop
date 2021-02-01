####################################
# Coolstore Application Deployment #
####################################

DIRECTORY=`dirname $0`
PROJECT_NAME=$1

#Starting from scratch
oc new-project ${PROJECT_NAME}
if [ $? -ne 0 ]
then
    echo -e "\033[0;31mPlease delete the '${PROJECT_NAME}' project\033[0m"
    exit 1
fi

$DIRECTORY/solutions/catalog-spring-boot/solve_deploy.sh ${PROJECT_NAME}
$DIRECTORY/solutions/inventory-quarkus/solve_deploy.sh ${PROJECT_NAME}
$DIRECTORY/solutions/gateway-vertx/solve_deploy.sh ${PROJECT_NAME}
$DIRECTORY/solutions/web-nodejs/deploy.sh ${PROJECT_NAME}
$DIRECTORY/solutions/health-probes/deploy.sh ${PROJECT_NAME}
$DIRECTORY/solutions/app-config/deploy.sh ${PROJECT_NAME}

echo -e "\033[0;32mThe deployment of the Coolstore Application in ${PROJECT_NAME} by Inner Loop has succeeded\033[0m"