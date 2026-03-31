CLASS z_cl_ssvg_permission_check DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS check_auth
      IMPORTING
        iv_transaction_code TYPE tcode
      RAISING
        z_cx_ssvg_flight_general.
ENDCLASS.

CLASS z_cl_ssvg_permission_check IMPLEMENTATION.
  METHOD check_auth.
    AUTHORITY-CHECK OBJECT 'S_TCODE'
      ID 'TCD' FIELD iv_transaction_code.

    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE z_cx_ssvg_flight_general
        EXPORTING
          textid = z_cx_ssvg_flight_general=>transaction_error.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
