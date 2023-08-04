# Kubernetes

Follow [Imperative commands](https://github.com/dgkanatsios/CKAD-exercises/blob/main/c.pod_design.md) guide.

## Install multi node kind cluster

- Make a file: [kind-example-config.yaml](kind-example-config.yaml)
- execute: `kind create cluster --config kind-example-config.yaml`
- To delete: `kind delete clusters kind`
- get into kind control plane: `docker exec -it kind-control-plane bash`
- If you face any error:
```bash
ERROR: failed to create cluster: failed to get kubeconfig to merge: yaml: unmarshal errors:
  line 23: mapping key "apiVersion" already defined at line 1
  line 24: mapping key "clusters" already defined at line 2
  line 29: mapping key "contexts" already defined at line 7
  line 34: mapping key "current-context" already defined at line 13
  line 35: mapping key "kind" already defined at line 14
  line 36: mapping key "preferences" already defined at line 15
  line 37: mapping key "users" already defined at line 16
```
- Under home find .kube/config and remove all the content in config file.


## Make an alias

```shell
export do="--dry-run=client -o yaml"    # k create deploy nginx --image=nginx $do

export now="--force --grace-period 0"   # k delete pod x $now

alias k=kubectl
```

## help

```kubernetes
kubectl run --help
kubectl api-resources
```
## pods
When you create a pod, kubernetes creates and stores the information in ETCD database or datastore.
```bash
kubectl get pods
or 
kb get pods -o wide

kubectl explain pod 

# get full yaml file
kubectl get pod nginx -o yaml

# create pod with name redis and image
kubectl run nginx --image=nginx
k run pod-name --image image --dry-run=client -o yaml

kubectl exec -i podName -n namespace -- pwd
kubectl exec -it podName -n namespace -- pwd
kubectl exec -it pod -- bash
kubectl exec --stdin --tty pod -- ping 10.244.0.8
kubectl exec -it webapp-color -- sh

# To replace the pod-definition file.
k replace --force -f pod.yaml --grace-period=0
or try
kubectl apply -f pod-with-secrets.yaml

kubectl replace -f pod.yaml --force

e.g:
kubectl run nginx --image=nginx --dry-run=client -o yaml
kb run redis --image redis --dry-run=client -o yaml > redispod.yaml

# To delete all pods
k delete pod --all
kubectl delete pod --all -n default

```
## Mulit-container-pod

[multi-container-pod](multi-container-pod/multi-container-pod.yaml)

connect to a container:
[pod-init-volumemount](PersistentVolumes/pod-init-container-volumemounts.yaml)

```
kubectl exec -it busybox -c container1 -- /bin/sh
ls
exit
```
## Pod with Init-containers
When a Pod is created, first init continer will run for one time. Later, the container will run. 

[init-container.yaml](initContainers/init-container.yaml)

## create pod with namespace

- kb create -f [pod-definition.yaml](/pod/pod-definition.yml) --namespace=namespace

or

- keep the namespace definition in pod [namespace-dev.yaml](/pod/namespace-dev.yaml)

## Create/update/delete ReplicaSet

- kubectl create -f [myapp-replicaset.yaml](/ReplicaSet/myapp-replicaset.yaml)

```bash
kubectl get replicaset 
or
kubectl get rs
```

- kubectl replace -f [myapp-replicaset.yaml](/ReplicaSet/myapp-replicaset.yaml)
```
kubectl scale --replicas=6 -f myapp-replicaset.yaml
kubectl scale --replicas=9 replicaset myapp-replicaset
kb delete replicaset replicaset-1 replicaset-2
```
## Deployments
[deployments.yaml](deployments/deployments.yaml)
```kubectl
kb create deploy my-deploy --image nginx --dry-run -o yaml
kb create deploy my-deploy --image nginx --dry-run -o yaml > deployment.yaml
kb create -f deployment.yaml --record

# create deploy with replicas
kubectl create deployment nginx --image=nginx --replicas=5
kubectl scale deployment nginx --replicas=5
kb create deploy redis-deploy --image=redis --replicas=2 -n=dev --dry-run=client -o yaml

# k -n namespace get deploy,pod | grep -i "podname"
# k get deploy,pod | grep -i "podname"
```
### Deployment strategy
[myapp-blue](deployments/blue-green-deployments/myapp-blue.yaml),
[myapp-green](deployments/blue-green-deployments/myapp-green.yaml)
- Old version is blue
- New version is Green

Use two deployments with `stage:blue` and `stage:green` labels. Use a Service with a `stage:blue` selector. Once the `stage:green` deployment is up and tested, edit the selector in the service to `stage:green`.

### Canary deployment:

Traffic is routed in small percentage to new deployment.

In Canary there will be two deployments:
- One is main deployment. The whole traffic is routed to main.
- Second is the canary deployment. Small portion of traffic is routed by creating less replicas (pods).

The svc aka service will be same with same selector label.

First, create a deployment and route the traffic with svc. 
Second, create a new deployement with less pods (replicas). And route the traffic to same svc. 

In service definition the labels are same for selectors. 

## Name spaces

Get namespaces
```
kb get namespace
```
- kb create namespace new-name-space
- kb get pod --namespace kube-system
- kubectl get pod -n=kube-system

- kb create -f [pod-definition.yml](pod/pod-definition.yml) --namespace=namespace

or

- keep the namespace definition in pod [namespace-pod.yaml](pod/namespace-pod.yaml)

### To set default namespace to any other

- kb config set-context $(kubectl config current-context) --namespace=<`namespace`>

## Resource quota

### To set limit on namespace. e.g: pods = 3

[resource-quota.yaml](ResourceQuota/resource-quota.yaml)


## Service

### Create a Service named redis-service of type ClusterIP to expose pod redis on port 6379

#### check the connection on port 80:
`nc -v -z -w 2 secure-service 80`

- kubectl create service clusterip redis-service --tcp=6379:6379 --dry-run=client -o yaml

`or`

- kubectl expose pod redis --port=6379 --name redis-service --dry-run=client -o yaml


## To view all resources

```
kb get all -n namespace
```
e.g: `kb get all -n dev`

## Imperative commands 

[*Imperative commands*](imperative-commands.md)

## Commands in Docker
- To sleep a container for 5 seconds
```bash
docker run --name ubuntu-sleeper ubuntu-sleeper 10

# publish port 8080 on the container to 8282 on the host.
docker run -p 8282:8080 webapp-color

# container image
docker run python:3.6 cat /etc/*release*
# for lite images use alpine and add "tag" to image.

docker build -t webapp-color:lite .

# build image with two tags

sudo docker build -t registry.killer.sh:5000/sun-cipher:latest -t registry.killer.sh:5000/sun-cipher:v1-docker .

sudo docker build -t image-name:latest -t image-name:tag-2 .

# push to registry

sudo docker push registry.killer.sh:5000/sun-cipher:latest

sudo docker push registry.killer.sh:5000/sun-cipher:v1-docker

# To save docker image to a location

sudo docker save -o buzz.tar image:1
sudo docker save -o buzz.tar buzz:1

# build image using podman

podman build -t registry.killer.sh:5000/sun-cipher:v1-podman .

# create a container using podman image

podman run -d --name sun-cipher registry.killer.sh:5000/sun-cipher:v1-podman

```

## Config maps

Imperative:

```bash
kubectl create configmap app-config --from-literal=app_color=blue --from-literal=APP_MOD=prod

-----

kubectl create configmap app-config --from-file=app_config.properties
```
Declarative: [configMap.yaml](ConfigMap/configMap.yaml)

## secrets

```bash
kubectl create secret generic app-secret --from-literal=DB_HOST=mysql

-----------

k get secrets app-secret -o yaml
```

To encode a string value
```bash
echo -n 'mysql' | base64
```

To decode a string value
```bash
echo -n 'bXlzcWw=' | base64 --decode
```

## Service account

Service account is used by applications. Which is similar to user accounts used by humans.

```bash
kubectl create serviceaccount app-dashboard-sa
```
Then you create the token for service account.
```bash
kubectl create token app-dashboard-sa   
```
-  When you create a pod, automatically a service account and correspoinding token is created, and the token is mounted under `/var/run/secrets/kubernetes.io/serviceaccount/token`

- For every namespace their is serviceaccount.
- decode the token and check the expiry data:
```bash
jq -R 'split(".") | select(length > 0) | .[0],.[1] | @base64d | fromjson' <<< eyJhbGciOiJSUzI1NiIsImtpZCI6IndhRzFranBvTTFRZUJ5VzN0V2x1cWctejFKekx6SE10U2tNT1RTamZqY28ifQ.eyJhdWQiOlsiaHR0cHM6Ly9rdWJlcm5ldGVzLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWwiXSwiZXhwIjoxNjg0MDU4NjQxLCJpYXQiOjE2ODQwNTUwNDEsImlzcyI6Imh0dHBzOi8va3ViZXJuZXRlcy5kZWZhdWx0LnN2Yy5jbHVzdGVyLmxvY2FsIiwia3ViZXJuZXRlcy5pbyI6eyJuYW1lc3BhY2UiOiJkZWZhdWx0Iiwic2VydmljZWFjY291bnQiOnsibmFtZSI6ImFwcC1kYXNoYm9hcmQtc2EiLCJ1aWQiOiJmN2FiMTVmNS00OWYwLTQ4MjgtODU5OC1iMTlmYTE4MjZiM2MifX0sIm5iZiI6MTY4NDA1NTA0MSwic3ViIjoic3lzdGVtOnNlcnZpY2VhY2NvdW50OmRlZmF1bHQ6YXBwLWRhc2hib2FyZC1zYSJ9.MvcxJT3OzWXAip8WWOXeuUYpv7vcT0fcTnV3n7x_myO_nggenoEheJTsJwyAexliHCCUiyk4vvqkjHLvAjyduyhGwl3xW5YfXrQdQdCXO-ohJ10W2WSj2UQQKbu1kT3vTw9qqyDNwrmTayH1pz7Mm5-x3zyPbHXlpe1VpA59PnDWEMGHJfncqQOUgbW2Q7Sj8UvgbVvTTyZk99QLhzliE-yGFHOzz-pTLmeXxbDB5pcipKlCrSYLhMIC7SUC3TbxN4wQHZrkU30uMrEVcy8waaG2uZgMsiKVA-b-aJd4n01n5QEz3Q1IFvkC88J7MjpwBeG1EUiov4JlsV7KnOtPvw
```

## Taints and Toleration

- Taints are on nodes.
- Tolerations are on pods.

```bash
kubectl taint nodes node-name key=value:taint-effect

e.g: kubectl taint nodes node1 app=blue:NoSchedule
```
The `taint-effect` has three options `NoSchedule`, `PreferNoSchedule`, `NoExecute`.
 
To remove taint fromt the node:

```bash
kubectl taint nodes kind-control-plane app=blue:NoSchedule-
```
- Edit the control plane and comment the taint.
```
k edit nodes controlplane
```

## Node selector
- label the nodes, we use node selectors while creating the pods.

```bash
kubectl label nodes node01 key=value
```
e.g:

```
kubectl label nodes node-1 size=Large
```

example script: [nodeSelector.yaml](NodeSelector/nodeSelector.yaml)

## Node Affinity
- Label the node and use the same label to place pods on that node.
- To help and limit pod placements on node with advance capabilities. This is similar to NodeSelector.

There are two types of node affinity ➜

- `requiredDuringSchedulingIgnoredDuringExecution`: The scheduler can't schedule the Pod unless the rule is met. This functions like nodeSelector, but with a more expressive syntax.
- `preferredDuringSchedulingIgnoredDuringExecution`: The scheduler tries to find a node that meets the rule. If a matching node is not available, the scheduler still schedules the Pod.

[nodeAffinity.yaml](NodeAffinity/nodeAffinity.yaml)

## Logs

```bash
kubectl logs -f pod
```
- Logs for multi-container

```bash
kubectl logs -f podName containerName
```

## Metrics

git clone https://github.com/kodekloudhub/kubernetes-metrics-server.git

kubectl create -f kubernetes-metrics-server/

For Kind: follow this [link](https://gist.github.com/sanketsudake/a089e691286bf2189bfedf295222bd43)

```bash
kubectl top node
kubectl top pod
```

## Labels and selectors
```bash
kubectl run hazelcast --image=hazelcast/hazelcast --labels="app=hazelcast,env=prod"
kubectl run strawberry --image=hazelcast/hazelcast --labels="app=strawberry,env=prod"
```
- To get the labels of all prod environment pods
```bash
kubectl get po --selector env=prod

# All objects in prod env
kubectl get all --selector env=prod

# Multi search
kubectl get po --selector env=prod,bu=finance,tier=frontend

# label pods
k label pod -l <previous=label> <new=label>
k label pod -l app=myapp protected=security

# add annotation to pod
kubectl annotate pods -l protected=true protected='do not delete this pod'

```

There are two types of labels:

*for example*: If you create replicaSet, it has two. 1). replicaSet itself. 2). for pods.

