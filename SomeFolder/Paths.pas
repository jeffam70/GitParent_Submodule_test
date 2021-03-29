unit Paths;

{--------------------------------------------------------------------------------------------------------------------------------+
ฆ                                                        COPYRIGHT NOTICE                                                        ฆ
ฆ--------------------------------------------------------------------------------------------------------------------------------ฆ
ฆ UNIT      Paths.pas                                                                                                            ฆ
ฆ AUTHOR    Jeff Martin                                                                                                          ฆ
ฆ COPYRIGHT (c) 2021 Parallax Inc.                                                                                               ฆ
ฆ--------------------------------------------------------------------------------------------------------------------------------ฆ
ฆ                                        PERMISSION NOTICE (TERMS OF USE): MIT X11 License                                       ฆ
ฆ--------------------------------------------------------------------------------------------------------------------------------ฆ
ฆ Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation     ฆ
ฆ files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,     ฆ
ฆ modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software ฆ
ฆ is furnished to do so, subject to the following conditions:                                                                    ฆ
ฆ                                                                                                                                ฆ
ฆ The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. ฆ
ฆ                                                                                                                                ฆ
ฆ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE           ฆ
ฆ WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR          ฆ
ฆ COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,    ฆ
ฆ ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                          ฆ
+--------------------------------------------------------------------------------------------------------------------------------}

{The Propeller Library Paths unit.

^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
NOTE: This unit is used by both the Propeller Tool and the Propellent Library; it MUST be maintained so as to have very few dependancies on objects which may not exist in both applications.
      The ISLIB directive can be used to remove some items not required by the Propellent Library.
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^}

interface

uses
  Classes, SysUtils, Windows, StrUtils, FileCtrl, Math;

