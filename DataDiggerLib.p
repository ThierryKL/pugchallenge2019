&ANALYZE-SUSPEND _VERSION-NUMBER AB_v10r12
&ANALYZE-RESUME
&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _DEFINITIONS Procedure 
/*------------------------------------------------------------------------

  Name: DataDiggerLib.p
  Desc: Library for DataDigger functions

------------------------------------------------------------------------*/
/*          This .W file was created with the Progress AppBuilder.       */
/*----------------------------------------------------------------------*/
DEFINE VARIABLE gcSaveDatabaseList  AS CHARACTER  NO-UNDO.  

/* Buildnr, temp-tables and forward defs */
{ DataDigger.i }

PROCEDURE GetUserNameA EXTERNAL "ADVAPI32.DLL":
  DEFINE INPUT        PARAMETER mUserId       AS MEMPTR NO-UNDO.
  DEFINE INPUT-OUTPUT PARAMETER intBufferSize AS LONG NO-UNDO.
  DEFINE RETURN       PARAMETER intResult     AS SHORT NO-UNDO.
END PROCEDURE. 

/* Detect bitness of running Progress version
 * See Progress kb #54631
 */
&IF PROVERSION <= '8' &THEN  /* OE 10+ */
  &IF PROVERSION >= '11.3' &THEN   /* PROCESS-ARCHITECTURE function is available */
    &IF PROCESS-ARCHITECTURE = 32 &THEN /* 32-bit pointers */
      &GLOBAL-DEFINE POINTERTYPE LONG
      &GLOBAL-DEFINE POINTERBYTES 4
    &ELSEIF PROCESS-ARCHITECTURE = 64 &THEN /* 64-bit pointers */
      &GLOBAL-DEFINE POINTERTYPE INT64
      &GLOBAL-DEFINE POINTERBYTES 8
    &ENDIF  /* PROCESS-ARCHITECTURE */
  &ELSE   /* Can't check architecture pre-11.3 so default to 32-bit */
    &GLOBAL-DEFINE POINTERTYPE LONG
    &GLOBAL-DEFINE POINTERBYTES 4
  &ENDIF  /* PROVERSION > 11.3 */
&ELSE   /* pre-OE10 always 32-bit on Windows */
  &GLOBAL-DEFINE POINTERTYPE LONG
  &GLOBAL-DEFINE POINTERBYTES 4
&ENDIF  /* PROVERSION < 8 */

PROCEDURE GetKeyboardState EXTERNAL "user32.dll":
  DEFINE INPUT  PARAMETER KBState AS {&POINTERTYPE}. /* memptr */
  DEFINE RETURN PARAMETER RetVal  AS LONG. /* bool   */
END PROCEDURE.

/* Windows API entry point */
PROCEDURE ShowScrollBar EXTERNAL "user32.dll":
  DEFINE INPUT  PARAMETER hwnd        AS LONG.
  DEFINE INPUT  PARAMETER fnBar       AS LONG.
  DEFINE INPUT  PARAMETER fShow       AS LONG.
  DEFINE RETURN PARAMETER ReturnValue AS LONG.
END PROCEDURE.

PROCEDURE SendMessageA EXTERNAL "user32.dll":
  DEFINE INPUT  PARAMETER hwnd   AS long NO-UNDO.
  DEFINE INPUT  PARAMETER wmsg   AS long NO-UNDO.
  DEFINE INPUT  PARAMETER wparam AS long NO-UNDO.
  DEFINE INPUT  PARAMETER lparam AS long NO-UNDO.
  DEFINE RETURN PARAMETER rc     AS long NO-UNDO.
END PROCEDURE.

PROCEDURE RedrawWindow EXTERNAL "user32.dll":
  DEFINE INPUT PARAMETER v-hwnd  AS LONG NO-UNDO.
  DEFINE INPUT PARAMETER v-rect  AS LONG NO-UNDO.
  DEFINE INPUT PARAMETER v-rgn   AS LONG NO-UNDO.
  DEFINE INPUT PARAMETER v-flags AS LONG NO-UNDO.
  DEFINE RETURN PARAMETER v-ret  AS LONG NO-UNDO.
END PROCEDURE.

PROCEDURE SetWindowTextA EXTERNAL "user32.dll":
  DEFINE INPUT PARAMETER hwnd AS long.
  DEFINE INPUT PARAMETER txt AS CHARACTER.
END PROCEDURE.

PROCEDURE GetWindow EXTERNAL "user32.dll" :
  DEFINE INPUT PARAMETER hwnd AS LONG.
  DEFINE INPUT PARAMETER uCmd AS LONG.
  DEFINE RETURN PARAMETER hwndOther AS LONG.
END PROCEDURE.

PROCEDURE GetParent EXTERNAL "user32.dll" :
  DEFINE INPUT PARAMETER hwndChild AS LONG.
  DEFINE RETURN PARAMETER hwndParent AS LONG.
END PROCEDURE.

PROCEDURE GetCursorPos EXTERNAL "user32":
  DEFINE INPUT  PARAMETER  lpPoint     AS MEMPTR.
  DEFINE RETURN PARAMETER  ReturnValue AS LONG.
END PROCEDURE.

PROCEDURE GetSysColor EXTERNAL "user32.dll":
  DEFINE INPUT PARAMETER nDspElement AS LONG.
  DEFINE RETURN PARAMETER COLORREF AS LONG.
END.

PROCEDURE ScreenToClient EXTERNAL "user32.dll" :
  DEFINE INPUT  PARAMETER hWnd     AS LONG.
  DEFINE INPUT  PARAMETER lpPoint  AS MEMPTR.
END PROCEDURE.

/* Transparency */
PROCEDURE SetWindowLongA EXTERNAL "user32.dll":
  DEFINE INPUT PARAMETER HWND AS LONG.
  DEFINE INPUT PARAMETER nIndex AS LONG.
  DEFINE INPUT PARAMETER dwNewLong AS LONG.
  DEFINE RETURN PARAMETER stat AS LONG.
END.

PROCEDURE SetLayeredWindowAttributes EXTERNAL "user32.dll":
  DEFINE INPUT PARAMETER HWND AS LONG.
  DEFINE INPUT PARAMETER crKey AS LONG.
  DEFINE INPUT PARAMETER bAlpha AS SHORT.
  DEFINE INPUT PARAMETER dwFlagsas AS LONG.
  DEFINE RETURN PARAMETER stat AS SHORT.
END.


/* Find out if a file is locked */
&GLOBAL-DEFINE GENERIC_WRITE         1073741824 /* &H40000000 */
&GLOBAL-DEFINE OPEN_EXISTING         3
&GLOBAL-DEFINE FILE_SHARE_READ       1          /* = &H1 */
&GLOBAL-DEFINE FILE_ATTRIBUTE_NORMAL 128        /* = &H80 */

PROCEDURE CreateFileA EXTERNAL "kernel32":
  DEFINE INPUT PARAMETER lpFileName AS CHARACTER.
  DEFINE INPUT PARAMETER dwDesiredAccess AS LONG.
  DEFINE INPUT PARAMETER dwShareMode AS LONG.
  DEFINE INPUT PARAMETER lpSecurityAttributes AS LONG.
  DEFINE INPUT PARAMETER dwCreationDisposition AS LONG.
  DEFINE INPUT PARAMETER dwFlagsAndAttributes AS LONG.
  DEFINE INPUT PARAMETER hTemplateFile AS LONG.
  DEFINE RETURN PARAMETER ReturnValue AS LONG.
END PROCEDURE.

PROCEDURE CloseHandle EXTERNAL "kernel32" :
  DEFINE INPUT  PARAMETER hObject     AS LONG.
  DEFINE RETURN PARAMETER ReturnValue AS LONG.
END PROCEDURE.

DEFINE TEMP-TABLE ttWidget NO-UNDO RCODE-INFORMATION
  FIELD hWidget   AS HANDLE
  FIELD iPosX     AS INTEGER
  FIELD iWidth    AS INTEGER
  INDEX iPrim AS PRIMARY hWidget.

DEFINE TEMP-TABLE ttColor NO-UNDO RCODE-INFORMATION
  FIELD cName  AS CHARACTER
  FIELD iColor AS INTEGER
  INDEX iPrim AS PRIMARY cName.

DEFINE TEMP-TABLE ttFont NO-UNDO RCODE-INFORMATION
  FIELD cName  AS CHARACTER
  FIELD iFont  AS INTEGER
  INDEX iPrim AS PRIMARY cName.

/* If you have trouble with the cache, disable it in the settings screen */
DEFINE VARIABLE glCacheTableDefs AS LOGICAL NO-UNDO.
DEFINE VARIABLE glCacheFieldDefs AS LOGICAL NO-UNDO.

/* Vars for caching dirnames */
DEFINE VARIABLE gcProgramDir AS CHARACTER NO-UNDO.
DEFINE VARIABLE gcWorkFolder AS CHARACTER NO-UNDO.

/* Locking / unlocking windows */
&GLOBAL-DEFINE WM_SETREDRAW     11
&GLOBAL-DEFINE RDW_ALLCHILDREN 128
&GLOBAL-DEFINE RDW_ERASE         4
&GLOBAL-DEFINE RDW_INVALIDATE    1

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


&ANALYZE-SUSPEND _UIB-PREPROCESSOR-BLOCK 

/* ********************  Preprocessor Definitions  ******************** */

&Scoped-define PROCEDURE-TYPE Procedure
&Scoped-define DB-AWARE no



/* _UIB-PREPROCESSOR-BLOCK-END */
&ANALYZE-RESUME


/* ************************  Function Prototypes ********************** */

&IF DEFINED(EXCLUDE-addConnection) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD addConnection Procedure 
FUNCTION addConnection RETURNS LOGICAL
  ( pcDatabase AS CHARACTER
  , pcSection  AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-formatQueryString) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD formatQueryString Procedure 
FUNCTION formatQueryString RETURNS CHARACTER
  ( INPUT pcQueryString AS CHARACTER
  , INPUT plExpanded    AS LOGICAL )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getColor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getColor Procedure 
FUNCTION getColor RETURNS INTEGER
  ( pcName AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getColorByRGB) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getColorByRGB Procedure 
FUNCTION getColorByRGB RETURNS INTEGER
  ( piRed   AS INTEGER
  , piGreen AS INTEGER
  , piBlue  AS INTEGER
  ) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getColumnLabel) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getColumnLabel Procedure 
FUNCTION getColumnLabel RETURNS CHARACTER
  ( INPUT phFieldBuffer AS HANDLE ) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getColumnWidthList) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getColumnWidthList Procedure 
FUNCTION getColumnWidthList RETURNS CHARACTER
  ( INPUT phBrowse AS HANDLE ) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getDatabaseList) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getDatabaseList Procedure 
FUNCTION getDatabaseList RETURNS CHARACTER FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getEscapedData) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getEscapedData Procedure 
FUNCTION getEscapedData RETURNS CHARACTER
  ( pcTarget AS CHARACTER
  , pcString AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getFieldList) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getFieldList Procedure 
FUNCTION getFieldList RETURNS CHARACTER
  ( pcDatabase AS CHARACTER
  , pcFile     AS CHARACTER
  ) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getFileCategory) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getFileCategory Procedure 
FUNCTION getFileCategory RETURNS CHARACTER
  ( piFileNumber AS INTEGER
  , pcFileName   AS CHARACTER
  )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getFont) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getFont Procedure 
FUNCTION getFont RETURNS INTEGER
  ( pcName AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getImagePath) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getImagePath Procedure 
FUNCTION getImagePath RETURNS CHARACTER
  ( pcImage AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getIndexFields) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getIndexFields Procedure 
FUNCTION getIndexFields RETURNS CHARACTER
  ( INPUT pcDatabaseName AS CHARACTER
  , INPUT pcTableName    AS CHARACTER
  , INPUT pcFlags        AS CHARACTER
  )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getKeyList) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getKeyList Procedure 
FUNCTION getKeyList RETURNS CHARACTER
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getLinkInfo) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getLinkInfo Procedure 
FUNCTION getLinkInfo RETURNS CHARACTER
  ( INPUT pcFieldName AS CHARACTER
  ) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getMaxLength) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getMaxLength Procedure 
FUNCTION getMaxLength RETURNS INTEGER
  ( cFieldList AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getOsErrorDesc) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getOsErrorDesc Procedure 
FUNCTION getOsErrorDesc RETURNS CHARACTER
  (INPUT piOsError AS INTEGER) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getProgramDir) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getProgramDir Procedure 
FUNCTION getProgramDir RETURNS CHARACTER
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getQuery) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getQuery Procedure 
FUNCTION getQuery RETURNS CHARACTER
  ( INPUT pcDatabase AS CHARACTER
  , INPUT pcTable    AS CHARACTER
  , INPUT piQuery    AS INTEGER
  )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getReadableQuery) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getReadableQuery Procedure 
FUNCTION getReadableQuery RETURNS CHARACTER
  ( INPUT pcQuery AS CHARACTER ) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getRegistry) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getRegistry Procedure 
FUNCTION getRegistry RETURNS CHARACTER
    ( pcSection AS CHARACTER
    , pcKey     AS CHARACTER
    )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getSchemaHolder) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getSchemaHolder Procedure 
FUNCTION getSchemaHolder RETURNS CHARACTER
  ( INPUT pcDataSrNameOrDbName AS CHARACTER
  ) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getStackSize) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getStackSize Procedure 
FUNCTION getStackSize RETURNS INTEGER() FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getTableDesc) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getTableDesc Procedure 
FUNCTION getTableDesc RETURNS CHARACTER
  ( INPUT pcDatabase AS CHARACTER
  , INPUT pcTable    AS CHARACTER
  )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getTableLabel) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getTableLabel Procedure 
FUNCTION getTableLabel RETURNS CHARACTER
  ( INPUT  pcDatabase AS CHARACTER
  , INPUT  pcTable    AS CHARACTER
  )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getTableList) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getTableList Procedure 
FUNCTION getTableList RETURNS CHARACTER
  ( INPUT  pcDatabaseFilter AS CHARACTER
  , INPUT  pcTableFilter    AS CHARACTER
  )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getUserName) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getUserName Procedure 
FUNCTION getUserName RETURNS CHARACTER
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getWidgetUnderMouse) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getWidgetUnderMouse Procedure 
FUNCTION getWidgetUnderMouse RETURNS HANDLE
  ( phFrame AS HANDLE )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getWorkFolder) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getWorkFolder Procedure 
FUNCTION getWorkFolder RETURNS CHARACTER
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getXmlNodeName) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD getXmlNodeName Procedure 
FUNCTION getXmlNodeName RETURNS CHARACTER
  ( pcFieldName AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isBrowseChanged) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD isBrowseChanged Procedure 
FUNCTION isBrowseChanged RETURNS LOGICAL
  ( INPUT phBrowse AS HANDLE )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isDataServer) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD isDataServer Procedure 
FUNCTION isDataServer RETURNS LOGICAL
  ( INPUT pcDataSrNameOrDbName AS CHARACTER
  ) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isDefaultFontsChanged) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD isDefaultFontsChanged Procedure 
FUNCTION isDefaultFontsChanged RETURNS LOGICAL
  ( /* parameter-definitions */ )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isFileLocked) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD isFileLocked Procedure 
FUNCTION isFileLocked RETURNS LOGICAL
  ( pcFileName AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isMouseOver) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD isMouseOver Procedure 
FUNCTION isMouseOver RETURNS LOGICAL
  ( phWidget AS HANDLE )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isTableFilterUsed) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD isTableFilterUsed Procedure 
FUNCTION isTableFilterUsed RETURNS LOGICAL
  ( INPUT TABLE ttTableFilter )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isValidCodePage) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD isValidCodePage Procedure 
FUNCTION isValidCodePage RETURNS LOGICAL
  (pcCodepage AS CHARACTER) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isWidgetChanged) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD isWidgetChanged Procedure 
FUNCTION isWidgetChanged RETURNS LOGICAL
  ( INPUT phWidget AS HANDLE )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-readFile) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD readFile Procedure 
FUNCTION readFile RETURNS LONGCHAR
  (pcFilename AS CHARACTER) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-removeConnection) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD removeConnection Procedure 
FUNCTION removeConnection RETURNS LOGICAL
  ( pcDatabase AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-resolveOsVars) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD resolveOsVars Procedure 
FUNCTION resolveOsVars RETURNS CHARACTER
  ( pcString AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-resolveSequence) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD resolveSequence Procedure 
FUNCTION resolveSequence RETURNS CHARACTER
  ( pcString AS CHARACTER )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setColor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD setColor Procedure 
FUNCTION setColor RETURNS INTEGER
  ( pcName  AS CHARACTER 
  , piColor AS INTEGER)  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setColumnWidthList) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD setColumnWidthList Procedure 
FUNCTION setColumnWidthList RETURNS LOGICAL
  ( INPUT phBrowse    AS HANDLE
  , INPUT pcWidthList AS CHARACTER) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setLinkInfo) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD setLinkInfo Procedure 
FUNCTION setLinkInfo RETURNS LOGICAL
  ( INPUT pcFieldName AS CHARACTER
  , INPUT pcValue     AS CHARACTER
  ) FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setRegistry) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION-FORWARD setRegistry Procedure 
FUNCTION setRegistry RETURNS CHARACTER
  ( pcSection AS CHARACTER
  , pcKey     AS CHARACTER
  , pcValue   AS CHARACTER
  )  FORWARD.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF


/* *********************** Procedure Settings ************************ */

&ANALYZE-SUSPEND _PROCEDURE-SETTINGS
/* Settings for THIS-PROCEDURE
   Type: Procedure
   Allow: 
   Frames: 0
   Add Fields to: Neither
   Other Settings: CODE-ONLY COMPILE
 */
&ANALYZE-RESUME _END-PROCEDURE-SETTINGS

/* *************************  Create Window  ************************** */

&ANALYZE-SUSPEND _CREATE-WINDOW
/* DESIGN Window definition (used by the UIB) 
  CREATE WINDOW Procedure ASSIGN
         HEIGHT             = 24.91
         WIDTH              = 53.4.
/* END WINDOW DEFINITION */
                                                                        */
&ANALYZE-RESUME

 


&ANALYZE-SUSPEND _UIB-CODE-BLOCK _CUSTOM _MAIN-BLOCK Procedure 


/* ***************************  Main Block  *************************** */

/* terminate it.                                                        */
ON CLOSE OF THIS-PROCEDURE
DO:
  DEFINE VARIABLE cEnvironment AS CHARACTER NO-UNDO.
  cEnvironment = SUBSTITUTE('DataDigger-&1', getUserName() ).

  UNLOAD 'DataDiggerHelp' NO-ERROR.
  UNLOAD 'DataDigger'     NO-ERROR.
  UNLOAD cEnvironment     NO-ERROR.
END. /* CLOSE OF THIS-PROCEDURE  */

/* Subscribe to setUsage event to track user behaviour */
SUBSCRIBE TO "setUsage" ANYWHERE.


/* Caching settings must be set from within UI.
 * Since the library might be started from DataDigger.p
 * we cannot rely on the registry being loaded yet
 */
glCacheTableDefs = FALSE .
glCacheFieldDefs = FALSE.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME


/* **********************  Internal Procedures  *********************** */

&IF DEFINED(EXCLUDE-applyChoose) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE applyChoose Procedure 
PROCEDURE applyChoose :
/* Apply the choose event to a dynamically created widget
   */
  DEFINE INPUT  PARAMETER pihWidget AS HANDLE NO-UNDO.

  IF VALID-HANDLE(pihWidget) THEN
  DO:
    PUBLISH "debugInfo" (3, SUBSTITUTE("Apply CHOOSE to &1 &2", pihWidget:TYPE, pihWidget:NAME)).
    APPLY 'choose' TO pihWidget.
  END.

END PROCEDURE. /* applyChoose */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-applyEvent) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE applyEvent Procedure 
PROCEDURE applyEvent :
/* Apply an event to a dynamically created widget
  */
  DEFINE INPUT  PARAMETER pihWidget AS HANDLE NO-UNDO.
  DEFINE INPUT  PARAMETER pcEvent   AS CHARACTER   NO-UNDO.

  IF VALID-HANDLE(pihWidget) THEN
  DO:
    PUBLISH "debugInfo" (3, SUBSTITUTE("Apply &1 to &2 &3", CAPS(pcEvent), pihWidget:TYPE, pihWidget:NAME)).
    APPLY pcEvent TO pihWidget.
  END.

END PROCEDURE. /* applyEvent */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-checkBackupFolder) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE checkBackupFolder Procedure 
PROCEDURE checkBackupFolder :
/* If backup is on, create a folder for it
  */
  DEFINE OUTPUT PARAMETER plFolderOk AS LOGICAL NO-UNDO.
  DEFINE VARIABLE cFolder      AS CHARACTER   NO-UNDO.

  IF LOGICAL(getRegistry("DataDigger:Backup","BackupOnCreate"))
  OR LOGICAL(getRegistry("DataDigger:Backup","BackupOnDelete"))
  OR LOGICAL(getRegistry("DataDigger:Backup","BackupOnDelete")) THEN
  DO:
    RUN getDumpFileName
      ( INPUT 'dump' /* action */
      , INPUT ''     /* database */
      , INPUT ''     /* table */
      , INPUT ''     /* extension */
      , INPUT getRegistry("DataDigger:Backup", "BackupDir") /* template */
      , OUTPUT cFolder
      ).
    RUN createFolder(cFolder).

    /* Now check if folder is actually created */
    FILE-INFO:FILE-NAME = cFolder.
    plFolderOk = (FILE-INFO:FULL-PATHNAME <> ?).

    IF NOT plFolderOk THEN
    DO:
      RUN showHelp('CannotCreateBackupFolder', cFolder).
      setRegistry("DataDigger:Backup","BackupOnCreate", "NO").
      setRegistry("DataDigger:Backup","BackupOnUpdate", "NO").
      setRegistry("DataDigger:Backup","BackupOnDelete", "NO").
    END.
  END.
  ELSE
    plFolderOk = TRUE.

