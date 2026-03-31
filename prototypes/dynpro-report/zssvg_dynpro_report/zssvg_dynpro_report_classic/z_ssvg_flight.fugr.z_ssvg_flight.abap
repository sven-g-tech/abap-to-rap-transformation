FUNCTION z_ssvg_flight.
*"----------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_INSERT) TYPE  /DMO/FLIGHT OPTIONAL
*"     VALUE(IS_UPDATE) TYPE  /DMO/FLIGHT OPTIONAL
*"     VALUE(IS_DELETE) TYPE  /DMO/FLIGHT OPTIONAL
*"----------------------------------------------------------------------

  IF is_insert IS NOT INITIAL.
    INSERT /dmo/flight FROM @is_insert.
    IF sy-subrc <> 0.
      MESSAGE e001(z_ssvg_flight).
    ENDIF.
  ENDIF.

  IF is_update IS NOT INITIAL.
    UPDATE /dmo/flight FROM @is_update.
    IF sy-subrc <> 0.
      MESSAGE e002(z_ssvg_flight).
    ENDIF.
  ENDIF.

  IF is_delete IS NOT INITIAL.
    DELETE /dmo/flight FROM @is_delete.
    IF sy-subrc <> 0.
      MESSAGE e003(z_ssvg_flight).
    ENDIF.
  ENDIF.



ENDFUNCTION.
