unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,GLEngine, ExtCtrls, StdCtrls, sEdit, sSpinEdit, sButton,PathFind,
  Buttons;

 const
   SizeMap1=100;
   
type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Timer1: TTimer;
    Panel2: TPanel;
    Panel3: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Panel1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Panel1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure Panel2Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;


  TMap=Class
   public
    nx,kx,ny,ky:integer;
   private

    xm,ym:integer;
    fdata: array of array of integer;
//    fdata:array[0..SizeMap,0..SizeMap]of integer;

   public
    TileCountX,TileCountY:integer;
   Constructor Create(SizeMapX,SizeMapY:integer);
   Procedure SetPoint(x,y,a:Integer);
   procedure draw;
   procedure Zoom(kx,ky:integer);
   Procedure Move(dx,dy:integer);
   Function GetPath(x,y,tox,toy:integer):TPath;
   Function GetCellWidth:single;
   Function GetCellHeigth:single;

   Function GetXYCenterCell(x,y:integer):TPoint;
   Function GetCellFromXY(x,y:integer):TPoint;

   Procedure SaveToFile(FileName:String);
   Procedure LoadFromFile(FileName:String);
  end;

  TUnit=class
   dx,dy,x,y:single;
   PathMove:Tpath;
   Constructor Create(xn,yn:integer);
   Procedure draw;
   Procedure move;
  end;

var
  Form1: TForm1;
  gle:TGLEngine;
  map:Tmap;
  imTr,imSt:Cardinal;

  mx,my:integer;
  drag:boolean=false;
  PaintMap:Boolean=false;

  Path : TPath;
  FPathMap:TPathMap;

  function MovingCost(X,Y,Direction : Integer) : Integer;
implementation

{$R *.dfm}

function MovingCost(X,Y,Direction : Integer) : Integer;
begin
 if map.fdata[y,x]=0 then
  Result:=2
 else
  Result:=-1
{  Result:=TerrainParams[Form1.FData[Y,X].TerrainType].MoveCost;
  if ((Direction AND 1) = 1) AND (Result > 0)
  then
    Result:=Result+(Result SHR 1); }
end;

{ TMap }

constructor TMap.Create(SizeMapX,SizeMapY:integer);
//var
// i,j:integer;
begin
 xm:= SizeMapX-1;
 ym:= SizeMapY-1;
 setlength(fdata,xm+1,ym+1);
 nx:=0;   ny:=0;
 TileCountX:=50;
 TileCountY:=50;

 kx:=nx+TileCountX; ky:=ny+TileCountY;

{ for i:=0 to xm do
  for j:=0 to ym do
  if random>0.7 then
   fdata[i,j]:=1
  else
   fdata[i,j]:=0  }
end;

procedure TMap.SetPoint(x, y, a: Integer);
begin
 fdata[x,y]:=a;
end;

procedure TMap.draw;
var
 i,j:integer;
 dx,dy,x,y:single;
begin

 kx:=nx+TileCountX;
 ky:=ny+TileCountY;

 x:=0;y:=0;

 if (nx<0) then
 begin
  nx:=0;
  kx:= nx+TileCountX;
 end;

 if (kx>=xm) then
 begin
  nx:=xm-TileCountX;
  kx:= xm;
 end;

 if (ny<0) then
 begin
  ny:=0;
  ky:= ny+TileCountY;
 end;

 if (Ky>=ym) then
 begin
  ny:=ym-TileCountY;
  ky:= ym;
 end;

 dx:=map.GetCellWidth;
 dy:=map.GetCellHeigth;

 gle.DrawTileImage(x,y,Form1.Panel1.ClientWidth,Form1.Panel1.ClientHeight,nx-kx,ny-ky,0,imtr);

 for i:=nx to kx do
 begin
  for j:=ny to ky do
  begin
   if fdata[i,j]<>0 then
 //   gle.DrawImage(x,y,dx,dy,0,false,false,imtr)
 //  else
    gle.DrawImage(x,y,dx,dy,0,false,false,imst);
   y:=y+dy;
  end ;
  y:=0;
  x:=x+dx;
 end;

 /////////////////////////////////////////////
 ///             ������ ����               ///
 /////////////////////////////////////////////

  gle.SetColor(1,0,0,0.5);
  if path <> NIL
  then
    for i:=0 to High(path) do
      begin       // "�" � "�" ���� �������� 
       if (path[i].Y>=nx)and(path[i].Y<=kx)and(path[i].X>=ny)and(path[i].X<=ky) then
         gle.Bar(((path[i].Y-nx))*dx,((path[i].X-nY))*dy,((path[i].Y-nx))*dx+dx,((path[i].X-nY))*dy+dy);
      end;
  gle.SetColor(1,1,1,1);
end;

function TMap.GetCellHeigth: single;
begin
 result:=Form1.Panel1.ClientWidth/TileCountX;
end;

function TMap.GetCellWidth: single;
begin
 result:=Form1.Panel1.ClientHeight/TileCountY;
end;

function TMap.GetXYCenterCell(x, y: integer): TPoint;
var
 dx,dy:single; // ������� � ���������� ��� ����� ������ � �������� ��� ������������� � ���������������    -- ������!
begin
 dx:=GetCellWidth;
 dy:=GetCellHeigth;
 result.X:=Round(x*dx-dx/2);
 result.Y:=Round(y*dy-dy/2);
end;

function TMap.GetCellFromXY(x, y: integer): TPoint;
begin
 result.X:= round((nx+x) / GetCellWidth);
 result.y:= round((ny+y) / GetCellHeigth);
end;

