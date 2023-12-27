unit UnitInterface;

interface

uses
  Windows, UnitErrorHandler, UnitVisualization, UnitGameMechanics;

procedure MenuInterface;     stdcall;
procedure MainGameInterface; stdcall;
procedure GameEndInterface;  stdcall;

var FlagEndInteraction :boolean;
    FlagCheckOneInput, FlagCheckOnePausedFrame  :boolean;

implementation

type TDifficulty = (difNone, difEasy, difMedium, difHard);
     TGameMode   = (gmNone, gmSmall, gmNormal, gmLarge);

const P_KEY = $50;
      W_KEY = $57;
      A_KEY = $41;
      S_KEY = $53;
      D_KEY = $44;

var NumberEvent, NumberRead :LongWord;
    MenuRecord :INPUT_RECORD;
    NewCursorCoord :COORD;
    TextDifficulty: byte = 0;
    TextGameMode :byte = 0;
    CurrDifficulty :TDifficulty;
    CurrGameMode :TGameMode;


procedure MenuInteraction;
begin
  if not GetNumberOfConsoleInputEvents(hStdIn, NumberEvent) then ShowError('MENU_INTERFACE');
  if NumberEvent > 0 then
  begin
    if not ReadConsoleInput(hStdIn, MenuRecord, sizeof (INPUT_RECORD), NumberRead) then ShowError('MENU_INTERFACE');
    if (MenuRecord.EventType = KEY_EVENT) then
    begin
      if (MenuRecord.Event.KeyEvent.bKeyDown = True) then
      begin
        case MenuRecord.Event.KeyEvent.wVirtualKeyCode of
          D_KEY:
          begin
            GetCurrentScreenBufferInfo;
            NewCursorCoord.X := ScreenBufferInfo.dwCursorPosition.X + 1;
            NewCursorCoord.Y := ScreenBufferInfo.dwCursorPosition.Y;
            if NewCursorCoord.X <= FrameRight then
              if not SetConsoleCursorPosition(hStdOut, NewCursorCoord) then ShowError('MENU_INTERFACE');
          end;
          A_KEY:
          begin
            GetCurrentScreenBufferInfo;
            NewCursorCoord.X := ScreenBufferInfo.dwCursorPosition.X - 1;
            NewCursorCoord.Y := ScreenBufferInfo.dwCursorPosition.Y;
            if NewCursorCoord.X >= FrameLeft then
              if not SetConsoleCursorPosition(hStdOut, NewCursorCoord) then ShowError('MENU_INTERFACE');
          end;
          W_KEY:
          begin
            GetCurrentScreenBufferInfo;
            NewCursorCoord.X := ScreenBufferInfo.dwCursorPosition.X;
            NewCursorCoord.Y := ScreenBufferInfo.dwCursorPosition.Y - 1;
            if NewCursorCoord.Y >= FrameTop then
              if not SetConsoleCursorPosition(hStdOut, NewCursorCoord) then ShowError('MENU_INTERFACE');
          end;
          S_KEY:
          begin
            GetCurrentScreenBufferInfo;
            NewCursorCoord.X := ScreenBufferInfo.dwCursorPosition.X;
            NewCursorCoord.Y := ScreenBufferInfo.dwCursorPosition.Y + 1;
            if NewCursorCoord.Y <= FrameBottom then
              if not SetConsoleCursorPosition(hStdOut, NewCursorCoord) then ShowError('MENU_INTERFACE');
          end;
          VK_RETURN:
          begin
            GetCurrentScreenBufferInfo;
            case ScreenBufferInfo.dwCursorPosition.Y of
              10:
              begin
                CurrDifficulty := difEasy;
                TextDifficulty := 1;
              end;
              11:
              begin
                CurrDifficulty := difMedium;
                TextDifficulty := 2;
              end;
              12:
              begin
                CurrDifficulty := difHard;
                TextDifficulty := 3;
              end;
              15:
              begin
                CurrGameMode := gmSmall;
                TextGameMode := 1;
              end;
              16:
              begin
                CurrGameMode := gmNormal;
                TextGameMode := 2;
              end;
              17:
              begin
                CurrGameMode := gmLarge;
                TextGameMode := 3;
              end;
              21: if (CurrGameMode <> gmNone) and (CurrDifficulty <> difNone) then FlagEndInteraction := True;
            end;
            if not FlagEndInteraction then MenuNewFrame(TextDifficulty, TextGameMode);
          end;
          VK_ESCAPE: FreeConsole;
        end;
      end;
    end
    //else if (MenuRecord.EventType = WINDOW_BUFFER_SIZE_EVENT) then ShowError('DON''T_RESIZE_WINDOW_YOU,_SILLY_QA_!_!_!')
    else sleep(100);
  end;
end;