## Annotation:

Used for buildversion, emails, phone numbers, etc.

[Annotation-pod](pod/namespace-pod.yaml)

## Rolling update & Rollbacks

[rolling-update-rollback](deployments/rolling-update-rollback.yaml)

`kubectl create -f deployment.yaml --record`
Update the yaml file e.g: replicas 3 to 4.

`kubectl set image deployment.apps/rolling-deployment containerName=1.23.4-perl`

`kubectl set image deployment deployName nginx=nginx:1.17`

`kubectl rollout history deployments/myapp-blue --revision=2`

### update deployment
`kubectl rollout status deployment/Appdeployment`

### status and history
`kubectl rollout status deployment/Appdeployment`

`kubectl rollout history deployment/Appdeployment`

`kubectl rollout history deployment rolling-deployment --revision=5`

### rollback aka undo
`kubectl rollout undo deployment/Appdeployment`

## Jobs

[job-pod.yaml](jobs/job-pod.yaml)

```bash
# Create job

kubectl create job throw-dice-job --image=kodekloud/throw-dice --dry-run=client -o yaml

kubectl get jobs

# To check the job detail

kubectl logs pod-name

e.g: kubectl logs math-add-job-9lh7c

# To delete

kubectl delete job job-name

# Job report, number of pod used to completions.

`kubectl get pods -l job-name=report -o name | wc -l`

```

