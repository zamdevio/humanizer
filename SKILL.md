---
name: humanizer
description: "A robust rewriting skill that transforms AI-generated prose into authentic, natural-sounding human text. It offers three distinct tiers of adaptation: Tier 1 (Polished), Tier 2 (Natural), and Tier 3 (Expressive). Operates by neutralizing AI-patterns like predictable rhythms, absolute certainties, and formulaic structure while strictly preserving the author's intent and all factual accuracy."
---

# @zamdevio/humanizer

This skill assists the user in rewriting content across the "humanization" spectrum, ensuring a natural flow and authentic voice while eliminating typical AI markers.

## Usage Logic

When asked:
1. **Consult preference**: If the user hasn't specified a writing style (Tier), present the choices (1|2|3) and their descriptions.
2. **Defaulting**: If the user says "Make this look human" or equivalent without tier mention, default to **Tier 2 (Natural)** unless the context suggests otherwise.
3. **Disambiguation**: If the user asks for "academic polishing," use Tier 1; if they ask to "pass AI detection," use Tier 3; if they say "just make it readable," use Tier 2.
4. **Detailed Reviews**: If requested to rewrite a project (multiple paragraphs), apply the same selected tier consistently throughout.

## Instruction Sets

The full, authoritative editing rules live in **`tiers.md`**. After the tier is selected, read `tiers.md` and apply **only** the matching tier section (`## [Tier 1]`, `## [Tier 2]`, or `## [Tier 3]`, plus its `## Global Constraints Across All Tiers`). Do not invent rules that are not in that file.

The brief summary below is only for tier selection and disambiguation:

### Tier 1: The Polished Professional
- Focus: Maximum syntactic fidelity; minimal variance.
- Goal: Rectify clunky wording, precision, and flow.
- Key Rule: Do not alter structure drastically. Remove explicitly recognizable AI buzzwords.
- Output: Text that is professionally written and grammatically perfect.

### Tier 2: Natural & Conversational (Default)
- Focus: Breaking the "perfect" pattern.
- Goal: Seamlessly fluent, relatable language.
- Key Rule: Vary sentence length within a moderate band and natural pacing. No lone-word fragments.
- Voice: Informed but relaxed. Use contractions that fit the context.

### Tier 3: Expressive & Distinctive
- Focus: Character and authority.
- Goal: Non-linearly structured and high impact.
- Key Rule: Reshape clauses and paragraphs, experiment with less predictable phrasing, and infuse a specific sense of agency and opinion, while staying loyal to the user's original meaning.

## Safe Guards

- **No Fabrication**: Never invent stories or statistics to make a human identity; reframe the existing info instead.
- **No Content Death**: Never shorten a piece so much that the argument is lost to satisfy "naturalness."
- **Voice Consistency**: Do not flip between tiers; find one on the spectrum and hold it.
- **Detector Signals**: Scores from a single detector are noisy and detector-specific. Never degrade meaning, tone, or voice solely to chase one detector's number; treat any score as one imperfect data point.

Always verify that the final result contains 100% of the factual information provided in the original source.
