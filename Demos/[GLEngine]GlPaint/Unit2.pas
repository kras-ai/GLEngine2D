unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, StdCtrls, ExtDlgs,GLEngine;

type
  TForm2 = class(TForm)
    BrushSize: TTrackBar;
    Label1: TLabel;
    GroupBox1: TGroupBox;
    GColor: TTrackBar;
    RColor: TTrackBar;
    AColor: TTrackBar;
    BColor: TTrackBar;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Panel1: TPanel;
    RadioGroup1: TRadioGroup;
    Button1: TButton;
    OpenPictureDialog1: TOpenPictureDialog;
    procedure ColorChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
 Form2: TForm2;
 oim:Cardinal;
implementation
 uses unit1;
{$R *.dfm}

procedure TForm2.ColorChange(Sender: TObject);
begin
 Panel1.Color:=RGB(RColor.Position,GColor.Position,BColor.Position);
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
 if OpenPictureDialog1.Execute then
  begin
   gle.FreeImage(oim);
   gle.BeginRender(false);
   gle.LoadImage(OpenPictureDialog1.FileName,oim,false);
   gle.SwichBlendMode(bmNormal);
   gle.BeginRenderToTex(CreateTex,Form1.Panel1.ClientWidth,Form1.Panel1.ClientHeight);
   gle.SetColor(1,1,1,1);
   gle.DrawImage(0,0,Form1.Panel1.ClientWidth,Form1.Panel1.ClientHeight,0,false,false,oim);
   gle.EndRenderToTex;
   gle.FinishRender;
  end;
end;

procedure TForm2.FormShow(Sender: TObject);
begin
 Panel1.Color:=RGB(RColor.Position,GColor.Position,BColor.Position);
end;

end.
