unit rmMultiStrings;

interface

uses classes, sysutils;

type
   ErmMultiStringNameException = Exception;
   TrmMultiStringsCollection = class;

   TrmMultiStringCollectionItem = class(TCollectionItem)
   private
     fItemDesc: string;
     fItemName: string;
     fData : TStringList;
     fMultiStrings : TrmMultiStringsCollection;
     function GetStrings: TStringList;
     function GetStringText: String;
     procedure SetItemName(const Value: string);
     procedure SetStrings(const Value: TStringList);
     procedure SetStringText(const Value: String);
   public
     constructor Create(Collection: TCollection); override;
     destructor Destroy; override;

     procedure Assign(Source: TPersistent); override;
   published
     property ItemName : string read fItemName write SetItemName;
     property Description : string read fItemDesc write fItemDesc;
     property Strings : TStringList read GetStrings write SetStrings stored false;
     property Text : String read GetStringText write SetStringText;
   end;

   TrmMultiStringsCollection = class(TOwnedCollection)
   private
     function GetItem(AIndex: integer): TrmMultiStringCollectionItem;
     procedure SetItem(AIndex: integer; const Value: TrmMultiStringCollectionItem);
   public

     function Add: TrmMultiStringCollectionItem;

     function IndexOf(ItemName:string):integer;
     function ValueOf(ItemName:string):String;
     function ValueOfIndex(aIndex:integer):string;

     procedure Assign(Source: TPersistent); override;

     property Items[AIndex: integer] : TrmMultiStringCollectionItem read GetItem write SetItem;
   end;

   TrmMultiStrings = class(TComponent)
   private
     fData : TrmMultiStringsCollection;
     procedure SetData(const Value: TrmMultiStringsCollection);
   public
     constructor Create(AOwner: TComponent); override;
     destructor Destroy; override;

     function IndexOf(ItemName:string):integer;
     function ValueOf(ItemName:string):String;
     function ValueOfIndex(aIndex:integer):string;
   published
     property Data : TrmMultiStringsCollection read fData write SetData;
   end;

procedure Register;

implementation

procedure Register;
begin
   RegisterClass(TrmMultiStringsCollection);
   RegisterClass(TrmMultiStringCollectionItem);
   RegisterComponents('rmConcordia', [TrmMultiStrings]);
end;


{ TrmMultiStringCollectionItem }

procedure TrmMultiStringCollectionItem.Assign(Source: TPersistent);
var
  wSrc : TrmMultiStringCollectionItem;
begin
  if Source is TrmMultiStringCollectionItem then
  begin
    wSrc := TrmMultiStringCollectionItem(Source);
    ItemName := wSrc.ItemName;
    Description := wSrc.Description;
    Text := wSrc.Text;
  end
  else
    inherited;
end;

constructor TrmMultiStringCollectionItem.Create(Collection: TCollection);
begin
  inherited;
  fMultiStrings := TrmMultiStringsCollection(Collection);
  fData := TStringList.create;
end;

destructor TrmMultiStringCollectionItem.Destroy;
begin
  fData.free;
  inherited;
end;

function TrmMultiStringCollectionItem.GetStrings: TStringList;
begin
   result := fData;
end;

function TrmMultiStringCollectionItem.GetStringText: String;
begin
   result := fData.Text;
end;

procedure TrmMultiStringCollectionItem.SetItemName(const Value: string);
begin
  if (fItemName <> Value) then
  begin
     if fMultiStrings.IndexOf(Value) = -1 then
        fItemName := Value
     else
        raise ErmMultiStringNameException.Create('Item name already exists');
  end;
end;

procedure TrmMultiStringCollectionItem.SetStrings(
  const Value: TStringList);
begin
   fData.Assign(Value);
end;

procedure TrmMultiStringCollectionItem.SetStringText(const Value: String);
begin
   fData.Text := Value;
end;

{ TrmMultiStringsCollection }

function TrmMultiStringsCollection.Add: TrmMultiStringCollectionItem;
begin
   result := TrmMultiStringCollectionItem(inherited Add);
   result.ItemName := 'Item_'+inttostr(NextID);
end;

procedure TrmMultiStringsCollection.Assign(Source: TPersistent);
var
   wSrc : TrmMultiStringsCollection;
   loop : integer;
begin
  if (source is TrmMultiStringsCollection)  then
  begin
     wSrc := TrmMultiStringsCollection(Source);
     Clear;
     for loop := 0 to wSrc.Count - 1 do
        Add.Assign(wSrc.Items[loop]);
  end
  else
    inherited;
end;

function TrmMultiStringsCollection.GetItem(
  AIndex: integer): TrmMultiStringCollectionItem;
begin
   result := TrmMultiStringCollectionItem(inherited Items[AIndex]);
end;

function TrmMultiStringsCollection.IndexOf(ItemName: string): integer;
var
   loop : integer;
begin
   result := -1;
   loop := 0;
   while (result = -1) and (loop < Count) do
   begin
      if (CompareText(Items[loop].ItemName, ItemName) = 0) then
         result := loop
      else
         inc(loop);
   end;
end;

procedure TrmMultiStringsCollection.SetItem(AIndex: integer; const Value: TrmMultiStringCollectionItem);
begin
  inherited SetItem(AIndex, Value)
end;

function TrmMultiStringsCollection.ValueOf(ItemName: string): String;
begin
   result := ValueOfIndex(IndexOf(ItemName));
end;

function TrmMultiStringsCollection.ValueOfIndex(aIndex: integer): string;
begin
   if (aIndex >= 0) and (aIndex < Count) then
     result := Items[aIndex].Text
   else
     result := '';
end;

{ TrmMultiStrings }

constructor TrmMultiStrings.Create(AOwner: TComponent);
begin
  inherited;
  fData := TrmMultiStringsCollection.Create(self, TrmMultiStringCollectionItem);
end;

destructor TrmMultiStrings.Destroy;
begin
  fData.Free;
  inherited;
end;

function TrmMultiStrings.IndexOf(ItemName: string): integer;
begin
   result := Data.IndexOf(ItemName);
end;

procedure TrmMultiStrings.SetData(const Value: TrmMultiStringsCollection);
begin
  fData.Assign(Value);
end;

function TrmMultiStrings.ValueOf(ItemName: string): String;
begin
   result := Data.ValueOf(ItemName);
end;

function TrmMultiStrings.ValueOfIndex(aIndex: integer): string;
begin
   result := Data.ValueOfIndex(aIndex);
end;

end.
