FUNCTION z_ssvg_connection.
*"----------------------------------------------------------------------
*"*"Update Function Module:
*"
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(IS_INSERT) TYPE  /DMO/CONNECTION OPTIONAL
*"     VALUE(IS_UPDATE) TYPE  /DMO/CONNECTION OPTIONAL
*"     VALUE(IS_DELETE) TYPE  /DMO/CONNECTION OPTIONAL
*"----------------------------------------------------------------------

  IF is_insert IS NOT INITIAL.
    INSERT /dmo/connection FROM @is_insert.
    IF sy-subrc <> 0.
      MESSAGE e001(z_ssvg_connection).
    ENDIF.
  ENDIF.

  IF is_update IS NOT INITIAL.
    UPDATE /dmo/connection FROM @is_update.
    IF sy-subrc <> 0.
      MESSAGE e002(z_ssvg_connection).
    ENDIF.
  ENDIF.

  IF is_delete IS NOT INITIAL.
    DELETE /dmo/connection FROM @is_delete.
    IF sy-subrc <> 0.
      MESSAGE e003(z_ssvg_connection).
    ENDIF.
  ENDIF.



ENDFUNCTION.
