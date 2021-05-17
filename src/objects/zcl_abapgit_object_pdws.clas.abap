CLASS zcl_abapgit_object_pdws DEFINITION
  PUBLIC
  INHERITING FROM zcl_abapgit_object_pdxx_super
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    METHODS constructor IMPORTING is_item     TYPE zif_abapgit_definitions=>ty_item
                                  iv_language TYPE spras
                        RAISING   zcx_abapgit_exception.

    METHODS zif_abapgit_object~serialize REDEFINITION.
    METHODS zif_abapgit_object~deserialize REDEFINITION.
    METHODS zif_abapgit_object~changed_by REDEFINITION.

  PROTECTED SECTION.

  PRIVATE SECTION.
    CONSTANTS c_object_type_workflow TYPE hr_sotype VALUE 'WS'.

    METHODS get_active_definition_key RETURNING VALUE(rs_wf_definition_key) TYPE swd_wfdkey.

ENDCLASS.


CLASS zcl_abapgit_object_pdws IMPLEMENTATION.

  METHOD constructor.

    super->constructor( is_item     = is_item
                        iv_language = iv_language ).

    IF is_experimental( ) = abap_false.
      "Work in progress
      zcx_abapgit_exception=>raise( 'PDWS is still work in progress' ).
    ENDIF.

    ms_objkey-otype = 'WS'.
    ms_objkey-objid = ms_item-obj_name.

  ENDMETHOD.


  METHOD zif_abapgit_object~changed_by.

    SELECT SINGLE uname
      INTO rv_user
      FROM hrs1205
      WHERE otype = ms_objkey-otype AND
            objid = ms_objkey-objid.

    IF sy-subrc <> 0.
      rv_user = c_user_unknown.
    ENDIF.

  ENDMETHOD.


  METHOD zif_abapgit_object~deserialize.

  ENDMETHOD.


  METHOD zif_abapgit_object~serialize.

    DATA: ls_wf_definition_key TYPE swd_wfdkey,

          lo_wfd_xml           TYPE REF TO cl_xml_document_base,
          lo_wfd_export        TYPE REF TO if_swf_pdef_export,
          lt_versions          TYPE TABLE OF swd_versns,

          lo_node              TYPE REF TO if_ixml_element,
          lo_def               TYPE REF TO lcl_workflow_definition,
          lo_error             TYPE REF TO zcx_abapgit_exception,
          lv_retcode           TYPE sysubrc,
          lv_stream            TYPE string,
          lv_size              TYPE sytabix,
          lv_definition        TYPE sww_task.

    lv_definition = 'WS90000001'.

    lo_def = lcl_workflow_definition=>load( lv_definition ).

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
    ELSE.
      zcx_abapgit_exception=>raise( 'Could not serialize PDWS' ).
    ENDIF.

  ENDMETHOD.

  METHOD get_active_definition_key.

    DATA lt_versions TYPE STANDARD TABLE OF swd_versns WITH DEFAULT KEY.

    CALL FUNCTION 'SWD_GET_VERSIONS_OF_WORKFLOW'
      EXPORTING
        im_task          = ms_objkey
        im_exetyp        = 'S'
      IMPORTING
        ex_active_wfdkey = rs_wf_definition_key
      TABLES
        ex_versions      = lt_versions.

  ENDMETHOD.


ENDCLASS.
