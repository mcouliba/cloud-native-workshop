##################################
# Continuus Deployment Solution #
##################################

DIRECTORY=`dirname $0`
USER_ID=$1
GITEA_URL=http://gitea-server.gitea.svc:3000

oc project cn-project${USER_ID}

#Create ArgoCD Tekton task
cat << EOF | oc apply -f -
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: argocd-task-sync-and-wait
  namespace: cn-project${USER_ID}
  labels:
    app.kubernetes.io/version: "0.1"
  annotations:
    tekton.dev/pipelines.minVersion: "0.12.1"
    tekton.dev/tags: deploy
    tekton.dev/displayName: "argocd"
spec:
  description: >-
    This task syncs (deploys) an Argo CD application and waits for it to be healthy.
    To do so, it requires the address of the Argo CD server and some form of
    authentication either a username/password or an authentication token.
  params:
    - name: application-name
      description: name of the application to sync
  stepTemplate:
    envFrom:
      - configMapRef:
          name: argocd-env-configmap  # used for server address
      - secretRef:
          name: argocd-env-secret  # used for authentication (username/password or auth token)
  steps:
    - name: login
      image: argoproj/argocd:v1.7.6
      script: |
        if [ -z $ARGOCD_AUTH_TOKEN ]; then
          yes | argocd login \$ARGOCD_SERVER --username=\$ARGOCD_USERNAME --password=\$ARGOCD_PASSWORD --plaintext;
        fi
    - name: sync
      image: argoproj/argocd:v1.7.6
      script: |
        argocd app sync \$(params.application-name)
    - name: wait
      image: argoproj/argocd:v1.7.6
      script: |
        argocd app wait \$(params.application-name) --health
EOF

#Create ArgoCD ConfigMap
oc create configmap argocd-env-configmap \
    --from-literal=ARGOCD_SERVER=argocd-server.argocd.svc \
    -n cn-project${USER_ID}

#Create ArgoCD secret
oc create secret generic argocd-env-secret \
    --from-literal=ARGOCD_USERNAME=user${USER_ID} \
    --from-literal=ARGOCD_PASSWORD=openshift \
    -n cn-project${USER_ID}

#Expand the existing pipeline
cat << EOF | oc apply -f -
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: inventory-pipeline
  namespace: cn-project${USER_ID}
spec:
  tasks:
    - name: git-clone
      params:
        - name: url
          value: '${GITEA_URL}/user${USER_ID}/inventory-quarkus.git'
        - name: revision
          value: master
        - name: submodules
          value: 'true'
        - name: depth
          value: '1'
        - name: sslVerify
          value: 'true'
        - name: deleteExisting
          value: 'true'
        - name: verbose
          value: 'true'
      taskRef:
        kind: ClusterTask
        name: git-clone
      workspaces:
        - name: output
          workspace: shared-workspace
    - name: s2i-java-11
      params:
        - name: PATH_CONTEXT
          value: .
        - name: TLSVERIFY
          value: 'false'
        - name: MAVEN_CLEAR_REPO
          value: 'false'
        - name: MAVEN_MIRROR_URL
          value: 'http://nexus.opentlc-shared.svc:8081/repository/maven-all-public'
        - name: IMAGE
          value: >-
            image-registry.openshift-image-registry.svc:5000/cn-project${USER_ID}/inventory-coolstore
      runAfter:
        - git-clone
      taskRef:
        kind: ClusterTask
        name: s2i-java-11
      workspaces:
        - name: source
          workspace: shared-workspace
    - name: argocd-task-sync-and-wait
      params:
        - name: application-name
          value: inventory
      runAfter:
        - s2i-java-11
      taskRef:
        kind: Task
        name: argocd-task-sync-and-wait
    - name: openshift-client
      params:
        - name: SCRIPT
          value: oc \$@
        - name: ARGS
          value:
            - rollout
            - latest
            - inventory-coolstore
      runAfter:
        - argocd-task-sync-and-wait
      taskRef:
        kind: ClusterTask
        name: openshift-client
  workspaces:
    - name: shared-workspace
EOF