type
  {Folder types: ftNone             = no path,
                 ftWork             = work folder (ie: it's not any other type),
                 ftLibraryIncluded  = explicitly included library folder,
                 ftLibraryRecursive = recursively included library folder,
                 ftExcludedLocal    = locally excluded folder,
                 ftExcludedGlobal   = globally excluded folder}
  TFolderType = (ftNone, ftWork, ftLibraryIncluded, ftLibraryRecursive, ftExcludedLocal, ftExcludedGlobal);

  PLibraryItem = ^TLibraryItem;
  TLibraryItem = record
    UserPath      : Boolean;
    Recurse       : Boolean;
    IgnoreMissing : Boolean;
    Path          : String;
    Exclusion     : TStringList;
  end;

  TLibraryFolder = class(TObject)
    FLibrary         : TList;
    FGlobalExclusion : TStrings;
  private
    function  CreateItem: PLibraryItem;
    procedure Clear;
    procedure Delete(Index: Integer);
    function  GetCount: Integer;
    function  GetExclusionCount(Index: Integer): Integer;
    function  GetPath(Index: Integer): TLibraryItem;
    function  GetPathLines: String;
    function  GetPaths: String;
    procedure SetPaths(Paths: String);
    function  GetPathIgnore(Index: Integer): Boolean;
    procedure SetPathIgnore(Index: Integer; Ignore: Boolean);
  public
    constructor Create;
    destructor  Destroy;  reintroduce;
    function  FolderType(Target: String): TFolderType;
    function  IndexOfFolder(Target: String): Integer;
    procedure RemovePath(Index: Integer);
    property Count : Integer read GetCount;
    property ExclusionCount[Index: Integer] : Integer read GetExclusionCount;
    property Path[Index: Integer] : TLibraryItem read GetPath;
    property PathIgnore[Index: Integer] : Boolean read GetPathIgnore write SetPathIgnore;
    property PathLines : String read GetPathLines;
    property Paths : String read GetPaths write SetPaths;
  end;

  {Support Routines}
  function GetDirectory(Filename: String): String;
  function SafeDirectoryExists(const Name: String): Boolean;
  function SafeFileExists(const FileName: String): Boolean;
  function SafeFileExistsCaseCorrect(var FileName: String): Boolean;

implementation

{##############################################################################}
{##############################################################################}
{############################### Support Routines #############################}
{##############################################################################}
{##############################################################################}

function GetDirectory(Filename: String): String;
{Return directory portion of Filename with trailing path delimiter}
begin
  Result := ExtractFilePath(Filename);
end;

{------------------------------------------------------------------------------}

function SafeDirectoryExists(const Name: String): Boolean;
{Perform a "safe" directory exists check that will not generate a hard system error.}
var
  OldMode : Cardinal;
begin
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    Result := DirectoryExists(Name);
  finally
    SetErrorMode(OldMode);
  end;
end;

{------------------------------------------------------------------------------}

function SafeFileExists(const FileName: String): Boolean;
{Perform a "safe" file exists check that will not generate a hard system error.}
var
  OldMode : Cardinal;
begin
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    Result := FileExists(Filename);
  finally
    SetErrorMode(OldMode);
  end;
end;

{------------------------------------------------------------------------------}

function SafeFileExistsCaseCorrect(var FileName: String): Boolean;
{Perform a "safe" file exists check that will not generate a hard system error
 and, if exists, case correct the FileName to match.}
var
  OldMode  : Cardinal;
  zName    : PChar;
  FileData : _WIN32_FIND_DATAA;
begin
  Result := False;
  OldMode := SetErrorMode(SEM_FAILCRITICALERRORS);
  try
    if not FileExists(Filename) then exit;                                      {Exit if Filename doesn't exist}
    getmem(zName, length(Filename)+1);                                          {Else, set Filename to case-preserved name}
    try
      strpcopy(zName, Filename);
      FindClose(FindFirstFile(zName, FileData));
      Filename := GetDirectory(Filename)+FileData.cFileName;
      Result := True;
    finally
      freemem(zName);
    end; {try..finally}
  finally
    SetErrorMode(OldMode);
  end;
end;

{##############################################################################}
{##############################################################################}
{########################## TLibraryFolder Routines ###########################}
{##############################################################################}
{##############################################################################}

{บบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบ}
{บบบบบบบบบบบบบบบบบบบบบบบบบ     Private Routines     บบบบบบบบบบบบบบบบบบบบบบบบบบบ}
{บบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบ}

function TLibraryFolder.CreateItem: PLibraryItem;
{Create new library item and return pointer to it}
begin
  New(Result);
  Result^.UserPath := False;
  Result^.Recurse := False;
  Result^.IgnoreMissing := False;
  Result^.Path := '';
  Result^.Exclusion := nil;
end;

{------------------------------------------------------------------------------}

procedure TLibraryFolder.Clear;
{Free all memory and clear list of library folders}
begin
  while FLibrary.Count > 0 do Delete(FLibrary.Count-1);                         {Free memory and delete library folder item}
  FLibrary.Add(CreateItem);                                                     {Create a blank item}
end;

{------------------------------------------------------------------------------}

procedure TLibraryFolder.Delete(Index: Integer);
{Free memory and delete library folder at Index}
begin
  if (Index < 0) or (Index >= FLibrary.Count) then exit;                        {Exit if Index outside of "true" count}
  PLibraryItem(FLibrary[Index])^.Exclusion.Free;                                {Free exclusions string list}
  Dispose(FLibrary[Index]);                                                     {Free TLibraryItem memory}
  FLibrary.Delete(Index);                                                       {Delete library folder item}
end;

{------------------------------------------------------------------------------}

function TLibraryFolder.GetCount: Integer;
{Return current count of items in library list}
begin
  Result := FLibrary.Count-1;                                                   {Return count-1 to "hide" blank item at end of list}
end;

{------------------------------------------------------------------------------}

function TLibraryFolder.GetExclusionCount(Index: Integer): Integer;
{Return count of current exclusion list}
begin
  Result := 0;
  if (Index > -1) and (Index < Count) and assigned(GetPath(Index).Exclusion) then Result := GetPath(Index).Exclusion.Count;
end;

{------------------------------------------------------------------------------}

function TLibraryFolder.GetPath(Index: Integer): TLibraryItem;
{Return library folder item at Index.}
begin
  Result := TLibraryItem(FLibrary[FLibrary.Count-1]^);                          {Default to the last item- a blank item}
  if (Index < 0) or (Index >= Count) then exit;                                 {Exit if out of bounds (0 to real_count - 2)}
  Result := TLibraryItem(PLibraryItem(FLibrary[Index])^);
end;

{------------------------------------------------------------------------------}

function TLibraryFolder.GetPathLines: String;
{Return Library Folder paths as a single, multi-line string.  Recursive folders are indicated as such but are not expanded.  Missing folders are indicated as such.
 Returns '<unknown>' if empty library.}
var
  Idx : Integer;
begin
  if Count-1 > -1 then Result := '' else Result := '<unknown>';
  for Idx := 0 to Count-1 do Result := Result + PLibraryItem(FLibrary[Idx])^.Path + ifthen(PLibraryItem(FLibrary[Idx])^.Recurse, '   [RECURSIVE]', '') + ifthen(SafeDirectoryExists(PLibraryItem(FLibrary[Idx])^.Path), '','   [MISSING]') + ifthen(Idx < Count-1, '#$D#$A', '');
end;

{------------------------------------------------------------------------------}

function TLibraryFolder.GetPaths: String;
{Return Library Folder paths as a single delimited string.}
// Format: {-/+}{>}folder_path_or_name|...
// {} denotes optional items, / denotes mutually exclusive items, | is a delimiter between library items, ... denotes repetition of all the proceeding
// - means exclude the following folder_path_or_name
// + means include the following folder_path_or_name as a user library folder
// if - and + are left off, the folder_path_or_name is included as a Propeller library folder
// > means recursively include subfolders
var
  Idx  : Integer;                   
  EIdx : Integer;
begin
  for Idx := 0 to FGlobalExclusion.Count-1 do Result := Result + '|-'+FGlobalExclusion[Idx];          {Prepend global exclusions}
  for Idx := 0 to Count-1 do                                                                          {Append Propeller and User folders}
    begin
    Result := Result + '|';
    if PLibraryItem(FLibrary[Idx])^.UserPath then Result := Result + '+';
    if PLibraryItem(FLibrary[Idx])^.Recurse then Result := Result + '>';
    Result := Result + PLibraryItem(FLibrary[Idx])^.Path;
    if (PLibraryItem(FLibrary[Idx])^.Recurse) then
      for EIdx := FGlobalExclusion.Count to ExclusionCount[Idx]-1 do                                  {Insert local exclusions}
        Result := Result + '|-' + PLibraryItem(FLibrary[Idx])^.Exclusion[EIdx];
    end;
  system.delete(Result, 1, 1);                                                                        {Delete leading delimiter}
end;

{------------------------------------------------------------------------------}

procedure TLibraryFolder.SetPaths(Paths: String);
{Set Library Folders according to Paths string}
var
  Path         : String;
  User         : Boolean;    {True = user path (+ switch given)}
  Exclude      : Boolean;    {True = excluded path (- switch given)}
  Recurse      : Boolean;    {True = recursive path (> switch given)}
  LibraryItem  : PLibraryItem;
  LocalExclude : Boolean;
  RemovingPath : Boolean;    {True = ProperPath removed invalid include, so it will dump all following excludes until next include}
  Idx          : Integer;

  {----------------}

  function MorePaths: Boolean;
  {Check for more Paths; if found, return True and set Path, else return False.}
  var
    P : Integer;

      {----------------}

      function ProperPath(Str: String): String;
      {Return string properly formatted as an absolute or relative path plus trailing path delimiter, and set global User, Exclude, and Recurse flags.
       Relative paths have a leading path delimiter.
       Included paths must be absolute and will be removed if not.}
      var
        Idx         : Integer;        {Index of path character being parsed}
        CurrentRule : Byte;           {Current rule in action}
        RulePattern : String;         {Chronological list of rules followed while parsing string}
      const
        {Character-to-Category Translator.
         0 = Include/Exclude or Plus/Minus (+-), 1 = Recurse (>), 2 = Path Delimiter (\/), 3 = Drive Delimiter (:), 4 = Drive Letters (A-Z, a-z),
         5 = Filename Chars (Chars at $20 - $7F, $C0 - $FF, excluding those previously defined and also "*<?|), 6 = End Of String, 7 = Illegal Character}
        CharCategoryTx : array[$00..$FF] of byte =
        // $00 $01 $02 $03 $04 $05 $06 $07 $08 $09 $0A $0B $0C $0D $0E $0F $10 $11 $12 $13 $14 $15 $16 $17 $18 $19 $1A $1B $1C $1D $1E $1F //
        // ------------------------------------------------ No Printable Characters Here ------------------------------------------------- //
          ( 7,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,

        // $20 $21 $22 $23 $24 $25 $26 $27 $28 $29 $2A $2B $2C $2D $2E $2F $30 $31 $32 $33 $34 $35 $36 $37 $38 $39 $3A $3B $3C $3D $3E $3F //
        //      !   "   #   $   %   &   '   (   )   *   +   ,   -   .   /   0   1   2   3   4   5   6   7   8   9   :   ;   <   =   >   ?  //
            6,  6,  8,  6,  6,  6,  6,  6,  6,  6,  8,  0,  6,  1,  6,  3,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  4,  6,  8,  6,  2,  8,

        // $40 $41 $42 $43 $44 $45 $46 $47 $48 $49 $4A $4B $4C $4D $4E $4F $50 $51 $52 $53 $54 $55 $56 $57 $58 $59 $5A $5B $5C $5D $5E $5F //
        //  @   A   B   C   D   E   F   G   H   I   J   K   L   M   N   O   P   Q   R   S   T   U   V   W   X   Y   Z   [   \   ]   ^   _  //
            6,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  6,  3,  6,  6,  6,

        // $60 $61 $62 $63 $64 $65 $66 $67 $68 $69 $6A $6B $6C $6D $6E $6F $70 $71 $72 $73 $74 $75 $76 $77 $78 $79 $7A $7B $7C $7D $7E $7F //
        //  `   a   b   c   d   e   f   g   h   i   j   k   l   m   n   o   p   q   r   s   t   u   v   w   x   y   z   {   |   }   ~      //
            6,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  5,  6,  8,  6,  6,  6,

        // $80 $81 $82 $83 $84 $85 $86 $87 $88 $89 $8A $8B $8C $8D $8E $8F $90 $91 $92 $93 $94 $95 $96 $97 $98 $99 $9A $9B $9C $9D $9E $9F //
        // ------------------------------------------------ No Printable Characters Here ------------------------------------------------- //
            8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,

        // $A0 $A1 $A2 $A3 $A4 $A5 $A6 $A7 $A8 $A9 $AA $AB $AC $AD $AE $AF $B0 $B1 $B2 $B3 $B4 $B5 $B6 $B7 $B8 $B9 $BA $BB $BC $BD $BE $BF //
        // ------------------------------------------------ No Printable Characters Here ------------------------------------------------- //
            8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,  8,

        // $C0 $C1 $C2 $C3 $C4 $C5 $C6 $C7 $C8 $C9 $CA $CB $CC $CD $CE $CF $D0 $D1 $D2 $D3 $D4 $D5 $D6 $D7 $D8 $D9 $DA $DB $DC $DD $DE $DF //
        //  ภ   ม   ย   ร   ฤ   ล   ฦ   ว   ศ   ษ   ส   ห   ฬ   อ   ฮ   ฯ   ะ   ั   า   ำ   ิ   ี   ึ   ื   ุ   ู   ฺ   Û   Ü   Ý   Þ   ฿  //
            6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,

        // $E0 $E1 $E2 $E3 $E4 $E5 $E6 $E7 $E8 $E9 $EA $EB $EC $ED $EE $EF $F0 $F1 $F2 $F3 $F4 $F5 $F6 $F7 $F8 $F9 $FA $FB $FC $FD $FE $FF //
        //  เ   แ   โ   ใ   ไ   ๅ   ๆ   ็   ่   ้   ๊   ๋   ์   ํ   ๎   ๏   ๐   ๑   ๒   ๓   ๔   ๕   ๖   ๗   ๘   ๙   ๚   ๛   ü   ý   þ   8  //
            6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6,  6);

        Pass = 9;
        Fail = 10;

        PathRule : array[0..Pass-1, 0..8] of Byte =
          { 0   1   2   3   4   5   6   7   8}
          { +   -   >   \   :   D   F Pass Fail}
        ( ( 1,  2,  3,  4, 10,  5,  6,  9, 10),    {Char 1 Rule}
          (10, 10,  3,  4, 10,  5,  6,  9, 10),    {Char 2 Rule      - Include (1)}
          (10, 10, 10,  4, 10,  5,  6,  9, 10),    {Char 2 Rule      - Exclude (2)}
          ( 4,  4, 10,  4, 10,  5,  6,  9, 10),    {Char 2/3 Rule    - Recurse (3)}
          ( 4,  4, 10,  8, 10,  4,  4,  9, 10),    {Char 2+ Rule     - Relative (44, 54, 64, 584, or 684)}
          ( 4,  4, 10,  8,  7,  4,  4,  9, 10),    {Char 2/3/4 Rule}
          ( 4,  4, 10,  8, 10,  4,  4,  9, 10),    {Char 2/3/4 Rule}
          (10, 10, 10,  8, 10, 10, 10,  9, 10),    {Char 3/4/5 Rule  - Drive (57 or 578)}
          ( 4,  4, 10, 10, 10,  4,  4,  9, 10)  ); {Char 3/4/5+ Rule - Drive (578) or Share (48)}
      begin
        Result := '';
        if Str = '' then exit;
        Idx := 1;                                                                                                    {Set to first path character}
        RulePattern := '';                                                                                           {Clear rule pattern}
        CurrentRule := 0;                                                                                            {Reset to first rule}
        repeat                                                                                                       {Loop until path passed or failed...}
          RulePattern := RulePattern + chr(CurrentRule + ord('0'));                                                  {  Append current rule to rule pattern}
          CurrentRule := PathRule[CurrentRule, CharCategoryTx[ifthen(Idx <= length(Str), ord(Str[Idx]), 0)]];        {  Check current path character against rule, get next rule}
          inc(Idx);                                                                                                  {  Adjust index to next path character}
        until (CurrentRule >= Pass);
        User := pos('1', RulePattern) > 0;                                                                           {User path?}
        Exclude := pos('2', RulePattern) > 0;                                                                        {Exclude path?}
        if not Exclude then Recurse := pos('3', RulePattern) > 0;                                                    {Recursive include path?}
        if (CurrentRule = Fail) or (Exclude and (RemovingPath or (LocalExclude and not Recurse))) then               {Current path is invalid or is a local exclude path of previous invalid or non-recursive include path?}
          begin
          RemovingPath := RemovingPath or not Exclude;                                                               {  Flag removal of include path}
          exit;                                                                                                      {  Exit}
          end;
        system.Delete(Str, 1, ord(User or Exclude)+ord(not Exclude and Recurse));                                    {Strip switches from front of path}
        system.Delete(RulePattern, 1, 1+ord(User or Exclude)+ord(not Exclude and Recurse));                          {Strip switches from rule pattern}
        if not Exclude and ((pos('57', RulePattern)=0) and (pos('48', RulePattern)=0)) then                          {Non-excluded relative path?}
          begin
          RemovingPath := True;                                                                                      {  Flag removal of include path}
          exit;                                                                                                      {  Exit}
          end;
        if (RulePattern = '5') or (pos('54', RulePattern)=1) then Str := '\' + Str;                                  {Relative path beginning with folder name?  Prepend path delimiter}
        if (pos('57', RulePattern)<>1) and (pos('48', RulePattern)<>1) then                                          {Relative path?}
          while (length(Str) > 0) and (Str[1] = '.') do system.Delete(Str, 1, 1);                                    {  Remove any prepended periods '.'}
        Result := IncludeTrailingPathDelimiter(Str);                                                                 {Return path}
        RemovingPath := False;                                                                                       {Flag acceptance of path}
      end;

      {----------------}

  begin
    Result := False;                                                                  {Assume no more paths}
    if Paths = '' then exit;                                                          {Exit if none}
    P := pos('|', Paths);                                                             {Find position of next delimiter}
    Result := P > 1;                                                                  {True = path is at least 1 character in length; False = null path}
    Path := ProperPath(trim(ifthen(Result, leftstr(Paths, P-1), '')));                {Extract path if possible}
    system.delete(Paths, 1, P);                                                       {Remove path (and delimiter) from Paths}
    if not Result or (Path = '') then Result := MorePaths;                            {If no path info, recursively call for MorePaths}
  end;

  {----------------}

begin
  LocalExclude := False;
  RemovingPath := False;
  Recurse := False;                                                                   {Prime for first run of ProperPath}
  FGlobalExclusion.Clear;
  Clear;
  Paths := Paths + '|';                                                               {Append delimiter to end of Paths}
  while MorePaths do                                                                  {While more paths to parse}
    begin
    LocalExclude := LocalExclude or not Exclude;                                      {  Check for end of global excludes}
    if not Exclude then                                                               {  If found inclusion path}
      begin  {Inclusion path found}
      LibraryItem := CreateItem;                                                      {    Create item}
      LibraryItem^.UserPath := User;                                                  {    Configure User flag}
      LibraryItem^.Recurse := Recurse;                                                {    Configure Recurse flag}
      LibraryItem^.Path := Path;                                                      {    Add path}
      if Recurse and (FGlobalExclusion.Count > 0) then                                {    If recursion and global exclusions exists}
        begin
        LibraryItem^.Exclusion := TStringList.Create;                                 {      Create local exclusion list}
        for Idx := 0 to FGlobalExclusion.Count-1 do                                   {      Add all global exclusions to local list}
          LibraryItem^.Exclusion.Add(FGlobalExclusion[Idx]);
        end;
      FLibrary.Insert(Count, LibraryItem);                                            {    Insert new library item just before last "blank" item}
      end
    else
      if LocalExclude then                                                            {  Else if local exclusion path}
        begin  {Local exclusion path}
        if LibraryItem^.Recurse = True then                                           {    If recursive folder}
          begin                                                                       {      Add local exclusion}
          if not assigned(LibraryItem^.Exclusion) then LibraryItem^.Exclusion := TStringList.Create;
          LibraryItem^.Exclusion.Add(Path);
          end;
        end
      else     {Global exclusion path}                                                {  Else, must be global exclusion path}
        FGlobalExclusion.Add(Path);
    end;
end;

{------------------------------------------------------------------------------}

function TLibraryFolder.GetPathIgnore(Index: Integer): Boolean;
{Return Ignore status of path at Index}
begin
  Result := (Index > -1) and (Index < Count);
  if Result then Result := PLibraryItem(FLibrary[Index])^.IgnoreMissing;
end;

{------------------------------------------------------------------------------}

procedure TLibraryFolder.SetPathIgnore(Index: Integer; Ignore: Boolean);
{Set Ignore status of path at Index}
begin
  if (Index < 0) or (Index >= Count) then exit;
  PLibraryItem(FLibrary[Index])^.IgnoreMissing := Ignore;
end;

{บบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบ}
{บบบบบบบบบบบบบบบบบบบบบบบบบบ     Public Routines     บบบบบบบบบบบบบบบบบบบบบบบบบบบ}
{บบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบบ}

constructor TLibraryFolder.Create;
begin
  inherited Create;
  FLibrary := TList.Create;
  FGlobalExclusion := TStringList.Create;
  Clear;                                  {Call Clear to reset list with special blank item}
end;

{------------------------------------------------------------------------------}

destructor TLibraryFolder.Destroy;
begin
  Clear;
  FLibrary.Free;
  FGlobalExclusion.Free;
  inherited Destroy;
end;

{------------------------------------------------------------------------------}

function TLibraryFolder.FolderType(Target: String): TFolderType;
{Test Target and return its folder type.  Target can be a filename, fully qualified path, or both.
 If Target is just a path, it must end with a path delimiter.}
var
  Idx, EIdx        : Integer;
  Include, Exclude : String;

    {----------------}

    function PutDelimiters(Str: String): String;
    {Return Str making sure that it begins and ends with a path delimiter}
    begin
      Result := '';
      if (Str <> '') then
        begin
        if Str[1] <> '\' then Result := '\';
        Result := Result + Str;
        if Result[length(Result)] <> '\' then Result := Result + '\';
        end;
    end;

    {----------------}

begin
  Target := uppercase(ExtractFilePath(Target));
  if Target = '' then Result := ftNone else Result := ftWork;                                                 {Target empty (file not saved) or in work folder?}
  Idx := 0;
  while (Idx < Count) and (Result = ftWork) do                                                                {Iterate through library folders looking for a match}
    begin
    Include := uppercase(IncludeTrailingPathDelimiter(PLibraryItem(FLibrary[Idx])^.Path));
    if (Target = Include) then                                                                                {  Is Target an explicitly included library folder?}
      Result := ftLibraryIncluded
    else
      if (PLibraryItem(FLibrary[Idx])^.Recurse) and (pos(Include, Target) = 1) then                           {  Else, is Target a subfolder of recursive library folder?}
        begin
        EIdx := 0;
        while (EIdx < ExclusionCount[Idx]) and (Result = ftWork) do                                           {    Iterate through exclusions of this library folder looking for a match}
          begin
          Exclude := uppercase(IncludeTrailingPathDelimiter(PLibraryItem(FLibrary[Idx])^.Exclusion[EIdx]));
          if (pos(Exclude, Target) = 1) then                                                                  {      Is Target at or within a locally excluded library folder?}
            Result := ftExcludedLocal
          else
            if (pos(Exclude, rightstr(Target, length(Target)-length(Include)+1)) > 0) then                    {      Else, is Target at or within a globally excluded library folder?}
              Result := ftExcludedGlobal;
          inc(EIdx);
          end;
        if Result = ftWork then Result := ftLibraryRecursive;                                                 {    Or, Target is a non-excluded subfolder of a recursive library folder.}
        end;
    inc(Idx);
    end;
end;

{------------------------------------------------------------------------------}

function TLibraryFolder.IndexOfFolder(Target: String): Integer;
{Return index of Target folder.  Returns -1 if not found.}
begin
  Result := 0;
  Target := uppercase(Target);
  while (Result < Count) and (Target <> uppercase(PLibraryItem(FLibrary[Result])^.Path)) do inc(Result);      {Search for Target in manually included library folders}
  if Result = Count then Result := -1;
end;

{------------------------------------------------------------------------------}

procedure TLibraryFolder.RemovePath(Index: Integer);
{Remove Index'd folder from library.}
begin
  if (Index < Count) then Delete(Index);  {Delete if Index within "public" count range}
end;


end.
