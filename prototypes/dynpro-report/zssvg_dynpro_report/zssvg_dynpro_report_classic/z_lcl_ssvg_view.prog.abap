*&---------------------------------------------------------------------*
*& Include z_lcl_ssvg_view
*&---------------------------------------------------------------------*
CLASS z_lcl_ssvg_view DEFINITION.
  PUBLIC SECTION.
    DATA go_salv TYPE REF TO cl_salv_table.

    METHODS init_salv_list.
    METHODS display_salv_list.
    METHODS create_airport_popup
      IMPORTING it_airport      TYPE gt_airport
      RETURNING VALUE(rt_popup) TYPE gt_string_table.
    METHODS update_details
      IMPORTING iv_departure_time  TYPE /dmo/flight_departure_time
                iv_arrival_time    TYPE /dmo/flight_arrival_time
                iv_aircraft_type   TYPE /dmo/plane_type_id
                iv_number_of_seats TYPE /dmo/plane_seats_max
                iv_seats_occupied  TYPE /dmo/plane_seats_occupied.
PRIVATE SECTION.
    DATA lv_salv_list_initialized TYPE abap_bool VALUE abap_false.
ENDCLASS.

CLASS z_lcl_ssvg_view IMPLEMENTATION.
  METHOD init_salv_list.
    IF lv_salv_list_initialized = abap_true.
      RETURN.
    ENDIF.

    TRY.
        go_salv->get_display_settings( )->set_list_header( TEXT-003 ).
        go_salv->get_selections( )->set_selection_mode( if_salv_c_selection_mode=>single ).

        DATA: lo_salv_columns                TYPE REF TO cl_salv_columns_table,
              lo_salv_column_airport_from    TYPE REF TO cl_salv_column_table,
              lo_salv_column_airport_to      TYPE REF TO cl_salv_column_table,
              lo_salv_column_price_in_eur    TYPE REF TO cl_salv_column_table,
              lo_salv_column_connection_id   TYPE REF TO cl_salv_column_table,
              lo_salv_column_depature_time   TYPE REF TO cl_salv_column_table,
              lo_salv_column_arrival_time    TYPE REF TO cl_salv_column_table,
              lo_salv_column_aircraft_type   TYPE REF TO cl_salv_column_table,
              lo_salv_column_distance        TYPE REF TO cl_salv_column_table,
              lo_salv_column_distance_unit   TYPE REF TO cl_salv_column_table,
              lo_salv_column_number_of_seats TYPE REF TO cl_salv_column_table,
              lo_salv_column_seats_occupied  TYPE REF TO cl_salv_column_table.

        lo_salv_columns = go_salv->get_columns( ).

        lo_salv_column_connection_id ?= lo_salv_columns->get_column( 'CONNECTION_ID' ).
        lo_salv_column_connection_id->set_visible( abap_false ).

        lo_salv_column_depature_time ?= lo_salv_columns->get_column( 'DEPARTURE_TIME' ).
        lo_salv_column_depature_time->set_visible( abap_false ).

        lo_salv_column_arrival_time ?= lo_salv_columns->get_column( 'ARRIVAL_TIME' ).
        lo_salv_column_arrival_time->set_visible( abap_false ).

        lo_salv_column_aircraft_type ?= lo_salv_columns->get_column( 'PLANE_TYPE_ID' ).
        lo_salv_column_aircraft_type->set_visible( abap_false ).

        lo_salv_column_distance ?= lo_salv_columns->get_column( 'DISTANCE' ).
        lo_salv_column_distance->set_visible( abap_false ).

        lo_salv_column_distance_unit ?= lo_salv_columns->get_column( 'DISTANCE_UNIT' ).
        lo_salv_column_distance_unit->set_visible( abap_false ).

        lo_salv_column_number_of_seats ?= lo_salv_columns->get_column( 'SEATS_MAX' ).
        lo_salv_column_number_of_seats->set_visible( abap_false ).

        lo_salv_column_seats_occupied ?= lo_salv_columns->get_column( 'SEATS_OCCUPIED' ).
        lo_salv_column_seats_occupied->set_visible( abap_false ).

        lo_salv_column_airport_from ?= lo_salv_columns->get_column( 'AIRPORT_FROM_ID' ).
        lo_salv_column_airport_from->set_cell_type( if_salv_c_cell_type=>hotspot ).

        lo_salv_column_airport_to ?= lo_salv_columns->get_column( 'AIRPORT_TO_ID' ).
        lo_salv_column_airport_to->set_cell_type( if_salv_c_cell_type=>hotspot ).

        lo_salv_column_price_in_eur ?= lo_salv_columns->get_column( 'PRICE_IN_EUR' ).
        lo_salv_column_price_in_eur->set_short_text( | { TEXT-011 } | ).
        lo_salv_column_price_in_eur->set_medium_text( | { TEXT-012 } | ).
        lo_salv_column_price_in_eur->set_long_text( | { TEXT-012 } | ).

        lo_salv_columns->set_optimize( abap_true ).

        go_salv->get_display_settings( )->set_striped_pattern( abap_true ).

        lv_salv_list_initialized = abap_true.

      CATCH cx_root INTO DATA(lo_exception).
        MESSAGE lo_exception->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
    ENDTRY.
  ENDMETHOD.

  METHOD display_salv_list.
    go_salv->display( ).
  ENDMETHOD.

  METHOD create_airport_popup.
    IF it_airport IS NOT INITIAL.
      LOOP AT it_airport INTO DATA(ls_airport).

        APPEND |{ TEXT-005 } { ls_airport-airport_id }| TO rt_popup.
        APPEND |{ TEXT-006 } { ls_airport-name }| TO rt_popup.
        APPEND |{ TEXT-007 } { ls_airport-city }| TO rt_popup.
        APPEND |{ TEXT-008 } { ls_airport-country }| TO rt_popup.

        IF lines( it_airport ) > 1.
          APPEND | | TO rt_popup.
        ENDIF.
      ENDLOOP.
    ENDIF.

    RETURN rt_popup.
  ENDMETHOD.

  METHOD update_details.
    gv_departure_time  = iv_departure_time.
    gv_arrival_time    = iv_arrival_time.
    gv_aircraft_type   = iv_aircraft_type.
    gv_number_of_seats = iv_number_of_seats.
    gv_seats_occupied  = iv_seats_occupied.
  ENDMETHOD.

ENDCLASS.
