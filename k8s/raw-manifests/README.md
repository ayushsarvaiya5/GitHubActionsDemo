# Raw Kubernetes Manifests (Reference)

These are **standalone, educational** manifests showing each core Kubernetes
resource type individually, without Helm templating. For actual
deployments, use the Helm chart in [helm/githubactionsdemo](../../helm/githubactionsdemo)
instead — it generalizes these same resources across `development`,
`staging`, and `production` environments.

| File | Resource |
|---|---|
| [namespace.yaml](namespace.yaml) | `Namespace` |
| [configmap.yaml](configmap.yaml) | `ConfigMap` |
| [secret.yaml](secret.yaml) | `Secret` |
| [pod.yaml](pod.yaml) | `Pod` |
| [replicaset.yaml](replicaset.yaml) | `ReplicaSet` |
| [deployment.yaml](deployment.yaml) | `Deployment` |
| [service.yaml](service.yaml) | `Service` |
| [ingress.yaml](ingress.yaml) | `Ingress` |
| [persistentvolume.yaml](persistentvolume.yaml) | `PersistentVolume` |
| [persistentvolumeclaim.yaml](persistentvolumeclaim.yaml) | `PersistentVolumeClaim` |

Apply them directly (for learning/testing only):

```bash
kubectl apply -f k8s/raw-manifests/namespace.yaml
kubectl apply -f k8s/raw-manifests/ -n githubactionsdemo
```
