---
draft: true
exam_objectives:
- Platform Architecture and Capabilities
---
# Capability Layers, Control Planes And Supported Interfaces

This module explains how a platform is built from layers: the interface that developers use, the control plane that makes requests true and the infrastructure that runs the work. It shows how a custom resource turns a capability into an API, how policies and RBAC guard it, and how failures stay within the layers where they start.

## Learning Goals

- Describe platform capability, control and implementation layers.
- Distinguish developer interfaces from the systems performing work.
- Reason about composability, failure domains and ownership.
- Define a custom resource with validation and add admission and access rules around it.

## Before You Start

You should know what a pod, a Deployment and a Service are. The hands-on part uses a playground with a kind cluster and `kubectl`. Technical terms are defined where they first appear.

## Reading Order

1. Capability Layers And Supported Interfaces
2. A Custom Resource As A Platform API
3. Guardrails, Failure Domains And Ownership
4. Summary

<!-- astrona:playground -->
