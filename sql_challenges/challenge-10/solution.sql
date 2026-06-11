/* ============================================================
   SQL Challenge 10 - Schema Backup & Restore
   ============================================================ */

/* ============================================================
   Exercise 1 - Explore your schema
   ============================================================ */

-- List all objects in the current schema, grouped by type.
SELECT object_type, COUNT(*) AS cnt
FROM user_objects
GROUP BY object_type
ORDER BY object_type;

-- Show more details about each object.
SELECT object_name, object_type, created, last_ddl_time
FROM user_objects
ORDER BY object_type, object_name;

/* ============================================================
   Exercise 2 - Basic GET_DDL
   ============================================================ */

-- Set transform parameters for cleaner output.
BEGIN
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'PRETTY', true);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR', true);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SEGMENT_ATTRIBUTES', false);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'STORAGE', false);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'TABLESPACE', false);
END;
/

SET LONG 100000
SET PAGESIZE 0

-- Get DDL for one table.
-- Replace MY_TABLE with an actual table name from your schema.
SELECT DBMS_METADATA.GET_DDL('TABLE', 'MY_TABLE')
FROM dual;

-- Get DDL for all tables.
SELECT DBMS_METADATA.GET_DDL('TABLE', table_name)
FROM user_tables
ORDER BY table_name;

-- In the output, identify:
-- - Column definitions
-- - Constraints
-- - Storage parameters, if they appear

/* ============================================================
   Exercise 3 - Clean DDL for portability
   ============================================================ */

-- Remove schema names and extra storage details from the generated DDL.
BEGIN
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'EMIT_SCHEMA', false);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'PRETTY', true);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR', true);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SEGMENT_ATTRIBUTES', false);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'STORAGE', false);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'TABLESPACE', false);
END;
/

-- With EMIT_SCHEMA:    CREATE TABLE "SALES"."ORDERS" ...
-- Without EMIT_SCHEMA: CREATE TABLE "ORDERS" ...

SELECT DBMS_METADATA.GET_DDL('TABLE', table_name)
FROM user_tables
WHERE ROWNUM = 1;

/* ============================================================
   Exercise 4 - Plan a migration
   ============================================================ */

-- Scenario: migrating from SCHEMA_OLD to SCHEMA_NEW.

-- First, identify schema names embedded in the DDL.
SELECT DBMS_METADATA.GET_DDL('TABLE', table_name)
FROM user_tables
WHERE table_name = 'ANY_TABLE_WITH_FK';

-- Check for foreign key relationships.
SELECT constraint_name, table_name, r_constraint_name
FROM user_constraints
WHERE constraint_type = 'R';

-- Migration checklist:
-- 1. Export all DDL with EMIT_SCHEMA = false.
-- 2. Review foreign key constraints for schema references.
-- 3. Update constraint references if needed.
-- 4. Reload in order: tables, constraints, indexes, views, code.

/* ============================================================
   Exercise 5 - Dependency order
   ============================================================ */

-- See all dependencies in the schema.
SELECT referenced_name, referencing_name, referencing_type
FROM user_dependencies
ORDER BY referenced_name;

-- Find objects that depend on tables.
SELECT referencing_name, referencing_type
FROM user_dependencies
WHERE referenced_name IN (
  SELECT table_name
  FROM user_tables
)
ORDER BY referencing_type, referencing_name;

-- Find direct dependencies for one object.
-- Replace PROC_NAME with an actual object name.
SELECT referenced_name, referenced_type
FROM user_dependencies
WHERE referencing_name = 'PROC_NAME';

-- Build a simple dependency list for PL/SQL objects.
SELECT referencing_name,
       referencing_type,
       LISTAGG(referenced_name, ', ') WITHIN GROUP (ORDER BY referenced_name) AS dependencies
FROM user_dependencies
WHERE referencing_type IN ('PACKAGE', 'PROCEDURE', 'FUNCTION')
GROUP BY referencing_name, referencing_type
ORDER BY referencing_type, referencing_name;

/* ============================================================
   Exercise 6 - Design your own backup strategy
   ============================================================ */

-- Given:
-- - No expdp access
-- - No directory privileges
-- - Need to move your schema to another database
-- - Only SQL access

-- Step 1: Document the current schema structure.
SELECT object_type, COUNT(*)
FROM user_objects
GROUP BY object_type;

SELECT table_name, num_rows
FROM user_tables
ORDER BY num_rows DESC;

-- Step 2: Extract all DDL.
BEGIN
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'PRETTY', true);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR', true);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SEGMENT_ATTRIBUTES', false);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'STORAGE', false);
  DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'TABLESPACE', false);
END;
/

-- Extract tables.
SELECT DBMS_METADATA.GET_DDL('TABLE', table_name)
FROM user_tables;

-- Extract indexes.
SELECT DBMS_METADATA.GET_DDL('INDEX', index_name)
FROM user_indexes;

-- Extract views.
SELECT DBMS_METADATA.GET_DDL('VIEW', view_name)
FROM user_views;

-- Extract sequences.
SELECT DBMS_METADATA.GET_DDL('SEQUENCE', sequence_name)
FROM user_sequences;

-- Extract constraints.
SELECT DBMS_METADATA.GET_DDL('CONSTRAINT', constraint_name)
FROM user_constraints
WHERE constraint_type IN ('P', 'U', 'R', 'C')
AND generated = 'USER NAME';

-- Extract triggers.
SELECT DBMS_METADATA.GET_DDL('TRIGGER', object_name)
FROM user_objects
WHERE object_type = 'TRIGGER';

-- Extract code.
SELECT DBMS_METADATA.GET_DDL('PROCEDURE', object_name)
FROM user_objects
WHERE object_type = 'PROCEDURE';

SELECT DBMS_METADATA.GET_DDL('FUNCTION', object_name)
FROM user_objects
WHERE object_type = 'FUNCTION';

SELECT DBMS_METADATA.GET_DDL('PACKAGE', object_name)
FROM user_objects
WHERE object_type = 'PACKAGE';

-- Step 3: Reload in the new schema using the proper order.
-- 1. Create tables without constraints.
-- 2. Create sequences.
-- 3. Create indexes.
-- 4. Add constraints.
-- 5. Create views.
-- 6. Create procedures, functions, and packages.
-- 7. Create triggers.

-- Step 4: Verify everything transferred.
SELECT object_type, COUNT(*)
FROM user_objects
GROUP BY object_type;

SELECT table_name, num_rows
FROM user_tables
ORDER BY table_name;

SELECT index_name, table_name
FROM user_indexes
ORDER BY index_name;

/* ============================================================
   Discussion questions
   ============================================================ */

-- Q1:
-- DBMS_METADATA exports DDL, but it does not export the table data by itself.
-- It also requires more manual work because the developer has to copy or spool
-- the output. expdp is better for complete backups because it can export data
-- and metadata, but it needs directory privileges.

-- Q2:
-- If there are circular dependencies, I would create the main objects first and
-- enable the constraints later. For PL/SQL packages, I would create the package
-- specification first and the package body after that.

-- Q3:
-- My plan would be:
-- 1. Document the source schema with user_objects and user_tables.
-- 2. Set EMIT_SCHEMA = false and extract clean DDL.
-- 3. Check dependencies and schema-qualified references.
-- 4. Review and clean the DDL.
-- 5. Run the DDL in the correct order.
-- 6. Verify object counts and run sample queries.
-- 7. If data is needed, export it separately with INSERT statements or CSV.
