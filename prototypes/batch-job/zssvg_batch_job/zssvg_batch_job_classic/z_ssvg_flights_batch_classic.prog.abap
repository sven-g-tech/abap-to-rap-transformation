*&---------------------------------------------------------------------*
*& Report z_ssvg_flights_batch_classic
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_ssvg_flights_batch_classic.

TYPES: BEGIN OF gs_flight,
         carrier_id     TYPE /dmo/carrier_id,
         connection_id  TYPE /dmo/connection_id,
         flight_date    TYPE /dmo/flight_date,
         seats_max      TYPE /dmo/plane_seats_max,
         seats_occupied TYPE /dmo/plane_seats_occupied,
       END OF gs_flight.

CONSTANTS: gc_table_name TYPE tabname   VALUE 'ZSSVG_FLIGHT',
           gc_lock_name  TYPE enqu_name VALUE 'EZSSVG_FLIGHT'.

DATA: gt_flight_source            TYPE STANDARD TABLE OF gs_flight WITH EMPTY KEY,
      gt_flight_overbooked_target TYPE zssvg_t_flight_overbooked,
      gv_successful_lines         TYPE i VALUE 0,
      go_flight_overbooked_db     TYPE REF TO zcl_ssvg_flight_overbooked_db,
      go_flight_lock              TYPE REF TO if_abap_lock_object.

go_flight_overbooked_db = NEW zcl_ssvg_flight_overbooked_db( ).

SELECT * FROM zssvg_flight
  INTO TABLE gt_flight_overbooked_target.               "#EC CI_NOWHERE

IF gt_flight_overbooked_target IS NOT INITIAL.
  TRY.
      go_flight_lock = cl_abap_lock_object_factory=>get_instance( gc_lock_name ).

      go_flight_lock->enqueue( it_table_mode = VALUE #( ( table_name = gc_table_name
                                                          mode       = if_abap_lock_object=>cs_mode-write_lock ) ) ).
    CATCH cx_abap_foreign_lock
          cx_abap_lock_failure INTO DATA(lo_lock_delete_exception).
      MESSAGE lo_lock_delete_exception->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
      RETURN.
  ENDTRY.

  TRY.
      go_flight_overbooked_db->delete( it_flight_overbooked = gt_flight_overbooked_target ).

    CATCH zcx_ssvg_flight_overbooked_db INTO DATA(lo_delete_exception).
      MESSAGE lo_delete_exception->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
      ROLLBACK WORK.
      RETURN.
  ENDTRY.
ENDIF.

SELECT carrier_id,
       connection_id,
       flight_date,
       seats_max,
       seats_occupied
  FROM /dmo/flight
  INTO TABLE @gt_flight_source.                         "#EC CI_NOWHERE

gt_flight_overbooked_target = VALUE #(
    FOR ls_flight_overbooked_source IN gt_flight_source
    ( carrier_id         = ls_flight_overbooked_source-carrier_id
      connection_id      = ls_flight_overbooked_source-connection_id
      flight_date        = ls_flight_overbooked_source-flight_date
      booking_ratio      = COND #( WHEN ls_flight_overbooked_source-seats_max = 0
                                   THEN 0
                                   ELSE ( ls_flight_overbooked_source-seats_occupied * 100 ) / ls_flight_overbooked_source-seats_max )
      is_overbooked_risk = COND abap_bool(
                             WHEN ls_flight_overbooked_source-seats_max = 0              THEN abap_false
                             WHEN ( ls_flight_overbooked_source-seats_occupied * 100 ) /
                                  ls_flight_overbooked_source-seats_max > 80             THEN abap_true
                             ELSE                                                             abap_false )
      is_overbooked      = COND #( WHEN ls_flight_overbooked_source-seats_occupied > ls_flight_overbooked_source-seats_max
                                   THEN abap_true
                                   ELSE abap_false ) ) ).

IF gt_flight_overbooked_target IS NOT INITIAL.
  TRY.
      go_flight_lock = cl_abap_lock_object_factory=>get_instance( gc_lock_name ).

      go_flight_lock->enqueue( it_table_mode = VALUE #( ( table_name = gc_table_name
                                                          mode       = if_abap_lock_object=>cs_mode-write_lock ) ) ).
    CATCH cx_abap_foreign_lock
          cx_abap_lock_failure INTO DATA(lo_lock_create_exception).
      MESSAGE lo_lock_create_exception->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
      RETURN.
  ENDTRY.

  TRY.
      go_flight_overbooked_db->create( it_flight_overbooked = gt_flight_overbooked_target ).

    CATCH zcx_ssvg_flight_overbooked_db INTO DATA(lo_create_exception).
      MESSAGE lo_create_exception->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
      ROLLBACK WORK.
      RETURN.
  ENDTRY.
ENDIF.

gv_successful_lines = lines( gt_flight_overbooked_target ).

MESSAGE s004(zssvg_flight_overb) WITH gv_successful_lines.
