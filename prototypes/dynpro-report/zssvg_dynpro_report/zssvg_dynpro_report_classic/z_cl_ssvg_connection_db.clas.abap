CLASS z_cl_ssvg_connection_db DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS create
      IMPORTING
                !is_connection TYPE /dmo/connection
      RAISING   z_cx_ssvg_connection_db.
    METHODS update
      IMPORTING
                !is_connection TYPE /dmo/connection
      RAISING   z_cx_ssvg_connection_db.
    METHODS delete
      IMPORTING
                !is_connection TYPE /dmo/connection
      RAISING   z_cx_ssvg_connection_db.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS z_cl_ssvg_connection_db IMPLEMENTATION.

  METHOD create.

    CALL FUNCTION 'Z_SSVG_CONNECTION' IN UPDATE TASK
      EXPORTING
        is_insert = is_connection.

    COMMIT WORK AND WAIT.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z_cx_ssvg_connection_db
        EXPORTING
          textid = z_cx_ssvg_connection_db=>creation_error.
    ENDIF.
  ENDMETHOD.

  METHOD update.
    CALL FUNCTION 'Z_SSVG_CONNECTION' IN UPDATE TASK
      EXPORTING
        is_update = is_connection.

    COMMIT WORK AND WAIT.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z_cx_ssvg_connection_db
        EXPORTING
          textid = z_cx_ssvg_connection_db=>update_error.
    ENDIF.
  ENDMETHOD.


  METHOD delete.
    CALL FUNCTION 'Z_SSVG_CONNECTION' IN UPDATE TASK
      EXPORTING
        is_delete = is_connection.

    COMMIT WORK AND WAIT.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z_cx_ssvg_connection_db
        EXPORTING
          textid = z_cx_ssvg_connection_db=>delete_error.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
