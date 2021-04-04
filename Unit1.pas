unit Unit1;

interface

uses SysUtils, Windows;

function TryStrToInt(const S: string; Default: Integer): Integer;
function TryStrToFloat(const S: string; Default: Real): Real;
procedure ClearScreen;

implementation

function TryStrToInt(const S: string; Default: Integer): Integer;
begin
  try
  Result := StrToInt(S);
  except
  Result := Default;
  end;
end;

function TryStrToFloat(const S: string; Default: Real): Real;
begin
  try
  Result := StrToFloat(S);
  except
  Result := Default;
  end;
end;

procedure ClearScreen;
var
  stdout: THandle;
  csbi: TConsoleScreenBufferInfo;
  ConsoleSize: DWORD;
  NumWritten: DWORD;
  Origin: TCoord;
begin
  stdout := GetStdHandle(STD_OUTPUT_HANDLE);
  Win32Check(stdout<>INVALID_HANDLE_VALUE);
  Win32Check(GetConsoleScreenBufferInfo(stdout, csbi));
  ConsoleSize := csbi.dwSize.X * csbi.dwSize.Y;
  Origin.X := 0;
  Origin.Y := 0;
  Win32Check(FillConsoleOutputCharacter(stdout, ' ', ConsoleSize, Origin, 
    NumWritten));
  Win32Check(FillConsoleOutputAttribute(stdout, csbi.wAttributes, ConsoleSize, Origin, 
    NumWritten));
  Win32Check(SetConsoleCursorPosition(stdout, Origin));
end;

end.
 