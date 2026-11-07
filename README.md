# README

[![Ruby](https://img.shields.io/badge/Ruby-%3E%3D%204.0-green?logo=ruby)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-8.x-green?logo=rubyonrails)](https://rubyonrails.org/)
[![Latest Release](https://img.shields.io/github/v/release/KeyHarbour/KeyHarbourCE?sort=semver)](https://github.com/KeyHarbour/KeyHarbourCE/releases)
![Coverage](coverage.svg)
[![CI](https://github.com/KeyHarbour/KeyHarbourCE/actions/workflows/ci.yml/badge.svg)](https://github.com/KeyHarbour/KeyHarbourCE/actions/workflows/ci.yml)
[![Dependabot enabled](https://img.shields.io/badge/Dependabot-enabled-025e8c?logo=dependabot)](https://github.com/KeyHarbour/KeyHarbourCE/blob/main/.github/dependabot.yml)
[![License](https://img.shields.io/github/license/KeyHarbour/KeyHarbourCE)](https://github.com/KeyHarbour/KeyHarbourCE/blob/main/LICENSE.md)


# KeyHarbour Enterprise Edition (KeyHarbourCE)

KeyHarbourCE is a robust enterprise management platform built with **Ruby on Rails 8**, designed for maximum security and optimal performance through a containerized architecture. It natively integrates PostgreSQL for data persistence and Meilisearch for an ultra-fast search experience.

---

## 🚀 Key Features

* **Rails 8 Engine**: Modern, high-performance web structure (Propshaft, Importmaps, and Stimulus).
* **High-Performance Search**: Full out-of-the-box integration with Meilisearch.
* **Hardened Security**: At-rest data encryption powered by Active Record Encryption.
* **Production Ready**: Optimized Docker multi-stage build setup and native compatibility with Kamal.

---

## 🛠️ Prerequisites

To run this application locally, you need to have the following installed on your machine:
* [Docker Desktop](https://docker.com) or [Podman](https://podman.io) (strongly recommended for macOS).
* **Docker Compose v2** (included with Docker Desktop or available via Homebrew).

---

## 📦 Quick Start with Docker Compose

The development environment is fully containerized. Follow these steps to get up and running:

### 1. Start the services
This command builds the application image and downloads the required dependent services (PostgreSQL & Meilisearch):
```bash
docker compose up --build
```

### 2. Initialize the Database
The database are created on the first run, but in cas eyou need to regenerate you can use the following command :
```bash
docker compose exec web rails db:create db:migrate
```

### 3. Access the Application
Once the boot process is complete, open your browser and navigate to:
* **Rails Web Application**: [http://localhost:3000](http://localhost:3000)
* **Meilisearch Dashboard**: [http://localhost:7700](http://localhost:7800)

---

## 🔒 Security & Environment Variables

The application uses native Active Record database column encryption. Upon the very first boot (`docker compose up`), the container initialization script (`docker-entrypoint.sh`) automatically generates a persistent file containing your development cryptographic keys. This data are store in the persistent volume /rails/storage/

To manually override or declare these keys, manage them in a /rails/storage/ folder at the root level:
```text
ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=your_primary_key_here
ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=your_deterministic_key_here
ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=your_salt_here
```

---

## 🧪 Running the Test Suite

Tests are built using RSpec. To execute the automated test suites inside the containerized environment, run:
```bash
docker compose exec web bundle exec rspec
```
*Note: The production licensing system and strict identity verifications are automatically skipped within the test environment to guarantee continuous integration (CI) safety.*

---

## 📄 License

KeyHarbourCE is an open-source project distributed under the terms of the **Business Source License 1.1 (BSL 1.1)**.

* You are fully permitted to use the source code for development, testing, and non-commercial purposes.
* Commercial production use is restricted subject to the clear provisions detailed in the `LICENSE.md` file.
* The source code automatically converts to a standard open-source license (Change License) after a specified time frame.

Please read the full [LICENSE.md](LICENSE.md) file for comprehensive usage terms.

---
© 2025-2026 KeyHarbour Enterprise Edition — Maintained by Ikigai Lab Inc.

