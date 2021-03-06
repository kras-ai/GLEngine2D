unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls,GLEngine;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;



 var
  Form1: TForm1;
  GLE:TGLEngine;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
 GLE:=TGLEngine.Create;
 GLE.VisualInit(GetDC(Panel1.Handle),Panel1.ClientWidth,Panel1.ClientHeight,4);
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
 gle.BeginRender(false);
 gle.AntiAlias(true);


 gle.FinishRender;
end;

procedure TForm1.FormResize(Sender: TObject);
begin
 gle.Resize(Panel1.Width,Panel1.Height);
end;

end.
