# SQL Challenge 10 - Schema Backup And Restore

## Problem
You need to inspect an Oracle schema and design a backup/restore strategy using only SQL access. You do not have Data Pump directory privileges, so you must rely on data dictionary views and `DBMS_METADATA`.

## Goals
- Explore the objects that exist in your schema.
- Generate DDL using `DBMS_METADATA.GET_DDL`.
- Clean exported DDL so it can be reused in another schema.
- Identify dependencies that affect reload order.
- Design a practical backup and migration checklist.

## Exercise 1 - Explore Your Schema
List all objects in your schema using `user_objects`. Group them by object type and count them. Then list object details such as name, type, creation date, and last DDL time.

## Exercise 2 - Basic GET_DDL
Set useful `DBMS_METADATA` transform parameters and generate DDL for one table. Then generate DDL for all tables in the schema.

Identify the key parts of the output:
- Column definitions.
- Constraints.
- Storage or tablespace details, if included.

## Exercise 3 - Clean DDL For Portability
Configure `DBMS_METADATA` so exported DDL does not include schema names, storage clauses, or tablespace clauses. Compare the output before and after setting `EMIT_SCHEMA` to `false`.

## Exercise 4 - Plan A Migration
You are moving from `SCHEMA_OLD` to `SCHEMA_NEW`. Decide what must be reviewed or changed in the exported DDL before loading it into the new schema.

## Exercise 5 - Dependency Order
Use `user_dependencies` and `user_constraints` to understand which objects depend on other objects. Use that information to decide a safe restore order.

## Exercise 6 - Design Your Own Backup Strategy
Given:
- No `expdp` access.
- No directory privileges.
- Need to move the schema to another database.
- Only SQL access is available.

Write the steps you would take to document, export, reload, and verify the schema.

## Discussion
Answer these in words:

1. What are the limitations of `DBMS_METADATA` compared with `expdp`?
2. If you have circular dependencies, how would you handle the reload?
3. Your company gives you read-only access to the old database and asks you to recreate the schema on a new database. What is your plan?
