*&---------------------------------------------------------------------*
*& Report z_ssvg_flights_batch_rap
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_ssvg_flights_batch_rap.

TYPES: BEGIN OF gs_flight,
         carrier_id     TYPE /dmo/carrier_id,
         connection_id  TYPE /dmo/connection_id,
         flight_date    TYPE /dmo/flight_date,
         seats_max      TYPE /dmo/plane_seats_max,
         seats_occupied TYPE /dmo/plane_seats_occupied,
       END OF gs_flight.

DATA: gt_flight_source            TYPE STANDARD TABLE OF gs_flight WITH EMPTY KEY,
      gt_flight_overbooked_target TYPE STANDARD TABLE OF zssvgi_flight_overbooked WITH EMPTY KEY,
      gv_successful_lines         TYPE i VALUE 0.

SELECT * FROM zssvgi_flight_overbooked
  INTO TABLE @gt_flight_overbooked_target.              "#EC CI_NOWHERE

IF gt_flight_overbooked_target IS NOT INITIAL.
  MODIFY ENTITIES OF zssvgi_flight_overbooked
         ENTITY Overbooked
         DELETE FROM CORRESPONDING #( gt_flight_overbooked_target )
         FAILED DATA(failed_delete)
         REPORTED DATA(reported_delete).

  COMMIT ENTITIES
         RESPONSE OF zssvgi_flight_overbooked
         FAILED DATA(failed_delete_commit)
         REPORTED DATA(reported_delete_commit).

  LOOP AT reported_delete-overbooked ASSIGNING FIELD-SYMBOL(<fs_overbooked_delete>).
    IF <fs_overbooked_delete>-%msg->m_severity = if_abap_behv_message=>severity-error.
      MESSAGE <fs_overbooked_delete>-%msg TYPE 'I' DISPLAY LIKE 'E'.
    ENDIF.
  ENDLOOP.

  LOOP AT reported_delete_commit-overbooked ASSIGNING FIELD-SYMBOL(<fs_overbooked_delete_commit>).
    IF <fs_overbooked_delete_commit>-%msg->m_severity = if_abap_behv_message=>severity-error.
      MESSAGE <fs_overbooked_delete_commit>-%msg TYPE 'I' DISPLAY LIKE 'E'.
    ENDIF.
  ENDLOOP.

  IF ( failed_delete IS NOT INITIAL ) OR ( failed_delete_commit IS NOT INITIAL ).
    MESSAGE i007(zssvg_flight_overb) DISPLAY LIKE 'E'.
    ROLLBACK ENTITIES.
    RETURN.
  ENDIF.
ENDIF.

SELECT AirlineID,
       ConnectionID,
       FlightDate
  FROM /DMO/I_Flight
  INTO TABLE @gt_flight_overbooked_target.              "#EC CI_NOWHERE

IF gt_flight_overbooked_target IS NOT INITIAL.
  MODIFY ENTITIES OF zssvgi_flight_overbooked
         ENTITY Overbooked
         CREATE AUTO FILL CID FIELDS ( AirlineID ConnectionID FlightDate )
         WITH CORRESPONDING #( gt_flight_overbooked_target )
         FAILED DATA(failed_create)
         REPORTED DATA(reported_create).

  COMMIT ENTITIES
         RESPONSE OF zssvgi_flight_overbooked
         FAILED DATA(failed_create_commit)
         REPORTED DATA(reported_create_commit).

  LOOP AT reported_create-overbooked ASSIGNING FIELD-SYMBOL(<fs_overbooked_create>).
    IF <fs_overbooked_create>-%msg->m_severity = if_abap_behv_message=>severity-error.
      MESSAGE <fs_overbooked_create>-%msg TYPE 'I' DISPLAY LIKE 'E'.
    ENDIF.
  ENDLOOP.

  LOOP AT reported_create_commit-overbooked ASSIGNING FIELD-SYMBOL(<fs_overbooked_create_commit>).
    IF <fs_overbooked_create_commit>-%msg->m_severity = if_abap_behv_message=>severity-error.
      MESSAGE <fs_overbooked_create_commit>-%msg TYPE 'I' DISPLAY LIKE 'E'.
    ENDIF.
  ENDLOOP.

  IF ( failed_create IS NOT INITIAL ) OR ( failed_create_commit IS NOT INITIAL ).
    MESSAGE i005(zssvg_flight_overb) DISPLAY LIKE 'E'.
    ROLLBACK ENTITIES.
    RETURN.
  ENDIF.
ENDIF.

gv_successful_lines = lines( gt_flight_overbooked_target ).

MESSAGE s004(zssvg_flight_overb) WITH gv_successful_lines.
