---
draft: true
exam_objectives:
- Continuous Integration Fundamentals
---
# Delivery, Deployment And Promotion Decisions

The `scout` pipeline produces a release-ready artifact after checks. Continuous delivery keeps software in a state that can be released through a controlled decision. Continuous deployment automatically deploys qualifying changes without a separate manual release approval. Both can use the same build and test foundation.

The abbreviation CD is used for both practices, so the decision gate matters more than the abbreviation. A pipeline that waits for a human to approve production promotion can still support continuous delivery. A pipeline that promotes every passing change automatically implements continuous deployment if its other requirements are met.

Deployment changes what runs in an environment. Release can also mean making behavior available to users. A feature flag can let deployed code remain inactive until an explicit decision enables it. This separation can reduce some release risks, but old and new behavior must still be tested and compatible.

## Promote one artifact through two environments

Promotion means that the artifact which passed the checks is the one that runs in the next environment. The environment supplies its own configuration. In a cluster, each environment is a namespace with a Deployment that names the same image, and a ConfigMap with the values that differ.

<!-- astrona:playground:renew -->

Create both environments from one image reference. The shell variable is the single source of the artifact, so both Deployments cannot drift apart by a typing mistake:

```sh
IMAGE=ghcr.io/stefanprodan/podinfo:6.15.0
for env in staging production; do
  kubectl create namespace $env --dry-run=client -o yaml | kubectl apply -f -
  kubectl -n $env create configmap app-config --from-literal=PODINFO_UI_MESSAGE=$env --dry-run=client -o yaml | kubectl apply -f -
  kubectl -n $env apply -f - <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scout
spec:
  replicas: 1
  selector:
    matchLabels:
      app: scout
  template:
    metadata:
      labels:
        app: scout
    spec:
      containers:
        - name: scout
          image: $IMAGE
          ports:
            - name: http
              containerPort: 9898
          envFrom:
            - configMapRef:
                name: app-config
YAML
done
kubectl -n staging rollout status deployment/scout --timeout=120s
kubectl -n production rollout status deployment/scout --timeout=120s
```

Each loop pass prints one line for the namespace, the ConfigMap and the Deployment, and both rollouts end with `successfully rolled out`. Compare what is the same and what is different:

```sh
kubectl get deployments -A -l app=scout -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.spec.template.spec.containers[0].image}{"\n"}{end}'
kubectl get configmaps -A --field-selector metadata.name=app-config -o jsonpath='{range .items[*]}{.metadata.namespace}{"\t"}{.data.PODINFO_UI_MESSAGE}{"\n"}{end}'
```

The first command lists `starfleet`, `staging` and `production`, and the image of each is `ghcr.io/stefanprodan/podinfo:6.15.0`. The second lists `staging` with the value `staging` and `production` with the value `production`. The artifact is identical and the configuration differs. If production misbehaves while staging does not, the difference to investigate is the configuration, and not an unknown rebuild.

## A release gate is a decision with evidence

The simplest gate is a condition that the pipeline reads before it promotes. A person or an automated check sets it. Create a gate in staging that starts closed:

```sh
kubectl -n staging create configmap release-gate --from-literal=approved=false
promote() {
  approved=$(kubectl -n staging get configmap release-gate -o jsonpath='{.data.approved}')
  if [ "$approved" = "true" ]; then echo "promote"; else echo "blocked"; fi
}
promote
```

The function prints `blocked`. A pipeline with this step waits for a decision, which is the shape of continuous delivery. Open the gate and run it again:

```sh
kubectl -n staging patch configmap release-gate --type=merge -p '{"data":{"approved":"true"}}'
promote
```

The function now prints `promote`. If the pipeline did not read the gate and always promoted, the production decision would be automatic, which is the shape of continuous deployment. Neither is better in general. The gate is only useful when the person or check that opens it has real evidence, such as the result of the staging checks.

## Locating the release decision

Consider a pipeline with automatic compilation, testing and staging deployment, followed by a manual production approval. It keeps the change ready for release and supports continuous delivery. Removing the final approval and automatically promoting every qualifying change changes the production decision to continuous deployment. Automated testing by itself does not distinguish them.

A team can also deploy dormant functionality controlled by a feature flag. The application bytes reach production before the feature becomes available to users. The flag needs ownership, monitoring and cleanup so old inactive branches do not become permanent hidden complexity. Switching a flag can also have compatibility and security consequences even without rebuilding an image.

Release gates should match the risk. A manual approval is useful only when the approver has meaningful evidence and authority. An automated gate is useful only when its checks reflect the required behavior. Neither a person clicking a button nor a green icon alone establishes that the release is safe.

## Configuration changes are releases too

Change the production message and watch the Deployment:

```sh
kubectl -n production patch configmap app-config --type=merge -p '{"data":{"PODINFO_UI_MESSAGE":"production v2"}}'
kubectl -n production get deployment scout -o jsonpath='{.spec.template.spec.containers[0].image}{"\n"}'
```

The image is unchanged. A running pod reads an environment variable from a ConfigMap only when it starts, so the new value does not reach the pod until it restarts. The configuration object changed and the running behavior did not. A release record must include the configuration change and the point at which it took effect, because the image alone does not describe what runs.

## What you know now

Promotion keeps the same artifact and varies the configuration per environment, and the comparison of the two shows what differs. A gate that the pipeline reads before it promotes is continuous delivery, and removing it is continuous deployment. A configuration change is a release and needs a record, even when the image is unchanged.

## Common pitfalls

> [!WARNING]
> Deployment and user-visible release can happen at different times. An image rollback does not automatically reverse database migrations or external effects.
> A gate that nobody reads, or that opens without evidence, is a ceremony and not a control.
> A changed ConfigMap does not change running pods that already read it.
