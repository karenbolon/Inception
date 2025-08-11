# Inception — Containerized Web Stack
I built a production-style web stack using Docker and Docker Compose: NGINX as reverse proxy, WordPress (PHP-FPM) as the app, and MariaDB as the database. Each service runs from a custom Dockerfile, isolated on a private network with persistent volumes for data. Configuration is environment-driven, startup is automated, and the stack supports local TLS, health checks, and least-privilege defaults. The goal was to practice containerization, service orchestration, and basic hardening while keeping the setup reproducible across machines/VMs.

## What I implemented

Compose topology, custom images, and a Makefile for one-command lifecycle.

NGINX vhost + TLS termination → PHP-FPM; WordPress bootstrap + DB initialization.

Bind-mounted volumes for durability and idempotent setup scripts (wp-cli, init SQL).

## Key challenges & learnings

Ordering/health of dependent services (DB → app), and permissions on mounted volumes.

Reproducible local DNS/hosts for TLS, and cross-VM portability (Debian/Ubuntu).

Core skills: Dockerfiles, networking, volumes, secrets/env management, logging & health checks.

[Click here to see walkthrough](https://youtu.be/rduM96qmuDE "YouTube video")
