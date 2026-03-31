*&---------------------------------------------------------------------*
*& Include z_ssvg_top
*&---------------------------------------------------------------------*
TYPES gt_carrier_id   TYPE RANGE OF /dmo/carrier_id.
TYPES gt_airport_from TYPE RANGE OF /dmo/airport_from_id.
TYPES gt_airport_to   TYPE RANGE OF /dmo/airport_to_id.
TYPES gt_flight_date  TYPE RANGE OF /dmo/flight_date.
TYPES: BEGIN OF gs_flights,
         carrier_id      TYPE /dmo/carrier_id,
         connection_id   TYPE /dmo/connection_id,
         flight_date     TYPE /dmo/flight_date,
         airport_from_id TYPE /dmo/airport_from_id,
         airport_to_id   TYPE /dmo/airport_to_id,
         price           TYPE /dmo/flight_price,
         price_in_eur    TYPE /dmo/flight_price,
         currency_code   TYPE /dmo/currency_code,
         plane_type_id   TYPE /dmo/plane_type_id,
         seats_max       TYPE /dmo/plane_seats_max,
         seats_occupied  TYPE /dmo/plane_seats_occupied,
         departure_time  TYPE /dmo/flight_departure_time,
         arrival_time    TYPE /dmo/flight_arrival_time,
         distance        TYPE /dmo/flight_distance,
         distance_unit   TYPE msehi,
       END OF gs_flights,

       gt_flight_data  TYPE STANDARD TABLE OF gs_flights WITH EMPTY KEY,
       gt_airport      TYPE STANDARD TABLE OF /dmo/airport WITH EMPTY KEY,
       gt_string_table TYPE STANDARD TABLE OF string WITH EMPTY KEY.

CONSTANTS: gc_dynnr              TYPE sydynnr VALUE '1100',
           gc_gui_container_name TYPE c LENGTH 8 VALUE 'CNT_MAIN',
           gc_transaction_code   TYPE c LENGTH 14 VALUE 'Z_SSVG_FLIGHTS',
           gc_currency_code_euro TYPE /dmo/currency_code VALUE 'EUR'.

DATA: gv_departure_time  TYPE /dmo/flight_departure_time,
      gv_arrival_time    TYPE /dmo/flight_arrival_time,
      gv_aircraft_type   TYPE /dmo/plane_type_id,
      gv_number_of_seats TYPE /dmo/plane_seats_max,
      gv_seats_occupied  TYPE /dmo/plane_seats_occupied.
