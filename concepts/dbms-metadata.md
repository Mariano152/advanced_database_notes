# DBMS_METADATA

## My understanding
`DBMS_METADATA` is an Oracle package that can generate the DDL for existing database objects. It is useful when I need to recreate objects and I only have SQL access. The most common function is `DBMS_METADATA.GET_DDL`, which can return `CREATE TABLE`, `CREATE INDEX`, `CREATE VIEW`, and other object definitions.

## Why it matters
It gives visibility into how objects are defined inside the database. It is not the same as a full export tool because it focuses on metadata and DDL, not the table data itself. Still, it is a strong option when I cannot use Data Pump or do not have directory privileges.

## Example
```sql
BEGIN
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'PRETTY', true);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR', true);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'EMIT_SCHEMA', false);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SEGMENT_ATTRIBUTES', false);
END;
/

SELECT DBMS_METADATA.GET_DDL('TABLE', table_name)
FROM user_tables
ORDER BY table_name;
```
