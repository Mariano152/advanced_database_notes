# Session - 2026-04-14

## Topics covered
- Oracle indexes.
- Execution plans in freesql.com.
- Full table scan versus index scan.
- Cardinality and selectivity.
- Date range queries with indexes.
- Composite indexes.
- How functions can prevent normal index usage.

## What I understood
- I understood that indexes are not always used automatically. Oracle's optimizer decides whether using an index is cheaper than scanning the full table.
- I understood that `site_id` is low cardinality because it only has values from 1 to 5. Because many rows can match each value, an index on only `site_id` may not help much.
- I understood that `patient_id` is high cardinality because it has many possible values, so it is usually a better candidate for indexing.
- I understood that a date index can help with smaller date ranges, but if the range is too large Oracle may still choose a full table scan.
- I understood that composite indexes depend on column order. An index on `(patient_id, visit_date)` works best when the query filters by `patient_id` first.
- I understood that `TO_CHAR(patient_id)` changes the indexed expression, so a normal index on `patient_id` may not be used.

## What is still confusing

## Questions

## Related concepts
- [Indexes](../concepts/indexes.md)
- [Execution plans](../concepts/execution-plans.md)
- [Cardinality and selectivity](../concepts/cardinality-selectivity.md)

## Resources used
- See `resources/`
- `sql_challenges/challenge-08/`

