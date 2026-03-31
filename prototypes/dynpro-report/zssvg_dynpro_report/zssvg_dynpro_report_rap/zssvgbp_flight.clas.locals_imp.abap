CLASS lhc_ZSSVGR_Flight DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Flight RESULT result.
    METHODS setoccupiedseats FOR MODIFY
      IMPORTING keys FOR ACTION flight~setoccupiedseats RESULT result.
    METHODS validateoccupiedseats FOR VALIDATE ON SAVE
      IMPORTING keys FOR flight~validateoccupiedseats.

ENDCLASS.

CLASS lhc_ZSSVGR_Flight IMPLEMENTATION.

  METHOD get_instance_authorizations.
    RETURN.
  ENDMETHOD.

  METHOD setOccupiedSeats.

    MODIFY ENTITIES OF ZSSVGR_Flight IN LOCAL MODE
      ENTITY Flight
      UPDATE FIELDS ( OccupiedSeats )
      WITH VALUE #( FOR key IN keys (
        %tky          = key-%tky
        OccupiedSeats = key-%param-OccupiedSeats ) )
      FAILED failed
      REPORTED reported.

    READ ENTITIES OF ZSSVGR_Flight IN LOCAL MODE
      ENTITY Flight
      ALL FIELDS
      WITH VALUE #( FOR key IN keys ( %tky = key-%tky ) )
      RESULT DATA(updated).

    result = VALUE #( FOR row IN updated (
      %tky   = row-%tky
      %param = row ) ).

  ENDMETHOD.

  METHOD validateOccupiedSeats.
    READ ENTITIES OF ZSSVGR_Flight IN LOCAL MODE
         ENTITY Flight
         ALL FIELDS
         WITH CORRESPONDING #( keys )
         RESULT DATA(flights).

    LOOP AT flights INTO DATA(flight).

      DATA lv_message_text TYPE string.

      IF flight-OccupiedSeats > flight-MaximumSeats.
        lv_message_text = TEXT-001.
      ELSEIF flight-OccupiedSeats < 0.
        lv_message_text = TEXT-002.
      ENDIF.

      IF lv_message_text IS NOT INITIAL.
        APPEND VALUE #( %tky = flight-%tky ) TO failed-flight.

        APPEND VALUE #( %tky = flight-%tky
                        %msg = new_message_with_text( severity = if_abap_behv_message=>severity-error
                                                      text     = lv_message_text ) )
               TO reported-flight.
      ENDIF.

    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
