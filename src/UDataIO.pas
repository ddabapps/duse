{
  Copyright (c) 2021-2025, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/ddabapps/duse
}

unit UDataIO;

interface

uses
  System.SysUtils,
  System.Classes,
  UUnitMap;

type

  TDataIOBase = class abstract(TObject)
  strict protected
    class function GenerateFileName(UnitMap: TUnitMap): string;
  end;

  TMapFileBase = class abstract(TDataIOBase)
  strict protected
    const
      FileVersion = 2;
      FileHeaderPrefix = 'DUSE unit map file v';
      MapNameIdent = 'NAME';
      MapNameSeparator = '=';
    function FileEncoding: TEncoding;
  end;

  TMapFileWriter = class sealed(TMapFileBase)
  strict private
    var
      fUnitMap: TUnitMap;
      fBuilder: TStringBuilder;
    procedure BuildOutput;
  public
    constructor Create(const UnitMap: TUnitMap);
    destructor Destroy; override;
    procedure WriteFile;
  end;

  TMapFileReader = class sealed(TMapFileBase)
  strict private
    const
      V1FileHeader = 'Unit2NS unit map file v1';
    type
      TLineReader = class(TObject)
      strict private
        var
          fLines: TArray<string>;
          fLineIdx: Integer;
        procedure SkipBlankLines;
      public
        constructor Create;
        procedure Init(const Lines: TArray<string>);
        function GetNextLine(out Line: string): Boolean; overload;
        function GetNextLine: string; overload;
        function AtEnd: Boolean;
      end;
    var
      fUnitMap: TUnitMap;
      fReader: TLineReader;
      fFileName: string;
    function ParseFileVersion(const Header: string): Integer;
    procedure CheckHeader;
    procedure ReadMapName;
    procedure ReadUnitScopes;
  public
    constructor Create(const UnitMap: TUnitMap);
    destructor Destroy; override;
    function LoadFile: Boolean;
  end;

  TMapFileDeleter = class(TDataIOBase)
  public
    class procedure DeleteMapFile(const UnitMap: TUnitMap);
  end;

  TAllMapFilesReader = class sealed(TDataIOBase)
  strict private
    class function GetFileNames: TArray<string>;
  public
    class function ReadFiles(const UnitMaps: TUnitMaps): Boolean;
  end;

  TAllMapFilesWriter = class sealed(TDataIOBase)
  public
    class procedure WriteFiles(const UnitMaps: TUnitMaps);
  end;

  {
    Reads all files with a given extension from a directory and all its
    sub-directories. Full unit name is file name without extension
  }
  TFileSystemReader = class sealed(TObject)
  public
    type
      TFileKind = (Source, Binary);
    const
      SourceFile = TFileKind.Source;
      BinaryFile = TFileKind.Binary;
  strict private
    const
      WildCards: array[TFileKind] of string = ('*.pas', '*.dcu');
    var
      fRoot: TFileName;
      fFileKind: TFileKind;
      fUnitMap: TUnitMap;
      fUnitFiles: TArray<string>;
    function FileNameToUnitName(const FileName: TFileName): string;
  public
    constructor Create(const Root: TFileName; const FileKind: TFileKind;
      const UnitMap: TUnitMap);
    procedure ReadFileNames;
  end;

  EMapFileHeader = class(Exception);

implementation

uses
  UConfig,
  System.Character,
  System.IOUtils,
  Generics.Collections;

///  <summary>Splits string S at the first occurence of delimiter string Delim.
///  S1 is set to to the sub-string of S before Delim and S2 to the remainder of
///  S after Delim. Returns True if S contains Delim or False if not.</summary>
///  <remarks>If Delim is not found then S1 is set to S and S2 to the empty
///  string.</remarks>
function SplitStr(const S, Delim: string; out S1, S2: string): Boolean;
var
  DelimPos: Integer;  // position of delimiter in source string
begin
  // Find position of first occurence of delimiter in string
  DelimPos := AnsiPos(Delim, S);
  if DelimPos > 0 then
  begin
    // Delimiter found: split and return True
    S1 := Copy(S, 1, DelimPos - 1);
    S2 := Copy(S, DelimPos + Length(Delim), MaxInt);
    Result := True;
  end
  else
  begin
    // Delimiter not found: return false and set S1 to whole string
    S1 := S;
    S2 := '';
    Result := False;
  end;
end;

{ TDataIOBase }

class function TDataIOBase.GenerateFileName(UnitMap: TUnitMap): string;
begin
  Result := TPath.Combine(TConfig.MapFilesRoot, UnitMap.StorageID);
