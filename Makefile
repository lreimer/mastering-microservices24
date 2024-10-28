GCP_PROJECT ?= cloud-native-experience-lab
GCP_REGION ?= europe-north1
GCP_ZONE ?= europe-north1-b

CLUSTER_NAME ?= mastering-microservices24

prepare-gcp:
	@gcloud config set project $(GCP_PROJECT)
	@gcloud config set compute/zone $(GCP_ZONE)
	@gcloud config set container/use_client_certificate False

create-gcp-cluster:
	@gcloud container clusters create $(CLUSTER_NAME)  \
	  	--release-channel=regular \
		--cluster-version=1.31 \
  		--region=$(GCP_REGION) \
		--addons HttpLoadBalancing,HorizontalPodAutoscaling \
		--workload-pool=$(GCP_PROJECT).svc.id.goog \
		--enable-autoscaling \
		--autoscaling-profile=optimize-utilization \
		--num-nodes=1 \
		--min-nodes=1 --max-nodes=3 \
		--machine-type=e2-standard-8 \
		--logging=SYSTEM \
    	--monitoring=SYSTEM
	@kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$$(gcloud config get-value core/account)
	@kubectl cluster-info

delete-gcp-cluster:
	@gcloud container clusters delete $(CLUSTER_NAME) --region=$(GCP_REGION) --async --quiet