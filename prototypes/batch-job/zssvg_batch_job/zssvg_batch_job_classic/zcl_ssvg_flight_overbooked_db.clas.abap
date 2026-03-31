CLASS zcl_ssvg_flight_overbooked_db DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS create
      IMPORTING it_flight_overbooked TYPE zssvg_t_flight_overbooked
      RAISING   zcx_ssvg_flight_overbooked_db.

    METHODS update
      IMPORTING it_flight_overbooked TYPE zssvg_t_flight_overbooked
      RAISING   zcx_ssvg_flight_overbooked_db.

    METHODS delete
      IMPORTING it_flight_overbooked TYPE zssvg_t_flight_overbooked
      RAISING   zcx_ssvg_flight_overbooked_db.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_ssvg_flight_overbooked_db IMPLEMENTATION.

  METHOD create.

    CALL FUNCTION 'ZSSVG_FLIGHT_OVERBOOKED' IN UPDATE TASK
      EXPORTING
        it_insert = it_flight_overbooked.

    COMMIT WORK AND WAIT.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_ssvg_flight_overbooked_db
        EXPORTING
          textid = zcx_ssvg_flight_overbooked_db=>creation_error.
    ENDIF.
  ENDMETHOD.

  METHOD update.
    CALL FUNCTION 'ZSSVG_FLIGHT_OVERBOOKED' IN UPDATE TASK
      EXPORTING
        it_update = it_flight_overbooked.

    COMMIT WORK AND WAIT.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_ssvg_flight_overbooked_db
        EXPORTING
          textid = zcx_ssvg_flight_overbooked_db=>update_error.
    ENDIF.
  ENDMETHOD.


  METHOD delete.
    CALL FUNCTION 'ZSSVG_FLIGHT_OVERBOOKED' IN UPDATE TASK
      EXPORTING
        it_delete = it_flight_overbooked.

    COMMIT WORK AND WAIT.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_ssvg_flight_overbooked_db
        EXPORTING
          textid = zcx_ssvg_flight_overbooked_db=>delete_error.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
