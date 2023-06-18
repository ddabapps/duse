{
  Copyright (c) 2021, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/ddabapps/duse
}

unit FmNewMapping;

interface

uses
  UUnitMap,
  FmMappingEditorBase,

  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  System.Actions, FMX.ActnList, FMX.Edit, FMX.Layouts,
  FMX.ListBox, FMX.Controls.Presentation;

type
  TNewMappingDlg = class(TMappingEditorBaseDlg)
    lblNameError: TLabel;
    procedure actSaveCloseExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure edMappingNameChangeTracking(Sender: TObject);
  strict private
    type
      TMappingNameValidationResult = (vrOK, vrEmpty, vrExists);
    var
      fNewMap: TUnitMap;
      fUnitMaps: TUnitMaps;
    procedure UpdateNameEditChecks;
    function IsUnitMapNameEmpty: Boolean;
    function ValidateMappingName: TMappingNameValidationResult;
  strict protected
    function GetUnitMapName: string;
    function GetUnitMap: TUnitMap; override;
    function CanSave: Boolean; override;
  public
    class function Execute(const AOwner: TComponent; const UnitMaps: TUnitMaps;
      out UnitMap: TUnitMap): Boolean;
  end;

implementation

uses
  UExceptions;

{$R *.fmx}

{ TNewMappingDlg }

procedure TNewMappingDlg.actSaveCloseExecute(Sender: TObject);
begin
  if not CanSave then
    raise EBug.Create('Should not be able to save: invalid entry.');
  ModalResult := mrOK;
end;

function TNewMappingDlg.CanSave: Boolean;
begin
  Result := (ValidateMappingName = TMappingNameValidationResult.vrOK)
    and ValidateUnitList;
end;

procedure TNewMappingDlg.edMappingNameChangeTracking(Sender: TObject);
begin
  inherited;
  UpdateNameEditChecks;
end;

class function TNewMappingDlg.Execute(const AOwner: TComponent;
  const UnitMaps: TUnitMaps; out UnitMap: TUnitMap): Boolean;
begin
  with Create(AOwner) do
  begin
    Result := False;
    UnitMap := nil;
    fUnitMaps := UnitMaps;
    try
      fNewMap := TUnitMap.Create;
      try
        if ShowModal = mrOK then
        begin
          UnitMap := TUnitMap.Create;
          fNewMap.CloneTo(UnitMap);
          UnitMap.Name := GetUnitMapName;
          Result := True;
        end
      finally
        fNewMap.Free;
      end;
    finally
      Free;
    end;
  end;
end;

procedure TNewMappingDlg.FormShow(Sender: TObject);
begin
  inherited;
  UpdateNameEditChecks;
end;

function TNewMappingDlg.GetUnitMap: TUnitMap;
begin
  Result := fNewMap;
end;

function TNewMappingDlg.GetUnitMapName: string;
begin
  Result := Trim(edMappingName.Text);
end;

function TNewMappingDlg.IsUnitMapNameEmpty: Boolean;
begin
  Result := GetUnitMapName = '';
end;

procedure TNewMappingDlg.UpdateNameEditChecks;

  procedure DisplayMsg(const Msg: string; const Valid: Boolean);
  begin
    if Valid then
      lblNameError.FontColor := TAlphaColorRec.Green
    else
      lblNameError.FontColor := TAlphaColorRec.Red;
    lblNameError.Text := Msg;
  end;

begin
  inherited;
  case ValidateMappingName of
    TMappingNameValidationResult.vrEmpty:
      DisplayMsg('A name is required', False);
    TMappingNameValidationResult.vrExists:
      DisplayMsg('Name in use', False);
    TMappingNameValidationResult.vrOK:
      DisplayMsg('Name available', True);
    else
      raise EBug.Create('Bad mapping name validation result');
  end;
end;

function TNewMappingDlg.ValidateMappingName: TMappingNameValidationResult;
begin
  if IsUnitMapNameEmpty then
    Result := TMappingNameValidationResult.vrEmpty
  else if fUnitMaps.NameExists(GetUnitMapName) then
    Result := TMappingNameValidationResult.vrExists
  else
    Result := TMappingNameValidationResult.vrOK
end;

end.
