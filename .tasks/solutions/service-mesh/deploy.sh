#########################
# Service Mesh Solution #
#########################

DIRECTORY=`dirname $0`
USER_ID=$1

oc project cn-project${USER_ID}

oc patch dc/catalog-coolstore --patch '{"spec": {"template": {"metadata": {"annotations": {"sidecar.istio.io/inject": "true"}}}}}' -n cn-project${USER_ID}
oc rollout latest catalog-coolstore

oc patch dc/inventory-coolstore --patch '{"spec": {"template": {"metadata": {"annotations": {"sidecar.istio.io/inject": "true"}}}}}' -n cn-project${USER_ID}
oc rollout latest inventory-coolstore

oc patch dc/gateway-coolstore --patch '{"spec": {"template": {"metadata": {"annotations": {"sidecar.istio.io/inject": "true"}}}}}' -n cn-project${USER_ID}
oc rollout latest gateway-coolstore

cat << EOF | oc apply -f -
apiVersion: networking.istio.io/v1beta1
kind: Gateway
metadata:
  name: gateway-coolstore
  namespace: cn-project${USER_ID}
spec:
  selector:
    istio: ingressgateway # use Istio default gateway implementation
  servers:
    - port:
        number: 80
        name: http
        protocol: HTTP
      hosts:
        - "*"
EOF

cat << EOF | oc apply -f -
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: gateway-coolstore
  namespace: cn-project${USER_ID}
spec:
  hosts:
    - "*"
  gateways:
    - gateway-coolstore
  http:
    - match:
        - uri:
            prefix: /cn-project${USER_ID}/api
      rewrite:
        uri: "/api"
      route:
        - destination:
            port:
              number: 8080
            host: gateway-coolstore
EOF

oc new-app https://github.com/mcouliba/cloud-native-workshop#ocp4.6 \
    --strategy=docker \
    --context-dir=/labs/catalog-go \
    --name=catalog-coolstore-v2 \
    --labels=app.kubernetes.io/part-of=coolstore,app.kubernetes.io/name=golang

cat << EOF | oc apply -f -
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  name: catalog-coolstore
  namespace: cn-project${USER_ID}
spec:
  hosts:
    - catalog-coolstore
  http:
  - route:
    - destination:
        host: catalog-coolstore
      weight: 0
    - destination:
        host: catalog-coolstore-v2
      weight: 100
EOF