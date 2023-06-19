{
  Copyright (c) 2021, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/delphidabbler/unit2ns
}

program DUSE;

uses
  System.StartUpCopy,
  FMX.Forms,
  FmMain in 'FmMain.pas' {MainForm},
  UUnitMap in 'UUnitMap.pas',
  UDataIO in 'UDataIO.pas',
  UConfig in 'UConfig.pas',
  FmMappingEditorBase in 'FmMappingEditorBase.pas' {MappingEditorBaseDlg},
  UExceptions in 'UExceptions.pas',
  FmEditMapping in 'FmEditMapping.pas' {EditMappingDlg},
  FmNewMapping in 'FmNewMapping.pas' {NewMappingDlg},
  UClipboard in 'UClipboard.pas',
  UDelphiInstalls in 'UDelphiInstalls.pas',
  FmDelphiInstallSelector in 'FmDelphiInstallSelector.pas' {DelphiInstallSelectorDlg};

{$R Resources.res}

begin
  {$IF defined(DEBUG)}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

