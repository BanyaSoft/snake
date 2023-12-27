unit UnitGameMechanics;

interface

uses
  Windows, UnitErrorHandler, System.SysUtils;

type TCell = array[1..2] of integer;
     TArrayOfCells = array of TCell;
     TObstacleMatrix = array[0..14, 0..14] of byte;
     TDirection = (dirRight, dirDown, dirLeft, dirUp);
     TBlockedDirection = (bdirRight, bdirDown, bdirLeft, bdirUp);
     TColour = word;

var SnakeLength, FieldLength :byte;
    TickCount, MovesMade :cardinal;
    CurrentScore, SpeedCap, CurrentSpeed :word;
    Fruit, SnakeTail, SnakeHead, LostCell :TCell;
    Snake :TArrayOfCells;
    SnakeDirection :TDirection;
    SnakeBlockedDirection :TBlockedDirection;
    FlagFruit, FlagEat, FlagWin, FlagCollision, FlagObstacles, FlagPause :boolean;
    CurrentObstacleSet :TObstacleMatrix;
    SnakeHeadTailColour, SnakeBodyColour, FruitColour, ObstacleColour :TColour;


procedure GameStartingValues; stdcall;
procedure CreateFruit;        stdcall;
procedure MoveSnake;          stdcall;
procedure CheckSnakeEat;      stdcall;
procedure SnakeGrow;          stdcall;
procedure CheckCollision;     stdcall;
procedure CheckWin;           stdcall;
procedure GameEndingValues;   stdcall;

implementation

