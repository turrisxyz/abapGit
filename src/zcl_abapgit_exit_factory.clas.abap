CLASS zcl_abapgit_exit_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.
    CLASS-METHODS get_instance RETURNING VALUE(ro_result) TYPE REF TO zcl_abapgit_exit_factory.
    METHODS get_implementation_of IMPORTING iv_exit_name     TYPE seoclsname
                                  RETURNING VALUE(ro_result) TYPE REF TO object
                                  RAISING   zcx_abapgit_exception.
  PROTECTED SECTION.
  PRIVATE SECTION.
    METHODS create_instance IMPORTING iv_classname     TYPE seorelkey-refclsname
                            RETURNING VALUE(ro_result) TYPE REF TO object
                            RAISING   zcx_abapgit_exception.

ENDCLASS.



CLASS zcl_abapgit_exit_factory IMPLEMENTATION.

  METHOD get_implementation_of.

    DATA: ls_implementers TYPE seo_relkeys,
          lo_intf         TYPE REF TO cl_oo_interface,
          lv_classname    TYPE seorelkey-refclsname,
          lv_class_count  TYPE i.

    TRY.
        CREATE OBJECT lo_intf
          EXPORTING
            intfname = iv_exit_name.
      CATCH cx_class_not_existent ##no_handler.
    ENDTRY.

    IF lo_intf IS BOUND.

      ls_implementers = lo_intf->get_implementing_classes( ).

      DESCRIBE TABLE ls_implementers LINES lv_class_count.

      CASE lv_class_count.

        WHEN 0.
          RETURN.

        WHEN 1.
          lv_classname = ls_implementers[ 1 ]-clsname.
          ro_result = create_instance( lv_classname ).

        WHEN OTHERS.
          "Todo / feature: multi-instance exits in separate method
          zcx_abapgit_exception=>raise( |Exit { iv_exit_name } may only be implemented once| ).

      ENDCASE.
    ENDIF.

  ENDMETHOD.


  METHOD get_instance.
    CREATE OBJECT ro_result.
  ENDMETHOD.


  METHOD create_instance.

    DATA lo_error TYPE REF TO cx_sy_create_object_error.

    TRY.
        CREATE OBJECT ro_result TYPE (iv_classname).

      CATCH cx_sy_create_object_error INTO lo_error.
        zcx_abapgit_exception=>raise( iv_text = lo_error->get_text( )
                                      ix_previous = lo_error ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