## Services

[service-NodePort.yaml](service/service-NodePort.yaml)

```bash
kubectl create service nodeport pod-label --tcp=3008:80 --dry-run=client -o yaml
```

## Ingress Networking

Nginx controller look for paths in nginx resource file. After, finding the path it will look for related service (which connects to pod, deployment).

### Ingress resource cmd
```bash
kubectl create ingress <ingress-name> --rule="host/path=service:port"

# e.g:
kubectl create ingress ingress-test --rule="wear.my-online-store.com/wear*=wear-service:80"
```


`https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.34.1/deploy/static/provider/baremetal/deploy.yaml`
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.34.1/deploy/static/provider/baremetal/deploy.yaml
```

## ingress related commands
```bash
kubectl get ingress -A
kubectl describe ingress -A
kubectl get svc -n ingress-nginx
kubectl get svc -A
```
To add the new path to your ingress:
- `kubectl edit ingress ingressName -n namespace` or `kubectl edit ingress -n namespace`.

Once you save, it will automatically updated with new path.

To get the `ingress-controller` namespace, type: `kubectl get svc -A`

### To get the host name of ingress resource

`kubectl describe ingress -A` or give namespace.

```bash
kubectl create ns ingress-nginx
kubectl create configmap ingress-nginx-controller -n ingress-nginx
kubectl create serviceaccount ingress-nginx -n ingress-nginx
kubectl create serviceaccount ingress-nginx-admission -n ingress-nginx
kubectl get roles -A
kubectl get rolebindings -A
```

[ingress-controller.yaml](ingress-controller/ingress-controller.yaml)

## Install k8s the kubeadm way


## Network Policy

A network policy can be applied on a Pod. The pod policy will define how the traffic is received or blocked from different pods in cluster.

ingress network policy: [network-policy-definition.yaml](NetworkPolicy/network-policy-definition.yaml)

## StatefulSets
[stateful, service and deploy](StatefulSets/Servcie-deployment.yaml)
- for stateful set you need servcie and deployment.
- In service ClusterIp set to none.
- In deployment file change kind from `Deployment` and `StatefulSet`

After creation, all pods will get separate DNS record created.

- `pod-0.service.default.svc.cluster.local`
- `pod-1.service.default.svc.cluster.local`

## State Persistence

### Persistent volume

A pod requires the volume to store the data.

To bind a pod and persistent volume. Create a persistent volume claim and bind with pod. Note: pod required the claim name to bind.

[pod-and-claim](PersistentVolumes/pod-and-claim.yaml)

### Storage classes

updating...

## Autentication

updating...

## kubeconfig

path: /root/.kube/config

`kubectl config view`

[kubeconfig.yaml](kubeconfig/kubeconfig.yaml)

To use that context, run the command: kubectl config --kubeconfig=/root/my-kube-config use-context research

To know the current context, run the command: kubectl config --kubeconfig=/root/my-kube-config current-context


## RBAC

[developer-user-role](RBAC/developer-role.yaml),

[user-role-binding.yaml](RBAC/user-role-binding.yaml)

```bash
# get roles
kubectl get roles
kubectl describe rolebindings.rbac.authorization.k8s.io devuser-developer-bindiing
# get particular role
kubectl describe role developer 
# get rolebindings
kubectl get rolebindings.rbac.authorization.k8s.io

