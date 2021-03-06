unit PathFind;

interface

uses
  Windows, Classes;

type
  TPath = array of TPoint;  // ��� ��� �������� � �������� ���������� ����.

  TPathMapCell = record   // ������ ����� ���� � ������� �� ��������:
    Distance : Integer;   // - ���������� ����� ������ � �������� �
    Direction : Integer;  // - �����������, � �������� �������� �� ��� ������.
  end;

  TPathMap = array of array of TPathMapCell;  // ����� ����.

  {����������� ��� ��� �������� � ������ ������ �������, ������� ����������
   ��������� �������� �� ������ (X,Y) � ����������� Direction.
   ���� (X,Y) -- �����������, �� ������� ������ ������� -1.
   ���� ������� ������������ � �������� ���������. ��� ������ ���������
   ������ ���������� ������� �� �����������.}
  TGetCostFunc = Function(X,Y,Direction : Integer) : Integer;

{������� ���������� ����� ����� ��� ���� ������ �������� �����.
 ������, ���� �� ������������� ��������� ���� �� ����� � ��� ��
 ��������� ����� � ��������� �������� �����.}
function MakePathMap(
  MapWidth,MapHeight : Integer;
  StartX,StartY : Integer;
  GetCostFunc : TGetCostFunc) : TPathMap;

{������� ���������� ���� � �������� �����, �������� ������������ (X,Y)
 �� ���������� �� ���������� ������� ����� ����.}
function FindPathOnMap(PathMap : TPathMap; X,Y : Integer) : TPath;

{������� ���� ���� �� ����� (StartX,StartY) � ����� (StopX,StopY).}
function FindPath(
  MapWidth,MapHeight : Integer;
  StartX,StartY,StopX,StopY : Integer;
  GetCostFunc : TGetCostFunc) : TPath;

implementation

type
  TWaveCell = record      // ���� ������ ������ �����. ��������:
    X,Y : Integer;        // - ���������� �����, � ������� �� ��������;
    Cost : Integer;       // - �������� ������� �� �������� �� �����;
    Direction : Integer;  // - ����������, �� �������� �� ��������.
  end;

  TWave = class
  private
    FData : array of TWaveCell;
    FPos : Integer;                // ������� ������� � �������.
    FCount : Integer;              // ���������� �������� ��������� � �������.
                                   // ������� ������������� ������� ��� ���������
                                   // ���������� ��������� �� ��������. ������
                                   // ������ ������.
    FMinCost : Integer;
    function GetItem : TWaveCell;
  public
    property Item : TWaveCell read GetItem;    // ������� ������� �������.
    property MinCost : Integer read FMinCost;  // ����������� �������� Cost
                                               // ����� ���� ��������� �������.
    constructor Create;
    destructor Destroy; override;
    procedure Add(NewX,NewY,NewCost,NewDirection : Integer); // ��������� �����
                                                             // ������� � ������.
    procedure Clear;  // ������� ������. �� ����� ���� ����� ���� ������
                      // �������� ���� FCount. ������������ ������ ��
                      // ������������� � ��� �������� �� ����������.
    function Start : Boolean;  // ������ ������������ �������. ������ �������
                               // ������ ������� �������. ���������� false,
                               // ���� ������ ����.
    function Next : Boolean;   // ������ ������� ��������� ������� �������.
                               // ���������� false, ���� ���������� �������� ���.
  end;

var
  GetCostFunc : TGetCostFunc;  // ���������� ��� �������� ������� �����������
                               // ��������� ��������, ���������� �� ��������
                               // ���������.
  MapWidth : Integer;          // ������ �����.
  MapHeight : Integer;         // ������ �����.

constructor TWave.Create;
begin
  Clear;  // �������������� �������� �����.
end;

destructor TWave.Destroy;
begin
  FData:=NIL;  // ����������� ������, ���������� ��������.
  inherited Destroy;
end;

function TWave.GetItem : TWaveCell;
begin
  Result:=FData[FPos];  // ���������� ������� ������� �������.
end;

procedure TWave.Add(NewX,NewY,NewCost,NewDirection : Integer);
begin
  if FCount >= Length(FData)            // ���� �� ������� ����� � �������,
  then                                  // ��
    SetLength(FData,Length(FData)+30);  // ����������� ��� ������. ����� 30
                                        // ����� �� ������.
  with FData[FCount] do
    begin
    X:=NewX;
    Y:=NewY;
    Cost:=NewCost;
    Direction:=NewDirection;
    end;
  if NewCost < FMinCost  // ��������� �������� NewCost �� �������������.
  then
    FMinCost:=NewCost;
  Inc(FCount);           // ����������� ������� ���������� ���������.
end;

