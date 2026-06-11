# Session - 2026-04-28

## Topics covered
- Schema backup and restore in Oracle.
- Exploring schema objects with `user_objects`, `user_tables`, `user_constraints`, and `user_dependencies`.
- Using `DBMS_METADATA.GET_DDL` to extract table, index, view, sequence, constraint, and PL/SQL definitions.
- Cleaning exported DDL so it can be reused in another schema.
- Planning migration order based on dependencies.
- Comparing `DBMS_METADATA` with Data Pump tools like `expdp` and `impdp`.

## What I understood
- I understood that a schema backup is not only about copying tables. I need to know which objects exist, how they depend on each other, and in what order they should be recreated. `DBMS_METADATA` is useful when I only have SQL access because it can generate the DDL for existing objects. I also understood that exported DDL often needs cleanup, especially schema names, storage settings, tablespace references, and dependency order.

## What is still confusing

## Questions

## Related concepts
- [Schema backup and restore](../concepts/schema-backup-and-restore.md)
- [DBMS_METADATA](../concepts/dbms-metadata.md)
- [Database object dependencies](../concepts/database-object-dependencies.md)

## Resources used
- See `sql_challenges/challenge-10/`