end;

{ TMapFileBase }

function TMapFileBase.FileEncoding: TEncoding;
begin
  Result := TConfig.TextFileEncoding;
end;

{ TMapFileWriter }

procedure TMapFileWriter.BuildOutput;
var
  Item: TUnitMap.TEntry;
begin
  fBuilder.Clear;
  // Header
  fBuilder.AppendLine(FileHeaderPrefix + FileVersion.ToString);
  fBuilder.AppendLine;
  // Name statement
  fBuilder.AppendLine(MapNameIdent + MapNameSeparator + fUnitMap.Name);
  fBuilder.AppendLine;
  // Unit list from map
  for Item in fUnitMap do
    fBuilder.AppendLine(Item.FullUnitName);
end;

constructor TMapFileWriter.Create(const UnitMap: TUnitMap);
begin
  inherited Create;
  fUnitMap := UnitMap;
  fBuilder := TStringBuilder.Create;
end;

destructor TMapFileWriter.Destroy;
begin
  fBuilder.Free;
  inherited;
end;

procedure TMapFileWriter.WriteFile;
var
  FullPath: string;
begin
  BuildOutput;

  if fUnitMap.StorageID = '' then
    fUnitMap.StorageID := GUIDToString(TGUID.NewGuid);
  FullPath := GenerateFileName(fUnitMap);
  TDirectory.CreateDirectory(TPath.GetDirectoryName(FullPath));
  TFile.WriteAllText(
    FullPath, fBuilder.ToString, FileEncoding
  );
end;

{ TMapFileReader }

procedure TMapFileReader.CheckHeader;
var
  Line: string;
begin
  if not fReader.GetNextLine(Line) then
    raise EMapFileHeader.Create('Empty map file');
  var Version := ParseFileVersion(Line);
  if not (Version in [1..FileVersion]) then
    raise EMapFileHeader.Create('Bad header or file version');
end;

constructor TMapFileReader.Create(const UnitMap: TUnitMap);
begin
  inherited Create;
  fUnitMap := UnitMap;
  fReader := TLineReader.Create;

  fFileName := GenerateFileName(fUnitMap);
end;

destructor TMapFileReader.Destroy;
begin
  fReader.Free;
  inherited;
end;

function TMapFileReader.LoadFile: Boolean;
begin
  Result := True;
  fUnitMap.ClearEntries;
  if not TFile.Exists(fFileName, False) then
    Exit(False); // It's possible the file won't exist - just clear the unit map
  try
    fReader.Init(TFile.ReadAllLines(fFileName, FileEncoding));
    CheckHeader;

    ReadMapName;
    ReadUnitScopes;
  except
    on E: EFileStreamError do
      Exit(False);  // file read error
    on E: EConvertError do
      Exit(False);  // flaky non-GUID file name
    on E: EMapFileHeader do
      Exit(False);  // problems with file header
    else
      raise;
  end;
end;

function TMapFileReader.ParseFileVersion(const Header: string): Integer;
begin
  if string.StartsText(FileHeaderPrefix, Header)
    and (Header.Length >= FileHeaderPrefix.Length + 1) then
  begin
    var Digits := Header.Substring(FileHeaderPrefix.Length);
    if not TryStrToInt(Digits, Result) then
      Result := -1;
  end
  else if Header = V1FileHeader then
    Result := 1
  else
    Result := -1;
end;

procedure TMapFileReader.ReadMapName;
var
  Ident: string;
  Name: string;
begin
  if fReader.AtEnd then
    raise Exception.CreateFmt(
      'Error reading unit map file "%0:s": no map name present.', [fFileName]
    );
  if not SplitStr(Trim(fReader.GetNextLine), MapNameSeparator, Ident, Name)
    or not SameText(Ident, MapNameIdent) then
    raise Exception.CreateFmt(
      'Error reading unit map file "%0:s": map name expected.', [fFileName]
    );
  Name := Trim(Name);
  if Name = '' then
    raise Exception.CreateFmt(
      'Error reading unit map file "%0:s": no map name specified.', [fFileName]
    );
  fUnitMap.Name := Name;
end;

procedure TMapFileReader.ReadUnitScopes;
begin
  while not fReader.AtEnd do
  begin
    fUnitMap.Add(
      TUnitMap.TEntry.CreateFromFullUnitName(
        Trim(fReader.GetNextLine)
      )
    );
  end;
end;

{ TMapFileReader.TLineReader }

function TMapFileReader.TLineReader.AtEnd: Boolean;
begin
  Result := fLineIdx >= Length(fLines);
