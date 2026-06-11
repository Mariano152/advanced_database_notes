# Schema Backup And Restore

## My understanding
A schema backup is a way to save the structure of a database schema so it can be recreated later. In Oracle, the structure includes tables, constraints, indexes, views, sequences, triggers, procedures, functions, and packages. A restore means running the exported definitions again in the correct order so the new schema behaves like the old one.

## Why it matters
Backups and migrations fail easily when dependencies are ignored. For example, a foreign key cannot point to a table that does not exist yet, and a view cannot compile correctly if its base table is missing. A good backup strategy documents what exists, exports clean DDL, reloads objects in a safe order, and verifies the result.

## Example
```sql
SELECT object_type, COUNT(*) AS object_count
FROM user_objects
GROUP BY object_type
ORDER BY object_type;
```

This query gives a quick inventory of the schema before planning a backup or migration.
