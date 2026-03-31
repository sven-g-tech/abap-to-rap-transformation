CLASS z_cl_ssvg_flight_db DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS create
      IMPORTING
                !is_flight TYPE /dmo/flight
      RAISING   z_cx_ssvg_flight_db.
    METHODS update
      IMPORTING
                !is_flight TYPE /dmo/flight
      RAISING   z_cx_ssvg_flight_db.
    METHODS delete
      IMPORTING
                !is_flight TYPE /dmo/flight
      RAISING   z_cx_ssvg_flight_db.
PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z_cl_ssvg_flight_db IMPLEMENTATION.

  METHOD create.

    CALL FUNCTION 'Z_SSVG_FLIGHT' IN UPDATE TASK
      EXPORTING
        is_insert = is_flight.

    COMMIT WORK AND WAIT.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z_cx_ssvg_flight_db
        EXPORTING
          textid = z_cx_ssvg_flight_db=>creation_error.
    ENDIF.
  ENDMETHOD.

  METHOD update.
    CALL FUNCTION 'Z_SSVG_FLIGHT' IN UPDATE TASK
      EXPORTING
        is_update = is_flight.

    COMMIT WORK AND WAIT.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z_cx_ssvg_flight_db
        EXPORTING
          textid = z_cx_ssvg_flight_db=>update_error.
    ENDIF.
  ENDMETHOD.


  METHOD delete.
    CALL FUNCTION 'Z_SSVG_FLIGHT' IN UPDATE TASK
      EXPORTING
        is_delete = is_flight.

    COMMIT WORK AND WAIT.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z_cx_ssvg_flight_db
        EXPORTING
          textid = z_cx_ssvg_flight_db=>delete_error.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
