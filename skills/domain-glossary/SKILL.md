---
name: domain-glossary
description: Build and maintain the project's shared vocabulary (ubiquitous language) in a repo-root CONTEXT.md. Use when pinning down terminology, when the same concept keeps getting different names, when a term is ambiguous or overloaded, or when brainstorming/spec-interview resolves a new domain term. 中文触发：定术语、统一叫法、术语表。
---

# Domain Glossary

Maintain the project's ubiquitous language: one canonical term per concept, recorded in `CONTEXT.md` at the repo root, used consistently in conversation, docs, and code.

Merely *reading* `CONTEXT.md` for vocabulary is not this skill — that is a habit every conversation should have. This skill is for when the vocabulary itself changes: a term is coined, sharpened, or found ambiguous.

## CONTEXT.md format

````md
# {Project Name}

{One or two sentences: what this project is.}

## Language

**Order**:
A request from a customer to buy specific items.
_Avoid_: purchase, transaction

**Invoice**:
A request for payment sent after delivery.
_Avoid_: bill, payment request

## Flagged ambiguities

- "backlog" meant both the tool and the work inside it — resolved: the
  tool is the **Issue tracker**; "backlog" is no longer a domain term.
````

An optional **Relationships** section (how terms relate: "an **Order** holds many **Line items**") is worth adding once terms start referencing each other.

## Rules

- **Terms keep their code-native form** (usually English). **Definitions are written in the working language of the conversation** — Chinese definitions if user and agent talk in Chinese.
- **Be opinionated.** When multiple words exist for one concept, pick the best and list the rest under `_Avoid_`.
- **Keep definitions tight.** One or two sentences. Define what it IS, not what it does.
- **Project-specific terms only.** General programming concepts (timeout, retry, cache) don't belong, however often the project uses them.
- **Group terms under subheadings** when natural clusters emerge; otherwise a flat list.
- **A glossary and nothing else.** No implementation details, no specs, no decisions. Decisions and their rationale go to `.planning/findings.md`.

## During any design or planning conversation

- **Challenge against the glossary.** When the user's wording conflicts with `CONTEXT.md`, call it out immediately: "The glossary defines *cancellation* as X, but you seem to mean Y — which is it?"
- **Sharpen fuzzy language.** When a term is vague or overloaded, propose a precise canonical term: "You said *account* — the Customer or the User? Those are different things."
- **Stress-test with concrete scenarios.** Invent edge-case scenarios that force precise boundaries between neighboring concepts.
- **Cross-reference with code.** When the stated model contradicts what the code does, surface the contradiction and resolve which side is right.
- **Update `CONTEXT.md` on the spot.** The moment a term is resolved, write it — don't batch glossary updates for later. Create the file lazily: only when the first term is resolved, not as empty scaffolding.
