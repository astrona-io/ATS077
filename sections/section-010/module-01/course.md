---
draft: true
exam_objectives:
- Declarative Resource Management
---
# Sufficient Intent, Rendering And Controller Contracts

This module explains how a platform team describes the state it wants and lets the system reach it. It starts with the declaration and the controller that acts on it, then shows how Kustomize renders declarations from a base and an overlay, and ends with ownership, drift and the status that tells whether a controller reached the intent.

## Learning Goals

- Assess whether a declaration expresses sufficient managed intent.
- Explain rendering inputs and controller ownership.
- Distinguish declarative management from a script stored in version control.
- Detect drift with `kubectl diff` and resolve a field conflict with server-side apply.

## Before You Start

You should know what a pod, a namespace and a Deployment are, and how to read YAML. The hands-on part uses a playground with a kind cluster and `kubectl`. Technical terms are defined where they first appear.

## Reading Order

1. Desired State, The API Server And Controllers
2. Rendering Declarations With Kustomize
3. Ownership, Drift And Field Managers
4. Summary

<!-- astrona:playground -->
