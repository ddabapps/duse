{
  Copyright (c) 2021-2022, Peter Johnson, delphidabbler.com
  MIT License
  https://github.com/delphidabbler/unit2ns
}

unit UUnitMap;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  Generics.Collections;

type

  TUnitMap = class(TObject)
  public
    type
      TEntry = record
      strict private
        var
          fUnitName: string;
          fNamespace: string;
      public
        constructor Create(const AUnitName, ANamespace: string);
        class function CreateFromFullUnitName(const AFullName: string): TEntry;
          static;
        function SameUnitName(const AUnitName: string): Boolean;
        function SameNamespace(const ANamespace: string): Boolean;
        class function Compare(const A, B: TEntry): Integer; static;
        class function CompareFullUnitNames(const A, B: TEntry): Integer;
          static;
        class operator Equal(const A, B: TEntry): Boolean;
        class operator NotEqual(const A, B: TEntry): Boolean;
        class operator GreaterThan(const A, B: TEntry): Boolean;
        class operator GreaterThanOrEqual(const A, B: TEntry): Boolean;
        class operator LessThan(const A, B: TEntry): Boolean;
        class operator LessThanOrEqual(const A, B: TEntry): Boolean;
        class function NamespaceSeparator: Char; static; inline;
        function GetFullUnitName: string;
        property UnitName: string read fUnitName;
        property Namespace: string read fNamespace;
        property FullUnitName: string read GetFullUnitName;
      end;
  strict private
    type
      TFilterFn = TFunc<TEntry,Boolean>;
      TCopyFn = TFunc<TEntry,string>;
    var
      fMap: TList<TEntry>;
      fName: string;
      fStorageID: string;
    function SelectIndices(const FilterFn: TFilterFn): TArray<Integer>;
    function CopyToArray(const Indices: TArray<Integer>; const MapFn: TCopyFn):
      TArray<string>;
    function Filter(const FilterFn: TFilterFn; const MapFn: TCopyFn):
      TArray<string>;
    function IndexOf(const Entry: TEntry): Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const Entry: TEntry);
    procedure Delete(const Entry: TEntry);
    procedure Update(const OldEntry, NewEntry: TEntry);
    procedure ClearEntries;
    procedure CloneTo(const DestMap: TUnitMap);
    procedure Sort;
    procedure SortByFullUnitName;
    function Contains(const Entry: TEntry): Boolean; inline;
    function IsEmpty: Boolean; inline;
    function FindUnitNamespaces(const UnitName: string): TArray<string>;
    function FindNamespaceUnits(const Namespace: string): TArray<string>;
    function FindUniqueNamespaces: TArray<string>;
    function TryFind(const UnitName, Namespace: string; out Entry: TEntry):
      Boolean;
    function GetEnumerator: TEnumerator<TEntry>;
    class function Compare(const Left, Right: TUnitMap): Integer;
    property Name: string read fName write fName;
    // StorageID used to remember file name first time saved: empty until then
    property StorageID: string read fStorageID write fStorageID;
  end;

  TUnitMaps = class(TObject)
  strict private
    var
      fList: TList<TUnitMap>;
    function GetItem(const Idx: Integer): TUnitMap;
    procedure SetItem(const Idx: Integer; const Value: TUnitMap);
    function IndexOfName(const AName: string): Integer;
    procedure DeleteItemAt(const Idx: Integer);
    function ItemExists(const Item: TUnitMap): Boolean;
    function IndexOfItem(const Item: TUnitMap): Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure AddItem(const Item: TUnitMap);
    procedure DeleteItem(const Item: TUnitMap);
    function GetEnumerator: TEnumerator<TUnitMap>;
    function FindByName(const AName: string): TUnitMap;
    function NameExists(const AName: string): Boolean;
    function IsEmpty: Boolean;
    property Items[const Idx: Integer]: TUnitMap
      read GetItem write SetItem; default;
  end;

implementation

uses
  UExceptions,
  System.StrUtils,
  Generics.Defaults;

{ TUnitMap }

procedure TUnitMap.Add(const Entry: TEntry);
begin
  if Contains(Entry) then
    raise EBug.Create(
      'Attempt to add duplicate entry in Unit/Namespace map'
    );
  fMap.Add(Entry);
end;

procedure TUnitMap.ClearEntries;
begin
  fMap.Clear;
end;

class function TUnitMap.Compare(const Left, Right: TUnitMap): Integer;
begin
  Result := CompareText(Left.Name, Right.Name);
end;

function TUnitMap.Contains(const Entry: TEntry): Boolean;
begin
  Result := IndexOf(Entry) >= 0;
end;

procedure TUnitMap.CloneTo(const DestMap: TUnitMap);
var
  Entry: TEntry;
begin
  DestMap.Name := Self.Name;
  DestMap.StorageID := Self.StorageID;
  DestMap.ClearEntries;
  for Entry in fMap do
    DestMap.fMap.Add(Entry);
end;

function TUnitMap.CopyToArray(const Indices: TArray<Integer>;
  const MapFn: TCopyFn): TArray<string>;
var
  Idx: Integer;
