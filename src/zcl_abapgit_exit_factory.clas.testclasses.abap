INTERFACE lif_test.
ENDINTERFACE.

CLASS ltc_test DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PUBLIC SECTION.
    INTERFACES lif_test.

  PRIVATE SECTION.

    DATA mo_cut TYPE REF TO zcl_abapgit_exit_factory.

    METHODS setup.

    METHODS not_found_is_empty FOR TESTING RAISING cx_static_check.
    METHODS correct_instance_returned FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltc_test IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_abapgit_exit_factory( ).
  ENDMETHOD.


  METHOD not_found_is_empty.
    DATA lo_exit TYPE REF TO object.

    lo_exit = mo_cut->get_implementation_of( 'FOO' ).
    cl_abap_unit_assert=>assert_not_bound( lo_exit ).

  ENDMETHOD.


  METHOD correct_instance_returned.
    DATA lo_exit TYPE REF TO object.

    lo_exit = mo_cut->get_implementation_of( 'ZIF_ABAPGIT_LOG' ).
    cl_abap_unit_assert=>assert_bound( lo_exit ).
    IF NOT lo_exit IS INSTANCE OF zcl_abapgit_log.
      cl_abap_unit_assert=>fail( ).
    ENDIF.

  ENDMETHOD.


ENDCLASS.
