##########################
# gateway-dotnet Solution #
##########################

DIRECTORY=`dirname $0`
CONTEXT_FOLDER=/projects/workshop/labs/gateway-dotnet
PROJECT_NAME=$1

cd ${CONTEXT_FOLDER}
mvn clean package -DskipTests

odo delete --all --force
odo project set ${PROJECT_NAME}
odo component create dotnet gateway --context ${CONTEXT_FOLDER} --s2i --app coolstore
odo url create gateway --port 8080
odo push
odo link inventory --component gateway --port 8080
odo link catalog --component gateway --port 8080

oc annotate --overwrite dc/gateway-coolstore app.openshift.io/connects-to='catalog,inventory'
oc label dc gateway-coolstore app.openshift.io/runtime=dotnet --overwrite

echo "Gateway .NET Deployed"