begin
  SetLength(Result, Length(Indices));
  if Length(Result) = 0 then
    Exit;
  for Idx := 0 to Pred(Length(Indices)) do
    Result[Idx] := MapFn(fMap[Indices[Idx]]);
end;

constructor TUnitMap.Create;
begin
  inherited;
  fMap := TList<TEntry>.Create(
    TDelegatedComparer<TEntry>.Create(
      TEntry.Compare
    )
  );
  fStorageID := '';
end;

procedure TUnitMap.Delete(const Entry: TEntry);
var
  Idx: Integer;
begin
  Idx := IndexOf(Entry);
  if Idx < 0 then
    raise EBug.Create(
      'Attempt to delete missing entry in Unit/Namespace map'
    );
  fMap.Delete(Idx);
end;

destructor TUnitMap.Destroy;
begin
  ClearEntries;
  fMap.Free;
  inherited;
end;

function TUnitMap.Filter(const FilterFn: TFilterFn;
  const MapFn: TCopyFn): TArray<string>;
begin
  Result := CopyToArray(SelectIndices(FilterFn), MapFn);
end;

function TUnitMap.FindNamespaceUnits(const Namespace: string): TArray<string>;
begin
  Result := Filter(
    function (Entry: TEntry): Boolean
    begin
      Result := Entry.SameNamespace(Namespace);
    end,
    function (Entry: TEntry): string
    begin
      Result := Entry.UnitName;
    end
  );
end;

function TUnitMap.FindUniqueNamespaces: TArray<string>;
var
  UniqueList: TList<string>;
  Entry: TEntry;
begin
  UniqueList := TList<string>.Create(
    TDelegatedComparer<string>.Create(
      function (const Left, Right: string): Integer
      begin
        Result := CompareText(Left, Right);
      end
    )
  );
  try
    for Entry in fMap do
    begin
      if not UniqueList.Contains(Entry.Namespace) then
        UniqueList.Add(Entry.Namespace);
    end;
    Result := UniqueList.ToArray;
  finally
    UniqueList.Free;
  end;
end;

function TUnitMap.FindUnitNamespaces(const UnitName: string): TArray<string>;
begin
  Result := Filter(
    function (Entry: TEntry): Boolean
    begin
      Result := Entry.SameUnitName(UnitName);
    end,
    function (Entry: TEntry): string
    begin
      Result := Entry.Namespace;
    end
  );
end;

function TUnitMap.GetEnumerator: TEnumerator<TEntry>;
begin
  Result := fMap.GetEnumerator;
end;

function TUnitMap.IndexOf(const Entry: TEntry): Integer;
begin
  Result := fMap.IndexOf(Entry);
end;

function TUnitMap.IsEmpty: Boolean;
begin
  Result := fMap.Count = 0;
end;

function TUnitMap.SelectIndices(const FilterFn: TFilterFn): TArray<Integer>;
var
  Idx: Integer;
  IdxList: TList<Integer>;
begin
  IdxList := TList<Integer>.Create(
    TDelegatedComparer<Integer>.Create(
      function(const Left, Right: Integer): Integer
      begin
        Result := Left - Right;
      end
    )
  );
  try
    for Idx := 0 to Pred(fMap.Count) do
    begin
      if FilterFn(fMap[Idx]) then
        IdxList.Add(Idx);
    end;
    Result := IdxList.ToArray;
  finally
    IdxList.Free;
  end;
end;

procedure TUnitMap.Sort;
begin
  fMap.Sort;
end;

procedure TUnitMap.SortByFullUnitName;
begin
  fMap.Sort(
    TDelegatedComparer<TEntry>.Create(
      TEntry.CompareFullUnitNames
    )
  );
end;

function TUnitMap.TryFind(const UnitName, Namespace: string;
  out Entry: TEntry): Boolean;
var
  FindItem: TEntry;
  Idx: Integer;
begin
  FindItem := TEntry.Create(UnitName, Namespace);
  Idx := IndexOf(FindItem);
  if Idx < 0 then
    Exit(False);
  Entry := fMap[Idx];
  Result := True;
end;

procedure TUnitMap.Update(const OldEntry, NewEntry: TEntry);
var
  OldIdx: Integer;
begin
  OldIdx := IndexOf(OldEntry);
  if OldIdx < 0 then
    raise EBug.Create(
      'Attempt to update non-existent entry in Unit/Namespace map'
    );
  fMap[OldIdx] := NewEntry;
end;

{ TUnitMap.TEntry }

class function TUnitMap.TEntry.Compare(const A, B: TEntry): Integer;
begin
  Result := CompareText(A.UnitName, B.UnitName);
  if Result = 0 then
    Result := CompareText(A.Namespace, B.Namespace);
end;

class function TUnitMap.TEntry.CompareFullUnitNames(const A,
  B: TEntry): Integer;
begin
  Result := CompareText(A.GetFullUnitName, B.GetFullUnitName);
end;

constructor TUnitMap.TEntry.Create(const AUnitName, ANamespace: string);
begin
  fUnitName := AUnitName;
  fNamespace := ANamespace;
