# ADR-0001: Flutter for the mobile app

- **Status:** Accepted
- **Date:** 2026-10-22

## Context
Target users have low-end Android phones (2 GB RAM). We need one codebase, good Bengali text support and small build size.

## Decision
Use Flutter (Dart), Android first.

## Consequences
Single codebase, smooth rendering on low-end devices. Larger baseline APK than native; mitigated by split-per-ABI and font subsetting. Alternative rejected: React Native (bigger runtime, more native glue).