```
- ClusterRole is a non-namespaced resource. You can check via the `kubectl api-resources --namespaced=false` command. So the correct answer would be Cluster Roles are cluster wide and not part of any namespace.

### check the user can access a resource or not, e.g: deployment
`kubectl auth can-i Use two deployments with stage:blue and stage:green labels. Use a Service with a stage:blue selector. Once the stage:green deployment is up and tested, edit the selector in the service to stage:green.bluecreate deployments`,

`kubectl auth can-i delete deployments`

To check for other user access:

`kubectl auth can-i create pod --as dev-user`,

`kubectl auth can-i delete pod --as dev-user`

`ps -auz | grep authorization`

## Admission controllers

e.g:

The requst flow:
user (kubectl) > Authentication (ssh) > Authorization (RBAC) > Admission Controllers (custom) > create pod

In admission controller we can define `NamespaceAutoProvision`. So, when a pod is created with namespace, the ns assigned to pod.

example senario:
- create a pod with namespace `blue`. Don't create a namesapce `blue` prior.
- The pod will be created with namespace, even though the namespace is not created earlier.

e.g: for namesapce auto provision: NamespaceAutoProvision

`vi /etc/kubernetes/manifests/kube-apiserver.yaml`

Add: `NamespaceAutoProvision` under, enabled-admission-plugins flag

`- --enable-admission-plugins=NodeRestriction,NamespaceAutoProvision`

-> To disable admission controller flag
`- --disable-admission-plugins=NodeRestriction,NamespaceAutoProvision`
```bash
ps -ef | grep kube-apiserver | grep admission-plugins
vi /etc/kubernetes/manifests/kube-apiserver.yaml 

