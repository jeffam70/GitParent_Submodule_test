unit Main;

{ SX_TESTER_AS_PROGRAMMER BUILDS: To compile a special version of Propeller.exe for Parallax's SX Tester As A Programmer (Manufacturing use), see Propeller.dpr. }

{ EUREKALOG BUILDS: To compile the Propeller.exe with exception logging, see Propeller.dpr.}



//{$DEFINE LoadDirList}  {Uncomment this if Integrated Explorer's directory list should be loaded upon startup, otherwise comment it out to load the directory list later}


{This is the Propeller Tool software.}

{Note: Editor.EditSheet[idx].CustomTag1 is the current ViewMode of that tab.}
{      Editor.EditSheet[idx].CustomData1 is a reference to the Source Information record, if any, for that tab.}
{      Editor.EditSheet[idx].CustomData2 is a reference to the TFileStream of binary file data, if any, for that tab (used for opening binary files in hex view).}
{      Editor.EditSheet[idx].CustomString1 is the path of the last archived-project saved for that tab's object}
{      Editor.EditSheet[idx].CustomString2 is the relative path of the auto-recover file for that tab's object}

{Add Split Editor}
{Add Contents... and Index...}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, ComCtrls, ExtCtrls, PEditor, StdCtrls, ShlObj, ShFolder, Buttons,
  EasyEditor, EasyEditSource, EasyStrings, EasyTab, Math, StrUtils, ShellAPI, About, Global, Chars, Serial, Info, ImgList, Dlgs, Registry, PTRegistry, ZipForge,
  EasyClasses, FileCtrl, DateUtils, Compiler, Paths, mmsystem {$IFDEF EUREKALOG}, ExceptionLog{$ENDIF}{, debug };

type
  EFontResource = class(Exception); {Font Resource exception}
  ETryPermanent = class(Exception); {Font Installation exception (indicates should try permanent installation}
  ETryTemporary = class(Exception); {Font Installation exception (indicates should try temporary installation}

  {Note, these are defined in the order in which they appear on the view mode control bar, see ViewModePanelCreated().  If they
  are changed in any way, update ViewModeText constant array.}
  TViewMode = (vmFull, vmCondensed, vmSummary, vmDocumentation, vmStandard);    {vmStandard is used by non-Propeller Source}

  TMainForm = class(TForm)
    MainMenu: TMainMenu;
    FileMenu: TMenuItem;
    NewItem: TMenuItem;
    OpenItem: TMenuItem;
    OpenFromItem: TMenuItem;
    SaveItem: TMenuItem;
    SaveAsItem: TMenuItem;
    SaveToItem: TMenuItem;
    CloseItem: TMenuItem;
    CloseAllItem: TMenuItem;
    Break01: TMenuItem;
    SelectTopFileItem: TMenuItem;
    Break03: TMenuItem;
    HideExplorerItem: TMenuItem;
    Break04: TMenuItem;
    ExitItem: TMenuItem;
    Break05: TMenuItem;
    PrintItem: TMenuItem;
    EditMenu: TMenuItem;
    Break09: TMenuItem;
    GoToBookmarkItem: TMenuItem;
    B1: TMenuItem;
    B2: TMenuItem;
    B3: TMenuItem;
    B4: TMenuItem;
    B5: TMenuItem;
    B6: TMenuItem;
    B7: TMenuItem;
    B8: TMenuItem;
    B9: TMenuItem;
    UndoItem: TMenuItem;
    Break07: TMenuItem;
    PrintPreviewItem: TMenuItem;
    RedoItem: TMenuItem;
    Break08: TMenuItem;
    CutItem: TMenuItem;
    CopyItem: TMenuItem;
    PasteItem: TMenuItem;
    SelectAllItem: TMenuItem;
    FindReplaceItem: TMenuItem;
    FindNextItem: TMenuItem;
    ReplaceItem: TMenuItem;
    Break10: TMenuItem;
    SplitEditorItem: TMenuItem;
    Break11: TMenuItem;
    PreferencesItem: TMenuItem;
    Break12: TMenuItem;
    TextBiggerItem: TMenuItem;
    TextSmallerItem: TMenuItem;
    RunMenu: TMenuItem;
    CompileTopViewInfoItem: TMenuItem;
    CompileTopLoadRAMRunItem: TMenuItem;
    CompileTopProgramEEPROMRunItem: TMenuItem;
    CompileCurrentViewInfoItem: TMenuItem;
    CompileCurrentLoadRAMRunItem: TMenuItem;
    CompileCurrentProgramEEPROMRunItem: TMenuItem;
    Break13: TMenuItem;
    IdentifyHardwareItem: TMenuItem;
    HelpMenu: TMenuItem;
    AboutItem: TMenuItem;
    Break19: TMenuItem;
    ViewParallaxWebsiteItem: TMenuItem;
    EmailParallaxSupportItem: TMenuItem;
    Break18: TMenuItem;
    PropellerToolItem: TMenuItem;
    AssemblyLanguageItem: TMenuItem;
    Break06: TMenuItem;
    Break17: TMenuItem;
    ViewCharacterChartItem: TMenuItem;
    CompileTopItem: TMenuItem;
    CompileCurrentItem: TMenuItem;
    ObjTreeViewImages: TImageList;
    SaveAllItem: TMenuItem;
    CompileCurrentUpdateStatusItem: TMenuItem;
    CompileTopUpdateStatusItem: TMenuItem;
    Break02: TMenuItem;
    ArchiveItem: TMenuItem;
    ArchiveProjectItem: TMenuItem;
    ArchiveProjectPlusPropellerIDEItem: TMenuItem;
    SpinLanguageItem: TMenuItem;
    ExampleProjectsItem: TMenuItem;
    QuickReferenceItem: TMenuItem;
    PropellerManualItem: TMenuItem;
    DemoBoardSchematicItem: TMenuItem;
    Break15: TMenuItem;
    VisitPropellerObjectExchangeItem: TMenuItem;
    PropellerDatasheetItem: TMenuItem;
    PropellerEducationKitLabsItem: TMenuItem;
    ViewPropeller1Forum: TMenuItem;
    Break14: TMenuItem;
    ParallaxSerialTerminalItem: TMenuItem;
    ViewPropeller2Forum: TMenuItem;
    ViewPropeller2Website: TMenuItem;
    QuickStartSchematicItem: TMenuItem;
    NewFromP1TemplateItem: TMenuItem;
    NewFromP2TemplateItem: TMenuItem;
    Break16: TMenuItem;
    Propeller2HardwareDocumentation1: TMenuItem;
    Propeller2AssemblyInstructions1: TMenuItem;
    Propeller2SpinLanguage1: TMenuItem;
    Propeller2TAQOZBootFirmware1: TMenuItem;
    Propeller2P2ESBoard1: TMenuItem;
    P2ESBoardSchematic1: TMenuItem;
    Break20: TMenuItem;
    EnableDebugItem: TMenuItem;
    procedure DefaultHandler(var Message); override;
    function  HiddenWindowMessageHandler(var Message: TMessage): Boolean;
    procedure PropIDEMessageHandler(var Message: TCMEstablishCommunication);
    procedure WMCopyDataMessageHandler(var Message: TMessage);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FinalInit;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FileMenuClick(Sender: TObject);
    procedure FileMenuItemClick(Sender: TObject);
    procedure EditMenuItemClick(Sender: TObject);
    procedure RunMenuClick(Sender: TObject);
    procedure RunMenuItemClick(Sender: TObject);
    procedure HelpMenuClick(Sender: TObject);
    procedure HelpMenuItemClick(Sender: TObject);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure EditSelectAll(ID: Integer);
    procedure EditTabNewFromTemplateItemClick(ID: Integer);
    procedure EditTabTopFileItemClick(ID: Integer);
    procedure EditTabArchiveItemClick(ID: Integer);
    procedure FileListTopFileItemClick(ID: Integer);
    procedure ViewModePanelCreated(Sender: TObject);
    procedure ViewModePanelAlign(Control: TControl; var NewLeft, NewTop, NewWidth, NewHeight: Integer; var AlignRect: TRect; AlignInfo: TAlignInfo);
    function  ViewModePanelIsActive(Sender: TPRadioGroup; Parent: TWinControl): Boolean;
    procedure ObjectViewAlign(Control: TControl; var NewLeft, NewTop, NewWidth, NewHeight: Integer; var AlignRect: TRect; AlignInfo: TAlignInfo);
    procedure ObjectClicked(Sender: TObjectTreeView; Node: TTreeNode; Button: TMouseButton);
    procedure ObjectDoubleClicked(Sender: TObjectTreeView; Node: TTreeNode; Hit: THitTests);
    procedure ObjectSelected(Sender: TObjectTreeView; Node: TTreeNode);
    procedure ParallaxLinkClick(Index: Integer);
    procedure PageAddedDeleted(Sender: TObject; Idx: Integer; PageState: TPageState; Action: TPageAction);
    procedure EnableDisablePageOptions(PageState: TPageState);
    function  CanFindReplace: Boolean;
    procedure FindReplaceShow(Sender: TObject);
    function  CanSourceChange(Operation: TEasyOperation; X, Y, State: Integer; Data: Pointer): Boolean;
    procedure EditSourceChanged(Sender: TObject; Index: Integer; EditorState: TEditorState);
    procedure EditStateChanged(Sender: TObject; Index: Integer; EditorState: TEditorState; var HighlightBgColor, HighlightFtColor: TColor; var HighlightPeriod: Integer);
    procedure EditModeChanged(Sender: TObject; Idx: Integer; EditMode: TEasyEditMode; var HighlightBgColor, HighlightFtColor: TColor; var HighlightPeriod: Integer);
    procedure EditDoubleClicked(Sender: TObject; GutterClicked, CollapseMarkClicked: Boolean; var AbortSelection: Boolean);
    procedure EnableDisableBookmarkItems(Sender: TObject; BookmarkState: Integer);
    procedure DrawTabName(Sender: TMultiViewPageControl; TabIdx: Integer; Canvas: TCanvas; Rect: TRect; Active: Boolean);
    procedure TabHint(Sender: TMultiViewPageControl; TabIdx: Integer; var HintText: String; var MaxWidth: Integer; var Center: Boolean);
    procedure TabSwitched(Sender: TObject; Index: Integer; Filename: String; Tabname: String);
    procedure SetTabName(Sender: TObject; Idx: Integer; var Tabname: string);
    procedure SetTitleBar(Tabname: String);
    procedure SplitEditor1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    function  ViewModeChanged(Sender: TPRadioGroup; PreviousSelection, CurrentSelection: Cardinal): Boolean;
    procedure ExplorerSized(Sender: TObject; Width: Integer; SplitPos: Integer; ExplorerSplitPos: Integer);
    procedure BeforeFileEvent(Sender: TObject; Idx: Integer; var Action: TFileAction; NewFilename: String);
    procedure AfterFileEvent(Sender: TObject; Idx: Integer; Action: TFileAction; PrevFileName: String);
    procedure SetEditTabs(Idx: Integer; AllowTabs: Boolean; UseStandardTabStops: Boolean);
    procedure TabKeyPressed(Sender: TObject; PageIndex: Integer; Position: TPoint; TabStopList: TTabStopList; ParserState: Word);
    procedure ShowHintOnStatusBar(Sender: TObject);
    procedure SetTopFile(Filename: String);
    procedure Archive(ProjectPlusIDE: Boolean);
    procedure MakeOpenDialogSelect(Sender: TObject);
    procedure FileListed(Sender: TObject; Filename: String; var Bold: Boolean);
    procedure FileListContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure EditTabContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure DoCustomDraw(Sender: TObject; Canvas: TCanvas; const Rect: TRect; Line, Char: integer; const S: TEasyString; DrawStates: TEasyDrawStates; LineState: Integer; var Handled: Boolean);
    procedure UpdateBlockIndentionsVisible;
    procedure UpdateBookmarksVisible;
    procedure UpdateLineNumbersVisible;
    function  ReadPortRulesPreference(Sender: TObject; Default: Boolean): String;
    procedure WritePortRulesPreference(Sender: TObject; PortRules: String);
    procedure LoadParserRules;
    procedure EnableDebugItemClick(Sender: TObject);
  private
    { Private declarations }
    procedure CreateNewFromTemplate(PropModel: TPropModel);
    procedure ShowHideExplorer;
    procedure AddFileToHistory(Filename: String);
//!!    procedure DeleteFileFromHistory(Filename: String);
    procedure UpdateMenuHistory(Enabled: Boolean);
    procedure OpenFromHistory(Sender: TObject);
    procedure AddDefaultFavorite(Path, Caption: String; UniqueList: TStrings);
    procedure OpenFromSaveTo(MenuItem: TMenuItem; Open: Boolean);
    procedure FontSized(Sender: TObject; Size: Integer);
    procedure CursorPositionChanged(Sender: TObject; EditPos: TPoint; SourcePos: Integer);
    function  ValidateOrInstallFont(var FaceName: String): Boolean;
    procedure ScheduleFutureAction(action: TActionType; Sender: TObject = nil; Flag: Boolean = False);
  public
    { Public declarations }
    procedure OpenAutoRecover;
    procedure SaveAutoRecover;
    procedure ClearAutoRecover(TabIdx: Integer);
    function  SetView(Mode: TViewMode): Boolean;
(*    procedure MoveItItemClick(Sender: TObject);*)
  end;

  TFontInstallType = (fiNone, fiPublic, fiPrivate);

  {Define block-group record type.  Used by DoCustomDraw to maintain conditional-block information for block-group line drawing}
  TBlockGroup = record
    ID         : TokenStyle; {Token ID of this block group}
    Complete   : Boolean;    {False = end not yet found, True = end found (group is complete)}
    RowStart   : Cardinal;   {The line where block-group begins}
    RowEnd     : Cardinal;   {The line where block-group ends}
    EndIsEIEWU : Boolean;    {False = normal end, True = end is an ELSEIF, ELSE, WHILE or UNTIL}
    Column     : Cardinal;   {The column of block-group}
    CaseLevel  : Cardinal;   {0 = not Case type; 1+ = Case type and level of indention within it}
  end;

  {Define Line Token type.  Used by DoCustomDraw to store info about token on a line}
  TLineToken = record
    Idx : Integer;    {Index of start of token on line; 0 if none}
    ID  : TokenStyle; {ID of this token; 0 if none}
  end;

  {Define Line Specs type.  Used by DoCustomDraw to store specs about currently parsed line.}
  TLineSpecs = record
    IsPubPri : Boolean;                   {Indicates line is/isn't in PUB or PRI block}
    Token    : array[1..3] of TLineToken; {Elements: 1 = first non-whitespace char/token, 2 = first executable token,}
  end;                                    {          3 = second executable token (after ':', if any)}

  TCDState = record
    BlockColor : TColor;    {Color of blocks background}
    NextLine   : Integer;   {The next line the Custom Draw routine expects to be requested of it}
    BlockEnd   : Integer;   {The last line of the block currently being drawn}
  end;

  {Support routines}
  {---External application search/show/launch routines---}
  procedure LaunchOrShowApp(Title: String; Path: String = ''; MainWin: TForm = nil);  {Call this to launch or show an external application}
  function AppFound: Boolean;                                                         {Used by LaunchOrShowApp}
  function IsApp(Handle: HWND; Param: Integer): Boolean; stdcall;                     {Used by LaunchOrShowApp; This is a callback function; STDCALL must be given or the callback parameters will be mixed up and Handle will be invalid}
  function ShowApp(Handle: HWND): Boolean;                                            {Used by LaunchOrShowApp}

var
  MainForm              : TMainForm;
  tc                    : TTimeCaps;                                                  {Windows TimeCaps structure}
  tr                    : Boolean;                                                    {True if time base accuracy adjustment successful, False otherwise}
  OpenReadOnly          : Boolean = False;
  OldIndent             : Integer;
  sbInfoTextPos         : Integer;                                                    {Index of panel on status bar for Info Text}
  sbCompiledTextPos     : Integer;                                                    {Index of panel on status bar for Compiled Text}
  sbStatusTextPos       : Integer;                                                    {Index of panel on status bar for general status text}
  etNewFromP1Template   : Integer;                                                    {ID of Edit Tab's New (From P1 Template) menu item}
  etNewFromP2Template   : Integer;                                                    {ID of Edit Tab's New (From P2 Template) menu item}
  etTopFile             : Integer;                                                    {ID of Edit Tab's Top File menu item}
  etArchive             : Integer;                                                    {ID of Edit Tab's Archive menu item}
  flTopFile             : Integer;                                                    {ID of File List's Top File menu item}
  OldOnShow             : TNotifyEvent;
  ProcessingObjClick    : Boolean;                                                    {Flag to ignore object view clicks while processing others}
  BG                    : array of TBlockGroup;                                       {Dynamically sized array used to record IF, ELSEIF, ELSE, REPEAT and CASE block-group metrics (for drawing grouping lines)}
  CDState               : TCDState;                                                   {Used by DoCustomDraw to determine when new block-group structure is needed}
  Initializing          : Boolean;                                                    {True = application initializing, False = application running}
  AppTitle              : String;                                                     {Title of external application window (for use by "App" support routines)}
  AppPath               : String;                                                     {Path to executable of external application window (for use by "App" support routines)}
  AppHandle             : HWND;                                                       {Handle to open external application (for use by "App" support routines)}
  AppStr                : PChar;                                                      {String for finding external application window (for use by "App" support routines)}

const
  FontName     = 'Parallax';                                                          {The public font's face name}
  FontPrivName = 'Parallxx';                                                          {The private font's face name}
  PrivNameRepl : array[0..1] of WideString = ('ParallaxRegular', 'ParallxxRegular');  {(0) = public font's face/style, (1) = private font's face/style (what public face/style is changed to when its made private)}
  FontRegName  = 'Parallax (TrueType)';                                               {The font's name in registry}
  FontFile     = 'Parallax.ttf';                                                      {The font's file name}
  FontID        = 1;

  {Parser Rules resource and (optional) file IDs}
  P1SyntaxRulesID = 1;
  P2SyntaxRulesID = 2;
  P1ParserRulesFile = 'P1ParserRules.xs';
  P2ParserRulesFile = 'P2ParserRules.xs';

  ViewModeText : array[low(TViewMode)..high(TViewMode)] of string = ('Full Source.',
                                                                     'Condensed.  Escape key reverts back to Full Source view.',
                                                                     'Summary.  Escape key reverts back to Full Source view.',
                                                                     'Documentation.  Escape key reverts back to Full Source view.',
                                                                     'Standard');    {vmStandard is used by non-Propeller Source}

  {Define Method set (set of all Parser States that are in PUB or PRI blocks)}
  Method : set of ParserState = [P___..sIBO];


implementation

uses Prefs, PortList, Progress, DebugUnit;

{$R *.DFM}
{$R StringResource.RES}
{$R FontResource.RES}

{oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo}
{oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo}
{ooooooooooooooooooooooooooooo Support Routines ooooooooooooooooooooooooooooooo}
{oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo}
{oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo}

procedure LaunchOrShowApp(Title: String; Path: String = ''; MainWin: TForm = nil);
{Launch external App (Path) or show App (Title) if it already exists.
 Path is optional; if left off, only existing App is shown (no new instance is launched).}
begin
  AppTitle := Title;                                                            {Remember App title (in global AppTitle)}
  if not AppFound and (Path <> '') and (assigned(MainWin)) then
    ShellExecute(MainWin.Handle, nil, pchar(Path), nil, nil, SW_SHOWNORMAL);    {Find existing App and show it; if it doesn't exist, launch it if we know the path}
end;

{------------------------------------------------------------------------------}

function AppFound: Boolean;
{Initiate search for an existing App and return True if found, False otherwise.}
begin
  Result := True;                                                               {Assume we've already found it}
  if not ShowApp(AppHandle) then                                                {App not already found?}
    begin
    EnumDesktopWindows(0, @IsApp, 0);                                           {  Start window enumeration process}
    Result := AppHandle <> INVALID_HANDLE_VALUE;                                {  Return result; when enumeration is complete, AppHandle is valid if existing application found and shown}
    end;
end;

{------------------------------------------------------------------------------}

function IsApp(Handle: HWND; Param: Integer): Boolean; stdcall;                 {NOTE: stcall MUST be given or the callback parameters will be mixed up and Handle will be invalid}
{Iteratively receive handles to all open windows looking for App (global AppTitle).  AppFound initiates the window enumeration process which causes Windows to callback to this
 function (IsApp) repeatedly passing it window handles until no more are left, or until this function returns False to Windows.}
begin
  Result := not ShowApp(Handle);                                                {Return True (continue enumerating) or False (stop enumerating)}
end;

{------------------------------------------------------------------------------}

function ShowApp(Handle: HWND): Boolean;
{If Handle is App window (global AppTitle), show it and return True (also store handle in global AppHandle), return False otherwise.}
begin
  Result := False;                                                              {Assume not serial terminal window}
  if GetWindowText(Handle, AppStr, length(AppTitle)+1) > 0 then                 {Get window text}
    begin  {Window has text}
    if strcomp(AppStr, pchar(AppTitle)) = 0 then                                {  If window has text and it is the App}
      begin {Found App}
      Result := True;                                                           {    Indicate that we found it}
      AppHandle := GetWindow(Handle, GW_OWNER);                                 {    Remember handle of window's owner, if any}
      if AppHandle = 0 then AppHandle := Handle;                                {    Otherwise, remember window's handle}
      ShowWindow(AppHandle, SW_SHOWNOACTIVATE);                                 {    Show window}
      SetForegroundWindow(AppHandle);                                           {    Bring to front}
      end;
    end;
  if not Result then AppHandle := INVALID_HANDLE_VALUE;                         {Not App?  Invalidate AppHandle}
end;

{oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo}
{oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo}
{oooooooooooooooooooooooooooooo Event Routines oooooooooooooooooooooooooooooooo}
{oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo}
{oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo}

procedure TMainForm.DefaultHandler(var Message);
{Handle our custom messages}
begin
  if TMessage(Message).Msg <> UserActionMsg then
    inherited                                                                     {Not custom message?  Pass it on}
  else
    begin
//!!    SendDebugMessage('Event: running scheduled user action', True);
    case TActionType(TMessage(Message).WParam) of
      atRunMenuItem : RunMenuItemClick(ScheduledAction.Sender);                   {Call Run menu item click hander}
      atArchive     : Archive(ScheduledAction.Flag);                              {Call archiver}
      atCloseApp    : Close;                                                      {Call Close handler}
    end; {case}
    end;
end;

{------------------------------------------------------------------------------}

function TMainForm.HiddenWindowMessageHandler(var Message: TMessage): Boolean;
{Message handler that receives this application's Hidden Window messages first.  This is part of TMainForm only because it needed
to be a method rather than a regular procedure for Application.HookMainWindow method call.  We trap our custom PropIDEMsg message here, and the
WM_COPYDATA message, and dispatch them to the PropIDEMessageHandler and WMCopyDataMessageHandler, respectively.  Any other messages are sent
to the inherited handler.}
begin
  Result := ((Message.Msg = PropIDEMsg) or (Message.Msg = WM_COPYDATA));          {Check for our custom message}
  if not Result then exit;                                                        {Not custom message?  Exit}
  if (Message.Msg = PropIDEMsg) then                                              {This is our custom PropIDE message}
    PropIDEMessageHandler(TCMEstablishCommunication(Message))                     {  Pass the message to PropIDEMessageHandler procedure.}
  else if (Message.Msg = WM_COPYDATA) then                                        {This is a WM_COPYDATA message}
    WMCopyDataMessageHandler(Message);                                            {  Pass the message to WMCopyDataMessageHandler procedure.}
end;

{------------------------------------------------------------------------------}

procedure TMainForm.PropIDEMessageHandler(var Message: TCMEstablishCommunication);
{Custom message handler for the Establish Communication message.  This routine processes incomming PropIDEMsg messages
that are used by other instances of the Propeller IDE to establish communication for the purpose of maintaining
only one instance of a particular version at once, and passing a file list to an existing instance, if necessary.

NOTES: Application.Handle is the handle of the "Hidden" window which actually ownes the Main Window in Delphi Applications.
It is exactly the same handle as what is retrieved by GetWindow(MainForm.Handle, GW_OWNER).  The Hidden window handle
needs to be used for the PropIDEMessageHandler since it is the responsibility of the second Propeller IDE instance to
choose to make the first instance application visible and in the foreground of all the windows... and doing so on the
Main window instead of the Hidden window causes the OS to think the application is still minimized, thus having the side
effect of disabling the Minimize function of the titlebar icon.}

var
  OtherInstance : ^HWnd;
begin
  if (Message.Sender <> Application.Handle) then
    begin {This message is from another Propeller IDE}
    if (Message.Code = 0) then  {This is a request for communication (requesting Applicaton's Hidden Window Handle}
      begin
      if FirstInstance then
        begin  {As long as we're the first instance...}
        GetMem(OtherInstance, sizeof(HWnd));                                        {Store other instance's handle in list}
        OtherInstance^ := Message.Sender;
        OtherInstanceHandles.Add(OtherInstance);
        SendMessage(Message.Sender, PropIDEMsg, Application.Handle, GetBCDVersion); {Respond with our handle and BCD version number}
        end;
      end
    else
      begin                     {This is a response indicating the version of the IDE responding.}
      if Message.Code = GetBCDVersion then FirstInstanceHandle := Message.Sender;  {If response was from Propeller IDE of the same version, that is our first instance}
      end;
    end;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.WMCopyDataMessageHandler(var Message: TMessage);
{CopyData Message handler.}
var
  Idx : Integer;
begin
  {Search through OtherInstanceHandle records to see if we know who this message came from}
  Idx := 0;
  while (Idx < OtherInstanceHandles.Count) and (Message.WParam <> HWnd(OtherInstanceHandles.Items[Idx]^)) do inc(Idx);
  if Idx <> OtherInstanceHandles.Count then
    begin  {CopyData message came from a Propeller IDE that recently started communicating with us.  Open the file it requested.}
    if Editor.Open(StrPas(PChar(PCopyDataStruct(Message.LParam)^.lpData)), '', nil, True, False) > -1 then
      begin {File successfully opened}
      FreeMem(OtherInstanceHandles.Items[Idx]);   {Free memory used to store other instance handle}
      OtherInstanceHandles.Delete(Idx);           {Delete record of other instance handle; we only accept one message per instance at a time}
      Message.Result := ord(True);                {Return true}
      end
    else
      begin {Error opening file, clear record of all other instance handles with pending CopyData messages}
      for Idx := 0 to OtherInstanceHandles.Count-1 do FreeMem(OtherInstanceHandles.Items[Idx]);
      OtherInstanceHandles.Clear;
      ReleaseSemaphore(ScheduleCopyData,1,nil);   {Release the ScheduleCopyData lock in case the calling process already terminated}
      Message.Result := ord(False);               {Return false}
      end;
    end;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.FormCreate(Sender: TObject);
begin
  {Initialize Error Logger if necessary}
  {$IFDEF EUREKALOG}
  if IsEurekaLogInstalled then
    CurrentEurekaLogOptions.AppName := PropIDEName;
  {$ENDIF}

  {Initialize menu item hints}
  Application.OnHint := ShowHintOnStatusBar;

  {Read preferences from registry}
  if not LoadPrefsFromRegistry then
    UpgradePrefsFromRegistry;     {Prefs didn't exist, look for previous version prefs}

  {Set default library path if necessary}
  if (CPrefs[LibraryPaths].SValue = '') and SafeDirectoryExists(UDPath+'Library\') then
    begin
    CPrefs[LibraryPaths].SValue := UDPath+'Library\';
    PrefsHaveChanged := True;
    end;

  {Set Library Folder object's Paths property}
  LibraryFolder.Paths := CPrefs[LibraryPaths].SValue;

  {Set default New P1 File Template if necessary}
  if (CPrefs[NewP1FileTemplate].SValue = '') and SafeFileExists(UDPath+'Templates\Simple_Spin_Template.spin') then
    begin
    CPrefs[NewP1FileTemplate].SValue := UDPath+'Templates\Simple_Spin_Template.spin';
    PrefsHaveChanged := True;
    end;
  {Set default New P2 File Template if necessary}
  if (CPrefs[NewP2FileTemplate].SValue = '') and SafeFileExists(UDPath+'Templates\Simple_Spin2_Template.spin2') then
    begin
    CPrefs[NewP2FileTemplate].SValue := UDPath+'Templates\Simple_Spin2_Template.spin2';
    PrefsHaveChanged := True;
    end;

  {Check File Associations}
  CheckFileAssociationsInRegistry(False);

  {Install custom message handler into application's hidden form message handler}
  Application.HookMainWindow(HiddenWindowMessageHandler);

  {Initialize serial port list object (setting event handler causes manual trigger of that event)}
  COM.OnReadPortRules := ReadPortRulesPreference;
  COM.OnWritePortRules := WritePortRulesPreference;

  {Get command line parameters}
  CheckCommandLine;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  Application.UnHookMainWindow(HiddenWindowMessageHandler);
end;

{------------------------------------------------------------------------------}

procedure TMainForm.FormShow(Sender: TObject);
{Instantiate Editor Class and set up preferences}
begin
  {Validate/Perform font installation}
  IDEFont := FontName;
  if not ValidateOrInstallFont(IDEFont) then
    begin
    MessageBeep(MB_ICONERROR);
    messagedlg('Unable to install Parallax font.  The Parallax font is required to properly view source code with diagrams.  Please run this software, at least once, while logged on as a user with Administrative rights in order to install the Parallax font.', mtWarning, [mbOk], 0);
    end;
  {Set PortList Device Name}
  PortListForm.DeviceName := 'Propeller';
  {Create Editor with 2 syntax parsers (for P1 and P2}
{$IFDEF LoadDirList}
  Editor := TEditor.Create(Self, 2, True);
{$ELSE}
  Editor := TEditor.Create(Self, 2, False);
{$ENDIF}  
  Editor.OnAfterFile := AfterFileEvent;
  Editor.OnAfterPage := PageAddedDeleted;
  Editor.OnBeforeFile := BeforeFileEvent;
  Editor.OnBeforeSourceChange := CanSourceChange;
  Editor.OnBookmark := EnableDisableBookmarkItems;
  Editor.OnEditCustomDraw := DoCustomDraw;
  Editor.OnDblClick := EditDoubleClicked;
  Editor.OnDrawEditTab := DrawTabName;
  Editor.OnEdit := EditSourceChanged;
  Editor.OnEditStateChanged := EditStateChanged;
  Editor.OnEditMode := EditModeChanged;
  Editor.OnExplorerSize := ExplorerSized;
  Editor.OnInsertTab := TabKeyPressed;
//  Editor.OnKeyDown := FormKeyDown;  //Removed 09-17-2006 because Main Form has Key Preview Set anyway
  Editor.OnName := SetTabName;
  Editor.OnPositionChange := CursorPositionChanged;
  Editor.OnTabSelect := TabSwitched;
  Editor.OnTabHint := TabHint;
  PageAddedDeleted(Editor, 0, psSome, paAdd);                                   {Force first call since page already created}
  Editor.OnControlPanelCreate := ViewModePanelCreated;
  Editor.FindReplace.AllowBlankReplace := True;
  Editor.FindReplace.OnBeforeFindReplace := CanFindReplace;
  Editor.FindReplace.OnShow := FindReplaceShow;
  Editor.ActiveEdit.ShowExpandButtons := False;
  Editor.ShowTabHints := True;
  Editor.LineBreak := lbCRLF;
  Editor.AllowAutoExpand := False;                                              {Disable automatic expansion of collapsed/hidden lines based on cursor position}

  Editor.ActiveEdit.SetFocus;                                                   {Force cursor to edit control}

  Editor.FontName := IDEFont;
  Editor.FontSizes := '8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 32, 36, 42, 48, 56, 64, 72';
  Editor.FontSize := CPrefs[FontSize].IValue;
  Editor.OnFontSize := FontSized;

  Editor.TabsFont.Style := [fsBold];

  Editor.UndoAfterSave := CPrefs[UndoAfterSave].BValue;

  {Configure Compiled status pane in status bar}
  sbCompiledTextPos := Editor.StatusBar.Panels.Count-1;
  Editor.StatusBar.Panels[sbCompiledTextPos].Width := Editor.StatusBar.TextWidth('Downloaded')+14;
  Editor.StatusBar.Panels[sbCompiledTextPos].Alignment := taCenter;
  {Configure Info Text pane in status bar}
  Editor.StatusBar.Panels.Add;
  sbInfoTextPos := Editor.StatusBar.Panels.Count-1;
  Editor.StatusBar.Panels[sbInfoTextPos].Alignment := taCenter;
  Editor.StatusBar.Panels[sbInfoTextPos].AutoSize := True;
  {Configure status pane in status bar}
  Editor.StatusBar.Panels.Add;
  sbStatusTextPos := Editor.StatusBar.Panels.Count-1;

  CharChartForm.FontName := Editor.FontName;
  CharChartForm.SetFontSize(CPrefs[ChartFontSize].IValue);

  CharChartForm.SetDisplayMode(CPrefs[ChartDisplayMode].IValue);

  Editor.TabStops := CPrefs[PrefEntity(ord(CONTabs)+ord(btPUBPRI))].SValue;  {Set global tab stop settings (will be overridden locally when necessary)}

  Editor.Filters.Add(PropSrcAppTxtFilter);
  Editor.FilterIndex := 0;

  Editor.FolderHistory.Add(ExtractFileDir(Application.ExeName));

  {Get P1 and P2 syntax highlighting rules}
  LoadParserRules;

  {Position the Main, Find/Replace, Character Chart and Preferences windows}
  Editor.FindReplace.Form.DefaultMonitor := dmDesktop; {Ensure Find/Replace form can be user-positioned all over desktop}
  LoadWindowMetrics(MainForm, EditorPos); //NOTE: MainForm cannot be set below "{Configure Panels}", below,or the explorer controls will be misaligned (reason unknown)}
  LoadWindowMetrics(Editor.FindReplace.Form, FindReplacePos);
  LoadWindowMetrics(CharChartForm, CharChartPos);
  LoadWindowMetrics(Preferences, PrefsPos);
  LoadWindowMetrics(PortListForm, PortListPos);

  {Configure Panels}
  Editor.AllowAutoEditSplit := True;               {Enables top/bottom splitter-controlled mouse-drag splitting of edit control (True = default)}
  Editor.AllowAutoExplorer := True;                {Enables left splitter-controlled mouse-drag explorer pullout of editor (True = default))}
  Editor.Explorer.Visible := CPrefs[ExplorerVisible].BValue;
  Editor.Explorer.ExplorerPanelMinSize := 86;
  Editor.Explorer.ExplorerPanelSplitPos := CPrefs[ExplorerPanelSplitPos].IValue;

  ObjectView := TObjectTreeView.Create(Editor.Explorer.ExplorerPanel.Panel);
  ObjectView.Parent := Editor.Explorer.ExplorerPanel.Panel;
  ObjectView.SetBounds(0, 0, Editor.Explorer.ExplorerPanel.Panel.ClientWidth, Editor.Explorer.ExplorerPanel.Panel.ClientHeight);
  ObjectView.Align := alCustom;
  ObjectView.Visible := True;
  ObjectView.OnClick := ObjectClicked;
  ObjectView.OnDblClick := ObjectDoubleClicked;
  ObjectView.OnEnterKey := ObjectSelected;
  Editor.Explorer.ExplorerPanel.Panel.OnAlign := ObjectViewAlign;

  Editor.Explorer.ExplorerPanel.Visible := True;
  Editor.Explorer.Width := CPrefs[ExplorerWidth].IValue;
  Editor.Explorer.SplitPos := CPrefs[FileSplitPos].IValue;
  Editor.Explorer.OnListFile := FileListed;
  Editor.Explorer.OnFileListContextPopup := FileListContextPopup;

  UpdateBookmarksVisible;
  UpdateLineNumbersVisible;

  Editor.EditPopup.DeleteItemAtIdx(0);                                                                                                   {Delete the 'Go To Bookmark' item from the edit tab's shortcut menu}
  Editor.EditPopup.InsertItemNearID(True, Editor.EditPopup.IDOfCaption('Cut'), 'Select All', True, True, EditSelectAll);                 {Add Select All item}
  etNewFromP1Template := Editor.EditTabPopup.InsertItemAtIdx(1, 'New (From P1 Template)', True, True, EditTabNewFromTemplateItemClick);  {Add New (From P1 Template) item}
  etNewFromP2Template := Editor.EditTabPopup.InsertItemAtIdx(2, 'New (From P2 Template)', True, True, EditTabNewFromTemplateItemClick);  {Add New (From P2 Template) item}
  Editor.EditTabPopup.AddItem('-', True, True);                                                                                          {Add separator}
  etTopFile := Editor.EditTabPopup.AddItem('Top Object File', True, True, EditTabTopFileItemClick);                                      {Add Top Object File item}
  Editor.EditTabPopup.AddItem('-', True, True);                                                                                          {Add separator}
  etArchive := Editor.EditTabPopup.AddItem('Archive...', True, True, EditTabArchiveItemClick);                                           {Add Archive item}
  Editor.OnEditTabContextPopup := EditTabContextPopup;
  flTopFile := Editor.Explorer.FileListPopup.InsertItemNearID(False, Editor.Explorer.FileListPopup.IDOfCaption('Open'), '-', True, True);
  flTopFile := Editor.Explorer.FileListPopup.InsertItemNearID(False, flTopFile, 'Top Object File', True, True, FileListTopFileItemClick);

  Editor.SaveNewAsUnicode := False;  {Set editor to use ASCII format (when possible) for saving new files}

  Editor.CreateBackups := False;

  {Preserve default Gutter Indent setting}
  OldIndent := Editor.ActiveEdit.Gutter.Indent;

  {Set up Find/Replace Dialog history}
  LoadFindReplaceHistory;

  {Update Menu History}
  UpdateMenuHistory(True);

  {$IFDEF SX_TESTER_AS_PROGRAMMER}
  CompileTopLoadRamRunItem.Enabled := False;
  CompileCurrentLoadRamRunItem.Enabled := False;
  {$ENDIF}
end;

{------------------------------------------------------------------------------}

procedure TMainForm.FinalInit;
{Perform final initialization routines}
var
  Dir       : String;
begin
  {Determine initial directory}
  Dir := ExtractFilePath(application.exename); {Initialize to fail-safe directory}
  if SafeDirectoryExists(UDPath+'Examples') then Dir := UDPath+'Examples';
//  if CPrefs[StartupDirectory].SValue = 'Set Via Shortcut' then
//    Dir := GetCurrentDir                         {Use current directory}
//  else
//    if CPrefs[StartupDirectory].SValue = 'Last Used' then
      if CPrefs[LastUsedDirectory].SValue <> '' then Dir := CPrefs[LastUsedDirectory].SValue;    {Use last used directory}
//    else
//      begin                                      {Default BS... or Favorite Directory}
//      Idx := 0;
//      while (Idx < 6) and (CPrefs[StartupDirectory].SValue <> GetModuleDirectoryName(Idx)) do inc(Idx);
//      if Idx < 6 then {Default BS...}
//        Dir := CPrefs[PrefEntity(ord(BS1Directory)+Idx)].SValue
//      else
//        begin         {Favorite Directory}
//        Idx := 0;
//        while (Idx < 10) and (copy(CPrefs[PrefEntity(ord(FavoriteDirectory01)+Idx)].SValue,1,length(CPrefs[StartupDirectory].SValue)) <> CPrefs[StartupDirectory].SValue) do inc(Idx);
//        if Idx < 10 then Dir := copy(CPrefs[PrefEntity(ord(FavoriteDirectory01)+Idx)].SValue,pos('|',CPrefs[PrefEntity(ord(FavoriteDirectory01)+Idx)].SValue)+1,length(CPrefs[PrefEntity(ord(FavoriteDirectory01)+Idx)].SValue));
//        end;
//      end;
  if not SafeDirectoryExists(Dir) then
    begin
    CPrefs[LastUsedDirectory].SValue := GetCurrentDir; {If doesn't exist, fall back on Current Directory}
    PrefsHaveChanged := True;
    Dir := CPrefs[LastUsedDirectory].SValue;
    end;

  {Create Propeller Serial object}
  Propeller := TPropellerSerial.Create;

  {Open file, if suggested via command line (requires extension)}
  if CmdLineFileName <> '' then
    begin
    if ExtractFilePath(CmdLineFileName) = '' then CmdLineFileName := ExtractFilePath(Application.ExeName)+CmdLineFileName;
    {$IFDEF SX_TESTER_AS_PROGRAMMER} TerminateAfterInfo := True; {$ENDIF}
    if Editor.Open(CmdLineFileName, ExtractFilePath(CmdLineFileName), nil, True, False) > -1 then Dir := ExtractFileDir(CmdLineFileName);
    {If compiled with SXTesterAsProgrammer directive, terminate upon closing Info display of opened binary or eeprom file}
    end;

  {Set initial directory}
  {$IFNDEF LoadDirList}
  Editor.Explorer.ShowRecentOnly := CPrefs[ShowRecentOnly].BValue;   {This should not be compiled if .Create's LoadDirList parameter is True}
  {$ENDIF}
  Editor.Explorer.Directory := Dir;

  {Set filter index}
  Editor.FilterIndex := CPrefs[FilterIdx].IValue;

  {Open auto-recovery files}
  Propeller.OpenAutoRecoverSerial;
  OpenAutoRecover;

  {Initialize file menu items}
  FileMenuClick(nil);
end;

{------------------------------------------------------------------------------}

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
{Can we close?  Terminate any active debug session and close all Edit Sheets if possible and if the user allows}
begin
  {Clear previously scheduled action}
  ScheduledAction.Action := atNone;
  {Assume can't close}
  CanClose := False;
  {Verify and enforce communication terminated}
  if (CommThreadState = tsDownloading) then
    MessageBeep(MB_ICONWARNING)                      {Beep if downloading; can't terminate yet}
  else if (CommThreadState < tsTerminated) then
    ScheduleFutureAction(atCloseApp, Sender)         {Communication in progress (but not downloading); terminate communication and reschedule this action}
  else if Editor.CloseAll(False) then
    CanClose := True;                                {Verify all edit tabs could be closed (user prompted, as necessary); we can close app if so}
end;

{------------------------------------------------------------------------------}

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
{Upon closing this application, save all adjusted metrics}
begin
  {Check and save metrics for Main Form, Find/Replace, Character Chart and Preference windows}
  SaveWindowMetrics(MainForm, EditorPos);
  SaveWindowMetrics(Editor.FindReplace.Form, FindReplacePos);
  SaveWindowMetrics(CharChartForm, CharChartPos);
  SaveWindowMetrics(Preferences, PrefsPos);
  SaveWindowMetrics(PortListForm, PortListPos);

  {Check ShowRecentlyOnly button (ScopeButton) state}
  if Editor.Explorer.ShowRecentOnly <> CPrefs[ShowRecentOnly].BValue then
    begin
    PrefsHaveChanged := True;
    CPrefs[ShowRecentOnly].BValue := Editor.Explorer.ShowRecentOnly;
    end;

  {Check for last used directory}
  if IncludeTrailingPathDelimiter(uppercase(CPrefs[LastUsedDirectory].SValue)) <> Editor.Explorer.Directory then
    begin
    CPrefs[LastUsedDirectory].SValue := Editor.Explorer.Directory;
    PrefsHaveChanged := True;
    end;

  {Check if Library Paths changed}
  if CPrefs[LibraryPaths].SValue <> LibraryFolder.Paths then
    begin
    CPrefs[LibraryPaths].SValue := LibraryFolder.Paths;
    PrefsHaveChanged := True;
    end;

  {Check for last used filter index}
  if Editor.FilterIndex <> CPrefs[FilterIdx].IValue then
    begin
    CPrefs[FilterIdx].IValue := Editor.FilterIndex;
    PrefsHaveChanged := True;
    end;

  {Check for last used info display mode}
  if InfoForm.ShowingHex <> CPrefs[InfoShowHex].BValue then
    begin
    CPrefs[InfoShowHex].BValue := InfoForm.ShowingHex;
    PrefsHaveChanged := True;
    end;

  {Check Find/Replace Dialog history}
  SaveFindReplaceHistory;

  {Check Character Chart Window's Font Size}
  if Cardinal(CharChartForm.FontSize) <> CPrefs[ChartFontSize].IValue then
    begin
    PrefsHaveChanged := True;
    CPrefs[ChartFontSize].IValue := CharChartForm.FontSize;
    end;

  {Check Character Chart Window's Display Mode}
  if Cardinal(CharChartForm.GetDisplayMode) <> CPrefs[ChartDisplayMode].IValue then
    begin
    PrefsHaveChanged := True;
    CPrefs[ChartDisplayMode].IValue := CharChartForm.GetDisplayMode;
    end;

  {Destroy Propeller Serial object}
  Propeller.Destroy;

  {Restore custom syntax scheme settings, if necessary}
  RestoreCustomSynScheme;

  if PrefsHaveChanged then SavePrefsToRegistry;                                 {Save preferences in the registry}
end;

{------------------------------------------------------------------------------}

procedure TMainForm.FileMenuClick(Sender: TObject);
{File menu clicked; update items}
begin
  NewFromP1TemplateItem.Enabled := SafeFileExists(CPrefs[NewP1FileTemplate].SValue);
  NewFromP2TemplateItem.Enabled := SafeFileExists(CPrefs[NewP2FileTemplate].SValue);
  ArchiveItem.Enabled := Editor.ActiveTabSheet.CustomTag1 <> ord(vmStandard);
  if ArchiveItem.Enabled then
    ArchiveItem.Caption := 'Archive "' + Editor.ActiveTabSheet.Caption + '"'
  else
    ArchiveItem.Caption := 'Archive';
end;

{------------------------------------------------------------------------------}

procedure TMainForm.FileMenuItemClick(Sender: TObject);
{Handle File Menu Items}
begin
  if Initializing then exit;

  if TControl(Sender).Tag in [OpenItem.Tag..SaveToItem.Tag] then
    begin {If Open/Save item, update their settings}
    Editor.AlterDialog(dlgSave, '', '', ActivePropSourceExtension);
    Editor.OpenDialog.InitialDir := Editor.Explorer.Directory;
    end;

  case TControl(Sender).Tag of
    00    : Editor.New(nil, True);                                                                                       {New}
    16    : CreateNewFromTemplate(P1);                                                                                   {New (From P1 Template)}
    17    : CreateNewFromTemplate(P2);                                                                                   {New (From P2 Template)}
    01    : Editor.Open('', '', nil, True, OpenReadOnly);                                                                {Open}
    02    : OpenFromSaveTo(TMenuItem(Sender), True);                                                                     {Open From}
    03    : Editor.Save;                                                                                                 {Save}
    04    : Editor.SaveAs('');                                                                                           {Save As}
    05    : OpenFromSaveTo(TMenuItem(Sender), False);                                                                    {Save To}
    06    : Editor.SaveAll;                                                                                              {Save All}
    07    : Editor.Close(True);                                                                                          {Close}
    08    : Editor.CloseAll(True);                                                                                       {Close All}
    09    : SetTopFile('');                                                                                              {Select Top File}
    10    : Archive(False);                                                                                              {Create Archive with project files}
    11    : Archive(True);                                                                                               {Create Archive with project and IDE files}
    12    : ShowHideExplorer;                                                                                            {Show/Hide Explorer}
    13    : Editor.PrintPreview;                                                                                         {Print Preview}
    14    : Editor.Print;                                                                                                {Print}
    15    : Close;                                                                                                       {Exit}
  end;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.EditMenuItemClick(Sender: TObject);
{Handle Edit Menu Items}
begin
  if Initializing then exit;

  case TControl(Sender).Tag of
    00    : Editor.ActiveSource.Undo;                      {Undo}
    01    : Editor.ActiveSource.Redo;                      {Redo}
    02    : Editor.Cut;                                    {Cut}
    03    : Editor.Copy;                                   {Copy}
    04    : Editor.Paste;                                  {Paste}
    05    : Editor.ActiveEdit.SelectAll;                   {Select All}
    06    : Editor.FindReplace.Show;                       {Find / Replace}
    07    : Editor.FindReplace.FindNext;                   {Find Next}
    08    : Editor.FindReplace.Replace((GetKeyState(VK_SHIFT) and $80000000) <> 0);  {Replace}
    09    : exit;                                             {Split Editor}
    10    : Editor.IncFontSize;                            {Text Bigger}
    11    : Editor.DecFontSize;                            {Text Smaller}
    12    : Preferences.Show;                              {Preferences}
    21..29: Editor.GotoBookmark(TMenuItem(Sender).Tag-20); {Go To Bookmark}
  end;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.RunMenuClick(Sender: TObject);
{Run menu clicked; update items}
var
  SearchRec : TSearchRec;
  CNV, TNV  : String;

  {----------------}

  function NVType(PropModel: TPropModel): String;
    begin
    Result := '';
    case PropModel of
      P1    : Result := 'EEPROM';
      P2    : Result := 'Flash';
    end;
    end;

  {----------------}

begin
  {Update compile menu items to reflect the non-volatile memory type of the target Propeller (if any)}
  CNV := NVType(ActiveSourceType);
  TNV := NVType(PropSourceType(CPrefs[TopFile].SValue));
  if CNV <> '' then CompileCurrentProgramEEPROMRunItem.Caption := 'L&oad ' + CNV;
  if TNV <> '' then  CompileTopProgramEEPROMRunItem.Caption := 'L&oad ' + TNV;
  {Enable Parallax Serial Terminal menu item if file exists}
  try
    ParallaxSerialTerminalItem.Enabled := (FindFirst(extractfiledir(application.exename)+'\Parallax Serial Terminal.exe', faAnyFile, SearchRec) = 0);
  finally
    FindClose(SearchRec);
  end; {try}
end;

{------------------------------------------------------------------------------}

procedure TMainForm.RunMenuItemClick(Sender: TObject);
{Handle Run Menu Items}
{Note: Tags 3 and 8 were the Load EEPROM only options, which were removed on 5/18/2006}
var
  Str       : String;
begin
  {If Initializing, or if compiled with SXTesterAsProgrammer directive and menu item's tag is a Load RAM option, exit}
  if Initializing {$IFDEF SX_TESTER_AS_PROGRAMMER} or (TControl(Sender).Tag in [2, 7]) {$ENDIF} then exit;
  {Clear previously scheduled action}
  ScheduledAction.Action := atNone;
  try {Take requested action}
    if TControl(Sender).Tag < 10 then
      begin
      SaveAutoRecover;                                                                                                                             {Save autorecovery files}
      Prop.P2DebugMode := EnableDebugItem.Checked;                                                                                                 {Prep to debug or not}
      if Compile(TDirLevel(2-(TControl(Sender).Tag div 5)), TControl(Sender).Tag in [0,5], False, not (TControl(Sender).Tag in [0, 1, 5, 6]), '', True, TControl(Sender).Tag in [4,9]) then {Compile and possibly View}
        if not (TControl(Sender).Tag in [0, 1, 5, 6]) then
          with PObjData(InfoObjectView.Items[0].Data)^ do
            Propeller.Download(PropModel, BinImage, BinSize, TControl(Sender).Tag mod 5 - 1, Prop.P2DebugMode and (Prop.P2DebugPin = 62));         {Load RAM/EEPROM/Flash and Run (and optionally Debug on P2)}
      end
    else
      if TControl(Sender).Tag = 10 then
        Propeller.GetVersion(UN)                                                                                                                   {Identify Hardware and get version}
      else
        LaunchOrShowApp('Parallax Serial Terminal', extractfiledir(application.exename)+'\Parallax Serial Terminal.exe', MainForm);                {Launch or show the Parallax Serial Terminal}
  except {If communication in progress; reschedule this action}
    on ECommTerminatable do
      ScheduleFutureAction(atRunMenuItem, Sender);
    on ECommDownloading do
      MessageBeep(MB_ICONWARNING);
  end;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.HelpMenuClick(Sender: TObject);
{Help menu clicked; update items}
var
  Idx       : Integer;
  SearchRec : TSearchRec;

    {---------------------------------}

    procedure EnableIfFound(MenuItem: TMenuItem; Str: String);
    begin
      try {Enable MenuItem if the Str file exists}
        MenuItem.Enabled := (FindFirst(Str, faAnyFile, SearchRec) = 0);
      finally
        FindClose(SearchRec);
      end;
    end;

    {---------------------------------}

begin
  for Idx := 0 to 6 do
    case Idx of
      0: EnableIfFound(PropellerToolItem, extractfiledir(application.exename)+'\Help\Propeller*Help*.exe');
      1: EnableIfFound(QuickReferenceItem, extractfiledir(application.exename)+'\Help\Propeller*Quick*Reference*.pdf');
      2: EnableIfFound(PropellerManualItem, extractfiledir(application.exename)+'\Help\Propeller*Manual*.pdf');
      3: EnableIfFound(PropellerDatasheetItem, extractfiledir(application.exename)+'\Help\Propeller*Datasheet*.pdf');
      4: EnableIfFound(DemoBoardSchematicItem, extractfiledir(application.exename)+'\Help\Propeller*Demo*Board*Schematic*.pdf');
      5: EnableIfFound(QuickStartSchematicItem, extractfiledir(application.exename)+'\Help\P8X32A*QuickStart*Schematic*.pdf');
      6: EnableIfFound(PropellerEducationKitLabsItem, UDPath+'Examples\PE Kit\Propeller*Education*Kit*Labs*Fundamentals*.pdf');
    end;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.HelpMenuItemClick(Sender: TObject);
{Handle Run Menu Items}
var
  Str       : String;
  SearchRec : TSearchRec;
begin
  if Initializing then exit;
  Str := '';
  case TControl(Sender).Tag of
    00    : LaunchOrShowApp('Propeller Help', extractfiledir(application.exename)+'\Help\Propeller Help.exe', MainForm);  {Propeller 1 Help}
    01    : exit;                                                                                                         {Spin Language [Deprecated]}
    02    : exit;                                                                                                         {Assembly Language [Deprecated]}
    03    : exit;                                                                                                         {Example Projects [Deprecated]}
    04    : Str := extractfiledir(application.exename)+'\Help\Propeller*Quick*Reference*.pdf';                            {P1 Quick Reference}
    05    : Str := extractfiledir(application.exename)+'\Help\Propeller*Manual*.pdf';                                     {Propeller 1 Manual}
    06    : Str := extractfiledir(application.exename)+'\Help\Propeller*Datasheet*.pdf';                                  {Propeller 1 Datasheet}
    07    : exit;                                                                                                         {Propeller Demo Board schematic [Deprecated]}
    08    : Str := extractfiledir(application.exename)+'\Help\P8X32A*QuickStart*Schematic*.pdf';                          {P8X32A QuickStart board schematic}
    09    : Str := UDPath+'Examples\PE Kit\Propeller*Education*Kit*Labs*Fundamentals*.pdf';                               {Propeller 1 Education Kit Labs - Fundamentals}
    10    : CharChartForm.Show;                                                                                           {View Character Chart}
    11    : ParallaxLinkClick(0);                                                                                         {View Propeller Object Exchange}
    12    : ParallaxLinkClick(1);                                                                                         {View Propeller 1 Forum}
    13    : ParallaxLinkClick(2);                                                                                         {View Propeller 2 Forum}
    14    : ParallaxLinkClick(3);                                                                                         {View Propeller 2 Website}
    15    : ParallaxLinkClick(4);                                                                                         {View Parallax Website}
    16    : ParallaxLinkClick(5);                                                                                         {E-Mail Parallax Support}
    17    : AboutForm.ShowModal;                                                                                          {About}
    18    : ParallaxLinkClick(6);                                                                                         {Propeller 2 Documentation}
    19    : ParallaxLinkClick(7);                                                                                         {Propeller 2 Assembly Instructions}
    20    : ParallaxLinkClick(8);                                                                                         {Propeller 2 Spin Language}
    21    : ParallaxLinkClick(9);                                                                                         {Propeller 2 TAQOZ Boot Firmware}
    22    : ParallaxLinkClick(10);                                                                                        {P2-ES Documentation}
    23    : ParallaxLinkClick(11);                                                                                        {P2-ES Schematic}
  end;
  if (Str = '') then exit;                                                                                                {Exit if no file to open up}
  try                                                                                                                     {Else, search for file}
    if FindFirst(Str, faAnyFile, SearchRec) <> 0 then exit;
    repeat
      Str := extractfiledir(Str)+'\'+SearchRec.Name;
    until FindNext(SearchRec) <> 0;
  finally
    FindClose(SearchRec);
  end;
  if (Str <> '') then ShellExecute(MainForm.Handle, nil, @Str[1], nil, nil, SW_SHOWNORMAL);                               {If file found, open it}
end;

{------------------------------------------------------------------------------}

procedure TMainForm.FormMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
{Mouse wheel event occurred}
 var
  Idx        : Integer;
begin
  if Initializing then exit;

  Idx := WheelDelta div WHEEL_DELTA;
  if (Idx <> 0) and (Shift = [ssAlt]) then
    begin {ALT key held down, change view mode}
    if TViewMode(Editor.EditSheet[Editor.ActiveIdx].CustomTag1) <> vmStandard then
      begin
      if Idx > 0 then
        SetView(TViewMode(max(ord(vmFull),ord(TViewMode(Editor.EditSheet[Editor.ActiveIdx].CustomTag1))-Idx)))           {Move view mode towards Full}
      else
        SetView(TViewMode(min(ord(vmDocumentation),ord(TViewMode(Editor.EditSheet[Editor.ActiveIdx].CustomTag1))-Idx))); {Move view mode towards documentation}
      SetStatusBarText(StatusViewMode + ViewModeText[TViewMode(Editor.EditSheet[Editor.ActiveIdx].CustomTag1)], 2.5);
      end;
    Handled := True;
    end;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.EditSelectAll(ID: Integer);
{Edit's Select All shortcut menu item clicked}
begin
  Editor.ActiveEdit.SelectAll;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.EditTabNewFromTemplateItemClick(ID: Integer);
{Edit Tab's New From Propeller 1 Template shortcut menu item clicked}
begin
  if ID = etNewFromP1Template then CreateNewFromTemplate(P1);
  if ID = etNewFromP2Template then CreateNewFromTemplate(P2);
end;

{------------------------------------------------------------------------------}

procedure TMainForm.EditTabTopFileItemClick(ID: Integer);
{Edit Tab's Top File shortcut menu item clicked}
var
  Filename : String;
begin
  Filename := Editor.ActiveTabSheet.FullFilename;
  if Filename = '' then Filename := Editor.ActiveTabSheet.Caption;
  SetTopFile(Filename);
end;

{------------------------------------------------------------------------------}

procedure TMainForm.EditTabArchiveItemClick(ID: Integer);
{Edit Tab's Archive shortcut menu item clicked}
begin
  Archive(False);
end;

{------------------------------------------------------------------------------}

procedure TMainForm.FileListTopFileItemClick(ID: Integer);
{File List's Top File shortcut menu item clicked}
begin
  SetTopFile(Editor.Explorer.Filenames[0]);
end;

{------------------------------------------------------------------------------}

procedure TMainForm.ViewModePanelCreated(Sender: TObject);
var
  ViewGroup   : TPRadioGroup;
  Idx         : TViewMode;
begin
  TControlPanel(Sender).Panel.BevelOuter := bvNone;
  TControlPanel(Sender).Panel.OnAlign := ViewModePanelAlign;
  TControlPanel(Sender).Panel.Visible := True;

  ViewGroup := TPRadioGroup.Create(TControlPanel(Sender).Panel);
  ViewGroup.Parent := TControlPanel(Sender).Panel;
  ViewGroup.Align := alCustom;
  ViewGroup.BevelOuter := bvNone;
  ViewGroup.ShowHint := True;
  ViewGroup.AllowToggle := True;
  ViewGroup.RowPadding := 3;
  ViewGroup.DoubleBuffered := True;
  ViewGroup.OnCanStay := ViewModeChanged;
  ViewGroup.OnIsActive := ViewModePanelIsActive;

  for Idx := low(TViewMode) to high(TViewMode) do
    case Idx of
      vmFull          : ViewGroup.Items.Add('Full &Source', 'View all source code lines|');
      vmCondensed     : ViewGroup.Items.Add('&Condensed', 'Hide comment lines (read-only view)|');
      vmSummary       : ViewGroup.Items.Add('S&ummary', 'View only CON, VAR, OBJ, PUB, PRI and DAT lines (read-only view)|');
      vmDocumentation : ViewGroup.Items.Add('&Documentation', 'View compiled object documentation (read-only view)|');
    end;

  TControlPanel(Sender).Panel.ClientHeight := ViewGroup.Height-2;
  Editor.EditMinWidth := ViewGroup.Width + 50;

  TControlPanel(Sender).Spacer.Height := 3;
  TControlPanel(Sender).Spacer.Visible := True;

  TDockingTabSheet(TControlPanel(Sender).Owner).CustomTag1 := ord(vmFull);
end;

{------------------------------------------------------------------------------}

procedure TMainForm.ViewModePanelAlign(Control: TControl; var NewLeft, NewTop, NewWidth, NewHeight: Integer; var AlignRect: TRect; AlignInfo: TAlignInfo);
begin
  NewLeft := (AlignRect.Right-AlignRect.Left) div 2 - (NewWidth div 2) + AlignRect.Left;
end;

{------------------------------------------------------------------------------}

function TMainForm.ViewModePanelIsActive(Sender: TPRadioGroup; Parent: TWinControl): Boolean;
{View Mode panel is asking if it is active or not.  Tell it if it is on the active tab (page control).}
begin
  Result := TDockingPageControl(TDockingTabSheet(TPPanel(Parent).Parent).PageControl).IsActive;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.ObjectViewAlign(Control: TControl; var NewLeft, NewTop, NewWidth, NewHeight: Integer; var AlignRect: TRect; AlignInfo: TAlignInfo);
{Integrated Explorer is realigning; resize and align the ObjectView contained within it's CustomExplorerPanel}
begin
  ObjectView.Left := 0;
  ObjectView.Top := 0;
  ObjectView.Width := AlignRect.Right-AlignRect.Left;
  ObjectView.Height := AlignRect.Bottom-AlignRect.Top;
end;


{------------------------------------------------------------------------------}

procedure TMainForm.ObjectClicked(Sender: TObjectTreeView; Node: TTreeNode; Button: TMouseButton);
{Node was just clicked, load up that file (or swtich to tab containing it); optionally switching to documentation view}
var
  Idx      : Integer;
  Filename : String;
begin
  if ProcessingObjClick then exit;
  ProcessingObjClick := True;
  try
    Filename := PObjData(Node.Data)^.FullFilename;
    Idx := IndexOfTabWithFile(Filename);
    if Idx > -1 then Editor.ActiveIdx := Idx else if not Editor.Open(Filename, '', nil, True, False) > -1 then exit;
    if Button = mbLeft then SetView(vmFull) else if Button = mbRight then SetView(vmDocumentation);
  finally
    ProcessingObjClick := False;
  end;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.ObjectDoubleClicked(Sender: TObjectTreeView; Node: TTreeNode; Hit: THitTests);
{Node may have just been double-clicked, load up all files it uses.  Note: The Click event occurred just before this, so the Node
that was double-clicked is now open.}
var
  ObjIdx, ObjLevel, TabIdx, OrigTabIdx : Integer;
  Filename                             : String;
begin
  if not (htOnItem in Hit) then exit;
  OrigTabIdx := IndexOfTabWithFile(PObjData(Node.Data)^.FullFilename);
  ObjIdx := Node.AbsoluteIndex+1;
  ObjLevel := Node.Level;
  while (ObjIdx < Sender.Count) and (ObjLevel < Sender.ObjectView.Items[ObjIdx].Level) do
    begin {Open any subobjects of this object}
    Filename := PObjData(Sender.ObjectView.Items.Item[ObjIdx].Data)^.FullFilename;
    TabIdx := IndexOfTabWithFile(Filename);
    if TabIdx > -1 then Editor.ActiveIdx := TabIdx else if not Editor.Open(Filename, '', nil, True, False) > -1 then exit;
    SetView(vmFull);
    Editor.RepaintTabs;
    inc(ObjIdx);
    end;
  Editor.ActiveIdx := OrigTabIdx;  
end;

{------------------------------------------------------------------------------}

procedure TMainForm.ObjectSelected(Sender: TObjectTreeView; Node: TTreeNode);
{Node was just selected (via Enter key), load up that file (or swtich to tab containing it)}
begin
  ObjectClicked(Sender, Node, mbLeft);
end;

{------------------------------------------------------------------------------}

procedure TMainForm.ParallaxLinkClick(Index: Integer);
{Visit web site or send support email}
begin
  case Index of
     0: ShellExecute(Handle, nil, 'https://github.com/parallaxinc/propeller/tree/master/libraries', nil, nil, SW_SHOWNORMAL);                                                                    {View Propeller Object Exchange}
     1: ShellExecute(Handle, nil, 'https://forums.parallax.com/categories/propeller-1-multicore-microcontroller', nil, nil, SW_SHOWNORMAL);                                                      {View Propeller 1 Forum}
     2: ShellExecute(Handle, nil, 'https://forums.parallax.com/categories/propeller-2-multicore-microcontroller', nil, nil, SW_SHOWNORMAL);                                                      {View Propeller 2 Forum}
     3: ShellExecute(Handle, nil, 'https://propeller.parallax.com/', nil, nil, SW_SHOWNORMAL);                                                                                                   {View Propeller 2 Website}
     4: ShellExecute(Handle, nil, 'https://www.parallax.com', nil, nil, SW_SHOWNORMAL);                                                                                                          {View Parallax Website}
     5: ShellExecute(Handle, nil, 'mailto:support@parallax.com', nil, nil, SW_SHOWNORMAL);                                                                                                       {E-Mail Parallax Support}
     6: ShellExecute(Handle, nil, 'https://docs.google.com/document/d/1gn6oaT5Ib7CytvlZHacmrSbVBJsD9t_-kmvjd7nUR6o/edit#heading=h.1h0sz9w9bl25', nil, nil, SW_SHOWNORMAL);                       {Propeller 2 Documentation}
     7: ShellExecute(Handle, nil, 'https://docs.google.com/spreadsheets/d/1_vJk-Ad569UMwgXTKTdfJkHYHpc1rZwxB-DcIiAZNdk/edit#gid=0', nil, nil, SW_SHOWNORMAL);                                    {Propeller 2 Assembly Instructions}
     8: ShellExecute(Handle, nil, 'https://docs.google.com/document/d/16qVkmA6Co5fUNKJHF6pBfGfDupuRwDtf-wyieh_fbqw/edit#', nil, nil, SW_SHOWNORMAL);                                             {Propeller 2 Spin Language}
     9: ShellExecute(Handle, nil, 'https://docs.google.com/document/d/e/2PACX-1vQKKl_A9gQ8VooCfrLOqw6a_rp9ddyAqiFeo1RopL2AtnHTaWIfvojYq-yfNlqoPD81a2EU1EJsQpRG/pub', nil, nil, SW_SHOWNORMAL);   {Propeller 2 TAQOZ Boot Firmware}
    10: ShellExecute(Handle, nil, 'https://docs.google.com/document/d/1PH20fQ8j-aRTqocTVBukXeK6bEliXfd7vfKHKlftYk8/edit', nil, nil, SW_SHOWNORMAL);                                              {P2-ES Documentation}
    11: ShellExecute(Handle, nil, 'https://www.parallax.com/sites/default/files/downloads/64000-ES_RevB_P2_EVAL_Schematic_0821.pdf', nil, nil, SW_SHOWNORMAL);                                   {P2-ES Schematic}
  end;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.PageAddedDeleted(Sender: TObject; Idx: Integer; PageState: TPageState; Action: TPageAction);
{A page is being added or deleted}
begin
  if Action = paAdd then Editor.EditSheet[Idx].CustomTag1 := ord(vmFull);
  {Update Page option items}
  EnableDisablePageOptions(PageState);
end;

{------------------------------------------------------------------------------}

procedure TMainForm.EnableDisablePageOptions(PageState: TPageState);
{Enable or disable the New, Open, Close, SaveAs and Print menu items according to whether or not they can be used at this time}
begin
  NewItem.Enabled := PageState <> psFull;
  OpenItem.Enabled := PageState <> psFull;
  CloseItem.Enabled := True;
  SaveAsItem.Enabled := True;
  PrintItem.Enabled := True;
end;

{------------------------------------------------------------------------------}

function TMainForm.CanFindReplace: Boolean;
begin
  Result := True; {Allow Find/Replace}
  if not (TViewMode(Editor.EditSheet[Editor.ActiveIdx].CustomTag1) in [vmStandard, vmFull, vmDocumentation]) then
    begin {Switch to Full Source view mode if necessary}
    messagebeep(MB_OK);
    SetView(vmFull);
    SetStatusBarText(StatusViewModeFull);
    end;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.FindReplaceShow(Sender: TObject);
{Make sure Find/Replace form is at reasonably displayable coordinates}
begin
  EnsureWindowDisplayable(TForm(Sender));
end;

{------------------------------------------------------------------------------}

function TMainForm.CanSourceChange(Operation: TEasyOperation; X, Y, State: Integer; Data: Pointer): Boolean;
begin
  Result := True; {Default to allow edits}
  if TViewMode(Editor.EditSheet[Editor.ActiveIdx].CustomTag1) in [vmCondensed, vmSummary, vmDocumentation] then
    begin {Disallow edits if not Full or Standard view mode}
    messagebeep(MB_OK);
    SetView(vmFull);    {Switch to Full Source view mode}
    SetStatusBarText(StatusViewModeFull);
    Result := False;
    end
  else
    if (CPrefs[ShowBlockIndentions].BValue) and (ParserState(State) in Method) then Editor.ActiveEdit.Invalidate;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.EditSourceChanged(Sender: TObject; Index: Integer; EditorState: TEditorState);
{Enable or disable Save, Undo and Redo menu items according to whether or not they can be used at this time.
Also invalidate source information reference.}
begin
  SaveItem.Enabled := EditorState in [esJustModified, esModified];
  if (EditorState = esReadOnly) and (TViewMode(Editor.EditSheet[Index].CustomTag1) = vmDocumentation) then
    begin
    SaveAsItem.Caption := 'Save Documentation &As...';
    SaveAsItem.Hint := 'Save the current documentation as a text file';
    SaveToItem.Caption := 'Save Documentation &To...';
    SaveToItem.Hint := 'Save the current documentation to a recently accessed folder';
    end
  else
    begin
    SaveAsItem.Caption := 'Save &As...';
    SaveAsItem.Hint := 'Save the current file with a new name';
    SaveToItem.Caption := 'Save &To...';
    SaveToItem.Hint := 'Save the current file to a recently accessed folder';
    end;
  SaveAllItem.Enabled := Editor.SaveAllAvailable;
  UndoItem.Enabled := Editor.ActiveSource.UndoAvailable; //EditorState in [esJustModified, esModified]; <--Removed 9/14/2006 to fix UndoAfterSave bug
  RedoItem.Enabled := Editor.ActiveSource.RedoAvailable;
  if (EditorState = esJustModified) and (Editor.EditSheet[Index].CustomData1 <> nil) then
    begin
    Editor.EditSheet[Index].CustomData1 := nil; {Discard source information data}
    UpdateCompileStatus;
    end;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.EditStateChanged(Sender: TObject; Index: Integer; EditorState: TEditorState; var HighlightBgColor, HighlightFtColor: TColor; var HighlightPeriod: Integer);
{Edit state changed, highlight changed state in status bar}
begin
  if EditorState = esUnModified then exit;
  HighlightBgColor := NewInfoColor;
  HighlightFtColor := NewInfoFtColor;
  HighlightPeriod := HighlightDelay;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.EditModeChanged(Sender: TObject; Idx: Integer; EditMode: TEasyEditMode; var HighlightBgColor, HighlightFtColor: TColor; var HighlightPeriod: Integer);
{Edit mode changed, highlight edit mode's panel in status bar}
begin
  HighlightBgColor := NewInfoColor;
  HighlightFtColor := NewInfoFtColor;
  HighlightPeriod := HighlightDelay;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.EditDoubleClicked(Sender: TObject; GutterClicked, CollapseMarkClicked: Boolean; var AbortSelection: Boolean);
{Edit double-clicked.  If text clicked in condensed or summary view, switch to full view.}
begin
  if not GutterClicked and not CollapseMarkClicked and (TViewMode(Editor.ActiveTabSheet.CustomTag1) in [vmCondensed, vmSummary]) then
    begin  {Text double-clicked while in Condensed or Summary view, expand to full view}
    AbortSelection := True;
    if TViewMode(Editor.ActiveTabSheet.CustomTag1) = vmCondensed then messagebeep(MB_OK);
    SetView(vmFull);
    SetStatusBarText(StatusViewModeFull);
    end;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.EnableDisableBookmarkItems(Sender: TObject; BookmarkState: Integer);
{Update the Go To Bookmark menu items}
var
  Idx: Integer;
begin
  if BookmarkState and 1 = 0 then
    GotoBookmarkItem.Enabled := False
  else
    begin
    GotoBookmarkItem.Enabled := True;
    for Idx := 0 to 8 do
      begin
      BookmarkState := BookmarkState shr 1;
      GotoBookmarkItem.Items[Idx].Enabled := BookmarkState and 1 = 1;
      end;
    end;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.DrawTabName(Sender: TMultiViewPageControl; TabIdx: Integer; Canvas: TCanvas; Rect: TRect; Active: Boolean);
{Draw the editor tabs manually to highlight the Top File (if exists)}
var
  Name : String;
begin
  Name := Editor.EditSheet[TabIdx].CaptionEx;
  if IsTopFile(TabIdx) then Canvas.Font.Style := [fsBold] else Canvas.Font.Style := [];
  Canvas.TextOut(Rect.Left+(Rect.Right-Rect.Left) div 2 - (Canvas.TextWidth(Name) div 2), Rect.Top+3, Name);
end;

{------------------------------------------------------------------------------}

procedure TMainForm.TabHint(Sender: TMultiViewPageControl; TabIdx: Integer; var HintText: String; var MaxWidth: Integer; var Center: Boolean);
{Set tab hint to indicate TopFile or not}
begin
  if IsTopFile(TabIdx) then
    begin
    if HintText <> '' then HintText := #$D#$A + HintText;
    HintText := '-- TOP OBJECT FILE --' + HintText;
    Center := True;
    end;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.TabSwitched(Sender: TObject; Index: Integer; Filename: String; Tabname: String);
{Active tab switched}
begin
  CompileCurrentItem.Enabled := TViewMode(Editor.EditSheet[Index].CustomTag1) <> vmStandard;   {Enable/disable compile current menu item}
  UpdateInfoStatus;                                                             {Update status bar}
  UpdateCompileStatus;
  SetTitleBar(Tabname);                                                         {Update title bar}
  if Filename <> '' then ObjectView.SelectObject(Filename, True) else ObjectView.SelectObject(Tabname, True); {Select object(s) in Object View (if it exists)}
end;

{------------------------------------------------------------------------------}
//!!! Need to create new SyntaxPaint types: Propeller1 and Propeller2
procedure TMainForm.SetTabName(Sender: TObject; Idx: Integer; var Tabname: string);
{Change tabname and enable/disable syntax highlighting and documentation mode.  Also, useful to update TitleBar when a new file is loaded.}

    {------------------------}

    procedure SourceIs(Propeller: Boolean);
    {Enabled/disabled syntax highlighting, control panel and compile options (Run menu) based on type of source file}
    var
      CIdx : Integer;
    begin
      CompileCurrentItem.Enabled := Propeller;
      if not Propeller then
        SetView(vmStandard) {Not Propeller source? Set to Standard view}
      else
        if TViewMode(Editor.EditSheet[Idx].CustomTag1) = vmStandard then
          SetView(vmFull);  {Propeller source that used to be non-propeller? Set to Full view}
      for CIdx := 0 to TWinControl(Editor.EditSheet[Idx].ControlPanel.Panel.Controls[0]).ControlCount-1 do
        if TWinControl(Editor.EditSheet[Idx].ControlPanel.Panel.Controls[0]).Controls[CIdx].Tag <> -1 then TWinControl(Editor.EditSheet[Idx].ControlPanel.Panel.Controls[0]).Controls[CIdx].Enabled := Propeller;
      Editor.EditSheet[Idx].Edit1.Painter.SyntaxPaint := Propeller;
      Editor.EditSheet[Idx].Edit1.Invalidate;
      Editor.EditSheet[Idx].Edit2.Painter.SyntaxPaint := Propeller;
      Editor.EditSheet[Idx].Edit2.Invalidate;
    end;

    {------------------------}
begin
  //!!! Update this when source parsing for propeller directive (P1 or P2) is available
  Tabname := PropModelPrefix[PropSourceType('', Editor.EditSheet[Idx])] + Tabname;
  if IsSpinSourceFile(Tabname) then
    begin              {Propeller Source File}
    Tabname := FilenameWithoutExt(Tabname);
    SourceIs(True);
    end
  else
    if Editor.EditSheet[Idx].FullFilename = '' then
      SourceIs(True)   {Unnamed and unsaved source; assume Propeller source}
    else
      SourceIs(False); {Non-Propeller source file}
  SetTitleBar(Tabname);
  {Select object(s) in Object View (if it exists)}
  if Editor.EditSheet[Idx].FullFilename <> '' then
    ObjectView.SelectObject(Editor.EditSheet[Idx].FullFilename, True)
  else
    ObjectView.SelectObject(Tabname, True);
end;

{------------------------------------------------------------------------------}

procedure TMainForm.SetTitleBar(Tabname: String);
{Set the form's caption to the title of the selected file}
begin
  Caption := PropIDEName + ' - ' + Tabname;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.SplitEditor1Click(Sender: TObject);
{Hide/Show Splitter}
begin
//  Editor.EditSheet[Editor.ActiveIdx].Splitter.Visible := TMenuItem(Sender).Checked;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
{These keys add to, duplicate and in some cases override what the editor does}
var
  WChar    : WideChar;
begin
  WChar := WideChar(0);
  if (Key = VK_ESCAPE) then
    if (ActiveControl is TPCustomEasyEdit) then
      begin {Escape pressed with edit control focused}
      if (Key = VK_ESCAPE) and (TViewMode(Editor.EditSheet[Editor.ActiveIdx].CustomTag1) in [vmCondensed, vmSummary, vmDocumentation]) then
        begin                                                                   {Escape to full view mode}
        SetView(vmFull);
        SetStatusBarText(StatusViewModeFull);
        end
      else
        DebugForm.Close;                                                        {Close all debug displays}
      Key := 0;
      end
    else
      begin {Escape pressed with non-edit control focused; focus active edit control}
      Editor.ActiveEdit.SetFocus;
      Key := 0;
      end;
  if Shift = [ssAlt] then
    begin {ALT key held down}
    if TViewMode(Editor.EditSheet[Editor.ActiveIdx].CustomTag1) <> vmStandard then
      case Key of
        VK_UP    : begin                                                        {Move view mode towards full}
                   SetView(TViewMode( ord(vmDocumentation) - ((ord(vmDocumentation)-Editor.EditSheet[Editor.ActiveIdx].CustomTag1+1) mod (ord(vmDocumentation)+1)) ));
                   SetStatusBarText(StatusViewMode + ViewModeText[TViewMode(Editor.EditSheet[Editor.ActiveIdx].CustomTag1)], 2.5);
                   Key := 0;
                   end;
        VK_DOWN  : begin                                                        {Move view mode towards documentation}
                   SetView(TViewMode((Editor.EditSheet[Editor.ActiveIdx].CustomTag1+1) mod (ord(vmDocumentation)+1)));
                   SetStatusBarText(StatusViewMode + ViewModeText[TViewMode(Editor.EditSheet[Editor.ActiveIdx].CustomTag1)], 2.5);
                   Key := 0;
                   end;
        VK_LEFT,
        VK_RIGHT : if (Shift = [ssAlt]) then
                     begin                                                      {Move to prior or next edit page (just like Ctrl+Shift+Tab and Ctrl+Tab)}
                     Editor.SelectNextPage(Key = VK_RIGHT);
                     Key := 0;
                     end;
        VK_F4    : Application.Terminate;                                       {ALT+F4, terminate application}
        18       : Key := 0;                                                    {Snub ALT-Key-Only presses so that ALT+MouseWheel doesn't leave focus on menu}
        word('T'): begin                                                        {Set current file as top file}
                   EditTabTopFileItemClick(Editor.ActiveIdx);
                   Key := 0;
                   end;
      end; {case}
    end;
  if Shift = [ssCtrl] then
    begin {CTRL key held down}
    case char(Key) of
     char(9) : if (Shift = [ssCtrl]) or (Shift = [ssCtrl, ssShift]) then
                 begin                                                          {Move to next or previous edit page}
                 Editor.SelectNextPage(boolean(not(ssShift in Shift)));
                 Key := 0;
                 end;
      'I'    : begin                                                            {Toggle Indention Indicators}
               CPrefs[ShowBlockIndentions].BValue := not CPrefs[ShowBlockIndentions].BValue;
               UpdateBlockIndentionsVisible;
               PrefsHaveChanged := True;
               Key := 0;
               end;
      'W'    : begin                                                            {Close current edit tab}
               Editor.Close(True);
               Key := 0;
               end;
    end; {case}
    end;
  if Shift = [ssCtrl,ssShift] then
    begin {CTRL+SHIFT keys held down}
    case Key of
      word('D') : WChar := WideChar($0394);                                     {Insert Delta}
      word('M') : WChar := WideChar($00B5);                                     {Insert Mu}
      word('P') : WChar := WideChar($03C0);                                     {Insert Pi}
      word('S') : WChar := WideChar($03A3);                                     {Insert Sigma}
      word('O') : WChar := WideChar($03A9);                                     {Insert Omega}
      word('I') : WChar := WideChar($221E);                                     {Insert Infinity}
      189 { - } : WChar := WideChar($00B1);                                     {Insert Plus/Minus} {Minus Key}
      056 { * } : WChar := WideChar($00D7);                                     {Insert Multiply}
      191 { / } : WChar := WideChar($00F7);                                     {Insert Divide}
      187 { = } : WChar := WideChar($2248);                                     {Insert Approximate Equal}
      word('R') : WChar := WideChar($221A);                                     {Insert Radical}
      word('1') : WChar := WideChar($00B9);                                     {Insert One Superior}
      word('2') : WChar := WideChar($00B2);                                     {Insert Two Superior}
      word('3') : WChar := WideChar($00B3);                                     {Insert Three Superior}
      053 { % } : WChar := WideChar($00B0);                                     {Insert Degree}
      052 { $ } : WChar := WideChar($20AC);                                     {Insert Euro}
      190 { . } : WChar := WideChar($2022);                                     {Insert Bullet}
      word('B') : begin                                                         {Toggle Bookmarks Enabled}
                  CPrefs[ShowBookmarks].BValue := not CPrefs[ShowBookmarks].BValue;
                  UpdateBookmarksVisible;
                  PrefsHaveChanged := True;
                  Key := 0;
                  end;
      word('N') : begin
                  CPrefs[ShowLineNumbers].BValue := not CPrefs[ShowLineNumbers].BValue;
                  UpdateLineNumbersVisible;
                  PrefsHaveChanged := True;
                  Key := 0;
                  end;
    end; {case}
    end;
  if Shift = [ssCtrl,ssShift,ssAlt] then
    begin {CTRL+SHIFT+ALT keys held down}
    case Key of
      052 { $ } : WChar := WideChar($00A3);                                     {Insert Stirling}
      038 {up } : WChar := WideChar($2191);                                     {Insert Up Arrow Bullet}
      040 {dwn} : WChar := WideChar($2193);                                     {Insert Down Arrow Bullet}
      037 {lft} : WChar := WideChar($2190);                                     {Insert Left Arrow Bullet}
      039 {rgt} : WChar := WideChar($2192);                                     {Insert Right Arrow Bullet}
      188 { < } : WChar := WideChar($25C0);                                     {Insert Left Bullet}
      190 { > } : WChar := WideChar($25B6);                                     {Insert Right Bullet}
      word('R') : LoadParserRules;                                              {Re-load Syntax Rules}
    end; {case}
    end;
  if Shift = [ssCtrl,ssAlt] then
    begin {CTRL+ALT keys held down}
    case Key of
      word('1') : WChar := WideChar($F016);                                     {Insert Negative One Superior}
      052 { $ } : WChar := WideChar($00A5);                                     {Insert Yen}
      038 {up } : WChar := WideChar($F0A0);                                     {Insert Up Arrow}
      040 {dwn} : WChar := WideChar($F0A2);                                     {Insert Down Arrow}
      037 {lft} : WChar := WideChar($F0BA);                                     {Insert Left Arrow}
      039 {rgt} : WChar := WideChar($F0BB);                                     {Insert Right Arrow}
      190 { . } : WChar := WideChar($2023);                                     {Insert Rectangle Bullet}
    end; {case}
    end;
  if WChar <> WideChar(0) then
    begin                                                                       {Insert a character}
    Editor.ActiveSource.InsertString(WideString(WChar));
    Editor.ActiveSource.MoveRight;
    Key := 0;
    end;
end;

{------------------------------------------------------------------------------}

function TMainForm.ViewModeChanged(Sender: TPRadioGroup; PreviousSelection, CurrentSelection: Cardinal): Boolean;
{Handle View Buttons}
begin
  Result := SetView(TViewMode(CurrentSelection));
end;

{------------------------------------------------------------------------------}

procedure TMainForm.ExplorerSized(Sender: TObject; Width: Integer; SplitPos: Integer; ExplorerSplitPos: Integer);
{Explorer or File Splitter sized.  Record settings.}
begin
  CPrefs[ExplorerWidth].IValue := Width;
  CPrefs[FileSplitPos].IValue := SplitPos;
  CPrefs[ExplorerPanelSplitPos].IValue := ExplorerSplitPos;
  PrefsHaveChanged := True;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.BeforeFileEvent(Sender: TObject; Idx: Integer; var Action: TFileAction; NewFilename: String);
{A file event is about to occur}
var
  Ext           : String;
begin
  if Action = faClose then
    begin
    PutFileBookmarksInHistory(IndexOfFileFromHistory(Editor.EditSheet[Idx].FullFilename), Idx); {File being closed, update bookmark history}
    ClearAutoRecover(Idx);                                                                      {Clear auto-recover file}
    end;
  if (Action = faSaveAs) then
    begin
    try
      if Editor.EditSheet[Idx].Source.ShowingAltSource then
        begin {Saving alternate source, we'll stop normal SaveAs and perform our own (changing filter to *.txt and *.* and extension to *.txt)}
        Action := faAbort;                                                      {Signal editor to ignore SaveAs request}
        Editor.AlterDialog(dlgSave, 'Save Documenation As', FilenameWithoutExt(ExtractFileName(Editor.ActiveTabSheet.FullFileName)) + '.txt', 'txt', TextAllFilter, 1);
        end
      else
        begin {Saving main source, we'll stop normal SaveAs and perform our own (changing filter to exclude combined source and AllPropAppFilter)}
        Editor.AlterDialog(dlgSave, '', NewFilename, ActivePropSourceExtension, PropSrcTxtFilter, ActiveSourceToFilterIndex(1, 2, 3, 4));
        end;
      Action := faAbort;                                                        {Signal editor to ignore SaveAs request}
      if not Editor.SaveDialog.Execute then exit;                               {SaveAs Dialog was cancelled, Exit}
      if (ExtractFileExt(Editor.SaveDialog.FileName) = '') then                 {File name was left with no extension}
        Editor.SaveDialog.FileName := Editor.SaveDialog.FileName + '.' + Ext;
      Editor.PerformSave(Editor.ActiveIdx, Editor.SaveDialog.FileName, True, not Editor.EditSheet[Idx].Source.ShowingAltSource); {All Okay; perform final save operations}
    finally
      Editor.RestoreDialog;                                                     {Restore SaveDialog settings}
    end;
    end;
  if (Action = faOpen) then
    begin {File being opened}
    if not IsSpinImageFile(NewFilename) then
      SetEditTabs(Idx, not IsSpinSourceFile(NewFilename), True)                                       {Normal file type: Spin source or text file}
    else
      begin
      Action := faAbort;                                                                              {Spin Image file (binary, eeprom, flash), open in Info window instead}
      InfoForm.ShowModal(ltTopWork, NewFilename, True);
      {If compiled with SXTesterAsProgrammer directive and TerminateAfterInfo is True, terminate upon closing Info display of opened binary or eeprom file}
      {$IFDEF SX_TESTER_AS_PROGRAMMER} if TerminateAfterInfo then application.terminate; {$ENDIF}
      end;
    end;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.AfterFileEvent(Sender: TObject; Idx: Integer; Action: TFileAction; PrevFileName: String);
{A file event occurred}
var
  IsSpinCode : Boolean;
begin
  if Action in [faOpen, faSaveAs] then
    begin
    IsSpinCode := IsSpinSourceFile(Editor.EditSheet[Idx].FullFilename);
    SetEditTabs(Idx, not IsSpinCode, not IsSpinCode);
    AddFileToHistory(Editor.EditSheet[Idx].FullFilename);  {Update History if necessary}
    SetFileToBookmarksFromHistory(IndexOfFileFromHistory(Editor.EditSheet[Idx].FullFilename), Idx);   {Set bookmarks from history (if any)}
    if Action = faOpen then
      begin {File opened, link to previously compiled info (if any) and update status bar}
      LinkTabToSourceInfo(Idx);                                                                       {Link tab to source info from last compilation (if any)}
      UpdateInfoStatus;                                                                               {Update Info Status and Compile Status (since AfterFile event occurs after TabSwitch event)}
      UpdateCompileStatus;
      end;
    if Action = faSaveAs then {File saved with a new name, update TopFile if path/name changed}
      if (uppercase(CPrefs[TopFile].SValue) = uppercase(PrevFileName)) and (PrevFileName <> Editor.EditSheet[Idx].FullFilename) then
        begin
        CPrefs[TopFile].SValue := Editor.EditSheet[Idx].FullFilename;
        if (FileList.Directory = uppercase(IncludeTrailingPathDelimiter(ExtractFileDir(Editor.EditSheet[Idx].FullFilename)))) or
         (FileList.Directory = uppercase(IncludeTrailingPathDelimiter(ExtractFileDir(PrevFileName)))) then FileList.Refresh;
        PrefsHaveChanged := True;
        end;
    end;
  if Action in [faSave, faSaveAs] then ClearAutoRecover(Idx);                                         {Clear auto-recover file}
end;

{------------------------------------------------------------------------------}

procedure TMainForm.SetEditTabs(Idx: Integer; AllowTabs: Boolean; UseStandardTabStops: Boolean);
{Set tab settings in EditSheet indicated by Idx.  AllowTabs indicates whether or not tabs should be allowed in the source.
 AllowTabs: True =  tab characters are allowed and existing tabs will remain intact.
            False = tab characters are disallowed and existing tabs will be replaced with spaces according to UseStandardTabStops.
 UseStandardTabStops: True  = Use StandardTabStops setting (8, 16, etc).
                      False = Use SpinTabStops setting (2, 4, 6, etc)}
begin
  Editor.EditSheet[Idx].LeaveTabs := AllowTabs;
  Editor.EditSheet[Idx].UseTabCharacter := AllowTabs;
  if UseStandardTabStops then
    Editor.EditSheet[Idx].Source.TabStops := StandardTabStops
  else
    Editor.EditSheet[Idx].Source.TabStops := CPrefs[PrefEntity(ord(CONTabs)+ord(btPUBPRI))].SValue;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.TabKeyPressed(Sender: TObject; PageIndex: Integer; Position: TPoint; TabStopList: TTabStopList; ParserState: Word);
begin
  if ParserState > ord(high(StyleName)) then exit;                              {Exit if not valid state}
  case TokenStyle(ParserState) of
    CONStart..CONEnd : TabStopList.TabStops := CPrefs[PrefEntity(ord(CONTabs)+ord(btCON))].SValue;
    VARStart..VAREnd : TabStopList.TabStops := CPrefs[PrefEntity(ord(CONTabs)+ord(btVAR))].SValue;
    OBJStart..OBJEnd : TabStopList.TabStops := CPrefs[PrefEntity(ord(CONTabs)+ord(btOBJ))].SValue;
    PUBStart..PRIEnd : TabStopList.TabStops := CPrefs[PrefEntity(ord(CONTabs)+ord(btPUBPRI))].SValue;
    DATStart..DATEnd : TabStopList.TabStops := CPrefs[PrefEntity(ord(CONTabs)+ord(btDAT))].SValue;
  end;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.ShowHintOnStatusBar(Sender: TObject);
{Show application-level hints on the status bar}
begin
  if (length(getlonghint(Application.Hint)) > 0) then
    begin
    Editor.StatusBar.SimplePanel := True;
    Editor.StatusBar.SimpleText := getlonghint(Application.Hint);
    end
  else
    Editor.StatusBar.SimplePanel := False;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.SetTopFile(Filename: String);
{Set top file to filename.  If Filename is '', open a browse window for user to select the top file.}
begin
  if Filename = '' then
    begin  {If no filename given, prompt user to find Top File}
    Editor.AlterDialog(dlgOpen, 'Select Top Object File', '', '', AllPropSourceFilter + '|' + Prop1SourceFilter + '|' + Prop2SourceFilter, 1);
    try
      OldOnShow := Editor.OpenDialog.OnShow;                                    {Temporarily intercept dialog's OnShow event to change Open button to Select button}
      Editor.OpenDialog.OnShow := MakeOpenDialogSelect;
      if Editor.OpenDialog.Execute then Filename := Editor.OpenDialog.FileName;
      if not IsSpinSourceFile(Filename) then Filename := '';
    finally
      Editor.RestoreDialog;                                                     {Restore OpenDialog settings}
    end;
    end;
  if (Filename <> '') and (uppercase(Filename) <> uppercase(CPrefs[TopFile].SValue)) then
    begin {Update top file setting}
    CPrefs[TopFile].SValue := Filename;
    PrefsHaveChanged := True;
    Editor.Explorer.ReloadFileList;
    Editor.RepaintTabs;
    end;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.Archive(ProjectPlusIDE: Boolean);
{Compile current edit tab's project and store related files (and optionally IDE; ProjectPlusIDE = True) into a zipped up, time-stamped archive file.}
var
  Idx              : Integer;
  ArchiveName      : String;
  ArchiveDateTime  : TDateTime;
  FriendlyDateTime : String;
  SrcName          : String;
  SrcStream        : array of TMemoryStream;
  ExeStream        : TFileStream;
  ZipForge         : TZipForge;
  ReadmeStrings    : TEasyStrings;
  ReadmeStream     : TMemoryStream;
const
  Strs : array[0..7] of WideString =
        ('',{header_line}
         #$D#$A+'Parallax Propeller Chip Project Archive'+#$D#$A#$D#$A,{header_line}
         #$D#$A#$D#$A+' Project :  "',{project_name}
         '"'+#$D#$A#$D#$A+'Archived :  ',{archive_stamp}
         #$D#$A#$D#$A+'    Tool :  ',{propeller_ide_version}
         #$D#$A#$D#$A#$D#$A#$D#$A,{object_structure}
         #$D#$A#$D#$A#$D#$A#$D#$A+'',{contact_line}
         #$D#$A+'Parallax Inc.'+#$D#$A+'www.parallax.com'+#$D#$A+'support@parallax.com');

    {-------------------------------------}

    procedure BuildReadmeStrings;
    var
      SIdx, OIdx, LIdx       : Integer;
      ObjText, HierarchyText : WideString;
      RefObj                 : TTreeNode;
    begin
      with ReadmeStrings do
        for SIdx := low(Strs) to high(Strs) do
          begin
          Text := Text + Strs[SIdx];
          case SIdx of
{header_line}           0,1 : begin
                              if SIdx = 1 then Text := Text + #$D#$A;
                              for OIdx := 1 to 39 do Text := Text + widechar($2500);
                              end;
{project_name}          2   : Text := Text + ObjectView.Items[0].Text;
{archive_stamp}         3   : Text := Text + FriendlyDateTime;
{propeller_ide_version} 4   : Text := Text + PropIDEName + ' version ' + GetVersionInfo(application.exename, viVersion);
{object_structure}      5   : begin
                              Text := Text + '            ' + extractfilename(PObjData(ObjectView.Items[0].Data)^.FullFilename);
                              for OIdx := 1 to ObjectView.Count-1 do
                                begin
                                RefObj := ObjectView.Items[OIdx];
                                ObjText := widestring('  ') + widechar($2514+8*ord(RefObj.getNextSibling <> nil)) + widechar($2500) + widechar($2500) + extractfilename(PObjData(RefObj.Data)^.FullFilename);
                                HierarchyText := '';
                                for LIdx := ObjectView.Items[OIdx].Level-1 downto 1 do
                                  begin
                                  RefObj := RefObj.Parent;
                                  HierarchyText := widestring('  ') + widechar($0020+$24E2*ord(RefObj.Parent.Count-1 > RefObj.Index)) + widestring('  ') + HierarchyText;
                                  end;
                                Text := Text + #$D#$A + '            ' + HierarchyText + widestring('  ') + widechar($2502) + #$D#$A + '            ' + HierarchyText + ObjText;
                                end;
                              end;
{contact_line}           6   : for OIdx := 1 to 20 do Text := Text + widechar($2500);
          end; {case}
          end;
    end;

    {-------------------------------------}

begin
  {Clear previously scheduled action}
  ScheduledAction.Action := atNone;
  try {Take requested action}
    if not Compile(ltCurWork, False, False, False) then exit;                                       {Compile for archival purposes.  Exit if failure}
    for Idx := 0 to ObjectView.Count-1 do
      begin
      if ObjectView.Items[Idx].ImageIndex = ord(fiDual) then                                        {Object name collision}
        begin
        messagebeep(MB_ICONERROR);
        if not PObjData(ObjectView.Items[Idx].Data)^.IsDataFile then
          messagedlg('Project uses same-named objects '''+ObjectView.Items[Idx].Text+''' from both Work and Library folders.  Archive cannot be created.', mtError, [mbOk], 0)
        else
          messagedlg('Project uses same-named data file '''+ObjectView.Items[Idx].Text+''' from both Work and Library folders.  Archive cannot be created.', mtError, [mbOk], 0);
        exit;
        end;
      if ObjectView.Items[Idx].ImageIndex = ord(fiNone) then                                        {Object not saved to any folder}
        begin
        messagebeep(MB_ICONERROR);
        messagedlg('Project uses object '''+ObjectView.Items[Idx].Text+''' that was never saved to any folder.  Archive cannot be created.', mtError, [mbOk], 0);
        exit;
        end;
      end;
    ArchiveDateTime := Now;
    DateTimeToString(FriendlyDateTime, 'dddd", "mmmm d", "yyyy" at "h:nn:ss ampm', ArchiveDateTime);
    DateTimeToString(ArchiveName, '"[Date" yyyy.mm.dd  "Time" hh.nn"]"', ArchiveDateTime);
    if Editor.ActiveTabSheet.CustomString1 = '' then  {Default to top object file's path}
      ArchiveName := extractfilepath(PObjData(ObjectView.Items[0].Data)^.FullFilename) + ObjectView.Items[0].Text + ' - Archive  ' + ArchiveName
    else                                              {or use last saved-as path}
      ArchiveName := Editor.ActiveTabSheet.CustomString1 + ObjectView.Items[0].Text + ' - Archive  ' + ArchiveName;

    {Update SaveAs settings (change filter to *.zip and *.* and extension to *.zip)}
    Editor.AlterDialog(dlgSave, 'Save Archive As', ArchiveName + '.zip', 'zip', ArchiveAllFilter, 1);
    {display SaveAs dialog}
    try
      if not Editor.SaveDialog.Execute then exit;                                                   {SaveAs Dialog was cancelled, Exit}
      ArchiveName := Editor.SaveDialog.FileName;
      if ExtractFileExt(ArchiveName) = '' then                                                      {File name was left with no extension}
        ArchiveName := ArchiveName + '.' + Editor.SaveDialog.DefaultExt;
      if SafeFileExists(ArchiveName) then                                                           {Archive file exists, delete it}
        begin {File already exists, warn user and ask to continue}
        messagebeep(MB_ICONWARNING);
        if not (MessageDlg(Format('File already exists.  Overwrite %s?', [ArchiveName]), mtConfirmation, [mbYes, mbNo], 0) = idYes) then exit;
        if not deletefile(ArchiveName) then                                                         {Couldn't delete it? error}
          begin
          messagebeep(MB_ICONERROR);
          messagedlg('Could not delete archive file '''+ArchiveName+'  Operation failed.', mtError, [mbOk], 0);
          exit;
          end;
        end;
      Editor.ActiveTabSheet.CustomString1 := extractfilepath(ArchiveName);                          {Save archive path for next time}
      {Create archive}
      try
        ReadmeStrings := TEasyStrings.Create;
        ReadmeStrings.LoadSaveAsUnicode := True;
        ReadmeStream := TMemoryStream.Create;
        try
          for Idx := 0 to ObjectView.Count-1 do                                                     {Create source streams}
            begin
            setlength(SrcStream, high(SrcStream)+2);
            SrcStream[Idx] := TMemoryStream.Create;
            end;
          ZipForge := TZipForge.Create(self);                                                       {Create zip object}
          if ProjectPlusIDE then                                                                    {Create exe stream, if necessary}
            ExeStream := TFileStream.Create(application.ExeName, fmOpenRead+fmShareDenyWrite);
          try
            try
              ZipForge.FileName := ArchiveName;                                                     {Create archive file, in memory, and add comments}
              ZipForge.InMemory := True;
              ZipForge.OpenArchive;
              //!!! Adjust this for P1 & P2
              ZipForge.Comment := #$D#$A#$D#$A+'PARALLAX INC PROPELLER 1 CHIP PROJECT ARCHIVE'+#$D#$A#$D#$A+'PROJECT: "'+ObjectView.Items[0].Text+'"'+#$D#$A+
                                  'ARCHIVED: '+FriendlyDateTime+#$D#$A+'TOOL: '+PropIDEName+' version '+GetVersionInfo(Application.ExeName, viVersion);
              try                                                                                   {Archive file created}
                BuildReadmeStrings;
                ReadmeStrings.SaveToStream(ReadmeStream);
                ZipForge.AddFromStream('_README_.txt', ReadmeStream, False, 0, 0, 0, ArchiveDateTime);{Add Readme as first item}
                for Idx := 0 to ObjectView.Count-1 do                                               {Add all project files to it}
                  begin
                  SrcName := PObjData(ObjectView.Items[Idx].Data)^.FullFilename;
                  if not PObjData(ObjectView.Items[Idx].Data)^.IsDataFile then                      {File is a source file?}
                    GetSource(SrcName).SaveToStream(SrcStream[Idx])                                 {  Get source and copy to stream}
                  else
                    begin                                                                           {File is a data file?}
                    SrcStream[Idx].SetSize(GetData(nil, SrcName, MAXINT));                          {  Set size of stream}
                    GetData(SrcStream[Idx].Memory, SrcName, SrcStream[Idx].Size);                   {  Copy file data to stream}
                    end;
                  ZipForge.AddFromStream(extractfilename(SrcName), SrcStream[Idx], False, 0, 0, GetSourceAttr(SrcName), GetSourceTimeStamp(SrcName, ArchiveDateTime));
                  end;
                if ProjectPlusIDE then                                                              {Add IDE exe if necessary}
                  ZipForge.AddFromStream(extractfilename(application.ExeName), ExeStream, False, 0, 0, SafeFileGetAttr(application.exename), FileDateToDateTime(FileAge(application.exename)));
                ZipForge.InMemory := False;
                ZipForge.CloseArchive;                                                              {Close archive}
              except                                                                                {Error?  Must be: cannot find file.}
                messagebeep(MB_ICONERROR);
                messagedlg('Cannot find object '''+ObjectView.Items[Idx].Text+'.''  Archive cannot be created.', mtError, [mbOk], 0);
                exit;
              end;
            except                                                                                  {Failed to create archive file}
              messagebeep(MB_ICONERROR);
              messagedlg('Cannot create zipped archive file '''+ArchiveName + '.zip.''', mtError, [mbOk], 0);
              exit;
            end;
          finally
            ZipForge.Free;                                                                          {Free zip object}
          end;
        finally
          if ProjectPlusIDE then ExeStream.Free;                                                    {Free IDE stream, if necessary}
          for Idx := 0 to high(SrcStream) do SrcStream[Idx].Free;                                   {Free source streams}
        end;
      finally
        ReadmeStream.Free;                                                                          {Free readme stream and strings}
        ReadmeStrings.Free;
      end;
    finally
      Editor.RestoreDialog;                                                                         {Restore SaveDialog settings}
    end;
  except {If communication in progress; reschedule this action}
    on ECommTerminatable do
      ScheduleFutureAction(atArchive, nil, ProjectPlusIDE);
    on ECommDownloading do
      MessageBeep(MB_ICONWARNING);
  end;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.MakeOpenDialogSelect(Sender: TObject);
{When assigned, this method temporarily intercepts the OpenDialog's OnShow event to change the Open button to a Select button.
 This makes it more clear that the user's action is selecting a (top) file rather than opening a file.}
var
  DlgHandle : HWnd;
  Str       : PChar;
begin
  getmem(Str,256);
  try
    strpcopy(Str, Editor.OpenDialog.Title);
    DlgHandle := FindWindowEx(Self.ClientHandle, 0, nil, Str);
    strcopy(str, '&Select');
    SetDlgItemText(DlgHandle, $0001, str);
  finally
    freemem(Str);
  end;
  Editor.OpenDialog.OnShow := OldOnShow;
  if assigned(OldOnShow) then OldOnShow(Sender);
end;

{------------------------------------------------------------------------------}

procedure TMainForm.FileListed(Sender: TObject; Filename: String; var Bold: Boolean);
{File is being listed, bold it if Top file}
begin
  Bold := uppercase(Filename) = uppercase(CPrefs[TopFile].SValue);
end;

{------------------------------------------------------------------------------}

procedure TMainForm.FileListContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
{File List's shortcut menu activated, hide Top File item unless only one file selected}
begin
  Editor.Explorer.FileListPopup.ItemOfID(flTopFile).Visible := (Editor.Explorer.FileCount = 1) and IsSpinSourceFile(Editor.Explorer.Filenames[0]);
end;

{------------------------------------------------------------------------------}

procedure TMainForm.EditTabContextPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
{Edit Tab's shortcut menu activated, hide New (From Template) items if template file(s) do not exist, and hide Top File and Archive items if this is a source file}
begin
  Editor.EditTabPopup.ItemOfID(etNewFromP1Template).Visible := SafeFileExists(CPrefs[NewP1FileTemplate].SValue);
  Editor.EditTabPopup.ItemOfID(etNewFromP2Template).Visible := SafeFileExists(CPrefs[NewP2FileTemplate].SValue);
  Editor.EditTabPopup.ItemOfID(etTopFile).Visible := Editor.ActiveTabSheet.CustomTag1 <> ord(vmStandard);
  Editor.EditTabPopup.ItemOfID(etArchive).Visible := Editor.ActiveTabSheet.CustomTag1 <> ord(vmStandard);
end;

{------------------------------------------------------------------------------}

procedure TMainForm.DoCustomDraw(Sender: TObject; Canvas: TCanvas; const Rect: TRect; Line, Char: integer; const S: TEasyString; DrawStates: TEasyDrawStates; LineState: Integer; var Handled: Boolean);
{Draw flow control lines for IF, ELSEIF, ELSE, REPEAT, CASE, etc.}
var
  L         : TLineSpecs; {Hold line spec results from IsExeLine}
  CaseLevel : Integer;    {0 = not at "case" conditional block level, 1 = }
const
  Comment         : set of TokenStyle = [CONaCodeComment, CONbCodeComment, CONaDocComment, CONbDocComment,
                                         DATaCodeComment, DATbCodeComment, DATaDocComment, DATbDocComment,
                                         OBJaCodeComment, OBJbCodeComment, OBJaDocComment, OBJbDocComment,
                                         PUBaCodeComment, PUBbCodeComment, PUBaDocComment, PUBbDocComment,
                                         PRIaCodeComment, PRIbCodeComment, PRIaDocComment, PRIbDocComment,
                                         VARaCodeComment, VARbCodeComment, VARaDocComment, VARbDocComment];
  BlockStart      : set of TokenStyle = [PUBaBlock, PUBbBlock, PRIaBlock, PRIbBlock];
  BGConditional   : set of TokenStyle = [PUBaHLCondIf1,   PUBbHLCondIf1,   PUBaHLCondIf2,   PUBbHLCondIf2,   PUBaHLCondIf3,  PUBbHLCondIf3,
                                         PUBaHLCondCase1, PUBbHLCondCase1, PUBaHLCondCase2, PUBbHLCondCase2,
                                         PUBaHLCondLoop1, PUBbHLCondLoop1,
                                         PRIaHLCondIf1,   PRIbHLCondIf1,   PRIaHLCondIf2,   PRIbHLCondIf2,   PRIaHLCondIf3,  PRIbHLCondIf3,
                                         PRIaHLCondCase1, PRIbHLCondCase1, PRIaHLCondCase2, PRIbHLCondCase2,
                                         PRIaHLCondLoop1, PRIbHLCondLoop1];
  {Block Group Case}
  BGCase          : set of TokenStyle = [PUBaHLCondCase1, PUBbHLCondCase1,
                                         PRIaHLCondCase1, PRIbHLCondCase1];
  {Block Group ElseIf, Else, While or Until}
  BGEIEWU         : set of TokenStyle = [PUBaHLCondIf2,   PUBbHLCondIf2,   PUBaHLCondIf3,  PUBbHLCondIf3,
                                         PUBaHLCondLoop2, PUBbHLCondLoop2,
                                         PRIaHLCondIf2,   PRIbHLCondIf2,   PRIaHLCondIf3,  PRIbHLCondIf3,
                                         PRIaHLCondLoop2, PRIbHLCondLoop2];
  {Repeat}
  RepeatToken     : set of TokenStyle = [PUBaHLCondLoop1, PUBbHLCondLoop1, PRIaHLCondLoop1, PRIbHLCondLoop1];
  {While or Until}
  WhiteUntilToken : set of TokenStyle = [PUBaHLCondLoop2, PUBbHLCondLoop2, PRIaHLCondLoop2, PRIbHLCondLoop2];
  {If}
  IfToken         : set of TokenStyle = [PUBaHLCondIf1,   PUBbHLCondIf1,   PRIaHLCondIf1,   PRIbHLCondIf1];
  {ElseIf}
  ElseIfToken     : set of TokenStyle = [PUBaHLCondIf2,   PUBbHLCondIf2,   PRIaHLCondIf2,   PRIbHLCondIf2];
  {Else}
  ElseToken       : set of TokenStyle = [PUBaHLCondIf3,   PUBbHLCondIf3,   PRIaHLCondIf3,   PRIbHLCondIf3];
  {Symbols}
  Symbols         : set of byte       = [ord('!'), ord('#'), ord('&'), ord('*'), ord('+'), ord('-'), ord('/'), ord(':'), ord(';'),
                                         ord('<'), ord('='), ord('>'), ord('?'), ord('\'), ord('^'), ord('|'), ord('~')];

    {---------------------}

    function ExeLine(SLine: Integer; var L: TLineSpecs): Boolean;
    {Scan SLine and return True if line is in PUB or PRI block and has executable content (compiled content) or False if no executable content found
     (could still be a PUB or PRI block, however). L's IsPubPri is False if neither PUB or PRI line, or True otherwise.  L's Token array is filled
     with the indexes and tokens of the first non-whitespace char/token, first executable char/token and second executable char/token, respectively.
     Note: The second executable char/token is after a ':' (if any) following the first executable char/token.}
    var
      Idx     : Integer;
      Str     : TEasyString;
      Len     : Integer;

          {---------------------}

          procedure ClearToken;
          {Clear L.Token in element Idx.}
          begin
            L.Token[Idx].Idx := 0;
            L.Token[Idx].ID := TokenStyle(0);
          end;

          {---------------------}

          function GetToken(var T: TLineToken): TokenStyle;
          {Set T.ID to token ID at (SLine, T.Idx) and also return that value}
          begin
            T.ID := TokenStyle(TPCustomEasyEdit(Sender).Lines.GetData(SLine, T.Idx));
            Result := T.ID;
          end;

          {---------------------}

    begin
      Result := False;
      for Idx := low(L.Token) to high(L.Token) do ClearToken;
      {Exit if not a PUB or PRI line}
      L.IsPubPri := ParserState(TPCustomEasyEdit(Sender).Lines.GetState(SLine)) in Method;
      if not L.IsPubPri then exit;
      {Get line}
      Str := TPCustomEasyEdit(Sender).Lines[SLine];
      Len := length(Str);
      {Exit if blank}
      if Len = 0 then exit;
      {Find first non-whitespace character/token}
      repeat
        inc(L.Token[1].Idx);
        inc(L.Token[2].Idx);
        inc(L.Token[3].Idx);
      until (L.Token[1].Idx > Len) or not (word(Str[L.Token[1].Idx]) in [9, 32]);
      {Find first executable character/token}
      while not (L.Token[2].Idx > Len) and ( (word(Str[L.Token[2].Idx]) in [9, 32]) or (GetToken(L.Token[2]) in Comment) ) do
        begin
        inc(L.Token[2].Idx);
        inc(L.Token[3].Idx);
        end;
      {Find second executable character/token (after ':', if any)}
      if not (L.Token[3].Idx > Len) then
        begin
        repeat
          while not (L.Token[3].Idx > Len) and not ( not (GetToken(L.Token[3]) in Comment) and (Str[L.Token[3].Idx] = widechar(':')) ) do inc(L.Token[3].Idx);
          inc(L.Token[3].Idx);
        until (L.Token[3].Idx > Len) or not (word(Str[L.Token[3].Idx]) in Symbols);
        if not (L.Token[3].Idx > Len) then
          while not (L.Token[3].Idx > Len) and ( (word(Str[L.Token[3].Idx]) in [9, 32]) or (GetToken(L.Token[3]) in Comment) ) do inc(L.Token[3].Idx);
        end;
      {Validate results}
      for Idx := low(L.Token) to high(L.Token) do if L.Token[Idx].Idx > Len then ClearToken;
      Result := Boolean(L.Token[2].Idx);
    end;

    {---------------------}

    function PubPriStart(SLine: Integer; var L: TLineSpecs): Boolean;
    {Returns True if SLine is start of a PUB or PRI block (or if SLine out of range), False otherwise.}
    begin
      Result := (SLine < 0) or (SLine > TPCustomEasyEdit(Sender).LineCount-1) or (ExeLine(SLine, L) and (L.Token[2].ID in BlockStart));
    end;

    {---------------------}

    procedure BuildBlockGroup;
    {Update BlockGroup records if SLine is a conditional block start line}
    var
      SLine : Integer;
      BGIdx : Integer;

          {---------------------}

          procedure NewBlock(TokenNum: Integer; CaseRoot: Boolean);
          {Add new block group.  TokenNum is the number 1, 2, or 3, of the L.Token to use.}
          begin
            BGIdx := high(BG)+1;
            setlength(BG, BGIdx+1);
            BG[BGIdx].ID := L.Token[TokenNum].ID;
            BG[BGIdx].RowStart := SLine;
            BG[BGIdx].RowEnd := SLine;
            BG[BGIdx].Column := L.Token[TokenNum].Idx;
            if CaseRoot then
              begin
              BG[BGIdx].CaseLevel := 2; {If line in Case Root (case level 1), mark as case 2}
              if (L.Token[3].ID in BGConditional) then NewBlock(3, False);
              end
            else
              if L.Token[TokenNum].ID in BGCase then BG[BGIdx].CaseLevel := 1;
          end;

          {---------------------}

          function ConditionalPair: Boolean;
          {Check current token against block group's token and return True if it forms a conditional pair (IF..ELSEIF, IF..ELSE, etc.), False otherwise}
          begin
            Result := False;
            if not ((L.Token[2].ID in BGEIEWU) and (L.Token[2].Idx = BG[BGIdx].Column)) then exit;
            case L.Token[2].ID of
              PUBaHLCondIf2,                                                       {ELSEIF after IF or ELSEIF?}
              PUBbHLCondIf2,
              PRIaHLCondIf2,
              PRIbHLCondIf2   : Result := BG[BGIdx].ID in IfToken + ElseIfToken;

              PUBaHLCondIf3,                                                       {ELSE after IF or ELSEIF?}
              PUBbHLCondIf3,
              PRIaHLCondIf3,
              PRIbHLCondIf3   : Result := BG[BGIdx].ID in IfToken + ElseIfToken;

              PUBaHLCondLoop2,                                                     {WHILE or UNTIL after REPEAT?}
              PUBbHLCondLoop2,
              PRIaHLCondLoop2,
              PRIbHLCondLoop2 : Result := BG[BGIdx].ID in RepeatToken;
            end;
          end;

          {---------------------}

    begin
      {Clear previous Block Groups}
      setlength(BG, 0);
      {Scan to top of PUB/PRI, record background color}
      SLine := Line;
      while not PubPriStart(SLine, L) do dec(SLine);
      CDState.BlockColor := GetStyleAttribute(L.Token[2].ID, BgClr);        {Get block's background color}
      while not PubPriStart(SLine+1, L) do
        begin {Scan all lines to bottom of this PUB/PRI}
        inc(SLine);
        {Find latest block group this line belong to}
        BGIdx := high(BG);
        while (BGIdx > -1) and (BG[BGIdx].Complete or not ( ConditionalPair or (L.Token[2].Idx > BG[BGIdx].Column) ) ) do
          begin {Line not in this block group}
          BG[BGIdx].Complete := BG[BGIdx].Complete or (L.Token[2].Idx > 0); {Mark block-group complete, if necessary}
          dec(BGIdx);                                                       {Move to previous group}
          end;
        {Include this line, if within group}
        CaseLevel := 0;
        if BGIdx > -1 then
          begin
          BG[BGIdx].RowEnd := SLine;                                        {Mark this line as being in found block group}
          if ConditionalPair then
            begin {If this is a conditional pair (IF..ELSEIF, IF..ELSE, REPEAT..WHILE, etc), set flag and mark group complete}
            BG[BGIdx].EndIsEIEWU := True;
            BG[BGIdx].Complete := True;
            end;
          CaseLevel := BG[BGIdx].CaseLevel;                                 {Remember case level for exception scenerio, below}
          end;
        {If line starts new group, add new group}
        if (L.Token[2].ID in BGConditional) or (CaseLevel = 1) then NewBlock(2, CaseLevel = 1);
        end;
      CDState.BlockEnd := SLine;
    end;

    {---------------------}

    procedure DrawBlockLine;
    {Draw block-group line, if necessary}
    var
      Idx             : Integer;
      X, Y, BGIdx     : Integer;
      CWidth, LHeight : Integer;    {Font character width and line height}
      LeftIndent      : Integer;    {Indent from left edge of edit control}
      BGLWidth        : Integer;    {Block-group line width}
      BGLMin, BGLMax  : Integer;    {The minimum and maximum offsets from center of the block-group line}

          {---------------------}

          procedure DrawHorizontal;
          {Draw horizontal line with arrowhead}
          var
            X1, X2, Y : Integer;
          begin
            X1 := LeftIndent + CWidth*(BG[BGIdx].Column-1-TPCustomEasyEdit(Sender).WindowChar) + CWidth div 2;
            X2 := X1+(L.Token[2].Idx-BG[BGIdx].Column)*CWidth - Trunc(CWidth * 0.50);
            Y := Rect.Bottom - (LHeight div 2);
            {Draw main line followed by arrowhead}
            Canvas.Rectangle(X1-BGLMin, Y-BGLMax, X2-BGLMax, Y+BGLMin);
            Idx := BGLMin-1;
            while Idx > 0 do
              begin
              Canvas.Rectangle(X2-BGLMax-1, Y-Idx+1, X2-BGLMax+BGLMin-Idx, Y+Idx);
              dec(Idx);
              end;
          end;

          {---------------------}

          procedure DrawVertical;
          {Draw vertical line.  May be corner piece or tee intersection.}
          var
            IArrow : Boolean;
            Corner : Boolean;
            DArrow : Boolean;
          begin
            IArrow :=                           BG[BGIdx].RowStart+1 = Line;
            Corner :=                           BG[BGIdx].RowEnd     = Line;
            DArrow := BG[BGIdx].EndIsEIEWU and (BG[BGIdx].RowEnd - 1 <= Line);
            X := LeftIndent + CWidth*(BG[BGIdx].Column-1-TPCustomEasyEdit(Sender).WindowChar) + CWidth div 2;
            Y := Rect.Top + BGLMax*ord(IArrow);
            if not (Corner and BG[BGIdx].EndIsEIEWU) then
              begin
              {Draw main line}
              Canvas.Rectangle(X-BGLMin, Y, X+BGLMax, Rect.Bottom - (LHeight div 2)*ord(Corner) - (BGLMax-2)*ord(DArrow));
              if IArrow then
                begin {Draw inverse arrowhead at beginning of line}
                Idx := 1;
                while Idx < BGLMin do
                  begin
                  Canvas.Rectangle(X-BGLMin, Y-Idx, X-Idx, Y-Idx+2);
                  Canvas.Rectangle(X+Idx-1, Y-Idx, X+BGLMax, Y-Idx+2);
                  inc(Idx);
                  end;
                end;
              end;
            if DArrow then
              begin {Draw arrowhead at end of line}
              if not (Corner and BG[BGIdx].EndIsEIEWU) then Y := Rect.Bottom - (BGLMax-1) else Y:= Rect.Top - BGLMax + 2;
              Idx := 1;
              while Idx < BGLMin do
                begin
                Canvas.Rectangle(X-BGLMin+Idx, Y, X+BGLMax-Idx, Y+Idx);
                inc(Idx);
                end;
              end;
          end;

          {---------------------}

    begin
      {Exit if no block-group records}
      if (high(BG) < 0) then exit;
      ExeLine(Line, L);
      {Find last block-group that contains this line}
      BGIdx := high(BG);
      while (BGIdx > -1) and ((Line <= BG[BGIdx].RowStart) or (Line > BG[BGIdx].RowEnd)) do dec(BGIdx);
      {Exit if line not in block-group}
      if BGIdx = -1 then exit;
      {Otherwise, draw block-group line(s)}
      LeftIndent := TPCustomEasyEdit(Sender).LeftIndent;
      CWidth := TPCustomEasyEdit(Sender).Painter.GetDefaultCharWidth;
      LHeight := TPCustomEasyEdit(Sender).Painter.GetDefaultLineHeight;
      BGLWidth := (CWidth div 2) or 1;
      BGLMin := Trunc(SimpleRoundTo(BGLWidth / 2, 0));
      BGLMax := BGLWidth-BGLMin;
      Canvas.Pen.Color := BlendColors(CDState.BlockColor, clBlack, 0.09);
      Canvas.Brush.Color := Canvas.Pen.Color;
      {Draw this line's horizontal connector, if any}
      if (L.Token[2].Idx > 0) and (not (L.Token[2].ID in BGEIEWU) or (L.Token[2].Idx > BG[BGIdx].Column)) then DrawHorizontal;
      {Draw this line's vertical (if any) and ancestor vertical(s) (if any)}
      while (BGIdx > -1) do
        begin
        if (Line > BG[BGIdx].RowStart) and (Line <= BG[BGIdx].RowEnd) then DrawVertical;
        dec(BGIdx);
        end;
      Canvas.Pen.Color := clWhite;
      Canvas.Brush.Color := Canvas.Pen.Color;
    end;

    {---------------------}

begin
//  if CPrefs[ShowBlockIndentions].BValue and ( (ParserState(LineState) in Method) and (DrawStates * [csdAfterPaint, csdText] = [csdAfterPaint, csdText]) ) then
//    begin
//    Canvas.Pen.Color := clRed;
//    Canvas.MoveTo(Rect.Left, Rect.Top);
//    Canvas.LineTo(Rect.Right, Rect.Bottom);
//    end;
  if not CPrefs[ShowBlockIndentions].BValue or not ( (ParserState(LineState) in Method) and (DrawStates * [csdAfterPaint, csdAfterText] = [csdAfterPaint, csdAfterText]) ) then exit;
  {Line is part of PUB or PRI block and is painted completely; if in indented block(s) then draw block-group lines accordingly}
  if Line <> CDState.NextLine then BuildBlockGroup; {This is not a continuation of the previous paint operation; build BlockGroup records for Line's PUB/PRI}
  DrawBlockLine;
  if Line < CDState.BlockEnd then CDState.NextLine := Line+1;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.UpdateBlockIndentionsVisible;
{Make block group indicators visible/invisible according to preferences}
begin
  Editor.RepaintEdits;
  {Update Preferences' Block Group Indicators checkbox, in case it's open}
  Preferences.ShowBlockGroupIndicatorsCheckbox.Checked := CPrefs[ShowBlockIndentions].BValue;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.UpdateBookmarksVisible;
{Make bookmarks visible/invisible according to preferences}
begin
  Editor.BookmarksEnabled := CPrefs[ShowBookmarks].BValue;
  GotoBookmarkItem.Visible := CPrefs[ShowBookmarks].BValue;
  {Update Preferences' bookmark checkbox, in case it's open}
  Preferences.ShowBookmarksCheckbox.Checked := CPrefs[ShowBookmarks].BValue;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.UpdateLineNumbersVisible;
{Make line numbers visible/invisible according to preferences}
begin
  Editor.LineNumbersVisible := CPrefs[ShowLineNumbers].BValue;
  {Update Preferences' line numbers checkbox, in case it's open}
  Preferences.ShowLineNumbersCheckbox.Checked := CPrefs[ShowLineNumbers].BValue;
end;

{------------------------------------------------------------------------------}

function TMainForm.ReadPortRulesPreference(Sender: TObject; Default: Boolean): String;
{TPortMetrics object is requesting Port Rules Preference, or the default Port Rules Preference.}
begin
  Result := ifthen(not Default, CPrefs[SerialSearchRules].SValue, DPrefs[SerialSearchRules].SValue);
end;

{------------------------------------------------------------------------------}

procedure TMainForm.WritePortRulesPreference(Sender: TObject; PortRules: String);
{TPortMetrics object is requesting to write Port Rule Preference}
begin
  if CPrefs[SerialSearchRules].SValue = PortRules then exit;
  CPrefs[SerialSearchRules].SValue := PortRules;
  PrefsHaveChanged := True;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.LoadParserRules;
{Get rules for P1 and P2 syntax highlighting from root folder or embedded resource}

  {----------------}

  procedure LoadRules(FileName: String; ResourceID: Cardinal; SyntaxID: Cardinal);
  var
    Stream : TResourceStream;
  begin
    Editor.SyntaxParsers[SyntaxID].UseDefaultColor := False;
    if SafeFileExists(FileName) then  {Syntax Highlighting Rules in root folder?  It overrides local resource rules}
      Editor.SyntaxParsers[SyntaxID].Rules.LoadFromFile(FileName)
    else
      if FindResource(hInstance, PChar(ResourceID), 'STRING') <> 0 then
        begin {Syntax Highlighting Rules string resource exists}
        Stream := TResourceStream.CreateFromID(hInstance, ResourceID, 'STRING');
        Editor.SyntaxParsers[SyntaxID].Rules.LoadFromStream(Stream);
        Stream.Free;
        end;
  end;

  {----------------}

begin
  LoadRules(P1ParserRulesFile, P1SyntaxRulesID, sID[P1]);
  LoadRules(P2ParserRulesFile, P2SyntaxRulesID, sID[P2]);
  UpdateStyles;
  Editor.SyntaxParsers.Enabled := True;
end;

{oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo}
{oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo}
{oooooooooooooooooooooooooooo Non-Event Routines oooooooooooooooooooooooooooooo}
{oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo}
{oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo}

procedure TMainForm.CreateNewFromTemplate(PropModel: TPropModel);
{Create new edit from template.
  PropModel must be P1 or P2.}
var
  TemplateFile : String;
begin
  TemplateFile := ifthen(PropModel = P1, CPrefs[NewP1FileTemplate].SValue, CPrefs[NewP2FileTemplate].SValue);
  if not SafeFileExists(TemplateFile) then exit;                                                               {NOTE: We check if file exists here because preference could have changed and shortcut key used (preventing enable/disable of menu item prior to this call)}
  if not ((Editor.EditSheet[Editor.ActiveIdx].FullFilename = '') and (Editor.ActiveEdit.Lines.Text = '')) then
    Editor.New(nil, True);                                                                                     {Create new edit if necessary}
  Editor.ActiveEdit.Lines.LoadFromFile(TemplateFile);                                                          {Load template into edit}
end;

{------------------------------------------------------------------------------}

procedure TMainForm.ShowHideExplorer;
{Show / Hide Explorer}
begin
  Editor.Explorer.Visible := not Editor.Explorer.Visible;
  CPrefs[ExplorerVisible].BValue := Editor.Explorer.Visible;
  PrefsHaveChanged := True;
//  ExploreButton.Down := Down;
  if Editor.Explorer.Visible then
    begin
    HideExplorerItem.Caption := 'Hide &Explorer';
    HideExplorerItem.Hint := 'Hide the explorer panel';
    end
  else
    begin
    HideExplorerItem.Caption := 'Show &Explorer';
    HideExplorerItem.Hint := 'Show the explorer panel';
    end;
//  ExploreButton.Hint := Explore1.Hint;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.AddFileToHistory(Filename: String);
{Adds FileName to history list, unless that name already exists in the list}
begin
  if IndexOfFileFromHistory(Filename) = -1 then
    begin {File is not already in the list}
    if FileHistory.Count = 10 then FileHistory.Delete(9); {If FileHistory is full, delete the last item}
    FileHistory.Insert(0, Filename);  {Insert new item at top of list}
    end
  else    {File is already in the list, move it to the top of the list}
    FileHistory.Move(IndexOfFileFromHistory(Filename), 0);
  {Update the File Menu History while maintaining history's enabled status}
  UpdateMenuHistory(FileMenu.Items[FileMenu.IndexOf(Break05) + 1].Enabled);
  {Flag Preferences}
  PrefsHaveChanged := True;
end;

{------------------------------------------------------------------------------}
//!!
(*
procedure TMainForm.DeleteFileFromHistory(Filename: String);
{Deletes FileName from history list}
begin
  if not (IndexOfFileFromHistory(Filename) = -1) then
    begin {File is in the list}
    FileHistory.Delete(IndexOfFileFromHistory(Filename));
    PrefsHaveChanged := True; {Flag Preferences}
    end;
  UpdateMenuHistory(True);    {Update the File Menu History}
end;
*)
{------------------------------------------------------------------------------}

procedure TMainForm.UpdateMenuHistory(Enabled: Boolean);
{Updates File menu's history section (both files and directories) with current items in history list}
var
  MenuItem : TMenuItem;
  MenuItem2: TMenuItem;
  Location : Integer;
  Idx1     : Integer;
  Idx2     : Integer;
  Files    : Integer;
  Unique   : TStrings;
  Path     : String;
begin
  Unique := TStringList.Create;
  {Update file history list}
  Idx1 := FileMenu.IndexOf(Break05) + 1;  {Break05 is the file menu separator}
  Idx2 := FileMenu.IndexOf(Break06);
  for Location := Idx1 to Idx2-1 do FileMenu.Delete(Idx1); {Delete all history items from menu}
  if FileHistory.Count > 0 then
    begin {We have history items to add}
    Files := min(10, FileHistory.Count);
    for Location := 0 to Files-1 do
      begin {For each item, create item as just file name and create hint as full path and file}
      MenuItem := TMenuItem.Create(FileMenu);
      MenuItem.Caption := '&' + IntToStr(Location+1) + '  ' + ExtractFilename(GetFileFromHistory(Location));
      MenuItem.Hint := GetFileFromHistory(Location);
      MenuItem.OnClick := OpenFromHistory;
      MenuItem.Enabled := Enabled;
      FileMenu.Insert(Idx1 + Location, MenuItem);
      end;
    end;

  {Update all three folder history lists (Open From... Save To... and Recent Folders)}
  while OpenFromItem.Count > 0 do begin OpenFromItem.Delete(0); SaveToItem.Delete(0); end; {Delete previous folder history items}
  Editor.FolderHistory.AutoUpdate := False;                                                {Disable auto updating of Recent Folders}
  Editor.FolderHistory.Clear;                                                              {Delete previous Recent Folders}

  {Add Library Directory to folders lists}
  if SafeDirectoryExists(UDPath+'Library\') then
    AddDefaultFavorite(UDPath+'Library', 'Propeller Library', Unique);
  {Add Library\_Demos Directory to folders lists}
  if SafeDirectoryExists(UDPath+'Library\_Demos\') then
    AddDefaultFavorite(UDPath+'Library\_Demos', 'Propeller Library - Demos', Unique);
  {Add Examples\Help Directory to folders lists}
  if SafeDirectoryExists(UDPath+'Examples\Help\') then
    AddDefaultFavorite(UDPath+'Examples\Help', 'Help - Examples', Unique);
  {Add Examples\PE Kit Directory to folders lists}
  if SafeDirectoryExists(UDPath+'Examples\PE Kit\') then
    AddDefaultFavorite(UDPath+'Examples\PE Kit', 'PE Kit - Examples', Unique);

  Idx1 := -1;
  if Unique.Count > 0 then
    begin {If there were favorite directories, add item separator}
    MenuItem := TMenuItem.Create(OpenFromItem);
    MenuItem2 := TMenuItem.Create(SaveToItem);
    MenuItem.Caption := '-';
    MenuItem2.Caption := '-';
    OpenFromItem.Add(MenuItem);
    SaveToItem.Add(MenuItem2);
    Idx1 := Unique.Count;
    end;

(*  {Favorite Directories}
  Idx2 := 0;
  while (Idx2 < 10) and (CPrefs[PrefEntity(ord(FavoriteFolder01)+Idx2)].SValue <> '') do
    begin  {Loop for all Favoite Folder records}
    Path := ExtractFilePath(GetFavoriteFolder(Idx2));
    MenuItem := TMenuItem.Create(OpenFrom1);
    MenuItem2 := TMenuItem.Create(SaveTo1);
    {Show actual folder path}
    if GetFavoriteName(Idx2) <> '' then MenuItem.Caption := GetFavoriteName(Idx2) else MenuItem.Caption := Path;
    MenuItem2.Caption := MenuItem.Caption;
    if Unique.Count = Idx1 then Edit.FolderHistory.Add('&') else Edit.FolderHistory.Add('');
    if (GetFavoriteName(Idx2) <> '') then Edit.FolderHistory.Strings[Edit.FolderHistory.Count-1] := Edit.FolderHistory.Strings[Edit.FolderHistory.Count-1] + GetFavoriteName(Idx2) + '|';
    Edit.FolderHistory.Strings[Edit.FolderHistory.Count-1] := Edit.FolderHistory.Strings[Edit.FolderHistory.Count-1] + ExcludeTrailingPathDelimiter(Path);
    {Enter hint with full folder path}
    MenuItem.Hint := 'Open a file from folder: '+Path;
    MenuItem2.Hint := 'Save the current file to folder: '+Path;
    {Keep Track of Unique strings and finish configuring menu items}
    if Unique.IndexOf(Path) = -1 then Unique.Add(Path);
    MenuItem.OnClick := Open1Click;
    MenuItem2.OnClick := SaveAs1Click;
    OpenFrom1.Add(MenuItem);
    SaveTo1.Add(MenuItem2);
    inc(Idx2);
    end;

  Idx1 := -1;
  if Unique.Count > 0 then
    begin {If there were favorite directories, add item separator}
    MenuItem := TMenuItem.Create(OpenFrom1);
    MenuItem2 := TMenuItem.Create(SaveTo1);
    MenuItem.Caption := '-';
    MenuItem2.Caption := '-';
    OpenFrom1.Add(MenuItem);
    SaveTo1.Add(MenuItem2);
    Idx1 := Unique.Count;
    end;*)

  {Recent file history}
  for Idx2 := 0 to FileHistory.Count-1 do
    begin  {Loop for all file history records}
    Path := ExtractFilePath(GetFileFromHistory(Idx2));
    if Unique.IndexOf(Path) <> -1 then continue; {If item is not unique, just continue, otherwise we'll create an item}
    MenuItem := TMenuItem.Create(OpenFromItem);
    MenuItem2 := TMenuItem.Create(SaveToItem);
    {Show actual folder path}
    MenuItem.Caption := Path;
    MenuItem2.Caption := Path;
    MenuItem.Tag := OpenFromItem.Tag;
    MenuItem2.Tag := SaveToItem.Tag;
    if Unique.Count = Idx1 then
      Editor.FolderHistory.Add('&'+ExcludeTrailingPathDelimiter(Path))  {Add item separator indicator plus item}
    else
      Editor.FolderHistory.Add(ExcludeTrailingPathDelimiter(Path));     {or just add item}
    {Enter hint with full folder path}
    MenuItem.Hint := 'Open a file from folder: '+Path;
    MenuItem2.Hint := 'Save the current file to folder: '+Path;
    {Keep Track of Unique strings and finish configuring menu items}
    if Unique.IndexOf(Path) = -1 then Unique.Add(Path);
    MenuItem.OnClick := FileMenuItemClick;
    MenuItem2.OnClick := FileMenuItemClick;
    OpenFromItem.Add(MenuItem);
    SaveToItem.Add(MenuItem2);
    end;
  {Enable/Disable menu items based on whether there are fly-out menu items or not}
  OpenFromItem.Enabled := OpenFromItem.Count > 0;
  SaveToItem.Enabled := SaveToItem.Count > 0;
  {Re-enable auto updating of Recent Folders}
  Editor.FolderHistory.AutoUpdate := True;
  {Free memory}
  Unique.Free;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.OpenFromHistory(Sender: TObject);
{Open file from history list}
var
  Idx : Integer;
begin
  Idx := FileMenu.IndexOf(TMenuItem(Sender)) - FileMenu.IndexOf(Break05) - 1;
  Editor.Open(GetFileFromHistory(Idx), '', nil, True, False);
end;

{------------------------------------------------------------------------------}

procedure TMainForm.AddDefaultFavorite(Path, Caption: String; UniqueList: TStrings);
{Add default folder to favorites}
var
  MenuItem : TMenuItem;
  MenuItem2: TMenuItem;
begin
  if not SafeDirectoryExists(Path) then exit;
  {Add Library Directory to folders lists}
  MenuItem := TMenuItem.Create(OpenFromItem);
  MenuItem2 := TMenuItem.Create(SaveToItem);
  {Set caption and actual folder path}
  MenuItem.Caption := Caption;
  MenuItem2.Caption := Caption;
  MenuItem.Tag := OpenFromItem.Tag;
  MenuItem2.Tag := SaveToItem.Tag;
  Editor.FolderHistory.Add(Caption + '|' + ExcludeTrailingPathDelimiter(Path));
  {Enter hint with full folder path}
  MenuItem.Hint := 'Open a file from folder: '+ Path;
  MenuItem2.Hint := 'Save the current file to folder: '+ Path;
  {Keep Track of Unique strings and finish configuring menu items}
  if UniqueList.IndexOf(Path) = -1 then UniqueList.Add(Path);
  MenuItem.OnClick := FileMenuItemClick;
  MenuItem2.OnClick := FileMenuItemClick;
  OpenFromItem.Add(MenuItem);
  SaveToItem.Add(MenuItem2);
end;

{------------------------------------------------------------------------------}

procedure TMainForm.OpenFromSaveTo(MenuItem: TMenuItem; Open: Boolean);
{Open file from folder}
var
  Idx : Integer;
begin
  Idx := pos(':', MenuItem.Hint);
  if Open then
    Editor.Open('', IncludeTrailingPathDelimiter(copy(MenuItem.Hint, Idx+2, length(MenuItem.Hint)-Idx)), nil, True, False)
  else
    Editor.SaveAs(IncludeTrailingPathDelimiter(copy(MenuItem.Hint, Idx+2, length(MenuItem.Hint)-Idx)));
end;

{------------------------------------------------------------------------------}

procedure TMainForm.FontSized(Sender: TObject; Size: Integer);
{Font size changed}
begin
  SetStatusBarText('Font size changed to: '+inttostr(Size)+' pt.');
  CPrefs[FontSize].IValue := Size;
  PrefsHaveChanged := True;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.CursorPositionChanged(Sender: TObject; EditPos: TPoint; SourcePos: Integer);
{Cursor postion changed}
begin
  UpdateInfoStatus;
end;

{------------------------------------------------------------------------------}

function TMainForm.ValidateOrInstallFont(var FaceName: String): Boolean;
{Checks the installation of the font FaceName.  Returns true if font is installed and okay to use it, false otherwise.}
var
  ResStream   : TResourceStream;     {Resource stream (holds internal font resource)}
  CurrVersion : String;              {Version of internal (current) font}
  InstVersion : String;              {Version of installed font, if any}
  FontsFolder : PChar;               {Typically C:\Windows\Fonts}
  MemStream   : TMemoryStream;       {Memory stream (holds installed font data)}

    {---------------------------------}

    function FindPosInFont(Buffer: PByteArray; BuffLen: Int64; Str: String; var Pos: Int64): Boolean;
    {Returns True if Str (case sensitive) found in Buffer of size BuffLen and returns position of first matching character in Pos.
     Returns False otherwise.  Note, while Str is a string, the data it is meant to match is a wide string, so Str is always
     converted to a wide string before the search.  Also, there is no guarantee that the widestring data is word-aligned, so it
     must be searched on a byte-by-byte basis.}
    var
      WStrLen, CIdx : Integer;
      NoMatch       : Integer;
      WStr          : WideString;
    begin
      Pos := 0;
      CIdx := 1;
      WStr := Str;                                                                  {Convert string to wide string}
      WStrLen := length(WStr)*2;                                                    {Get WStr size (in bytes)}
      while (Pos < BuffLen) and (CIdx < WStrLen) do                                 {Search whole buffer until complete WStr found}
        begin
        NoMatch := ord(Buffer[Pos] <> PByteArray(@WStr[1])[CIdx]);                    {Not match?}
        Pos := Pos + 1 - (CIdx-1)*NoMatch;                                            {Inc buffer Idx (unless NoMatch and CIdx>1, then dec Idx by CIdx-1 to restart search)}
        CIdx := NoMatch + (CIdx+1)*(NoMatch xor 1);                                   {Reset WStr Idx if NoMatch, else inc it}
        end;
      Result := CIdx = WStrLen;
      if Result then dec(Pos, WStrLen) else Pos := -1;                              {WStr found?  Return True and position where found, else return False and -1}
    end;

    {---------------------------------}

    function GetFontVersion(MemStream: TCustomMemoryStream; var Version: String): Boolean;
    {Returns True if version of font (whose data is in MemStream) was found (False otherwise) and returns font version in Version.}
    const
      VerHeader  = 'Version '; {Text preceeding version number string in font file}
    var
      Pos : Int64;
      WBuffer  : PByteArray;
    begin
      Result := False;
      Version := '';
      WBuffer := MemStream.Memory;
      if not FindPosInFont(WBuffer, MemStream.Size, VerHeader, Pos) then exit;                   {Find Version header in font}
      inc(Pos, length(VerHeader)*2);                                                             {Move past version header}
      while (Pos < MemStream.Size) and not ((WBuffer[Pos] = $20) and (WBuffer[Pos+1] = $00)) do  {Read version number string (ends in ' ')}
        begin
        Version := Version + Char(WBuffer[Pos]);
        inc(Pos, 2);
        end;
      Result := (Pos < MemStream.Size) and ((WBuffer[Pos] = $20) and (WBuffer[Pos+1] = $00));    {Found full version number?}
    end;

    {---------------------------------}

    function InstallFont(TryPermanent: Boolean): Boolean;
    {Install font in Fonts folder or as a temporary font (in AppData folder)}

        {---------------------------------}
    
        function AddFont(Temporary: Boolean): Boolean;
        {Adds the FontFile, in FontsFolder, to the Windows Font Table.  Returns true if successful, false otherwise.  Temporary, if true,
         adds the font as a temporary font resource}
        var
          Reg : TRegistry;
          Num : Int64;
        begin
          if Temporary then
            begin
            MemStream.CopyFrom(ResStream, ResStream.Size);
            if not FindPosInFont(MemStream.Memory, MemStream.Size, PrivNameRepl[0], Num) then abort;
            MemStream.Seek(Num, soFromBeginning);
            MemStream.WriteBuffer(PrivNameRepl[1][1], length(PrivNameRepl[1])*2);
            if (AddFontMemResourceEx(MemStream.Memory, MemStream.Size, nil, @Num) = 0) and (Num <> 1) then abort;
            end
          else
            begin
            ResStream.SaveToFile(FontsFolder+FontFile);
            if AddFontResourceEx(PChar(FontsFolder+FontFile), 0, nil) = 0 then
              begin {Failed to add font, remove it from fonts folder}
              DeleteFile(StrPas(FontsFolder)+FontFile);
              abort;
              end;
            Reg := TRegistry.Create;
            Reg.RootKey := HKEY_LOCAL_MACHINE;
            if not Reg.OpenKey('\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts\', False) then abort;
            try
              if uppercase(Reg.ReadString(FontRegName)) <> uppercase(FontFile) then Reg.WriteString(FontRegName, FontFile);
            except
              RemoveFontResourceEx(PChar(FontsFolder+FontFile), 0, nil);
              DeleteFile(StrPas(FontsFolder)+FontFile);
              abort;
            end;
            end;
          Result := True;
          if not Temporary then FaceName := FontName else FaceName := FontPrivName;
          sendmessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0);
        end;

        {---------------------------------}

    begin
      Result := False;
      if TryPermanent then
        try {Try permanent font installation}
          Result := AddFont(False);
        except
        end;
      if Result then exit;
      {Try temporary font installation}
      try
        Result := AddFont(True);
        if not Result then abort;
      except
      end;
    end;

    {---------------------------------}

begin
  Result := False;
  InstVersion := '';
  ResStream := nil;
  try {Find internal font resource}
    try
      if FindResource(hInstance, PChar(FontID), 'DATA') = 0 then raise EFontResource.Create('Internal font resource is missing!');             {Abort if font data resource doesn't exist}
      ResStream := TResourceStream.CreateFromID(hInstance, FontID, 'DATA');
      if not GetFontVersion(ResStream, CurrVersion) then raise EFontResource.Create('Internal font resource is corrupt!');                     {Abort if ResStream = nil or no version found}
    except
      on E: EFontResource do
        begin
        messagebeep(MB_ICONERROR);
        messagedlg(E.Message, mtError, [mbOK], 0);
        exit;
        end;
    end;
    MemStream := TMemoryStream.Create;
    try
      getmem(FontsFolder, MAX_PATH + 1);
      try
        try {Find Font Folder, check installed version (if exists) and delete it (if old)}
          if not SHGetFolderPath(0, CSIDL_FONTS, 0, 0, FontsFolder) = 0 then raise ETryTemporary.Create('Could not find fonts folder.');       {Font's folder not found?}
          strcat(FontsFolder, '\');                                                                                                            {Else, append \}
          {Get installed font's version (if font is installed)}
          try MemStream.LoadFromFile(FontsFolder+FontFile) except raise ETryPermanent.Create('Font not installed yet'); end;                   {Font not installed? Do permanent install}
          if not GetFontVersion(MemStream, InstVersion) then raise ETryTemporary.Create('Could not find Version Number in installed font');    {No version found?  Do temporary install}
          Result := InstVersion = CurrVersion;                                                                                                 {Current version?}
          if Result then exit;
          if StrToSingle(InstVersion) > StrToSingle(CurrVersion) then raise ETryTemporary.Create('Installed font is newer than internal font.');
          if not RemoveFontResourceEx(PChar(FontsFolder+FontFile), 0, nil) then raise ETryTemporary.Create('Failed to "remove" existing font.');
          if not DeleteFile(StrPas(FontsFolder)+FontFile) then
            begin {Failed to delete font file, re-add resource}
            AddFontResourceEx(PChar(FontsFolder+FontFile), 0, nil);
            raise ETryTemporary.Create('Failed to "delete" existing font.');                                                                   {else delete it. Can't delete? Do temporary install}
            end;
          raise ETryPermanent.Create('Deleted existing font (v'+InstVersion+').');                                                             {if old font deleted, try permanent install}
        except
          on E: ETryPermanent do Result := InstallFont(True);                                                                                  {Perform permanent install}
          on E: ETryTemporary do Result := InstallFont(False);                                                                                 {Perform temporary install}
        end;
      finally
        freemem(FontsFolder, MAX_PATH + 1);                                                                                                    {Free memory}
      end;
    finally
      MemStream.Free;                                                                                                                          {Free memory}
    end;
  finally
    if ResStream <> nil then ResStream.Free;                                                                                                   {Free memory}
    if not Result then FaceName := 'Courier';                                                                                                  {Set font name substitution, if necessary}
  end;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.ScheduleFutureAction(Action: TActionType; Sender: TObject = nil; Flag: Boolean = False);
{Schedule future action which must be delayed due to current Propeller communication operations.}
begin
//!!  SendDebugMessage('Event: rescheduling user action', True);
  {Save action details for later}
  ScheduledAction.AppHandle := self.Handle;
  ScheduledAction.Action := Action;
  ScheduledAction.Sender := Sender;
  ScheduledAction.Flag := Flag;
  {Initiate termination of current Propeller communication if necessary}
  if CommThreadState < tsTerminating then
    begin
    {if Prop.P2DebugMode then Propeller.CancelComm else} DebugForm.Close;   //!!! Consider re-enabling this (and optimizing elsewhere) for a smoother re-download experience with no artifacts in other cases
    end;
end;

{บบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบ}
{บบบบบบบบบบบบบบบบบบบบบบบบบบบ     Public Routines     บบบบบบบบบบบบบบบบบบบบบบบบบบ}
{บบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบ}

procedure TMainForm.OpenAutoRecover;
{Open auto-recovery file(s) if necessary}
var
  Idx        : Integer;                {General purpose index}
  ID         : Integer;                {Index of editor tab}
  FileHandle : THandle;
  FindData   : Win32_Find_Data;        {Structure for response from FindFirstFile and FindNextFile methods}
  Filename   : String;                 {Name of AR file}
  FileFolder : String;                 {File's original path and filename}
  Files      : TStrings;               {List of all AR files found}
  Times      : TStrings;               {List of all AR files time stamps}
  Str        : TEasyStrings;           {Holds AR file's source}
  Time       : TDateTime;              {Current time; to compare against AR file's time stamp}
  Prefix     : String;                 {Prefix to FileFolder when inserted into source}
  Postfix    : String;                 {Postfix to FileFolder when inserted into source}
  CWidth     : Integer;                {Width of characters on-screen}

const
  O1a  = ' *  OPTIONS:             1)  RESTORE THIS FILE by deleting these comments and compiling it as before.       *';
  O1b  = ' *  OPTIONS:             1)  RESTORE THIS FILE by deleting these comments and selecting File -> Save As.    *';
  O1c  = ' *  OPTIONS:             1)  RESTORE THIS FILE by deleting these comments and selecting File -> Save.       *';
  O1a2 = ' *                           Check the tab name since it is likely to be different than it was originally.  *';
  O1b2 = ' *                           The original folder does not exist so take necessary steps before compiling.   *';
  O1b3 = ' *                           The original file does not exist so take necessary steps before compiling.     *';
  O1c2 = ' *                           The existing file in the original folder will be replaced by this one.         *';
  O2a  = ' *                       2)  IGNORE THIS FILE by closing it without saving.                                 *';
  O2a2 = ' *                           This file will be discarded.                                                   *';
  O2a3 = ' *                           This file will be discarded and the original will be left intact.              *';

    {--------------------------------}

    function GetTime(FileTime: _FileTime): String;
    {Return time "Auto saved", including a relative reference, as a string.}
    var
      SystemTime      : _SystemTime;
      TimeStamp       : TDateTime;
      Days, Hrs, Mins : Integer;
    begin
      Result := '';
      if not FileTimeToSystemTime(FileTime, SystemTime) then exit;              {Convert file time to system time.  Exit if error}
      SystemTimeToTzSpecificLocalTime(nil, SystemTime, SystemTime);             {Convert system time from UTC to local time}
      TimeStamp := SystemTimeToDateTime(SystemTime);                            {Convert system time to time stamp}
      if WithinPastDays(Time, TimeStamp, 30) then                               {Convert time stamp to friendly string}
        begin
        Days := DaysBetween(Time, TimeStamp);                                   {Calculate days, hours, minutes}
        Hrs := HoursBetween(Time, TimeStamp);
        Mins := MinutesBetween(Time, TimeStamp)-Hrs*60;
        if (Days = 0) and (Hrs = 0) then Mins := max(1, Mins);                  {Compensate for < 60 seconds old}
        Result := ifthen(Days = 0, '', ifthen(Days = 1, 'over 1 day', 'over '+inttostr(Days)+' days'));
        if Result = '' then
          begin {Less than a day, show hours and minutes}
          Result := ifthen(Hrs = 0, '', ifthen(Hrs = 1, '1 hour', inttostr(Hrs)+' hours'));
          Result := Result + ifthen(Mins = 0, '', ifthen(Hrs = 0, '', ', ') + ifthen(Mins = 1, '1 minute', inttostr(Mins)+' minutes'));
          end;
        Result := Result + ' ago (';
        end;
      Result := Result + DateTimeToStr(TimeStamp) + ifthen(Hrs+Mins = 0, '', ')');
    end;

    {--------------------------------}

begin
  if not FirstInstance or (ARPath = '') or not CPrefs[AutoRecover].BValue then exit;       {Exit if auto recover not allowed}
  FileHandle := findfirstfile(PChar(ARPath+'*.*'), FindData);                              {Search for files in auto-recovery folder}
  if FileHandle = INVALID_HANDLE_VALUE then exit;                                          {No files found?  Exit}
  Time := Now;
  Files := TStringList.Create;
  try
    Times := TStringList.Create;
    try
      Str := TEasyStrings.Create;
      try
        repeat                                                                             {Else, collect the names of each of them}
          if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) <> 0 {cFileName[0] = '.'} then continue;                                    {  not file name?  continue with next one}
          Files.Add(strpas(FindData.cFileName));                                           {  otherwise record file name and}
          Times.Add(GetTime(FindData.ftLastWriteTime));                                    {  file auto-save time stamp}
        until not FindNextFile(FileHandle, FindData);
        for Idx := 0 to Files.Count -1 do
          begin
          Filename := Files[Idx];
          Str.LoadFromFile(ARPath+Filename);                                               {Load file data}
          if leftstr(Str[0], 13) <> 'AUTORECOVER: ' then                                   {Not auto-recover file?}
            begin
            deletefile(ARPath+Filename);                                                   {  Delete it}
            continue;                                                                      {  and move on to the next one}
            end;
          {Get editor ready for auto-recover file}
          Prefix := '';
          Postfix := '';
          FileFolder := rightstr(Str[0], length(Str[0])-13);                               {Extract original folder path and filename}
          if (FileFolder = '') then
            Prefix := '<not saved>'                                                        {Original file never saved}
          else if not SafeDirectoryExists(extractfilepath(FileFolder)) then
            Prefix := '<not found> '                                                       {Original folder does not exist}
          else if not SafeFileExists(FileFolder) then
            Postfix := ' <file "'+extractfilename(FileFolder)+'" not found>';              {Original file not found}
          if (Prefix <> '') or (Postfix <> '') then
            begin                                                                          {Folder not found/file not stored/found}
            ID := Editor.ActiveIdx;                                                        {  Use existing edit, or create new edit if necessary}
            if (Editor.EditSheet[ID].FullFilename <> '') or (Editor.EditSheet[ID].Source.Strings.Text <> '') then ID := Editor.New(nil, True);
            if ID = -1 then exit;
            end
          else                                                                             {Else...}
            begin
            ID := IndexOfTabWithFile(FileFolder);                                          {  Find original file in open tabs or}
            if ID = -1 then ID := Editor.Open(FileFolder, '', nil, True, False);           {  Open original file}
            if ID = -1 then exit;
            FileFolder := extractfilepath(FileFolder);
            end;
          Editor.EditSheet[ID].CustomString2 := Filename;                                {Link to auto-recover file}
          {Insert friendly "auto-recover" text into top of source}
          CWidth := Editor.ActiveEdit.Canvas.TextWidth('M');
          Str.Delete(0);
          Str.Insert(0, '.{');
          Str.Insert(1, ' '+stringofchar('*', 108));
          Str.Insert(2, ' *'+stringofchar(' ', 106)+'*');
          Str.Insert(3, ' *  AUTO-RECOVER NOTICE: This file was automatically recovered from an earlier Propeller Tool session.      *');
          Str.Insert(4, ' *'+stringofchar(' ', 106)+'*');
          Str.Insert(5, ' *  ORIGINAL FOLDER:     '+Prefix+MinimizeName(extractfilepath(FileFolder), Editor.ActiveEdit.Canvas, CWidth*81-CWidth*length(Prefix)-CWidth*length(Postfix))+PostFix);
          Str[5] := Str[5] + stringofchar(' ', 108-length(Str[5])) + '*';
          Str.Insert(6, ' *  TIME AUTO-SAVED:     '+Times[Idx]);
          Str[6] := Str[6] + stringofchar(' ', 108-length(Str[6])) + '*';
          Str.Insert(7, ' *'+stringofchar(' ', 106)+'*');
          Str.Insert(8,  ifthen(Prefix = '<not saved>', O1a,  ifthen((Prefix = '<not found> '), O1b,  ifthen(Postfix <> '',  O1b,  O1c))));
          Str.Insert(9,  ifthen(Prefix = '<not saved>', O1a2, ifthen((Prefix = '<not found> '), O1b2, ifthen(Postfix <> '',  O1b3, O1c2))));
          Str.Insert(10, ' *'+stringofchar(' ', 106)+'*');
          Str.Insert(11, ' *                           -- OR --'+stringofchar(' ', 71)+'*');
          Str.Insert(12, ' *'+stringofchar(' ', 106)+'*');
          Str.Insert(13, O2a);
          Str.Insert(14, ifthen(Prefix = '<not saved>', O2a2, ifthen((Prefix = '<not found> '), O2a2, ifthen(Postfix <> '',  O2a2, O2a3))));
          Str.Insert(15, ' *'+stringofchar(' ', 106)+'*');
          Str.Insert(16, ' '+stringofchar('*', 108));
          Str.Insert(17, '.}');
          Editor.EditSheet[ID].Source.Strings.Text := Str.Text;
          messagebeep(MB_ICONWARNING);
          end;
      finally
        Str.Free;
      end;
    finally
      Times.Free;
    end;
  finally
    if FileHandle <> INVALID_HANDLE_VALUE then windows.findclose(FileHandle);
    Files.Free;
  end;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.SaveAutoRecover;
{Save auto-recovery file for every modified source}
var
  Idx      : Integer;
  Str      : TEasyStrings;
  Filename : String;
  Time     : Cardinal;
begin
  if (ARPath = '') or not CPrefs[AutoRecover].BValue then exit;                 {Exit if auto recover not allowed}
  Str := TEasyStrings.Create;
  try
    for Idx := 0 to Editor.Count-1 do
      begin {For all open files}
      if Editor.EditSheet[Idx].Source.MainModified then
        begin {Source modified, save a backup}
        Str.LoadSaveAsUnicode := Editor.EditSheet[Idx].Source.MainStrings.TextRequiresUnicode;
        Str.Text := Editor.EditSheet[Idx].Source.MainStrings.Text;              {Get current source strings}
        Filename := Editor.EditSheet[Idx].FullFilename;                         {Get full path and filename}
        Str.Insert(0, 'AUTORECOVER: '+Filename);                                {Insert full path and filename into text}
        if Filename <> '' then Filename := extractfilename(Filename) else Filename := Editor.EditSheet[Idx].Caption;
        if Editor.EditSheet[Idx].CustomString2 = '' then                        {Create auto-recover filename and store into CustomString2}
          begin
          repeat Time := GetTickCount; until not SafeFileExists(ARPath + inttostr(Time) + '_' + Filename);
          Editor.EditSheet[Idx].CustomString2 := inttostr(Time) + '_' + Filename;
          end;
        Str.SaveToFile(ARPath + Editor.EditSheet[Idx].CustomString2);           {Save source in auto-recover folder}
        end;
      end;
  finally
    Str.Free;
  end;
end;

{------------------------------------------------------------------------------}

procedure TMainForm.ClearAutoRecover(TabIdx: Integer);
{Clear (remove) auto-recover file for TabIdx's source.}
var
  Filename : String;
begin
  Filename := Editor.EditSheet[TabIdx].CustomString2;
  Editor.EditSheet[TabIdx].CustomString2 := '';
  if (ARPath = '') or (Filename = '') or not SafeFileExists(ARPath + Filename) then exit;
  deletefile(ARPath + Filename);
end;

{------------------------------------------------------------------------------}

function TMainForm.SetView(Mode: TViewMode): Boolean;
{Set view mode to Mode.  Returns true if successful.}
var
  Idx1, Idx2 : Integer;
  TopInvLine : Integer;       {Index of topmost invisible line in current contiguous block}
  Blanks     : Byte;          {Bit0 = blank line before comments, Bit1 = blank line after comments}
  IsBlank    : Boolean;
  CurWinRow  : Integer;       {Row cursor was on relative to first visible row in window}
  Buffer     : WideString;
  Strings    : TEasyStrings;
  BlockDoc   : Boolean;       {In Block Document comment}
  BlockCom   : Integer;       {Block Comment nesting index}

    {--------------------------------}

    function BlockLine(Str: String): Boolean;
    {Returns true if string begins with a block directive}
    var
      DChar : Char;
    const
      Delimiters = #9+' !"#$%&''()*+,-./:;<=>?@[\]^`{|}~';
    begin
      Str := Trim(Str);
      if length(Str) < 4 then DChar := ' ' else DChar := Str[4];
      Str := uppercase(leftstr(Str,3));
      Result := ((Str = 'CON') or (Str = 'DAT') or (Str = 'PRI') or (Str = 'PUB') or (Str = 'OBJ') or (Str = 'VAR')) and (pos(DChar, Delimiters)>0);
    end;

    {--------------------------------}

    function BlankOrCommentLine(Str: String; var Blank: Boolean): Boolean;

        {-----------------------}

        function BlockComment: Boolean;
        var
          Idx    : Integer;
          Len    : Integer;
          Token  : String;    {Character Pair}
        begin
          Idx := 1;
          Len := length(Str);
          Result := False;
          while (Idx <= Len) do
            begin
            Token := copy(Str, Idx, 2);
            if (Token = '{{') or (Token = '}}') then
              begin {Start or end of block doc comment}
              BlockDoc := (BlockDoc or (Token = '{{')) and not (Token = '}}');
              inc(Idx);
              end
            else    {Normal character, or block comment start or end}
              BlockCom := max(0, BlockCom + ord(Token[1] = '{') - ord(Token[1] = '}'));
            Result := Result or not (BlockDoc or (BlockCom > 0) or (Token[1] = '}'));
            inc(Idx);
            end;
          Result := not Result;
        end;

        {-----------------------}

    begin {Returns true if string is effectively blank, begins with a Code/Doc Comment or entirely contains a Block Code/Doc comment.}
      Str := Trim(Str);
      Blank := boolean(length(Str) = 0);
      Result := Blank or (Str[1] = '''') or BlockComment;
    end;

    {--------------------------------}

    procedure CollapseBlock(CurrentLine: Integer);
    begin {Collapse current block}
      if TopInvLine = -1 then exit; {Exit if no collapsable block}
      if TopInvLine > 0 then
        begin
        Editor.ActiveEdit.EditSource.Strings.Visible[ord(Blanks=0)*-1 + ord(Blanks=1)*TopInvLine + ord(Blanks>1)*(CurrentLine-1)] := True;
        inc(TopInvLine,ord(Blanks=1));
        end;
      Editor.ActiveEdit.EditSource.Strings.Collapsed[TopInvLine-1] := True;
    end;

    {--------------------------------}

    procedure Visible(Line: Integer; Mode: Boolean);
    begin
      Editor.ActiveEdit.EditSource.Strings.Visible[Line] := Mode;
      PEasyStringItem(Editor.ActiveEdit.EditSource.Strings.List[Line])^.FHiddenLevel := 0;
      Editor.ActiveEdit.EditSource.Strings.Collapsed[Line] := False;
    end;

    {--------------------------------}

begin
  Result := True;
  if Editor.EditSheet[Editor.ActiveIdx].CustomTag1 = ord(Mode) then exit; {Exit if not different mode}
  if Mode = vmStandard then
    begin
    Editor.EditSheet[Editor.ActiveIdx].CustomTag1 := ord(vmStandard);
    exit;
    end;
  TopInvLine := -1;
  Blanks := 0;
  BlockDoc := False;
  BlockCom := 0;
  {Make sure cursor line is visible in window and current selection is cleared, then calculate visible offset}
  Editor.ActiveEdit.EnsureCaretVisible;
  Editor.ActiveTabSheet.Edit1.SelLength := 0;
  Editor.ActiveTabSheet.Edit2.SelLength := 0;
  if Mode <> vmDocumentation then
    begin
    if Editor.ActiveSource.ShowingAltSource then Editor.ActiveSource.Snapshot(soSwap, nil, True, Editor.ActiveTabSheet.Edit1, Editor.ActiveTabSheet.Edit2);
    Editor.ActiveEdit.EditSource.BeginSourceUpdate(oprUpdateState);
    CurWinRow := Editor.ActiveEdit.GetVisibleWindowLine(Editor.ActiveEdit.CurrentPosition.Y)-Editor.ActiveEdit.WindowLine;
    end;
  {Set view to new mode}
  case Mode of
    vmFull          : begin
                      for Idx1 := 0 to Editor.ActiveEdit.EditSource.Strings.Count-1 do Visible(Idx1, True);
                      end;
    vmCondensed     : begin
                      for Idx1 := 0 to Editor.ActiveEdit.EditSource.Strings.Count-1 do
                        begin {For every line...}
                        if BlankOrCommentLine(Editor.ActiveEdit.EditSource.Strings[Idx1], IsBlank) then
                          begin {Blank, doc comment or code comment line}
                          Visible(Idx1, False);
                          Blanks := (Blanks and (3 shr ord((TopInvLine > -1) and not IsBlank))) or ord(TopInvLine = -1)*ord(IsBlank) or ord(TopInvLine > -1)*(ord(IsBlank) shl 1);
                          if TopInvLine = -1 then TopInvLine := Idx1;
                          end
                        else
                          begin {Compileable line}
                          Visible(Idx1, True);
                          CollapseBlock(Idx1);
                          TopInvLine := -1;
                          Blanks := 0;
                          end;
                        end;
                      CollapseBlock(Idx1+1);
                      end;
    vmSummary       : begin
                      for Idx1 := 0 to Editor.ActiveEdit.EditSource.Strings.Count-1 do
                        begin {For every line...}
                        if not BlockLine(Editor.ActiveEdit.EditSource.Strings[Idx1]) then
                          begin {Not block line}
                          Visible(Idx1, False);
                          if TopInvLine = -1 then TopInvLine := Idx1;
                          end
                        else
                          begin
                          Visible(Idx1, True);
                          CollapseBlock(Idx1);
                          TopInvLine := -1;
                          end;
                        end;
                      CollapseBlock(Idx1+1);
                      end;
    vmDocumentation : begin
                      if Compile(ltCurWork, False, True) then
                        begin {Successfully compiled, show compiled docs}
                        try
                          Strings := TEasyStrings.Create;
                          Idx2 := 0;
                          for Idx1 := 0 to Prop.DocLength-1 do inc(Idx2, ord(Prop.Doc[Idx1] = $0D));   {Count CRs}
                          setlength(Buffer, Prop.DocLength + Idx2);                                    {Size wide string buffer, including extra for CR/LF}
                          Idx2 := 1;                                                                   {Convert and copy PASCII doc to Unicode wide string}
                          for Idx1 := 0 to Prop.DocLength-1 do
                            begin
                            Buffer[Idx2] := WideChar(PASCIIToUnicodeText[Prop.Doc[Idx1]]);
                            if Word(Buffer[Idx2]) = $000D then Buffer[Idx2+1] := WideChar($000A);    {Add LF after CR}
                            inc(Idx2, 1 + ord(Word(Buffer[Idx2]) = $000D));
                            end;
                          Strings.Text := Buffer;                                                    {Copy to Strings (TEasyStrings) then to Editor}
                          Editor.ActiveSource.Snapshot(soMove, Strings, False, Editor.ActiveTabSheet.Edit1, Editor.ActiveTabSheet.Edit2);
                          UpdateInfoStatus;
                          UpdateCompileStatus;
                        finally
                          Strings.Free;
                        end;
                        end
                      else
                        begin {Error during compilation}
                        Result := False;
                        if CommThreadState < tsTerminating then exit;
                        messagebeep(MB_ICONWARNING);
                        SetStatusBarText('Error during compilation.  Unable to generate compiled documentation.', 2.5, False);
                        MessageDlg(Editor.StatusBar.Panels[sbStatusTextPos].Text, mtWarning, [mbOK], 0);
                        exit;
                        end;
                      end;
    end;
  Editor.ActiveEdit.Invalidate; {Make sure entire page will be drawn to get rid of flicker in rare cases}
  if Mode <> vmDocumentation then
    begin
    Editor.ActiveEdit.EditSource.EndSourceUpdate;
    if TViewMode(Editor.EditSheet[Editor.ActiveIdx].CustomTag1) = vmDocumentation then
      Editor.ActiveEdit.CenterCurrentLine(False)      {Vertically center current line}
    else                                              {or move source to keep cursor line at same visual offset as before (if possible)}
      Editor.ActiveEdit.WindowLine := Editor.ActiveEdit.WindowLine + (Editor.ActiveEdit.GetVisibleWindowLine(Editor.ActiveEdit.CurrentPosition.Y)-Editor.ActiveEdit.WindowLine) - CurWinRow;
    end;
  {Set view button according to final view and store view mode in edit sheet}
  TPRadioGroup(Editor.EditSheet[Editor.ActiveIdx].ControlPanel.Panel.Controls[0]).SelectedIndex := ord(Mode);
  Editor.EditSheet[Editor.ActiveIdx].CustomTag1 := ord(Mode);
  {Set focus on edit}
  Editor.ActiveEdit.SetFocus;
end;

(*procedure TMainForm.MoveItItemClick(Sender: TObject);

  procedure PrintSubComponents(Component: TObject; Step: Boolean);
  var
    Idx  : Integer;
    Name : String;
  begin
    if not (Component is TComponent) then exit;
    Name := TComponent(Component).Name;
    if Component is TPanel then Name := Name + '(Panel)';
    if Component is TPStatusBar then Name := Name + '(PStatusBar)';
    if Component is TStatusBar then Name := Name + '(StatusBar)';
    if Component is TBevel then Name := Name + '(Bevel)';
    if Component is TButton then Name := Name + '(Button)';
    for Idx := 0 to TComponent(Component).ComponentCount-1 do
      begin
      Step := Step or (Idx = 143);
      if not Step then continue;
      Name := Name + ' [ '+ TControl(TComponent(Component).Components[Idx]).ClassName + ' ] ';
      if TComponent(Component).Components[Idx] is TControl then
        begin
        TControl(TComponent(Component).Components[Idx]).Left := TControl(TComponent(Component).Components[Idx]).Left + 10;
//        if TControl(TComponent(Component).Components[Idx]).HasParent then
        showmessage(Name+'-> '+inttostr(Idx+1)+' of '+inttostr(TComponent(Component).ComponentCount)+' : '+TComponent(Component).Components[Idx].Name);
        end;
      PrintSubComponents(TComponent(Component).Components[Idx], Step);
      end;
  end;

begin
  PrintSubComponents(MainForm, False);
end; *)

{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}
{------------------------------------------------------------------------------}

procedure TMainForm.EnableDebugItemClick(Sender: TObject);
begin
  SetStatusBarText('P2 Debug subsystem ' + ifthen(EnableDebugItem.Checked, 'enabled.', 'disabled.'));
end;

initialization
  ProcessingObjClick := False;
  {Initialize Custom Draw State}
  CDState.NextLine := -1;
  CDState.BlockEnd := -1;
  {Get memory for external "App" support routines and initialize handle}
  getmem(AppStr, 1024);
  AppHandle := INVALID_HANDLE_VALUE;
  {Request best time resolution for pauses (sleep, etc.)}
  tr := false;
  if timeGetDevCaps(@tc, sizeof(tc)) = TIMERR_NOERROR then tr := timeBeginPeriod(tc.wPeriodMin) = TIMERR_NOERROR;

finalization
  {Free memory for external "App" support routines}
  freemem(AppStr);
  {End best time resolution}
  if tr then timeEndPeriod(tc.wPeriodMin);

end.


