# Database Object Dependencies

## My understanding
Database object dependencies describe which objects need other objects to exist. A view can depend on a table, a procedure can depend on a table or function, and a foreign key depends on a referenced primary key or unique key. Oracle exposes these relationships through views such as `user_dependencies` and `user_constraints`.

## Why it matters
Dependencies affect migration order. If objects are restored in the wrong order, some DDL statements may fail or objects may be created as invalid. A safer approach is to create base tables first, then sequences and indexes, then constraints, then views and PL/SQL code.

## Example
```sql
SELECT referenced_name, referencing_name, referencing_type
FROM user_dependencies
ORDER BY referenced_name, referencing_name;
```

This helps identify which objects must exist before dependent objects can compile correctly.
