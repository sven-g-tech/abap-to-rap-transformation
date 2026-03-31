FUNCTION zssvg_flight_overbooked.
*"----------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IT_INSERT) TYPE  ZSSVG_T_FLIGHT_OVERBOOKED OPTIONAL
*"     VALUE(IT_UPDATE) TYPE  ZSSVG_T_FLIGHT_OVERBOOKED OPTIONAL
*"     VALUE(IT_DELETE) TYPE  ZSSVG_T_FLIGHT_OVERBOOKED OPTIONAL
*"----------------------------------------------------------------------
  IF it_insert IS NOT INITIAL.
    INSERT zssvg_flight FROM TABLE @it_insert.
    IF sy-subrc <> 0.
      MESSAGE e001(zssvg_flight_overb).
    ENDIF.
  ENDIF.

  IF it_update IS NOT INITIAL.
    UPDATE zssvg_flight FROM TABLE @it_update.
    IF sy-subrc <> 0.
      MESSAGE e002(zssvg_flight_overb).
    ENDIF.
  ENDIF.

  IF it_delete IS NOT INITIAL.
    DELETE zssvg_flight FROM TABLE @it_delete.
    IF sy-subrc <> 0.
      MESSAGE e003(zssvg_flight_overb).
    ENDIF.
  ENDIF.
ENDFUNCTION.
