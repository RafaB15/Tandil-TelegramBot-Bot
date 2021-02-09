Infra creation
==============

```
kubectl create namespace <NAMESPACE>

kubectl apply -f configmap.yaml

kubectl apply -f secret.yaml

kubectl apply -f deployment.yaml
```


Otros comandos útiles
=====================

```
# sync minikube and host clocks
minikube ssh -- docker run -i --rm --privileged --pid=host debian nsenter -t 1 -m -u -n -i date -u $(date -u +%m%d%H%M%Y)

# log into container
kubectl exec <pod_name> -c <container_name> --stdin --tty /bin/bash

```
