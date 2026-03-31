CLASS z_cl_ssvg_gui_container DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    CLASS-METHODS get_instance
      IMPORTING
        iv_container_name  TYPE c
        iv_repid           TYPE syrepid
        iv_dynnr           TYPE sy-dynnr
      RETURNING
        VALUE(ro_instance) TYPE REF TO cl_gui_custom_container.
  PROTECTED SECTION.
  PRIVATE SECTION.
    CLASS-DATA lo_instance TYPE REF TO cl_gui_custom_container.

    CLASS-METHODS create_instance
      IMPORTING
        iv_container_name TYPE c
        iv_repid          TYPE syrepid
        iv_dynnr          TYPE sy-dynnr.
ENDCLASS.

CLASS z_cl_ssvg_gui_container IMPLEMENTATION.
  METHOD get_instance.
    IF lo_instance IS NOT BOUND.
      create_instance( iv_container_name = iv_container_name
                       iv_repid          = iv_repid
                       iv_dynnr          = iv_dynnr ).
    ENDIF.
    ro_instance = lo_instance.
  ENDMETHOD.

  METHOD create_instance.
    lo_instance = NEW cl_gui_custom_container( container_name = iv_container_name
                                               repid          = iv_repid
                                               dynnr          = iv_dynnr ).
  ENDMETHOD.
ENDCLASS.

