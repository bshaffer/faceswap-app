### PHASE 0 ###
kubectl create secret docker-registry gcr-json-key \
          --docker-server=https://gcr.io \
          --docker-username=_json_key \
          --docker-password="$(cat ~/gcloud/creds/sunshine-php-2018.json)" \
          --docker-email=bshafs@gmail.com

### PHASE 1 ###
kubectl run faceswap-app --image=gcr.io/sunshine-php-2018/faceswap-app --port=8080
kubectl expose deployment faceswap-app --type LoadBalancer --port 80


### PHASE 2 ###
kubectl create configmap pubsub --from-literal=PUBSUB_TOPIC=faceswap-images --from-literal=PUBSUB_SUBSCRIPTION=faceswap-worker
kubectl create secret generic google-credentials --from-literal=cloud-next-php.json="$(cat ~/gcloud/creds/cloud-next-php.json)"