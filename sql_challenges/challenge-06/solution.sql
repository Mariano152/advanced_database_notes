/* ============================================================
   SQL Challenge 06 - PET_CARE_LOG Triggers
   ============================================================ */

/* ------------------------------------------------------------
   1. Before insert trigger
      - Assigns the current date/time to LAST_UPDATE_DATETIME.
      - Assigns the current database user to CREATED_BY_USER.
   ------------------------------------------------------------ */

CREATE OR REPLACE TRIGGER trg_pet_care_log_bi
BEFORE INSERT ON pet_care_log
FOR EACH ROW
BEGIN
  :NEW.last_update_datetime := SYSDATE;
  :NEW.created_by_user := USER;
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
        user stored in CREATED_BY_USER.
   ------------------------------------------------------------ */

CREATE OR REPLACE TRIGGER trg_pet_care_log_bu
BEFORE UPDATE ON pet_care_log
FOR EACH ROW
BEGIN
  IF USER <> :OLD.created_by_user THEN
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
