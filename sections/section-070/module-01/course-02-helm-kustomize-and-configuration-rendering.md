---
draft: true
exam_objectives:
- Continuous Delivery and GitOps
---
# Helm, Kustomize And Configuration Rendering

The `scout` application needs similar Kubernetes resources in `staging` and `production`, with different replica counts and image tags. Configuration tools reduce repeated manual editing, but they use different methods. The rendered resources are still subject to API validation and normal controller behavior.

Helm packages related resources in a chart. Templates and values produce Kubernetes manifests, and Helm tracks releases for installation and updates. A chart can express many configuration choices, but template complexity can hide the actual resource changes if reviewers only inspect a values file.

Kustomize starts from resource files and composes or patches them through bases and overlays. An overlay can adjust an image or replica count for one environment without rewriting the base. It does not use the same general templating model as Helm, though both can appear in a delivery workflow.

Rendering is the transformation from tool inputs to the final resource declarations. Review those outputs to confirm names, namespaces, image identities, labels and permissions. A correct-looking source value can still render a selector mismatch or an unintended privilege.

Neither tool automatically supplies continuous reconciliation. A GitOps controller may render Helm or Kustomize inputs and then reconcile the result, but the packaging or customization tool alone is a different part of the workflow. Likewise, neither output guarantees application readiness.

## The environment

The playground repository `starfleet/scout-deploy` uses Kustomize. It has a `base` directory and two overlays, `staging` and `production`. A Gitea server in the cluster hosts it, and Argo CD renders the same overlays when it syncs.

<!-- astrona:playground:renew -->

Reach the Git server through a port-forward and clone the repository. Run the port-forward in the background:

```sh
kubectl -n gitea port-forward svc/gitea-http 3000:3000 >/dev/null 2>&1 &
sleep 3
git clone http://platform:starfleet-gitops@127.0.0.1:3000/starfleet/scout-deploy.git
cd scout-deploy
ls base overlays
```

The listing shows the base files `deployment.yaml`, `kustomization.yaml` and `service.yaml`, plus the directories `overlays/production` and `overlays/staging`.

## Read the inputs

The base holds the shared resources. An overlay points at the base and changes selected fields:

```sh
cat base/kustomization.yaml
cat overlays/staging/kustomization.yaml
cat overlays/production/kustomization.yaml
```

The base lists its resources. Each overlay sets a namespace, an image tag and a replica count. The staging overlay uses tag `6.15.0` and one replica. The production overlay uses tag `6.14.0` and two replicas. Production is one version behind on purpose.

## Render the outputs

Kustomize is built into `kubectl`. Rendering writes the final resources to the screen and changes nothing in the cluster:

```sh
kubectl kustomize overlays/staging
```

The output shows a Service and a Deployment with `namespace: staging`, `replicas: 1` and the image `ghcr.io/stefanprodan/podinfo:6.15.0`. Read the selector and the pod labels next to each other. They must match, or the Deployment would be rejected or would own no pods.

## Diff two environments

A diff of the two rendered outputs shows what truly differs:

```sh
diff <(kubectl kustomize overlays/staging) <(kubectl kustomize overlays/production)
```

The diff lists lines for the namespace, the replica count, the image tag and the message value. Everything else is shared. A reviewer can read a few lines instead of two full manifests, and that is the gain of rendering before approving.

## Helm in the same workflow

Helm produces the same kind of output from a chart and a values file, and the command is `helm template <release> <chart> -f values.yaml`. This playground does not install Helm, so the rest of this part stays with Kustomize. The review habit is identical. Render first, read the Deployment that comes out, and confirm names, namespaces and images, not only the changed value. Argo CD can render a chart or an overlay itself, so the controller consumes either and reconciles the output.

## Choosing and reviewing

Choose Helm when a parameterized package and release workflow suit the use case. Choose Kustomize when resource composition and environment overlays fit better. Decide from maintainability and review needs rather than assuming every deployment requires both. A base change affects every overlay, and an overlay patch can break when the base structure changes, so composition reduces duplication but does not remove review. Names and namespaces must stay consistent across references, because a generated set can be valid while containing a reference that points at nothing.

Stop the port-forward when you finish:

```sh
cd ..
kill %1
```

## What you know now

Kustomize builds a base plus an overlay into final resources, and `kubectl kustomize` shows them without applying. A diff between environments shows the real differences. Helm and Kustomize produce configuration, and the controller reconciles it.

## Common pitfalls

> [!WARNING]
> Helm and Kustomize produce configuration. Neither provides continuous GitOps reconciliation.
> Review rendered resources, not only the inputs that generate them.
> A base change affects every overlay. Render each overlay after editing the base.
