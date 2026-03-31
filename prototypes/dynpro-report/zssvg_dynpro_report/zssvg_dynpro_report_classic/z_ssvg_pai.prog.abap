*&---------------------------------------------------------------------*
*& Include z_ssvg_pai
*&---------------------------------------------------------------------*
MODULE user_command_1100 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
      MESSAGE i012(z_ssvg_general) DISPLAY LIKE 'E'.
  ENDCASE.
ENDMODULE.

MODULE user_command_1200 INPUT.
  CASE sy-ucomm.
    WHEN 'BACK' OR 'CANCEL' OR 'EXIT'.
      LEAVE TO SCREEN 0.
    WHEN 'SAVE'.
      lv_controller->update_record( iv_aircraft_type   = gv_aircraft_type
                                    iv_arrival_time    = gv_arrival_time
                                    iv_departure_time  = gv_departure_time
                                    iv_number_of_seats = gv_number_of_seats
                                    iv_seats_occupied  = gv_seats_occupied ).
    WHEN 'DELETE'.
      lv_controller->delete_record( ).
      LEAVE TO SCREEN 0.
    WHEN OTHERS.
      MESSAGE i012(z_ssvg_general) DISPLAY LIKE 'E'.
  ENDCASE.
ENDMODULE.
