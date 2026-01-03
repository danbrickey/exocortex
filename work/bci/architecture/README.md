---
title: "Architecture Diagrams - Visual Documentation Index"
author: "Dan Brickey"
last_updated: "2024-12-09T17:30:00Z"
version: "1.0.0"
category: "architecture-documentation"
tags: ["diagrams", "architecture", "visual-documentation", "reference"]
status: "active"
audience: ["architects", "engineers", "stakeholders"]
---

# Architecture Diagrams - Visual Documentation Index

This directory contains all architectural diagrams for the EDP (Enterprise Data Platform) modernization project. Diagrams are organized by category to support different phases of our architecture inventory and design work.

---

## Directory Structure

### `/current-state/`
**Purpose:** Documents the existing architecture as discovered during Session 1: Current State Documentation
**Contents:**
- Current Data Vault hub, link, and satellite structures
- Existing business key patterns and relationships
- Source system integration patterns
- Current data flow architectures

### `/data-vault-models/`
**Purpose:** Data Vault 2.0 entity relationship diagrams and modeling artifacts
**Contents:**
- Hub design patterns and business key strategies
- Link relationship models and hierarchies
- Satellite attribute groupings and temporal patterns
- Business Vault calculated fields and point-in-time constructs

### `/data-flow/`
**Purpose:** Data pipeline architecture and integration flow diagrams
**Contents:**
- Source system CDC patterns (Legacy FACETS, Gemstone FACETS, VALENZ)
- Real-time vs. batch processing flows
- Medallion architecture layer transitions (Raw → Integration → Curation → Consumption)
- MSK streaming pipeline designs

### `/platform-architecture/`
**Purpose:** Snowflake platform configuration and infrastructure diagrams
**Contents:**
- Warehouse sizing and scaling strategies
- Database organization across environments
- Security and access control models
- Performance optimization patterns

---

## Naming Conventions

**File Naming Pattern:** `YYYY-MM-DD_category_description_version.png`

**Examples:**
- `2024-12-09_current-state_hub-overview_v1.png`
- `2024-12-09_data-vault_person-hub-satellites_v1.png`
- `2024-12-09_data-flow_cdc-integration_v1.png`
- `2024-12-09_platform_warehouse-architecture_v1.png`

---

## Diagram Standards

### Required Elements
- **Title:** Clear, descriptive title
- **Date:** Creation or last update date
- **Version:** Version number for change tracking
- **Context:** Brief description of what the diagram represents
- **Legend:** Key for symbols, colors, or notation used

### Visual Guidelines
- Use consistent colors and symbols across related diagrams
- Include data flow directions with arrows
- Show system boundaries clearly
- Label all entities, relationships, and processes
- Keep diagrams focused - create multiple diagrams rather than overcrowding one

---

## Integration with Documentation

Each diagram should be referenced in relevant documentation:
- **Architecture Baseline:** `ai-resources/context-documents/edp-architecture-baseline.md`
- **Work Plan:** `ai-resources/context-documents/edp-work-plan-breakdown.md`
- **Engineering Guides:** `docs/engineering-knowledge-base/`
- **Meeting Notes:** Document architectural decisions that led to diagram updates

---

## Diagram Inventory

*This section will be updated as diagrams are added to track our visual documentation library.*

### Current State Diagrams
- [ ] Overall Data Vault structure overview
- [ ] Hub inventory and business keys
- [ ] Link relationship patterns
- [ ] Satellite attribute organization
- [ ] Source system integration patterns

### Target State Diagrams
- [ ] Proposed Data Vault enhancements
- [ ] Business Vault calculated field patterns
- [ ] Point-in-time and bridge table designs
- [ ] Performance optimization strategies

---

**Document Maintenance:** Update this index whenever diagrams are added, modified, or deprecated to maintain accurate visual documentation inventory.