function TMap.GetPath(x, y, tox, toy: integer): TPath;
begin
 FPathMap:=MakePathMap(SizeMap1,SizeMap1,y,x,MovingCost);
 result:=FindPathOnMap(FPathMap,toy,tox);
end;

procedure TMap.Move(dx, dy: integer);
begin
 map.nx:=map.nx-dx;  map.kx:=map.kx-dx;
 map.ny:=map.ny-dy;  map.ky:=map.ky-dy;
end;


procedure TMap.Zoom(kx, ky: integer);
begin
  map.TileCountX:=map.TileCountX+kx;
  map.TileCountY:=map.TileCountY+ky;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
 randomize;
 GLE:=TGLEngine.Create;
 GLE.VisualInit(GetDC(Panel1.Handle),Panel1.ClientWidth,Panel1.ClientHeight,0);
 GLE.LoadImage(ExtractFilePath(application.ExeName)+'tr.bmp',imTr,false);
 GLE.LoadImage(ExtractFilePath(application.ExeName)+'st.bmp',imSt,false);
 map:=Tmap.Create(SizeMap1,SizeMap1);
 Timer1.Enabled:=true;
 path:=nil;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
 gle.BeginRender(true);
 gle.SetColor(1,1,1,1);
  map.draw;

 gle.SetColor(1,1,1,0.5);
 gle.Bar(0,0,100,100);
 gle.SetColor(0,0,1,0.7);
 gle.Bar(100*map.nx/SizeMap1,100*map.ny/SizeMap1,100*map.kx/SizeMap1,100*map.ky/SizeMap1);
 gle.FinishRender;
end;

procedure TForm1.Panel1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
 dx,dy,dlx,dly:integer;
 kx,ky:single;
 mousex,mousey:integer;
begin

 kx:=map.GetCellWidth;
 ky:=map.GetCellHeigth;

 MouseX:= map.GetCellFromXY(x,y).X;
 MouseY:=map.GetCellFromXY(x,y).Y;

 if drag then
  begin
   dx:=x-mx;
   dy:=y-my;

    dlx:=Round(dx /kx);
    dly:=Round(dy /ky);

    if (ABS(dlx)>=1) or (ABS(dly)>=1) then
     begin
      mx:=x;
      my:=y;
     end;

   map.Move(dlx,dly);

  end ;

  if PaintMap then
  begin

   map.SetPoint(map.nx+ MouseX,map.ny+MouseY,1);

  end;

  if (not PaintMap) and (not drag) then
   Path:= map.GetPath(3,3,MouseX,MouseY-1);

 Form1.Caption:=IntToStr(MouseX)+'x'+IntToStr(MouseY);
end;

procedure TForm1.Panel1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
 var
  kx,ky:integer;
begin

 kx:=Round(Panel1.ClientWidth/ map.TileCountX);
 ky:=Round(Panel1.ClientHeight/map.TileCountY);

 if Button=mbLeft then
 begin
  mx:=x;my:=y;
  drag:=true;
 end;

 if Button=mbRight then
 begin
  mx:=x;my:=y;
  PaintMap:=true;
    map.SetPoint(map.nx+Round(x/kx),map.ny+Round(y/ky),1);
 end;

end;

procedure TForm1.Panel1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
 drag:=false;
 PaintMap:=false;
end;

procedure TForm1.FormMouseWheel(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
 if WheelDelta>0 then
  map.Zoom(1,1)
 else
  map.Zoom(-1,-1)
end;


procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
 case key of
  vk_down:map.Move(0,-1);
  vk_up:map.Move(0,1);
  vk_left:map.Move(1,0);
  vk_right:map.Move(-1,0);
 end;
end;

procedure TForm1.Panel2Click(Sender: TObject);
var
 bx,by,kx,ky:integer;
begin
 repeat
  bx:=random(30);
  by:=random(30);
 until map.fdata[bx,by]=0;

 repeat
  kx:=100+random(30);
  ky:=100+random(30);
 until map.fdata[kx,ky]=0;
 
 path:=map.GetPath(bx,by,kx,ky);
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);

begin
 if SaveDialog1.Execute then
  begin
   map.SaveToFile(SaveDialog1.FileName);
  end;
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
  if OpenDialog1.Execute then
  begin
   map.LoadFromFile(OpenDialog1.FileName);
  end;
end;

procedure TMap.SaveToFile(FileName: String);
var
 fs:TFileStream;
 i,j:integer;
begin
 fs:=TFileStream.Create(FileName,fmCreate);
 fs.Write(xm,SizeOf(integer));
 fs.Write(ym,SizeOf(integer));

  for i:= 0 to xm do
   for j:= 0 to ym do
    fs.Write(map.fdata[i][j],SizeOf(integer));

// fs.WriteBuffer(map.fdata[0][0],(xm+1)*(ym+1));
 fs.Free;
end;

procedure TMap.LoadFromFile(FileName: String);
var
 fs:TFileStream;
 i,j:integer;
begin
 fs:=TFileStream.Create(FileName,fmOpenRead);
 fs.Read(xm,SizeOf(integer));
 fs.Read(ym,SizeOf(integer));

  for i:= 0 to xm do
   for j:= 0 to ym do
    fs.read(map.fdata[i][j],SizeOf(integer));

// fs.ReadBuffer(map.fdata[0][0],(xm+1)*(ym+1));
 fs.Free;

end;







{ TUnit }

constructor TUnit.Create(xn, yn: integer);
begin
 x:=xn;
 y:=yn;

end;

procedure TUnit.draw;
begin
 gle.SetColor(0,0,1,1);
 gle.Bar(x,y,5,5,0);
end;

procedure TUnit.move;
begin

end;

end.
