<!-- Banners -->
<p align="center">
  <img src="assets/banner.png" alt="skill-verify — The Verification Skill Suite for AI Agents" width="100%" />
</p>

<h1 align="center">skill-verify</h1>

<p align="center">
  <strong>The complete skill suite for AI coding agents that prove they work, not just say they do.</strong>
</p>

<p align="center">
  <a href="https://github.com/agtktID/skill-verify/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/agtktID/skill-verify.svg?style=flat-square" alt="License MIT" />
  </a>
  <a href="https://github.com/agtktID/skill-verify/stargazers">
    <img src="https://img.shields.io/github/stars/agtktID/skill-verify.svg?style=flat-square&color=yellow" alt="GitHub Stars" />
  </a>
  <a href="https://github.com/agtktID/skill-verify/network/members">
    <img src="https://img.shields.io/github/forks/agtktID/skill-verify.svg?style=flat-square" alt="Forks" />
  </a>
  <a href="https://github.com/agtktID/skill-verify/releases">
    <img src="https://img.shields.io/github/v/release/agtktID/skill-verify.svg?style=flat-square" alt="Latest Release" />
  </a>
  <img src="https://img.shields.io/badge/works%20with-Claude%20Code%20%7C%20Codex%20%7C%20Cursor%20%7C%20Hermes-blueviolet?style=flat-square" alt="Works with" />
  <img src="https://img.shields.io/badge/skills-13-blue?style=flat-square" alt="13 skills" />
</p>

<p align="center">
  <a href="#-quick-start">Quick Start</a> ·
  <a href="#-project-suite-5-skills">Project Suite</a> ·
  <a href="#-verification-suite">Verification Suite</a> ·
  <a href="#-auto-trigger-hook">Auto-Trigger</a> ·
  <a href="#-full-skill-catalogue">All Skills</a> ·
  <a href="./CONTRIBUTING.md">Contribute</a>
</p>

---

## 🎯 What is skill-verify?

**skill-verify** is an open-source collection of **13 Claude Code skills** designed to make AI agents
**prove their work** instead of hallucinating results.

Two suites, one goal — ship production-quality code:

| Suite | Skills | Purpose |
|-------|--------|---------|
| 🏗️ **Project Suite** | `project-init` `project-build` `project-test` `project-ship` `project-review` | Build a complete project from idea to production |
| 🛡️ **Verification Suite** | `verify` `verify-feature-end2end` `verify-context-health` `verify-unity-playmode` | Prove it works with real execution |
| ⚙️ **Auto-Trigger Hook** | `post-task.sh` + `hooks.json` | Automatically verify after every completed task |

**Core principles:**

