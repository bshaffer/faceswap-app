
### PHASE 0 ###
kubectl create secret docker-registry gcr-json-key \
          --docker-server=https://gcr.io \
          --docker-username=_json_key \
          --docker-password="$(cat ~/gcloud/creds/confoo-montreal-2018.json)" \
          --docker-email=bshafs@gmail.com

### PHASE 1 ###
kubectl run faceswap-app --image=gcr.io/confoo-montreal-2018/faceswap-app --port=8080
kubectl expose deployment faceswap-app --type LoadBalancer


### PHASE 2 ###
kubectl create configmap pubsub \
    --from-literal=PUBSUB_TOPIC=faceswap-images-local \
    --from-literal=PUBSUB_SUBSCRIPTION=faceswap-worker-local

kubectl create secret generic google-credentials \
    --from-literal=confoo-montreal-2018.json="$(cat ~/gcloud/creds/confoo-montreal-2018.json)"

kubectl create secret generic firebase-credentials \
    --from-literal=apikey="$(cat ~/gcloud/creds/confoo-montreal-2018-apikey.txt)"

# for production
kubectl create configmap pubsub \
    --from-literal=PUBSUB_TOPIC=faceswap-images \
    --from-literal=PUBSUB_SUBSCRIPTION=faceswap-worker

kubectl create secret generic google-credentials \
    --from-literal=confoo-montreal-2018.json="$(cat ~/gcloud/creds/confoo-montreal-2018.json)"

kubectl create secret generic firebase-credentials \
    --from-literal=apikey="$(cat ~/gcloud/creds/confoo-montreal-2018-apikey.txt)"

### PHASE EXTRA ###
 kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/v1.7.1/src/deploy/recommended/kubernetes-dashboard.yaml
