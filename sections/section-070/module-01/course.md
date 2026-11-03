---
draft: true
exam_objectives:
- Continuous Delivery and GitOps
---
# GitOps And Deployment Configuration

This module explains how a controller reconciles a cluster with desired state stored in Git, how Helm and Kustomize produce the resources that get reconciled, and how a change moves between environments as a commit. A Git server and Argo CD run in the playground cluster, so every statement can be checked against a live Application.

## Learning Goals

- Explain declarative, versioned desired state.
- Describe pull-based reconciliation, drift and self-heal.
- Compare Helm templating with Kustomize overlays and read rendered output.
- Promote a change through a Git commit and tie it to the revision the controller reached.
- Identify what a GitOps controller cannot infer from repository state.

## Before You Start

You should know what a Deployment, a namespace and a Secret are. The hands-on parts use a playground with a kind cluster, `kubectl` and `git`. Technical terms are defined where they first appear.

## Reading Order

1. GitOps Reconciliation And Drift
2. Helm, Kustomize And Configuration Rendering
3. Promotion Through Git And Revision Evidence
4. Summary

<!-- astrona:playground -->
