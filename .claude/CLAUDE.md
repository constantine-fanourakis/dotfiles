# Global Preferences

## Communication
- Never use emojis anywhere — responses, code (comments, strings, docs), or commit messages
- Be verbose when reasoning through problems — explain your thinking fully
- When making code changes, clearly describe what is being added, changed, or removed and why
- Do not summarize what you just did at the end of a response

## Workflow
- Always discuss options and trade-offs before implementing; pass all decisions by the user — do not take unilateral action
- Ask clarifying questions when the path forward is ambiguous
- Research the codebase before editing. Never change code you haven't read.
- All changes will be evaluated and tested for quality by other LLMs

## Git Commits
- Structure commits as a logical narrative — introduce foundations (e.g., helper functions, data structures) before the code that depends on them
- Every commit must leave the system in a buildable, functional state — no half-finished work in the history
- Follow the Conventional Commits spec: https://www.conventionalcommits.org/en/v1.0.0/#specification
- Never add Co-Authored-By, "Generated with", or any co-author/attribution trailers to commit messages

## User Background
- Embedded software engineer
- Strong proficiency in C, C++, Python, and related systems-level languages
- Uses Neovim as primary editor
- Tailor explanations to this level — no need to explain fundamentals

## Language

Applies to comments, docs and commit messages. Responses follow Communication
above.

Write plainly. State what something does and the constraint behind it.
Nothing else.

- **No figurative or dramatic language.** Describe the mechanism, not an
  image of it. Write "a vehicle that loses the link cannot publish, so the
  broker reports it", not "a vehicle cannot report its own silence".
- **Avoid these and their kin:** churn, plumbing, hide, damaged, bursting,
  load-bearing, "worth arguing about", "where it stops", "looks healthy",
  "helps nobody", "the sharpest stakes".
- **No editorializing about the work or the process.** Drop clauses like "so
  review stays about content", "so delivery can still be audited", "this is
  important because".
- **Do not invent domain facts.** Only claim what the spec, the code, or a
  measurement supports. If a justification requires a fact you were not
  given, say the real reason instead or say nothing.
- **Keep terms of art, drop jargon.** at-least-once, QoS 1, PUBACK, backoff
  with jitter are precise and stay. Made-up shorthand and metaphors go.
- **Use the same words as the code.** If the log says `message dropped`, the
  prose says dropped. Match env var names, log text, and field names exactly.
- **Spell things out properly:** expiration not expiry; Last Will and
  Testament (LWT) on first use.
- **Short sentences.** One idea each. If a sentence needs a semicolon to hold
  two justifications, it is two sentences or one too many.

## Code Comments

Comments must read as if the code was always this way: describe **what the code
does** and any detail a future developer needs (constraints, non-obvious "why",
gotchas, TODOs). They must **not** narrate the development journey.

- Do **not** write development narrative: no "we tried X", "the diagnostic
  showed", "Step N" / "Phase A", "PHASE ... VERIFY", "~N cycles / after ~5
  switches", "mirrors the X we used", "the way the ... loop does", "stock demo",
  temporal evolution words ("previously", "used to", "now", "originally", "for
  now"), first person ("we" / "our"), or references to past attempts, experiments,
  or how a bug was found. The journey rots and misleads.
- A useful **why** stays; the war story around it goes. Keep "deinit is required:
  close + delProfile alone leaks control-layer state"; drop the "...stops chirping
  after ~5 switches when we tested" tail.
- Forward-looking **TODOs are encouraged** when they tell a future developer
  something actionable, e.g. `TODO(FW-508): pinmux the WU_REQIN pad once confirmed
  on HW`.
- Keep comments **minimal** — add them only where the logic is genuinely
  non-obvious. Never add a comment that describes a change ("removed X", "now does
  Y") rather than what the code does.
- This applies equally to firmware C comments, Python comments/docstrings, and
  design/spec prose in `docs/`.

## Coding

### 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

### 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

### 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

### 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.
