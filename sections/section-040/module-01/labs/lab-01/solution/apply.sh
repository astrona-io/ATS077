#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

kubectl apply -f - <<'YAML'
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
YAML
kubectl wait --for=condition=Established crd/apprequests.platform.starfleet.io --timeout=60s

kubectl apply -f - <<'YAML'
apiVersion: platform.starfleet.io/v1
kind: AppRequest
metadata:
  name: scout-request
  namespace: starfleet
spec:
  name: scout
  tier: small
  replicas: 2
YAML
kubectl -n starfleet patch apprequest scout-request --subresource=status --type=merge -p '{"status":{"phase":"Accepted"}}'
echo "[solution] Applied."
