# CodeMap - Codebase Structural Index
`codemap` is an effcient tool to search and explore the code.

## When to Use
Understand the file structure. Locate relevant sections in the code. Locate line numbers. Locate code segments by name.
When I want to Read the entire file, I consider using `codemap find` or `codemap-show` first, because narrowing down the relevant lines is more token-efficient.

## Example
1. **Search before scanning**: Always use `codemap find` instead of grep.
I run:
```bash
codemap find "UserService"
```
It outputs:
```
src/services/user.ts:15-189 [class] UserService
  (config: Config)
```
I understand:
class UserService is defined in L15-189 of src/services/user.ts

2. **Explore file structure**: Use `codemap-show` to understand file layout.
I run:
```bash
codemap-show src/services/user.ts
```
It outputs:
```
File: src/services/user.ts (hash: a3f2b8c1)
Lines: 542
Language: typescript

Symbols:
- UserService [class] L15-189
  - constructor [method] L20-35
  - getUser [method] L37-98
    (userId: string) : Promise<User>
  - createUser [async_method] L100-145
    (data: CreateUserDto) : Promise<User>
```
I understand:
UserService has three methods `constructor`, `getUser`, `createUser`.
constructor is defined in L20-35.
getUser takes string argument `userId` and return Promise<User>. It is defined in L37-98.
createUser takes CreateUserDto argument `data` and return Promise<User>. It is defined in L100-145.
There are no other method in UserService.

**Important**: `codemap-show` does not recognize directory arguments. `codemap-show` can take one or multiple files or wildcards (`codemap-show src/*.ts`). `codemap-show` on all files (`find -f . | xargs codemap-show`) can be very lengthy, so it should be avoided in a large project. `codemap-show` can show the outline of css files and markdown documents too. For show command, use hyphens (`codemap-show`), not without it (`codemap show`).

## Best Practices:
1. **Search before scanning**: Always use `codemap find` first, before grep.
2. **Refine context**: When I find occurences by grep, I determine how many lines before and after the occurence by invoking `codemap-show` data.
3. **Remember file structure**: I remember the `codemap-show` data. I recall these data when I need later.
4. **Run codemap again after edits**: When I want to read the symbol definitions based on remembered line numbers, I check if I have edited the relevant files after I acquired the line numbers. If so, I will run `codemap find` or `codemap-show` again to ensure the fresh line numbers.

## Quick Reference

```bash
# Find a symbol by name (case-insensitive)
codemap find "SymbolName"

# Filter by type
codemap find "handle" --type method
codemap find "User" --type class
codemap find "Config" --type interface

# Fuzzy search
codemap find -f "account"

# Show file structure with all symbols
codemap-show path/to/file.ts
codemap-show path/to/*.ts

# Check if index is up-to-date
codemap validate

# View index statistics
codemap stats
```

## Symbol Types

| Type | Description |
|------|-------------|
| `class` | Class declaration |
| `function` | Function declaration |
| `method` | Class method |
| `async_function` | Async function |
| `async_method` | Async class method |
| `interface` | TypeScript interface |
| `type` | TypeScript type alias |
| `enum` | Enum declaration |

## Example Session

Task: "Fix the authentication bug in the login handler"

```bash
# 1. Find relevant symbols
codemap find "login"
# → src/auth/handlers.ts:45-92 [function] handleLogin

# 2. Check file structure
codemap show src/auth/handlers.ts
# Shows handleLogin and related functions with line ranges

# 3. Read only the relevant function (lines 45-92)
# ... make your fix ...

# 4. If you need related code, find it
codemap find "validateToken"
# → src/auth/utils.ts:12-38 [function] validateToken
```
