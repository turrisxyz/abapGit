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
          lv_classname    TYPE seorelkey-refclsname.

    TRY.
        lo_intf = NEW cl_oo_interface( iv_exit_name ).
      CATCH cx_class_not_existent ##no_handler.
    ENDTRY.

    IF lo_intf IS BOUND.

      ls_implementers = lo_intf->get_implementing_classes( ).
      "Todo: multi-instance exits as separate method
      IF lines( ls_implementers ) > 1.
        zcx_abapgit_exception=>raise( |Exit { iv_exit_name } may only be implemented once (todo)| ).
      ENDIF.

      ro_result = create_instance( iv_classname = ls_implementers[ 1 ]-clsname ).

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
