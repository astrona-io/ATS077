---
draft: true
exam_objectives:
- Continuous Integration Fundamentals
---
# Pipeline Identities, Release Records And Rollback

A pipeline touches source, artifacts and running environments, and each of those has a different level of risk. This part covers three controls that keep a pipeline defensible: separate identities for separate stages, a record that says what was released, and a way back when a release is wrong.

## Why stages need different identities

The build stage may need source access and permission to publish to one artifact repository. The production delivery stage may need to update a scoped set of workloads. Granting the build process unrestricted cluster access combines these trust boundaries without a reason. A compromised dependency or build step can then change the deployment environment directly.

In Kubernetes, a pipeline stage runs as a ServiceAccount, and a Role lists exactly what that account may do in one namespace. The permission check `kubectl auth can-i` asks the API server what an identity may do without changing anything, so a team can test its boundaries.

## Create a deploy identity for production

Create the namespaces, a ServiceAccount for the production stage, and a Role that allows only what a deployment needs:

<!-- astrona:playground:renew -->

```sh
for ns in ci staging production; do
  kubectl create namespace $ns --dry-run=client -o yaml | kubectl apply -f -
done
kubectl -n ci create serviceaccount deploy-production
kubectl apply -f - <<'YAML'
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: deployer
  namespace: production
rules:
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "list", "patch", "update"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: deployer
  namespace: production
subjects:
  - kind: ServiceAccount
    name: deploy-production
    namespace: ci
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: deployer
YAML
```

The commands print `serviceaccount/deploy-production created`, then `role.rbac.authorization.k8s.io/deployer created` and `rolebinding.rbac.authorization.k8s.io/deployer created`. The account lives in `ci` and has rights only in `production`, because the binding is in that namespace. Ask the API server what it may do:

```sh
SA=system:serviceaccount:ci:deploy-production
kubectl auth can-i patch deployments -n production --as=$SA
kubectl auth can-i patch deployments -n staging --as=$SA
kubectl auth can-i delete deployments -n production --as=$SA
kubectl auth can-i get secrets -n production --as=$SA
```

The answers are `yes`, `no`, `no` and `no`. The identity can update production Deployments and nothing else. If its credential leaks, the damage is limited to those verbs in that namespace. A second account for staging gets its own Role and binding, so that a staging pipeline can never touch production.

## A release record says what was released

An investigation after a failed release needs to know the revision, the artifact, the configuration and the time. The Deployment itself stores part of this. Create the Deployment that the production stage updates:

```sh
kubectl -n production apply -f - <<'YAML'
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
        release: r1
    spec:
      containers:
        - name: scout
          image: ghcr.io/stefanprodan/podinfo:6.15.0
          ports:
            - name: http
              containerPort: 9898
YAML
kubectl -n production rollout status deployment/scout --timeout=120s
```

Release r2 changes the pod template. Mark the change with a label, and write the reason as an annotation in the same patch, so that the rollout history shows it for the new revision:

```sh
kubectl -n production patch deployment scout --type=merge -p '{"metadata":{"annotations":{"kubernetes.io/change-cause":"release r2"}},"spec":{"template":{"metadata":{"labels":{"release":"r2"}}}}}'
kubectl -n production rollout status deployment/scout --timeout=120s
kubectl -n production rollout history deployment/scout
```

The history lists two revisions, `1` and `2`, and the `CHANGE-CAUSE` column shows `release r2` for the current one. The cause is stored on the Deployment object, so it is part of the cluster state. Read the revision number of the live Deployment:

```sh
kubectl -n production get deployment scout -o jsonpath='{.metadata.annotations.deployment\.kubernetes\.io/revision}{"\n"}'
```

The command prints `2`. A release record outside the Deployment, such as a ConfigMap in the `ci` namespace, holds the pipeline's view of the same release:

```sh
kubectl -n ci create configmap release-record --from-literal=revision=r2 --from-literal=image=ghcr.io/stefanprodan/podinfo:6.15.0 --from-literal=deployed-revision=2 --from-literal=previous-revision=1
```

The record names the previous revision, which is where to return to if r2 is wrong.

## Rollback is a decision, and it has limits

A rollback returns the pod template to an earlier revision:

```sh
kubectl -n production rollout undo deployment/scout --to-revision=1
kubectl -n production rollout status deployment/scout --timeout=120s
kubectl -n production get deployment scout -o jsonpath='{.spec.template.metadata.labels.release}{"\n"}'
```

The last command prints `r1`. The Deployment now uses the template of revision 1 and creates a new revision number for it, so the history does not go back in numbers. The old record that says `deployed-revision=2` no longer describes the cluster, so a rollback must also update the release record.

A rollback of the image does not reverse everything. Configuration, data migrations, feature flags and external side effects can survive it. A schema that a new version migrated forward may be unreadable to the old version. Keep secrets out of ordinary logs and limit credentials to the stages that use them. A short-lived deployment identity reduces exposure compared with a widely shared permanent credential, while repository protections control who can change the pipeline instructions.

Record a recovery plan for more than the image. A team that can explain how a qualifying change reaches users, how an unsuitable change is detected and how it is corrected has a pipeline it can defend.

## What you know now

Each stage runs as its own identity with the narrowest Role that lets it do its job, and `kubectl auth can-i` proves the boundary. The Deployment stores a revision number and a change cause, and a record outside it ties the release to the pipeline. A rollback restores the pod template, creates a new revision number and does not undo data or external effects.

## Common pitfalls

> [!WARNING]
> Giving the build identity cluster-wide rights lets one compromised step change every environment.
> A rollback creates a new revision number. Update the release record after it.
> An image rollback does not reverse migrations, flags or external side effects.
