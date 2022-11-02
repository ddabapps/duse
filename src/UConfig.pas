{
  Copyright (c) 2021-2022, Peter Johnson, delphidabbler.com
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
    class function GetConfigItemStr(const Key: string): string;
    class procedure SetConfigItemStr(const Key, Value: string);
    class function GetCurrentMapping: string; static;
    class function GetConfigData: TStringList;
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

class function TConfig.GetConfigData: TStringList;
begin
  if not Assigned(fConfigData) then
  begin
    fConfigData := TStringList.Create;
    fConfigData.NameValueSeparator := KeyValueSeparator;
    if TFile.Exists(ConfigFilePath) then
      fConfigData.LoadFromFile(ConfigFilePath, TextFileEncoding);
  end;
  Result := fConfigData;
end;

class function TConfig.GetConfigItemStr(const Key: string): string;
begin
  Result := GetConfigData.Values[Key];
end;

class function TConfig.GetCurrentMapping: string;
begin
  Result := GetConfigItemStr(CurrentMappingKey);
end;

class function TConfig.MapFilesRoot: string;
begin
  Result := TPath.Combine(GetAppPath, MapFilesRelativeRoot);
end;

class procedure TConfig.SetConfigItemStr(const Key, Value: string);
begin
  GetConfigData.Values[Key] := Value;
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
  GetConfigData.SaveToFile(ConfigFilePath, TextFileEncoding);
end;

end.

