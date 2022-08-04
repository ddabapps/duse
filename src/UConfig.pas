{
  Copyright (c) 2021, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/delphidabbler/unit2ns
}

unit UConfig;

interface

uses
  System.SysUtils,
  System.Classes;

type
  TConfig = class(TObject)
  strict private
    class var
      fConfigData: TStringList;
    class procedure SetCurrentMapping(const Value: string); static;
    class function GetAppPath: string;
    class function ConfigFilePath: string;
    class procedure WriteConfigFile;
    class procedure ReadConfigFile;
    class function GetConfigItemStr(const Key: string): string;
    class procedure SetConfigItemStr(const Key, Value: string);
    class function GetCurrentMapping: string; static;
  public
    const
      MapFilesRelativeRoot = 'config\mappings';
      ConfigFileRelativeName = 'config\config.data';
      KeyValueSeparator = ':';
      CurrentMappingKey = 'current.mapping';

    class destructor Destroy;

    class function MapFilesRoot: string;
    class function TextFileEncoding: TEncoding; inline;

    class property CurrentMapping: string
      read GetCurrentMapping write SetCurrentMapping;
  end;

implementation

uses
  System.IOUtils;

{ TConfig }

class function TConfig.ConfigFilePath: string;
begin
  Result := TPath.Combine(GetAppPath, ConfigFileRelativeName);
end;

class destructor TConfig.Destroy;
begin
  fConfigData.Free;
end;

class function TConfig.GetAppPath: string;
begin
  Result := TPath.GetDirectoryName(ParamStr(0));
end;

class function TConfig.GetConfigItemStr(const Key: string): string;
begin
  if not Assigned(fConfigData) then
    ReadConfigFile;
  Result := fConfigData.Values[Key];
end;

class function TConfig.GetCurrentMapping: string;
begin
  Result := GetConfigItemStr(CurrentMappingKey);
end;

class function TConfig.MapFilesRoot: string;
begin
  Result := TPath.Combine(GetAppPath, MapFilesRelativeRoot);
end;

class procedure TConfig.ReadConfigFile;
begin
  fConfigData.Free;
  fConfigData := TStringList.Create;
  fConfigData.NameValueSeparator := KeyValueSeparator;
  if TFile.Exists(ConfigFilePath) then
    fConfigData.LoadFromFile(ConfigFilePath, TextFileEncoding);
end;

class procedure TConfig.SetConfigItemStr(const Key, Value: string);
begin
  fConfigData.Values[Key] := Value;
  WriteConfigFile;
end;

class procedure TConfig.SetCurrentMapping(const Value: string);
begin
  SetConfigItemStr(CurrentMappingKey, Value);
end;

class function TConfig.TextFileEncoding: TEncoding;
begin
  Result := TEncoding.UTF8;
end;

class procedure TConfig.WriteConfigFile;
begin
  TDirectory.CreateDirectory(TPath.GetDirectoryName(ConfigFilePath));
  fConfigData.SaveToFile(ConfigFilePath, TextFileEncoding);
end;

end.

