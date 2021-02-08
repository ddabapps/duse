{
  Copyright (c) 2021, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/delphidabbler/unit2ns
}

unit FmMappingEditorBase;

interface

uses
  UExceptions, UUnitMap,

  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit, FMX.Layouts, FMX.ListBox,
  System.Actions, FMX.ActnList;

type
  TMappingEditorBaseDlg = class(TForm)
    lblName: TLabel;
    gbEdit: TGroupBox;
    lbFullUnitNames: TListBox;
    edNameEditor: TEdit;
    btnAdd: TButton;
    btnUpdate: TButton;
    btnDelete: TButton;
    lblAddHelp: TLabel;
    lblUpdateHelp: TLabel;
    lblDeleteHelp: TLabel;
    btnSort: TButton;
    btnSaveClose: TButton;
    alMain: TActionList;
    actReadSourceDir: TAction;
    actAdd: TAction;
    actSort: TAction;
    actUpdate: TAction;
    actSaveClose: TAction;
    actCancel: TAction;
    actDelete: TAction;
    btnCancel: TButton;
    edMappingName: TEdit;
    btnReadSourceDir: TButton;
    lblUnitNamesError: TLabel;
    btnClear: TButton;
    actClear: TAction;
    procedure actAddExecute(Sender: TObject);
    procedure actAddUpdate(Sender: TObject);
    procedure actUpdateExecute(Sender: TObject);
    procedure actUpdateUpdate(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actDeleteUpdate(Sender: TObject);
    procedure actReadSourceDirExecute(Sender: TObject);
    procedure actCancelExecute(Sender: TObject);
    procedure actSortExecute(Sender: TObject);
    procedure actSortUpdate(Sender: TObject);
    procedure lbFullUnitNamesDblClick(Sender: TObject);
    procedure lbFullUnitNamesKeyUp(Sender: TObject; var Key: Word;
      var KeyChar: Char; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure actClearExecute(Sender: TObject);
    procedure actClearUpdate(Sender: TObject);
    procedure actSaveCloseUpdate(Sender: TObject);
  strict private
    function GetNameEditorText: string;
    function IsNameEditorTextValid: Boolean;
    function IsNameEditorEmpty: Boolean;
    function IsFullUnitNameSelected: Boolean;
    procedure BuildMapFromFileSystem(const Dir: string; const Map: TUnitMap);
    procedure UpdateCurrentMap(const NewMap: TUnitMap);
    function GetFileDirectory(out Dir: string): Boolean;
    procedure ClearAndFocusUnitNameEdit;
    procedure UpdateUnitListErrorReport;
    procedure ClearAllEntries;
  strict protected
    procedure PopulateFullUnitNamesList;
    function GetUnitMap: TUnitMap; virtual; abstract;
    function CanSave: Boolean; virtual; abstract;
    function ValidateUnitList: Boolean;
  end;

  EMappingEditor = class(EUser);

implementation

uses
  UDataIO,
  FMX.DialogService,
  System.IOUtils;

resourcestring
  sBadUnitName = 'Invalid unit name: must be valid Pascal identifier.';
  sUnitNameExists = 'Unit name already exists in mapping.';

{$R *.fmx}

procedure TMappingEditorBaseDlg.actAddExecute(Sender: TObject);
var
  Entry: TUnitMap.TEntry;
  Idx: Integer;
begin
  if not IsNameEditorTextValid then
    raise EMappingEditor.Create(sBadUnitName);

  Entry := TUnitMap.TEntry.CreateFromFullUnitName(GetNameEditorText);
  if GetUnitMap.Contains(Entry) then
    raise EMappingEditor.CreateFmt(sUnitNameExists, [Entry.GetFullUnitName]);

  GetUnitMap.Add(Entry);
  Idx := lbFullUnitNames.Items.Add(Entry.GetFullUnitName);
  lbFullUnitNames.ItemIndex := Idx;

  ClearAndFocusUnitNameEdit;
  UpdateUnitListErrorReport;
end;

procedure TMappingEditorBaseDlg.actAddUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := not IsNameEditorEmpty;
end;

procedure TMappingEditorBaseDlg.actCancelExecute(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TMappingEditorBaseDlg.actClearExecute(Sender: TObject);
begin
  TDialogService.MessageDialog(
    'This will clear all units from the list. '
      + 'This cannot be undone.'#10#10
      + 'Do you want to continue?',
    TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
    TMsgDlgBtn.mbNo,
    0,
    procedure(const AResult: TModalResult)
    begin
      if AResult = mrYes then
        ClearAllEntries;
    end
  );
end;

procedure TMappingEditorBaseDlg.actClearUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := not GetUnitMap.IsEmpty;
end;

procedure TMappingEditorBaseDlg.actDeleteExecute(Sender: TObject);
var
  DeleteIdx: Integer;
  DeleteUnitFullName: string;
  DeleteEntry: TUnitMap.TEntry;
begin
  DeleteIdx := lbFullUnitNames.ItemIndex;
  if DeleteIdx < 0 then
    raise EBug.Create('Delete: no item selected in list box.');

  DeleteUnitFullName := lbFullUnitNames.Items[DeleteIdx];
  DeleteEntry := TUnitMap.TEntry.CreateFromFullUnitName(DeleteUnitFullName);
  if not GetUnitMap.Contains(DeleteEntry) then
    raise EBug.Create('Delete: item to deleted is not in mapping');

  lbFullUnitNames.Items.Delete(DeleteIdx);
  GetUnitMap.Delete(DeleteEntry);

  ClearAndFocusUnitNameEdit;
  UpdateUnitListErrorReport;
end;

procedure TMappingEditorBaseDlg.actDeleteUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := IsFullUnitNameSelected;
end;

procedure TMappingEditorBaseDlg.actReadSourceDirExecute(Sender: TObject);
var
  Dir: string;
  ReadMap: TUnitMap;
begin
  if not GetFileDirectory(Dir) then
    Exit;

  ReadMap := TUnitMap.Create;
  try
    BuildMapFromFileSystem(Dir, ReadMap);
    UpdateCurrentMap(ReadMap);
    PopulateFullUnitNamesList;
  finally
    ReadMap.Free;
  end;
end;

procedure TMappingEditorBaseDlg.actSaveCloseUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := CanSave;
end;

procedure TMappingEditorBaseDlg.actSortExecute(Sender: TObject);
var
  SelectedItem: string;
begin
  if lbFullUnitNames.Count <= 1 then
    raise EBug.Create('Can''t sort list with less than 2 items.');
  if lbFullUnitNames.ItemIndex >= 0 then
    SelectedItem := lbFullUnitNames.Items[lbFullUnitNames.ItemIndex]
  else
    SelectedItem := '';
  GetUnitMap.SortByFullUnitName;
  PopulateFullUnitNamesList;
  if SelectedItem <> '' then
    lbFullUnitNames.ItemIndex := lbFullUnitNames.Items.IndexOf(SelectedItem)
  else
    lbFullUnitNames.ItemIndex := -1;
end;

procedure TMappingEditorBaseDlg.actSortUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := lbFullUnitNames.Count > 1;
end;

procedure TMappingEditorBaseDlg.actUpdateExecute(Sender: TObject);
var
  UpdateIdx: Integer;
  OldEntry: TUnitMap.TEntry;
  NewEntry: TUnitMap.TEntry;
  OldUnitFullName: string;
  NewUnitFullName: string;
begin
  UpdateIdx := lbFullUnitNames.ItemIndex;
  Assert(UpdateIdx >= 0, 'Update: no item selected in list box.');
  if not IsNameEditorTextValid then
    raise EMappingEditor.Create(sBadUnitName);

  OldUnitFullName := lbFullUnitNames.Items[UpdateIdx];
  OldEntry := TUnitMap.TEntry.CreateFromFullUnitName(OldUnitFullName);
  if not GetUnitMap.Contains(OldEntry) then
    EBug.CreateFmt('Mapping does not contain unit "%s".', [OldUnitFullName]);

  NewUnitFullName := GetNameEditorText;
  NewEntry := TUnitMap.TEntry.CreateFromFullUnitName(NewUnitFullName);
  lbFullUnitNames.Items[UpdateIdx] := NewUnitFullName;
  GetUnitMap.Update(OldEntry, NewEntry);

  ClearAndFocusUnitNameEdit;
end;

procedure TMappingEditorBaseDlg.actUpdateUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := not IsNameEditorEmpty
    and IsFullUnitNameSelected;
end;

procedure TMappingEditorBaseDlg.BuildMapFromFileSystem(const Dir: string;
  const Map: TUnitMap);
var
  Reader: TFileSytemReader;
begin
  Reader := TFileSytemReader.Create(Dir, Map);
  try
    Reader.ReadFileNames;
  finally
    Reader.Free;
  end;
end;

procedure TMappingEditorBaseDlg.ClearAllEntries;
begin
  lbFullUnitNames.BeginUpdate;
  try
    lbFullUnitNames.Clear;
    GetUnitMap.ClearEntries;
    UpdateUnitListErrorReport;
  finally
    lbFullUnitNames.EndUpdate;
  end;
end;

procedure TMappingEditorBaseDlg.ClearAndFocusUnitNameEdit;
begin
  edNameEditor.Text := '';
  edNameEditor.SetFocus;
end;

procedure TMappingEditorBaseDlg.FormShow(Sender: TObject);
begin
  lblUnitNamesError.FontColor := TAlphaColorRec.Red;
  UpdateUnitListErrorReport;
end;

function TMappingEditorBaseDlg.GetFileDirectory(out Dir: string): Boolean;
begin
  Result := SelectDirectory('Choose source code root directory', '', Dir);
end;

function TMappingEditorBaseDlg.GetNameEditorText: string;
begin
  Result := Trim(edNameEditor.Text);
end;

function TMappingEditorBaseDlg.IsFullUnitNameSelected: Boolean;
begin
  Result := lbFullUnitNames.ItemIndex >= 0;
end;

function TMappingEditorBaseDlg.IsNameEditorEmpty: Boolean;
begin
  Result := GetNameEditorText = '';
end;

function TMappingEditorBaseDlg.IsNameEditorTextValid: Boolean;
begin
  Result := IsValidIdent(GetNameEditorText, True);
end;

procedure TMappingEditorBaseDlg.lbFullUnitNamesDblClick(Sender: TObject);
begin
  if lbFullUnitNames.ItemIndex < 0 then
    Exit;
  edNameEditor.Text := lbFullUnitNames.Selected.Text;
end;

procedure TMappingEditorBaseDlg.lbFullUnitNamesKeyUp(Sender: TObject;
  var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if KeyChar <> ' ' then
    Exit;
  if lbFullUnitNames.ItemIndex < 0 then
    Exit;
  edNameEditor.Text := lbFullUnitNames.Selected.Text;
end;

procedure TMappingEditorBaseDlg.PopulateFullUnitNamesList;
var
  Entry: TUnitMap.TEntry;
begin
  lbFullUnitNames.BeginUpdate;
  try
    lbFullUnitNames.Clear;
    for Entry in GetUnitMap do
      lbFullUnitNames.Items.Add(Entry.GetFullUnitName);
    lbFullUnitNames.ItemIndex := -1;
  finally
    lbFullUnitNames.EndUpdate;
  end;
  UpdateUnitListErrorReport;
end;

procedure TMappingEditorBaseDlg.UpdateCurrentMap(const NewMap: TUnitMap);
var
  Entry: TUnitMap.TEntry;
  CurMap: TUnitMap;
begin
  CurMap := GetUnitMap;
  for Entry in NewMap do
    if not CurMap.Contains(Entry) then
      CurMap.Add(Entry);
end;

procedure TMappingEditorBaseDlg.UpdateUnitListErrorReport;
begin
  lblUnitNamesError.Visible := not ValidateUnitList;
end;

function TMappingEditorBaseDlg.ValidateUnitList: Boolean;
begin
  Result := lbFullUnitNames.Count > 1;
end;

end.

