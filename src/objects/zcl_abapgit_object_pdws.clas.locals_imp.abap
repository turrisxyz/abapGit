CLASS lcl_workflow_definition DEFINITION CREATE PUBLIC.

  PUBLIC SECTION.
    CLASS-METHODS load  IMPORTING iv_wf            TYPE sww_task
                        RETURNING VALUE(rv_result) TYPE REF TO lcl_workflow_definition
                        RAISING   zcx_abapgit_exception.

    METHODS serialize RETURNING VALUE(rv_result) TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
    DATA mv_wf TYPE sww_task.
    DATA mv_objid TYPE hrobjid.
    DATA mo_wfdef TYPE REF TO cl_workflow_task_ws.

    METHODS supply_instance RAISING zcx_abapgit_exception.
    METHODS check_subrc_for IMPORTING iv_call TYPE clike OPTIONAL
                            RAISING   zcx_abapgit_exception.
    METHODS get_active_definition_key RETURNING VALUE(rs_wf_definition_key) TYPE swd_wfdkey.
ENDCLASS.

CLASS lcl_workflow_definition IMPLEMENTATION.

  METHOD load.
    DATA lo_def TYPE REF TO lcl_workflow_definition.

    CREATE OBJECT lo_def.
    lo_def->mv_wf = iv_wf.
    lo_def->mv_objid = iv_wf+2(8).
    lo_def->supply_instance( ).
    rv_result = lo_def.
  ENDMETHOD.


  METHOD supply_instance.

    cl_workflow_factory=>create_ws(
       EXPORTING
         objid                        = mv_objid
       RECEIVING
         ws_inst                      = mo_wfdef
       EXCEPTIONS
         workflow_does_not_exist = 1
         object_could_not_be_locked   = 2
         objid_not_given              = 3
         OTHERS                       = 4 )  ##SUBRC_OK.

    check_subrc_for( 'CREATE_TS' ).

  ENDMETHOD.


  METHOD check_subrc_for.
    IF sy-subrc <> 0.
      zcx_abapgit_exception=>raise( iv_call && ' returned ' && sy-subrc ).
    ENDIF.
  ENDMETHOD.

  METHOD serialize.

    DATA: ls_wf_definition_key TYPE swd_wfdkey,

          lo_wfd_xml           TYPE REF TO cl_xml_document_base,
          lo_wfd_export        TYPE REF TO if_swf_pdef_export,
          lt_versions          TYPE TABLE OF swd_versns,

          lo_node              TYPE REF TO if_ixml_element,
          lo_def               TYPE REF TO lcl_workflow_definition,
          lo_error             TYPE REF TO zcx_abapgit_exception,
          lv_retcode           TYPE sysubrc,
          lv_stream            TYPE string,
          lv_size              TYPE sytabix.

    TRY.
        lo_def = load( mv_wf ).
      CATCH zcx_abapgit_exception INTO lo_error.
        WRITE / lo_error->get_text( ).
    ENDTRY.

    ls_wf_definition_key = get_active_definition_key( ).

    CREATE OBJECT lo_wfd_export TYPE cl_wfd_convert_def_to_ixml.

    lo_wfd_xml = lo_wfd_export->convert( load_from_db = abap_true
                                         language = sy-langu
                                         wfd_key = ls_wf_definition_key ).

    IF lo_wfd_xml IS BOUND.

*  Blah foo bar lo_node->append_child( lo_wfd_xml->get_first_node( ) ).

      lo_wfd_xml->render_2_string(
        EXPORTING
          pretty_print = 'X'
        IMPORTING
          retcode      = lv_retcode
          stream       = lv_stream
          size         = lv_size ).

      cl_demo_output=>display_xml( lv_stream ).
      rv_result = lv_stream.
    ELSE.
      cl_demo_output=>display( 'No XML' ).
    ENDIF.

  ENDMETHOD.

  METHOD get_active_definition_key.
    DATA: lt_versions TYPE STANDARD TABLE OF swd_versns.

    CALL FUNCTION 'SWD_GET_VERSIONS_OF_WORKFLOW'
      EXPORTING
        im_task          = mv_wf
        im_exetyp        = 'S'
      IMPORTING
        ex_active_wfdkey = rs_wf_definition_key
      TABLES
        ex_versions      = lt_versions.

  ENDMETHOD.


ENDCLASS.
