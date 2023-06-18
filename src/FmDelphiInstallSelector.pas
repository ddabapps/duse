{
  Copyright (c) 2022, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/ddabapps/duse
}

unit FmDelphiInstallSelector;

interface

uses
  System.Classes,
  System.Actions,
  FMX.ActnList,
  FMX.StdCtrls,
  FMX.Controls.Presentation,
  FMX.Types,
  FMX.Controls,
  FMX.Layouts,
  FMX.ListBox,
  FMX.Forms;

type
  TDelphiInstallSelectorDlg = class(TForm)
    lbDelphis: TListBox;
    lblDelphis: TLabel;
    btnOK: TButton;
    btnCancel: TButton;
    alMain: TActionList;
    actOK: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure actOKUpdate(Sender: TObject);
    procedure actOKExecute(Sender: TObject);
  strict private
    var
      fSelectedDelphi: string;
  public
    property SelectedDelphi: string read fSelectedDelphi;
  end;


implementation

uses
  UDelphiInstalls;

{$R *.fmx}

procedure TDelphiInstallSelectorDlg.actOKExecute(Sender: TObject);
begin
  Assert(lbDelphis.ItemIndex >= 0);
  fSelectedDelphi := lbDelphis.Selected.Text;
end;

procedure TDelphiInstallSelectorDlg.actOKUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := TDelphiInstalls.HaveInstalls
    and (lbDelphis.ItemIndex >= 0);
end;

procedure TDelphiInstallSelectorDlg.FormCreate(Sender: TObject);
begin
  if TDelphiInstalls.HaveInstalls then
  begin
    for var Name in TDelphiInstalls.Names do
      lbDelphis.Items.Add(Name);
    lbDelphis.ItemIndex := 0;
    lbDelphis.Enabled := True;
    btnOK.Enabled := True;
  end
  else
  begin
    lbDelphis.Enabled := False;
    btnOK.Enabled := False;
  end;
end;

procedure TDelphiInstallSelectorDlg.FormShow(Sender: TObject);
begin
  if lbDelphis.Enabled then
    lbDelphis.SetFocus;
end;

end.
