*&---------------------------------------------------------------------*
*& Include z_ssvg_pbo
*&---------------------------------------------------------------------*
MODULE status_1100 OUTPUT.
  SET PF-STATUS 'ST_1100'.
  SET TITLEBAR 'ST_1100_TITLE'.

  DATA(lv_controller) = z_lcl_ssvg_controller=>get_instance( ).

  lv_controller->update_view( iv_carr = so_carr[]
                              iv_airf = so_airf[]
                              iv_airt = so_airt[]
                              iv_fldt = so_fldt[]  ).
ENDMODULE.

MODULE status_1200 OUTPUT.
  SET PF-STATUS 'ST_1200'.
  SET TITLEBAR 'ST_1200_TITLE'.
ENDMODULE.
