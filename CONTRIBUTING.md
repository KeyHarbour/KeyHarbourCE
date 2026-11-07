# Contributing to KeyHarbourCE

Thank you for considering contributing to **KeyHarbourCE**! We welcome bug reports, documentation improvements, and pull requests that enhance the Community Edition.

## Scope (Community vs. Enterprise)
`KeyHarbourCE` is the core, self-hosted edition of KeyHarbour. Please ensure your pull requests focus on core features, bug fixes, and performance improvements without introducing SaaS-specific dependencies.

## Getting Started Locally
1. Fork the repository and create your branch from `main` (`git checkout -b fix/my-feature`).
2. Start the development environment with Docker Compose:
   ```bash
   docker compose up --build
   ```
3. Prepare the database:
   ```bash
   docker compose exec web bundle exec rails db:prepare
   ```

## Running Tests & Linter
Before submitting a Pull Request, please make sure all tests and style checks pass:
```bash
docker compose exec web bundle exec rspec
docker compose exec web bundle exec rubocop
```

## Pull Request Process
- Keep pull requests focused on a single bug fix or feature.
- Add or update RSpec tests for any new behavior.
- Use clear, descriptive commit messages (e.g., `feat: ...`, `fix: ...`, `docs: ...`).
- By submitting a pull request, you agree that your contributions will be licensed under the project's license.
