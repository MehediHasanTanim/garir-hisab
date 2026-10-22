# ADR-0004: Riverpod for state and DI

- **Status:** Accepted
- **Date:** 2026-10-22

## Context
We need testable dependency injection and reactive state over Drift streams.

## Decision
Use flutter_riverpod.

## Consequences
Compile-safe providers and easy test overrides. Alternative rejected: Bloc (more boilerplate).
