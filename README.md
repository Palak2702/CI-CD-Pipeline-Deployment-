# 🚀 CI/CD Pipeline Deployment on AWS EC2 with Jenkins, Docker & Kubernetes

## 📌 Project Overview

This project demonstrates an end-to-end **CI/CD and DevSecOps deployment workflow** for a Java/Spring Boot Board Game web application.

The application itself is an existing Java/Spring Boot application used as the workload for the deployment pipeline. The primary focus of this project is the **DevOps implementation**:

- Source code checkout
- Maven build and testing
- Static code quality analysis
- Security scanning
- Artifact management
- Docker image creation
- Container image security scanning
- Docker Hub image publishing
- Kubernetes deployment
- Kubernetes RBAC
- NGINX Ingress Controller
- Multi-node Kubernetes cluster
- Deployment verification
- Automated email notification

The complete environment was built on **AWS EC2**.

---

# 🏗️ Architecture

```text
                         ┌─────────────────────┐
                         │      Developer      │
                         │     Git Push        │
                         └──────────┬──────────┘
                                    │
                                    ▼
                         ┌─────────────────────┐
                         │       GitHub        │
                         │   Source Repository │
                         └──────────┬──────────┘
                                    │
                                    ▼
                         ┌─────────────────────┐
                         │       Jenkins       │
                         │    CI/CD Server     │
                         └──────────┬──────────┘
                                    │
              ┌─────────────────────┼─────────────────────┐
              │                     │                     │
              ▼                     ▼                     ▼
        Maven Compile/Test     SonarQube              Trivy
                              Code Quality         Security Scan
              │                     │                     │
              └─────────────────────┼─────────────────────┘
                                    │
                                    ▼
                              ┌───────────┐
                              │   Nexus   │
                              │ Artifact  │
                              │ Repository│
                              └─────┬─────┘
                                    │
                                    ▼
                              ┌───────────┐
                              │  Docker   │
                              │   Build   │
                              └─────┬─────┘
                                    │
                                    ▼
                                ┌─────────┐
                                │  Trivy  │
                                │Image Scan│
                                └────┬────┘
                                     │
                                     ▼
                              ┌──────────────┐
                              │  Docker Hub  │
                              │ Image Registry│
                              └──────┬───────┘
                                     │
                                     ▼
                  ┌─────────────────────────────────┐
                  │       Kubernetes Cluster        │
                  │                                 │
                  │  ┌─────────────┐                │
                  │  │ Master /    │                │
                  │  │ Control     │                │
                  │  │ Plane       │                │
                  │  └──────┬──────┘                │
                  │         │                       │
                  │    ┌────┴─────┐                 │
                  │    │          │                 │
                  │    ▼          ▼                 │
                  │ Worker-1   Worker-2             │
                  │    │          │                 │
                  │    └────┬─────┘                 │
                  │         │                       │
                  │    Board Game Pods              │
                  │         │                       │
                  │    NGINX Ingress                │
                  └─────────┬───────────────────────┘
                            │
                            ▼
                       End User