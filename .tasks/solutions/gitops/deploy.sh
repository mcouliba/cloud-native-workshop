##################################
# Gitops Solution #
##################################

DIRECTORY=`dirname $0`
CONTEXT_FOLDER=/projects/workshop/labs/gitops
USER_ID=$1

/projects/workshop/.tasks/gitops_export_coolstore.sh my-project${USER_ID} cn-project${USER_ID}

#Gitea initialization
GITEA_URL=http://gitea-server.gitea.svc:3000
GITEA_URL_WITH_CREDENTIALS=http://user${USER_ID}:openshift@gitea-server.gitea.svc:3000

curl -X POST ${GITEA_URL_WITH_CREDENTIALS}/api/v1/user/repos \
    -H  "accept: application/json" \
    -H  "Content-Type: application/json" \
    -d '{"name" : "gitops-cn-project"}' 

cd ${CONTEXT_FOLDER}
git init
git remote add origin ${GITEA_URL}/user${USER_ID}/gitops-cn-project.git
git add *
git commit -m "Initial"
git push ${GITEA_URL_WITH_CREDENTIALS}/user${USER_ID}/gitops-cn-project.git

oc project cn-project${USER_ID}

#ArgoCD initialization
ARGOCD_SERVER=argocd-server.argocd.svc

argocd login ${ARGOCD_SERVER} --username user${USER_ID} --password openshift --plaintext

argocd repo add ${GITEA_URL}/user${USER_ID}/gitops-cn-project.git

argocd app create cn-project${USER_ID} \
    --project "default" \
    --sync-policy "none" \
    --repo "${GITEA_URL}/user${USER_ID}/gitops-cn-project.git" \
    --revision "HEAD" \
    --path "." \
    --dest-server "https://kubernetes.default.svc" \
    --dest-namespace "cn-project${USER_ID}"