END PROCEDURE. /* checkBackupFolder */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-checkDir) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE checkDir Procedure 
PROCEDURE checkDir :
/* Check if a folder exists, is accessible etc
  */
  DEFINE INPUT  PARAMETER pcFileName AS CHARACTER   NO-UNDO.
  DEFINE OUTPUT PARAMETER pcError    AS CHARACTER   NO-UNDO.

  DEFINE VARIABLE cDumpDir     AS CHARACTER NO-UNDO.
  DEFINE VARIABLE cDirToCreate AS CHARACTER NO-UNDO.
  DEFINE VARIABLE iDir         AS INTEGER   NO-UNDO.

  PUBLISH "debugInfo" (3, SUBSTITUTE("Check &1", pcFileName)).

  /* If no path is given, use startup folder */
  cDumpDir = SUBSTRING(pcFileName, 1, R-INDEX(pcFileName,"\")).
  IF cDumpDir = '' THEN cDumpDir = '.'.

  /* We cannot use the program dir itself */
  FILE-INFO:FILE-NAME = cDumpDir.
  IF TRIM(FILE-INFO:FULL-PATHNAME,'\/') = TRIM(getProgramDir(),"/\") THEN
  DO:
    pcError = getRegistry('DataDigger:Help', 'ExportToProgramdir:message').
    RETURN.
  END.

  PUBLISH "debugInfo" (3, SUBSTITUTE("Dir = &1", cDumpDir)).

  /* Ask to overwrite if it already exists */
  FILE-INFO:FILE-NAME = pcFileName.
  IF FILE-INFO:FULL-PATHNAME <> ? THEN
  DO:
    PUBLISH "debugInfo" (3, SUBSTITUTE("Already exists as &1 (&2)", FILE-INFO:FULL-PATHNAME, FILE-INFO:FILE-TYPE)).

    IF FILE-INFO:FILE-TYPE MATCHES '*F*' THEN
    DO:
      RUN showHelp('OverwriteDumpFile', pcFileName).
      IF getRegistry('DataDigger:Help', 'OverwriteDumpFile:answer') <> '1' THEN
      DO:
        /* Do not remember the answer "No" for this question, otherwise it will be
         * confusing the next time the user encounters this situation
         */
        setRegistry('DataDigger:Help', 'OverwriteDumpFile:answer',?).
        pcError = 'Aborted by user.'.
        RETURN.
      END.

      /* Write access to this file? */
      IF NOT FILE-INFO:FILE-TYPE MATCHES '*W*' THEN
      DO:
        pcError = SUBSTITUTE('Cannot overwrite output file "&1"', pcFileName).
        RETURN.
      END.
    END.

    /* If a dir already exists with the same name as the output file, we cannot create it */
    IF FILE-INFO:FILE-TYPE MATCHES '*D*' THEN
    DO:
      pcError = SUBSTITUTE('A directory named "&1" exists; cannot create a file with the same name.', pcFileName).
      RETURN.
    END.
  END.

  /* Check dir */
  FILE-INFO:FILE-NAME = cDumpDir.
  IF cDumpDir <> "" /* Don't complain about not using a dir */
    AND FILE-INFO:FULL-PATHNAME = ? THEN
  DO:
    RUN showHelp('CreateDumpDir', cDumpDir).
    IF getRegistry('DataDigger:Help', 'CreateDumpDir:answer') <> '1' THEN
    DO:
      pcError = 'Aborted by user.'.
      RETURN.
    END.
  END.

  /* Try to create path + file. Progress will not raise an error if it already exists */
  cDirToCreate = ENTRY(1,cDumpDir,'\').
  DO iDir = 2 TO NUM-ENTRIES(cDumpDir,'\').

    /* In which dir do we want to create a subdir? */
    IF iDir = 2 THEN
      FILE-INFO:FILE-NAME = cDirToCreate + '\'.
    ELSE
      FILE-INFO:FILE-NAME = cDirToCreate.

    /* Does it even exist? */
    IF FILE-INFO:FULL-PATHNAME = ? THEN
    DO:
      pcError = SUBSTITUTE('Directory "&1" does not exist.', cDirToCreate).
      PUBLISH "debugInfo" (3, SUBSTITUTE("Error: &1", pcError)).
      RETURN.
    END.

    /* Check if the dir is writable */
    IF FILE-INFO:FILE-TYPE MATCHES '*X*'  /* Happens on CD-ROM drives */
      OR (        FILE-INFO:FILE-TYPE MATCHES '*D*'
          AND NOT FILE-INFO:FILE-TYPE MATCHES '*W*' ) THEN
    DO:
      pcError = SUBSTITUTE('No write-access to directory: "&1"', cDirToCreate).
      PUBLISH "debugInfo" (3, SUBSTITUTE("Error: &1", pcError)).
      RETURN.
    END.

    /* Seems to exist and to be writable. */
    cDirToCreate = cDirToCreate + '\' + ENTRY(iDir,cDumpDir,'\').

    /* If a file already exists with the same name, we cannot create a dir */
    FILE-INFO:FILE-NAME = cDirToCreate.
    IF FILE-INFO:FILE-TYPE MATCHES '*F*' THEN
    DO:
      pcError = SUBSTITUTE('A file named "&1" exists; cannot create a dir with the same name.', cDirToCreate).
      PUBLISH "debugInfo" (3, SUBSTITUTE("Error: &1", pcError)).
      RETURN.
    END.

    /* Create the dir. Creating an existing dir gives no error */
    OS-CREATE-DIR value(cDirToCreate).
    IF OS-ERROR <> 0 THEN
    DO:
      pcError = getOsErrorDesc(OS-ERROR).
      PUBLISH "debugInfo" (3, SUBSTITUTE("Error: &1", pcError)).
      RETURN.
    END. /* error */

  END. /* iDir */

END PROCEDURE. /* checkDir */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-clearColorCache) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clearColorCache Procedure 
PROCEDURE clearColorCache :
/* Clear the registry cache
  */
  PUBLISH "debugInfo" (3, SUBSTITUTE("Clearing color cache")).
  EMPTY TEMP-TABLE ttColor.

END PROCEDURE. /* clearColorCache */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-clearDiskCache) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clearDiskCache Procedure 
PROCEDURE clearDiskCache :
/* Clear the cache files on disk
  */
  DEFINE VARIABLE cFile AS CHARACTER NO-UNDO EXTENT 3.

  PUBLISH "debugInfo" (3, SUBSTITUTE("Clearing disk cache")).

  FILE-INFORMATION:FILE-NAME = getWorkFolder() + "cache".
  IF FILE-INFORMATION:FULL-PATHNAME = ? THEN RETURN.

  INPUT FROM OS-DIR(FILE-INFORMATION:FULL-PATHNAME).
  REPEAT:
    IMPORT cFile.
    IF cFile[1] MATCHES "*.xml" THEN OS-DELETE VALUE( cFile[2]).
  END.
  INPUT CLOSE.

END PROCEDURE. /* clearDiskCache */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-clearFontCache) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clearFontCache Procedure 
PROCEDURE clearFontCache :
/* Clear the font cache
  */
  PUBLISH "debugInfo" (3, SUBSTITUTE("Clearing font cache")).
  EMPTY TEMP-TABLE ttFont.

END PROCEDURE. /* clearFontCache */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-clearMemoryCache) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clearMemoryCache Procedure 
PROCEDURE clearMemoryCache :
/* Clear the memory cache
  */
  PUBLISH "debugInfo" (3, SUBSTITUTE("Clearing memory cache")).
  EMPTY TEMP-TABLE ttFieldCache.

END PROCEDURE. /* clearMemoryCache */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-clearRegistryCache) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE clearRegistryCache Procedure 
PROCEDURE clearRegistryCache :
/* Clear the registry cache
  */
  PUBLISH "debugInfo" (3, SUBSTITUTE("Clearing registry cache")).
  EMPTY TEMP-TABLE ttConfig.

END PROCEDURE. /* clearRegistryCache */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-collectQueryInfo) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE collectQueryInfo Procedure 
PROCEDURE collectQueryInfo :
/* Fill the query temp-table
  */
  DEFINE INPUT  PARAMETER pcDatabase     AS CHARACTER   NO-UNDO.
  DEFINE INPUT  PARAMETER pcTable        AS CHARACTER   NO-UNDO.

  DEFINE VARIABLE iMaxQueryHistory AS INTEGER NO-UNDO.
  DEFINE VARIABLE iQueryNr         AS INTEGER NO-UNDO.
  DEFINE VARIABLE iLoop            AS INTEGER NO-UNDO.
  DEFINE VARIABLE cSetting         AS CHARACTER NO-UNDO.

  DEFINE BUFFER bQuery FOR ttQuery.
  {&timerStart}

  /* Delete all known queries in memory of this table */
  FOR EACH bQuery
    WHERE bQuery.cDatabase = pcDatabase
      AND bQuery.cTable    = pcTable:
    DELETE bQuery.
  END.

  iMaxQueryHistory = INTEGER(getRegistry("DataDigger", "MaxQueryHistory" )).
  IF iMaxQueryHistory = 0 THEN RETURN. /* no query history wanted */

  /* If it is not defined use default setting */
  IF iMaxQueryHistory = ? THEN iMaxQueryHistory = 10.

  collectQueries:
  DO iLoop = 1 TO iMaxQueryHistory:
    cSetting = getRegistry( SUBSTITUTE("DB:&1", pcDatabase)
                          , SUBSTITUTE('&1:query:&2', pcTable, iLoop )).

    IF cSetting = '<Empty>' THEN NEXT collectQueries.

    IF cSetting <> ? THEN
    DO:
      CREATE bQuery.
      ASSIGN
        iQueryNr         = iQueryNr + 1
        bQuery.cDatabase = pcDatabase
        bQuery.cTable    = pcTable
        bQuery.iQueryNr  = iQueryNr
        bQuery.cQueryTxt = cSetting.
    END.
    ELSE
      LEAVE collectQueries.

  END. /* 1 .. MaxQueryHistory */
  {&timerStop}
END PROCEDURE. /* collectQueryInfo */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-correctFilterList) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE correctFilterList Procedure 
PROCEDURE correctFilterList :
/* Move negative entries from positive list to negative
  */
  DEFINE INPUT-OUTPUT PARAMETER pcPositive AS CHARACTER   NO-UNDO.
  DEFINE INPUT-OUTPUT PARAMETER pcNegative AS CHARACTER   NO-UNDO.

  DEFINE VARIABLE iWord AS INTEGER NO-UNDO.

  /* Strip entries that start with a ! */
  IF INDEX(pcPositive,"!") > 0 THEN
  DO:
    DO iWord = 1 TO NUM-ENTRIES(pcPositive):
      IF ENTRY(iWord,pcPositive) BEGINS "!" THEN
      DO:
        /* Add this word to the negative-list */
        pcNegative = TRIM(pcNegative + ',' + TRIM(ENTRY(iWord,pcPositive),'!'),',').

        /* And wipe it from the positive-list */
        ENTRY(iWord,pcPositive) = ''.
      END.
    END.

    /* Remove empty elements */
    pcPositive = REPLACE(pcPositive,',,',',').
    pcPositive = TRIM(pcPositive,',').
  END.

END PROCEDURE. /* correctFilterList */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-createFolder) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE createFolder Procedure 
PROCEDURE createFolder :
/* Create a folder structure
  */
  DEFINE INPUT PARAMETER pcFolder AS CHARACTER NO-UNDO.

  DEFINE VARIABLE iElement AS INTEGER     NO-UNDO.
  DEFINE VARIABLE cPath    AS CHARACTER   NO-UNDO.

  /* c:\temp\somefolder\subfolder\ */
  DO iElement = 1 TO NUM-ENTRIES(pcFolder,'\'):
    cPath = SUBSTITUTE('&1\&2', cPath, ENTRY(iElement,pcFolder,'\')).
    cPath = LEFT-TRIM(cPath,'\').

    IF iElement > 1 THEN OS-CREATE-DIR VALUE(cPath).
  END.

END PROCEDURE. /* createFolder */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-dumpRecord) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE dumpRecord Procedure 
PROCEDURE dumpRecord :
/* Dump the record(s) to disk
  */
  DEFINE INPUT  PARAMETER pcAction   AS CHARACTER   NO-UNDO.
  DEFINE INPUT  PARAMETER phSource   AS HANDLE      NO-UNDO.
  DEFINE OUTPUT PARAMETER plContinue AS LOGICAL     NO-UNDO.

  DEFINE VARIABLE hExportTT       AS HANDLE    NO-UNDO.
  DEFINE VARIABLE hExportTtBuffer AS HANDLE    NO-UNDO.
  DEFINE VARIABLE hBuffer         AS HANDLE    NO-UNDO.
  DEFINE VARIABLE cFileName       AS CHARACTER NO-UNDO.
  DEFINE VARIABLE cError          AS CHARACTER NO-UNDO.
  DEFINE VARIABLE cMessage        AS CHARACTER NO-UNDO.
  DEFINE VARIABLE iRow            AS INTEGER   NO-UNDO.
  DEFINE VARIABLE lDefaultDump    AS LOGICAL   NO-UNDO.

  IF NOT VALID-HANDLE(phSource) THEN RETURN.

  /* Protect against wrong input */
  IF LOOKUP(pcAction,'Dump,Create,Update,Delete') = 0 THEN
  DO:
    MESSAGE 'Unknown action' pcAction VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    RETURN.
  END.

  /* Determine appropriate buffer and populate an intermediate tt
   * with the data to export
   */
  CASE phSource:TYPE:
    WHEN 'buffer' THEN
    DO:
      hBuffer = phSource.

      /* Create temptable-handle... */
      CREATE TEMP-TABLE hExportTt.
      hExportTt:CREATE-LIKE(SUBSTITUTE("&1.&2", hBuffer:DBNAME, hBuffer:TABLE)).

      /* Prepare the TempTable... */
      hExportTt:TEMP-TABLE-PREPARE(SUBSTITUTE("&1", hBuffer:TABLE)).
      hExportTtBuffer = hExportTt:DEFAULT-BUFFER-HANDLE.
      hExportTtBuffer:BUFFER-CREATE().
      hExportTtBuffer:BUFFER-COPY(hBuffer).
    END.

    WHEN 'browse' THEN
    DO:
      hBuffer = phSource:QUERY:GET-BUFFER-HANDLE(1).

      /* Create temptable-handle... */
      CREATE TEMP-TABLE hExportTt.
      hExportTt:CREATE-LIKE(SUBSTITUTE("&1.&2", hBuffer:DBNAME, hBuffer:TABLE)).

      /* Prepare the TempTable... */
      hExportTt:TEMP-TABLE-PREPARE(SUBSTITUTE("&1", hBuffer:TABLE)).
      hExportTtBuffer = hExportTt:DEFAULT-BUFFER-HANDLE.

      /* Copy the records */
      DO iRow = 1 TO phSource:NUM-SELECTED-ROWS:
        phSource:FETCH-SELECTED-ROW(iRow).
        hExportTtBuffer:BUFFER-CREATE().
        hExportTtBuffer:BUFFER-COPY(hBuffer).
      END.
    END.

    OTHERWISE RETURN.
  END CASE.

  /* Do we need to dump at all?
   * If the setting=NO or if no setting at all, then don't do any checks
   */
  IF pcAction <> 'Dump'
    AND (   getRegistry('DataDigger:Backup','BackupOn' + pcAction) = ?
        OR logical(getRegistry('DataDigger:Backup','BackupOn' + pcAction)) = NO
        ) THEN
  DO:
    ASSIGN plContinue = YES.
    RETURN.
  END.

  /* Determine the default name to save to */
  RUN getDumpFileName
    ( INPUT pcAction        /* Dump | Create | Update | Delete */
    , INPUT hBuffer:DBNAME
    , INPUT hBuffer:TABLE
    , INPUT "XML"
    , INPUT ""
    , OUTPUT cFileName
    ).

  RUN checkDir(INPUT cFileName, OUTPUT cError).
  IF cError <> "" THEN
  DO:
    MESSAGE cError VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    RETURN.
  END.

  /* Fix XML Node Names for fields in the tt */
  RUN setXmlNodeNames(INPUT hExportTt:DEFAULT-BUFFER-HANDLE).

  /* See if the user has specified his own dump program
   */
  plContinue = ?. /* To see if it ran or not */
  PUBLISH "customDump"
      ( INPUT pcAction
      , INPUT hBuffer:DBNAME
      , INPUT hBuffer:TABLE
      , INPUT hExportTt
      , INPUT cFileName
      , OUTPUT cMessage
      , OUTPUT lDefaultDump
      , OUTPUT plContinue
      ).

  IF plContinue <> ? THEN
  DO:
    IF cMessage <> "" THEN MESSAGE cMessage VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
    IF NOT lDefaultDump OR NOT plContinue THEN RETURN.
  END.

  plContinue = hExportTT:WRITE-XML
    ( 'file'        /* TargetType     */
    , cFileName     /* File           */
    , YES           /* Formatted      */
    , ?             /* Encoding       */
    , ?             /* SchemaLocation */
    , NO            /* WriteSchema    */
    , NO            /* MinSchema      */
    ).

  DELETE OBJECT hExportTt.
END PROCEDURE. /* dumpRecord */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-dynamicDump) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE dynamicDump Procedure 
PROCEDURE dynamicDump :
/* Dump the data to a file that is similar to those of Progress self.
  */
  DEFINE INPUT PARAMETER pihBrowse AS HANDLE      NO-UNDO.
  DEFINE INPUT PARAMETER picFile   AS CHARACTER   NO-UNDO.

  DEFINE VARIABLE cTimeStamp AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE hBuffer    AS HANDLE      NO-UNDO EXTENT 5.
  DEFINE VARIABLE hColumn    AS HANDLE      NO-UNDO.
  DEFINE VARIABLE hField     AS HANDLE      NO-UNDO.
  DEFINE VARIABLE hQuery     AS HANDLE      NO-UNDO.
  DEFINE VARIABLE iBack      AS INTEGER     NO-UNDO.
  DEFINE VARIABLE iBuffer    AS INTEGER     NO-UNDO.
  DEFINE VARIABLE iColumn    AS INTEGER     NO-UNDO.
  DEFINE VARIABLE iExtent    AS INTEGER     NO-UNDO.
  DEFINE VARIABLE iRecords   AS INTEGER     NO-UNDO.
  DEFINE VARIABLE iTrailer   AS INTEGER     NO-UNDO.
  DEFINE VARIABLE lFirst     AS LOGICAL     NO-UNDO.

  hQuery = pihBrowse:QUERY.

  /* Accept max 5 buffers for a query */
  DO iBuffer = 1 TO min(5, hQuery:NUM-BUFFERS):
    hBuffer[iBuffer] = hQuery:GET-BUFFER-HANDLE(iBuffer).
  END.

  ASSIGN
    iRecords   = 0
    cTimeStamp = STRING(YEAR( TODAY),"9999":u) + "/":u
              + string(MONTH(TODAY),"99":u  ) + "/":u
              + string(DAY(  TODAY),"99":u  ) + "-":u
              + string(TIME,"HH:MM:SS":u).

  hQuery:GET-FIRST.

  /* Open outputfile */
  OUTPUT to value(picFile) no-echo no-map.
  EXPORT ?.
  iBack = seek(output) - 1.
  SEEK OUTPUT TO 0.

  REPEAT WHILE NOT hQuery:QUERY-OFF-END
  ON STOP UNDO, LEAVE:

    ASSIGN
      iRecords = iRecords + 1
      lFirst   = TRUE
      .

    PROCESS EVENTS.

    browseColumn:
    DO iColumn = 1 TO pihBrowse:NUM-COLUMNS:

      /* Grab the handle */
      hColumn = pihBrowse:GET-BROWSE-COLUMN(iColumn).

      /* Skip invisible columns */
      IF NOT hColumn:VISIBLE THEN NEXT browseColumn.

      /* Find the buffer the column belongs to */
      SearchLoop:
      DO iBuffer = 1 TO 5:
        ASSIGN hField = hBuffer[iBuffer]:BUFFER-FIELD(hColumn:NAME) NO-ERROR.
        IF ERROR-STATUS:ERROR = FALSE
          AND hField <> ? THEN
          LEAVE SearchLoop.
      END.

      /* If no column found, something weird happened */
      IF hField = ? THEN NEXT browseColumn.

      IF hField:DATA-TYPE = "recid":u THEN NEXT browseColumn.

      IF lFirst THEN
        lFirst = FALSE.
      ELSE
      DO:
        SEEK OUTPUT TO seek(output) - iBack.
        PUT CONTROL ' ':u.
      END.

      IF hField:EXTENT > 1 THEN
      DO iExtent = 1 TO hField:EXTENT:
        IF iExtent > 1 THEN
        DO:
          SEEK OUTPUT TO SEEK(OUTPUT) - iBack.
          PUT CONTROL ' ':u.
        END.

        EXPORT hField:BUFFER-VALUE(iExtent).
      END.
      ELSE
        EXPORT hField:BUFFER-VALUE.
    END.

    hQuery:GET-NEXT().
  END.

  /* Add a checksum and nr of records at the end of the file.
  */
  PUT UNFORMATTED ".":u SKIP.
  iTrailer = SEEK(OUTPUT).

  PUT UNFORMATTED
        "PSC":u
    SKIP "filename=":u hBuffer[1]:TABLE
    SKIP "records=":u  STRING(iRecords,"9999999999999":u)
    SKIP "ldbname=":u  hBuffer[1]:DBNAME
    SKIP "timestamp=":u cTimeStamp
    SKIP "numformat=":u ASC(SESSION:NUMERIC-SEPARATOR) ",":u ASC(SESSION:NUMERIC-DECIMAL-POINT)
    SKIP "dateformat=":u SESSION:DATE-FORMAT "-":u SESSION:YEAR-OFFSET
    SKIP "map=NO-MAP":u
    SKIP "cpstream=":u SESSION:CPSTREAM
    SKIP ".":u
    SKIP STRING(iTrailer,"9999999999":u)
    SKIP.

  OUTPUT CLOSE.

END PROCEDURE. /* dynamicDump */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-flushRegistry) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE flushRegistry Procedure 
PROCEDURE flushRegistry :
/* Flush all dirty registry settings to disk
*/
  {&timerStart}

  IF CAN-FIND(FIRST ttConfig WHERE ttConfig.lUser = TRUE AND ttConfig.lDirty = TRUE) THEN
    RUN saveConfigFileSorted.

  {&timerStop}
END PROCEDURE. /* flushRegistry */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getColumnSort) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getColumnSort Procedure 
PROCEDURE getColumnSort :
/* Return the column nr the browse is sorted on
  */
  DEFINE INPUT  PARAMETER phBrowse    AS HANDLE      NO-UNDO.
  DEFINE OUTPUT PARAMETER pcColumn    AS CHARACTER   NO-UNDO.
  DEFINE OUTPUT PARAMETER plAscending AS LOGICAL     NO-UNDO.

  DEFINE VARIABLE hColumn AS HANDLE      NO-UNDO.
  DEFINE VARIABLE iColumn AS INTEGER     NO-UNDO.

  {&timerStart}

  #BrowseColumns:
  DO iColumn = 1 TO phBrowse:NUM-COLUMNS:
    hColumn = phBrowse:GET-BROWSE-COLUMN(iColumn).
    IF hColumn:SORT-ASCENDING <> ? THEN
    DO:
      ASSIGN
        pcColumn    = hColumn:NAME
        plAscending = hColumn:SORT-ASCENDING
        .
      LEAVE #BrowseColumns.
    END.
  END.

  IF pcColumn = '' THEN
    ASSIGN
      pcColumn    = phBrowse:GET-BROWSE-COLUMN(1):name
      plAscending = TRUE.

  PUBLISH "debugInfo" (3, SUBSTITUTE("Sorting &1 on &2", STRING(plAscending,"up/down"), pcColumn)).

  {&timerStop}

