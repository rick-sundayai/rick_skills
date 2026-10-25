# rick-skills

Curated engineering skills for AI coding agents, tuned for a **Next.js + Supabase + Vercel + n8n** stack.

Three sources, merged:

1. **Lifecycle skills** cherry-picked from [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) — the ones that cover the back half of shipping (security, observability, performance, launch, migration, CI/CD, constraints, frontend), with their reference checklists co-located so per-skill installs work.
2. **Patched workflow skills** forked from [Superpowers](https://github.com/obra/superpowers) / [Matt Pocock's skills](https://github.com/mattpocock/skills) — `grill-me`, `tdd`, `systematic-debugging`, `writing-plans` — with the best ideas from Addy's overlapping skills folded in (confidence-tracked interviewing, the Prove-It bug-fix pattern, error-type triage, explicit task dependencies) and a *Common Rationalizations / Red Flags* section on each.
3. **Stack notes** appended to the skills where it matters: App Router server/client boundaries, Server Actions as public endpoints, RLS, `NEXT_PUBLIC_` rules, Vercel preview/rollback, Supabase expand/contract migrations, n8n webhook auth and observability, LLM prompt-injection boundaries.

## Install

### Claude Code (plugin — recommended)

Once per machine:

```
/plugin marketplace add rick-sundayai/rick_skills
```

Then in any project:

```
/plugin install rick-skills@rick-skills
```

Update later with `/plugin update rick-skills@rick-skills`. Skills are namespaced as `rick-skills:<name>` where a built-in or other plugin has the same name.

> If you also have the Superpowers or Matt Pocock plugins enabled in a project, disable their `tdd`, `plan-griller`/`grill-me`, `systematic-debugging` and `writing-plans` there — the versions here replace them, and running both doubles the context cost and confuses routing.

### Any agent via the skills CLI

```bash
npx skills add rick-sundayai/rick_skills                       # all skills
npx skills add rick-sundayai/rick_skills --skill tdd            # one skill
```

### Plain copy (no tooling)

```bash
git clone https://github.com/rick-sundayai/rick_skills ~/rick-skills
~/rick-skills/scripts/install.sh            # → ./.claude/skills in the current project
~/rick-skills/scripts/install.sh .cursor/skills
```

Re-run to update; same-named skills are replaced.

## Skills

| Skill | Phase | Source | What it does |
|---|---|---|---|
| `grill-me` | Define | fork | One-question-at-a-time interview with a confidence number and a guess on every question, walking the decision tree until an explicitly confirmed statement of intent |
| `writing-plans` | Plan | fork | Dependency-aware, vertically sliced plans with real code in every step, explicit `Depends on`, checkpoints every 2–3 tasks |
| `constraint-driven-development` | Plan | Addy | Writes the project's quality bar to `CONSTRAINTS.md` and watches diffs for a lowered bar (`@ts-ignore`, skipped tests, edited thresholds) |
| `tdd` | Build | fork | Red → green at pre-agreed seams; Prove-It pattern for bug fixes; discover the repo's test commands first |
| `frontend-ui-engineering` | Build | Addy + stack | Component architecture, state, WCAG 2.1 AA, responsive, loading states — plus App Router / Server Action / Supabase client rules |
| `systematic-debugging` | Verify | fork | Root cause before fixes; four-phase process; error-type triage trees; 3-failures → question the architecture |
| `security-and-hardening` | Verify | Addy + stack | Threat model first, three-tier boundaries, OWASP controls — plus Server Actions, RLS, service-role key, n8n webhooks, LLM input |
| `performance-optimization` | Verify | Addy | Measure before optimizing: Core Web Vitals, N+1s, bundle, queries |
| `observability-and-instrumentation` | Ship | Addy + stack | Logs/metrics/traces that answer production questions — plus request-ID correlation across Vercel, Supabase and n8n |
| `ci-cd-and-automation` | Ship | Addy | Pipelines as quality gates, deployment strategies |
| `shipping-and-launch` | Ship | Addy + stack | Pre-launch checklist, flags, staged rollout, rollback — plus Vercel envs, Supabase migrations, n8n workflow versioning |
| `deprecation-and-migration` | Ship | Addy | Expand/contract migrations, sunsetting APIs and features without downtime |

`references/` holds the shared checklists (security, performance, accessibility, observability, definition-of-done, testing patterns, orchestration patterns). The skills that use them carry their own copy in `skills/<name>/references/` so a single-skill install never has a dangling link.

## Suggested flow

```
grill-me → (spec) → writing-plans → tdd per task → systematic-debugging when stuck
         → security-and-hardening + performance-optimization before merge
         → observability-and-instrumentation + shipping-and-launch before deploy
```

## Updating from upstream

The Addy skills are copied verbatim except for (a) `../../references/` → `references/` path rewrites and (b) the `## Stack Notes` sections. To pull a newer upstream version of one, copy its `SKILL.md` over, re-apply those two changes, and bump `version` in `.claude-plugin/plugin.json` and `marketplace.json`.

## License

MIT. Includes material from addyosmani/agent-skills (MIT), Superpowers, and Matt Pocock's skills; see `LICENSE`.