# Admission controllers enable by default:
kubectl exec -it kube-apiserver-kind-control-plane -n kube-system -- kube-apiserver -h | grep 'enable-admission-plugins'

# check the enabled and disabled amission plugins.
ps -ef | grep kube-apiserver | grep admission-plugins

```

## Install kubectl convert plugin on the controlplane node.

[K8s doc for kubectl convert](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-kubectl-convert-plugin)

![convert](image-1.png)

`kubectl-convert -f deploy.yaml --output-version apps/v2beta1`

### It lists the cluster objects using a specific API version, which is useful for detecting deprecated components in the cluster

`kubectl api-resources --verbs=list -o name | xargs -n 1`



## Start kube-apiserver

`kubectl proxy 8001&`

## CustomResourceDefinition

[flightticket.yaml](CustomResourceDefinition/flightticket.yaml)

For custom definition file or object you need a controller.

## Helm

It acts like a package manager for kubernetes resources.

[Helm installation](https://helm.sh/docs/intro/install/)

Templates and values file form a heml chart.

Artifact hub repository: https://artifacthub.io/ stores the helm charts. A repo contains help charts.

To search helm chart: examples:-

$ `helm search hub nginx`

$ `helm search hub wordpress`

cmds:
```bash
# To list repositories
helm repo list

# To list packages, installed using helm
helm list
helm list -n namespace

# install release
helm install releaseName bitnami/apache 
helm install releaseName bitnami/apache --set replicaCount=2

# uninstall release
helm uninstall my-release
helm search repo package
helm pull --untar bitnami/wordpress
ls wordpress
# install package
helm install release-4 ./wordpress

e.g:
helm repo add bitnami https://charts.bitnami.com/bitnami
helm search repo joomla
# download repository
helm pull chatrepo/chartname

# Download the bitnami apache package
helm pull --untar bitnami/apache

# upgrade release
helm upgrade releaseName bitnami/nginx
helm upgrade releaseName bitnami/nginx -n mercury

# to delete relase.
# list release 
helm ls
helm uninstall release

## set replica count to a new release
helm install new-bitnami-apace-relase bitnami/apache --set replicaCount=2

or for image

--set image.debug=true
```