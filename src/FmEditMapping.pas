{
  Copyright (c) 2021-2022, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/delphidabbler/unit2ns
}

unit FmEditMapping;

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
  TEditMappingDlg = class(TMappingEditorBaseDlg)
    actDeleteMapping: TAction;
    actRename: TAction;
    procedure FormShow(Sender: TObject);
    procedure actSaveCloseExecute(Sender: TObject);
  strict private
    var
      fEditMap: TUnitMap;
  strict protected
    function GetUnitMap: TUnitMap; override;
    function CanSave: Boolean; override;
  public
    class function Execute(const AOwner: TComponent; const UnitMap: TUnitMap):
      Boolean;
  end;

implementation

uses
  UExceptions;

{$R *.fmx}

procedure TEditMappingDlg.actSaveCloseExecute(Sender: TObject);
begin
  if not CanSave then
    raise EBug.Create('Should not be able to save: invalid entry.');
  ModalResult := mrOK;
end;

function TEditMappingDlg.CanSave: Boolean;
begin
  Result := ValidateUnitList;
end;

class function TEditMappingDlg.Execute(const AOwner: TComponent;
  const UnitMap: TUnitMap): Boolean;
begin
  with Create(AOwner) do
  begin
    Result := False;
    try
      fEditMap := TUnitMap.Create;
      try
        UnitMap.CloneTo(fEditMap);
        if ShowModal = mrOK then
        begin
          fEditMap.CloneTo(UnitMap);
          Result := True;
        end;
      finally
        fEditMap.Free;
      end;
    finally
      Free;
    end;
  end;
end;

procedure TEditMappingDlg.FormShow(Sender: TObject);
begin
  inherited;
  edMappingName.Text := fEditMap.Name;
  Application.ProcessMessages;
  PopulateFullUnitNamesList;
end;

function TEditMappingDlg.GetUnitMap: TUnitMap;
begin
  Result := fEditMap;
end;

end.