end;

constructor TMapFileReader.TLineReader.Create;
begin
  inherited Create;
  SetLength(fLines, 0);
  fLineIdx := -1;
end;

function TMapFileReader.TLineReader.GetNextLine: string;
begin
  if not GetNextLine(Result) then
    raise Exception.Create('Can''t read beyond end of line array');
end;

function TMapFileReader.TLineReader.GetNextLine(out Line: string): Boolean;
begin
  Result := not AtEnd;
  if not Result then
    Exit;
  Line := fLines[fLineIdx];
  Inc(fLineIdx);
  SkipBlankLines;
end;

procedure TMapFileReader.TLineReader.Init(const Lines: TArray<string>);
begin
  SetLength(fLines, Length(Lines));
  if Length(Lines) > 0 then
    TArray.Copy<string>(Lines, fLines, Length(Lines));
  fLineIdx := 0;
  SkipBlankLines;
end;

procedure TMapFileReader.TLineReader.SkipBlankLines;
begin
  while not AtEnd and (Trim(fLines[fLineIdx]) = '') do
    Inc(fLineIdx);
end;

{ TMapFileDeleter }

class procedure TMapFileDeleter.DeleteMapFile(const UnitMap: TUnitMap);
begin
  if UnitMap.StorageID = '' then
    Exit; // never saved - nothing to do: this shouldn't happen
  TFile.Delete(GenerateFileName(UnitMap));
end;

{ TAllMapFilesReader }

class function TAllMapFilesReader.GetFileNames: TArray<string>;
begin
  if not TDirectory.Exists(TConfig.MapFilesRoot) then
  begin
    SetLength(Result, 0);
    Exit;
  end;
  Result := TDirectory.GetFiles(TConfig.MapFilesRoot);
end;

class function TAllMapFilesReader.ReadFiles(const UnitMaps: TUnitMaps): Boolean;
var
  FileName: string;
  Reader: TMapFileReader;
  Map: TUnitMap;
  Success: Boolean;
begin
  Success := False;
  Result := True;
  UnitMaps.Clear;
  for FileName in GetFileNames do
  begin
    Map := TUnitMap.Create;
    try
      Map.StorageID := TPath.GetFileName(FileName);
      Reader := TMapFileReader.Create(Map);
      try
        if Reader.LoadFile then
        begin
          UnitMaps.AddItem(Map);
          Success := True;
        end
        else
          Result := False;
      finally
        Reader.Free;
      end;
    finally
      if not Success then
        Map.Free;
    end;
  end;
end;

{ TAllMapFilesWriter }

class procedure TAllMapFilesWriter.WriteFiles(const UnitMaps: TUnitMaps);
var
  Map: TUnitMap;
  Writer: TMapFileWriter;
begin
  for Map in UnitMaps do
  begin
    Writer := TMapFileWriter.Create(Map);
    try
      Writer.WriteFile;
    finally
      Writer.Free;
    end;
  end;
end;

{ TFileSystemReader }

constructor TFileSystemReader.Create(const Root: TFileName;
  const FileKind: TFileKind; const UnitMap: TUnitMap);
begin
  inherited Create;
  fRoot := Root;
  fFileKind := FileKind;
  fUnitMap := UnitMap;
  SetLength(fUnitFiles, 0);
end;

function TFileSystemReader.FileNameToUnitName(const FileName: TFileName):
  string;
begin
  // Strip path and extension
  Result := TPath.ChangeExtension(
    TPath.GetFileName(FileName),
    ''
  );
  // TPath.ChangeExtension leaves a trailing dot at end of file name: strip it
  if (Length(Result) > 0)
    and (Result[Length(Result)] = TPath.ExtensionSeparatorChar) then
    Result := Copy(Result, 1, Length(Result) - 1);
end;

procedure TFileSystemReader.ReadFileNames;
var
  FileNames: TArray<string>;
  FileName: TFileName;
  FullUnitName: string;
  Entry: TUnitMap.TEntry;
begin
  // Get files with required extension from given root and all sub-directories
  FileNames := TDirectory.GetFiles(
    fRoot, WildCards[fFileKind], TSearchOption.soAllDirectories
  );

  // Convert file name to unit name and add to unit map, if not already present
  for FileName in FileNames do
  begin
    FullUnitName := FileNameToUnitName(FileName);
    // add to map if not present
    Entry := TUnitMap.TEntry.CreateFromFullUnitName(FullUnitName);
    if not fUnitMap.Contains(Entry) then
      fUnitMap.Add(Entry);
  end;
end;

end.