end;

class function TUnitMap.TEntry.CreateFromFullUnitName(
  const AFullName: string): TEntry;
var
  LastSepPos: Integer;
begin
  LastSepPos := LastDelimiter(NamespaceSeparator, AFullName);
  if LastSepPos > 0 then
  begin
    // We have a Namespace
    Result := TEntry.Create(
      Copy(AFullName, LastSepPos + 1, Length(AFullName) - LastSepPos),
      Copy(AFullName, 1, LastSepPos - 1)
    );
  end
  else
    Result := TEntry.Create(AFullName, '');
end;

class operator TUnitMap.TEntry.Equal(const A, B: TEntry): Boolean;
begin
  Result := Compare(A, B) = 0;
end;

function TUnitMap.TEntry.GetFullUnitName: string;
begin
  if fNameSpace <> '' then
    Result := fNameSpace + NamespaceSeparator + fUnitName
  else
    Result := fUnitName;
end;

class operator TUnitMap.TEntry.GreaterThan(const A, B: TEntry): Boolean;
begin
  Result := Compare(A, B) > 0;
end;

class operator TUnitMap.TEntry.GreaterThanOrEqual(const A,
  B: TEntry): Boolean;
begin
  Result := Compare(A, B) >= 0;
end;

class operator TUnitMap.TEntry.LessThan(const A, B: TEntry): Boolean;
begin
  Result := Compare(A, B) < 0;
end;

class operator TUnitMap.TEntry.LessThanOrEqual(const A, B: TEntry): Boolean;
begin
  Result := Compare(A, B) <= 0;
end;

class function TUnitMap.TEntry.NamespaceSeparator: Char;
begin
  Result := TPath.ExtensionSeparatorChar;
end;

class operator TUnitMap.TEntry.NotEqual(const A, B: TEntry): Boolean;
begin
  Result := Compare(A, B) <> 0;
end;

function TUnitMap.TEntry.SameNamespace(const ANamespace: string): Boolean;
begin
  Result := CompareText(ANamespace, fNameSpace) = 0;
end;

function TUnitMap.TEntry.SameUnitName(const AUnitName: string): Boolean;
begin
  Result := CompareText(AUnitName, fUnitName) = 0;
end;

{ TUnitMaps }

procedure TUnitMaps.AddItem(const Item: TUnitMap);
begin
  if ItemExists(Item) then
    raise EBug.Create('Attempt to add duplicate unit map to list.');
  fList.Add(Item);
end;

procedure TUnitMaps.Clear;
var
  Idx: Integer;
begin
  for Idx := Pred(fList.Count) downto 0 do
    DeleteItemAt(Idx);
end;

constructor TUnitMaps.Create;
begin
  inherited;
  fList := TList<TUnitMap>.Create(
    TDelegatedComparer<TUnitMap>.Create(TUnitMap.Compare)
  );
end;

procedure TUnitMaps.DeleteItem(const Item: TUnitMap);
var
  Idx: Integer;
begin
  Idx := IndexOfItem(Item);
  if Idx < 0 then
    raise EBug.Create(
      'Attempt to delete non existent unit map from list.'
    );
  DeleteItemAt(Idx);
end;

procedure TUnitMaps.DeleteItemAt(const Idx: Integer);
begin
  if (Idx < 0) or (Idx >= fList.Count) then
    raise EBug.Create('Attempt to delete item with invalid index.');
  var Item: TUnitMap := fList[Idx];
  fList.Delete(Idx);
  Item.Free;
end;

destructor TUnitMaps.Destroy;
begin
  Clear;
  fList.Destroy;
  inherited;
end;

function TUnitMaps.FindByName(const AName: string): TUnitMap;
var
  Idx: Integer;
begin
  Idx := IndexOfName(AName);
  if Idx < 0 then
    raise EBug.Create('Map with given name does not exist in map list');
  Result := fList[Idx];
end;

function TUnitMaps.GetEnumerator: TEnumerator<TUnitMap>;
begin
  Result := fList.GetEnumerator;
end;

function TUnitMaps.GetItem(const Idx: Integer): TUnitMap;
begin
  Result := fList[Idx];
end;

function TUnitMaps.IndexOfItem(const Item: TUnitMap): Integer;
begin
  Result := fList.IndexOf(Item);
end;

function TUnitMaps.IndexOfName(const AName: string): Integer;
var
  Idx: Integer;
begin
  for Idx := 0 to Pred(fList.Count) do
  begin
    if SameText(fList[Idx].Name, AName) then
      Exit(Idx);
  end;
  Result := -1;
end;

function TUnitMaps.IsEmpty: Boolean;
begin
  Result := fList.Count = 0;
end;

function TUnitMaps.ItemExists(const Item: TUnitMap): Boolean;
begin
  Result := IndexOfItem(Item) >= 0;
end;

function TUnitMaps.NameExists(const AName: string): Boolean;
begin
  Result := IndexOfName(AName) >= 0;
end;

procedure TUnitMaps.SetItem(const Idx: Integer; const Value: TUnitMap);
begin
  fList[Idx] := Value;
end;

end.

