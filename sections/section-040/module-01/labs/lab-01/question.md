# Question

Solve this question on: `terminal`

The platform team wants to offer an application request as part of its own API. Teams will ask for an application by creating an object, and a controller (not part of this task) will deliver it. Build the interface and use it once.

1. Define a CustomResourceDefinition named `apprequests.platform.starfleet.io`: group `platform.starfleet.io`, kind `AppRequest`, plural `apprequests`, singular `apprequest`, short name `apr`, scope `Namespaced`. It has one version `v1` that is served and stored, and the `status` subresource is enabled.

2. The schema of `v1` has these rules. `spec` requires `name` (string) and `tier` (string). `tier` must be one of `small`, `medium` or `large`. `replicas` is an optional integer from `1` to `5`. `contact` is an optional string. A request with the tier `large` must have a `contact`, and this rule must be a CEL validation rule in the CRD. `status` is an object with the string field `phase`.

3. Create the `AppRequest` named `scout-request` in `starfleet` with `name: scout`, `tier: small` and `replicas: 2`. Then act as the controller once: write `Accepted` in `status.phase` through the status subresource.

Do not delete, scale down or replace `scout` or `shuttle`. `kubectl` already points at the cluster as the cluster administrator. Test your schema with `kubectl create --dry-run=server`.