END PROCEDURE. /* getColumnSort */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getDumpFileName) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getDumpFileName Procedure 
PROCEDURE getDumpFileName :
/* Return a file name based on a template
  */
  DEFINE INPUT  PARAMETER pcAction    AS CHARACTER   NO-UNDO.
  DEFINE INPUT  PARAMETER pcDatabase  AS CHARACTER   NO-UNDO.
  DEFINE INPUT  PARAMETER pcTable     AS CHARACTER   NO-UNDO.
  DEFINE INPUT  PARAMETER pcExtension AS CHARACTER   NO-UNDO.
  DEFINE INPUT  PARAMETER pcTemplate  AS CHARACTER   NO-UNDO.
  DEFINE OUTPUT PARAMETER pcFileName  AS CHARACTER   NO-UNDO.

  DEFINE VARIABLE cLastDir      AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cDayOfWeek    AS CHARACTER   NO-UNDO EXTENT 7 INITIAL ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].
  DEFINE VARIABLE cDumpName     AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cDumpDir      AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cBackupDir    AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE hBuffer       AS HANDLE      NO-UNDO.
  DEFINE VARIABLE cUserId       AS CHARACTER   NO-UNDO.

  /* Checks */
  IF LOOKUP(pcAction, "Dump,Create,Update,Delete") = 0 THEN
  DO:
    MESSAGE 'Unknown action' pcAction VIEW-AS ALERT-BOX.
    RETURN.
  END.

  /* If not provided, find the template from the settings,
   * depending on the action we want to perform.
   */
  IF pcTemplate = ? OR pcTemplate = "" THEN
  DO:
    IF pcAction = 'Dump' THEN
      pcFileName = "<DUMPDIR>" + getRegistry("DumpAndLoad", "DumpFileTemplate").
    ELSE
      pcFileName = "<BACKUPDIR>" + getRegistry("DataDigger:Backup", "BackupFileTemplate").
  END.
  ELSE
    pcFileName = pcTemplate.

  IF pcFileName = ? THEN pcFileName = "".

  PUBLISH "debugInfo" (3, SUBSTITUTE("Dump to: &1", pcFileName)).

  /* Dump dir / backup dir / last-used dir from settings */
  cDumpDir = RIGHT-TRIM(getRegistry("DumpAndLoad", "DumpDir"),'/\') + '\'.
  IF cDumpDir = ? OR cDumpDir = '' THEN cDumpDir = "<WORKDIR>dump\".

  cBackupDir  = RIGHT-TRIM(getRegistry("DataDigger:Backup", "BackupDir"),'/\') + '\'.
  IF cBackupDir = ? OR cBackupDir = '' THEN cBackupDir = "<WORKDIR>backup\".

  cLastDir = RIGHT-TRIM(getRegistry("DumpAndLoad", "DumpLastFileName"),'/\').
  cLastDir = SUBSTRING(cLastDir,1,R-INDEX(cLastDir,"\")).
  IF cLastDir = ? THEN cLastDir = "<WORKDIR>dump".
  cLastDir = RIGHT-TRIM(cLastDir,'\').

  /* Find _file for the dump-name */
  CREATE BUFFER hBuffer FOR TABLE SUBSTITUTE('&1._file', pcDatabase) NO-ERROR.
  IF VALID-HANDLE(hBuffer) THEN
  DO:
    hBuffer:FIND-UNIQUE(SUBSTITUTE('where _file-name = &1 and _File._File-Number < 32768', QUOTER(pcTable)),NO-LOCK).
    IF hBuffer:AVAILABLE THEN
      cDumpName = hBuffer::_dump-name.
    ELSE
      cDumpName = pcTable.
  END.
  ELSE
    cDumpName = pcTable.
  IF cDumpName = ? THEN cDumpName = pcTable.

  /* If you have no db connected, userid gives back unknown value
   * which misbehaves in a replace statement */
  cUserId = USERID(LDBNAME(1)).
  IF cUserId = ? THEN cUserId = ''.

  PUBLISH "debugInfo" (3, SUBSTITUTE("DumpDir  : &1", cDumpDir)).
  PUBLISH "debugInfo" (3, SUBSTITUTE("BackupDir: &1", cBackupDir)).
  PUBLISH "debugInfo" (3, SUBSTITUTE("LastDir  : &1", cLastDir)).
  PUBLISH "debugInfo" (3, SUBSTITUTE("DumpName : &1", cDumpName)).

  /* Now resolve all tags */
  pcFileName = REPLACE(pcFileName,"<DUMPDIR>"  , cDumpDir                    ).
  pcFileName = REPLACE(pcFileName,"<BACKUPDIR>", cBackupDir                  ).
  pcFileName = REPLACE(pcFileName,"<LASTDIR>"  , cLastDir                    ).
  pcFileName = REPLACE(pcFileName,"<PROGDIR>"  , getWorkFolder()             ).
  pcFileName = REPLACE(pcFileName,"<WORKDIR>"  , getWorkFolder()             ).

  pcFileName = REPLACE(pcFileName,"<ACTION>"   , pcAction                    ).
  pcFileName = REPLACE(pcFileName,"<USERID>"   , cUserId                     ).
  pcFileName = REPLACE(pcFileName,"<DB>"       , pcDatabase                  ).
  pcFileName = REPLACE(pcFileName,"<TABLE>"    , pcTable                     ).
  pcFileName = REPLACE(pcFileName,"<DUMPNAME>" , cDumpName                   ).
  pcFileName = REPLACE(pcFileName,"<EXT>"      , pcExtension                 ).

  pcFileName = REPLACE(pcFileName,"<TIMESTAMP>", "<YEAR><MONTH><DAY>.<HH><MM><SS>" ).
  pcFileName = REPLACE(pcFileName,"<DATE>"     , "<YEAR>-<MONTH>-<DAY>"      ).
  pcFileName = REPLACE(pcFileName,"<TIME>"     , "<HH>:<MM>:<SS>"            ).
  pcFileName = REPLACE(pcFileName,"<WEEKDAY>"  , STRING(WEEKDAY(TODAY))      ).
  pcFileName = REPLACE(pcFileName,"<DAYNAME>"  , cDayOfWeek[WEEKDAY(today)]  ).

  pcFileName = REPLACE(pcFileName,"<YEAR>"     , STRING(YEAR (TODAY),"9999") ).
  pcFileName = REPLACE(pcFileName,"<MONTH>"    , STRING(MONTH(TODAY),  "99") ).
  pcFileName = REPLACE(pcFileName,"<DAY>"      , STRING(DAY  (TODAY),  "99") ).
  pcFileName = REPLACE(pcFileName,"<HH>"       , ENTRY(1,STRING(TIME,"HH:MM:SS"),":" ) ).
  pcFileName = REPLACE(pcFileName,"<MM>"       , ENTRY(2,STRING(TIME,"HH:MM:SS"),":" ) ).
  pcFileName = REPLACE(pcFileName,"<SS>"       , ENTRY(3,STRING(TIME,"HH:MM:SS"),":" ) ).

  /* Get rid of annoying slashes */
  pcFileName = TRIM(pcFileName,'/\').

  /* Get rid of double slashes (except at the beginning for UNC paths) */
  pcFileName = SUBSTRING(pcFileName,1,1) + REPLACE(SUBSTRING(pcFileName,2),'\\','\').

  /* Sequences */
  pcFileName = resolveSequence(pcFileName).

  /* OS-vars */
  pcFileName = resolveOsVars(pcFileName).

  /* Make lower */
  pcFileName = LC(pcFileName).
  PUBLISH "debugInfo" (3, SUBSTITUTE("Dump to: &1", pcFileName)).

END PROCEDURE. /* getDumpFileName */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getFields) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getFields Procedure 
PROCEDURE getFields :
/* Fill the fields temp-table
  */
  DEFINE INPUT  PARAMETER pcDatabase  AS CHARACTER   NO-UNDO.
  DEFINE INPUT  PARAMETER pcTableName AS CHARACTER   NO-UNDO.
  DEFINE OUTPUT PARAMETER DATASET FOR dsFields.

  DEFINE VARIABLE cCacheFile         AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cPrimIndexFields   AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cQuery             AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cSelectedFields    AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cUniqueIndexFields AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cSDBName           AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE hBufferField       AS HANDLE      NO-UNDO.
  DEFINE VARIABLE hBufferFile        AS HANDLE      NO-UNDO.
  DEFINE VARIABLE hQuery             AS HANDLE      NO-UNDO.
  DEFINE VARIABLE iFieldExtent       AS INTEGER     NO-UNDO.
  DEFINE VARIABLE iFieldOrder        AS INTEGER     NO-UNDO.
  DEFINE VARIABLE lDataField         AS LOGICAL     NO-UNDO.
  DEFINE VARIABLE iDataOrder         AS INTEGER     NO-UNDO.
  DEFINE VARIABLE i                  AS INTEGER     NO-UNDO.

  DEFINE BUFFER bTable       FOR ttTable.
  DEFINE BUFFER bField       FOR ttField.
  DEFINE BUFFER bColumn      FOR ttColumn.
  DEFINE BUFFER bFieldCache  FOR ttFieldCache.
  DEFINE BUFFER bColumnCache FOR ttColumnCache.
  DEFINE BUFFER bTableFilter FOR ttTableFilter.

  {&timerStart}

  /* Clean up first */
  EMPTY TEMP-TABLE bField.
  EMPTY TEMP-TABLE bColumn.

  /* For dataservers, use the schema name [dataserver] */
  ASSIGN cSDBName = SDBNAME(pcDatabase).

  /* Return if no db connected */
  IF NUM-DBS = 0 THEN RETURN.

  /* caching */
  IF glCacheFieldDefs THEN
  DO:
    /* Find the table. Should exist. */
    FIND bTable WHERE bTable.cDatabase = pcDatabase AND bTable.cTableName = pcTableName NO-ERROR.
    IF NOT AVAILABLE bTable THEN RETURN.

    /* Verify whether the CRC is still the same. If not, kill the cache */
    PUBLISH "DD:Timer" ("start", 'getFields - step 1: verify CRC').
    CREATE BUFFER hBufferFile FOR TABLE cSDBName + "._File".

    hBufferFile:FIND-UNIQUE(SUBSTITUTE('where _file-name = &1 and _File._File-Number < 32768', QUOTER(pcTableName)),NO-LOCK).
    IF hBufferFile::_crc <> bTable.cCrc THEN
    DO:
      /* It seems that it is not possible to refresh the schema cache of the running
       * session. You just have to restart your session.
       */
      PUBLISH "debugInfo" (1, SUBSTITUTE("File CRC changed, kill cache and build new")).
      FOR EACH bFieldCache WHERE bFieldCache.cTableCacheId = bTable.cCacheId:
        DELETE bFieldCache.
      END.
      FOR EACH bColumnCache WHERE bColumnCache.cTableCacheId = bTable.cCacheId:
        DELETE bColumnCache.
      END.

      /* Get a fresh list of tables */
      RUN getTables(INPUT TABLE bTableFilter, OUTPUT TABLE bTable).

      /* Find the table back. Should exist. */
      FIND bTable WHERE bTable.cDatabase = pcDatabase AND bTable.cTableName = pcTableName NO-ERROR.
      IF NOT AVAILABLE bTable THEN RETURN.
    END.
    PUBLISH "DD:Timer" ("stop", 'getFields - step 1: verify CRC').

    /* First look in the memory-cache */
    IF CAN-FIND(FIRST bFieldCache WHERE bFieldCache.cTableCacheId = bTable.cCacheId) THEN
    DO:
      PUBLISH "DD:Timer" ("start", 'getFields - step 2: check memory cache').
      PUBLISH "debugInfo" (3, SUBSTITUTE("Get from memory-cache")).

      FOR EACH bFieldCache WHERE bFieldCache.cTableCacheId = bTable.cCacheId:
        CREATE bField.
        BUFFER-COPY bFieldCache TO bField.
      END.

      FOR EACH bColumnCache WHERE bColumnCache.cTableCacheId = bTable.cCacheId:
        CREATE bColumn.
        BUFFER-COPY bColumnCache TO bColumn.
      END.

      /* Update with settings from registry */
      RUN updateFields(INPUT pcDatabase, INPUT pcTableName, INPUT-OUTPUT TABLE bField).

      PUBLISH "DD:Timer" ("stop", 'getFields - step 2: check memory cache').
      RETURN.
    END.

    /* See if disk cache exists */
    cCacheFile = SUBSTITUTE('&1cache\&2.xml', getWorkFolder(), bTable.cCacheId).
    PUBLISH "debugInfo" (2, SUBSTITUTE("Cachefile: &1", cCacheFile)).

    IF SEARCH(cCacheFile) <> ? THEN
    DO:
      PUBLISH "DD:Timer" ("start", 'getFields - step 3: get from disk cache').
      PUBLISH "debugInfo" (3, SUBSTITUTE("Get from disk cache")).
      DATASET dsFields:READ-XML("file", cCacheFile, "empty", ?, ?, ?, ?).

      /* Add to memory cache, so the next time it's even faster */
      IF TEMP-TABLE bField:HAS-RECORDS THEN
      DO:
        PUBLISH "debugInfo" (3, SUBSTITUTE("Add to first-level cache")).
        FOR EACH bField {&TABLE-SCAN}:
          CREATE bFieldCache.
          BUFFER-COPY bField TO bFieldCache.
        END.

        FOR EACH bColumn {&TABLE-SCAN}:
          CREATE bColumnCache.
          BUFFER-COPY bColumn TO bColumnCache.
        END.
      END.

      /* Update with settings from registry */
      RUN updateFields(INPUT pcDatabase, INPUT pcTableName, INPUT-OUTPUT TABLE bField).

      PUBLISH "DD:Timer" ("stop", 'getFields - step 3: get from disk cache').
      RETURN.
    END.

    PUBLISH "debugInfo" (3, SUBSTITUTE("Not found in any cache, build tables...")).
  END.

  /*
   * If we get here, the table either cannot be found in the cache
   * or caching is disabled. Either way, fill the tt with fields
   */
  PUBLISH "DD:Timer" ("start", 'getFields - step 4: build cache').
  FIND bTable WHERE bTable.cDatabase = pcDatabase AND bTable.cTableName = pcTableName NO-ERROR.
  IF NOT AVAILABLE bTable THEN RETURN.

  CREATE BUFFER hBufferFile  FOR TABLE cSDBName + "._File".
  CREATE BUFFER hBufferField FOR TABLE cSDBName + "._Field".

  CREATE QUERY hQuery.
  hQuery:SET-BUFFERS(hBufferFile,hBufferField).

  cQuery = SUBSTITUTE("FOR EACH &1._File  WHERE &1._file._file-name = '&2' AND _File._File-Number < 32768 NO-LOCK, " +
                      "    EACH &1._Field OF &1._File NO-LOCK BY _ORDER"
                    , cSDBName
                    , pcTableName
                    ).

  hQuery:QUERY-PREPARE(cQuery).
  hQuery:QUERY-OPEN().
  hQuery:GET-FIRST().

  /* Get list of fields in primary index. */
  cPrimIndexFields = getIndexFields(cSDBName, pcTableName, "P").

  /* Get list of fields in all unique indexes. */
  cUniqueIndexFields = getIndexFields(cSDBName, pcTableName, "U").

  /* Get list of all previously selected fields */
  cSelectedFields = getRegistry(SUBSTITUTE("DB:&1",pcDatabase), SUBSTITUTE("&1:Fields",pcTableName)).

  /* If none selected, set mask to 'all' */
  IF cSelectedFields = ? THEN cSelectedFields = '*'.

  REPEAT WHILE NOT hQuery:QUERY-OFF-END:

    CREATE bField.
    ASSIGN
      iFieldOrder          = iFieldOrder + 1
      bField.cTableCacheId = bTable.cCacheId
      bField.cDatabase     = pcDatabase
      bField.cTablename    = pcTableName
      bField.cFieldName    = hBufferField:BUFFER-FIELD('_field-name'):BUFFER-VALUE

      bField.lShow         = CAN-DO(cSelectedFields, hBufferField:BUFFER-FIELD('_field-name'):BUFFER-VALUE)
      bField.iOrder        = iFieldOrder
      bField.iOrderOrg     = iFieldOrder

      bField.cFullName     = hBufferField:BUFFER-FIELD('_field-name'):BUFFER-VALUE
      bField.cDataType     = hBufferField:BUFFER-FIELD('_data-type'):BUFFER-VALUE
      bField.cInitial      = hBufferField:BUFFER-FIELD('_initial'):BUFFER-VALUE
      bField.cFormat       = hBufferField:BUFFER-FIELD('_format'):BUFFER-VALUE
      bField.cFormatOrg    = hBufferField:BUFFER-FIELD('_format'):BUFFER-VALUE
      bField.iWidth        = hBufferField:BUFFER-FIELD('_width'):BUFFER-VALUE
      bField.cLabel        = hBufferField:BUFFER-FIELD('_label'):BUFFER-VALUE
      bField.lPrimary      = CAN-DO(cPrimIndexFields, bField.cFieldName)
      bField.iExtent       = hBufferField:BUFFER-FIELD('_Extent'):BUFFER-VALUE
      bField.lMandatory    = hBufferField:BUFFER-FIELD('_mandatory'):BUFFER-VALUE
      bField.lUniqueIdx    = CAN-DO(cUniqueIndexFields,bField.cFieldName)

      /* New fields as per v19 */
      bField.cColLabel     = hBufferField:BUFFER-FIELD('_Col-label'):BUFFER-VALUE
      bField.iDecimals     = hBufferField:BUFFER-FIELD('_Decimals'):BUFFER-VALUE
      bField.iFieldRpos    = hBufferField:BUFFER-FIELD('_Field-rpos'):BUFFER-VALUE
      bField.cValExp       = hBufferField:BUFFER-FIELD('_ValExp'):BUFFER-VALUE
      bField.cValMsg       = hBufferField:BUFFER-FIELD('_ValMsg'):BUFFER-VALUE
      bField.cHelp         = hBufferField:BUFFER-FIELD('_Help'):BUFFER-VALUE
      bField.cDesc         = hBufferField:BUFFER-FIELD('_Desc'):BUFFER-VALUE
      bField.cViewAs       = hBufferField:BUFFER-FIELD('_View-as'):BUFFER-VALUE
      .
    ASSIGN
      bField.cXmlNodeName  = getXmlNodeName(bField.cFieldName)
      .

    /* Make a list of fields on table level */
    bTable.cFields = bTable.cFields + "," + bField.cFieldName.

    /* Some types should not be shown like CLOB BLOB and RAW */
    lDataField = (LOOKUP(bField.cDataType, 'clob,blob,raw') = 0).

    /* Create TT records for each column to show, except for CLOB / BLOB / RAW */
    IF lDataField = TRUE THEN
    DO iFieldExtent = (IF bField.iExtent = 0 THEN 0 ELSE 1) TO bField.iExtent:

      iDataOrder = iDataOrder + 1.

      CREATE bColumn.
      ASSIGN
        bColumn.cTableCacheId = bTable.cCacheId
        bColumn.cDatabase     = bField.cDatabase
        bColumn.cTableName    = bField.cTablename
        bColumn.cFieldName    = bField.cFieldName
        bColumn.iExtent       = iFieldExtent
        bColumn.cFullName     = bField.cFieldName + (IF iFieldExtent > 0 THEN SUBSTITUTE("[&1]", iFieldExtent) ELSE "")
        bColumn.iColumnNr     = iDataOrder
        bColumn.iOrder        = bField.iOrder
        bColumn.cLabel        = bField.cLabel
        .
      PUBLISH "debugInfo"(3,SUBSTITUTE("Field &1 created", bColumn.cFullName)).
    END. /* For each extent nr */

    hQuery:GET-NEXT().
  END.
  hQuery:QUERY-CLOSE().

  DELETE OBJECT hQuery.
  DELETE OBJECT hBufferField.
  DELETE OBJECT hBufferFile.

  /* Fieldlist */
  bTable.cFields = SUBSTRING(bTable.cFields,2).

  /* Add columns for recid/rowid */
  DO i = 1 TO 2:

    CREATE bField.
    ASSIGN
      iFieldOrder          = iFieldOrder + 1
      bField.cTableCacheId = bTable.cCacheId
      bField.cDatabase     = pcDatabase
      bField.cTablename    = pcTableName
      bField.cFieldName    = ENTRY(i,"RECID,ROWID")
      bField.lShow         = FALSE
      bField.iOrder        = iFieldOrder
      bField.iOrderOrg     = iFieldOrder
      bField.cFieldName    = bField.cFieldName
      bField.cFullName     = bField.cFieldName
      bField.cDataType     = 'character'
      bField.cInitial      = ''
      bField.cFormat       = ENTRY(i,"X(14),X(30)")
      bField.cFormatOrg    = bField.cFormat
      bField.cLabel        = bField.cFieldName
      bField.lPrimary      = NO
      bField.iExtent       = 0
      .

    iDataOrder = iDataOrder + 1.
    CREATE bColumn.
    ASSIGN
      bColumn.cTableCacheId = bField.cTableCacheId
      bColumn.cDatabase     = bField.cDatabase
      bColumn.cTableName    = bField.cTablename
      bColumn.cFieldName    = bField.cFieldName
      bColumn.iExtent       = 0
      bColumn.cFullName     = bField.cFieldName
      bColumn.iColumnNr     = iDataOrder
      bColumn.iOrder        = bField.iOrder
      bColumn.cLabel        = bField.cLabel
      .
  END.
  PUBLISH "DD:Timer" ("stop", 'getFields - step 4: build cache').

  /* Update the cache */
  IF glCacheFieldDefs THEN
  DO:
    /* Add to disk cache */
    PUBLISH "DD:Timer" ("start", 'getFields - step 5: save to disk').
    PUBLISH "debugInfo" (3, SUBSTITUTE("Add to second-level cache.")).
    DATASET dsFields:WRITE-XML( "file", cCacheFile, YES, ?, ?, NO, NO).

    /* Add to memory cache */
    PUBLISH "debugInfo" (3, SUBSTITUTE("Add to first-level cache.")).
    FOR EACH bField {&TABLE-SCAN}:
      CREATE bFieldCache.
      BUFFER-COPY bField TO bFieldCache.
    END.

    FOR EACH bColumn {&TABLE-SCAN}:
      CREATE bColumnCache.
      BUFFER-COPY bColumn TO bColumnCache.
    END.
    PUBLISH "DD:Timer" ("stop", 'getFields - step 5: save to disk').
  END.

  /* Update fields with settings from registry */
  RUN updateFields(INPUT pcDatabase, INPUT pcTableName, INPUT-OUTPUT TABLE bField).

  {&timerStop}

END PROCEDURE. /* getFields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getMouseXY) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getMouseXY Procedure 
PROCEDURE getMouseXY :
/* Get the position of the mouse relative to the frame
  */
  DEFINE INPUT  PARAMETER phFrame  AS HANDLE  NO-UNDO.
  DEFINE OUTPUT PARAMETER piMouseX AS INTEGER NO-UNDO.
  DEFINE OUTPUT PARAMETER piMouseY AS INTEGER NO-UNDO.

  DEFINE VARIABLE lp   AS MEMPTR NO-UNDO.
  DEFINE VARIABLE iRet AS INT64  NO-UNDO.

  SET-SIZE( LP ) = 16.
  RUN GetCursorPos(INPUT lp, OUTPUT iRet).

  /* Get the location of the mouse relative to the frame */
  RUN ScreenToClient ( INPUT phFrame:HWND, INPUT lp ).

  piMouseX = GET-LONG( lp, 1 ).
  piMouseY = GET-LONG( lp, 5 ).
  SET-SIZE( LP ) = 0.

  PUBLISH "debugInfo" (3, SUBSTITUTE("Mouse X/Y = &1 / &2", piMouseX, piMouseY)).

END PROCEDURE. /* getMouseXY */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getQueryTable) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getQueryTable Procedure 
PROCEDURE getQueryTable :
/* Get the ttQuery table
  * Note: This procedure just returns the table, no further logic needed.
  */
  DEFINE OUTPUT PARAMETER table FOR ttQuery.

END PROCEDURE. /* getQueryTable */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getRegistryTable) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getRegistryTable Procedure 
PROCEDURE getRegistryTable :
/* Return complete registry tt
  */
  DEFINE OUTPUT PARAMETER TABLE FOR ttConfig.

END PROCEDURE. /* getRegistryTable */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getTables) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getTables Procedure 
PROCEDURE getTables :
/* Fill ttTable with all currently connected databases.
  */
  DEFINE INPUT PARAMETER TABLE FOR ttTableFilter.
  DEFINE OUTPUT PARAMETER TABLE FOR ttTable.

  DEFINE VARIABLE cCacheFile       AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE hDbBuffer        AS HANDLE     NO-UNDO.
  DEFINE VARIABLE hDbStatusBuffer  AS HANDLE     NO-UNDO.
  DEFINE VARIABLE hQuery           AS HANDLE     NO-UNDO.
  DEFINE VARIABLE hDbQuery         AS HANDLE     NO-UNDO.
  DEFINE VARIABLE iDatabase        AS INTEGER    NO-UNDO.
  DEFINE VARIABLE cCacheTimeStamp  AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE cCacheDir        AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE cSchemaCacheFile AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE cOneCacheFile    AS CHARACTER  NO-UNDO.
  
  DEFINE BUFFER bTable    FOR ttTable.
  DEFINE BUFFER bTableXml FOR ttTableXml.
  
  {&timerStart}
  
  /* Dataserver support can be for:
   *
   * V9:   "PROGRESS,AS400,ORACLE,MSS,ODBC"
   * V10:  "PROGRESS,ORACLE,MSS,ODBC"        (from V10 no native support for AS400)
   * V11:  "PROGRESS,ORACLE,MSS,ODBC"
   * V12:  "PROGRESS,ORACLE,MSS"             (from V12 no ODBC support anymore)
   *
   */
  EMPTY TEMP-TABLE ttTable.
  CREATE WIDGET-POOL "metaInfo".
  CREATE QUERY hQuery IN WIDGET-POOL "metaInfo".

  #Database:
  DO iDatabase = 1 TO NUM-DBS:
    IF DBTYPE(iDatabase) <> "PROGRESS" THEN NEXT #Database.

    /* Compose name of the cache file. Use date/time of last schema change in the name */
    IF glCacheTableDefs THEN
    DO:
      CREATE BUFFER hDbStatusBuffer FOR TABLE LDBNAME(iDatabase) + "._DbStatus" IN WIDGET-POOL "metaInfo".
      hDbStatusBuffer:FIND-FIRST("",NO-LOCK).
      
      ASSIGN 
        cCacheTimeStamp = REPLACE(REPLACE(hDbStatusBuffer::_dbstatus-cachestamp," ","_"),":","")
        cCacheFile = SUBSTITUTE("&1cache\db.&2.&3.xml", getWorkFolder(), LDBNAME(iDatabase), cCacheTimeStamp ).
        
      DELETE OBJECT hDbStatusBuffer.
    END.

    /* If caching enabled and there is a cache file, read it */
    IF glCacheTableDefs AND SEARCH(cCacheFile) <> ? THEN
    DO:
      PUBLISH "debugInfo" (3, SUBSTITUTE("Get table list from cache file &1", cCacheFile)).
      TEMP-TABLE ttTable:READ-XML("file", cCacheFile, "APPEND", ?, ?, ?, ?).
      
      cCacheDir = SUBSTITUTE( "&1cache", getWorkFolder() ).
      INPUT FROM OS-DIR(cCacheDir).
      #ReadSchemaCache:
      REPEAT:
        IMPORT cSchemaCacheFile.
        
        IF cSchemaCacheFile BEGINS SUBSTITUTE("db.&1;", LDBNAME(iDatabase))
         AND ENTRY(NUM-ENTRIES(cSchemaCacheFile, ".") - 1, cSchemaCacheFile, ".") = ENTRY (NUM-ENTRIES(cCacheFile, ".") - 1, cCacheFile, ".")  /* Check timestamp */
        THEN
        DO:
          cOneCacheFile = SUBSTITUTE( "&1\&2", cCacheDir, cSchemaCacheFile).
          TEMP-TABLE ttTable:READ-XML("file", cOneCacheFile, "APPEND", ?, ?, ?, ?).
        END.
      END.
      INPUT CLOSE.
    END.

    /* Otherwise build it */
    ELSE
    DO:
      CREATE ALIAS 'dictdb' FOR DATABASE VALUE(LDBNAME(iDatabase)).
      RUN getSchema.p(INPUT TABLE ttTable BY-REFERENCE).

      /* Save cache file for next time */
      IF glCacheTableDefs THEN
      DO:
        /* Move the tables of the current db to a separate tt so we can dump it. */
        EMPTY TEMP-TABLE ttTableXml.

        CREATE QUERY hDbQuery IN WIDGET-POOL "metaInfo".
        CREATE BUFFER hDbBuffer FOR TABLE LDBNAME(iDatabase) + "._Db" IN WIDGET-POOL "metaInfo".

        hDbQuery:SET-BUFFERS(hDbBuffer).
        hDbQuery:QUERY-PREPARE("FOR EACH _Db NO-LOCK WHERE _Db._Db-local = TRUE").
        hDbQuery:QUERY-OPEN().

        #DB:
        REPEAT:
          hDbQuery:GET-NEXT().
          IF hDbQuery:QUERY-OFF-END THEN LEAVE #DB.

          FOR EACH bTable
            WHERE bTable.cDatabase = (IF hDbBuffer::_Db-slave THEN hDbBuffer::_Db-name ELSE LDBNAME(iDatabase)):
            CREATE bTableXml.
            BUFFER-COPY bTable TO bTableXml.
          END.
        END.

        hDbQuery:QUERY-CLOSE().
        DELETE OBJECT hDbQuery.
        DELETE OBJECT hDbBuffer.

        TEMP-TABLE ttTableXml:WRITE-XML("file", cCacheFile, YES, ?, ?, NO, NO).
        EMPTY TEMP-TABLE ttTableXml.
        
        /* Support Dataservers */
        FOR EACH bTable 
          WHERE bTable.cSchemaHolder = LDBNAME(iDatabase)
          BREAK BY bTable.cDatabase
                BY bTable.cTableName:
                  
          IF FIRST-OF(bTable.cDatabase) THEN
          DO:
            cCacheFile  = SUBSTITUTE( "&1cache\db.&2;&3.&4.xml"
                                    , getWorkFolder()
                                    , LDBNAME(iDatabase)
                                    , bTable.cDatabase
                                    , cCacheTimeStamp
                                    ).
            EMPTY TEMP-TABLE bTableXml.
          END.            

          CREATE bTableXml.
          BUFFER-COPY bTable TO bTableXml.
            
          IF LAST-OF(bTable.cDatabase) THEN
          DO:
            TEMP-TABLE bTableXml:WRITE-XML("file", cCacheFile, YES, ?, ?, NO, NO).
            EMPTY TEMP-TABLE bTableXml.
          END. /* IF LAST-OF */
        END. /* FOR EACH bTable */
      END. /* IF glCacheTableDefs THEN */
    END. /* tt empty */
  END. /* 1 to num-dbs */

  DELETE WIDGET-POOL "metaInfo".

  /* Apply filter to collection of tables */
  RUN getTablesFiltered(INPUT TABLE ttTableFilter, OUTPUT TABLE ttTable).

  /* Get table properties from the INI file */
  RUN getTableStats(INPUT-OUTPUT TABLE ttTable).

  {&timerStop}

END PROCEDURE. /* getTables */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getTablesFiltered) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getTablesFiltered Procedure 
PROCEDURE getTablesFiltered :
/* Determine whether tables in the ttTable are visible given a user defined filter
  */
  {&timerStart}
  DEFINE INPUT PARAMETER TABLE FOR ttTableFilter.
  DEFINE OUTPUT PARAMETER TABLE FOR ttTable.

  DEFINE VARIABLE cSearchFld  AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cThisField  AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE iSearch     AS INTEGER     NO-UNDO.
  DEFINE VARIABLE iField      AS INTEGER     NO-UNDO.
  DEFINE VARIABLE lRejected   AS LOGICAL     NO-UNDO.
  DEFINE VARIABLE lFieldFound AS LOGICAL     NO-UNDO.
  DEFINE VARIABLE lNormal     AS LOGICAL     NO-UNDO.
  DEFINE VARIABLE lSchema     AS LOGICAL     NO-UNDO.
  DEFINE VARIABLE lVst        AS LOGICAL     NO-UNDO.
  DEFINE VARIABLE lSql        AS LOGICAL     NO-UNDO.
  DEFINE VARIABLE lOther      AS LOGICAL     NO-UNDO.
  DEFINE VARIABLE lHidden     AS LOGICAL     NO-UNDO.
  DEFINE VARIABLE lFrozen     AS LOGICAL     NO-UNDO.
  DEFINE VARIABLE cNameShow   AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cNameHide   AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cFieldShow  AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cFieldHide  AS CHARACTER   NO-UNDO.

  /* This table **SHOULD** exist and have exactly 1 record */
  FIND ttTableFilter NO-ERROR.
  IF NOT AVAILABLE ttTableFilter THEN RETURN.

  ASSIGN
    lNormal    = ttTableFilter.lShowNormal
    lSchema    = ttTableFilter.lShowSchema
    lVst       = ttTableFilter.lShowVst
    lSql       = ttTableFilter.lShowSql
    lOther     = ttTableFilter.lShowOther
    lHidden    = ttTableFilter.lShowHidden
    lFrozen    = ttTableFilter.lShowFrozen
    cNameShow  = ttTableFilter.cTableNameShow
    cNameHide  = ttTableFilter.cTableNameHide
    cFieldShow = ttTableFilter.cTableFieldShow
    cFieldHide = ttTableFilter.cTableFieldHide
    .

  /* Reset the filters to sane values if needed */
  IF cNameShow  = ''  OR cNameShow  = ? THEN cNameShow  = '*'.
  IF cNameHide  = '*' OR cNameHide  = ? THEN cNameHide  = '' .
  IF cFieldShow = '*' OR cFieldShow = ? THEN cFieldShow = ''.
  IF cFieldHide = '*' OR cFieldHide = ? THEN cFieldHide = ''.

  /* Move elements starting with "!" from pos-list to neg-list */
  RUN correctFilterList(INPUT-OUTPUT cNameShow, INPUT-OUTPUT cNameHide).
  RUN correctFilterList(INPUT-OUTPUT cFieldShow, INPUT-OUTPUT cFieldHide).

  #Table:
  FOR EACH ttTable {&TABLE-SCAN}:
    /* Init table to false until proven otherwise */
    ASSIGN ttTable.lShowInList = FALSE.

    /* Check against filter-to-hide */
    IF CAN-DO(cNameHide,ttTable.cTableName) THEN NEXT #Table.

    /* Check against filter-to-show */
    IF NOT CAN-DO(cNameShow,ttTable.cTableName) THEN NEXT #Table.

    /* User tables          : _file-number > 0   AND _file-number < 32000
     * Schema tables        : _file-number > -80 AND _file-number < 0
     * Virtual system tables: _file-number < -16384
     * SQL catalog tables   : _file-name BEGINS "_sys"
     */
    IF NOT lNormal AND ttTable.cCategory = 'Normal' THEN NEXT #Table.
    IF NOT lSchema AND ttTable.cCategory = 'Schema' THEN NEXT #Table.
    IF NOT lVst    AND ttTable.cCategory = 'VST'    THEN NEXT #Table.
    IF NOT lSql    AND ttTable.cCategory = 'SQL'    THEN NEXT #Table.
    IF NOT lOther  AND ttTable.cCategory = 'Other'  THEN NEXT #Table.

    /* Handling for Hidden and Frozen apply only to user tables otherwise it will be too confusing
     * because Schema, VST and SQL tables are all by default hidden and frozen.
     */
    IF NOT lHidden AND ttTable.cCategory = 'Application' AND ttTable.lHidden = TRUE THEN NEXT #Table.
    IF NOT lFrozen AND ttTable.cCategory = 'Application' AND ttTable.lFrozen = TRUE THEN NEXT #Table.

    /* Fields that must be in the list */
    DO iSearch = 1 TO NUM-ENTRIES(cFieldShow):
      cSearchFld = ENTRY(iSearch,cFieldShow).

      /* If no wildcards used, we can simply CAN-DO */
      IF INDEX(cSearchFld,"*") = 0 THEN
      DO:
        IF NOT CAN-DO(ttTable.cFields, cSearchFld) THEN NEXT #Table.
      END.
      ELSE
      DO:
        lFieldFound = FALSE.

        #Field:
        DO iField = 1 TO NUM-ENTRIES(ttTable.cFields):
          cThisField = ENTRY(iField,ttTable.cFields).
          IF CAN-DO(cSearchFld,cThisField) THEN
          DO:
            lFieldFound = TRUE.
            LEAVE #Field.
          END.
        END.
        IF NOT lFieldFound THEN NEXT #Table.
      END.
    END.

    /* Fields that may not be in the list */
    DO iSearch = 1 TO NUM-ENTRIES(cFieldHide):
      cSearchFld = ENTRY(iSearch,cFieldHide).

      /* If no wildcards used, we can simply CAN-DO */
      IF INDEX(cSearchFld,"*") = 0 THEN
      DO:
        IF CAN-DO(ttTable.cFields, cSearchFld) THEN NEXT #Table.
      END.
      ELSE
      DO:
        lRejected = FALSE.
        #Field:
        DO iField = 1 TO NUM-ENTRIES(ttTable.cFields):
          cThisField = ENTRY(iField,ttTable.cFields).
          IF CAN-DO(cSearchFld,cThisField) THEN
          DO:
            lRejected = TRUE.
            LEAVE #Field.
          END.
        END. /* do iField */
        IF lRejected THEN NEXT #Table.
      END. /* else */
    END. /* do iSearch */

    /* If we get here, we should add the table */
    ASSIGN ttTable.lShowInList = TRUE.
  END. /* for each ttTable */

  {&timerStop}
END PROCEDURE. /* getTablesFiltered */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getTableStats) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE getTableStats Procedure 
PROCEDURE getTableStats :
/* Get table statistics from the INI file
  */
  DEFINE INPUT-OUTPUT PARAMETER table FOR ttTable.

  DEFINE VARIABLE cIniFile    AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cLine       AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cSection    AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cDatabase   AS CHARACTER   NO-UNDO.

  /* Read the ini file as plain text and parse the lines.
   *
   * The normal way would be to do a FOR-EACH on the _file table and
   * retrieve the information needed. But if you have a large database
   * (or a lot of databases), this becomes VERY slow. Searching the
   * other way around by parsing the INI is a lot faster.
   */
  {&timerStart}

  cIniFile = SUBSTITUTE('&1DataDigger-&2.ini', getWorkFolder(), getUserName() ).
  IF SEARCH(cIniFile) = ? THEN RETURN.

  INPUT FROM VALUE(cIniFile).

  #ReadLine:
  REPEAT:
    /* Sometimes lines get screwed up and are waaaay too long
     * for the import statement. So just ignore those.
     */
    IMPORT UNFORMATTED cLine NO-ERROR.
    IF ERROR-STATUS:ERROR THEN NEXT #ReadLine.

    /* Find DB sections */
    IF cLine MATCHES '[DB:*]' THEN
    DO:
      cSection = TRIM(cLine,'[]').
      cDatabase = ENTRY(2,cSection,":").
    END.

    /* Only process lines of database-sections */
    IF NOT cSection BEGINS "DB:" THEN NEXT #ReadLine.

    /* Only process setting lines */
    IF NOT cLine MATCHES '*:*=*' THEN NEXT #ReadLine.

    /* Filter out some settings */
    IF cLine MATCHES "*:QueriesServed=*" THEN
    DO:
      FIND FIRST ttTable
        WHERE ttTable.cDatabase = cDatabase
          AND ttTable.cTableName = ENTRY(1,cLine,':') NO-ERROR.

      IF AVAILABLE ttTable THEN
      DO:
        ttTable.iNumQueries = INTEGER(ENTRY(2,cLine,'=')) NO-ERROR.
        IF ttTable.iNumQueries = ? THEN ttTable.iNumQueries = 0.
      END.
    END. /* queriesServed */

    ELSE
    IF cLine MATCHES "*:LastUsed=*" THEN
    DO:
      FIND FIRST ttTable
        WHERE ttTable.cDatabase = cDatabase
          AND ttTable.cTableName = ENTRY(1,cLine,':') NO-ERROR.

      IF AVAILABLE ttTable THEN
        ttTable.tLastUsed = DATETIME(ENTRY(2,cLine,'=')) NO-ERROR.

    END. /* lastUsed */

    ELSE
    IF cLine MATCHES "*:Favourites=*" THEN
    DO:
      FIND FIRST ttTable
        WHERE ttTable.cDatabase = cDatabase
          AND ttTable.cTableName = ENTRY(1,cLine,':') NO-ERROR.

      IF AVAILABLE ttTable THEN
        ttTable.cFavourites = ENTRY(2,cLine,'=') NO-ERROR.

    END. /* favourite */

  END. /* repeat */
  INPUT CLOSE.

  {&timerStop}

END PROCEDURE. /* getTableStats */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-initTableFilter) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE initTableFilter Procedure 
PROCEDURE initTableFilter :
/* Set table filter values back to their initial values
  */
  DEFINE INPUT-OUTPUT PARAMETER TABLE FOR ttTableFilter.

  EMPTY TEMP-TABLE ttTableFilter.
  CREATE ttTableFilter.

  /* Set visibility of schema tables */
  ttTableFilter.lShowSchema = LOGICAL(getRegistry('DataDigger','ShowHiddenTables')).
  IF ttTableFilter.lShowSchema = ? THEN ttTableFilter.lShowSchema = NO.

END PROCEDURE. /* initTableFilter */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-loadSettings) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE loadSettings Procedure 
PROCEDURE loadSettings :
/* Load settings from ini files
*/
  DEFINE VARIABLE lValue AS LOGICAL   NO-UNDO.

  /* Help file is least important, so read that first */
  RUN readConfigFile( SUBSTITUTE("&1DataDiggerHelp.ini", getProgramDir() ), FALSE).

  /* General DD settings (always in program folder) */
  RUN readConfigFile( SUBSTITUTE("&1DataDigger.ini", getProgramDir() ), FALSE).

  /* Per-user settings */
  RUN readConfigFile( SUBSTITUTE("&1DataDigger-&2.ini", getWorkFolder(), getUserName() ), TRUE).

  /* When all ini-files have been read, we can determine whether
   * caching needs to be enabled
   */
  lValue = LOGICAL(getRegistry("DataDigger:Cache","TableDefs")) NO-ERROR.
  IF lValue <> ? THEN ASSIGN glCacheTableDefs = lValue.

