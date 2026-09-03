# Security Policy

## Scope

This repository contains agent instructions, shell scripts, verification hooks, and optional browser automation. Review every hook before enabling it in a project.

## Do not publish secrets

Never put API keys, tokens, passwords, private URLs, personal data, or exploit details in issues, pull requests, logs, screenshots, or commits.

## Reporting a vulnerability

Do not open a public issue for suspected command injection, credential exposure, unsafe hook behavior, prompt-injection bypasses, or data exfiltration. Contact the repository maintainer privately with a minimal reproduction and the affected path.

## Safe disclosure

Allow maintainers reasonable time to investigate before public disclosure. Redact secrets from all supporting evidence.

## Supported branch

The `main` branch is the supported development line. Security fixes should include a regression test or a documented reason why automated coverage is not possible.
