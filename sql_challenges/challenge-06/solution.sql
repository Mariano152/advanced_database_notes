/* ============================================================
   SQL Challenge 06 - PET_CARE_LOG Triggers
   ============================================================ */

/* ------------------------------------------------------------
   1. Before insert trigger
      - Assigns the current date/time to UPDATE_DATE.
      - Assigns the current database user to UPDATED_BY_USER.
   ------------------------------------------------------------ */

CREATE OR REPLACE TRIGGER trg_pet_care_log_bi
BEFORE INSERT ON pet_care_log
FOR EACH ROW
BEGIN
  :NEW.update_date := SYSDATE;
  :NEW.updated_by_user := USER;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(
      -20001,
      'Error inserting PET_CARE_LOG record: ' || SQLERRM
    );
END;
/

/* ------------------------------------------------------------
   2. Before update trigger
      - Allows updates only when the current user is the same
        user stored in UPDATED_BY_USER.
   ------------------------------------------------------------ */

CREATE OR REPLACE TRIGGER trg_pet_care_log_bu
BEFORE UPDATE ON pet_care_log
FOR EACH ROW
BEGIN
  IF USER <> :OLD.updated_by_user THEN
    RAISE_APPLICATION_ERROR(
      -20002,
      'Update denied. Users can update only records they created.'
    );
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE BETWEEN -20999 AND -20000 THEN
      RAISE;
    END IF;

    RAISE_APPLICATION_ERROR(
      -20003,
      'Error updating PET_CARE_LOG record: ' || SQLERRM
    );
END;
/

/* ------------------------------------------------------------
   3. Before delete trigger
      - Allows deletes only when the current user is JOEMANAGER.
   ------------------------------------------------------------ */

CREATE OR REPLACE TRIGGER trg_pet_care_log_bd
BEFORE DELETE ON pet_care_log
FOR EACH ROW
BEGIN
  IF USER <> 'JOEMANAGER' THEN
    RAISE_APPLICATION_ERROR(
      -20004,
      'Delete denied. Only JOEMANAGER can delete PET_CARE_LOG records.'
    );
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE BETWEEN -20999 AND -20000 THEN
      RAISE;
    END IF;

    RAISE_APPLICATION_ERROR(
      -20005,
      'Error deleting PET_CARE_LOG record: ' || SQLERRM
    );
END;
/
