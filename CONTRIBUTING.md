# Contributing to skill-verify

Thank you for helping make AI-assisted development more verifiable.

## Contribution standard

A contribution should improve one of these areas without adding unnecessary output noise:

- evidence quality;
- verification coverage;
- stack detection;
- UI or API flow replay;
- agent skill portability;
- security and failure handling;
- documentation and evaluation cases.

## Workflow

1. Create a focused branch from `main`.
2. Make the smallest change that solves the problem.
3. Add or update the relevant evaluation case.
4. Run the affected verification gates.
5. Record the exact commands, outputs, exit codes and uncovered areas.
6. Open a pull request with a concise evidence report.

## Pull request checklist

- [ ] The change has a clear goal.
- [ ] The affected user flow is identified.
- [ ] Tests or verification commands were executed.
- [ ] Exit codes are recorded.
- [ ] UI changes include fresh screenshots when applicable.
- [ ] `NON VERIFIE` items are listed honestly.
- [ ] No API keys, tokens or personal data were added.
- [ ] Destructive actions remain behind explicit confirmation.
- [ ] Existing behavior was not changed accidentally.

## Skill changes

When modifying a `SKILL.md`:

- keep the frontmatter valid;
- keep `name` aligned with the directory name;
- describe both what the skill does and when it should trigger;
- separate instructions from repository data;
- add should-trigger and should-not-trigger cases;
- test the skill on realistic and edge-case prompts;
- document limitations instead of claiming unsupported guarantees.

## Verification philosophy

`skill-verify` follows one rule:

> No fresh evidence means no success claim.

A passing unit test does not automatically prove that the real user flow works. Match every claim to the evidence required to support it.

## Code of conduct

Be precise, constructive and respectful. Report security issues privately instead of publishing sensitive details in an issue.

## License

By contributing, you agree that your contributions are provided under the repository's MIT License.