---
draft: true
exam_objectives:
- Platform Architecture and Capabilities
---
# Capability Layers, Control Planes And Supported Interfaces

A platform architecture connects user-facing capability contracts to the systems that implement them. Developers can request deployment, databases, identities or observation through a portal, API or command interface. Behind those interfaces, controllers, workflow systems and providers perform the actual work. The platform's value comes from a coherent supported experience, not from replacing every underlying implementation.

Capability boundaries describe what users can request and what outcomes they can observe. A database capability might accept a service class and retention choice, then expose connection information and readiness. The user should not need to understand every provider API call. The contract still needs enough detail to explain supported choices, ownership and failure conditions.

Control planes interpret intent and coordinate implementation. A Kubernetes operator, infrastructure controller or workflow engine can participate in that layer. Providers create the underlying resources. These layers can have different timing and failure behavior. An API accepting a request does not mean the external database is already usable, so status must preserve the transition from accepted to pending, ready or failed.

Consider a self-service service template. The portal collects inputs and submits an approved workflow. The workflow creates source artifacts and requests infrastructure through APIs. Reconciliation then maintains the declared environment. If provisioning is denied, the portal should show the relevant condition rather than claim success because its form submission completed. The user sees one task, but several contracts contribute to the result.

Shared capabilities need explicit ownership. The platform team can own the interface and supported integration while another internal team or managed provider operates the underlying service. This division should be visible in incident and support paths. Without it, each team can assume the other owns the failure and users remain blocked.

Composability lets applications consume capabilities independently where practical. A team may use the platform's deployment path while keeping a specialized data service outside it under an approved contract. Forcing every workload into one oversized template can make adoption harder and create unnecessary coupling. Supported extension and exception paths can preserve governance without making the platform an obstacle to every uncommon need.

Failure domains deserve review. A central control service can simplify operation while concentrating dependency and access. Separate controllers can isolate some failures while increasing coordination work. The architecture should identify which capabilities become unavailable when a component fails and whether already running applications continue. Control-plane availability and application runtime availability are related but not identical.

Interfaces need lifecycle and version policy. A field rename in a platform API can break automation even when the underlying provider remains healthy. Defaults should be stable or changed through a deliberate migration. The platform should avoid exposing provider-specific implementation details as permanent public contracts unless it intends to support them over time.

Observability belongs across the layers. Useful evidence connects a user request to its declared object, controller result and provider outcome. Error messages should identify the failing boundary and protect confidential values. A portal dashboard with only one green availability icon cannot explain whether provisioning, policy or deployment is blocked.

Architecture review should therefore ask what users can request, who implements it, which identity acts and what outcome proves completion. That reasoning supports a platform that is both simpler to consume and honest about its dependencies. Students can use the same questions to assess unfamiliar platform products and internal designs.

## Common pitfalls

> [!WARNING]
> A portal is an interface, not the whole implementation. Accepted requests are not necessarily ready capabilities. Define ownership, API lifecycle and failure domains so abstraction reduces complexity without concealing actionable status.
