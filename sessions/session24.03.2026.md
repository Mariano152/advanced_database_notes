# Session - 2026-03-24

## Topics covered
- PL/SQL triggers for automating actions before insert, update, and delete operations.
- Use of pseudocolumns like `:NEW` and `:OLD` to read or assign row values inside triggers.
- Basic database security rules using the current database user and `RAISE_APPLICATION_ERROR`.
- Controlling who can update or delete records in the `PET_CARE_LOG` table.

## What I understood
- I understood that triggers can help automate repeated tasks in the database, like saving the current date and user whenever a new care log record is created. I also understood that triggers can enforce rules directly in the database, so the protection does not depend only on the application. In this challenge, the insert trigger fills audit columns, the update trigger checks that the same user who created the record is the one editing it, and the delete trigger only allows the manager user to remove records.

## What is still confusing
- 

## Questions
- 

## Related concepts
- [Concept name](../concepts/concept-name.md)

## Resources used
- See `resources/`