procedure MenuInterface;
begin
  MenuInitialization;
  MenuStartingFrame;
  CurrDifficulty := difNone;
  CurrGameMode   := gmNone;
  TextDifficulty := 0;
  TextGameMode   := 0;
  FlagEndInteraction := False;
  FlushConsoleInputBuffer(hStdIn);

  while not FlagEndInteraction do
  begin
    MenuInteraction;
  end;
end;

procedure MainGameInteraction;
begin
  if not GetNumberOfConsoleInputEvents(hStdIn, NumberEvent) then ShowError('MAIN_GAME_INTERFACE');
  if NumberEvent > 0 then
  begin
    if not ReadConsoleInput(hStdIn, MenuRecord, sizeof (INPUT_RECORD), NumberRead) then ShowError('MAIN_GAME_INTERFACE');
    if (MenuRecord.EventType = KEY_EVENT) and (MenuRecord.Event.KeyEvent.bKeyDown = True) then
    begin
      if not FlagPause then
      begin
        case MenuRecord.Event.KeyEvent.wVirtualKeyCode of
          D_KEY:
          begin
            if SnakeBlockedDirection <> bdirRight then
            begin
              SnakeDirection        := dirRight;
              SnakeBlockedDirection := bdirLeft;
              FlagCheckOneInput     := True;
            end;
          end;
          A_KEY:
          begin
            if SnakeBlockedDirection <> bdirLeft then
            begin
              SnakeDirection        := dirLeft;
              SnakeBlockedDirection := bdirRight;
              FlagCheckOneInput     := True;
            end;
          end;
          W_KEY:
          begin
            if SnakeBlockedDirection <> bdirUp then
            begin
              SnakeDirection        := dirUp;
              SnakeBlockedDirection := bdirDown;
              FlagCheckOneInput     := True;
            end;
          end;
          S_KEY:
          begin
            if SnakeBlockedDirection <> bdirDown then
            begin
              SnakeDirection        := dirDown;
              SnakeBlockedDirection := bdirUp;
              FlagCheckOneInput     := True;
            end;
          end;
          P_KEY:
          begin
            FlagPause         := True;
            FlagCheckOneInput := True;
          end;
          VK_ESCAPE: FreeConsole;
        end;
      end
      else if FlagPause then if MenuRecord.Event.KeyEvent.wVirtualKeyCode = P_KEY then FlagPause := False;
    end;
    //if not (MenuRecord.EventType = WINDOW_BUFFER_SIZE_EVENT) then ShowError('DON''T_RESIZE_WINDOW_YOU,_SILLY_QA_!_!_!');
  end;
end;

procedure MainGameInterface;
begin
  if hStdOut = 0 then GetHandle;

  case CurrDifficulty of
    difEasy:
    begin
      SpeedCap     := 50;
      CurrentSpeed := 100;
    end;
    difMedium:
    begin
      SpeedCap     := 30;
      CurrentSpeed := 60;
    end;
    difHard:
    begin
      SpeedCap     := 20;
      CurrentSpeed := 30;
    end;
  end;

  case CurrGameMode of
    gmSmall:
    begin
      FlagObstacles := False;
      FieldLength   := 6;
    end;
    gmNormal:
    begin
      FlagObstacles := False;
      FieldLength   := 10;
    end;
    gmLarge:
    begin
       FlagObstacles := True;
       FieldLength   := 15;
    end;
  end;

  MainGameInitialization;
  GameStartingValues;
  MainGameNewFrame;
  FlagEndInteraction := False;
  FlagCheckOneInput  := False;


  while not FlagEndInteraction do
  begin
    if TickCount mod CurrentSpeed = CurrentSpeed-1 then
    begin
      FlagCheckOneInput       := False;
      FlagCheckOnePausedFrame := False;
      MoveSnake;

      if not FlagFruit then CreateFruit;
      if FlagFruit     then CheckSnakeEat;
      if FlagEat       then Inc(CurrentScore);
      if FlagEat       then SnakeGrow;

      CheckCollision;
      CheckWin;
      if FlagWin or FlagCollision then FlagEndInteraction := True;

      if not FlagEndInteraction then
      begin
        MainGameNewFrame;
        //FlushConsoleInputBuffer(hStdIn);
        TickCount := 0;
        Inc(MovesMade);
      end;
    end
    else if not FlagPause then
    begin
      if not FlagCheckOneInput then MainGameInteraction;
      Sleep(10);
      Inc(TickCount);
    end
    else if FlagPause then
    begin
      if not FlagCheckOnePausedFrame then MainGameNewFrame;
      FlagCheckOnePausedFrame := True;
      MainGameInteraction;
      Sleep(10);
    end;
  end;
end;

procedure GameEndInterface;
begin
  GameEndInitialization;
  GameEndStartingFrame;
end;

end.

