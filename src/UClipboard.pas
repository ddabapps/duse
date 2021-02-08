{
  Copyright (c) 2021, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/delphidabbler/unit2ns
}

unit UClipboard;

interface

uses
  FMX.Platform,
  FMX.Clipboard;

type
  TClipboard = class
  strict private
    class var
      fClipboard: IFMXClipboardService;
      fClipboardSupported: Boolean;
  public
    class constructor Create;
    class destructor Destroy;
    class function IsClipboardSupported: Boolean;
    class procedure StoreText(const AText: string);
  end;

implementation

uses
  UExceptions;

{ TClipboard }

class constructor TClipboard.Create;
begin
  inherited;
  fClipboardSupported := TPlatformServices.Current.SupportsPlatformService(
    IFMXExtendedClipboardService, fClipboard
  );
end;

class destructor TClipboard.Destroy;
begin
  fClipboard := nil;
  inherited;
end;

class function TClipboard.IsClipboardSupported: Boolean;
begin
  Result := fClipboardSupported;
end;

class procedure TClipboard.StoreText(const AText: string);
begin
  if not (IsClipboardSupported) then
    raise EBug.Create('Attempting to use unsupported clipboard');
  fClipboard.SetClipboard(AText);
end;

end.
