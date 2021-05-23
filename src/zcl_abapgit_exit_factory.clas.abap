CLASS zcl_abapgit_exit_factory DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS get_implementation_of IMPORTING iv_exit_name     TYPE seoclsname
                                  RETURNING VALUE(ro_result) TYPE REF TO object
                                  RAISING   zcx_abapgit_exception.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_abapgit_exit_factory IMPLEMENTATION.

  METHOD get_implementation_of.

    DATA: ls_implementers TYPE seo_relkeys,
          lo_intf         TYPE REF TO cl_oo_interface,
          lv_classname    TYPE seorelkey-refclsname.

    TRY.
        lo_intf = NEW cl_oo_interface( iv_exit_name ).
      CATCH cx_class_not_existent.
        RETURN.
    ENDTRY.

    ls_implementers = lo_intf->get_implementing_classes( ).
    IF lines( ls_implementers ) > 1.
      zcx_abapgit_exception=>raise( |Exit { iv_exit_name } may only be implemented once| ).
    ENDIF.

    lv_classname = ls_implementers[ 1 ]-clsname.
    TRY.
        CREATE OBJECT ro_result TYPE (lv_classname).
      CATCH cx_sy_create_object_error INTO DATA(lo_error).
        zcx_abapgit_exception=>raise( iv_text = lo_error->get_text( )
                                      ix_previous = lo_error ).
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
