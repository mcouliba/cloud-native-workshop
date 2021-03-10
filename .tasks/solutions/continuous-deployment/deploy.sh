##################################
# Continuus Deployment Solution #
##################################

DIRECTORY=`dirname $0`
USER_ID=$1

oc project cn-project${USER_ID}

#Run the pipeline
tkn pipeline start inventory-pipeline -n cn-project${USER_ID} \
    --workspace name=shared-workspace,claimName=inventory-pipeline-pvc

#Deploy the whole Coolstore Application
/projects/workshop/.tasks/pipeline_deploy_coolstore.sh cn-project${USER_ID}
