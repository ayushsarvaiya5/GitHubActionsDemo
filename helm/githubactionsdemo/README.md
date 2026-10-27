# GitHubActionsDemo Helm Chart

Generalized Helm chart for deploying the GitHubActionsDemo ASP.NET Core app
across `development`, `staging`, and `production` environments.

## Resources created

- `Namespace` (optional, per-environment, via `namespace.create`)
- `ServiceAccount`
- `ConfigMap` (non-sensitive config, e.g. `ASPNETCORE_ENVIRONMENT`, logging)
- `Secret` (sensitive config, e.g. connection strings)
- `Deployment` (manages Pods/ReplicaSets, with readiness/liveness probes)
- `Service` (ClusterIP by default)
- `Ingress` (optional, per-environment hosts/TLS)
- `PersistentVolumeClaim` / `PersistentVolume` (optional, disabled by default — app is stateless)
- `HorizontalPodAutoscaler` (optional)
- `PodDisruptionBudget` (optional, enabled in production)

## Usage

```bash
# Lint and render for review
helm lint ./helm/githubactionsdemo
helm template githubactionsdemo ./helm/githubactionsdemo -f ./helm/githubactionsdemo/values-development.yaml

# Install / upgrade per environment
helm upgrade --install githubactionsdemo-dev ./helm/githubactionsdemo \
  -f ./helm/githubactionsdemo/values-development.yaml \
  --namespace githubactionsdemo-dev --create-namespace

helm upgrade --install githubactionsdemo-staging ./helm/githubactionsdemo \
  -f ./helm/githubactionsdemo/values-staging.yaml \
  --namespace githubactionsdemo-staging --create-namespace

helm upgrade --install githubactionsdemo-prod ./helm/githubactionsdemo \
  -f ./helm/githubactionsdemo/values-production.yaml \
  --namespace githubactionsdemo-prod --create-namespace \
  --set image.tag=5.0.0
```

## Overriding secrets safely

Never commit real secret values. Pass them at deploy time instead:

```bash
helm upgrade --install githubactionsdemo-prod ./helm/githubactionsdemo \
  -f ./helm/githubactionsdemo/values-production.yaml \
  --set-string secret.data.ConnectionStrings__Default="$DB_CONNECTION_STRING"
```

See [values.yaml](values.yaml) for all configurable options.

## Blue-Green deployments

Set `blueGreen.enabled: true` to render two full Deployments (`<release>-blue`
and `<release>-green`) instead of the single stable Deployment. The Service
only routes to whichever slot matches `blueGreen.activeSlot`, so you can
pre-warm the idle slot on a new image, verify it, then cut traffic over
instantly:

```bash
# Deploy/update the idle "green" slot with the new image
helm upgrade githubactionsdemo ./helm/githubactionsdemo --reuse-values \
  --set blueGreen.enabled=true \
  --set blueGreen.green.image.tag=5.1.0

# Verify green (e.g. kubectl port-forward to the -green Deployment's pods),
# then cut traffic over:
helm upgrade githubactionsdemo ./helm/githubactionsdemo --reuse-values \
  --set blueGreen.activeSlot=green

# Roll back instantly if needed:
helm upgrade githubactionsdemo ./helm/githubactionsdemo --reuse-values \
  --set blueGreen.activeSlot=blue
```

## Canary deployments

Set `canary.enabled: true` to render a small extra Deployment
(`<release>-canary`) alongside the stable one. The Service has no track
selector, so Kubernetes load-balances across stable + canary pods
proportionally to replica counts:

```bash
# ~10% of traffic to canary (9 stable + 1 canary replica)
helm upgrade githubactionsdemo ./helm/githubactionsdemo --reuse-values \
  --set canary.enabled=true \
  --set canary.image.tag=5.1.0 \
  --set replicaCount=9 \
  --set canary.replicaCount=1

# Promote: bump the stable image.tag to the canary's version, then disable canary
helm upgrade githubactionsdemo ./helm/githubactionsdemo --reuse-values \
  --set image.tag=5.1.0 \
  --set canary.enabled=false
```

Canary is ignored while `blueGreen.enabled` is true (the two strategies are
mutually exclusive in this chart).

## Fully automated pipeline (canary → blue-green promotion)

[push-docker-image-publish.yml](../../.github/workflows/push-docker-image-publish.yml)
automates this end-to-end whenever a new version is released (merge to `main`
that triggers release-please + a new Docker image):

1. **`canary-deploy`** — progressively shifts traffic in stages
   (10% → 20% → 30% → 40% → 50%), scaling the canary Deployment up and
   the stable Deployment down at each step. Between stages it waits for
   rollout, bakes, then checks: any canary pod restart, any canary pod
   not Ready, **or** canary pod logs containing more than
   `CANARY_MAX_ERROR_LOGS_PER_REPLICA × canary replica count` lines
   matching `CANARY_ERROR_LOG_PATTERN` (default: `error|exception|fatal|critical`,
   case-insensitive) during the bake window — the threshold scales with
   the stage's traffic share (strict at 10%, proportionally more tolerant
   at 50%) — any of these aborts the rollout before more traffic shifts,
   printing the last 50 matching log lines for diagnosis.
2. **`promote-bluegreen`** — only runs if every canary stage was healthy.
   Deploys the new version at full scale into the idle blue/green slot,
   applies the same restart/readiness/error-log checks (threshold scaled
   to `TOTAL_REPLICAS`), then flips the Service to that slot (instant
   cutover, i.e. the final 100% step) and disables the canary.
3. **`rollback-on-failure`** — only runs if either step above failed.
   Disables the canary and restores the original stable replica count /
   autoscaling, so production traffic keeps flowing to the last-known-good
   stable/active slot; no manual intervention needed.

Tune the error-log gate via workflow env vars `CANARY_MAX_ERROR_LOGS_PER_REPLICA`
and `CANARY_ERROR_LOG_PATTERN` in
[push-docker-image-publish.yml](../../.github/workflows/push-docker-image-publish.yml).

Prerequisite: add a `KUBE_CONFIG` repository secret containing a
base64-encoded kubeconfig with access to the target namespace
(`githubactionsdemo-prod` by default — adjust `NAMESPACE`/`RELEASE_NAME` in
the workflow env to match your cluster). `jq` must be available on the
runner (used to read the current `activeSlot` from the live Helm release).