- 🚫 **Anti-hallucination** — No step is PASS without real Bash execution + exit code.
- 📦 **Progressive disclosure** — SKILL.md stays concise; heavy scripts live in `scripts/`.
- 🔁 **TDD-first** — Write the test before the code (Matt Pocock's methodology).
- 🔒 **Git guardrails** — Never force-push, never deploy without a PASS verdict.
- 📋 **Structured reports** — Every session produces `.verify/<timestamp>/report.md`.

---

## ⚡ Quick Start

### Install with 1 command

```bash
# Install all skills in your project
npx skills@latest add agtktID/skill-verify

# Or clone and copy manually
git clone https://github.com/agtktID/skill-verify.git
mkdir -p .claude/skills
cp -r skill-verify/skills/* .claude/skills/
```

### Install specific skills

```bash
# Just the verification suite
cp -r skill-verify/skills/verify .claude/skills/
cp -r skill-verify/skills/verify-feature-end2end .claude/skills/

# Just the project suite
cp -r skill-verify/skills/project-init .claude/skills/
cp -r skill-verify/skills/project-build .claude/skills/
cp -r skill-verify/skills/project-test .claude/skills/
cp -r skill-verify/skills/project-ship .claude/skills/
cp -r skill-verify/skills/project-review .claude/skills/
```

### Install the auto-trigger hook

```bash
# Copy the hook to your project
mkdir -p .claude/hooks
cp skill-verify/skills/verify/hooks/post-task.sh .claude/hooks/
cp skill-verify/skills/verify/hooks/hooks.json .claude/hooks/
chmod +x .claude/hooks/post-task.sh
```

The hook will **automatically run `/verify`** after every completed task, step, or feature.

---

## 🏗️ Project Suite (5 Skills)

Build a complete project from idea to production using only these 5 skills:

```
💡 Idea
  ↓
/project-init     ← Brainstorm → PRD → Issues → Scaffold → Git init
  ↓
/project-build    ← TDD (Red→Green→Refactor) + Gauntlet Loop
  ↓
/project-test     ← Unit + Integration + E2E + Coverage report
  ↓
/project-ship     ← CHANGELOG → Version bump → Build → Tag → Deploy → Release
  ↓
/project-review   ← Code quality + Architecture + Performance + Security
  ↓
🚀 Production
```

### `/project-init` — Start from zero

Turns a rough idea into a structured, ready-to-code project.

```text
/project-init

Idea: A SaaS that helps developers track their coding streaks and share them on GitHub.
```

Deliverables: `docs/prd.md`, `docs/issues.md`, scaffolded structure, `README.md`, git init, lint configured.

### `/project-build` — TDD-first feature implementation

Enforces **Red → Green → Refactor** on every feature. Blocks if tests fail.

```text
/project-build

Issue: #3 — Implement calculateTotal() that sums cart item prices.
```

Deliverables: `src/<feature>.<ext>`, `tests/<feature>.test.<ext>`, `.verify/<ts>/report.md`, 1 atomic commit.

### `/project-test` — Full test suite

Writes and runs tests at 3 levels: unit, integration, E2E.

```text
/project-test
```

Deliverables: complete test suite, coverage report in `.verify/<ts>/coverage-report.md`.

### `/project-ship` — Production delivery

Handles the entire release pipeline: changelog → versioning → build → tag → deploy.

```text
/project-ship v1.0.0
```

Deliverables: updated `CHANGELOG.md`, bumped version, Git tag `v1.0.0`, deployed URL.

### `/project-review` — Full code review

Reviews 5 dimensions: code quality, architecture, performance, security, DX.

```text
/project-review --scope all
```

Deliverables: `.verify/<ts>/review-report.md` with prioritized findings (P0/P1/P2).

---

## 🛡️ Verification Suite

### `/verify` — Persistent verification mode

The core skill: runs gates (tests, build, lint, typecheck), collects logs,
generates a structured report.

```text
/verify

Task: Add calculateTotal() function.
Constraints:
- Write the unit test BEFORE implementation.
- Run tests after each change.
- If a test fails, fix and re-run until PASS.
```

### `/verify-feature-end2end` — Prove it works, then PR it

Starts the app, exercises the route (Playwright or cURL), runs CI, opens the PR only if PASS.

### `/verify-context-health` — Agent context audit

Audits token budget, progressive disclosure compliance, unused skills, and tool schema bloat.

### `/verify-unity-playmode` — Unity CI

Runs EditMode + PlayMode tests and build in batchmode via Unity CLI.

---

## ⚙️ Auto-Trigger Hook

The `post-task.sh` hook **automatically triggers `/verify`** whenever Claude Code detects
a task, step, or feature has been completed — no manual invocation needed.

```
Claude Code finishes a Bash command or Stop event
    ↓
post-task.sh reads the Claude Code JSON payload from stdin
    ↓
Detects completion keywords (done, implemented, fixed, PASS, etc.)
    ↓
Triggers run-verify.sh → check.sh → runs all gates
    ↓
Prints PASS / ECHEC / PARTIEL directly in the terminal
```

### Install the hook

```bash
mkdir -p .claude/hooks
cp .claude/skills/verify/hooks/post-task.sh .claude/hooks/
cp .claude/skills/verify/hooks/hooks.json .claude/hooks/
chmod +x .claude/hooks/post-task.sh
```

### Customize the trigger keywords

Edit `post-task.sh` and update `COMPLETION_KEYWORDS`:

```bash
COMPLETION_KEYWORDS="done|finished|completed|implemented|refactored|fixed|added"
```

### Manual trigger

```bash
# Run all gates
bash .claude/skills/verify/scripts/run-verify.sh

# Run specific gates
bash .claude/skills/verify/scripts/check.sh --tests --lint

# Full CI pipeline
bash .claude/skills/verify/scripts/ci.sh
```

---

## 📦 Full Skill Catalogue

| # | Skill | Category | Command | Works with |
|---|-------|----------|---------|------------|
| 1 | [`verify`](./skills/verify/) | Verification | `/verify` | Claude Code, Codex, Cursor |
| 2 | [`verify-feature-end2end`](./skills/verify-feature-end2end/) | Verification | `/verify-feature-end2end` | Claude Code |
| 3 | [`verify-context-health`](./skills/verify-context-health/) | Verification | `/verify-context-health` | Claude Code, Hermes |
| 4 | [`verify-unity-playmode`](./skills/verify-unity-playmode/) | Verification | `/verify-unity-playmode` | Claude Code + Unity |
| 5 | [`project-init`](./skills/project-init/) | Project Suite | `/project-init` | Claude Code, Codex |
| 6 | [`project-build`](./skills/project-build/) | Project Suite | `/project-build` | Claude Code, Codex |
| 7 | [`project-test`](./skills/project-test/) | Project Suite | `/project-test` | Claude Code, Codex |
| 8 | [`project-ship`](./skills/project-ship/) | Project Suite | `/project-ship` | Claude Code, Codex |
| 9 | [`project-review`](./skills/project-review/) | Project Suite | `/project-review` | Claude Code, Codex |
| 10 | [`skill-architect`](./skills/skill-architect/) | Meta | `/skill-architect` | Claude Code |
| 11 | [`gauntlet-loop-dev`](./skills/gauntlet-loop-dev/) | Quality | `/gauntlet-loop-dev` | Claude Code |
| 12 | [`indagis-feature-builder`](./skills/indagis-feature-builder/) | Project | `/indagis-feature-builder` | Claude Code |
| 13 | [`unity-gamedev`](./skills/unity-gamedev/) | Game Dev | `/unity-gamedev` | Claude Code + Unity |

---

## 📁 Repository Structure

```text
skill-verify/
├── skills/
│   ├── verify/                      ← Core verification skill
│   │   ├── SKILL.md
│   │   ├── scripts/
│   │   │   ├── check.sh             ← Gate runner (tests/lint/build)
│   │   │   ├── ci.sh                ← Full CI pipeline (clean→install→lint→test→build)
│   │   │   └── run-verify.sh        ← Manual trigger / hook entry point
│   │   ├── hooks/
│   │   │   ├── post-task.sh         ← Auto-trigger on task completion
│   │   │   └── hooks.json           ← Claude Code hooks config
│   │   ├── evals/
│   │   └── assets/
│   ├── verify-feature-end2end/      ← E2E pipeline (Playwright, CI, PR gate)
│   ├── verify-context-health/       ← Context audit (tokens, progressive disclosure)
│   ├── verify-unity-playmode/       ← Unity CLI (EditMode/PlayMode/build)
│   ├── project-init/                ← Project bootstrapper (PRD, issues, scaffold)
│   ├── project-build/               ← TDD implementation loop
│   ├── project-test/                ← Full test suite (unit/integ/e2e)
│   ├── project-ship/                ← Release pipeline (changelog→deploy→release)
│   ├── project-review/              ← Code review (quality/arch/perf/security)
│   ├── skill-architect/
│   ├── gauntlet-loop-dev/
│   ├── indagis-feature-builder/
│   ├── unity-gamedev/
│   └── manifest.yml                 ← Skills registry v0.3
├── assets/
├── .github/
├── CHANGELOG.md
├── CONTRIBUTING.md
└── README.md
```

---

## 🔄 Verdict system

Every skill produces a structured verdict:

| Verdict | Meaning | Action |
|---------|---------|--------|
| ✅ `PASS` | All critical gates passed | Safe to commit / merge / deploy |
| ❌ `ECHEC` | At least one critical gate failed | Fix before continuing |
| ⚠️ `PARTIEL` | Critical gates PASS but warnings exist | Review warnings before release |
| 🔒 `BLOQUÉ` | Cannot run (missing config) | Setup the missing commands |

---

## 🤝 Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md). PRs welcome — new skills, new scripts, new hooks.

## 📜 License

MIT — See [LICENSE](./LICENSE).

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/agtktID">agtktID</a> ·
  Inspired by <a href="https://github.com/mattpocock/skills">Matt Pocock</a>,
  <a href="https://github.com/obra/superpowers">Superpowers</a>,
  <a href="https://ecc.tools">ECC</a> and the Claude Code community.
</p>
