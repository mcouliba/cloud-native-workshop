####################################
# Coolstore Application Deployment #
####################################

DIRECTORY=`dirname $0`

$DIRECTORY/catalog-spring-boot/solve_deploy.sh
$DIRECTORY/inventory-quarkus/solve_deploy.sh
$DIRECTORY/gateway-vertx/solve_deploy.sh
$DIRECTORY/web-nodejs/deploy.sh
$DIRECTORY/health-probes/deploy.sh
$DIRECTORY/app-config/deploy.sh