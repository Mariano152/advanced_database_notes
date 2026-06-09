# Session - 2026-04-21

## Topics covered
- Manual transactions using `COMMIT`, `ROLLBACK`, and `SAVEPOINT`.
- How transactions protect related database changes so they succeed or fail together.
- Creating stored procedures to package database logic.
- Error handling in PL/SQL with `RAISE_APPLICATION_ERROR`, `ROLLBACK`, and re-raising exceptions.
- Difference between procedures and functions in Oracle.

## What I understood
- I understood that transactions are important when several changes belong to the same operation, like moving money from one account to another. If one step fails, `ROLLBACK` helps return the database to a safe state instead of leaving partial changes. I also understood that `SAVEPOINT` is useful when I only want to undo part of the work, not the whole transaction. Stored procedures help keep this logic inside the database, while functions are better when I need to return a value and use it in a query.

## What is still confusing

## Questions

## Related concepts
- [Concept name](../concepts/concept-name.md)

## Resources used
- See `resources/`
- `sql_challenges/challenge-09/`
