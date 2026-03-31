*&---------------------------------------------------------------------*
*& Include z_lcl_ssvg_model
*&---------------------------------------------------------------------*
CLASS z_lcl_ssvg_model DEFINITION.
  PUBLIC SECTION.
    DATA: gt_flights_result TYPE gt_flight_data,
          gs_flight_detail  TYPE gs_flights.

    METHODS constructor.
    METHODS get_flight_data
      IMPORTING iv_carr        TYPE gt_carrier_id
                iv_airf        TYPE gt_airport_from
                iv_airt        TYPE gt_airport_to
                iv_fldt        TYPE gt_flight_date
      RETURNING VALUE(rt_data) TYPE gt_flight_data.
    METHODS get_airport
      IMPORTING iv_airport_id  TYPE /dmo/airport_id
      RETURNING VALUE(rt_data) TYPE gt_airport.
    METHODS update_record
      IMPORTING iv_departure_time  TYPE /dmo/flight_departure_time
                iv_arrival_time    TYPE /dmo/flight_arrival_time
                iv_aircraft_type   TYPE /dmo/plane_type_id
                iv_number_of_seats TYPE /dmo/plane_seats_max
                iv_seats_occupied  TYPE /dmo/plane_seats_occupied.
    METHODS delete_record.

  PRIVATE SECTION.
    DATA: lo_flight_db     TYPE REF TO z_cl_ssvg_flight_db,
          lo_connection_db TYPE REF TO z_cl_ssvg_connection_db.

    METHODS calculate_prices_in_eur
      IMPORTING it_flight_data TYPE gt_flight_data
      RETURNING VALUE(rt_data) TYPE gt_flight_data.
    METHODS convert_currency
      IMPORTING iv_currency_code_source TYPE /dmo/currency_code
                iv_currency_code_target TYPE /dmo/currency_code
                iv_amount               TYPE /dmo/total_price
      RETURNING VALUE(rv_amount)        TYPE /dmo/total_price.
ENDCLASS.


