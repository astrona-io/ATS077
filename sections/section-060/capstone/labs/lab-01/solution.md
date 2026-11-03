# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-060/capstone/labs/lab-01
```

`astrona submit` right after the start shows one check that already passes: `workloads-running`.

## Step 1: Identities

Save this as `identities.yaml`:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ci-build
  namespace: ci
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: deploy-staging
  namespace: ci
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: deploy-production
  namespace: ci
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pipeline-build
  namespace: ci
rules:
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["get", "list", "create", "update", "patch"]
  - apiGroups: ["batch"]
    resources: ["jobs"]
    verbs: ["get", "list", "create"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: pipeline-build
  namespace: ci
subjects:
  - kind: ServiceAccount
    name: ci-build
    namespace: ci
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: pipeline-build
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: deployer
  namespace: staging
rules:
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "list", "patch", "update"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: deployer
  namespace: staging
subjects:
  - kind: ServiceAccount
    name: deploy-staging
    namespace: ci
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: deployer
---
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
```

Apply it and test the boundaries:

```sh
kubectl apply -f identities.yaml
kubectl auth can-i patch deployments.apps -n production --as=system:serviceaccount:ci:deploy-production
kubectl auth can-i patch deployments.apps -n staging --as=system:serviceaccount:ci:deploy-production
kubectl auth can-i patch deployments.apps -n production --as=system:serviceaccount:ci:ci-build
```

The answers are `yes`, `no` and `no`. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-060/capstone/labs/lab-01 --keep
```

`pipeline-identities` passes. `release-promotion` and `release-record` still fail.

## Step 2: Release r2

Staging goes first, and production follows after staging is healthy:

```sh
kubectl -n staging patch deployment scout --type=merge -p '{"spec":{"template":{"metadata":{"labels":{"release":"r2"}}}}}'
kubectl -n staging rollout status deployment/scout --timeout=120s
kubectl -n production patch deployment scout --type=merge -p '{"metadata":{"annotations":{"kubernetes.io/change-cause":"release r2"}},"spec":{"template":{"metadata":{"labels":{"release":"r2"}}}}}'
kubectl -n production rollout status deployment/scout --timeout=120s
kubectl -n production rollout history deployment/scout
```

Each patch prints `deployment.apps/scout patched`, and each rollout ends with `successfully rolled out`. The history of production lists revisions `1` and `2`, and the change cause of revision 2 is `release r2`. The template changed, so each Deployment replaced its pod. The image was not touched, so both environments run the same artifact.

## Step 3: The release record

```sh
IMAGE=$(kubectl -n production get deployment scout -o jsonpath='{.spec.template.spec.containers[0].image}')
REV=$(kubectl -n production get deployment scout -o jsonpath='{.metadata.annotations.deployment\.kubernetes\.io/revision}')
kubectl -n ci create configmap release-record --from-literal=revision=r2 --from-literal=image=$IMAGE --from-literal=deployed-revision=$REV --from-literal=previous-revision=$((REV - 1))
kubectl -n ci get configmap release-record -o jsonpath='{.data}{"\n"}'
```

The last command prints an object with `deployed-revision` `2`, `image` the podinfo image, `previous-revision` `1` and `revision` `r2`. Grade the whole task:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-060/capstone/labs/lab-01
```

All four checks pass. Remove the lab when you are done:

```sh
astrona destroy ats-077-capstone-060
```

## Why it works

Each stage runs as its own identity, and a Role in one namespace gives rights only there, so a leaked build credential cannot change a Deployment and a leaked staging credential cannot reach production. The label in the pod template makes a new rollout revision and the annotation stores the reason in the history. The image stays the same, so the release changes what runs without changing the artifact. The record is derived from the cluster, and its `previous-revision` is the revision a rollback would return to.