END PROCEDURE. /* loadSettings */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-lockWindow) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE lockWindow Procedure 
PROCEDURE lockWindow :
/* Lock / unlock updates that Windows does to windows.
  */
  DEFINE INPUT PARAMETER phWindow AS HANDLE  NO-UNDO.
  DEFINE INPUT PARAMETER plLock   AS LOGICAL NO-UNDO.

  DEFINE VARIABLE iRet AS INTEGER NO-UNDO.
  DEFINE BUFFER ttWindowLock FOR ttWindowLock.

  {&timerStart}
  PUBLISH "debugInfo" (3, SUBSTITUTE("Window &1, lock: &2", phWindow:TITLE, STRING(plLock,"ON/OFF"))).

  IF NOT VALID-HANDLE(phWindow) THEN RETURN.

  /* Find window in our tt of locked windows */
  FIND ttWindowLock WHERE ttWindowLock.hWindow = phWindow NO-ERROR.
  IF NOT AVAILABLE ttWindowLock THEN
  DO:
    /* If we try to unlock a window thats not in the tt, just go back */
    IF NOT plLock THEN RETURN.

    /* Otherwise create a tt record for it */
    CREATE ttWindowLock.
    ttWindowLock.hWindow = phWindow.
  END.

  /* Because commands to lock or unlock may be nested, keep track
   * of the number of locks/unlocks using a semaphore.
   *
   * The order of commands may be:
   * lockWindow(yes). -> actually lock the window
   * lockWindow(yes). -> do nothing
   * lockWindow(yes). -> do nothing
   * lockWindow(no).  -> do nothing
   * lockWindow(no).  -> do nothing
   * lockWindow(yes). -> do nothing
   * lockWindow(no).  -> do nothing
   * lockWindow(no).  -> actually unlock the window
   */
  IF plLock THEN
    ttWindowLock.iLockCounter = ttWindowLock.iLockCounter + 1.
  ELSE
    ttWindowLock.iLockCounter = ttWindowLock.iLockCounter - 1.

  PUBLISH "debugInfo" (3, SUBSTITUTE("Lock counter: &1", ttWindowLock.iLockCounter)).

  /* Now, only lock when the semaphore is increased to 1 */
  IF plLock AND ttWindowLock.iLockCounter = 1 THEN
  DO:
    RUN SendMessageA( phWindow:HWND /* {&window-name}:hwnd */
                    , {&WM_SETREDRAW}
                    , 0
                    , 0
                    , OUTPUT iRet
                    ).
  END.

  /* And only unlock after the last unlock command */
  ELSE IF ttWindowLock.iLockCounter <= 0 THEN
  DO:
    RUN SendMessageA( phWindow:HWND /* {&window-name}:hwnd */
                    , {&WM_SETREDRAW}
                    , 1
                    , 0
                    , OUTPUT iRet
                    ).

    RUN RedrawWindow( phWindow:HWND /* {&window-name}:hwnd */
                    , 0
                    , 0
                    , {&RDW_ALLCHILDREN} + {&RDW_ERASE} + {&RDW_INVALIDATE}
                    , OUTPUT iRet
                    ).

    /* Don't delete, creating records is more expensive than re-use, so just reset */
    ttWindowLock.iLockCounter = 0.
  END.

  {&timerStop}

