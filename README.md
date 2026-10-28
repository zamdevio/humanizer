<div align="center">

  <h1>✍️ humanizer</h1>

  [![npm version](https://img.shields.io/npm/v/@zamdevio/humanizer?logo=npm&logoColor=white&color=CB3837)](https://www.npmjs.com/package/@zamdevio/humanizer)
  [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)
  [![Agent Skill](https://img.shields.io/badge/Agent%20Skill-SKILL.md-0A7EA4)](SKILL.md)
  [![pnpm](https://img.shields.io/badge/pnpm-package%20manager-F69220?logo=pnpm&logoColor=white)](https://pnpm.io/)

  <p><strong>Humanize · Polish · Naturalize · Rewrite</strong></p>
  <p>
    An <b>Agent Skill</b> and <b>npm package</b> that turns robotic, AI-sounding prose into
    natural human writing — without losing a single fact or your voice.
  </p>
  <p>
    <a href="#tiers">Tiers</a> ·
    <a href="#install">Install</a> ·
    <a href="#usage">Usage</a> ·
    <a href="#javascript-api">JavaScript API</a> ·
    <a href="#architecture">Architecture</a> ·
    <a href="#development">Development</a>
  </p>
</div>

---

`@zamdevio/humanizer` is a three-tier rewriting skill that removes the AI "gloss" — predictable rhythms, formulaic transitions, and empty filler — while strictly preserving meaning, factual accuracy, and the author's intent.

## Tiers

| Tier | Name | Editing depth | Best for |
|------|------|---------------|----------|
| 1 | **Polished** | Minimal, targeted edits (clarity, grammar, flow). Structure and voice preserved. | Academic, professional, technical writing |
| 2 | **Natural** *(default)* | Rewrites stiff, formulaic phrasing into fluent, conversational prose. Rhythm varied. | Most essays, articles, general use |
| 3 | **Expressive** | Deep structural and stylistic changes for a distinctive, engaging voice. | Opinion pieces, creative work, storytelling |

Tiers differ by **editing depth and structural change**, not word swaps.

> **Semantic fidelity (all tiers):** claims, qualifications, and certainty are preserved. No fabricated experiences, evidence, statistics, or "personality" tricks are added just to look human.

## Install

Requires the [`skills` CLI](https://github.com/openai/agents-skills).

```sh
# global Agent Skill (all supported tools)
skills add -g @zamdevio/humanizer

# or from a local checkout
skills add -g ./humanizer
```

## Usage

The agent introduces the tiers once, then reuses your choice for the whole task — no nagging.

```text
Humanize this (Tier 2): "Furthermore, it is paramount to leverage innovative solutions..."
```

```text
I'll give you three paragraphs. Polish them, Tier 1.
```

```text
Just make it sound human.
```

- **No tier specified** → brief prompt or **Tier 2** default.
- **"Try all three"** → exactly three labeled versions.
- **"You choose"** → Tier 2 unless context says otherwise.

## JavaScript API

`@zamdevio/humanizer` also works as a small CommonJS prompt helper:

```js
const { getInstructions } = require('@zamdevio/humanizer');

const tier2Rules = getInstructions(2);
```

`getInstructions(tier)` returns the editing rules for tier `1`, `2`, or `3`, read from `tiers.md`. It is a **prompt helper only** — it does not call an LLM or rewrite text by itself.

## Architecture

| File | Role |
|------|------|
| `SKILL.md` | Discovery + interaction logic + fidelity safeguards for agents. Points to `tiers.md` for editing rules. |
| `tiers.md` | **Single canonical tier instruction matrix** — the actual rewriting rules for each tier. |
| `index.js` | CommonJS helper exposing `getInstructions(tier)`. |
| `package.json` | npm metadata; `files` allowlist guarantees the tarball ships all skill files. |
| `README.md` | This file. |

## Development

```sh
git clone https://github.com/zamdevio/humanizer
cd humanizer
skills add -g .          # install locally for testing
npm pack                 # inspect the tarball before publishing
```

## License

[MIT](./LICENSE) © 2026 Zamdevio