CLASS z_lcl_ssvg_model IMPLEMENTATION.

  METHOD constructor.
    lo_flight_db = NEW #( ).
    lo_connection_db = NEW #( ).
  ENDMETHOD.

  METHOD get_flight_data.
    TRY.
        SELECT
          flight~carrier_id,
          flight~connection_id,
          flight~flight_date,
          connection~airport_from_id,
          connection~airport_to_id,
          flight~price,
          0 AS price_in_eur,
          flight~currency_code,
          flight~plane_type_id,
          flight~seats_max,
          flight~seats_occupied,
          connection~departure_time,
          connection~arrival_time,
          connection~distance,
          connection~distance_unit
          FROM /dmo/flight AS flight
          INNER JOIN /dmo/connection AS connection
            ON  flight~connection_id = connection~connection_id
            AND flight~carrier_id    = connection~carrier_id
          WHERE flight~carrier_id          IN @iv_carr
            AND connection~airport_from_id IN @iv_airf
            AND connection~airport_to_id   IN @iv_airt
            AND flight~flight_date         IN @iv_fldt
          INTO TABLE @gt_flights_result.

      CATCH cx_sy_open_sql_db INTO DATA(lo_exception).
        MESSAGE lo_exception->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
    ENDTRY.

    gt_flights_result = calculate_prices_in_eur( it_flight_data = gt_flights_result ).
    rt_data = gt_flights_result.
  ENDMETHOD.

  METHOD get_airport.
    TRY.
        SELECT client,
               airport_id,
               name,
               city,
               country
        FROM /dmo/airport
        WHERE airport_id = @iv_airport_id
        INTO TABLE @rt_data
        UP TO 1 ROWS.

      CATCH cx_sy_open_sql_db INTO DATA(lo_exception).
        MESSAGE lo_exception->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
    ENDTRY.
  ENDMETHOD.

  METHOD calculate_prices_in_eur.
    DATA(lt_flight_data) = it_flight_data.

    LOOP AT lt_flight_data ASSIGNING FIELD-SYMBOL(<fs_flight>).
      TRY.
          IF <fs_flight>-currency_code = gc_currency_code_euro.
            <fs_flight>-price_in_eur = <fs_flight>-price.
          ELSE.
            <fs_flight>-price_in_eur = convert_currency(
              iv_currency_code_source = <fs_flight>-currency_code
              iv_currency_code_target = gc_currency_code_euro
              iv_amount               = <fs_flight>-price ).
          ENDIF.

          IF <fs_flight>-price > 0 AND <fs_flight>-price_in_eur = 0.
            MESSAGE w004(z_ssvg_general) WITH <fs_flight>-currency_code DISPLAY LIKE 'W'.
          ENDIF.
        CATCH cx_sy_open_sql_db INTO DATA(lo_exception).
          MESSAGE lo_exception->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDTRY.
    ENDLOOP.

    rt_data = lt_flight_data.
  ENDMETHOD.

  METHOD convert_currency.
    DATA(lv_exchange_rate_date) = cl_abap_context_info=>get_system_date( ).

    /dmo/cl_flight_amdp=>convert_currency(
      EXPORTING
        iv_amount               = iv_amount
        iv_currency_code_source = iv_currency_code_source
        iv_currency_code_target = iv_currency_code_target
        iv_exchange_rate_date   = lv_exchange_rate_date
      IMPORTING
        ev_amount               = rv_amount
    ).
  ENDMETHOD.

  METHOD update_record.
    DATA lv_connection_success TYPE abap_bool VALUE abap_false.
    DATA lv_flight_success     TYPE abap_bool VALUE abap_false.

    IF    ( iv_aircraft_type   <> gs_flight_detail-plane_type_id )
       OR ( iv_number_of_seats <> gs_flight_detail-seats_max )
       OR ( iv_seats_occupied  <> gs_flight_detail-seats_occupied ).

      IF iv_seats_occupied > iv_number_of_seats.
        MESSAGE i005(z_ssvg_general) DISPLAY LIKE 'E'.
        RETURN.
      ENDIF.

      TRY.
          DATA(ls_flight) = VALUE /dmo/flight( carrier_id     = gs_flight_detail-carrier_id
                                               connection_id  = gs_flight_detail-connection_id
                                               flight_date    = gs_flight_detail-flight_date
                                               price          = gs_flight_detail-price
                                               currency_code  = gs_flight_detail-currency_code
                                               plane_type_id  = iv_aircraft_type
                                               seats_max      = iv_number_of_seats
                                               seats_occupied = iv_seats_occupied ).

          lo_flight_db->update( is_flight = ls_flight ).

          lv_flight_success = abap_true.

        CATCH z_cx_ssvg_flight_db INTO DATA(lo_flight_exception).
          MESSAGE lo_flight_exception->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
          ROLLBACK WORK.
          RETURN.
      ENDTRY.
    ENDIF.

    IF    ( iv_departure_time <> gs_flight_detail-departure_time )
       OR ( iv_arrival_time   <> gs_flight_detail-arrival_time ).
      TRY.
          DATA(ls_connection) = VALUE /dmo/connection( carrier_id      = gs_flight_detail-carrier_id
                                                       connection_id   = gs_flight_detail-connection_id
                                                       airport_from_id = gs_flight_detail-airport_from_id
                                                       airport_to_id   = gs_flight_detail-airport_to_id
                                                       departure_time  = iv_departure_time
                                                       arrival_time    = iv_arrival_time
                                                       distance        = gs_flight_detail-distance
                                                       distance_unit   = gs_flight_detail-distance_unit ).

          lo_connection_db->update( is_connection = ls_connection ).

          lv_connection_success = abap_true.

        CATCH z_cx_ssvg_connection_db INTO DATA(lo_connection_exception).
          MESSAGE lo_connection_exception->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
          ROLLBACK WORK.
          RETURN.
      ENDTRY.
    ENDIF.

    ASSIGN gt_flights_result[ carrier_id    = gs_flight_detail-carrier_id
                              connection_id = gs_flight_detail-connection_id
                              flight_date   = gs_flight_detail-flight_date ]
           TO FIELD-SYMBOL(<fs_flight>).

    IF <fs_flight> IS ASSIGNED.
      IF lv_connection_success = abap_true.
        <fs_flight>-departure_time = iv_departure_time.
        <fs_flight>-arrival_time   = iv_arrival_time.
      ENDIF.

      IF lv_flight_success = abap_true.
        <fs_flight>-plane_type_id  = iv_aircraft_type.
        <fs_flight>-seats_max      = iv_number_of_seats.
        <fs_flight>-seats_occupied = iv_seats_occupied.
      ENDIF.

      gs_flight_detail = <fs_flight>.
    ENDIF.

    MESSAGE s008(z_ssvg_general).
  ENDMETHOD.

  METHOD delete_record.
    TRY.
        DATA(ls_connection) = VALUE /dmo/connection( carrier_id      = gs_flight_detail-carrier_id
                                                     connection_id   = gs_flight_detail-connection_id
                                                     airport_from_id = gs_flight_detail-airport_from_id
                                                     airport_to_id   = gs_flight_detail-airport_to_id
                                                     departure_time  = gs_flight_detail-departure_time
                                                     arrival_time    = gs_flight_detail-arrival_time
                                                     distance        = gs_flight_detail-distance
                                                     distance_unit   = gs_flight_detail-distance_unit ).

        lo_connection_db->delete( is_connection = ls_connection ).

      CATCH z_cx_ssvg_connection_db INTO DATA(lo_connection_exception).
        MESSAGE lo_connection_exception->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
        ROLLBACK WORK.
        RETURN.
    ENDTRY.

    TRY.
        DATA(ls_flight) = VALUE /dmo/flight( carrier_id     = gs_flight_detail-carrier_id
                                             connection_id  = gs_flight_detail-connection_id
                                             flight_date    = gs_flight_detail-flight_date
                                             price          = gs_flight_detail-price
                                             currency_code  = gs_flight_detail-currency_code
                                             plane_type_id  = gs_flight_detail-plane_type_id
                                             seats_max      = gs_flight_detail-seats_max
                                             seats_occupied = gs_flight_detail-seats_occupied ).

        lo_flight_db->delete( is_flight = ls_flight ).

      CATCH z_cx_ssvg_flight_db INTO DATA(lo_flight_exception).
        MESSAGE lo_flight_exception->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
        ROLLBACK WORK.
        RETURN.
    ENDTRY.

    ASSIGN gt_flights_result[ carrier_id    = gs_flight_detail-carrier_id
                              connection_id = gs_flight_detail-connection_id
                              flight_date   = gs_flight_detail-flight_date ]
           TO FIELD-SYMBOL(<fs_flight>).

    IF <fs_flight> IS ASSIGNED.
      ##INDEX_NUM
      DELETE gt_flights_result FROM gs_flight_detail.
    ENDIF.

    CLEAR gs_flight_detail.

    MESSAGE s011(z_ssvg_general).
  ENDMETHOD.

ENDCLASS.
