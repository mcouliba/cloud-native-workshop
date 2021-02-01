####################################
# Coolstore Application Deployment #
####################################

DIRECTORY=`dirname $0`
USER_ID=$1

$DIRECTORY/solutions/continuous-integration/deploy.sh ${USER_ID}
$DIRECTORY/solutions/gitops/deploy.sh ${USER_ID}
$DIRECTORY/solutions/continuous-deployment/deploy.sh ${USER_ID}

echo -e "\033[0;32mThe deployment of the Coolstore Application in cn-project${USER_ID} by Outer Loop has succeeded\033[0m"