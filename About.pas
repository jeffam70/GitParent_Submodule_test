unit About;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, Global, ShellAPI;

type
  TAboutForm = class(TForm)
    OKButton: TBitBtn;
    VersionLabel: TLabel;
    CopyrightLabel: TLabel;
    Website: TLabel;
    EmailLabel: TLabel;
    SupportsLabel: TLabel;
    Products: TLabel;
    Image1: TImage;
    Copyright: TLabel;
    WebLabel: TLabel;
    EmailAddress: TLabel;
    Label1: TLabel;
    Version: TLabel;
    procedure FormShow(Sender: TObject);
    procedure LabelMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure LabelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation

{ SX_TESTER_AS_PROGRAMMER BUILDS: To compile a special version of Propeller.exe for Parallax's SX Tester As A Programmer (Manufacturing use), see Propeller.dpr. }

uses Main;

{$R *.DFM}

procedure TAboutForm.FormShow(Sender: TObject);
var
  Temp : String;
begin
  {Update version information}
  Version.Caption := GetVersionInfo(Application.ExeName, viVersion) {$IFDEF SX_TESTER_AS_PROGRAMMER} + ' (SXTAP)' {$ENDIF};
  Copyright.Caption := GetVersionInfo(Application.ExeName, viCopyright);
  Temp := GetVersionInfo(Application.ExeName, viComments);
  Products.Caption := copy(Temp, pos(': ', Temp)+2, length(Temp));
end;

{------------------------------------------------------------------------------}

procedure TAboutForm.LabelMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
{User clicked on our web or email address}
begin
  MainForm.ParallaxLinkClick(TControl(Sender).Tag);
end;

{------------------------------------------------------------------------------}

procedure TAboutForm.LabelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  Website.Font.Color := clInactiveCaption * ord(TControl(Sender).Tag = 4) + clBlack * ord(TControl(Sender).Tag <> 4);
  EmailAddress.Font.Color := clInactiveCaption * ord(TControl(Sender).Tag = 5) + clBlack * ord(TControl(Sender).Tag <> 5);
end;

end.
