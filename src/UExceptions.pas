{
  Copyright (c) 2021, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/delphidabbler/unit2ns
}

unit UExceptions;

interface

uses
  System.SysUtils;

type
  EBug = class(Exception);

  EUser = class(Exception);

implementation

end.