END PROCEDURE. /* lockWindow */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-readConfigFile) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE readConfigFile Procedure 
PROCEDURE readConfigFile :
/* Read the ini-file and create tt records for it
  */
  DEFINE INPUT PARAMETER pcConfigFile   AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER plUserSettings AS LOGICAL   NO-UNDO.

  DEFINE VARIABLE cFile      AS LONGCHAR    NO-UNDO.
  DEFINE VARIABLE cLine      AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cChunk     AS LONGCHAR    NO-UNDO.
  DEFINE VARIABLE cSection   AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cTrimChars AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE iLine      AS INTEGER     NO-UNDO.

  {&timerStart}
  DEFINE BUFFER bfConfig FOR ttConfig.

  /* Read file in 1 pass to memory */
  IF SEARCH(pcConfigFile) = ? THEN RETURN.
  COPY-LOB FILE pcConfigFile TO cFile NO-CONVERT NO-ERROR.
  IF ERROR-STATUS:ERROR THEN cFile = readFile(pcConfigFile).

  cTrimChars = " " + CHR(1) + "~r". /* space / chr-1 / LF */

  /* Process line by line */
  #LineLoop:
  DO iLine = 1 TO NUM-ENTRIES(cFile,"~n"):

    cChunk = ENTRY(iLine,cFile,"~n").
    cChunk = SUBSTRING(cChunk, 1,20000). /* trim very long lines */
    cLine = TRIM(cChunk, cTrimChars).    /* remove junk */

    /* Section line */
    IF cLine MATCHES "[*]" THEN
    DO:
      cSection = TRIM(cLine,"[]").
      NEXT #LineLoop.
    END.

    /* Ignore weird settings within [DB:xxxx] sections */
    IF cSection BEGINS 'DB:'
      AND NUM-ENTRIES( TRIM(ENTRY(1,cLine,"=")), ':') = 1 THEN NEXT #LineLoop.

    /* Config line */
    FIND bfConfig
      WHERE bfConfig.cSection = cSection
        AND bfConfig.cSetting = TRIM(ENTRY(1,cLine,"=")) NO-ERROR.

    IF NOT AVAILABLE bfConfig THEN
    DO:
      CREATE bfConfig.
      ASSIGN
        bfConfig.cSection = cSection
        bfConfig.cSetting = TRIM(ENTRY(1,cLine,"="))
        .
    END.

    /* Config line /might/ already exist. This can happen if you have
     * the same setting in multiple .ini files.
     */
    ASSIGN
      bfConfig.cValue = TRIM(SUBSTRING(cLine, INDEX(cLine,"=") + 1))
      bfConfig.lUser  = plUserSettings.
  END.

  {&timerStop}
END PROCEDURE. /* readConfigFile */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-resetAnswers) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE resetAnswers Procedure 
PROCEDURE resetAnswers :
/* Reset answers to all 'do not ask again' questions
*/
  {&timerStart}
  DEFINE BUFFER bfConfig FOR ttConfig.

  FOR EACH bfConfig
    WHERE bfConfig.cSection = 'DataDigger:Help'
      AND (bfConfig.cSetting MATCHES '*:hidden' OR bfConfig.cSetting MATCHES '*:answer'):
    setRegistry(bfConfig.cSection, bfConfig.cSetting, ?).
  END. /* for each bfConfig */

  RUN flushRegistry.

  {&timerStop}

END PROCEDURE. /* resetAnswers */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-resizeFilterFields) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE resizeFilterFields Procedure 
PROCEDURE resizeFilterFields :
/* Redraw the browse filter fields
  */
  DEFINE INPUT PARAMETER phLeadButton   AS HANDLE      NO-UNDO.
  DEFINE INPUT PARAMETER pcFilterFields AS CHARACTER   NO-UNDO.
  DEFINE INPUT PARAMETER pcButtons      AS CHARACTER   NO-UNDO.
  DEFINE INPUT PARAMETER phBrowse       AS HANDLE      NO-UNDO.

  DEFINE VARIABLE iField        AS INTEGER NO-UNDO.
  DEFINE VARIABLE iButton       AS INTEGER NO-UNDO.
  DEFINE VARIABLE iCurrentPos   AS INTEGER NO-UNDO.
  DEFINE VARIABLE iRightEdge    AS INTEGER NO-UNDO.
  DEFINE VARIABLE iWidth        AS INTEGER NO-UNDO.
  DEFINE VARIABLE hColumn       AS HANDLE  NO-UNDO.
  DEFINE VARIABLE hButton       AS HANDLE  NO-UNDO.
  DEFINE VARIABLE hFilterField  AS HANDLE  NO-UNDO.
  DEFINE VARIABLE iFilter       AS INTEGER NO-UNDO.

  {&timerStart}

  /* Find out if there has been a change in the browse or in one of
   * its columns. If no changes, save a little time by not redrawing
   */
  IF NOT isBrowseChanged(phBrowse) THEN RETURN.

  /* To prevent drawing error, make all fields small */
  PUBLISH "DD:Timer" ("start", "resizeFilterFields:makeSmall").
  DO iField = 1 TO NUM-ENTRIES(pcFilterFields):
    hFilterField = HANDLE(ENTRY(iField,pcFilterFields)).
    hFilterField:VISIBLE      = NO.
    hFilterField:X            = phBrowse:X.
    hFilterField:Y            = phBrowse:Y - 23.
    hFilterField:WIDTH-PIXELS = 1.
  END.
  PUBLISH "DD:Timer" ("stop", "resizeFilterFields:makeSmall").

  /* Start by setting the buttons at the proper place. Do this right to left */
  PUBLISH "DD:Timer" ("start", "resizeFilterFields:reposition").
  ASSIGN iRightEdge = phBrowse:X + phBrowse:WIDTH-PIXELS.
  DO iButton = NUM-ENTRIES(pcButtons) TO 1 BY -1:
    hButton = HANDLE(ENTRY(iButton,pcButtons)).
    hButton:X = iRightEdge - hButton:WIDTH-PIXELS.
    hButton:Y = phBrowse:Y - 23. /* filter buttons close to the browse */
    iRightEdge = hButton:X + 0. /* A little margin between buttons */
  END.
  PUBLISH "DD:Timer" ("stop", "resizeFilterFields:reposition").

  /* The left side of the left button is the maximum point
   * Fortunately, this value is already in iRightEdge.
   * Resize and reposition the fields from left to right,
   * use the space between browse:x and iRightEdge
   */

  /* Take the left side of the first visible column as a starting point. */
  PUBLISH "DD:Timer" ("start", "resizeFilterFields:firstVisibleColumn").
  firstVisibleColumn:
  DO iField = 1 TO phBrowse:NUM-COLUMNS:
    hColumn = phBrowse:GET-BROWSE-COLUMN(iField):HANDLE.

    IF hColumn:X > 0 AND hColumn:VISIBLE THEN
    DO:
      iCurrentPos = phBrowse:X + hColumn:X.
      LEAVE firstVisibleColumn.
    END.
  END.
  PUBLISH "DD:Timer" ("stop", "resizeFilterFields:firstVisibleColumn").

  PUBLISH "DD:Timer" ("start", "resizeFilterFields:#Field").
  #Field:
  DO iField = 1 TO phBrowse:NUM-COLUMNS:

    hColumn = phBrowse:GET-BROWSE-COLUMN(iField):handle.

    /* Some types cannot have a filter */
    IF hColumn:DATA-TYPE = 'raw' THEN NEXT #Field.

    iFilter = iFilter + 1.
    IF iFilter > NUM-ENTRIES(pcFilterFields) THEN LEAVE #Field.

    /* Determine the handle of the filterfield */
    hFilterField = HANDLE(ENTRY(iFilter, pcFilterFields)).

    /* If the column is hidden, make the filter hidden and go to the next */
    IF NOT hColumn:VISIBLE THEN
    DO:
      hFilterField:VISIBLE = NO.
      NEXT #Field.
    END.

    /* Where *are* we ?? */
    iCurrentPos = phBrowse:X + hColumn:X.

    /* If the columns have been resized, some columns might have fallen off the screen */
    IF hColumn:X < 1 THEN NEXT #Field.

    /* Does it fit on the screen? */
    IF iCurrentPos >= iRightEdge - 5 THEN LEAVE #Field. /* accept some margin */

    /* Where will this field end? And does it fit? */
    iWidth = hColumn:WIDTH-PIXELS + 4.
    IF iCurrentPos + iWidth > iRightEdge THEN iWidth = iRightEdge - iCurrentPos.

    /* Ok, seems to fit */
    hFilterField:X            = iCurrentPos.
    hFilterField:WIDTH-PIXELS = iWidth.
    iCurrentPos               = iCurrentPos + iWidth.
    hFilterField:VISIBLE      = phBrowse:VISIBLE. /* take over the visibility of the browse */
  END.
  PUBLISH "DD:Timer" ("stop", "resizeFilterFields:#Field").

  /* Finally, set the lead button to the utmost left */
  IF VALID-HANDLE(phLeadButton) THEN
    ASSIGN
      phLeadButton:X = phBrowse:X
      phLeadButton:Y = phBrowse:Y - 23.

  {&timerStop}

END PROCEDURE. /* resizeFilterFields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-restoreWindowPos) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE restoreWindowPos Procedure 
PROCEDURE restoreWindowPos :
/* Restore position / size of a window
  */
  DEFINE INPUT PARAMETER phWindow     AS HANDLE      NO-UNDO.
  DEFINE INPUT PARAMETER pcWindowName AS CHARACTER   NO-UNDO.

  DEFINE VARIABLE iValue AS INTEGER     NO-UNDO.

  iValue = INTEGER(getRegistry(pcWindowName, 'Window:x' )).
  IF iValue = ? THEN iValue = INTEGER(getRegistry('DataDigger', 'Window:x' )) + 50.
  ASSIGN phWindow:X = iValue NO-ERROR.

  iValue = INTEGER(getRegistry(pcWindowName, 'Window:y' )).
  IF iValue = ? THEN iValue = INTEGER(getRegistry('DataDigger', 'Window:y' )) + 50.
  IF iValue <> ? THEN ASSIGN phWindow:Y = iValue NO-ERROR.

  iValue = INTEGER(getRegistry(pcWindowName, 'Window:height' )).
  IF iValue = ? OR iValue = 0 THEN iValue = INTEGER(getRegistry('DataDigger', 'Window:height' )) - 100.
  ASSIGN phWindow:HEIGHT-PIXELS = iValue NO-ERROR.

  iValue = INTEGER(getRegistry(pcWindowName, 'Window:width' )).
  IF iValue = ? OR iValue = 0 THEN iValue = INTEGER(getRegistry('DataDigger', 'Window:width' )) - 100.
  ASSIGN phWindow:WIDTH-PIXELS = iValue NO-ERROR.

  /* Force a redraw */
  APPLY 'window-resized' TO phWindow.

END PROCEDURE. /* restoreWindowPos */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-saveConfigFileSorted) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE saveConfigFileSorted Procedure 
PROCEDURE saveConfigFileSorted :
/* Save settings file sorted
  */
  DEFINE VARIABLE cUserConfigFile AS CHARACTER NO-UNDO.
  DEFINE BUFFER bfConfig FOR ttConfig.

  {&timerStart}

  /* Clean up rubbish settings data */
  FOR EACH bfConfig
    WHERE bfConfig.cSetting = '' OR bfConfig.cSetting = ?
       OR bfConfig.cValue   = '' OR bfConfig.cValue   = ?:
    DELETE bfConfig.
  END.

  cUserConfigFile = SUBSTITUTE("&1DataDigger-&2.ini", getWorkFolder(), getUserName() ).
  OUTPUT TO VALUE(cUserConfigFile).

  FOR EACH bfConfig
    WHERE bfConfig.lUser = TRUE
    BREAK BY (bfConfig.cSection BEGINS "DataDigger") DESCENDING
          BY bfConfig.cSection
          BY bfConfig.cSetting:

    bfConfig.lDirty = FALSE.

    IF FIRST-OF(bfConfig.cSection) THEN PUT UNFORMATTED SUBSTITUTE("[&1]",bfConfig.cSection) SKIP.
    PUT UNFORMATTED SUBSTITUTE("&1=&2",bfConfig.cSetting, bfConfig.cValue) SKIP.
    IF LAST-OF(bfConfig.cSection) THEN PUT UNFORMATTED SKIP(1).
  END.

  OUTPUT CLOSE.

  {&timerStop}
END PROCEDURE. /* saveConfigFileSorted */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-saveQuery) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE saveQuery Procedure 
PROCEDURE saveQuery :
/* Save a single query to the INI file.
  */
  DEFINE INPUT  PARAMETER pcDatabase     AS CHARACTER   NO-UNDO.
  DEFINE INPUT  PARAMETER pcTable        AS CHARACTER   NO-UNDO.
  DEFINE INPUT  PARAMETER pcQuery        AS CHARACTER   NO-UNDO.

  DEFINE VARIABLE cQuery AS CHARACTER NO-UNDO.
  DEFINE VARIABLE iNewNr AS INTEGER   NO-UNDO.

  DEFINE BUFFER bQuery FOR ttQuery.

  {&timerStart}

  /* Prepare query for saving in ini-file */
  cQuery = pcQuery.
  cQuery = REPLACE(cQuery,'~n',CHR(1)).
  cQuery = REPLACE(cQuery,{&QUERYSEP},CHR(1)).
  IF cQuery = '' THEN RETURN.

  /* Get the table with queries again, because they might be
   * changed if the user has more than one window open.
   */
  RUN collectQueryInfo(pcDatabase, pcTable).

  /* Save current query in the tt. If it already is in the
   * TT then just move it to the top
   */
  FIND bQuery
    WHERE bQuery.cDatabase = pcDatabase
      AND bQuery.cTable    = pcTable
      AND bQuery.cQueryTxt = cQuery NO-ERROR.

  IF AVAILABLE bQuery THEN
  DO:
    ASSIGN bQuery.iQueryNr = 0.
  END.
  ELSE
  DO:
    CREATE bQuery.
    ASSIGN bQuery.cDatabase = pcDatabase
          bQuery.cTable    = pcTable
          bQuery.iQueryNr  = 0
          bQuery.cQueryTxt = cQuery.
  END.

  /* The ttQuery temp-table is already filled, renumber it */
  #QueryLoop:
  REPEAT PRESELECT EACH bQuery
    WHERE bQuery.cDatabase = pcDatabase
      AND bQuery.cTable    = pcTable
      BY bQuery.iQueryNr:

    FIND NEXT bQuery NO-ERROR.
    IF NOT AVAILABLE bQuery THEN LEAVE #QueryLoop.
    ASSIGN
      iNewNr          = iNewNr + 1
      bQuery.iQueryNr = iNewNr.
  END.

  /* And save it to the INI-file */
  RUN saveQueryTable(table bQuery, pcDatabase, pcTable).

  {&timerStop}
END PROCEDURE. /* saveQuery */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-saveQueryTable) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE saveQueryTable Procedure 
PROCEDURE saveQueryTable :
/* Save the queries in the TT to the INI file with a max of MaxQueryHistory
  */
  DEFINE INPUT  PARAMETER table FOR ttQuery.
  DEFINE INPUT  PARAMETER pcDatabase     AS CHARACTER   NO-UNDO.
  DEFINE INPUT  PARAMETER pcTable        AS CHARACTER   NO-UNDO.

  DEFINE VARIABLE iMaxQueryHistory AS INTEGER NO-UNDO.
  DEFINE VARIABLE iQuery           AS INTEGER NO-UNDO.
  DEFINE VARIABLE cSetting         AS CHARACTER NO-UNDO.

  DEFINE BUFFER bQuery FOR ttQuery.

  {&timerStart}

  iMaxQueryHistory = INTEGER(getRegistry("DataDigger", "MaxQueryHistory" )).
  IF iMaxQueryHistory = 0 THEN RETURN. /* no query history wanted */

  /* If it is not defined use default setting */
  IF iMaxQueryHistory = ? THEN iMaxQueryHistory = 10.

  iQuery = 1.

  #SaveQuery:
  FOR EACH bQuery
    WHERE bQuery.cDatabase = pcDatabase
      AND bQuery.cTable    = pcTable
      BY bQuery.iQueryNr:

    cSetting = bQuery.cQueryTxt.
    IF cSetting = '' THEN NEXT #SaveQuery.

    setRegistry( SUBSTITUTE("DB:&1", pcDatabase)
              , SUBSTITUTE('&1:query:&2', pcTable, iQuery)
              , cSetting).
    iQuery = iQuery + 1.
    IF iQuery > iMaxQueryHistory THEN LEAVE #SaveQuery.
  END.

  /* Delete higher nrs than MaxQueryHistory */
  DO WHILE iQuery <= iMaxQueryHistory:

    setRegistry( SUBSTITUTE("DB:&1", pcDatabase)
              , SUBSTITUTE('&1:query:&2', pcTable, iQuery)
              , ?).
    iQuery = iQuery + 1.
  END. /* iQuery .. MaxQueryHistory */

  {&timerStop}
END PROCEDURE. /* saveQueryTable */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-saveWindowPos) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE saveWindowPos Procedure 
PROCEDURE saveWindowPos :
/* Save position / size of a window
  */
  DEFINE INPUT PARAMETER phWindow     AS HANDLE      NO-UNDO.
  DEFINE INPUT PARAMETER pcWindowName AS CHARACTER   NO-UNDO.

  setRegistry(pcWindowName, "Window:x"     , STRING(phWindow:X) ).
  setRegistry(pcWindowName, "Window:y"     , STRING(phWindow:Y) ).
  setRegistry(pcWindowName, "Window:height", STRING(phWindow:HEIGHT-PIXELS) ).
  setRegistry(pcWindowName, "Window:width" , STRING(phWindow:WIDTH-PIXELS) ).

END PROCEDURE. /* saveWindowPos */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setCaching) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setCaching Procedure 
PROCEDURE setCaching :
/* Set the cache vars for the library
  */
  glCacheTableDefs = LOGICAL( getRegistry("DataDigger:Cache","TableDefs") ).
  glCacheFieldDefs = LOGICAL( getRegistry("DataDigger:Cache","FieldDefs") ).

END PROCEDURE. /* setCaching */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setLabelPosition) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setLabelPosition Procedure 
PROCEDURE setLabelPosition :
/* Correct the position of the label for larger fonts
  */
  DEFINE INPUT PARAMETER phWidget AS HANDLE NO-UNDO.

  /* Move horizontally far enough from the widget */
  phWidget:SIDE-LABEL-HANDLE:X = phWidget:X
    - FONT-TABLE:GET-TEXT-WIDTH-PIXELS(phWidget:SIDE-LABEL-HANDLE:SCREEN-VALUE, phWidget:FRAME:FONT)
    - (IF phWidget:TYPE = 'fill-in' THEN 5 ELSE 0)
    .

END PROCEDURE. /* setLabelPosition */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setSortArrow) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setSortArrow Procedure 
PROCEDURE setSortArrow :
/* Set the sorting arrow on a browse
  */
  DEFINE INPUT PARAMETER phBrowse    AS HANDLE    NO-UNDO.
  DEFINE INPUT PARAMETER pcSortField AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER plAscending AS LOGICAL   NO-UNDO.

  DEFINE VARIABLE iColumn    AS INTEGER   NO-UNDO.
  DEFINE VARIABLE hColumn    AS HANDLE    NO-UNDO.
  DEFINE VARIABLE lSortFound AS LOGICAL   NO-UNDO.

  {&timerStart}

  DO iColumn = 1 TO phBrowse:NUM-COLUMNS:
    hColumn = phBrowse:GET-BROWSE-COLUMN(iColumn).

    /* If you apply the sort to the same column, the order
     * of sorting is inverted.
     */
    IF hColumn:NAME = pcSortField THEN
    DO:
      phBrowse:SET-SORT-ARROW(iColumn, plAscending ).
      lSortFound = TRUE.

      /* Setting is one of: ColumnSortFields | ColumnSortIndexes | ColumnSortTables */
      setRegistry( 'DataDigger'
                , SUBSTITUTE('ColumnSort&1', SUBSTRING(phBrowse:NAME,3))
                , SUBSTITUTE('&1,&2',iColumn, plAscending)
                ).
    END.
    ELSE
      phBrowse:SET-SORT-ARROW(iColumn, ? ). /* erase existing arrow */
  END.

  /* If no sort is found, delete setting */
  IF NOT lSortFound THEN
    setRegistry( 'DataDigger', SUBSTITUTE('ColumnSort&1', SUBSTRING(phBrowse:NAME,3)), ?).

  {&timerStop}

END PROCEDURE. /* setSortArrow */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setTransparency) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setTransparency Procedure 
PROCEDURE setTransparency :
/* Set transparency level for a frame, using Windows api
  */
  DEFINE INPUT  PARAMETER phFrame AS HANDLE     NO-UNDO.
  DEFINE INPUT  PARAMETER piLevel AS INTEGER    NO-UNDO.

  &SCOPED-DEFINE GWL_EXSTYLE         -20
  &SCOPED-DEFINE WS_EX_LAYERED       524288
  &SCOPED-DEFINE LWA_ALPHA           2
  &SCOPED-DEFINE WS_EX_TRANSPARENT   32

  DEFINE VARIABLE stat AS INTEGER    NO-UNDO.

  /* Set WS_EX_LAYERED on this window  */
  RUN SetWindowLongA(phFrame:HWND, {&GWL_EXSTYLE}, {&WS_EX_LAYERED}, OUTPUT stat).

  /* Make this window transparent (0 - 255) */
  RUN SetLayeredWindowAttributes(phFrame:HWND, 0, piLevel, {&LWA_ALPHA}, OUTPUT stat).

