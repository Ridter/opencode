# OpenCode Agent Guidelines

This document provides guidelines for AI agents working in the OpenCode repository.

## Repository Overview

- **Runtime**: Bun with TypeScript ESM modules
- **Package Manager**: Bun (v1.3.6+)
- **Monorepo**: Uses Bun workspaces with Turbo for task orchestration
- **Default Branch**: `dev`

## Build/Test Commands

### Installation

```bash
bun install
```

### Running OpenCode

```bash
bun run dev                                    # Run from root
bun run --conditions=browser ./src/index.ts    # Run from packages/opencode
```

### Type Checking

```bash
bun run typecheck          # From root (runs turbo typecheck)
bun run typecheck          # From packages/opencode (uses tsgo)
```

### Testing

```bash
# Run all tests (from packages/opencode)
bun test

# Run a single test file
bun test test/tool/bash.test.ts

# Run tests matching a pattern
bun test --grep "tool.bash"
```

### SDK Regeneration

```bash
./packages/sdk/js/script/build.ts    # Regenerate JavaScript SDK
./script/generate.ts                  # Regenerate SDK after server changes
```

## Code Style Guidelines

### General Principles

- Keep things in one function unless composable or reusable
- Rely on type inference; avoid explicit type annotations unless necessary for exports
- Use Bun APIs when possible (e.g., `Bun.file()`, `Bun.write()`)
- Avoid using the `any` type
- Prefer single-word variable names where possible

### Avoid `let` Statements

Use `const` with ternary operators or early returns instead of `let` with if/else.

```ts
// Good
const foo = condition ? 1 : 2

// Bad
let foo
if (condition) foo = 1
else foo = 2
```

### Avoid `else` Statements

Prefer early returns or IIFE patterns.

```ts
// Good
function foo() {
  if (condition) return 1
  return 2
}

// Bad
function foo() {
  if (condition) return 1
  else return 2
}
```

### Avoid Unnecessary Destructuring

Preserve context by using dot notation.

```ts
// Good
obj.a
obj.b

// Bad
const { a, b } = obj
```

### Avoid `try`/`catch` Where Possible

Use Result patterns or let errors propagate naturally.

### Naming Conventions

- **Variables/Functions**: camelCase, prefer single words
- **Classes/Namespaces**: PascalCase
- **Files**: kebab-case for most files

### Imports

- Use relative imports for local modules
- Named imports preferred over default imports
- Path aliases: `@/*` maps to `./src/*`, `@tui/*` maps to `./src/cli/cmd/tui/*`

```ts
import z from "zod"
import { Tool } from "./tool"
import { Log } from "../util/log"
import { Instance } from "@/project/instance"
```

## Architecture Patterns

### Namespace Pattern

Code is organized using TypeScript namespaces for module encapsulation.

```ts
export namespace Storage {
  const log = Log.create({ service: "storage" })

  export async function read<T>(key: string[]) { ... }
  export async function write<T>(key: string[], content: T) { ... }
}
```

### Tool Definition

Tools use `Tool.define()` with Zod schemas for parameter validation.

```ts
export const ReadTool = Tool.define("read", {
  description: DESCRIPTION,
  parameters: z.object({
    filePath: z.string().describe("The path to the file to read"),
    offset: z.coerce.number().optional(),
  }),
  async execute(params, ctx) {
    // Implementation
    return { title, output, metadata: { preview, truncated } }
  },
})
```

### Logging

Use the `Log.create()` pattern with a service identifier.

```ts
const log = Log.create({ service: "session" })
log.info("message", { key: "value" })
log.error("failed", { error })
```

### Lazy Initialization

Use the `lazy()` helper for deferred initialization.

```ts
import { lazy } from "../util/lazy"

const state = lazy(async () => {
  // Expensive initialization
  return { dir }
})
```

### Error Handling

Use `NamedError.create()` for typed errors with Zod schemas.

```ts
export const NotFoundError = NamedError.create("NotFoundError", z.object({ message: z.string() }))
```

### Context and DI

- Pass `sessionID` in tool context
- Use `Instance.provide()` for dependency injection in tests

## Testing Guidelines

- **Avoid mocks**: Tests should test actual implementation
- **No logic duplication**: Don't duplicate implementation logic in tests
- **Use fixtures**: Use `tmpdir()` from `test/fixture/fixture.ts` for temp directories
- **Test framework**: Bun's built-in test runner with `bun:test`

```ts
import { describe, expect, test } from "bun:test"
import { tmpdir } from "../fixture/fixture"

describe("feature", () => {
  test("behavior", async () => {
    await using tmp = await tmpdir({ git: true })
    // Test implementation
    expect(result).toBe(expected)
  })
})
```

## Formatting

- **Prettier**: Semi-colons disabled, print width 120
- **No trailing semicolons**
- **Double quotes** for strings in most cases

## Agent Behavior

- **Parallel tools**: ALWAYS USE PARALLEL TOOLS WHEN APPLICABLE
- **Automation**: Execute requested actions without confirmation unless blocked by missing info or safety concerns
- **File operations**: Prefer editing existing files over creating new ones

## Key Directories

- `packages/opencode/` - Main OpenCode application
- `packages/opencode/src/tool/` - Tool implementations
- `packages/opencode/src/session/` - Session management
- `packages/opencode/test/` - Test files
- `packages/sdk/js/` - JavaScript SDK
- `packages/web/` - Web interface
