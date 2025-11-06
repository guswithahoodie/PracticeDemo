# demo_propject Task AI - Demo Project

This project is a demo **Django-based task management API** deployed on AWS using ECS Fargate. It demonstrates how to containerize a Django application, push it to AWS ECR, and run it in a fully managed serverless container environment with an Application Load Balancer (ALB).

---

## Table of Contents
1. [Project Overview](#project-overview)  
2. [Django Application](#django-application)  
3. [Architecture & AWS Components](#architecture--aws-components)  
4. [Local Development](#local-development)  
5. [Deployment](#deployment)  
6. [Shutting Down Resources](#shutting-down-resources)  
7. [Next Steps](#next-steps)

---

## Project Overview

The goal of this project is to:

- Build a Django API (`task_api`) for managing tasks.
- Containerize the Django application using Docker.
- Push the Docker image to AWS ECR.
- Deploy the app on **AWS ECS Fargate** using an Application Load Balancer for public access.
- Learn end-to-end cloud deployment while keeping costs minimal via shutdown scripts.

---

## Django Application

The backend is built with **Django 3.x+ / Python 3.12** and includes:

- **Apps:**
  - `task_api` – handles REST API endpoints for tasks.
  - `tasks` – defines models, business logic, and database migrations.
- **Key Files:**
  - `manage.py` – Django CLI utility.
  - `requirements.txt` – lists Python dependencies (including Django, Django REST Framework, etc.).
  - `Dockerfile` – Docker configuration to containerize the Django app.
  - `docker-compose.yml` – optional local development setup with containers.

---

## Architecture & AWS Components

The deployment uses the following AWS services:

| Component | Purpose |
|-----------|---------|
| **ECS Fargate** | Runs the Django app in a serverless container environment. |
| **ECR (Elastic Container Registry)** | Stores the Docker image (`demo_propject-task-ai-dev:latest`). |
| **ALB (Application Load Balancer)** | Distributes incoming HTTP requests to ECS tasks. |
| **Target Groups** | Groups ECS tasks for the ALB to route traffic. |
| **Security Groups** | Manages inbound/outbound access to tasks. |
| **VPC & Subnets** | Isolated network for resources. |
| **IAM Roles/Policies** | Permissions for ECS tasks to access ECR and CloudWatch logs. |