END PROCEDURE. /* setTransparency */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setUsage) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setUsage Procedure 
PROCEDURE setUsage :
/* Save DataDigger usage in the INI file
  */
  DEFINE INPUT PARAMETER pcName AS CHARACTER NO-UNDO.
  DEFINE VARIABLE i AS INTEGER NO-UNDO.

  {&timerStart}

  i = INTEGER(getRegistry("DataDigger:Usage", SUBSTITUTE("&1:numUsed", pcName))).
  IF i = ? THEN i = 0.

  i = i + 1.
  setRegistry("DataDigger:Usage", SUBSTITUTE("&1:numUsed", pcName), STRING(i)).

  {&timerStop}

END PROCEDURE. /* setUsage */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setXmlNodeNames) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE setXmlNodeNames Procedure 
PROCEDURE setXmlNodeNames :
/* Set the XML-NODE-NAMES of all fields in a buffer
  */
  DEFINE INPUT PARAMETER phTable AS HANDLE NO-UNDO.
  DEFINE VARIABLE iField AS INTEGER NO-UNDO.

  DO iField = 1 TO phTable:NUM-FIELDS:
    phTable:BUFFER-FIELD(iField):XML-NODE-NAME = getXmlNodeName(phTable:BUFFER-FIELD(iField):NAME).
  END.

END PROCEDURE. /* setXmlNodeNames */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-showHelp) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE showHelp Procedure 
PROCEDURE showHelp :
/* Show a help message and save answer to ini
  */
  DEFINE INPUT PARAMETER pcTopic   AS CHARACTER   NO-UNDO.
  DEFINE INPUT PARAMETER pcStrings AS CHARACTER   NO-UNDO.

  DEFINE VARIABLE cButtons       AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cMessage       AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cPrg           AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cTitle         AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cType          AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cUrl           AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cCanHide       AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE iButtonPressed AS INTEGER     NO-UNDO.
  DEFINE VARIABLE lDontShowAgain AS LOGICAL     NO-UNDO.
  DEFINE VARIABLE lCanHide       AS LOGICAL     NO-UNDO.
  DEFINE VARIABLE lHidden        AS LOGICAL     NO-UNDO.
  DEFINE VARIABLE iString        AS INTEGER     NO-UNDO.
  DEFINE VARIABLE cUserString    AS CHARACTER   NO-UNDO EXTENT 9.

  /* If no message, then just return */
  cMessage = getRegistry('DataDigger:Help', pcTopic + ':message').

  /* What to start? */
  cUrl = getRegistry('DataDigger:Help', pcTopic + ':url').
  cPrg = getRegistry('DataDigger:Help', pcTopic + ':program').
  cCanHide = getRegistry('DataDigger:Help', pcTopic + ':canHide').
  cCanHide = TRIM(cCanHide).
  lCanHide = LOGICAL(cCanHide) NO-ERROR.
  IF lCanHide = ? THEN lCanHide = TRUE.

  IF cMessage = ? THEN
  DO:
    IF cUrl = ? AND cPrg = ? THEN RETURN.
    lHidden        = YES. /* suppress empty text window */
    iButtonPressed = 1.   /* forces to start the url or prog */
  END.

  /* If type is unknown, set to QUESTION if there is a question mark in the message */
  cType    = getRegistry('DataDigger:Help', pcTopic + ':type').
  IF cType = ? THEN cType = (IF cMessage MATCHES '*?*' THEN 'Question' ELSE 'Message').

  /* If no button labels defined, set them based on message type */
  cButtons = getRegistry('DataDigger:Help', pcTopic + ':buttons').
  IF cButtons = ? THEN cButtons = (IF cType = 'Question' THEN '&Yes,&No,&Cancel' ELSE '&Ok').

  /* If title is empty, set it to the type of the message */
  cTitle   = getRegistry('DataDigger:Help', pcTopic + ':title').
  IF cTitle = ? THEN cTitle = cType.

  /* If hidden has strange value, set it to NO */
  lHidden = LOGICAL(getRegistry('DataDigger:Help', pcTopic + ':hidden')) NO-ERROR.
  IF lHidden = ? THEN lHidden = NO.

  /* If ButtonPressed has strange value, set hidden to NO */
  iButtonPressed = INTEGER( getRegistry('DataDigger:Help',pcTopic + ':answer') ) NO-ERROR.
  IF iButtonPressed = ? THEN lHidden = NO.

  /* if we have no message, but we do have an URL or prog, then
   * dont show an empty message box.
   */
  IF cMessage = ? THEN
    ASSIGN
      lHidden        = YES /* suppress empty text window */
      iButtonPressed = 1.   /* forces to start the url or prog */

  /* Fill in strings in message */
  DO iString = 1 TO NUM-ENTRIES(pcStrings):
    cUserString[iString] = ENTRY(iString,pcStrings).
  END.

  cMessage = SUBSTITUTE( cMessage
                      , cUserString[1]
                      , cUserString[2]
                      , cUserString[3]
                      , cUserString[4]
                      , cUserString[5]
                      , cUserString[6]
                      , cUserString[7]
                      , cUserString[8]
                      , cUserString[9]
                      ).

  /* If not hidden, show the message and let the user choose an answer */
  IF NOT lHidden THEN
  DO:
    RUN VALUE( getProgramDir() + 'dQuestion.w')
      ( INPUT cTitle
      , INPUT cMessage
      , INPUT cButtons
      , INPUT lCanHide
      , OUTPUT iButtonPressed
      , OUTPUT lDontShowAgain
      ).

    IF lDontShowAgain THEN
      setRegistry('DataDigger:Help', pcTopic + ':hidden', 'yes').
  END.

  /* Start external things if needed */
  IF iButtonPressed = 1 THEN
  DO:
    IF cUrl <> ? THEN OS-COMMAND NO-WAIT START (cUrl).
    IF cPrg <> ? THEN RUN VALUE(cPrg) NO-ERROR.
  END.

  /* Save answer */
  setRegistry('DataDigger:Help',pcTopic + ':answer', STRING(iButtonPressed)).

END PROCEDURE. /* showHelp */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-showScrollbars) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE showScrollbars Procedure 
PROCEDURE showScrollbars :
/* Hide or show scrollbars the hard way
  */
  DEFINE INPUT PARAMETER ip-Frame      AS HANDLE  NO-UNDO.
  DEFINE INPUT PARAMETER ip-horizontal AS LOGICAL NO-UNDO.
  DEFINE INPUT PARAMETER ip-vertical   AS LOGICAL NO-UNDO.

  DEFINE VARIABLE iv-retint AS INTEGER NO-UNDO.

  {&timerStart}

  IF NOT VALID-HANDLE(ip-Frame) OR ip-Frame:HWND = ? THEN RETURN.

  &scoped-define SB_HORZ 0
  &scoped-define SB_VERT 1
  &scoped-define SB_BOTH 3
  &scoped-define SB_THUMBPOSITION 4

  RUN ShowScrollBar ( ip-Frame:HWND,
                      {&SB_HORZ},
                      IF ip-horizontal THEN -1 ELSE 0,
                      OUTPUT iv-retint ).

  RUN ShowScrollBar ( ip-Frame:HWND,
                      {&SB_VERT},
                      IF ip-vertical  THEN -1 ELSE 0,
                      OUTPUT iv-retint ).
  &undefine SB_HORZ
  &undefine SB_VERT
  &undefine SB_BOTH
  &undefine SB_THUMBPOSITION

  {&timerStop}
END PROCEDURE. /* ShowScrollbars */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-unlockWindow) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE unlockWindow Procedure 
PROCEDURE unlockWindow :
/* Force a window to unlock
  */
  DEFINE INPUT PARAMETER phWindow AS HANDLE  NO-UNDO.

  DEFINE VARIABLE iRet AS INTEGER NO-UNDO.
  DEFINE BUFFER ttWindowLock FOR ttWindowLock.

  PUBLISH "debugInfo" (3, SUBSTITUTE("Window &1, force to unlock", phWindow:TITLE)).

  /* Find window in our tt of locked windows */
  FIND ttWindowLock WHERE ttWindowLock.hWindow = phWindow NO-ERROR.
  IF NOT AVAILABLE ttWindowLock THEN RETURN.

  IF ttWindowLock.iLockCounter > 0 THEN
  DO:
    RUN SendMessageA(phWindow:HWND, {&WM_SETREDRAW}, 1, 0, OUTPUT iRet).
    RUN RedrawWindow(phWindow:HWND, 0, 0, {&RDW_ALLCHILDREN} + {&RDW_ERASE} + {&RDW_INVALIDATE}, OUTPUT iRet).
    DELETE ttWindowLock.
  END.

END PROCEDURE. /* unlockWindow */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-updateFields) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE updateFields Procedure 
PROCEDURE updateFields :
/* Update the fields temp-table with settings from registry
  */
  DEFINE INPUT PARAMETER pcDatabase    AS CHARACTER   NO-UNDO.
  DEFINE INPUT PARAMETER pcTableName   AS CHARACTER   NO-UNDO.
  DEFINE INPUT-OUTPUT PARAMETER TABLE FOR ttField.

  DEFINE VARIABLE cCustomFormat      AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cSelectedFields    AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cFieldOrder        AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE iColumnOrder       AS INTEGER     NO-UNDO.
  DEFINE VARIABLE iFieldOrder        AS INTEGER     NO-UNDO.
  DEFINE VARIABLE iMaxExtent         AS INTEGER     NO-UNDO.
  DEFINE VARIABLE lRecRowAtEnd       AS LOGICAL     NO-UNDO.

  DEFINE BUFFER bField FOR ttField.
  DEFINE BUFFER bColumn FOR ttColumn.

  {&timerStart}
  PUBLISH "debugInfo" (1, SUBSTITUTE("Update field definitions for &1.&2", pcDatabase, pcTableName)).

  /* Get list of all previously selected fields */
  cSelectedFields = getRegistry(SUBSTITUTE("DB:&1",pcDatabase), SUBSTITUTE("&1:fields",pcTableName)).
  IF cSelectedFields = ? THEN cSelectedFields = '!RECID,!ROWID,*'.

  /* Get field ordering */
  cFieldOrder = getRegistry(SUBSTITUTE('DB:&1',pcDatabase), SUBSTITUTE('&1:fieldOrder',pcTableName)).

  /* RECID and ROWID at the end? */
  IF cFieldOrder <> ? THEN
  DO:
    lRecRowAtEnd = LOOKUP("ROWID", cFieldOrder) > NUM-ENTRIES(cFieldOrder) - 2 AND LOOKUP("RECID", cFieldOrder) > NUM-ENTRIES(cFieldOrder) - 2.
    PUBLISH "debugInfo" (2, SUBSTITUTE("Field order for table &1: &2", pcTableName, cFieldOrder)).
    PUBLISH "debugInfo" (3, SUBSTITUTE("Rowid/recid at the end for table &1: &2", pcTableName, lRecRowAtEnd)).
  END.

  FOR EACH bField {&TABLE-SCAN}:

    /* Due to a bug the nr of decimals may be set on non-decimal fields
     * See PKB P185263 (article 18087) for more information
     * http://knowledgebase.progress.com/articles/Article/P185263
     */
    IF bField.cDataType <> 'DECIMAL' THEN bField.iDecimals = ?.

    /* Was this field selected? */
    bField.lShow = CAN-DO(cSelectedFields, bField.cFullName).

    /* Customization option for the user to show/hide certain fields */
    PUBLISH "DD:Timer" ("start", 'customShowField').
    PUBLISH 'customShowField' (pcDatabase, pcTableName, bField.cFieldName, INPUT-OUTPUT bField.lShow).
    PUBLISH "DD:Timer" ("stop", 'customShowField').

    /* Customization option for the user to adjust the format */
    PUBLISH "DD:Timer" ("start", 'customFormat').
    PUBLISH 'customFormat' (pcDatabase, pcTableName, bField.cFieldName, bField.cDatatype, INPUT-OUTPUT bField.cFormat).
    PUBLISH "DD:Timer" ("stop", 'customFormat').

    /* Restore changed field format. */
    cCustomFormat = getRegistry(SUBSTITUTE("DB:&1",pcDatabase), SUBSTITUTE("&1.&2:format",pcTableName,bField.cFieldName) ).
    IF cCustomFormat <> ? THEN bField.cFormat = cCustomFormat.

    /* Restore changed field order. */
    bField.iOrder = LOOKUP(bField.cFullName,cFieldOrder).
    IF bField.iOrder = ? THEN bField.iOrder = bField.iOrderOrg.

    /* Keep track of highest nr */
    iFieldOrder = MAXIMUM(iFieldOrder,bField.iOrder).

  END. /* f/e bField */

  /* Only show first X of an extent */
  iMaxExtent = INTEGER(getRegistry("DataDigger","MaxExtent")) NO-ERROR.
  IF iMaxExtent = ? THEN iMaxExtent = 100.
  IF iMaxExtent > 0 THEN
  FOR EACH bColumn WHERE bColumn.iExtent > iMaxExtent:
    DELETE bColumn.
  END.

  IF CAN-FIND(FIRST bField WHERE bField.iOrder = 0) THEN
  DO:
    /* Set new fields (no order assigned) at the end */
    FOR EACH bField WHERE bField.iOrder = 0 BY bField.iFieldRpos:
      ASSIGN
        iFieldOrder   = iFieldOrder + 1
        bField.iOrder = iFieldOrder.
    END.

    /* If RECID+ROWID should be at the end then re-assign them */
    IF lRecRowAtEnd THEN
    FOR EACH bField
      WHERE bField.cFieldName = "RECID" OR bField.cFieldName = "ROWID" BY bField.iOrder:
      ASSIGN
        iFieldOrder   = iFieldOrder + 1
        bField.iOrder = iFieldOrder.
    END.
  END.

  /* Reorder fields to get rid of gaps */
  iFieldOrder = 0.
  #FieldLoop:
  REPEAT PRESELECT EACH bField BY bField.iOrder:
    FIND NEXT bField NO-ERROR.
    IF NOT AVAILABLE bField THEN LEAVE #FieldLoop.
    ASSIGN
      iFieldOrder   = iFieldOrder + 1
      bField.iOrder = iFieldOrder.
  END.

  /* Assign order nrs to columns to handle extents */
  iColumnOrder = 0.
  FOR EACH bField BY bField.iOrder:
    FOR EACH bColumn WHERE bColumn.cFieldName =  bField.cFieldName BY bColumn.cFieldName:
      iColumnOrder = iColumnOrder + 1.
      bColumn.iColumnNr = iColumnOrder.
    END.
  END.

  {&timerStop}
END PROCEDURE. /* updateFields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-updateMemoryCache) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _PROCEDURE updateMemoryCache Procedure 
PROCEDURE updateMemoryCache :
/* Update the memory cache with current settings
  */
  DEFINE INPUT PARAMETER pcDatabase  AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER pcTableName AS CHARACTER NO-UNDO.
  DEFINE INPUT PARAMETER TABLE FOR ttField.
  DEFINE INPUT PARAMETER TABLE FOR ttColumn.

  DEFINE BUFFER bField  FOR ttField.
  DEFINE BUFFER bColumn FOR ttColumn.
  DEFINE BUFFER bFieldCache  FOR ttFieldCache.
  DEFINE BUFFER bColumnCache FOR ttColumnCache.

  PUBLISH "debugInfo" (2, SUBSTITUTE("Update first-level cache for &1.&2", pcDatabase, pcTableName)).

  /* Delete old */
  FOR EACH bFieldCache
    WHERE bFieldCache.cDatabase  = pcDatabase
      AND bFieldCache.cTableName = pcTableName:

    DELETE bFieldCache.
  END.

  FOR EACH bColumnCache
    WHERE bColumnCache.cDatabase  = pcDatabase
      AND bColumnCache.cTableName = pcTableName:

    DELETE bColumnCache.
  END.

  /* Create new */
  FOR EACH bField {&TABLE-SCAN}:
    CREATE bFieldCache.
    BUFFER-COPY bField TO bFieldCache.
  END.

  FOR EACH bColumn {&TABLE-SCAN}:
    CREATE bColumnCache.
    BUFFER-COPY bColumn TO bColumnCache.
  END.

END PROCEDURE. /* updateMemoryCache */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

/* ************************  Function Implementations ***************** */

&IF DEFINED(EXCLUDE-addConnection) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION addConnection Procedure 
FUNCTION addConnection RETURNS LOGICAL
  ( pcDatabase AS CHARACTER
  , pcSection  AS CHARACTER ) :
  /* Add a connection to the temp-table
  */
  IF NOT CAN-FIND(ttDatabase WHERE ttDatabase.cLogicalName = pcDatabase) THEN
  DO:
    CREATE ttDatabase.
    ASSIGN
      ttDatabase.cLogicalName  = pcDatabase
      ttDatabase.cSection      = pcSection
      .
  END.
  RETURN TRUE.

END FUNCTION.

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-formatQueryString) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION formatQueryString Procedure 
FUNCTION formatQueryString RETURNS CHARACTER
  ( INPUT pcQueryString AS CHARACTER
  , INPUT plExpanded    AS LOGICAL ) :
  /* Return a properly formatted query string
  */
  DEFINE VARIABLE cReturnValue AS CHARACTER   NO-UNDO.

  {&timerStart}
  cReturnValue = pcQueryString.
  IF cReturnValue <> '' AND cReturnValue <> ? THEN
  DO:
    /* There might be chr(1) chars in the text (if read from ini, for example)
     * Replace these with normal CRLF, then proceed
     */
    cReturnValue = REPLACE(cReturnValue,CHR(1),'~n').

    IF plExpanded THEN
      cReturnValue = REPLACE(cReturnValue, {&QUERYSEP}, '~n').
    ELSE
      cReturnValue = REPLACE(cReturnValue, '~n', {&QUERYSEP}).
  END.

  RETURN cReturnValue.
  {&timerStop}

END FUNCTION. /* formatQueryString */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getColor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getColor Procedure 
FUNCTION getColor RETURNS INTEGER
  ( pcName AS CHARACTER ) :
  /* Return the color number for a color name
   */
  DEFINE BUFFER bColor FOR ttColor.

  FIND bColor WHERE bColor.cName = pcName NO-ERROR.
  IF NOT AVAILABLE bColor THEN 
    RETURN setColor(pcName,?).
  ELSE 
    RETURN bColor.iColor.   /* Function return value. */

END FUNCTION. /* getColor */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getColorByRGB) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getColorByRGB Procedure 
FUNCTION getColorByRGB RETURNS INTEGER
  ( piRed   AS INTEGER
  , piGreen AS INTEGER
  , piBlue  AS INTEGER
  ):
  /* Return the color number for a RGB combination
   * if needed, add color to color table.
   */
  DEFINE VARIABLE i AS INTEGER NO-UNDO.
  
  /* See if already exists */
  DO i = 0 TO COLOR-TABLE:NUM-ENTRIES - 1:
    IF    COLOR-TABLE:GET-RED-VALUE(i)   = piRed
      AND COLOR-TABLE:GET-GREEN-VALUE(i) = piGreen
      AND COLOR-TABLE:GET-BLUE-VALUE(i)  = piBlue THEN RETURN i.
  END.

  /* Define new color */
  i = COLOR-TABLE:NUM-ENTRIES.
  COLOR-TABLE:NUM-ENTRIES = COLOR-TABLE:NUM-ENTRIES + 1.
  COLOR-TABLE:SET-DYNAMIC(i, TRUE).
  COLOR-TABLE:SET-RED-VALUE  (i, piRed  ).
  COLOR-TABLE:SET-GREEN-VALUE(i, piGreen).
  COLOR-TABLE:SET-BLUE-VALUE (i, piBlue ).

  RETURN i.

END FUNCTION. /* getColorByRGB */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getColumnLabel) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getColumnLabel Procedure 
FUNCTION getColumnLabel RETURNS CHARACTER
  ( INPUT phFieldBuffer AS HANDLE ):
  /* Return column label, based on settings
  */
  DEFINE VARIABLE cColumnLabel AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cTemplate    AS CHARACTER   NO-UNDO.

  {&timerStart}

  cTemplate = getRegistry("DataDigger","ColumnLabelTemplate").
  IF cTemplate = ? OR cTemplate = "" THEN cTemplate = "&1".

  cColumnLabel = SUBSTITUTE(cTemplate
                          , phFieldBuffer::cFullName
                          , phFieldBuffer::iOrder
                          , phFieldBuffer::cLabel
                          ).
  RETURN cColumnLabel.
  {&timerStop}

END FUNCTION. /* getColumnLabel */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getColumnWidthList) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getColumnWidthList Procedure 
FUNCTION getColumnWidthList RETURNS CHARACTER
  ( INPUT phBrowse AS HANDLE ):
  /* returns a list of all fields and their width like:
   * custnum:12,custname:20,city:12
   */
  DEFINE VARIABLE cWidthList AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE hColumn    AS HANDLE      NO-UNDO.
  DEFINE VARIABLE iColumn    AS INTEGER     NO-UNDO.

  {&timerStart}

  DO iColumn = 1 TO phBrowse:NUM-COLUMNS:

    hColumn = phBrowse:GET-BROWSE-COLUMN(iColumn).
    cWidthList = SUBSTITUTE('&1,&2:&3'
                          , cWidthList
                          , hColumn:NAME
                          , hColumn:WIDTH-PIXELS
                          ).
  END.

  RETURN TRIM(cWidthList,',').
  {&timerStop}

