---
draft: true
exam_objectives:
- Continuous Delivery and GitOps
---
# Helm, Kustomize And Configuration Rendering

The `scout` application needs similar Kubernetes resources in development and production, with different replica counts. Configuration tools reduce repeated manual editing, but they use different methods. The rendered resources are still subject to API validation and normal controller behavior.

Helm packages related resources in a chart. Templates and values produce Kubernetes manifests, and Helm tracks releases for installation and updates. A chart can express many configuration choices, but template complexity can hide the actual resource changes if reviewers only inspect a values file.

Kustomize starts from resource files and composes or patches them through bases and overlays. An overlay can adjust an image or replica count for one environment without rewriting the base. It does not use the same general templating model as Helm, though both can appear in a delivery workflow.

Rendering is the transformation from tool inputs to the final resource declarations. Review those outputs to confirm names, namespaces, image identities, labels and permissions. A correct-looking source value can still render a selector mismatch or an unintended privilege.

Neither tool automatically supplies continuous reconciliation. A GitOps controller may render Helm or Kustomize inputs and then reconcile the result, but the packaging or customization tool alone is a different part of the workflow. Likewise, neither output guarantees application readiness.

Choose Helm when a parameterized package and release workflow suit the use case. Choose Kustomize when resource composition and environment overlays fit better. Decide from maintainability and review needs rather than assuming every deployment requires both. Whatever the tool, the final manifest should express the intended state clearly enough to inspect.

## Reviewing Rendered Resources

Suppose a Helm value changes the application image and replica count. A chart template uses those values to produce a Deployment. The rendered result can also contain labels, selectors, mounts and permissions defined elsewhere in the chart. Reviewing only the two changed values can miss an unintended interaction in the generated resources.

With Kustomize, a production overlay can change replicas and image identity over a shared base. Patches need to target the intended object and field. A base change can affect every overlay, while an overlay patch can become incompatible with a changed base structure. Composition reduces duplication but does not remove review of the final configuration.

Names and namespaces must remain consistent across references. A customized Secret name, Service selector or claim reference needs a corresponding consumer relationship. A generated set can be individually valid while containing references that do not resolve to the intended objects. Rendering validation and runtime behavior answer different questions.

## Choosing A Configuration Abstraction

A chart is useful for packaging a reusable application with defined parameter choices and release tracking. An overlay is useful for modifying concrete resource files across environments. Either can become difficult to maintain if it accumulates too many conditionals, patches or unexplained environment exceptions.

Prefer an abstraction whose inputs and outputs reviewers can understand. A small repeated setting may be clearer as an explicit overlay than a large general template. A reusable application with several related resources may benefit from a chart's packaging contract. The tools can be combined when needed, but that adds another transformation to inspect.

The delivery controller, if present, consumes these outputs and reconciles them. Helm rendering, Kustomize composition, API acceptance and application readiness remain distinct stages. A useful configuration lesson follows a specific input through its rendered field and resulting behavior rather than assuming the chosen tool makes correctness automatic.

## Common pitfalls

> [!WARNING]
> Helm and Kustomize produce configuration; neither inherently provides continuous GitOps reconciliation. Review rendered resources, not just the inputs used to generate them.
