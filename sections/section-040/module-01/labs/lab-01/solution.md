# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check. This lab was built without running it, so the text describes what you should see instead of printing output.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-040/module-01/labs/lab-01
```

`astrona submit` right after the start shows one check that already passes: `workloads-running`.

## Step 1: The definition

Save this as `apprequest-crd.yaml`:

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: apprequests.platform.starfleet.io
spec:
  group: platform.starfleet.io
  scope: Namespaced
  names:
    plural: apprequests
    singular: apprequest
    kind: AppRequest
    shortNames:
      - apr
  versions:
    - name: v1
      served: true
      storage: true
      subresources:
        status: {}
      additionalPrinterColumns:
        - name: Tier
          type: string
          jsonPath: .spec.tier
        - name: Phase
          type: string
          jsonPath: .status.phase
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              required: ["name", "tier"]
              x-kubernetes-validations:
                - rule: "self.tier != 'large' || has(self.contact)"
                  message: "a large request needs a contact"
              properties:
                name:
                  type: string
                tier:
                  type: string
                  enum: ["small", "medium", "large"]
                replicas:
                  type: integer
                  minimum: 1
                  maximum: 5
                contact:
                  type: string
            status:
              type: object
              properties:
                phase:
                  type: string
```

Apply it and wait until the API server serves the kind:

```sh
kubectl apply -f apprequest-crd.yaml
kubectl wait --for=condition=Established crd/apprequests.platform.starfleet.io --timeout=60s
```

The first command prints `customresourcedefinition.apiextensions.k8s.io/apprequests.platform.starfleet.io created`. The second prints `condition met`. Then check the kind and the rules:

```sh
kubectl api-resources --api-group=platform.starfleet.io
kubectl explain apprequest.spec.tier
```

Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-040/module-01/labs/lab-01 --keep
```

The checks `crd-defined` and `crd-validation` pass. If `crd-validation` fails, its output names the object that was accepted or rejected wrongly.

## Step 2: The request and its status

Save this as `scout-request.yaml`:

```yaml
apiVersion: platform.starfleet.io/v1
kind: AppRequest
metadata:
  name: scout-request
  namespace: starfleet
spec:
  name: scout
  tier: small
  replicas: 2
```

Apply it, then write the phase through the status endpoint:

```sh
kubectl apply -f scout-request.yaml
kubectl -n starfleet patch apprequest scout-request --subresource=status --type=merge -p '{"status":{"phase":"Accepted"}}'
kubectl -n starfleet get apr
```

The list shows the tier `small` and the phase `Accepted`. A change to `status` made through the normal endpoint would be ignored, because the status subresource is enabled. Grade the whole task:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS077.git -c sections/section-040/module-01/labs/lab-01
```

All four checks pass. Remove the lab when you are done:

```sh
astrona destroy ats-077-lab-040-01
```

## Why it works

The CRD adds the kind to the API server together with its schema, so the API server validates every object, including the enum, the number range and the CEL rule, and rejects bad requests before any controller exists. The `status` subresource separates what the user declares from what the platform reports. No Deployment appears for the request, because a CRD stores and validates objects and a controller delivers them.