END FUNCTION. /* getColumnWidthList */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getDatabaseList) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getDatabaseList Procedure 
FUNCTION getDatabaseList RETURNS CHARACTER:
  /* Return a comma separated list of all connected databases
  */
  DEFINE VARIABLE cDatabaseList    AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE cSchemaHolders   AS CHARACTER  NO-UNDO.
  DEFINE VARIABLE iCount           AS INTEGER    NO-UNDO.
  DEFINE VARIABLE cDbType          AS CHARACTER  NO-UNDO.  
  DEFINE VARIABLE cLogicalDbName   AS CHARACTER  NO-UNDO.  
  DEFINE VARIABLE iPos             AS INTEGER    NO-UNDO.  
  DEFINE VARIABLE iDataserverNr    AS INTEGER    NO-UNDO.  
  
  DEFINE BUFFER bDataserver FOR ttDataserver.
  
  {&timerStart}

  /* Support Dataservers */
  IF gcSaveDatabaseList <> ""
   AND PROGRAM-NAME(2) BEGINS "initializeObjects " THEN RETURN gcSaveDatabaseList.

  /* Make a list of schema holders */
  #Db:
  DO iCount = 1 TO NUM-DBS:
    ASSIGN
      cDbType        = DBTYPE(iCount)
      cLogicalDbName = LDBNAME(iCount).

    IF cDbType <> 'PROGRESS' THEN
      cSchemaHolders = cSchemaHolders + ',' + SDBNAME(iCount).
    
    cDbType = DBTYPE(iCount).
    IF cDbType <> "PROGRESS" THEN NEXT #Db.
    
    cDatabaseList = cDatabaseList + ',' + cLogicalDbName.
  END.

  /* Build list of all databases. Skip if already in the list of schemaholders  */
  #Db:
  DO iCount = 1 TO NUM-DBS:
    ASSIGN
      cDbType         = DBTYPE(iCount)
      cLogicalDbName  = LDBNAME(iCount).

    IF LOOKUP(LDBNAME(iCount), cSchemaHolders) > 0 OR cDbType <> "PROGRESS" THEN NEXT #Db.
    
    CREATE ALIAS dictdb FOR DATABASE VALUE(cLogicalDbName).
    RUN getDataserver.p
      ( INPUT              THIS-PROCEDURE
      , INPUT              cLogicalDbName
      , INPUT-OUTPUT       iDataserverNr
      , INPUT-OUTPUT TABLE bDataserver
      ).
    DELETE ALIAS dictdb.
  END.
  
  /* Support dataservers */    
  FOR EACH bDataserver BY bDataserver.cLDbNameSchema:
    /* Remove schemaholder from database list */
    IF bDataserver.lDontShowSchemaHr THEN
    DO:
      iPos = LOOKUP(bDataserver.cLDbNameSchema, cDatabaseList).
      IF iPos > 0
       AND NOT CAN-FIND(FIRST ttTable WHERE ttTable.cDatabase = bDataserver.cLDbNameSchema
                                        AND ttTable.lHidden   = NO) THEN
      DO:
        ENTRY(iPos, cDatabaseList) = "".
        cDatabaseList = TRIM(REPLACE(cDatabaseList, ",,", ","), ",").
      END.
    END.

    /* Add dataserver to database list */
    iPos = LOOKUP(bDataserver.cLDbNameDataserver, cDatabaseList).
    IF bDataserver.lConnected THEN
    DO:
      IF iPos = 0 THEN cDatabaseList = TRIM(cDatabaseList + "," + bDataserver.cLDbNameDataserver, ",").
    END. /* IF bDataserver.lConnected */
    
    ELSE
    DO:
      IF iPos > 0 THEN
      DO:
        ENTRY(iPos, cDatabaseList) = "".
        cDatabaseList = TRIM(REPLACE(cDatabaseList, ",,", ","), ",").
      END. /* IF iPos > 0 */
    END. /* else */
  END. /* FOR EACH bDataserver */

  ASSIGN
    cDatabaseList      = TRIM(cDatabaseList, ',')
    gcSaveDatabaseList = cDatabaseList.

  RETURN cDatabaseList.
  
  {&timerStop}
END FUNCTION. /* getDatabaseList */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getEscapedData) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getEscapedData Procedure 
FUNCTION getEscapedData RETURNS CHARACTER
  ( pcTarget AS CHARACTER
  , pcString AS CHARACTER ) :
  /* Return html- or 4gl-safe string
  */
  DEFINE VARIABLE cOutput AS CHARACTER NO-UNDO.
  DEFINE VARIABLE iTmp    AS INTEGER   NO-UNDO.

  {&timerStart}

  /* Garbage in, garbage out  */
  cOutput = pcString.

  CASE pcTarget:
    WHEN "HTML" THEN
    DO:
      cOutput = REPLACE(cOutput,"<","&lt;").
      cOutput = REPLACE(cOutput,">","&gt;").
    END.

    WHEN "4GL" THEN
    DO:
      /* Replace single quotes because we are using them for 4GL separating too */
      cOutput = REPLACE(cOutput, "'", "~~'").

      /* Replace CHR's 1 till 13  */
      DO iTmp = 1 TO 13:
        cOutput = REPLACE(cOutput, CHR(iTmp), "' + chr(" + string(iTmp) + ") + '").
      END.
    END.
  END CASE.

  RETURN pcString.
  {&timerStop}

END FUNCTION. /* getEscapedData */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getFieldList) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getFieldList Procedure 
FUNCTION getFieldList RETURNS CHARACTER
  ( pcDatabase AS CHARACTER
  , pcFile     AS CHARACTER
  ):
  /* Return a comma separated list of all fields of a table
  */
  DEFINE VARIABLE hQuery  AS HANDLE    NO-UNDO.
  DEFINE VARIABLE hFile   AS HANDLE    NO-UNDO.
  DEFINE VARIABLE hField  AS HANDLE    NO-UNDO.
  DEFINE VARIABLE cFields AS CHARACTER NO-UNDO.

  CREATE BUFFER hFile FOR TABLE pcDatabase + "._file".
  CREATE BUFFER hField FOR TABLE pcDatabase + "._field".

  CREATE QUERY hQuery.
  hQuery:SET-BUFFERS(hFile,hField).
  hQuery:QUERY-PREPARE(SUBSTITUTE('FOR EACH _File WHERE _File-name = &1, EACH _Field OF _File', QUOTER(pcFile))).
  hQuery:QUERY-OPEN().

  #CollectFields:
  REPEAT:
    hQuery:GET-NEXT().
    IF hQuery:QUERY-OFF-END THEN LEAVE #CollectFields.
    cFields = cFields + "," + hField::_Field-name.
  END. /* #CollectFields */

  RETURN TRIM(cFields, ",").

  FINALLY:
    hQuery:QUERY-CLOSE().
    DELETE OBJECT hField.
    DELETE OBJECT hFile.
    DELETE OBJECT hQuery.
  END FINALLY.

END FUNCTION. /* getFieldList */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getFileCategory) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getFileCategory Procedure 
FUNCTION getFileCategory RETURNS CHARACTER
  ( piFileNumber AS INTEGER
  , pcFileName   AS CHARACTER
  ) :
  /* Based on table name and -number, return the category for a table
   *
   * Application tables   : _file-number > 0   AND _file-number < 32000
   * Schema tables        : _file-number > -80 AND _file-number < 0
   * Virtual system tables: _file-number < -16384
   * SQL catalog tables   : _file-name BEGINS "_sys"
   * Other tables         : _file-number >= -16384 AND _file-number <= -80
   */
  IF piFileNumber > 0       AND piFileNumber < 32000 THEN RETURN 'Normal'.
  IF piFileNumber > -80     AND piFileNumber < 0     THEN RETURN 'Schema'.
  IF piFileNumber < -16384                           THEN RETURN 'VST'.
  IF pcFileName BEGINS '_sys'                        THEN RETURN 'SQL'.
  IF piFileNumber >= -16384 AND piFileNumber <= -80  THEN RETURN 'Other'.

  RETURN ''.   /* Function return value. */

END FUNCTION. /* getFileCategory */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getFont) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getFont Procedure 
FUNCTION getFont RETURNS INTEGER
  ( pcName AS CHARACTER ) :
  /* Return the fontnumber for the type given
  */
  DEFINE BUFFER bFont FOR ttFont.

  {&timerStart}

  FIND bFont WHERE bFont.cName = pcName NO-ERROR.
  IF AVAILABLE bFont THEN RETURN bFont.iFont.

  CREATE bFont.
  ASSIGN bFont.cName = pcName.

  bFont.iFont = INTEGER(getRegistry('DataDigger:Fonts',pcName)) NO-ERROR.

  IF bFont.iFont = ? OR bFont.iFont > 23 THEN
  CASE pcName:
    WHEN 'Default' THEN bFont.iFont = 4.
    WHEN 'Fixed'   THEN bFont.iFont = 0.
  END CASE.

  RETURN bFont.iFont.   /* Function return value. */
  {&timerStop}

END FUNCTION. /* getFont */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getImagePath) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getImagePath Procedure 
FUNCTION getImagePath RETURNS CHARACTER
  ( pcImage AS CHARACTER ) :
  /* Return the image path + icon set name
  */
  {&timerStart}
  RETURN SUBSTITUTE('&1Image/default_&2', getProgramDir(), pcImage).
  {&timerStop}
  
END FUNCTION. /* getImagePath */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getIndexFields) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getIndexFields Procedure 
FUNCTION getIndexFields RETURNS CHARACTER
  ( INPUT pcDatabaseName AS CHARACTER
  , INPUT pcTableName    AS CHARACTER
  , INPUT pcFlags        AS CHARACTER
  ) :
  /* Return the index fields of a table.
  */
  DEFINE VARIABLE cWhere            AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE hQuery            AS HANDLE      NO-UNDO.
  DEFINE VARIABLE hFieldBuffer      AS HANDLE      NO-UNDO.
  DEFINE VARIABLE hFileBuffer       AS HANDLE      NO-UNDO.
  DEFINE VARIABLE hIndexBuffer      AS HANDLE      NO-UNDO.
  DEFINE VARIABLE hIndexFieldBuffer AS HANDLE      NO-UNDO.
  DEFINE VARIABLE cFieldList        AS CHARACTER   NO-UNDO.

  {&timerStart}

  CREATE BUFFER hFileBuffer       FOR TABLE pcDatabaseName + "._File".
  CREATE BUFFER hIndexBuffer      FOR TABLE pcDatabaseName + "._Index".
  CREATE BUFFER hIndexFieldBuffer FOR TABLE pcDatabaseName + "._Index-Field".
  CREATE BUFFER hFieldBuffer      FOR TABLE pcDatabaseName + "._Field".

  CREATE QUERY hQuery.
  hQuery:SET-BUFFERS(hFileBuffer,hIndexBuffer,hIndexFieldBuffer,hFieldBuffer).

  {&_proparse_ prolint-nowarn(longstrings)}
  cWhere = SUBSTITUTE("FOR EACH &1._file WHERE &1._file._file-name = &2 AND _File._File-Number < 32768, ~
                          EACH &1._index       OF &1._file WHERE TRUE &3 &4,  ~
                          EACH &1._index-field OF &1._index,            ~
                          EACH &1._field       OF &1._index-field"
                    , pcDatabaseName
                    , QUOTER(pcTableName)
                    , (IF CAN-DO(pcFlags,"U") THEN "AND _index._unique = true" ELSE "")
                    , (IF CAN-DO(pcFlags,"P") THEN "AND recid(_index) = _file._prime-index" ELSE "")
                    ).

  IF hQuery:QUERY-PREPARE (cWhere) THEN
  DO:
    hQuery:QUERY-OPEN().
    hQuery:GET-FIRST(NO-LOCK).
    REPEAT WHILE NOT hQuery:QUERY-OFF-END:
      cFieldList = cFieldList + "," + trim(hFieldBuffer:BUFFER-FIELD("_field-name"):string-value).
      hQuery:GET-NEXT(NO-LOCK).
    END.
  END.

  cFieldList = TRIM(cFieldList, ",").

  hQuery:QUERY-CLOSE.

  DELETE OBJECT hFileBuffer.
  DELETE OBJECT hIndexBuffer.
  DELETE OBJECT hIndexFieldBuffer.
  DELETE OBJECT hFieldBuffer.
  DELETE OBJECT hQuery.

  RETURN cFieldList.   /* Function return value. */
  {&timerStop}
END FUNCTION. /* getIndexFields */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getKeyList) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getKeyList Procedure 
FUNCTION getKeyList RETURNS CHARACTER
  ( /* parameter-definitions */ ) :
  /* Return a list of special keys pressed
  */
  DEFINE VARIABLE mKeyboardState AS MEMPTR    NO-UNDO.
  DEFINE VARIABLE iReturnValue   AS INT64     NO-UNDO.
  DEFINE VARIABLE cKeyList       AS CHARACTER NO-UNDO.

  SET-SIZE(mKeyboardState) = 256.

  /* Get the current state of the keyboard */
  RUN GetKeyboardState(GET-POINTER-VALUE(mKeyboardState), OUTPUT iReturnValue) NO-ERROR.
  IF ERROR-STATUS:ERROR THEN RETURN ''. /* try to suppress error: 'C' Call Stack has been compromised after calling  in  (6069) */

  IF GET-BITS(GET-BYTE(mKeyboardState, 1 + 16), 8, 1) = 1 THEN cKeyList = TRIM(cKeyList + ",SHIFT",",").
  IF GET-BITS(GET-BYTE(mKeyboardState, 1 + 17), 8, 1) = 1 THEN cKeyList = TRIM(cKeyList + ",CTRL",",").
  IF GET-BITS(GET-BYTE(mKeyboardState, 1 + 18), 8, 1) = 1 THEN cKeyList = TRIM(cKeyList + ",ALT",",").

  FINALLY:
    SET-SIZE(mKeyboardState) = 0.
    RETURN cKeyList.   /* Function return value. */
  END FINALLY.

END FUNCTION. /* getKeyList */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getLinkInfo) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getLinkInfo Procedure 
FUNCTION getLinkInfo RETURNS CHARACTER
  ( INPUT pcFieldName AS CHARACTER
  ):
  /* Save name/value of a field.
  */
  DEFINE BUFFER bLinkInfo FOR ttLinkInfo.
  {&timerStart}
  FIND bLinkInfo WHERE bLinkInfo.cField = pcFieldName NO-ERROR.

  RETURN (IF AVAILABLE bLinkInfo THEN bLinkInfo.cValue ELSE "").
  {&timerStop}
END FUNCTION. /* getLinkInfo */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getMaxLength) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getMaxLength Procedure 
FUNCTION getMaxLength RETURNS INTEGER
  ( cFieldList AS CHARACTER ) :
  /* Return the length of the longest element in a comma separated list
  */
  DEFINE VARIABLE iField     AS INTEGER NO-UNDO.
  DEFINE VARIABLE iMaxLength AS INTEGER NO-UNDO.
  {&timerStart}

  /* Get max field length */
  DO iField = 1 TO NUM-ENTRIES(cFieldList):
    iMaxLength = MAXIMUM(iMaxLength,LENGTH(ENTRY(iField,cFieldList))).
  END.

  RETURN iMaxLength.   /* Function return value. */
  {&timerStop}
END FUNCTION. /* getMaxLength */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getOsErrorDesc) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getOsErrorDesc Procedure 
FUNCTION getOsErrorDesc RETURNS CHARACTER
  (INPUT piOsError AS INTEGER):
  /* Return string for os-error
  */
  CASE piOsError:
    WHEN   0 THEN RETURN "No error                 ".
    WHEN   1 THEN RETURN "Not owner                ".
    WHEN   2 THEN RETURN "No such file or directory".
    WHEN   3 THEN RETURN "Interrupted system call  ".
    WHEN   4 THEN RETURN "I/O error                ".
    WHEN   5 THEN RETURN "Bad file number          ".
    WHEN   6 THEN RETURN "No more processes        ".
    WHEN   7 THEN RETURN "Not enough core memory   ".
    WHEN   8 THEN RETURN "Permission denied        ".
    WHEN   9 THEN RETURN "Bad address              ".
    WHEN  10 THEN RETURN "File exists              ".
    WHEN  11 THEN RETURN "No such device           ".
    WHEN  12 THEN RETURN "Not a directory          ".
    WHEN  13 THEN RETURN "Is a directory           ".
    WHEN  14 THEN RETURN "File table overflow      ".
    WHEN  15 THEN RETURN "Too many open files      ".
    WHEN  16 THEN RETURN "File too large           ".
    WHEN  17 THEN RETURN "No space left on device  ".
    WHEN  18 THEN RETURN "Directory not empty      ".
    OTHERWISE RETURN "Unmapped error           ".
  END CASE.

END FUNCTION. /* getOsErrorDesc */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getProgramDir) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getProgramDir Procedure 
FUNCTION getProgramDir RETURNS CHARACTER
  ( /* parameter-definitions */ ) :
  /* Return the DataDigger install dir, including a backslash
  */

  /* Cached the value in a global var (about 100x as fast) */
  IF gcProgramDir = '' THEN
  DO:
    /* this-procedure:file-name will return the .p name without path when the
     * procedure us run without full path. We need to seek it in the propath.
     */
    FILE-INFO:FILE-NAME = THIS-PROCEDURE:FILE-NAME.
    IF FILE-INFO:FULL-PATHNAME = ? THEN
    DO:
      IF SUBSTRING(THIS-PROCEDURE:FILE-NAME,LENGTH(THIS-PROCEDURE:FILE-NAME) - 1, 2) = ".p" THEN
        FILE-INFO:FILE-NAME = SUBSTRING(THIS-PROCEDURE:FILE-NAME,1,LENGTH(THIS-PROCEDURE:FILE-NAME) - 2) + ".r".
    END.

    gcProgramDir = SUBSTRING(FILE-INFO:FULL-PATHNAME,1,R-INDEX(FILE-INFO:FULL-PATHNAME,'\')).
    PUBLISH "message"(50,gcProgramDir).
  END.

  RETURN gcProgramDir.

END FUNCTION. /* getProgramDir */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getQuery) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getQuery Procedure 
FUNCTION getQuery RETURNS CHARACTER
  ( INPUT pcDatabase AS CHARACTER
  , INPUT pcTable    AS CHARACTER
  , INPUT piQuery    AS INTEGER
  ) :
  /* Get previously used query nr <piQuery>
  */
  DEFINE BUFFER bQuery FOR ttQuery.

  FIND bQuery
    WHERE bQuery.cDatabase = pcDatabase
      AND bQuery.cTable    = pcTable
      AND bQuery.iQueryNr  = piQuery NO-ERROR.

  IF AVAILABLE bQuery THEN
    RETURN bQuery.cQueryTxt.
  ELSE
    RETURN ?.

END FUNCTION. /* getQuery */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getReadableQuery) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getReadableQuery Procedure 
FUNCTION getReadableQuery RETURNS CHARACTER
  ( INPUT pcQuery AS CHARACTER ):
  /* Return a query as a string that is readable for humans.
  */
  DEFINE VARIABLE hQuery AS HANDLE NO-UNDO.

  /* Accept query or query-handle */
  hQuery = WIDGET-HANDLE(pcQuery) NO-ERROR.
  IF VALID-HANDLE( hQuery ) THEN
  DO:
    hQuery = WIDGET-HANDLE(pcQuery).
    pcQuery = hQuery:PREPARE-STRING.
  END.

  pcQuery = REPLACE(pcQuery,' EACH ' ,' EACH ').
  pcQuery = REPLACE(pcQuery,' FIRST ',' FIRST ').
  pcQuery = REPLACE(pcQuery,' WHERE ',  '~n  WHERE ').
  pcQuery = REPLACE(pcQuery,' AND '  ,  '~n    AND ').
  pcQuery = REPLACE(pcQuery,' BY '   ,  '~n     BY ').
  pcQuery = REPLACE(pcQuery,' FIELDS ()','').
  pcQuery = REPLACE(pcQuery,'FOR EACH ' ,'FOR EACH ').
  pcQuery = REPLACE(pcQuery,' NO-LOCK',  ' NO-LOCK').
  pcQuery = REPLACE(pcQuery,' INDEXED-REPOSITION',  '').

  pcQuery = pcQuery + '~n'.

  RETURN pcQuery.
END FUNCTION. /* getReadableQuery */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getRegistry) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getRegistry Procedure 
FUNCTION getRegistry RETURNS CHARACTER
    ( pcSection AS CHARACTER
    , pcKey     AS CHARACTER
    ) :
  /* Get a value from the registry.
  */
  {&timerStart}
  DEFINE BUFFER bDatabase FOR ttDatabase.
  DEFINE BUFFER bConfig   FOR ttConfig.

  /* If this is a DB-specific section then replace db name if needed */
  IF pcSection BEGINS "DB:" THEN
  DO:
    FIND bDatabase WHERE bDatabase.cLogicalName = ENTRY(2,pcSection,":") NO-ERROR.
    IF AVAILABLE bDatabase THEN pcSection = "DB:" + bDatabase.cSection.
  END.

  /* Load settings if there is nothing in the config table */
  IF NOT TEMP-TABLE ttConfig:HAS-RECORDS THEN
    RUN loadSettings.

  /* Search in settings tt */
  FIND bConfig WHERE bConfig.cSection = pcSection AND bConfig.cSetting = pcKey NO-ERROR.

  RETURN ( IF AVAILABLE bConfig THEN bConfig.cValue ELSE ? ).
  {&timerStop}
END FUNCTION. /* getRegistry */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getSchemaHolder) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getSchemaHolder Procedure 
FUNCTION getSchemaHolder RETURNS CHARACTER
  ( INPUT pcDataSrNameOrDbName AS CHARACTER
  ):
  DEFINE BUFFER bDataserver FOR ttDataserver.

  FIND bDataserver WHERE bDataserver.cLDBNameDataserver = pcDataSrNameOrDbName NO-ERROR.
  RETURN (IF AVAILABLE bDataserver THEN bDataserver.cLDBNameSchema ELSE pcDataSrNameOrDbName).
  
END FUNCTION. /* getSchemaHolder */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getStackSize) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getStackSize Procedure 
FUNCTION getStackSize RETURNS INTEGER():
  /* Return value of the -s session setting
  */
  DEFINE VARIABLE cList      AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cParm      AS CHARACTER   CASE-SENSITIVE NO-UNDO.
  DEFINE VARIABLE cSetting   AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cValue     AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE iParm      AS INTEGER     NO-UNDO.
  DEFINE VARIABLE iStackSize AS INTEGER     NO-UNDO.

  cList = SESSION:STARTUP-PARAMETERS.

  DO iParm = 1 TO NUM-ENTRIES(cList):
    cSetting = ENTRY(iParm,cList) + " ".
    cParm    = ENTRY(1,cSetting," ").
    cValue   = ENTRY(2,cSetting," ").

    IF cParm = "-s" THEN
    DO:
      iStackSize = INTEGER(cValue) NO-ERROR.
      IF ERROR-STATUS:ERROR THEN iStackSize = 0.
    END.
  END.

  /* If not defined, report the default */
  IF iStackSize = 0 THEN iStackSize = 40.

  RETURN iStackSize.
END FUNCTION. /* getStackSize */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getTableDesc) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getTableDesc Procedure 
FUNCTION getTableDesc RETURNS CHARACTER
  ( INPUT pcDatabase AS CHARACTER
  , INPUT pcTable    AS CHARACTER
  ) :
  DEFINE BUFFER bTable FOR ttTable.

  FIND bTable 
    WHERE bTable.cDatabase  = pcDatabase
      AND bTable.cTableName = pcTable NO-ERROR.

  RETURN (IF AVAILABLE bTable THEN bTable.cTableDesc ELSE '').

END FUNCTION. /* getTableDesc */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getTableLabel) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getTableLabel Procedure 
FUNCTION getTableLabel RETURNS CHARACTER
  ( INPUT  pcDatabase AS CHARACTER
  , INPUT  pcTable    AS CHARACTER
  ) :
  DEFINE BUFFER bTable FOR ttTable.

  FIND bTable 
    WHERE bTable.cDatabase  = pcDatabase
      AND bTable.cTableName = pcTable NO-ERROR.

  RETURN (IF AVAILABLE bTable AND bTable.cTableLabel <> ? THEN bTable.cTableLabel ELSE '').