procedure TWave.Clear;   // ���������� � �������� ��������� ��� ����.
begin
  FPos:=0;
  FCount:=0;
  FMinCost:=High(Integer);
end;

function TWave.Start : Boolean;
begin
  FPos:=0;               // ������������� ��������� ������� ������ �� ������
  Result:=(FCount > 0);  // �������. ���������� false, ���� ������ ����.
end;

function TWave.Next : Boolean;
begin
  Inc(FPos);                // ����������� ��������� ������� ������. ����������
  Result:=(FPos < FCount);  // false, ���� ������ ��� ���������.
end;

{��������� ������� ����������� ��������� ������������. � ��������� ������
 ���������� ������ ���. ������� �������� �������� Direction � ��������� 0..7,
 � ����� ��������� ����� �� ������� �����. ���� �������, �� ���� ����������
 -1 (��� �����������), � �� �������� �� ������� �������.
 �������� FoolProof: ����� ����������� ���������� ������ �� ������������
 �������� �� ����� �� ������� �����.
 �������� ���������� �������� ���������� �������� �� ������� ������� �
 ���������� ��������� �� ������.}
function GetCost(X,Y,Direction : Integer) : Integer;
begin
  Direction:=(Direction AND 7);
  if (X < 0) OR (X >= MapWidth) OR (Y < 0) OR (Y >= MapHeight)
  then
    Result:=-1
  else
    Result:=GetCostFunc(X,Y,Direction);
end;

{������� ����������: ��������� ����������� � ���������� ���������� X.}
function DirToDX(Direction : Integer) : Integer;
begin
  case Direction of
    0,4  : Result:=0;
    1..3 : Result:=1;
  else
    Result:=-1;
  end;
end;

{������� ����������: ��������� ����������� � ���������� ���������� Y.}
function DirToDY(Direction : Integer) : Integer;
begin
  case Direction of
    2,6  : Result:=0;
    3..5 : Result:=1;
  else
    Result:=-1;
  end;
end;

{�������� ������� ������� -- ���� ���������. ���������� ����� ����,
 ������������ �� ��������� �� �������� �����.
 ��� ��������� ��������� ����� ���� ����������� �� ���������� ���������.}
function FillPathMap(X1,Y1,X2,Y2 : Integer) : TPathMap;
var
  OldWave, NewWave : TWave;
  Finished : Boolean;
  I : TWaveCell;

  procedure PreparePathMap;  // ������� ������������ ������ ��� ��������� �
  var                        // �������� ��� ������ ������ ���� Distance
    X,Y : Integer;           // (����� ������ � ��������) ���������� -1,
  begin                      // �����������, ��� ������ ������ ��� �� ���������.
    SetLength(Result,MapHeight,MapWidth);
    for Y:=0 to (MapHeight-1) do
      for X:=0 to (MapWidth-1) do
        Result[Y,X].Distance:=-1;
  end;

  procedure TestNeighbours;  //��������� ������ ������, �������� � �������,
  var                        // �� ������� ��������� ������� ������� �����.
    X,Y,C,D : Integer;
  begin
   // for D:=7 downto 0 do
   d:=0;
   while d<7 do                    // ������� �� ������
      begin
      X:=OldWave.Item.X+DirToDX(D);
      Y:=OldWave.Item.Y+DirToDY(D);
      C:=GetCost(X,Y,D);
      if (C >= 0) AND (Result[Y,X].Distance < 0) // ���� �� ����������� � ��� ��
      then                                       // ���������, ��
        NewWave.Add(X,Y,C,D);                    // �������� �������� ����.
        d:=d+2;
      end;

   d:=1;
   while d<8 do                 // ������ �� ����������
      begin
      X:=OldWave.Item.X+DirToDX(D);
      Y:=OldWave.Item.Y+DirToDY(D);
      C:=GetCost(X,Y,D);
      if (C >= 0) AND (Result[Y,X].Distance < 0) // ���� �� ����������� � ��� ��
      then                                       // ���������, ��
        NewWave.Add(X,Y,C,D);                    // �������� �������� ����.
        d:=d+2;
      end;
  end;

  procedure ExchangeWaves; // ������ �������� ������ � ����� �����
  var
    W : TWave;
  begin
    W:=OldWave;
    OldWave:=NewWave;
    NewWave:=W;
    NewWave.Clear;
  end;

