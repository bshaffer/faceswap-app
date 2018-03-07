#	Copyright 2018, Google, Inc.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
PROJECT_ID=$(shell gcloud config list project --format=flattened | awk 'FNR == 1 {print $$2}')

build-frontend:
	docker build -f Dockerfile.frontend . \
	 -t gcr.io/$(PROJECT_ID)/faceswap-frontend

build-worker:
	docker build -f Dockerfile.worker . \
	 -t gcr.io/$(PROJECT_ID)/faceswap-worker

run-frontend:
	  #--link zipkin
	docker run -it -p 8080:8080 \
	  -v $(HOME)/gcloud/creds:/etc/creds \
	  -e FIREBASE_API_KEY=$(FIREBASE_API_KEY) \
	  -e GOOGLE_APPLICATION_CREDENTIALS=/etc/creds/$(PROJECT_ID).json \
	  -e GCLOUD_PROJECT=$(PROJECT_ID) \
	  -e PUBSUB_TOPIC=faceswap-images \
	  gcr.io/$(PROJECT_ID)/faceswap-frontend

config-minikube:
	kubectl config use-context minikube
config-faceswap-app:
	kubectl config use-context faceswap-app
config-faceswap-cluster:
	kubectl config use-context faceswap-cluster

run-worker:
	  #--link zipkin
	docker run -it \
	  -v $(HOME)/gcloud/creds:/etc/creds \
	  -e GOOGLE_APPLICATION_CREDENTIALS=/etc/creds/$(PROJECT_ID).json \
	  -e GCLOUD_PROJECT=$(PROJECT_ID) \
	  -e PUBSUB_SUBSCRIPTION=faceswap-worker \
	  gcr.io/$(PROJECT_ID)/faceswap-worker

authorize-minikube:
	kubectl create secret docker-registry gcr-json-key \
      --docker-server=https://gcr.io \
      --docker-username=_json_key \
      --docker-password="$(cat $(HOME)/gcloud/creds/$(PROJECT_ID).json)" \
      --docker-email=bshafs@gmail.com

run-zipkin:
	-docker stop zipkin && docker rm zipkin
	docker run -d \
	  -p 9411:9411 \
	  --name zipkin \
	  openzipkin/zipkin