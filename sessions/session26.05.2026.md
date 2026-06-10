# Session - 2026-05-26

## Topics covered
- ETL process: extract, transform, and load.
- Difference between OLTP tables and data warehouse tables.
- Assignment history using `valid_from` and `valid_to`.
- Triggers for automatically logging assignment changes.
- Star schema design with dimension and fact tables.
- Loading daily ticket metrics into a fact table.

## What I understood
- I understood that OLTP tables store the current operational state, while a data warehouse stores data in a structure that is easier to analyze. Assignment history is important because the current assignee is not always the same person who owned the ticket when it was created or resolved. The ETL process uses the history table to decide which agent gets credit for each event.

## What is still confusing
- I still need more practice deciding the exact grain of a fact table.
- I also want to understand better when to do transformations in SQL and when to do them in pandas.

## Questions
- Should the fact table count created and resolved tickets in the same row or separate event rows?
- How often should this ETL pipeline run in a real system?
- What should happen if assignment history has gaps or overlapping date ranges?

## Related concepts
- [ETL and data warehouse](../concepts/etl-and-data-warehouse.md)

## Resources used
- See `sql_challenges/challenge-13/`
