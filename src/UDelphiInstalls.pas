{
  Copyright (c) 2022-2023, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/ddabapps/duse

  Based on the demo code of the article "How to programatically detect installed
  versions of Delphi" - https://delphidabbler.com/articles/27
}

unit UDelphiInstalls;

interface

uses
  System.Generics.Collections,
  WinApi.Windows;

type
  ///  <summary>Static class that detects any installed versions of Delphi and
  ///  finds the path to each installation's source code directory.</summary>
  ///  <remarks>Only Delphi versions that support unit scope names are
  ///  detected.</remarks>
  TDelphiInstalls = class(TObject)
  strict private
    type
      // Record that relates the name of a Delphi version to its associated
      // registry key
      TInstallInfo = record
        Name: string;
        RegKey: string;
      end;
    const
      // List of all versions of Delphi that support unit scope names, along
      // with the registry key where info about the installation is stored.
      AllDelphis: array[0..12] of TInstallInfo = (
        (Name: 'Delphi XE2'; RegKey: '\Software\Embarcadero\BDS\9.0'),
        (Name: 'Delphi XE3'; RegKey: '\Software\Embarcadero\BDS\10.0'),
        (Name: 'Delphi XE4'; RegKey: '\Software\Embarcadero\BDS\11.0'),
        (Name: 'Delphi XE5'; RegKey: '\Software\Embarcadero\BDS\12.0'),
        (Name: 'Delphi XE6'; RegKey: '\Software\Embarcadero\BDS\14.0'),
        (Name: 'Delphi XE7'; RegKey: '\Software\Embarcadero\BDS\15.0'),
        (Name: 'Delphi XE8'; RegKey: '\Software\Embarcadero\BDS\16.0'),
        (Name: 'Delphi 10 Seattle'; RegKey: '\Software\Embarcadero\BDS\17.0'),
        (Name: 'Delphi 10.1 Berlin'; RegKey: '\Software\Embarcadero\BDS\18.0'),
        (Name: 'Delphi 10.2 Tokyo'; RegKey: '\Software\Embarcadero\BDS\19.0'),
        (Name: 'Delphi 10.3 Rio'; RegKey: '\Software\Embarcadero\BDS\20.0'),
        (Name: 'Delphi 10.4 Sydney'; RegKey: '\Software\Embarcadero\BDS\21.0'),
        (Name: 'Delphi 11 Alexandria'; RegKey: '\Software\Embarcadero\BDS\22.0')
      );
    type
      // Record containing name of a Delphi version with the path to its source
      // files.
      TDelphiInfo = record
        Name: string;
        SrcPath: string;
        constructor Create(AName, ASrcPath: string);
      end;
    // List of records providing information about installed versions of Delphi.
    class var fDelphis: TList<TDelphiInfo>;
    // Detects whether a version of Delphi with the given sub-key is registered
    // under the given registry root key.
    class function IsRegisteredInRootKey(RootKey: HKEY; SubKey: string):
      Boolean;
    // Checks whether a version of Delphi is registered under the given registry
    // sub-key, either system wide or for the current user.
    class function IsRegistered(SubKey: string): Boolean;
    // Finds the root key under which the given registry sub-key exists. Returns
    // 0 if the sub-key does not exist.
    class function GetRegRootKey(SubKey: string): HKEY;
    // Gets the installation directory of the version of Delphi registered under
    // the given registry sub-key. Returns '' if that version of Delphi is not
    // installed.
    class function GetInstallDir(SubKey: string): string;
    // Checks whether an installation directory exists for a version of Delphi
    // registered under the given registry sub-key.
    class function InstallDirExists(SubKey: string): Boolean;
    // Returns an array of information about each installed version of Delphi.
    class function GetInstallations: TList<TDelphiInfo>;
    // Attempts to get the source code directory for any version of Delphi
    // registered under the given registry sub-key. Stores the directory in Path
    // and returns True on success. Sets Path to the empty string and returns
    // False on error.
    class function TryGetSourcePath(SubKey: string; out Path: string):
      Boolean;
    // Helper method to check if the two named versions of Delphi are the same.
    class function IsSameName(const NameA, NameB: string): Boolean; inline;
  public
    class destructor Destroy;
    ///  <summary>Returns an array of names of installed versions of Delphi.
    ///  </summary>
    class function Names: TArray<string>;
    ///  <summary>Checks if any installed version of Delphi have been found.
    ///  </summary>
    class function HaveInstalls: Boolean;
    ///  <summary>Checks if a Delphi installation with the given name exists.
    ///  </summary>
    class function NameExists(const Name: string): Boolean;
    ///  <summary>Returns the directory where the given Delphi version stores
    ///  its source code.</summary>
    ///  <remarks>Returns an empty string if the Delphi version is not
    ///  installed.</remarks>
    class function GetSrcPath(const Name: string): string;
  end;

