*&---------------------------------------------------------------------*
*& Include z_lcl_ssvg_model_rap
*&---------------------------------------------------------------------*
CLASS z_lcl_ssvg_model_rap DEFINITION.
  PUBLIC SECTION.
    DATA: gt_flights_result TYPE gt_flight_data,
          gs_flight_detail  TYPE gs_flights.

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
ENDCLASS.


CLASS z_lcl_ssvg_model_rap IMPLEMENTATION.
  METHOD get_flight_data.
    TRY.
        SELECT *
          FROM zssvgr_flight_connection( p_target_currency = @gc_currency_code_euro ) AS flight_connection
          WHERE flight_connection~AirlineID          IN @iv_carr
            AND flight_connection~DepartureAirport   IN @iv_airf
            AND flight_connection~DestinationAirport IN @iv_airt
            AND flight_connection~FlightDate         IN @iv_fldt
          INTO TABLE @gt_flights_result.

      CATCH cx_sy_open_sql_db INTO DATA(lo_exception).
        MESSAGE lo_exception->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
    ENDTRY.

    LOOP AT gt_flights_result ASSIGNING FIELD-SYMBOL(<fs_flights_result>).
      IF <fs_flights_result>-price > 0 AND <fs_flights_result>-price_in_eur = 0.
        MESSAGE w004(z_ssvg_general) WITH <fs_flights_result>-currency_code DISPLAY LIKE 'W'.
      ENDIF.
    ENDLOOP.

    rt_data = gt_flights_result.
  ENDMETHOD.

  METHOD get_airport.
    TRY.
        SELECT AirportID,
               Name,
               City,
               CountryCode
        FROM /DMO/I_Airport
        WHERE AirportID = @iv_airport_id
        INTO TABLE @rt_data
        UP TO 1 ROWS.

      CATCH cx_sy_open_sql_db INTO DATA(lo_exception).
        MESSAGE lo_exception->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
    ENDTRY.
  ENDMETHOD.

  METHOD update_record.
    DATA: lv_connection_success TYPE abap_bool VALUE abap_false,
          lv_flight_success     TYPE abap_bool VALUE abap_false.

    IF ( iv_aircraft_type <> gs_flight_detail-plane_type_id )
      OR ( iv_number_of_seats <> gs_flight_detail-seats_max )
      OR ( iv_seats_occupied <> gs_flight_detail-seats_occupied ).

      MODIFY ENTITIES OF zssvgi_flight
      ENTITY Flight
      UPDATE FIELDS ( PlaneType MaximumSeats OccupiedSeats )
      WITH VALUE #( ( AirlineID     = gs_flight_detail-carrier_id
                      ConnectionID  = gs_flight_detail-connection_id
                      FlightDate    = gs_flight_detail-flight_date
                      PlaneType     = iv_aircraft_type
                      MaximumSeats  = iv_number_of_seats
                      OccupiedSeats = iv_seats_occupied ) )
      FAILED DATA(flight_failed_update)
      REPORTED DATA(flight_reported_update).

      COMMIT ENTITIES
      RESPONSE OF zssvgi_flight
      FAILED DATA(flight_failed_commit)
      REPORTED DATA(flight_reported_commit).

      LOOP AT flight_reported_update-flight ASSIGNING FIELD-SYMBOL(<fs_flight_reported_update>).
        IF <fs_flight_reported_update>-%msg->m_severity = if_abap_behv_message=>severity-error.
          MESSAGE <fs_flight_reported_update>-%msg TYPE 'I' DISPLAY LIKE 'E'.
        ENDIF.
      ENDLOOP.

      LOOP AT flight_reported_commit-flight ASSIGNING FIELD-SYMBOL(<fs_flight_reported_commit>).
        IF <fs_flight_reported_commit>-%msg->m_severity = if_abap_behv_message=>severity-error.
          MESSAGE <fs_flight_reported_commit>-%msg TYPE 'I' DISPLAY LIKE 'E'.
        ENDIF.
      ENDLOOP.

      IF ( flight_failed_update IS NOT INITIAL ) OR ( flight_failed_commit IS NOT INITIAL ).
        MESSAGE i006(z_ssvg_general) DISPLAY LIKE 'E'.
        ROLLBACK ENTITIES.
        RETURN.
      ELSE.
        lv_flight_success = abap_true.
      ENDIF.

    ENDIF.

    IF ( iv_departure_time <> gs_flight_detail-departure_time )
      OR ( iv_arrival_time <> gs_flight_detail-arrival_time ).

      MODIFY ENTITIES OF zssvgi_connection
      ENTITY Connection
      UPDATE FIELDS ( DepartureTime ArrivalTime )
      WITH VALUE #( ( AirlineID     = gs_flight_detail-carrier_id
                      ConnectionID  = gs_flight_detail-connection_id
                      DepartureTime = iv_departure_time
                      ArrivalTime   = iv_arrival_time ) )
      FAILED DATA(connection_failed_update)
      REPORTED DATA(connection_reported_update).

      COMMIT ENTITIES
      RESPONSE OF zssvgi_connection
      FAILED DATA(connection_failed_commit)
      REPORTED DATA(connection_reported_commit).

      LOOP AT connection_reported_update-connection ASSIGNING FIELD-SYMBOL(<fs_connection_update>).
        IF <fs_connection_update>-%msg->m_severity = if_abap_behv_message=>severity-error.
          MESSAGE <fs_connection_update>-%msg TYPE 'I' DISPLAY LIKE 'E'.
        ENDIF.
      ENDLOOP.

      LOOP AT connection_reported_commit-connection ASSIGNING FIELD-SYMBOL(<fs_connection_commit>).
        IF <fs_connection_commit>-%msg->m_severity = if_abap_behv_message=>severity-error.
          MESSAGE <fs_connection_commit>-%msg TYPE 'I' DISPLAY LIKE 'E'.
        ENDIF.
      ENDLOOP.

      IF ( connection_failed_update IS NOT INITIAL ) OR ( connection_failed_commit IS NOT INITIAL ).
        MESSAGE i007(z_ssvg_general) DISPLAY LIKE 'E'.
        ROLLBACK ENTITIES.
        RETURN.
      ELSE.
        lv_connection_success = abap_true.
      ENDIF.

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
    MODIFY ENTITIES OF zssvgi_connection
           ENTITY Connection
           DELETE FROM VALUE #( ( AirlineID    = gs_flight_detail-carrier_id
                                  ConnectionID = gs_flight_detail-connection_id ) )
           FAILED DATA(connection_failed_delete)
           REPORTED DATA(connection_reported_delete).

    COMMIT ENTITIES
           RESPONSE OF zssvgi_connection
           FAILED DATA(connection_failed_commit)
           REPORTED DATA(connection_reported_commit).

    LOOP AT connection_reported_delete-connection ASSIGNING FIELD-SYMBOL(<fs_connection_delete>).
      IF <fs_connection_delete>-%msg->m_severity = if_abap_behv_message=>severity-error.
        MESSAGE <fs_connection_delete>-%msg TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
    ENDLOOP.

    LOOP AT connection_reported_commit-connection ASSIGNING FIELD-SYMBOL(<fs_connection_commit>).
      IF <fs_connection_commit>-%msg->m_severity = if_abap_behv_message=>severity-error.
        MESSAGE <fs_connection_commit>-%msg TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
    ENDLOOP.

    IF ( connection_failed_delete IS NOT INITIAL ) OR ( connection_failed_commit IS NOT INITIAL ).
      MESSAGE i010(z_ssvg_general) DISPLAY LIKE 'E'.
      ROLLBACK ENTITIES.
      RETURN.
    ENDIF.

    MODIFY ENTITIES OF zssvgi_flight
           ENTITY Flight
           DELETE FROM VALUE #( ( AirlineID    = gs_flight_detail-carrier_id
                                  ConnectionID = gs_flight_detail-connection_id
                                  FlightDate   = gs_flight_detail-flight_date ) )
           FAILED DATA(flight_failed_delete)
           REPORTED DATA(flight_reported_delete).

    COMMIT ENTITIES
           RESPONSE OF zssvgi_flight
           FAILED DATA(flight_failed_commit)
           REPORTED DATA(flight_reported_commit).

    LOOP AT flight_reported_delete-flight ASSIGNING FIELD-SYMBOL(<fs_flight_delete>).
      IF <fs_flight_delete>-%msg->m_severity = if_abap_behv_message=>severity-error.
        MESSAGE <fs_flight_delete>-%msg TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
    ENDLOOP.

    LOOP AT flight_reported_commit-flight ASSIGNING FIELD-SYMBOL(<fs_flight_commit>).
      IF <fs_flight_commit>-%msg->m_severity = if_abap_behv_message=>severity-error.
        MESSAGE <fs_flight_commit>-%msg TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
    ENDLOOP.

    IF ( flight_failed_delete IS NOT INITIAL ) OR ( flight_failed_commit IS NOT INITIAL ).
      MESSAGE i009(z_ssvg_general) DISPLAY LIKE 'E'.
      ROLLBACK ENTITIES.
      RETURN.
    ENDIF.

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
