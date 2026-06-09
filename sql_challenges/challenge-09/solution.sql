/* ============================================================
   SQL Challenge 09 - Transactions and Stored Procedures
   ============================================================ */

/* ============================================================
   Setup
   ============================================================ */

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE accounts PURGE';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

CREATE TABLE accounts (
    account_id   NUMBER PRIMARY KEY,
    owner_name   VARCHAR2(50) NOT NULL,
    balance      NUMBER(10,2) NOT NULL CHECK (balance >= 0)
);

INSERT INTO accounts VALUES (1, 'Alice', 1000.00);
INSERT INTO accounts VALUES (2, 'Bob', 500.00);
INSERT INTO accounts VALUES (3, 'Charlie', 250.00);
COMMIT;

SELECT account_id, owner_name, balance
FROM accounts
ORDER BY account_id;

/* ============================================================
   Exercise 1 - Manual transaction
   Transfer $50 from Charlie to Alice.
   ============================================================ */

SELECT account_id, owner_name, balance
FROM accounts
ORDER BY account_id;

UPDATE accounts
SET balance = balance - 50
WHERE account_id = 3;

UPDATE accounts
SET balance = balance + 50
WHERE account_id = 1;

COMMIT;

SELECT account_id, owner_name, balance
FROM accounts
ORDER BY account_id;

/* ============================================================
   Exercise 2 - Catch yourself with ROLLBACK
   Attempt a $10,000 transfer from Bob to Charlie, then undo it.
   ============================================================ */

SELECT account_id, owner_name, balance
FROM accounts
ORDER BY account_id;

-- Bob only has $500, so this transfer should not be committed.
-- Adding to Charlie first shows why rollback matters if one step has
-- already succeeded before the full transfer fails.
UPDATE accounts
SET balance = balance + 10000
WHERE account_id = 3;

SELECT account_id, owner_name, balance
FROM accounts
ORDER BY account_id;

-- This step should fail because Bob does not have enough money and the
-- table has CHECK (balance >= 0).
UPDATE accounts
SET balance = balance - 10000
WHERE account_id = 2;

ROLLBACK;

SELECT account_id, owner_name, balance
FROM accounts
ORDER BY account_id;

/* ============================================================
   Exercise 3 - SAVEPOINT checkpoint
   ============================================================ */

UPDATE accounts
SET balance = balance + 25
WHERE account_id = 1;

SAVEPOINT after_alice_deposit;

UPDATE accounts
SET balance = balance - 25
WHERE account_id = 3;

ROLLBACK TO after_alice_deposit;

UPDATE accounts
SET balance = balance - 25
WHERE account_id = 2;

COMMIT;

SELECT account_id, owner_name, balance
FROM accounts
ORDER BY account_id;

/* ============================================================
   Exercise 4 - Stored procedure: deposit_funds
   ============================================================ */

CREATE OR REPLACE PROCEDURE deposit_funds(
    p_account_id IN NUMBER,
    p_amount     IN NUMBER
) AS
BEGIN
    IF p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Deposit amount must be greater than zero.');
    END IF;

    UPDATE accounts
    SET balance = balance + p_amount
    WHERE account_id = p_account_id;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20011, 'Account does not exist: ' || p_account_id);
    END IF;

    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/

EXEC deposit_funds(3, 75);

SELECT account_id, owner_name, balance
FROM accounts
ORDER BY account_id;

/* ============================================================
   Exercise 5 - Discussion
   ============================================================ */

-- Q1:
-- The time slot reservation and the appointment record should be inside
-- the same transaction because they are part of the same database change.
-- They need to succeed together or fail together. Sending the confirmation
-- notification should happen after the transaction commits, because it is an
-- external side effect. A good design could store a notification request in
-- the database during the transaction, then send the actual message after.

-- Q2:
-- If a procedure commits inside a larger transaction, it takes control away
-- from the caller. The developer cannot roll back the full larger operation
-- anymore because part of it was already committed by the procedure.

-- Q3:
-- calculate_copay() can be used in a SELECT statement if it is a function
-- that returns a value and does not perform transaction control. post_payment()
-- is a procedure, so it cannot be used as a SELECT expression. A procedure is
-- called with EXEC or CALL and is used for actions that change state.

/* ============================================================
   Lesson 04 - Stored procedure: transfer_funds
   ============================================================ */

CREATE OR REPLACE PROCEDURE transfer_funds(
    p_from_account IN NUMBER,
    p_to_account   IN NUMBER,
    p_amount       IN NUMBER
) AS
    v_from_balance NUMBER;
BEGIN
    IF p_amount <= 0 THEN
        RAISE_APPLICATION_ERROR(-20020, 'Transfer amount must be greater than zero.');
    END IF;

    SELECT balance
    INTO v_from_balance
    FROM accounts
    WHERE account_id = p_from_account;

    IF v_from_balance < p_amount THEN
        RAISE_APPLICATION_ERROR(
            -20021,
            'Insufficient funds in account ' || p_from_account
        );
    END IF;

    UPDATE accounts
    SET balance = balance - p_amount
    WHERE account_id = p_from_account;

    UPDATE accounts
    SET balance = balance + p_amount
    WHERE account_id = p_to_account;

    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20022, 'Destination account does not exist.');
    END IF;

    COMMIT;

    DBMS_OUTPUT.PUT_LINE(
        'Transfer complete: $' || p_amount ||
        ' from account ' || p_from_account ||
        ' to account ' || p_to_account
    );
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Transfer failed. All changes rolled back.');
        RAISE;
END;
/

SET SERVEROUTPUT ON;

SELECT account_id, owner_name, balance
FROM accounts
ORDER BY account_id;

EXEC transfer_funds(1, 2, 100);

SELECT account_id, owner_name, balance
FROM accounts
ORDER BY account_id;

-- Expected to fail and rollback.
EXEC transfer_funds(1, 2, 99999);

SELECT account_id, owner_name, balance
FROM accounts
ORDER BY account_id;

/* ============================================================
   Lesson 04 - Function: get_balance
   ============================================================ */

CREATE OR REPLACE FUNCTION get_balance(
    p_account_id IN NUMBER
) RETURN NUMBER AS
    v_balance NUMBER;
BEGIN
    SELECT balance
    INTO v_balance
    FROM accounts
    WHERE account_id = p_account_id;

    RETURN v_balance;
END;
/

SELECT account_id, owner_name, get_balance(account_id) AS current_balance
FROM accounts
ORDER BY account_id;

-- This is not valid because transfer_funds is a procedure, not a function:
-- SELECT transfer_funds(1, 2, 100) FROM dual;
