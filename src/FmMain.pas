{
  Copyright (c) 2021, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/delphidabbler/unit2ns
}

unit FmMain;

interface

uses
  UUnitMap,
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts,
  FMX.ListBox, FMX.StdCtrls, FMX.Edit, FMX.Controls.Presentation,
  System.Actions, FMX.ActnList;

type
  TMainForm = class(TForm)
    cbMappings: TComboBox;
    btnNewMapping: TButton;
    gbUnitToNS: TGroupBox;
    edUnitToFind: TEdit;
    lblUnitToFind: TLabel;
    lblFoundNS: TLabel;
    btnFindNS: TButton;
    btnCopyFullName: TButton;
    gbUnitInNS: TGroupBox;
    lblChooseNS: TLabel;
    lblUnitsInNS: TLabel;
    cbChooseNS: TComboBox;
    lbUnitsInNS: TListBox;
    btnEditMapping: TButton;
    lblMappings: TLabel;
    lbFoundNS: TListBox;
    alMain: TActionList;
    actFindNS: TAction;
    actCopyFullName: TAction;
    actEditMapping: TAction;
    actNewMapping: TAction;
    btnDeleteMapping: TButton;
    actDeleteMapping: TAction;
    btnExit: TButton;
    actExit: TAction;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actFindNSExecute(Sender: TObject);
    procedure actFindNSUpdate(Sender: TObject);
    procedure actCopyFullNameExecute(Sender: TObject);
    procedure actCopyFullNameUpdate(Sender: TObject);
    procedure actFindUnitsUpdate(Sender: TObject);
    procedure actNewMappingExecute(Sender: TObject);
    procedure actEditMappingExecute(Sender: TObject);
    procedure actEditMappingUpdate(Sender: TObject);
    procedure cbChooseNSChange(Sender: TObject);
    procedure actDeleteMappingExecute(Sender: TObject);
    procedure actDeleteMappingUpdate(Sender: TObject);
    procedure cbMappingsChange(Sender: TObject);
    procedure actExitExecute(Sender: TObject);
  strict private
    const
      EmptyNSDisplayText = '<no namespace>';
    var
      fUnitMaps: TUnitMaps;
    procedure ExceptionHandler(Sender: TObject; E: Exception);
    procedure LoadMappings;
    procedure PopulateMappingList;
    procedure ClearMappingDisplay;
    procedure UpdateMappingDisplay;
    procedure WriteMapping(const Map: TUnitMap);
    procedure DeleteSelectedMapping;

    function StandardNSToFriendlyNS(const SNS: string): string;
    function FriendlyNSToStandardNS(const FNS: string): string;

    function SelectedUnitMap: TUnitMap;
    function IsUnitMapSelected: Boolean;
    function GetUnitToFindEditText: string;
    function IsUnitToFindEditEmpty: Boolean;
    procedure DisplayUnitsInNS(const Units: array of string);
  end;

var
  MainForm: TMainForm;

implementation

uses
  FMX.DialogService,
  FmEditMapping,
  FmNewMapping,
  UClipboard,
  UConfig,
  UDataIO,
  UExceptions;

{$R *.fmx}

procedure TMainForm.actCopyFullNameExecute(Sender: TObject);
var
  Entry: TUnitMap.TEntry;
begin
  if not TClipboard.IsClipboardSupported then
    raise EBug.Create('Can''t access clipboard: not supported');
  if not IsUnitMapSelected then
    raise EBug.Create('Can''t check clipboard item: no mapping selected');
  if lbFoundNS.ItemIndex < 0 then
    raise EBug.Create('Can''t copy: no namespace selected');
  if IsUnitToFindEditEmpty then
    raise EBug.Create('Can''t copy: unit edit box is empty');

  if SelectedUnitMap.TryFind(
    GetUnitToFindEditText,
    FriendlyNSToStandardNS(lbFoundNS.Selected.Text),
    Entry
  ) then
    TClipboard.StoreText(Entry.GetFullUnitName)
  else
    raise EUser.Create(
      'Can''t find a matching entry in the current mapping.'#10
      + 'Have you changed the unit name without pressing "Find Namespace(s)"'
      + ' again?'
    );
end;

procedure TMainForm.actCopyFullNameUpdate(Sender: TObject);
begin
  (Sender as TAction).Visible := TClipboard.IsClipboardSupported;
  (Sender as TAction).Enabled := IsUnitMapSelected
    and (lbFoundNS.ItemIndex >= 0)
    and not IsUnitToFindEditEmpty;

end;

