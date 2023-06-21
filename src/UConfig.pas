{
  Copyright (c) 2021-2023, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/ddabapps/duse
}

unit UConfig;

interface

uses
  System.SysUtils,
  System.Classes;

type
  TConfig = class(TObject)
  strict private
    var
      fData: TStringList;
    function GetVersion: Cardinal;
    procedure SetCurrentVersion;
    function GetCurrentMapping: string;
    procedure SetCurrentMapping(const Value: string);
    class function GetAppPath: string;
    class function ConfigFilePath: string;
    procedure SetConfigItemStr(const Key, Value: string);
    function GetConfigItemStr(const Key, Default: string): string;
    const
      MapFilesRelativeRoot = 'config\mappings';
      ConfigFileRelativeName = 'config\config.data';
      ConfigFileVersionKey = 'config.version';
      ConfigFileVersion = 1;
      CurrentMappingKey = 'current.mapping';
      KeyValueSeparator = ':';
      SupportedKeys: array of string =
        [ConfigFileVersionKey, CurrentMappingKey];
  public
    constructor Create;
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    destructor Destroy; override;
    class function MapFilesRoot: string;
    class function TextFileEncoding: TEncoding; inline;

    property Version: Cardinal
      read GetVersion;
    property CurrentMapping: string
      read GetCurrentMapping write SetCurrentMapping;

  end;

implementation

uses
  System.IOUtils;

{ TConfig }

procedure TConfig.AfterConstruction;

  function IsSupportedKey(const AKey: string): Boolean;
  begin
    Result := False;
    for var ValidKey in SupportedKeys do
      if AKey = ValidKey then
        Exit(True);
  end;

begin
  inherited;
  if TFile.Exists(ConfigFilePath) then
  begin
    // Load config file
    fData.LoadFromFile(ConfigFilePath, TConfig.TextFileEncoding);
    if GetVersion <> ConfigFileVersion then
    begin
      // Not expected file version: purge any unsupported key config entries
      for var I := Pred(fData.Count) downto 0 do
      begin
        if not IsSupportedKey(fData.Names[I]) then
          fData.Delete(I);
      end;
    end;
  end
  else
    // No config file to load, so we have our own version
    SetCurrentVersion;
end;

procedure TConfig.BeforeDestruction;
begin
  var DirName := TPath.GetDirectoryName(ConfigFilePath);
  if not TDirectory.Exists(DirName) then
    TDirectory.CreateDirectory(DirName);
  SetCurrentVersion;
  fData.SaveToFile(ConfigFilePath, TConfig.TextFileEncoding);
  inherited;
end;

class function TConfig.ConfigFilePath: string;
begin
  Result := TPath.Combine(TConfig.GetAppPath, ConfigFileRelativeName);
end;

constructor TConfig.Create;
begin
  inherited;
  fData := TStringList.Create;
  fData.NameValueSeparator := TConfig.KeyValueSeparator;
end;

destructor TConfig.Destroy;
begin
  fData.Free;
  inherited;
end;

class function TConfig.GetAppPath: string;
begin
  Result := TPath.GetDirectoryName(ParamStr(0));
end;

function TConfig.GetConfigItemStr(const Key, Default: string): string;
begin
  if fData.IndexOfName(Key) >= 0 then
    Result := fData.Values[Key]
  else
    Result := Default;
end;

function TConfig.GetCurrentMapping: string;
begin
  Result := GetConfigItemStr(CurrentMappingKey, '');
end;

function TConfig.GetVersion: Cardinal;
begin
  Result := GetConfigItemStr(ConfigFileVersionKey, '0').ToInteger;
end;

class function TConfig.MapFilesRoot: string;
begin
  Result := TPath.Combine(GetAppPath, MapFilesRelativeRoot);
end;

procedure TConfig.SetConfigItemStr(const Key, Value: string);
begin
  fData.Values[Key] := Value;
end;

procedure TConfig.SetCurrentMapping(const Value: string);
begin
  SetConfigItemStr(CurrentMappingKey, Value);
end;

procedure TConfig.SetCurrentVersion;
begin
  SetConfigItemStr(ConfigFileVersionKey, ConfigFileVersion.ToString);
end;

class function TConfig.TextFileEncoding: TEncoding;
begin
  Result := TEncoding.UTF8;
end;

end.

