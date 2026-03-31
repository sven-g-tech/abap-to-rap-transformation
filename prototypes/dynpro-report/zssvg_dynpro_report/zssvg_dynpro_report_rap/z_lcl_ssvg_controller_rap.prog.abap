*&---------------------------------------------------------------------*
*& Include z_lcl_ssvg_controller_rap
*&---------------------------------------------------------------------*
CLASS z_lcl_ssvg_controller_rap DEFINITION CREATE PRIVATE.
  PUBLIC SECTION.
    CLASS-METHODS get_instance
      RETURNING VALUE(r_instance) TYPE REF TO z_lcl_ssvg_controller_rap.

    METHODS constructor.
    METHODS update_view
      IMPORTING iv_carr TYPE gt_carrier_id
                iv_airf TYPE gt_airport_from
                iv_airt TYPE gt_airport_to
                iv_fldt TYPE gt_flight_date.
    METHODS update_record
      IMPORTING iv_departure_time  TYPE /dmo/flight_departure_time
                iv_arrival_time    TYPE /dmo/flight_arrival_time
                iv_aircraft_type   TYPE /dmo/plane_type_id
                iv_number_of_seats TYPE /dmo/plane_seats_max
                iv_seats_occupied  TYPE /dmo/plane_seats_occupied.
    METHODS delete_record.

  PRIVATE SECTION.
    CLASS-DATA lo_instance TYPE REF TO z_lcl_ssvg_controller_rap.

    DATA lo_model TYPE REF TO z_lcl_ssvg_model_rap.
    DATA lo_view  TYPE REF TO z_lcl_ssvg_view_rap.

    METHODS on_link_click FOR EVENT link_click OF cl_salv_events_table
      IMPORTING
        row
        column
        sender.

    METHODS on_double_click FOR EVENT double_click OF cl_salv_events_table
      IMPORTING
        row
        column
        sender.
ENDCLASS.

CLASS z_lcl_ssvg_controller_rap IMPLEMENTATION.
  METHOD constructor.
    lo_model = NEW z_lcl_ssvg_model_rap( ).
    lo_view = NEW z_lcl_ssvg_view_rap( ).
  ENDMETHOD.

  METHOD get_instance.
    IF lo_instance IS NOT BOUND.
      lo_instance = NEW z_lcl_ssvg_controller_rap( ).
    ENDIF.
    r_instance = lo_instance.
  ENDMETHOD.

  METHOD update_view.
    lo_model->get_flight_data( iv_carr = iv_carr
                               iv_airf = iv_airf
                               iv_airt = iv_airt
                               iv_fldt = iv_fldt ).

    IF lo_model->gt_flights_result IS INITIAL.
      MESSAGE w002(z_ssvg_general) DISPLAY LIKE 'W'.
      RETURN.
    ENDIF.

    TRY.
        IF lo_view->go_salv IS NOT BOUND.
          DATA(lo_gui_container) = z_cl_ssvg_gui_container=>get_instance( iv_container_name = gc_gui_container_name
                                                                          iv_repid          = sy-repid
                                                                          iv_dynnr          = gc_dynnr ).
          cl_salv_table=>factory( EXPORTING
                                    r_container  = lo_gui_container
                                  IMPORTING
                                    r_salv_table = lo_view->go_salv
                                  CHANGING
                                    t_table      = lo_model->gt_flights_result ).

          SET HANDLER on_link_click FOR lo_view->go_salv->get_event( ).
          SET HANDLER on_double_click FOR lo_view->go_salv->get_event( ).
        ENDIF.

      CATCH cx_root INTO DATA(lo_exception).
        MESSAGE lo_exception->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
    ENDTRY.

    lo_view->init_salv_list( ).
    lo_view->display_salv_list( ).
  ENDMETHOD.

  METHOD on_link_click.
    DATA(current_cell_value) = lo_view->go_salv->get_selections( )->get_current_cell( )-value.

    IF current_cell_value IS NOT INITIAL.
      CASE column.
        WHEN 'AIRPORT_FROM_ID' OR 'AIRPORT_TO_ID'.
          DATA(lt_airport) = lo_model->get_airport( CONV /dmo/airport_id( current_cell_value ) ).

          IF lt_airport IS INITIAL.
            MESSAGE w003(z_ssvg_general) DISPLAY LIKE 'W'.
            RETURN.
          ENDIF.

          DATA(lt_popup) = lo_view->create_airport_popup( lt_airport ).

          CALL FUNCTION 'POPUP_WITH_TABLE_DISPLAY_OK'
            EXPORTING
              endpos_col   = 120
              endpos_row   = 15
              startpos_col = 10
              startpos_row = 5
              titletext    = TEXT-004
            TABLES
              valuetab     = lt_popup
            EXCEPTIONS
              OTHERS       = 1.

      ENDCASE.
    ENDIF.
  ENDMETHOD.

  METHOD on_double_click.
    IF row > 0 AND row <= lines( lo_model->gt_flights_result ).
      lo_model->gs_flight_detail = lo_model->gt_flights_result[ row ].

      lo_view->update_details( iv_aircraft_type   = lo_model->gs_flight_detail-plane_type_id
                               iv_arrival_time    = lo_model->gs_flight_detail-arrival_time
                               iv_departure_time  = lo_model->gs_flight_detail-departure_time
                               iv_number_of_seats = lo_model->gs_flight_detail-seats_max
                               iv_seats_occupied  = lo_model->gs_flight_detail-seats_occupied ).
      CALL SCREEN 1200.
    ENDIF.
  ENDMETHOD.

  METHOD update_record.
    lo_model->update_record( iv_aircraft_type   = iv_aircraft_type
                             iv_arrival_time    = iv_arrival_time
                             iv_departure_time  = iv_departure_time
                             iv_number_of_seats = iv_number_of_seats
                             iv_seats_occupied  = iv_seats_occupied ).

    lo_view->update_details( iv_aircraft_type   = gv_aircraft_type
                             iv_arrival_time    = gv_arrival_time
                             iv_departure_time  = gv_departure_time
                             iv_number_of_seats = gv_number_of_seats
                             iv_seats_occupied  = gv_seats_occupied ).
  ENDMETHOD.

  METHOD delete_record.
    lo_model->delete_record( ).
    lo_view->go_salv->refresh( ).
  ENDMETHOD.

ENDCLASS.
