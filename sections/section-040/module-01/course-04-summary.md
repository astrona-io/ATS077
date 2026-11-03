---
draft: true
exam_objectives:
- Platform Architecture and Capabilities
---
# Summary

A platform separates a capability, the interface that exposes it and the implementation behind it. The developer interface is the set of objects and commands that users work with. The control plane stores the desired state and keeps making it true, and the infrastructure runs the work. A request travels down through the layers, and status travels back up through conditions and events. A supported interface keeps the meaning of a request when the implementation below it changes. A Service keeps its name and port while controllers and the network plugin change the addresses behind it.

A custom resource lets a platform team add its own kind of object to the API. A CustomResourceDefinition names the group, the kind and the scope, and carries a schema. The API server validates every object against the schema, including enums, number bounds and rules written in the Common Expression Language, and it answers a bad request with a specific message. A `status` subresource keeps the user's declaration apart from the platform's report, with its own permission. A CRD stores and validates objects and does nothing else. Behavior comes from a controller that watches the objects, and without one the objects only sit in the API server.

Guardrails apply the platform's rules to every request. A ValidatingAdmissionPolicy holds CEL expressions that the API server evaluates before it stores an object, and a binding states the namespaces where the policy applies and whether a violation is denied, warned or audited. A policy matches only the resources it lists, so scaling through a subresource needs its own entry. RBAC completes the boundary: the team may create requests in its namespace, and only the controller's identity may write their status.

A failure domain is the set of things that fail together. When the control plane is unavailable, running pods continue, and no change can be made. When a controller stops, requests are accepted and not processed. When a node fails, controllers replace its pods when capacity allows. When a policy cannot be evaluated, its failure policy chooses between rejecting requests and letting them pass unchecked. Each layer needs an owner, and status should say which layer refused or failed.

Key facts:

- The interface, the control plane and the infrastructure are separate layers with separate owners.
- A CRD is an API definition. It does not create workloads without a controller.
- Schema and CEL validation reject a request before a controller sees it.
- A policy needs a binding, and it matches only the resources in its rule.
- Pods that run keep running when the API server is down, but nothing new is scheduled.

<!-- astrona:playground:destroy -->
