## Overview
This repository contains files for conducting experiments related to the paper [**A Cost Model to Optimize Queries over Heterogeneous Federations of RDF Data Sources**](https://dmkg-workshop.github.io/papers/paper7042.pdf).

We have implemented the cost model introduced in the paper (as well as the baseline approach) in our query federation engine called [HeFQUIN](https://github.com/LiUSemWeb/HeFQUIN/).

For running the experiments we utilize [**KOBE**](https://github.com/semagrow/kobe/), a benchmarking system based on Kubernetes infrastructure, to containerize and configure federations of RDF datasets, queries, federation engines, and experiments. The typical workflow for defining a KOBE experiment includes the following steps:
1. **DatasetTemplate**: Create one for each dataset server used in your benchmark.
2. **Benchmark**: Define it with a list of datasets and queries.
3. **FederatorTemplate**: Create one for the federator engine used in your experiment.
4. **Experiment**: Define it over your previously defined benchmark.

## Installation

### Prerequisites
Before installing the KOBE benchmarking engine, ensure the following prerequisites are met:

- **kubectl**: Install using native package management. Detailed instructions for Linux can be found [here](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-using-native-package-management). The experiments in the paper use version v1.20.7. Verify the installation:
  ```bash
  kubectl version --client
  ```
- **nfs-common**: Install on the nodes of the cluster. For Debian or Ubuntu:
  ```bash
  apt-get install nfs-common
  ```
- **minikube**: Detailed installation instructions can be found [here](https://minikube.sigs.k8s.io/docs/start/?arch=%2Fmacos%2Fx86-64%2Fstable%2Fbinary+download).

### Starting the Cluster
Start your cluster using the following commands:
```bash
minikube start
kubectl get po -A
minikube dashboard
```
Open the Minikube dashboard locally by accessing the default port in your browser:
```
http://127.0.0.1:44393/api/v1/namespaces/kubernetes-dashboard/services/http:kubernetes-dashboard:/proxy/
```

If the cluster is started on a remote server, such as `ontology.ida.liu.se`, use SSH tunneling to access the dashboard.

### Install KOBE
A detailed instruction for installing KOBE can be found [here](https://semagrow.github.io/kobe/getting_started/install/). There are some notes for the installation.
1. When installing the Networking subsystem, you can consult the [official installation guide](https://istio.io/latest/docs/setup/getting-started/) or follow the steps below.
- To download 'istio' with specific verion, use the follwoing curl command:
```
    curl -L https://istio.io/downloadIstio | ISTIO_VERSION=1.11.3 TARGET_ARCH=x86_64 sh -
```
- Then, add the istioctl client to your path (Linux or macOS):
```
    export PATH=$PWD/istio-1.11.3/bin:$PATH
```
- Then, install Istio using the following command:
```
istioctl install --set profile=demo -y
```
2. Before installing the logging subsystem, 'helm' need to be installed. Note the current commend only works for helm2.
An instruction to install and set up helm2 and tiller can be found [here](https://v2.helm.sh/docs/install/)

After set up all required components, you can check status of all Pods via browswer, or via command:
```kubectl get pods```

### Conducting Experiments
First, make sure the cluster is running
```
minikube status
```
1. Deploy dataset servers: Virtuoso, TPF, and brTPF server
```bash
kobectl apply dataset/dataset-virtuoso/virtuosotemplate.yaml
kobectl apply dataset/dataset-ldfserver-hdt/ldfservertemplate-hdt.yaml
kobectl apply dataset/dataset-brtpfserver/brtpfservertemplate.yaml
```
For the TPF server and brTPF server, several docker images are used and corresponding source code for these images can be found in the corresponding directory. If any changes applied, these docker images need to be rebuilt using the following command:
- TPF server:
```
cd dataset/dataset-ldfserver-hdt
cd ldfserver-init-hdt
docker build --no-cache -t chengsijin817/ldfserver-init-hdt .
docker push chengsijin817/ldfserver-init-hdt
    
cd ../ldfserver-main-hdt
docker build --no-cache -t chengsijin817/ldfserver-main-hdt .
docker push chengsijin817/ldfserver-main-hdt
```
Note: '[chengsijin817/ldfserver-init-hdt](https://hub.docker.com/r/chengsijin817/ldfserver-init-hdt)' and '[chengsijin817/ldfserver-main-hdt](https://hub.docker.com/r/chengsijin817/ldfserver-main-hdt)' are image names, which can be renamed but should be the same as specified in ldfservertemplate-hdt.yaml file.

- brTPF server:
```
cd dataset/dataset-brtpfserver
cd brtpfserver-init
docker build --no-cache -t chengsijin817/brtpfserver-init .
docker push chengsijin817/brtpfserver-init
    
cd ../brtpfserver-main
docker build --no-cache -t chengsijin817/brtpfserver-main .
docker push chengsijin817/brtpfserver-main
```
Similarly, '[chengsijin817/brtpfserver-init](https://hub.docker.com/r/chengsijin817/brtpfserver-init)' and '[chengsijin817/brtpfserver-main](https://hub.docker.com/r/chengsijin817/brtpfserver-main)' are image names, which can be renamed but should be the same as specified in brtpfservertemplate.yaml file.

2. Deploy a benchmark, specifying all federation members and benchmark queries.
```
kobectl apply benchmark-fedbench/fedbench-het3-nodelay.yaml
kobectl show benchmark fedbench-het3-nodelay
```
Note: Queries should use correct URIs in SERVICE clause, depending on the type of interface of each federation member.
Two example federations are provided under directory 'benchmark-fedbench'.

3. Deploy HeFQUIN engine

Use one of the following commands to apply a implementation of HeFQUIN engine:
```
kobectl apply federator-hefquin/hefquin-mincost-greedy.yaml 
```
Or
```
kobectl apply federator-hefquin/hefquin-card-greedy.yaml 
```
For example, hefquin-mincost-greedy.yaml invokes a [docker image](https://hub.docker.com/r/chengsijin817/hefquin-mincost-greedy) of HeFQUIN engine, which implements cost-based greedy algorithm applied.

To integrate the HeFQUIN engine with the KOBE system, use the following Docker images: '[chengsijin817/hefquin-init](https://hub.docker.com/r/chengsijin817/hefquin-init)' and '[chengsijin817/hefquin-init-all](https://hub.docker.com/r/chengsijin817/hefquin-init-all)'. The source code for these images can be found in the repository directory. To rebuild these images after updates:
```bash
cd federator-hefquin/hefquin-init
docker build --no-cache -t chengsijin817/hefquin-init .
docker push chengsijin817/hefquin-init

cd ../hefquin-init-all
docker build --no-cache -t chengsijin817/hefquin-init-all .
docker push chengsijin817/hefquin-init-all
```
4. Deploy experiments based on the provided configuration files, fDepending on the algorithm and federation used, apply the appropriate experiment configuration:
```bash
kubectl apply -f experiment/fed3nodelay-mincostgreedy-exp.yaml
# or
kubectl apply -f experiment/fed4nodelay-mincostgreedy-exp.yaml
# or
kubectl apply -f experiment/fed3nodelay-cardgreedy-exp.yaml
# or
kubectl apply -f experiment/fed4nodelay-cardgreedy-exp.yaml
```

After completion, download the log file via the Minikube dashboard.

### Cleaning Up Before Next Experiment
To clean up all components:
```bash
kubectl delete experiments.kobe.semagrow.org --all
kubectl delete benchmarks.kobe.semagrow.org --all
kubectl delete federatortemplates.kobe.semagrow.org --all
kubectl delete datasettemplates.kobe.semagrow.org --all
kubectl delete pod kobenfs
```
Alternatively, remove specific components using the following command:
```bash
kubectl delete experiment het3nodelay-mincostgreedy-exp
kubectl delete federatortemplate hefquintemplate-mincost-greedy
```

## Stopping the Cluster
To stop the cluster:
```bash
minikube status
minikube stop
minikube delete
```
Note: Previous experiment results will be lost upon restarting Minikube.
