##################################
# Gitops Solution #
##################################

DIRECTORY=`dirname $0`
CONTEXT_FOLDER=/projects/workshop/labs/gitops
USER_ID=$1

echo "--- ArgoCD Applications for GitOps ---"

/projects/workshop/.tasks/gitops_export_coolstore.sh my-project${USER_ID} cn-project${USER_ID}

#Gitea initialization
GITEA_URL=http://gitea-server.gitea.svc:3000
GITEA_URL_WITH_CREDENTIALS=http://user${USER_ID}:openshift@gitea-server.gitea.svc:3000

declare -a COMPONENTS=("inventory" "catalog" "gateway" "web")

for COMPONENT_NAME in "${COMPONENTS[@]}"
do
    echo "Creating '${COMPONENT_NAME}' ArgoCD Application ..."

    REPO_NAME=${COMPONENT_NAME}"-gitops"

    curl -X DELETE ${GITEA_URL_WITH_CREDENTIALS}/api/v1/repos/user${USER_ID}/${REPO_NAME} \
        -H  "accept: application/json" \
        -H  "Content-Type: application/json"
        
    curl -X POST ${GITEA_URL_WITH_CREDENTIALS}/api/v1/user/repos \
        -H  "accept: application/json" \
        -H  "Content-Type: application/json" \
        -d '{"name" : "'${REPO_NAME}'"}' 

    cd ${CONTEXT_FOLDER}/${COMPONENT_NAME}-coolstore
    rm -rf .git
    git init
    git remote add origin ${GITEA_URL}/user${USER_ID}/${REPO_NAME}.git
    git add *
    git commit -m "Initial"
    git push ${GITEA_URL_WITH_CREDENTIALS}/user${USER_ID}/${REPO_NAME}.git

    oc project cn-project${USER_ID}

    #ArgoCD initialization
    ARGOCD_SERVER=argocd-server.argocd.svc

    argocd login ${ARGOCD_SERVER} --username user${USER_ID} --password openshift --plaintext

    argocd repo add ${GITEA_URL}/user${USER_ID}/${REPO_NAME}.git

    argocd app create ${COMPONENT_NAME}${USER_ID} \
        --project "cn-project${USER_ID}" \
        --sync-policy "none" \
        --repo "${GITEA_URL}/user${USER_ID}/${REPO_NAME}.git" \
        --revision "HEAD" \
        --path "." \
        --dest-server "https://kubernetes.default.svc" \
        --dest-namespace "cn-project${USER_ID}"

done

echo "--- ArgoCD Applications has been created! ---"