END FUNCTION. /* getTableLabel */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getTableList) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getTableList Procedure 
FUNCTION getTableList RETURNS CHARACTER
  ( INPUT  pcDatabaseFilter AS CHARACTER
  , INPUT  pcTableFilter    AS CHARACTER
  ) :
  /* Get a filtered list of all tables in the current database
  */
  DEFINE VARIABLE cTableList  AS CHARACTER   NO-UNDO.
  DEFINE VARIABLE cQuery      AS CHARACTER   NO-UNDO.

  DEFINE BUFFER bTable FOR ttTable.
  DEFINE QUERY qTable FOR bTable.

  {&timerStart}
  IF pcDatabaseFilter = '' OR pcDatabaseFilter = ? THEN pcDatabaseFilter = '*'.

  /* Build query */
  cQuery = SUBSTITUTE('for each bTable where cDatabase matches &1', QUOTER(pcDatabaseFilter)).
  cQuery = SUBSTITUTE("&1 and cTableName matches &2", cQuery, QUOTER(pcTableFilter )).

  QUERY qTable:QUERY-PREPARE( SUBSTITUTE('&1 by cTableName', cQuery)).
  QUERY qTable:QUERY-OPEN.
  QUERY qTable:GET-FIRST.

  /* All fields */
  REPEAT WHILE NOT QUERY qTable:QUERY-OFF-END:
    cTableList = cTableList + "," + bTable.cTableName.
    QUERY qTable:GET-NEXT.
  END.
  QUERY qTable:QUERY-CLOSE.

  cTableList = LEFT-TRIM(cTableList, ",").

  RETURN cTableList.   /* Function return value. */
  {&timerStop}
END FUNCTION. /* getTableList */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getUserName) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getUserName Procedure 
FUNCTION getUserName RETURNS CHARACTER
  ( /* parameter-definitions */ ) :
  /* Return login name of user
  */
  DEFINE VARIABLE cUserName AS LONGCHAR   NO-UNDO.
  DEFINE VARIABLE intResult AS INTEGER    NO-UNDO.
  DEFINE VARIABLE intSize   AS INTEGER    NO-UNDO.
  DEFINE VARIABLE mUserId   AS MEMPTR     NO-UNDO.

  {&startTimer}

  /* Otherwise determine the value */
  SET-SIZE(mUserId) = 256.
  intSize = 255.

  RUN GetUserNameA(INPUT mUserId, INPUT-OUTPUT intSize, OUTPUT intResult).
  COPY-LOB mUserId FOR (intSize - 1) TO cUserName NO-CONVERT.

  IF intResult <> 1 THEN
    cUserName = "default".
  ELSE
    cUserName = REPLACE(cUserName,".","").

  RETURN STRING(cUserName). /* Function return value. */

  {&stopTimer}
END FUNCTION. /* getUserName */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getWidgetUnderMouse) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getWidgetUnderMouse Procedure 
FUNCTION getWidgetUnderMouse RETURNS HANDLE
  ( phFrame AS HANDLE ) :
  /* Return the handle of the widget that is currently under the mouse cursor
  */
  DEFINE VARIABLE hWidget AS HANDLE  NO-UNDO.
  DEFINE VARIABLE iMouseX AS INTEGER NO-UNDO.
  DEFINE VARIABLE iMouseY AS INTEGER NO-UNDO.

  {&timerStart}
  hWidget = phFrame:FIRST-CHILD:first-child.
  RUN getMouseXY(INPUT phFrame, OUTPUT iMouseX, OUTPUT iMouseY).

  REPEAT WHILE VALID-HANDLE(hWidget):

    IF hWidget:TYPE <> "RECTANGLE"
      AND iMouseX >= hWidget:X
      AND iMouseX <= hWidget:X + hWidget:WIDTH-PIXELS
      AND iMouseY >= hWidget:Y
      AND iMouseY <= hWidget:Y + hWidget:HEIGHT-PIXELS THEN RETURN hWidget.

    hWidget = hWidget:NEXT-SIBLING.
  END.

  RETURN ?.
  {&timerStop}
END FUNCTION. /* getWidgetUnderMouse */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getWorkFolder) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getWorkFolder Procedure 
FUNCTION getWorkFolder RETURNS CHARACTER
  ( /* parameter-definitions */ ) :

  /* Cached the value in a global var  */
  IF gcWorkFolder = '' THEN
  DO:
    gcWorkFolder = getRegistry("DataDigger", "WorkFolder").

    /* Possibility to specify where DD files are created */
    IF gcWorkFolder = ? OR gcWorkFolder = '' THEN
      gcWorkFolder = getProgramDir().
    ELSE
    DO:
      gcWorkFolder = RIGHT-TRIM(gcWorkFolder,'/\') + '\'.
      gcWorkFolder = resolveOsVars(gcWorkFolder).
      RUN createFolder(gcWorkFolder).

      FILE-INFO:FILE-NAME = gcWorkFolder.
      IF FILE-INFO:FULL-PATHNAME = ? THEN gcWorkFolder = getProgramDir().
    END.
  END.

  RETURN gcWorkFolder.

END FUNCTION. /* getWorkFolder */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-getXmlNodeName) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION getXmlNodeName Procedure 
FUNCTION getXmlNodeName RETURNS CHARACTER
  ( pcFieldName AS CHARACTER ) :
  /* Return a name that is safe to use in XML output
  */
  pcFieldName = REPLACE(pcFieldName,'%', '_').
  pcFieldName = REPLACE(pcFieldName,'#', '_').

  RETURN pcFieldName.

END FUNCTION. /* getXmlNodeName */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isBrowseChanged) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION isBrowseChanged Procedure 
FUNCTION isBrowseChanged RETURNS LOGICAL
  ( INPUT phBrowse AS HANDLE ) :
  /* Check the browse to see if its size has changed
  */
  DEFINE VARIABLE iField  AS INTEGER NO-UNDO.
  DEFINE VARIABLE hColumn AS HANDLE  NO-UNDO.

  IF NOT VALID-HANDLE(phBrowse) THEN RETURN FALSE.
  IF phBrowse:TYPE <> "BROWSE" THEN RETURN FALSE.

  {&TimerStart}

  /* First check the browse itself */
  IF isWidgetChanged(phBrowse) THEN RETURN TRUE.

  DO iField = 1 TO phBrowse:NUM-COLUMNS:
    hColumn = phBrowse:GET-BROWSE-COLUMN(iField):handle.
    IF isWidgetChanged(hColumn) THEN RETURN TRUE.
  END. /* browse */

  /* apparently nothing changed, so... */
  PUBLISH "debugInfo" (2, SUBSTITUTE("Nothing changed in browse: &1", phBrowse:NAME)).

  RETURN FALSE.
  {&timerStop}
END FUNCTION. /* isBrowseChanged */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isDataServer) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION isDataServer Procedure 
FUNCTION isDataServer RETURNS LOGICAL
  ( INPUT pcDataSrNameOrDbName AS CHARACTER
  ):
  RETURN CAN-FIND(ttDataserver WHERE ttDataserver.cLDBNameDataserver = pcDataSrNameOrDbName).
  
END FUNCTION. /* isDataServer */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isDefaultFontsChanged) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION isDefaultFontsChanged Procedure 
FUNCTION isDefaultFontsChanged RETURNS LOGICAL
  ( /* parameter-definitions */ ) :
  /* Returns whether the default fonts 0-7 were changed.
  */
  DEFINE VARIABLE cFontSize AS CHARACTER NO-UNDO EXTENT 8.
  DEFINE VARIABLE i         AS INTEGER   NO-UNDO.

  /* These are the expected fontsizes of the text 'DataDigger' */
  cFontSize[1] = '70/14'. /* font0 */
  cFontSize[2] = '54/13'. /* font1 */
  cFontSize[3] = '70/14'. /* font2 */
  cFontSize[4] = '70/14'. /* font3 */
  cFontSize[5] = '54/13'. /* font4 */
  cFontSize[6] = '70/16'. /* font5 */
  cFontSize[7] = '65/13'. /* font6 */
  cFontSize[8] = '54/13'. /* font7 */

  checkFont:
  DO i = 0 TO 7:
    IF cFontSize[i + 1] <> SUBSTITUTE('&1/&2'
                                    , FONT-TABLE:GET-TEXT-WIDTH-PIXELS('DataDigger',i)
                                    , FONT-TABLE:GET-TEXT-HEIGHT-PIXELS(i)
                                    ) THEN RETURN TRUE.
  END. /* checkFont */

  RETURN FALSE.

END FUNCTION. /* isDefaultFontsChanged */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isFileLocked) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION isFileLocked Procedure 
FUNCTION isFileLocked RETURNS LOGICAL
  ( pcFileName AS CHARACTER ) :
  /* Check whether a file is locked on the file system
  */
  DEFINE VARIABLE iFileHandle   AS INTEGER NO-UNDO.
  DEFINE VARIABLE nReturn       AS INTEGER NO-UNDO.

  /* Try to lock the file agains writing */
  RUN CreateFileA ( INPUT pcFileName
                  , INPUT {&GENERIC_WRITE}
                  , {&FILE_SHARE_READ}
                  , 0
                  , {&OPEN_EXISTING}
                  , {&FILE_ATTRIBUTE_NORMAL}
                  , 0
                  , OUTPUT iFileHandle
                  ).

  /* Release file handle */
  RUN CloseHandle ( INPUT iFileHandle
                  , OUTPUT nReturn
                  ).

  RETURN (iFileHandle = -1).

END FUNCTION. /* isFileLocked */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isMouseOver) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION isMouseOver Procedure 
FUNCTION isMouseOver RETURNS LOGICAL
  ( phWidget AS HANDLE ) :
  /* Return whether the mouse is currently over a certain widget
  */
  DEFINE VARIABLE iMouseX AS INTEGER   NO-UNDO.
  DEFINE VARIABLE iMouseY AS INTEGER   NO-UNDO.

  IF NOT VALID-HANDLE(phWidget) THEN RETURN FALSE.
  RUN getMouseXY(INPUT phWidget:FRAME, OUTPUT iMouseX, OUTPUT iMouseY).

  RETURN (    iMouseX >= phWidget:X
          AND iMouseX <= phWidget:X + phWidget:WIDTH-PIXELS
          AND iMouseY >= phWidget:Y
          AND iMouseY <= phWidget:Y + phWidget:HEIGHT-PIXELS ).

END FUNCTION. /* isMouseOver */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isTableFilterUsed) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION isTableFilterUsed Procedure 
FUNCTION isTableFilterUsed RETURNS LOGICAL
  ( INPUT TABLE ttTableFilter ) :
  /* Returns whether any setting is used for table filtering
  */
  FIND ttTableFilter NO-ERROR.
  IF NOT AVAILABLE ttTableFilter THEN RETURN FALSE.

  /* Main toggles */
  IF   ttTableFilter.lShowNormal = FALSE
    OR ttTableFilter.lShowSchema <> LOGICAL(getRegistry('DataDigger','ShowHiddenTables'))
    OR ttTableFilter.lShowVst    = TRUE
    OR ttTableFilter.lShowSql    = TRUE
    OR ttTableFilter.lShowOther  = TRUE
    OR ttTableFilter.lShowHidden = TRUE
    OR ttTableFilter.lShowFrozen = TRUE THEN RETURN TRUE.

  /* Show these tables */
  IF   ttTableFilter.cTableNameShow <> ?
    AND ttTableFilter.cTableNameShow <> ''
    AND ttTableFilter.cTableNameShow <> '*' THEN RETURN TRUE.

  /* But hide these */
  IF   ttTableFilter.cTableNameHide <> ?
    AND ttTableFilter.cTableNameHide <> '' THEN RETURN TRUE.

  /* Show only tables that contain all of these fields */
  IF    ttTableFilter.cTableFieldShow <> ?
    AND ttTableFilter.cTableFieldShow <> ''
    AND ttTableFilter.cTableFieldShow <> '*' THEN RETURN TRUE.

  /* But hide tables that contain any of these */
  IF    ttTableFilter.cTableFieldHide <> ?
    AND ttTableFilter.cTableFieldHide <> '' THEN RETURN TRUE.

  /* else */
  RETURN FALSE.

END FUNCTION. /* isTableFilterUsed */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isValidCodePage) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION isValidCodePage Procedure 
FUNCTION isValidCodePage RETURNS LOGICAL
  (pcCodepage AS CHARACTER):
  /* Returns whether pcCodePage is valid
  */
  DEFINE VARIABLE cDummy AS LONGCHAR NO-UNDO.

  IF pcCodePage = '' THEN RETURN TRUE.

  FIX-CODEPAGE(cDummy) = pcCodepage NO-ERROR.
  RETURN NOT ERROR-STATUS:ERROR.

END FUNCTION. /* isValidCodePage */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-isWidgetChanged) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION isWidgetChanged Procedure 
FUNCTION isWidgetChanged RETURNS LOGICAL
  ( INPUT phWidget AS HANDLE ) :
  /* Returns whether a widget is changed (position or size)
  */
  DEFINE VARIABLE lChangeDetected AS LOGICAL NO-UNDO.
  DEFINE BUFFER ttWidget FOR ttWidget.

  IF NOT VALID-HANDLE(phWidget) THEN RETURN FALSE.
  {&timerStart}

  FIND ttWidget WHERE ttWidget.hWidget = phWidget NO-ERROR.
  IF NOT AVAILABLE ttWidget THEN
  DO:
    CREATE ttWidget.
    ASSIGN ttWidget.hWidget = phWidget.
  END.

  PUBLISH "debugInfo" (3, SUBSTITUTE("Widget: &1 &2", phWidget:TYPE, phWidget:NAME)).

  IF ttWidget.iPosX  <> phWidget:X
  OR ttWidget.iWidth <> phWidget:WIDTH-PIXELS THEN
  DO:
    ASSIGN
      ttWidget.iPosX  = phWidget:X
      ttWidget.iWidth = phWidget:WIDTH-PIXELS
      lChangeDetected = TRUE.
  END.

  PUBLISH "debugInfo" (2, SUBSTITUTE("  Widget changed: &1", lChangeDetected)).

  RETURN lChangeDetected.
  {&TimerStop}
END FUNCTION. /* isWidgetChanged */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-readFile) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION readFile Procedure 
FUNCTION readFile RETURNS LONGCHAR
  (pcFilename AS CHARACTER):
  /* Read contents of a file as a longchar.
  */
  DEFINE VARIABLE cContent AS LONGCHAR  NO-UNDO.
  DEFINE VARIABLE cLine    AS CHARACTER NO-UNDO.

  IF SEARCH(pcFilename) <> ? THEN
  DO:
    INPUT FROM VALUE(pcFilename).
    REPEAT:
      IMPORT UNFORMATTED cLine.
      cContent = cContent + "~n" + cLine.
    END.
    INPUT CLOSE.
  END.

  RETURN cContent.
END FUNCTION. /* readFile */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-removeConnection) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION removeConnection Procedure 
FUNCTION removeConnection RETURNS LOGICAL
  ( pcDatabase AS CHARACTER ) :
  /* Remove record from connection temp-table
  */
  DEFINE BUFFER bfDatabase FOR ttDatabase.
  FIND bfDatabase WHERE bfDatabase.cLogicalName = pcDatabase NO-ERROR.
  IF AVAILABLE bfDatabase THEN DELETE bfDatabase.
  RETURN TRUE.

END FUNCTION. /* removeConnection */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-resolveOsVars) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION resolveOsVars Procedure 
FUNCTION resolveOsVars RETURNS CHARACTER
  ( pcString AS CHARACTER ) :

  /* Return a string with OS vars resolved
  */
  DEFINE VARIABLE i AS INTEGER NO-UNDO.

  DO i = 1 TO NUM-ENTRIES(pcString,'%'):
    IF i MODULO 2 = 0
      AND OS-GETENV(ENTRY(i,pcString,'%')) <> ? THEN
      ENTRY(i,pcString,'%') = OS-GETENV(ENTRY(i,pcString,'%')).
  END.
  
  pcString = REPLACE(pcString,'%','').
  RETURN pcString.
END FUNCTION. /* resolveOsVars */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-resolveSequence) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION resolveSequence Procedure 
FUNCTION resolveSequence RETURNS CHARACTER
  ( pcString AS CHARACTER ) :
  /* Return a string where sequence nr for file is resolved
  */
  DEFINE VARIABLE iFileNr    AS INTEGER   NO-UNDO.
  DEFINE VARIABLE cSeqMask   AS CHARACTER NO-UNDO .
  DEFINE VARIABLE cSeqFormat AS CHARACTER NO-UNDO .
  DEFINE VARIABLE cFileName  AS CHARACTER NO-UNDO.

  cFileName = pcString.

  /* User can specify a sequence for the file. The length of
   * the tag sets the format: <###> translates to a 3-digit nr
   * Special case is <#> which translates to no leading zeros
   */
  IF    INDEX(cFileName,'<#') > 0
    AND index(cFileName,'#>') > 0 THEN
  DO:
    cSeqMask = SUBSTRING(cFileName,INDEX(cFileName,'<#')). /* <#####>tralalala */
    cSeqMask = SUBSTRING(cSeqMask,1,INDEX(cSeqMask,'>')). /* <#####> */
    cSeqFormat = TRIM(cSeqMask,'<>'). /* ##### */
    cSeqFormat = REPLACE(cSeqFormat,'#','9').
    IF cSeqFormat = '9' THEN cSeqFormat = '>>>>>>>>>9'.

    setFileNr:
    REPEAT:
      iFileNr = iFileNr + 1.
      IF SEARCH(REPLACE(cFileName,cSeqMask,TRIM(STRING(iFileNr,cSeqFormat)))) = ? THEN
      DO:
        cFileName = REPLACE(cFileName,cSeqMask,TRIM(STRING(iFileNr,cSeqFormat))).
        LEAVE setFileNr.
      END.
    END.
  END.

  RETURN cFileName.

END FUNCTION. /* resolveSequence */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setColor) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION setColor Procedure 
FUNCTION setColor RETURNS INTEGER
  ( pcName  AS CHARACTER 
  , piColor AS INTEGER) :
  /* Set color nr in the color tt
   */
  DEFINE BUFFER bColor FOR ttColor.

  FIND bColor WHERE bColor.cName = pcName NO-ERROR.
  IF NOT AVAILABLE bColor THEN 
  DO:
    CREATE bColor.
    ASSIGN bColor.cName = pcName.
  END.

  /* Set to default value from settings */
  IF piColor = ? THEN
  DO:
    piColor = INTEGER(getRegistry('DataDigger:Colors', pcName)) NO-ERROR.
    IF ERROR-STATUS:ERROR THEN piColor = ?.
  END.
  
  bColor.iColor = piColor.
  RETURN bColor.iColor.

END FUNCTION. /* setColor */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setColumnWidthList) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION setColumnWidthList Procedure 
FUNCTION setColumnWidthList RETURNS LOGICAL
  ( INPUT phBrowse    AS HANDLE
  , INPUT pcWidthList AS CHARACTER):
  /* Set all specified columns in pcWidthList to a specified width
  */
  DEFINE VARIABLE cColumnName  AS CHARACTER NO-UNDO.
  DEFINE VARIABLE cListItem    AS CHARACTER NO-UNDO.
  DEFINE VARIABLE hColumn      AS HANDLE    NO-UNDO.
  DEFINE VARIABLE iColumnWidth AS INTEGER   NO-UNDO.
  DEFINE VARIABLE i            AS INTEGER   NO-UNDO.
  DEFINE VARIABLE j            AS INTEGER   NO-UNDO.

  DO i = 1 TO NUM-ENTRIES(pcWidthList):
    cListItem    = ENTRY(i,pcWidthList).
    cColumnName  = ENTRY(1,cListItem,':') NO-ERROR.
    iColumnWidth = INTEGER(ENTRY(2,cListItem,':')) NO-ERROR.

    DO j = 1 TO phBrowse:NUM-COLUMNS:
      hColumn = phBrowse:GET-BROWSE-COLUMN(j).
      IF hColumn:NAME = cColumnName THEN
        hColumn:WIDTH-PIXELS = iColumnWidth.
    END. /* j */
  END. /* i */

  RETURN TRUE.
END FUNCTION. /* setColumnWidthList */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setLinkInfo) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION setLinkInfo Procedure 
FUNCTION setLinkInfo RETURNS LOGICAL
  ( INPUT pcFieldName AS CHARACTER
  , INPUT pcValue     AS CHARACTER
  ):
  /* Save name/value of a field.
  */
  DEFINE BUFFER bLinkInfo FOR ttLinkInfo.
  {&timerStart}

  PUBLISH "debugInfo" (2, SUBSTITUTE("Set linkinfo for field &1 to &2", pcFieldName, pcValue)).

  FIND bLinkInfo WHERE bLinkInfo.cField = pcFieldName NO-ERROR.
  IF NOT AVAILABLE bLinkInfo THEN
  DO:
    CREATE bLinkInfo.
    ASSIGN bLinkInfo.cField = pcFieldName.
  END.

  bLinkInfo.cValue = TRIM(pcValue).

  RETURN TRUE.   /* Function return value. */
  {&timerStop}

END FUNCTION. /* setLinkInfo */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF

&IF DEFINED(EXCLUDE-setRegistry) = 0 &THEN

&ANALYZE-SUSPEND _UIB-CODE-BLOCK _FUNCTION setRegistry Procedure 
FUNCTION setRegistry RETURNS CHARACTER
  ( pcSection AS CHARACTER
  , pcKey     AS CHARACTER
  , pcValue   AS CHARACTER
  ) :
  /* Set a value in the registry.
  */
  {&timerStart}
  DEFINE BUFFER bfConfig FOR ttConfig.

  FIND bfConfig
    WHERE bfConfig.cSection = pcSection
      AND bfConfig.cSetting = pcKey NO-ERROR.

  IF NOT AVAILABLE bfConfig THEN
  DO:
    CREATE bfConfig.
    ASSIGN
      bfConfig.cSection = pcSection
      bfConfig.cSetting = pcKey.
  END.

  IF pcValue = ? OR TRIM(pcValue) = '' THEN
    DELETE bfConfig.
  ELSE
    ASSIGN
      bfConfig.lDirty = bfConfig.lDirty OR (bfConfig.cValue <> pcValue)
      bfConfig.lUser  = TRUE
      bfConfig.cValue = pcValue.

  RETURN "". /* Function return value. */
  {&timerStop}

END FUNCTION. /* setRegistry */

/* _UIB-CODE-BLOCK-END */
&ANALYZE-RESUME

&ENDIF
