
/* ============================================================
   Exercise 1 - Find the slow query
   ============================================================ */

SELECT *
FROM patient_visits
WHERE site_id = 3;

-- a) What scan type do you see? Why?
-- I expect a full table scan. site_id has only five possible values,
-- so site_id = 3 can match a large percentage of the table. Because
-- the filter is not selective, Oracle may choose to scan the whole table.

-- b) site_id has values 1-5. Is this high or low cardinality?
-- Low cardinality, because there are only five possible values.

-- c) Would adding an index on site_id help? Why or why not?
-- Usually no. An index on a low-cardinality column may not help because
-- many rows have the same value. Oracle may still prefer a full table scan.

/* ============================================================
   Exercise 2 - Create an index and see if it helps
   ============================================================ */

CREATE INDEX idx_pv_visit_date
ON patient_visits(visit_date);

BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'PATIENT_VISITS', cascade => TRUE);
END;
/

SELECT *
FROM patient_visits
WHERE visit_date BETWEEN SYSDATE - 30 AND SYSDATE;

-- a) Does Oracle use the index for this range?
-- It depends on selectivity. If the 30-day range returns a small enough
-- part of the table, Oracle may use the index. If many rows match, it may
-- still choose a full table scan.

SELECT *
FROM patient_visits
WHERE visit_date BETWEEN SYSDATE - 7 AND SYSDATE;

-- b) Change the range to the last 7 days. Does the plan change?
-- It can change because 7 days is more selective than 30 days. A smaller
-- range makes an index range scan more likely.

SELECT *
FROM patient_visits
WHERE visit_date BETWEEN SYSDATE - 700 AND SYSDATE;

-- c) Change to the last 700 days. What happens?
-- Oracle is likely to choose a full table scan because this range covers
-- almost all of the generated data.

-- d) Why does the range size affect whether Oracle uses the index?
-- The range size changes selectivity. Small ranges return fewer rows, so
-- an index can help. Large ranges return many rows, so a full table scan
-- can be cheaper.

/* ============================================================
   Exercise 3 - Composite index
   ============================================================ */

CREATE INDEX idx_pv_patient_date
ON patient_visits(patient_id, visit_date);

BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(USER, 'PATIENT_VISITS', cascade => TRUE);
END;
/

SELECT *
FROM patient_visits
WHERE patient_id = 1234
  AND visit_date > SYSDATE - 90;

-- a) Does the plan use the composite index?
-- Yes, it should be able to use the composite index because the query
-- filters by the leading column, patient_id, and then by visit_date.

SELECT *
FROM patient_visits
WHERE patient_id = 1234;

-- This can still use the composite index because patient_id is the first
-- column in the index.

SELECT *
FROM patient_visits
WHERE visit_date > SYSDATE - 90;

-- b) Now try querying ONLY on visit_date. Does the composite index get used?
-- Usually no. The composite index starts with patient_id, so Oracle cannot
-- efficiently use it when the query only filters by visit_date.

-- c) What's the rule about column order in composite indexes?
-- The leading column matters. A composite index is most useful when the
-- query filters on the first indexed column, or on the first column plus
-- later columns in the same order.

/* ============================================================
   Exercise 4 - Function that breaks an index
   ============================================================ */

SELECT *
FROM patient_visits
WHERE patient_id = 5432;

SELECT *
FROM patient_visits
WHERE TO_CHAR(patient_id) = '5432';

-- a) What scan type did the second query use?
-- I expect a full table scan unless there is a function-based index on
-- TO_CHAR(patient_id).

-- b) Why does wrapping a column in a function break index use?
-- A normal index stores patient_id as a number. TO_CHAR(patient_id)
-- creates a different expression, so Oracle cannot use the normal index
-- efficiently.

-- c) How would you rewrite the second query to allow index use?
SELECT *
FROM patient_visits
WHERE patient_id = 5432;

/* ============================================================
   Exercise 5 - Discussion: real-world scenarios
   ============================================================ */

-- Scenario A:
-- A reporting table gets loaded once per night. During the day, analysts
-- run SELECT queries by date range. The table has 50 million rows.
-- I would add an index on the date column because the table is large and
-- analysts search by date range. The concern is that very large ranges may
-- still use a full table scan, and the index adds storage and load cost.

-- Scenario B:
-- An OLTP orders table gets 10,000 inserts per minute. Support staff look
-- up orders by customer_id or order_status. order_status has 4 values.
-- I would add an index on customer_id because it is likely selective.
-- I would be careful with order_status because it has low cardinality.
-- If searches often use both customer_id and order_status, a composite
-- index like (customer_id, order_status) could help. The main concern is
-- insert overhead because the table receives many writes.

-- Scenario C:
-- A patient table has an email column, unique per patient. There are
-- 5 million patients and the app frequently searches by email.
-- A unique index on email is best because it supports fast lookup and
-- enforces that each email belongs to only one patient.

/* ============================================================
   Cleanup
   ============================================================ */

DROP INDEX idx_pv_patient_date;
DROP INDEX idx_pv_visit_date;

