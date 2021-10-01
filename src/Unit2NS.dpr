{
  Copyright (c) 2021, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/delphidabbler/unit2ns
}

program Unit2NS;

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
  UClipboard in 'UClipboard.pas';

{$R Resources.res}

begin
  {$IF defined(DEBUG)}
  ReportMemoryLeaksOnShutdown := True;
  {$ENDIF}
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.