begin
  PreparePathMap;             // ������� ������ ����������� � ��������� ���
                              // ���������� ����������.
  OldWave:=TWave.Create;
  NewWave:=TWave.Create;
  Result[Y1,X1].Distance:=0;  // ��������, ��� ������ ��������� �����.
  OldWave.Add(X1,Y1,0,0);     // ������� ����� �� ����� ��������� �����
  TestNeighbours;             // ��� ��� ������������ ������� � OldWave �����
                              // �������� Cost = 0, �� TestNeighbours ������� �
                              // NewWave ��������� ���� ����� �� ���� ���������
                              // ������������ �� ��������� �����.
  Finished:=((X1 = X2) AND (Y1 = Y2));  // �������� �� ���������� ��������� �
                                        // �������� �����.
  while NOT Finished do        // ����, ���� �� ������� �������� �����.
    begin
    ExchangeWaves;             // �������� ����� ���� ����� � OldWave �
                               // ����������� NewWave ��� �������� ���������
                               // ����.
    if NOT OldWave.Start then Break;  // ������������� OldWave �� ������. ����
                                      // �������� ���, �� ����� ������. �����.
      repeat                          // ���� �� ������.
        I:=OldWave.Item;                 // ����� ������� ������� �����.
        I.Cost:=I.Cost-OldWave.MinCost;  // ������� �� Cost ����������� ��������
                                         // ��� ���� OldWave �������� ��������,
                                         // ������� ��������� �� ���� (Cost=0).
        if I.Cost > 0                             // ���, ��� �� ��������,
        then                                      // ���������� � NewWave �
          NewWave.Add(I.X,I.Y,I.Cost,I.Direction) // �������� Cost.
        else
          begin
          // ���� �� ������ ��� ��������, �� �����������.
          if Result[I.Y,I.X].Distance >= 0 then Continue;
          // ���� �� ������ �� ��������, �� ���������� � Distance ����� ������
          // �� ��������. ����� ����������� ��� ����� ���������� ������
          // �������� +1.
          Result[I.Y,I.X].Distance:=Result[I.Y-DirToDY(I.Direction),I.X-DirToDX(I.Direction)].Distance+1;
          // ��������� �����������, �� �������� �� ���� ��������.
          Result[I.Y,I.X].Direction:=I.Direction;
          // �������� �� ���������� �������� �����.
          Finished:=((I.X = X2) AND (I.Y = Y2));
          if Finished then Break;
          // �� ����������� ������ ������� ����� ����� �� ���� ���������
          // ������������. ��������� � NewWave.
          TestNeighbours;
          end;
      until NOT OldWave.Next;  // ���������� ����, ���� �� ���������
    end;                       // ��� �������� �� OldWave;
  NewWave.Free;
  OldWave.Free;
end;

function MakePathMap(
  MapWidth,MapHeight : Integer;
  StartX,StartY : Integer;
  GetCostFunc : TGetCostFunc) : TPathMap;
begin
  PathFind.MapWidth:=MapWidth;       // ��������� ���������� �������� ����������
  PathFind.MapHeight:=MapHeight;     // � ��������� ����������, ��� �������������
  PathFind.GetCostFunc:=GetCostFunc; // ������� ����������� ������.
  // ��������� ����� ����, ��� ��� �������� ����� �����������, �� �����
  // ���������� ������ ����� ����, ��� �� ������� ��� ��������� ������.
  // ��������������, �� ������ �� ������� ������ ����� ����.
  Result:=FillPathMap(StartX,StartY,-1,-1);
end;

function FindPathOnMap(PathMap : TPathMap; X,Y : Integer) : TPath;
var
  Direction : Integer;
begin
  Result:=NIL;
  if PathMap[Y,X].Distance < 0 then Exit;
  SetLength(Result,PathMap[Y,X].Distance+1); // ������� ������ ��� ����������.
  // ��������� �� ����� ���� � �������� ������� �� �������� ����� �
  // ��������� ���������� ������ � ������������� �������.
  while PathMap[Y,X].Distance > 0 do
    begin
    Result[PathMap[Y,X].Distance]:=Point(X,Y);
    Direction:=PathMap[Y,X].Direction;
    X:=X-DirToDX(Direction);
    Y:=Y-DirToDY(Direction);
    end;
  Result[0]:=Point(X,Y);  //��������� ��������� ���������� ������ ��������.
end;

function FindPath(
  MapWidth,MapHeight : Integer;
  StartX,StartY,StopX,StopY : Integer;
  GetCostFunc : TGetCostFunc) : TPath;
begin
  PathFind.MapWidth:=MapWidth;       // ��������� ���������� �������� ����������
  PathFind.MapHeight:=MapHeight;     // � ��������� ����������, ��� �������������
  PathFind.GetCostFunc:=GetCostFunc; // ������� ����������� ������.
  // ������� ����� ���� �� �������� ����� � ��� �� ���� �� ��� ����.
  // ���������� ���� ���������� �������.
  Result:=FindPathOnMap(FillPathMap(StartX,StartY,StopX,StopY),StopX,StopY);
end;

end.
