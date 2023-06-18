{
  Copyright (c) 2021-2022, Peter Johnson, delphidabbler.com
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
    type
      TPersistentData = class(TObject)
      strict private
        class var fData: TStringList;
        class function ConfigFilePath: string;
      public
        class destructor Destroy;
        class function Data: TStringList;
        class procedure Save;
      end;

    class procedure SetCurrentMapping(const Value: string); static;
    class function GetCurrentMapping: string; static;
    class function GetAppPath: string;
    class procedure SetConfigItemStr(const Key, Value: string);
  public
    const
      MapFilesRelativeRoot = 'config\mappings';
      ConfigFileRelativeName = 'config\config.data';
      KeyValueSeparator = ':';
      CurrentMappingKey = 'current.mapping';

    class function MapFilesRoot: string;
    class function TextFileEncoding: TEncoding; inline;

    class property CurrentMapping: string
      read GetCurrentMapping write SetCurrentMapping;
  end;

implementation

uses
  System.IOUtils;

{ TConfig }

class function TConfig.GetAppPath: string;
begin
  Result := TPath.GetDirectoryName(ParamStr(0));
end;

class function TConfig.GetCurrentMapping: string;
begin
  Result := TPersistentData.Data.Values[CurrentMappingKey];
end;

class function TConfig.MapFilesRoot: string;
begin
  Result := TPath.Combine(GetAppPath, MapFilesRelativeRoot);
end;

class procedure TConfig.SetConfigItemStr(const Key, Value: string);
begin
  TPersistentData.Data.Values[Key] := Value;
  TPersistentData.Save;
end;

class procedure TConfig.SetCurrentMapping(const Value: string);
begin
  SetConfigItemStr(CurrentMappingKey, Value);
end;

class function TConfig.TextFileEncoding: TEncoding;
begin
  Result := TEncoding.UTF8;
end;

{ TConfig.TPersistentData }

class function TConfig.TPersistentData.ConfigFilePath: string;
begin
  Result := TPath.Combine(TConfig.GetAppPath, ConfigFileRelativeName);
end;

class function TConfig.TPersistentData.Data: TStringList;
begin
  if not Assigned(fData) then
  begin
    fData := TStringList.Create;
    fData.NameValueSeparator := TConfig.KeyValueSeparator;
    if TFile.Exists(ConfigFilePath) then
      fData.LoadFromFile(ConfigFilePath, TConfig.TextFileEncoding);
  end;
  Result := fData;
end;

class destructor TConfig.TPersistentData.Destroy;
begin
  fData.Free;
end;

class procedure TConfig.TPersistentData.Save;
begin
  TDirectory.CreateDirectory(TPath.GetDirectoryName(ConfigFilePath));
  Data.SaveToFile(ConfigFilePath, TConfig.TextFileEncoding);
end;

end.

