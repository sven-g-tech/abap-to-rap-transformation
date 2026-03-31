*&---------------------------------------------------------------------*
*& Include z_ssvg_sel_rap
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK flight_filter WITH FRAME TITLE TEXT-001.

  DATA: lv_carrid TYPE /dmo/carrier_id,
        lv_airfr  TYPE /dmo/airport_from_id,
        lv_airto  TYPE /dmo/airport_to_id,
        lv_fldate TYPE /dmo/flight_date.

  SELECT-OPTIONS: so_carr FOR lv_carrid,
                  so_airf FOR lv_airfr,
                  so_airt FOR lv_airto,
                  so_fldt FOR lv_fldate.

SELECTION-SCREEN END OF BLOCK flight_filter.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_carr-low.
  PERFORM carrier_f4 CHANGING so_carr-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_carr-high.
  PERFORM carrier_f4 CHANGING so_carr-high.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_airf-low.
  PERFORM airport_f4 CHANGING so_airf-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_airf-high.
  PERFORM airport_f4 CHANGING so_airf-high.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_airt-low.
  PERFORM airport_f4 CHANGING so_airt-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR so_airt-high.
  PERFORM airport_f4 CHANGING so_airt-high.

FORM airport_f4
  CHANGING
    cv_airportid TYPE /dmo/airport_id.

  DATA: lv_value  TYPE help_info-fldvalue,
        lt_return TYPE STANDARD TABLE OF ddshretval.

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      tabname           = '/DMO/AIRPORT'
      fieldname         = 'AIRPORT_ID'
      searchhelp        = 'Z_SSVG_AIRPORT'
      value             = lv_value
    TABLES
      return_tab        = lt_return
    EXCEPTIONS
      field_not_found   = 1
      no_help_for_field = 2
      inconsistent_help = 3
      no_values_found   = 4
      OTHERS            = 5.

  IF sy-subrc NE 0.
    RETURN.
  ENDIF.
  READ TABLE lt_return INTO DATA(ls_return) INDEX 1.
  cv_airportid = ls_return-fieldval.

ENDFORM.

FORM carrier_f4
  CHANGING
    cv_carrierid TYPE /dmo/carrier_id.

  DATA: lv_value  TYPE help_info-fldvalue,
        lt_return TYPE STANDARD TABLE OF ddshretval.

  CALL FUNCTION 'F4IF_FIELD_VALUE_REQUEST'
    EXPORTING
      tabname           = '/DMO/CARRIER'
      fieldname         = 'AIRLINEID'
      searchhelp        = 'Z_SSVG_CARRIER'
      value             = lv_value
    TABLES
      return_tab        = lt_return
    EXCEPTIONS
      field_not_found   = 1
      no_help_for_field = 2
      inconsistent_help = 3
      no_values_found   = 4
      OTHERS            = 5.

  IF sy-subrc NE 0.
    RETURN.
  ENDIF.
  READ TABLE lt_return INTO DATA(ls_return) INDEX 1.
  cv_carrierid = ls_return-fieldval.

ENDFORM.
