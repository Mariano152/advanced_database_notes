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


## Questions


## Related concepts
- [ETL and data warehouse](../concepts/etl-and-data-warehouse.md)

## Resources used
- See `sql_challenges/challenge-13/`