function GetRandomObstacleSet: TObstacleMatrix;
const ObstacleSets :array [0..4] of TObstacleMatrix =
  (
   ((1,1,1,1,1,0,0,0,0,0,1,1,1,1,1), //FirstTemplate
    (1,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
    (1,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
    (1,0,0,0,0,1,0,0,0,1,0,0,0,0,1),
    (1,0,0,0,0,1,0,0,0,1,0,0,0,0,1),
    (0,0,0,1,1,1,0,0,0,1,1,1,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,1,1,1,0,0,0,1,1,1,0,0,0),
    (1,0,0,0,0,1,0,0,0,1,0,0,0,0,1),
    (1,0,0,0,0,1,0,0,0,1,0,0,0,0,1),
    (1,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
    (1,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
    (1,1,1,1,1,0,0,0,0,0,1,1,1,1,1)),

   ((0,0,0,0,0,0,1,0,1,0,0,0,0,0,0), //SecondTemplate
    (0,0,0,0,0,0,1,0,1,0,0,0,0,0,0),
    (0,0,0,0,0,0,1,0,1,0,0,0,0,0,0),
    (0,0,0,0,0,0,1,0,1,0,0,0,0,0,0),
    (0,0,0,0,0,0,1,0,1,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (1,1,1,1,1,0,1,0,1,0,1,1,1,1,1),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (1,1,1,1,1,0,1,0,1,0,1,1,1,1,1),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,1,0,1,0,0,0,0,0,0),
    (0,0,0,0,0,0,1,0,1,0,0,0,0,0,0),
    (0,0,0,0,0,0,1,0,1,0,0,0,0,0,0),
    (0,0,0,0,0,0,1,0,1,0,0,0,0,0,0),
    (0,0,0,0,0,0,1,0,1,0,0,0,0,0,0)),

   ((0,0,0,1,0,0,0,1,0,0,0,1,0,0,0), //ThirdTemplate
    (0,0,0,1,0,0,0,1,0,0,0,1,0,0,0),
    (0,0,0,1,0,0,0,1,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,1,0,0,0,0,0,0,0),
    (0,0,0,0,0,0,0,1,0,0,0,1,0,0,0),
    (0,0,0,0,0,0,0,1,0,0,0,1,0,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,1,0,0,0),
    (0,0,0,1,0,0,0,0,0,0,0,1,0,0,0),
    (0,0,0,1,0,0,0,0,0,0,0,1,0,0,0),
    (0,0,0,1,0,0,0,0,0,0,0,1,0,0,0),
    (0,0,0,1,0,0,0,1,0,0,0,1,0,0,0),
    (0,0,0,1,0,0,0,1,0,0,0,0,0,0,0),
    (0,0,0,1,0,0,0,1,0,0,0,0,0,0,0),
    (0,0,0,1,0,0,0,1,0,0,0,1,0,0,0),
    (0,0,0,1,0,0,0,1,0,0,0,1,0,0,0)),

   ((1,1,1,1,1,1,1,1,1,1,1,1,1,1,1), //ForthTemplate
    (1,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
    (1,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
    (1,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
    (1,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
    (1,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
    (1,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
    (1,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
    (1,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
    (1,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
    (1,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
    (1,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
    (1,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
    (1,0,0,0,0,0,0,0,0,0,0,0,0,0,1),
    (1,1,1,1,1,1,1,1,1,1,1,1,1,1,1)),

   ((1,0,0,0,0,0,0,0,0,0,0,0,0,0,1), //FifthTemplate
    (0,1,0,0,0,0,1,0,1,0,0,0,0,1,0),
    (0,0,1,0,1,1,0,0,0,1,1,0,1,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,1,0,0,0,0,0,0,0,0,0,1,0,0),
    (0,0,1,0,0,0,0,0,0,0,0,0,1,0,0),
    (0,1,0,0,0,0,0,0,0,0,0,0,0,1,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,1,0,0,0,0,0,0,0,0,0,0,0,1,0),
    (0,0,1,0,0,0,0,0,0,0,0,0,1,0,0),
    (0,0,1,0,0,0,0,0,0,0,0,0,1,0,0),
    (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0),
    (0,0,1,0,1,1,0,0,0,1,1,0,1,0,0),
    (0,1,0,0,0,0,1,0,1,0,0,0,0,1,0),
    (1,0,0,0,0,0,0,0,0,0,0,0,0,0,1))
                                    );
begin
  Randomize;
  Result := ObstacleSets[random(100) mod 5];
end;

procedure GameStartingValues;
begin
  FlagFruit     := False;
  FlagEat       := False;
  FlagWin       := False;
  FlagCollision := False;
  FlagPause     := False;

  SnakeLength  := 2;
  TickCount    := 0;
  CurrentScore := 0;
  MovesMade    := 0;

  SetLength(Snake, SnakeLength);
  Snake[0, 1] := FieldLength div 2;
  Snake[0, 2] := FieldLength div 2;
  Snake[1, 1] := FieldLength div 2 - 1;
  Snake[1, 2] := FieldLength div 2;
  SnakeHead := Snake[0];
  SnakeTail := Snake[1];
  SnakeDirection := dirRight;
  SnakeBlockedDirection := bdirLeft;

  Fruit[1] := 0;
  Fruit[2] := 0;

  if FlagObstacles then CurrentObstacleSet := GetRandomObstacleSet;

  SnakeHeadTailColour := BACKGROUND_GREEN;
  SnakeBodyColour     := BACKGROUND_GREEN or BACKGROUND_INTENSITY;
  FruitColour         := BACKGROUND_RED;
  ObstacleColour      := BACKGROUND_BLUE;
end;

procedure CreateFruit;
var i, j :byte;
    FlagError :boolean;
begin
  Randomize;
  FlagFruit := True;
  repeat
    FlagError := False;
    Fruit[1] := Random(FieldLength);
    Fruit[2] := Random(FieldLength);
    for i := 0 to SnakeLength-1 do if (Fruit[1] = Snake[i, 1]) and (Fruit[2] = snake[i, 2]) then FlagError := True;
    if FlagObstacles then
    for i := 0 to FieldLength-1 do
    for j := 0 to FieldLength-1 do
    if (CurrentObstacleSet[i, j] = 1) then if (j = Fruit[1]) and (i = Fruit[2]) then FlagError := True;
  until not FlagError;
end;

procedure MoveSnake;
var NewHead :TCell;
    LengthCount :byte;
begin
  case SnakeDirection of
  dirRight:
  begin
    NewHead[1] := SnakeHead[1] + 1;
    NewHead[2] := SnakeHead[2];
  end;
  dirLeft:
  begin
    NewHead[1] := SnakeHead[1] - 1;
    NewHead[2] := SnakeHead[2];
  end;
  dirUp:
  begin
    NewHead[1] := SnakeHead[1];
    NewHead[2] := SnakeHead[2] - 1;
  end;
  dirDown:
  begin
    NewHead[1] := SnakeHead[1];
    NewHead[2] := SnakeHead[2] + 1;
  end;
  end;

  if      NewHead[1] = -1          then NewHead[1] := FieldLength-1
  else if NewHead[1] = FieldLength then NewHead[1] := 0;
  if      NewHead[2] = -1          then NewHead[2] := FieldLength-1
  else if NewHead[2] = FieldLength then NewHead[2] := 0;

  LostCell := Snake[SnakeLength-1];
  for LengthCount := SnakeLength-2 downto 0 do Snake[LengthCount+1] := Snake[LengthCount];
  Snake[0]  := NewHead;
  SnakeHead := NewHead;
  SnakeTail := Snake[SnakeLength-1];
end;

procedure CheckSnakeEat;
begin
  if (Fruit[1] = SnakeHead[1]) and (Fruit[2] = SnakeHead[2]) then FlagEat := True
  else FlagEat := False;
end;

procedure SnakeGrow;
begin
  FlagFruit := False;
  FlagEat   := False;
  if CurrentSpeed > SpeedCap then Dec(CurrentSpeed, 1);
  Fruit[1] := 0;
  Fruit[2] := 0;
  Inc(SnakeLength);
  SetLength(Snake, SnakeLength);
  Snake[SnakeLength-1] := LostCell;
  SnakeTail := Snake[SnakeLength-1];
end;

procedure CheckCollision;
var i, j, LengthCount :byte;
begin
  FlagCollision := False;
  for i := 0 to SnakeLength-1 do for j := i+1 to SnakeLength-1 do if (Snake[i, 1] = Snake[j, 1]) and (Snake[i, 2] = Snake[j, 2]) then FlagCollision := True;
  if FlagObstacles then
  begin
    for i := 0 to FieldLength-1 do
    for j := 0 to FieldLength-1 do
    for LengthCount := 0 to SnakeLength-1 do
    if (CurrentObstacleSet[i, j] = 1) and (j = Snake[LengthCount, 1]) and (i = Snake[LengthCount, 2]) then FlagCollision := True;
  end;
end;

procedure CheckWin;
begin
  if not FlagObstacles then
  begin
    if CurrentScore = FieldLength*FieldLength-2 then FlagWin := True;
  end;
end;

procedure GameEndingValues;
begin
  SetLength(Snake, 0);
end;

end.
