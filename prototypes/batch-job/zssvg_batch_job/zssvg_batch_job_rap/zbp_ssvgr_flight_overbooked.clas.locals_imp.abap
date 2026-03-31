CLASS lhc_ZSSVGR_FLIGHT_OVERBOOKED DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Overbooked RESULT result.
    METHODS calculateOverbooking FOR DETERMINE ON MODIFY
      IMPORTING keys FOR overbooked~calculateOverbooking.

ENDCLASS.


CLASS lhc_ZSSVGR_FLIGHT_OVERBOOKED IMPLEMENTATION.
  METHOD get_instance_authorizations.
    RETURN.
  ENDMETHOD.

  METHOD calculateOverbooking.
    SELECT AirlineID, ConnectionID, FlightDate, MaximumSeats, OccupiedSeats
      FROM /DMO/I_Flight
      FOR ALL ENTRIES IN @keys
      WHERE AirlineID    = @keys-AirlineID
        AND ConnectionID = @keys-ConnectionID
        AND FlightDate   = @keys-FlightDate
      INTO TABLE @DATA(lt_flights).

    READ ENTITIES OF zssvgr_flight_overbooked IN LOCAL MODE
         ENTITY overbooked
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT DATA(flights).

    LOOP AT flights ASSIGNING FIELD-SYMBOL(<fs_flight_overbooked>).
      ASSIGN lt_flights[ AirlineID    = <fs_flight_overbooked>-AirlineID
                         ConnectionId = <fs_flight_overbooked>-ConnectionID
                         FlightDate   = <fs_flight_overbooked>-FlightDate ] TO FIELD-SYMBOL(<fs_flight>).

      IF <fs_flight> IS NOT ASSIGNED.
        CONTINUE.
      ENDIF.

      DATA(lv_booking_ratio) = COND #( WHEN <fs_flight>-MaximumSeats = 0
                                       THEN 0
                                       ELSE ( <fs_flight>-OccupiedSeats * 100 ) / <fs_flight>-MaximumSeats ).

      <fs_flight_overbooked>-bookingratio     = lv_booking_ratio.
      <fs_flight_overbooked>-isoverbookedrisk = COND #( WHEN lv_booking_ratio > 80
                                                        THEN abap_true
                                                        ELSE abap_false ).
      <fs_flight_overbooked>-isoverbooked     = COND #( WHEN <fs_flight>-OccupiedSeats > <fs_flight>-MaximumSeats
                                                        THEN abap_true
                                                        ELSE abap_false ).
    ENDLOOP.

    MODIFY ENTITIES OF zssvgr_flight_overbooked IN LOCAL MODE
           ENTITY overbooked
           UPDATE FIELDS ( BookingRatio IsOverbookedRisk IsOverbooked )
           WITH CORRESPONDING #( flights ).
  ENDMETHOD.
ENDCLASS.