implementation

uses
  System.SysUtils,
  System.IOUtils,
  System.Win.Registry;

{ TDelphiInstalls }

class destructor TDelphiInstalls.Destroy;
begin
  fDelphis.Free;
end;

class function TDelphiInstalls.GetInstallations: TList<TDelphiInfo>;
begin
  if not Assigned(fDelphis) then
  begin
    fDelphis := TList<TDelphiInfo>.Create;
    for var Rec in AllDelphis do
    begin
      var SrcPath: string;
      if IsRegistered(Rec.RegKey) and TryGetSourcePath(Rec.RegKey, SrcPath) then
        fDelphis.Add(TDelphiInfo.Create(Rec.Name, SrcPath));
    end;
  end;
  Result := fDelphis;
end;

class function TDelphiInstalls.GetInstallDir(SubKey: string): string;
begin
  if GetRegRootKey(SubKey) = 0 then
    Exit('');
  var Reg: TRegistry := TRegistry.Create(KEY_READ);
  try
    if not Reg.OpenKeyReadOnly(SubKey) then
      Exit(''); // no installation
    Result := Reg.ReadString('RootDir');
    Reg.CloseKey;
  finally
    Reg.Free;
  end;
end;

class function TDelphiInstalls.GetRegRootKey(SubKey: string): HKEY;
begin
  if IsRegisteredInRootKey(HKEY_LOCAL_MACHINE, SubKey) then
    Result := HKEY_LOCAL_MACHINE
  else if IsRegisteredInRootKey(HKEY_CURRENT_USER, SubKey) then
    Result := HKEY_CURRENT_USER
  else
    Result := 0;  // not registered
end;

class function TDelphiInstalls.GetSrcPath(const Name: string): string;
begin
  for var Rec in GetInstallations do
    if string.Compare(Rec.Name, Name, [TCompareOption.coIgnoreCase]) = 0 then
      Exit(Rec.SrcPath);
  Result := '';
end;

class function TDelphiInstalls.HaveInstalls: Boolean;
begin
  Result := GetInstallations.Count > 0;
end;

class function TDelphiInstalls.InstallDirExists(SubKey: string): Boolean;
begin
  var InstDir := GetInstallDir(SubKey);
  if InstDir = '' then
    Exit(False);
  Result := TDirectory.Exists(InstDir);
end;

class function TDelphiInstalls.IsRegistered(SubKey: string): Boolean;
begin
  Result := IsRegisteredInRootKey(HKEY_LOCAL_MACHINE, SubKey);
  if not Result then
    Result := IsRegisteredInRootKey(HKEY_CURRENT_USER, SubKey);
end;

class function TDelphiInstalls.IsRegisteredInRootKey(RootKey: HKEY;
  SubKey: string): Boolean;
begin
  var Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := RootKey;
    Result := Reg.OpenKeyReadOnly(SubKey);
    if Result then
      Reg.CloseKey;
  finally
    Reg.Free;
  end;
end;

class function TDelphiInstalls.IsSameName(const NameA, NameB: string): Boolean;
begin
  Result := string.Compare(NameA, NameB, [TCompareOption.coIgnoreCase]) = 0;
end;

class function TDelphiInstalls.NameExists(const Name: string): Boolean;
begin
  for var Rec in GetInstallations do
    if IsSameName(Rec.Name, Name) then
      Exit(True);
  Result := False;
end;

class function TDelphiInstalls.Names: TArray<string>;
begin
  var Infos := GetInstallations;
  SetLength(Result, Infos.Count);
  for var Idx := 0 to Pred(Infos.Count) do
    Result[Idx] := Infos[Idx].Name;
end;

class function TDelphiInstalls.TryGetSourcePath(SubKey: string;
  out Path: string): Boolean;
begin
  if InstallDirExists(SubKey) then
  begin
    Path := IncludeTrailingPathDelimiter(GetInstallDir(SubKey)) + 'source';
    Result := TDirectory.Exists(Path);
  end
  else
    Result := False;
  if not Result then
    Path := '';
end;

{ TDelphiInstalls.TDelphiInfo }

constructor TDelphiInstalls.TDelphiInfo.Create(AName, ASrcPath: string);
begin
  Name := AName;
  SrcPath := ASrcPath;
end;

end.
