# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-040/capstone/labs/lab-01
```

`astrona submit` right after the start shows one check that already passes: `workloads-running`.

## Step 1: The replica cap

Save this as `replica-cap.yaml`:

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicy
metadata:
  name: starfleet-replica-cap
spec:
  failurePolicy: Fail
  matchConstraints:
    resourceRules:
      - apiGroups: ["apps"]
        apiVersions: ["v1"]
        operations: ["CREATE", "UPDATE"]
        resources: ["deployments"]
  validations:
    - expression: "object.spec.replicas <= 3"
      message: "a Deployment may have at most 3 replicas"
---
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicyBinding
metadata:
  name: starfleet-replica-cap-binding
spec:
  policyName: starfleet-replica-cap
  validationActions: ["Deny"]
  matchResources:
    namespaceSelector:
      matchLabels:
        platform: managed
```

Apply it and label the namespace:

```sh
kubectl apply -f replica-cap.yaml
kubectl label namespace starfleet platform=managed
```

Then check. A new policy needs a few seconds before it is enforced, so repeat the first command if it is accepted:

```sh
kubectl -n starfleet create deployment extra --image=curlimages/curl:8.22.0 --replicas=4 --dry-run=server
kubectl -n outpost create deployment extra --image=curlimages/curl:8.22.0 --replicas=4 --dry-run=server
```

The first command is denied by `ValidatingAdmissionPolicy 'starfleet-replica-cap'` with the message from the policy. The second prints `deployment.apps/extra created (server dry run)`. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-040/capstone/labs/lab-01 --keep
```

The check `replica-cap-policy` passes.

## Step 2: Access for the team

Save this as `team-submit.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: apprequest-submitter
rules:
  - apiGroups: ["platform.starfleet.io"]
    resources: ["apprequests"]
    verbs: ["create", "get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: drifter-team-submit
  namespace: outpost
subjects:
  - kind: Group
    name: drifter-team
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: apprequest-submitter
  apiGroup: rbac.authorization.k8s.io
```

Apply it:

```sh
kubectl apply -f team-submit.yaml
```

Then check:

```sh
kubectl auth can-i create apprequests.platform.starfleet.io -n outpost --as=casey --as-group=drifter-team
kubectl auth can-i create apprequests.platform.starfleet.io -n starfleet --as=casey --as-group=drifter-team
```

The answers are `yes` and `no`. The RoleBinding makes the ClusterRole valid in `outpost` only.

## Step 3: Access for the controller

Save this as `controller-access.yaml`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: apprequest-controller
rules:
  - apiGroups: ["platform.starfleet.io"]
    resources: ["apprequests"]
    verbs: ["get", "list", "watch"]
  - apiGroups: ["platform.starfleet.io"]
    resources: ["apprequests/status"]
    verbs: ["update", "patch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: apprequest-controller
subjects:
  - kind: ServiceAccount
    name: apprequest-controller
    namespace: starfleet
roleRef:
  kind: ClusterRole
  name: apprequest-controller
  apiGroup: rbac.authorization.k8s.io
```

Apply it:

```sh
kubectl apply -f controller-access.yaml
```

Then check:

```sh
kubectl auth can-i update apprequests.platform.starfleet.io --subresource=status -n outpost --as=system:serviceaccount:starfleet:apprequest-controller
kubectl auth can-i create apprequests.platform.starfleet.io -n outpost --as=system:serviceaccount:starfleet:apprequest-controller
```

The answers are `yes` and `no`. Grade the whole task:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-040/capstone/labs/lab-01
```

All four checks pass. Remove the lab when you are done:

```sh
astrona destroy ats-077-capstone-040
```

## Why it works

The policy runs in the API server for the namespaces that the binding selects, and `failurePolicy: Fail` makes the guardrail reject requests when it cannot be evaluated, so it cannot be bypassed by an outage. The status is a subresource with its own permission, so the team that asks can read the answer but cannot write it, and the controller that reports can write the status but cannot create or delete requests.
