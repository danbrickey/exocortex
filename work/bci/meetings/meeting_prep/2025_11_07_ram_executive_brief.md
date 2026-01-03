---
title: "Executive Brief: EDP Architecture Initiatives"
to: "Ram Garimella, Director"
from: "Dan Brickey, Enterprise Data Platform Architect"
date: "2025-11-07"
category: "executive-brief"
decision_deadline: "2025-11-14"
---

# Executive Brief: EDP Architecture Initiatives

---

## Hakkoda Contractor Performance

**Overall Assessment: Highly Positive.** Emily, Odell, Lokendra, and Shweta demonstrated strong technical skills, excellent communication, and deep expertise in healthcare payer data engineering. Engagement exceeded previous contractor experiences significantly.

**Expectation Adjustment**: Initial expectation was finished products requiring customization. Reality was custom builds leveraging prior healthcare experience. Despite mismatch, delivery quality and architecture outcomes exceeded historical contractor performance.

**Measurable Impact**: RBAC model worked on first deployment with minimal tweaks (historical timeline: weeks to months for permission resolution). Environment setup didn't slow engineering work—a first for our environment migrations.

**Recommendation**: Hakkoda brings substantial value; engagement model should be continued with adjusted expectations around custom build vs. finished product delivery.

---

## Environment Hardening Status

**Completed**: Rising Sun → North Star migration; dev/test environment hydration; RBAC model deployment; 1000+ test/model failures systematically resolved.

**Timeline**: 2-week extension beyond initial estimate due to three factors:
1. **Repository deletion**: PHI false positive on test data; work-in-progress branches lost; test/main branches promoted from develop prematurely
2. **Unstable code promotion**: Work-in-progress code in all environments required systematic cleanup (normally resolved in dev before release)
3. **dbt deprecation warnings**: Rapid software evolution (likely AI-assisted development at dbt Labs) requiring deprecation fixes on accelerated timeline

**Outcome**: Codebase healthier; working methods improved; systematic error resolution completed. Extension was time-consuming but resulted in quality improvements justifying the investment.

**Current Status**: Member consecutive coverage temporal merge bug resolved (Nov 6-7); validation in progress; the few remaining failures being addressed systematically.

---

## Business Logic Documentation Process - Collaborative POC

### Overview

Collaborative proof of concept with Data Governance and domain data councils to establish AI-driven business logic documentation workflow. This initiative creates a sustainable model for business-owned technical documentation with engineering synchronization, addressing long-standing requirements drift issues.

### POC Workflow

**Process**: AI-generated logic guides (from code refactoring) → Data Governance facilitation → Data Council ratification → Alation publication → future AI-driven code validation capability

**Status**: Active collaboration with Data Governance (Tyler Head, Nicole Bowen, Tina Day). Framework established; pilot validation in progress.

### Progress to Date

- **4-audience documentation framework**: Executive/Business/BA/Engineering levels established (Logic guide framework, Nov 5, 2025)
- **Terminology standardized**: "Logic Guides" adopted vs. "Business Rules" for better stakeholder communication (Nov 5, 2025)
- **Alation integration workflow**: Engineering Hub staging area defined for business handoff (Nov 4, 2025)
- **Provider data council**: Operational and engaged; PCP attribution logic guide selected as pilot validation (Nov 5, 2025)
- **Member/Product data councils**: Formation underway for Q1 2026 PI planning (Oct 27-Nov 3, 2025)

### Pilot Validation Approach

**Phase 1** (Current): Provider council reviews PCP attribution logic guide to validate format and utility
**Phase 2** (Q1 2026): Expand to Member and Product domains based on Provider feedback
**Phase 3** (Future): Develop Alation return-path for AI-driven code validation against business-ratified guides

### Open Items

**Alation Return-Path Mechanism**
Process to extract business-ratified logic guides from Alation for AI code evaluation is under development. Forward path (engineering → Alation) is ready for deployment; return path is future enhancement not blocking current POC.

**Data Council Coordination**
Three data councils requiring engagement during Q1 PI planning period. Provider council operational and receptive; Member/Product councils forming. Data Governance driving facilitation.

---

**Prepared by**: Dan Brickey
**Date**: November 7, 2025
