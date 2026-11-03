---
draft: true
exam_objectives:
- Platform Architecture and Capabilities
---
# Guardrails, Failure Domains And Ownership

A platform interface also needs rules about what may be requested, and it needs a clear answer to the question of what stops working when a part fails. This part builds a policy with the Common Expression Language that runs inside the API server, separates the rights of users from the rights of the platform's own controller, and walks through the failure domains of the layers of a platform.

## A policy inside the API server

A ValidatingAdmissionPolicy is an object that holds CEL expressions. The API server evaluates them for matching requests after authorization and before the object is stored. It needs no extra component to run, because the evaluation happens in the API server itself. A policy has two objects: the policy, which states what to check, and a binding, which states where the policy applies and what happens on a violation.

The platform rule in this example is that no Deployment in a managed namespace has more than two replicas. Save this as `replica-cap.yaml`:

```yaml
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicy
metadata:
  name: outpost-replica-cap
spec:
  failurePolicy: Fail
  matchConstraints:
    resourceRules:
      - apiGroups: ["apps"]
        apiVersions: ["v1"]
        operations: ["CREATE", "UPDATE"]
        resources: ["deployments"]
  validations:
    - expression: "object.spec.replicas <= 2"
      message: "a Deployment may have at most 2 replicas"
---
apiVersion: admissionregistration.k8s.io/v1
kind: ValidatingAdmissionPolicyBinding
metadata:
  name: outpost-replica-cap-binding
spec:
  policyName: outpost-replica-cap
  validationActions: ["Deny"]
  matchResources:
    namespaceSelector:
      matchLabels:
        platform: managed
```

The policy matches create and update requests for Deployments. The binding applies it to namespaces with the label `platform=managed` and denies violations. A policy without a binding has no effect. Apply both and mark `outpost` as managed:

<!-- astrona:playground:renew -->

```sh
kubectl apply -f replica-cap.yaml
kubectl label namespace outpost platform=managed
```

The first command prints one `created` line for each object. The second prints `namespace/outpost labeled`. A new policy needs a few seconds before the API server enforces it. Then check:

```sh
kubectl -n outpost create deployment extra --image=curlimages/curl:8.22.0 --replicas=3 --dry-run=server
kubectl -n starfleet create deployment extra --image=curlimages/curl:8.22.0 --replicas=3 --dry-run=server
```

The first command is denied with a message that starts with `ValidatingAdmissionPolicy 'outpost-replica-cap' with binding 'outpost-replica-cap-binding' denied request` and ends with the message from the policy. The second prints `deployment.apps/extra created (server dry run)`, because `starfleet` does not carry the label. The same rule is applied only where the binding selects.

## The rule matches what it lists

A policy matches the resources in its rule and nothing else. This rule lists `deployments`. A scale request goes to the `deployments/scale` subresource, which the rule does not list, so a scale command can pass a rule that checks replicas on creation. To cover scaling, add `deployments/scale` to the resources. The Scale object also has `spec.replicas`, so the same expression works. A guardrail has to be tested through every way that a user can reach the same field.

## Identity: who may ask, and who may report

The second boundary is RBAC. Consider a platform API where users submit requests as custom resources of the kind `AppRequest` in the group `platform.starfleet.io`, and a controller reports their status. These are two identities with different rights. A ClusterRole is a list of rules without a namespace, and a RoleBinding grants it inside one namespace. Create a role for the team and bind it in one namespace:

```sh
kubectl create clusterrole apprequest-submitter --verb=create,get,list,watch --resource=apprequests.platform.starfleet.io
kubectl -n outpost create rolebinding drifter-team-submit --clusterrole=apprequest-submitter --group=drifter-team
```

Both commands print `created`. A role may name a resource whose definition does not exist yet, so the commands succeed in any case, and the checks below are answered from the role alone. Check the team's rights:

```sh
kubectl auth can-i create apprequests.platform.starfleet.io -n outpost --as=casey --as-group=drifter-team
kubectl auth can-i create apprequests.platform.starfleet.io -n starfleet --as=casey --as-group=drifter-team
kubectl auth can-i update apprequests.platform.starfleet.io --subresource=status -n outpost --as=casey --as-group=drifter-team
```

The answers are `yes`, `no` and `no`. The team may submit in its own namespace, may not submit in another one and may not write the status. Status is the platform's report, so a user who could write it could declare their own request accepted.

## Failure domains

A failure domain is the set of things that stop working together. Reason about each layer:

- If the API server or etcd is unavailable, no one can create or change objects. Pods that already run keep running, because the kubelet works from its local copy of the pod specs, but nothing new is scheduled and no controller can act.
- If a controller stops, objects are still stored and validated, but nothing reacts to them. The status stops changing, which is why status should carry a timestamp or a condition that shows when it was last updated.
- If a node fails, the pods on it are lost, and the controllers create replacements on other nodes when capacity allows.
- If an admission policy cannot be evaluated, the field `failurePolicy` decides. With `Fail`, the request is rejected, which is safe but blocks users. With `Ignore`, the request passes unchecked, which keeps users working but removes the guardrail.

The choice between the two is a decision about ownership and risk. The platform team states it for each policy, and it does not leave the default to chance. See how the control plane reports its own state:

```sh
kubectl get --raw '/livez?verbose' | tail -n 3
kubectl get validatingadmissionpolicy outpost-replica-cap -o jsonpath='{.spec.failurePolicy}{"\n"}'
```

The first command prints the last checks, ending with `livez check passed`. The second prints `Fail`.

## Ownership by layer

Each failure needs an owner who can fix it. The user owns the request and its content. The platform team owns the CRD, the controller, the policies and the roles. The infrastructure team, which can be the same people, owns the nodes. Status and events should say which layer refused or failed, so that the user can tell a schema error from an unavailable controller. A platform that returns one generic error for all of these sends every question to the platform team.

## What you know now

A ValidatingAdmissionPolicy and its binding enforce rules in the API server where the binding selects, and the rule matches only the resources it lists. RBAC separates the identity that submits a request from the identity that writes its status. Each layer has its own failure domain: pods keep running when the control plane is down, a stopped controller leaves requests unprocessed, and the failure policy of a guardrail chooses between safety and availability. Naming an owner for each layer makes failures actionable.

## Common pitfalls

> [!WARNING]
> A policy without a binding does nothing, and a binding with the wrong namespace selector does nothing for the namespace you meant.
> `failurePolicy: Ignore` lets requests through unchecked when the policy cannot run. Use it only when availability matters more than the rule.
> A rule that lists `deployments` does not cover the `deployments/scale` subresource.
