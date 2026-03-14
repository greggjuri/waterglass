# Code Examples

This folder contains reference patterns for Claude Code to follow when implementing features.

## Purpose

These examples serve as:
1. **Living documentation** of coding standards
2. **Reference patterns** Claude Code can follow
3. **Consistency enforcers** across the codebase

## Contents

### Backend Patterns
- `{backend}/handler_pattern.{ext}` - Standard API handler structure
- `{backend}/db_pattern.{ext}` - Database access patterns
- `{backend}/service_pattern.{ext}` - Business logic service structure
- `{backend}/model_pattern.{ext}` - Data model definitions

### Infrastructure Patterns
- `{infrastructure}/stack_pattern.{ext}` - Standard IaC stack structure
- `{infrastructure}/resource_pattern.{ext}` - Common resource configurations

### Frontend Patterns
- `{frontend}/component_pattern.tsx` - React component structure
- `{frontend}/hook_pattern.ts` - Custom hook structure
- `{frontend}/service_pattern.ts` - API service pattern

## Usage

When implementing a new feature, Claude Code should:
1. Check if a relevant example exists
2. Follow the patterns shown
3. Adapt to specific requirements while maintaining consistency

## Creating New Patterns

When you establish a pattern that should be followed:
1. Create a minimal example in this folder
2. Add comments explaining key decisions
3. Update this README

## Pattern Guidelines

- Keep examples minimal - show pattern, not complete implementation
- Add comments for non-obvious decisions
- Include both happy path and error handling
- Show test patterns alongside implementation patterns

---

*Add your specific patterns below as you establish them*
