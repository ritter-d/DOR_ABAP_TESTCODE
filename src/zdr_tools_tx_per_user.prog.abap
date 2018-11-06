REPORT zdr_tools_tx_per_user.

PARAMETERS: month TYPE dats DEFAULT sy-datum OBLIGATORY,
            user  TYPE usr02-bname OBLIGATORY DEFAULT sy-uname.

TYPES: BEGIN OF zusertcode,
         operation TYPE char30,
         type      TYPE char10,
         count     TYPE swncshcnt,
       END OF zusertcode.

TYPES: tt_zusertcode TYPE STANDARD TABLE OF zusertcode WITH KEY operation type.

DATA: lt_usertcode TYPE swnc_t_aggusertcode,
      ls_result    TYPE zusertcode,
      lt_result    TYPE tt_zusertcode.

CONSTANTS: cv_tcode  TYPE char30 VALUE 'Tcode',
           cv_report TYPE char30 VALUE 'Report',
           cv_count  TYPE char5 VALUE 'Count'.

START-OF-SELECTION.

  CALL FUNCTION 'SWNC_COLLECTOR_GET_AGGREGATES'
    EXPORTING
      component     = 'TOTAL'
      periodtype    = 'M'
      periodstrt    = month
    TABLES
      usertcode     = lt_usertcode
    EXCEPTIONS
      no_data_found = 1
      OTHERS        = 2.

  DELETE lt_usertcode WHERE tasktype <> '01'.

  LOOP AT lt_usertcode ASSIGNING FIELD-SYMBOL(<user>) WHERE account = user.
    CLEAR: ls_result.
    ls_result-operation = <user>-entry_id.
    ls_result-type = <user>-entry_id+72.
    ls_result-count = <user>-count.
    COLLECT ls_result INTO lt_result.
  ENDLOOP.

  SORT lt_result BY count DESCENDING.

  WRITE:  10 cv_tcode, 20 cv_report, 60 cv_count COLOR COL_NEGATIVE.
  LOOP AT lt_result ASSIGNING FIELD-SYMBOL(<result>).
    IF <result>-type = 'T'.
      WRITE: / <result>-operation COLOR COL_TOTAL UNDER cv_tcode,
               <result>-count COLOR COL_POSITIVE UNDER cv_count.
    ELSE.
      WRITE: / <result>-operation COLOR COL_GROUP UNDER cv_report,
               <result>-count COLOR COL_POSITIVE UNDER cv_count.
    ENDIF.
  ENDLOOP.
