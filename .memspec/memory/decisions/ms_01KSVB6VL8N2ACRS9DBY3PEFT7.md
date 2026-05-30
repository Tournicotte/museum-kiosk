---
id: ms_01KSVB6VL8N2ACRS9DBY3PEFT7
type: decision
state: active
confidence: 0.7
created: '2026-05-30T00:00:00.000Z'
source: claude
tags:
  - cicd
  - infrastructure
  - oracle-cloud
  - deployment
decay_after: '2026-11-26T00:00:00.000Z'
---
# CI/CD pipeline planned on Oracle Cloud Free Tier

Decision: implement CI/CD pipeline using Oracle Cloud Free Tier (always-free resources) for build, test, and APK distribution.

**Why:** Oracle Always Free gives 4x ARM Ampere A1 instances (24 GB RAM total) or 2x AMD Micro VMs — enough to run Flutter builds and host an APK distribution endpoint at zero cost.

**Planned shape:**
- GitHub Actions for CI (lint + test on every PR — free for public repos)
- Oracle Cloud ARM VM for build server / self-hosted runner (flutter build apk)
- Oracle Object Storage (free tier) for APK artifact storage
- Simple APK download endpoint so tablets can pull updates

**Alternatives considered:**
- GitHub Actions cloud runners only — fine for analyze/test but Flutter APK builds are slow on free tier minutes
- Firebase App Distribution — good UX but adds Google dependency
- Codemagic — generous free tier for Flutter specifically, worth revisiting

**Status:** not yet implemented — Phase 5 work.
