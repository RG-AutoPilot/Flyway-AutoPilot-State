# Flyway Oracle Ignore Rules - Full Guide

This repository includes a **comprehensive IgnoreRules.scpf file** for Flyway projects using Redgate Compare for Oracle.

## ✅ Purpose
Ignore Rules allow you to include or exclude specific Oracle objects during schema comparison. This helps you avoid deploying unwanted objects like test packages or temporary tables.

---

## 📂 Included Object Types
The provided file includes all major Oracle object types:
- function
- job
- materializedView
- materializedViewLog
- package
- packageBody
- procedure
- publicSynonym
- queue
- queueTable
- sequence
- synonym
- table
- trigger
- type
- userObjectPrivileges
- view

Each type defaults to `"."` (include all objects), except **package** and **packageBody**, which exclude objects starting with `TEST` or `ZZZ`.

---

## 🛠 How to Modify Rules
- **Include all objects of a type**:
```json
"table": ["."]
```

- **Ignore all objects of a type**:
```json
"table": ["\!"]
```

- **Include only objects starting with APP**:
```json
"table": ["^APP"]
```

- **Exclude objects ending with _ARCH**:
```json
"table": ["\!_ARCH$"]
```

- **Combine conditions (AND)**:
```json
"table": ["^APP+\&USER"]
```

---

## 🔍 Common Operators
- `.` → Match everything
- `^PREFIX` → Starts with PREFIX
- `SUFFIX$` → Ends with SUFFIX
- `\!` → Negate (exclude)
- `\&` → Logical AND

Multiple patterns in a list = OR logic.

---

## ⚠ Troubleshooting ORA-00936 Errors
This error usually occurs when:
- You use `\!` incorrectly (e.g., double backslash instead of single in JSON).
- The pattern list is empty.

✅ Correct way to ignore all objects:
```json
"table": ["\!"]
```

❌ Incorrect:
```json
"table": ["\\!"]
```

---

## 🔗 Flyway Integration
Add this to your `flyway.toml`:
```toml
[redgateCompare.oracle]
ignoreRulesFile = "IgnoreRules.scpf"
```

Place `IgnoreRules.scpf` in your Flyway project root.

---

## 📚 References
- [Oracle Ignore Rules Format](https://documentation.red-gate.com/fd/oracle-ignore-rules-format-282626592.html)
- [Flyway + Redgate Compare Integration](https://documentation.red-gate.com/fd)