procedure TMainForm.actDeleteMappingExecute(Sender: TObject);
begin
  if not IsUnitMapSelected then
    raise EBug.Create('No mapping selected: can''t delete.');
  if fUnitMaps.IsEmpty then
    raise EBug.Create('There are no mappings to delete.');

  TDialogService.MessageDialog(
    'You are about to delete the currently selected mapping. '
      + 'This cannot be undone.'#10#10
      + 'Do you want to continue?',
    TMsgDlgType.mtConfirmation,
    [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
    TMsgDlgBtn.mbNo,
    0,
    procedure(const AResult: TModalResult)
    begin
      if AResult = mrYes then
        DeleteSelectedMapping;
    end
  );
end;

procedure TMainForm.actDeleteMappingUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := IsUnitMapSelected
    and not fUnitMaps.IsEmpty;
end;

procedure TMainForm.actEditMappingExecute(Sender: TObject);
var
  UnitMap: TUnitMap;
begin
  if not IsUnitMapSelected then
    raise EBug.Create('No mapping selected: can''t edit');

  UnitMap := SelectedUnitMap;

  if TEditMappingDlg.Execute(Self, SelectedUnitMap) then
  begin
    WriteMapping(UnitMap);
    UpdateMappingDisplay;
  end;
end;

procedure TMainForm.actEditMappingUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := IsUnitMapSelected;
end;

procedure TMainForm.actExitExecute(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.actFindNSExecute(Sender: TObject);
var
  Namespaces: TArray<string>;
  NS: string;
begin
  if IsUnitToFindEditEmpty then
    raise EBug.Create('Can''t find name spaces: no unit name specified');
  if not IsUnitMapSelected then
    raise EBug.Create('Can''t find name spaces: no mapping is selected');

  Namespaces := SelectedUnitMap.FindUnitNamespaces(GetUnitToFindEditText);
  lbFoundNS.BeginUpdate;
  try
    lbFoundNS.Clear;
    for NS in Namespaces do
      lbFoundNS.Items.Add(StandardNSToFriendlyNS(NS));
    lbFoundNS.Sort(
      function (Left, Right: TFmxObject): Integer
      begin
        Result := CompareText(
          lbFoundNS.Items[Left.Index], lbFoundNS.Items[Right.Index]
        )
      end
    );
  finally
    lbFoundNS.EndUpdate;
  end;
  if Length(Namespaces) > 0 then
    lbFoundNS.ItemIndex := 0
  else
    ShowMessageFmt('Unit "%s" not found', [GetUnitToFindEditText]);
end;

procedure TMainForm.actFindNSUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := not IsUnitToFindEditEmpty
    and IsUnitMapSelected;
end;

procedure TMainForm.actFindUnitsUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := cbChooseNS.ItemIndex >= 0;
end;

procedure TMainForm.actNewMappingExecute(Sender: TObject);
var
  UnitMap: TUnitMap;
begin
  if TNewMappingDlg.Execute(Self, fUnitMaps, UnitMap) then
  begin
    fUnitMaps.AddItem(UnitMap);
    WriteMapping(UnitMap);
    cbMappings.ItemIndex := cbMappings.Items.Add(UnitMap.Name);
  end;
end;

procedure TMainForm.cbChooseNSChange(Sender: TObject);
begin
  if not IsUnitMapSelected then
    Exit;
  if cbChooseNS.ItemIndex < 0 then
  begin
    lbUnitsInNS.Clear;
    Exit;
  end;
  DisplayUnitsInNS(
    SelectedUnitMap.FindNamespaceUnits(
      FriendlyNSToStandardNS(cbChooseNS.Selected.Text)
    )
  );
end;

procedure TMainForm.cbMappingsChange(Sender: TObject);
begin
  UpdateMappingDisplay;
end;

procedure TMainForm.ClearMappingDisplay;
begin
  edUnitToFind.Text := '';
  lbFoundNS.Clear;
  cbChooseNS.Clear;
  lbUnitsInNS.Clear;
end;

procedure TMainForm.DeleteSelectedMapping;
var
  DeleteIdx: Integer;
  DeleteMap: TUnitMap;
begin
  DeleteIdx := cbMappings.ItemIndex;
  if DeleteIdx < 0 then
    raise EBug.Create('No mapping is selected: can''t delete.');
  if not IsUnitMapSelected then
    raise EBug.Create('No mapping is selected: can''t delete.');
  DeleteMap := SelectedUnitMap;

  ClearMappingDisplay;
  cbMappings.BeginUpdate;
  try
    cbMappings.Items.Delete(DeleteIdx);
    if cbMappings.Count = 0 then
      cbMappings.ItemIndex := -1
    else if DeleteIdx < cbMappings.Count then
      cbMappings.ItemIndex := DeleteIdx
    else
      cbMappings.ItemIndex := Pred(DeleteIdx);
  finally
    cbMappings.EndUpdate;
  end;

  TMapFileDeleter.DeleteMapFile(DeleteMap);
  fUnitMaps.DeleteItem(DeleteMap);
end;

procedure TMainForm.DisplayUnitsInNS(const Units: array of string);
var
  UnitName: string;
begin
  lbUnitsInNS.BeginUpdate;
  try
    lbUnitsInNS.Clear;
    for UnitName in Units do
      lbUnitsInNS.Items.Add(UnitName);
    lbUnitsInNS.ItemIndex := -1;
  finally
    lbUnitsInNS.EndUpdate;
  end;
end;

procedure TMainForm.ExceptionHandler(Sender: TObject; E: Exception);
resourcestring
  sBug = 'Probable BUG: please report at '
    + 'https://github.com/delphidabbler/unit2ns';
begin
  if (E is EUser) or (E is EFileStreamError) then
    TDialogService.MessageDialog(
      E.Message, TMsgDlgType.mtError, [TMsgDlgBtn.mbOK], TMsgDlgBtn.mbOK, 0, nil
    )
  else
    TDialogService.MessageDialog(
      sBug + #10#10 + E.Message,
      TMsgDlgType.mtError,
      [TMsgDlgBtn.mbOK],
      TMsgDlgBtn.mbOK,
      0,
      nil
    )
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  Application.OnException := ExceptionHandler;
  fUnitMaps := TUnitMaps.Create;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if IsUnitMapSelected then
    TConfig.CurrentMapping := SelectedUnitMap.Name
  else
    TConfig.CurrentMapping := '';
  fUnitMaps.Free;
  inherited;
end;

procedure TMainForm.FormShow(Sender: TObject);
var
  LastMapName: string;
  LastNameIdx: Integer;
begin
  LoadMappings;
  PopulateMappingList;
  // Select last used mapping name
  LastMapName := TConfig.CurrentMapping;
  if (LastMapName = '') or not fUnitMaps.NameExists(LastMapName) then
    Exit;
  LastNameIdx := cbMappings.Items.IndexOf(LastMapName);
  if LastNameIdx < 0 then
    Exit;
  cbMappings.ItemIndex := LastNameIdx;
end;

function TMainForm.FriendlyNSToStandardNS(const FNS: string): string;
begin
  if SameText(FNS, EmptyNSDisplayText) then
    Exit('');
  Result := FNS;
end;

function TMainForm.GetUnitToFindEditText: string;
begin
  Result := Trim(edUnitToFind.Text);
end;

function TMainForm.IsUnitMapSelected: Boolean;
begin
  Result := cbMappings.ItemIndex >= 0;
end;

function TMainForm.IsUnitToFindEditEmpty: Boolean;
begin
  Result := GetUnitToFindEditText = '';
end;

procedure TMainForm.LoadMappings;
var
  MainCaption: string;
begin
  MainCaption := Self.Caption;
  try
    Self.Caption := 'Unit2NS ... Loading mappings';
    Application.ProcessMessages;
    TAllMapFilesReader.ReadFiles(fUnitMaps);
  finally
    Self.Caption := MainCaption;
  end;
end;

procedure TMainForm.PopulateMappingList;
var
  Map: TUnitMap;
begin
  cbMappings.BeginUpdate;
  try
    for Map in fUnitMaps do
      cbMappings.Items.Add(Map.Name);
    cbMappings.Sort(
      function (Left, Right: TFmxObject): Integer
      begin
        Result := CompareText(
          cbMappings.Items[Left.Index], cbMappings.Items[Right.Index]
        )
      end
    );
    if cbMappings.Count > 0 then
      cbMappings.ItemIndex := 0;
  finally
    cbMappings.EndUpdate;
  end;
end;

function TMainForm.SelectedUnitMap: TUnitMap;
var
  Name: string;
begin
  if not IsUnitMapSelected then
    raise EBug.Create('Attempt to get selected mapping: nothing selected');
  Name := cbMappings.Selected.Text;
  if not fUnitMaps.NameExists(Name) then
    raise EBug.Create('There is no mapping with selected name');
  Result := fUnitMaps.FindByName(Name);
end;

function TMainForm.StandardNSToFriendlyNS(const SNS: string): string;
begin
  if SNS = '' then
    Exit(EmptyNSDisplayText);
  Result := SNS;
end;

procedure TMainForm.UpdateMappingDisplay;
var
  NSList: TArray<string>;
  NS: string;
begin
  // Clear controls
  ClearMappingDisplay;
  // Get out if we have no mappings
  if fUnitMaps.IsEmpty or not IsUnitMapSelected then
    Exit;
  // Populate namespaces list
  NSList := SelectedUnitMap.FindUniqueNamespaces;
  cbChooseNS.BeginUpdate;
  try
    for NS in NSList do
      cbChooseNS.Items.Add(
        StandardNSToFriendlyNS(NS)
      );
    cbChooseNS.Sort(
      function (Left, Right: TFmxObject): Integer
      begin
        Result := CompareText(
          cbChooseNS.Items[Left.Index], cbChooseNS.Items[Right.Index]
        )
      end
    );
    if cbChooseNS.Count > 0 then
      cbChooseNS.ItemIndex := 0
    else
      cbChooseNS.ItemIndex := -1;
  finally
    cbChooseNS.EndUpdate;
  end;
end;

procedure TMainForm.WriteMapping(const Map: TUnitMap);
var
  Writer: TMapFileWriter;
begin
  Writer := TMapFileWriter.Create(Map);
  try
    Writer.WriteFile;
  finally
    Writer.Free;
  end;
end;

end.

