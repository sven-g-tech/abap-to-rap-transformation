*&---------------------------------------------------------------------*
*& Report z_ssvg_flights
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_ssvg_flights_rap.

INCLUDE z_ssvg_top_rap.
INCLUDE z_lcl_ssvg_model_rap.
INCLUDE z_lcl_ssvg_view_rap.
INCLUDE z_lcl_ssvg_controller_rap.
INCLUDE z_ssvg_sel_rap.
INCLUDE z_ssvg_pbo_rap.
INCLUDE z_ssvg_pai_rap.

START-OF-SELECTION.
  TRY.
      z_cl_ssvg_permission_check=>check_auth( |{ gc_transaction_code }| ).

      CALL SCREEN 1100.
    CATCH z_cx_ssvg_flight_general INTO DATA(lo_exception).
      MESSAGE ID lo_exception->if_t100_message~t100key-msgid
              TYPE 'E'
              NUMBER lo_exception->if_t100_message~t100key-msgno
              WITH lo_exception->if_t100_message~t100key-attr1
                   lo_exception->if_t100_message~t100key-attr2
                   lo_exception->if_t100_message~t100key-attr3
                   lo_exception->if_t100_message~t100key-attr4.

  ENDTRY.
