unit DevAll.Migracao;

interface

uses
  System.Classes, System.SysUtils, FireDAC.Comp.Client;

type
  EDevAllMigracaoNameException = Exception;
  TDevAllCamposCollection = class;

  TCampoTipo = (ctNaoDefinido, ctInteger, ctString, ctNumeric, ctDate);
  TCampoBeforeChangeEvent = procedure (const ACampoOrigem, ACampoDestino: string; var AValor: Variant) of object;
  TIncProgressBarEvent = procedure (const APosicao: Integer) of object;
  TMensagemEvent = procedure (const ATabela, AMsg: string) of object;
  TValidarRegistroEvent = procedure (const AOrigem: TFDQuery; var APodeMigrar: Boolean) of object;

  TDevAllCampoCollectionItem = class(TCollectionItem)
  private
    fCampos : TDevAllCamposCollection;
    fsOnBeforeChange: TCampoBeforeChangeEvent;
    fsStrUpper: Boolean;
    FIgnorarZero: Boolean;
    fsEscala: Integer;
    fsEquivalente: string;
    fsPrecisao: Integer;
    fsValorDefault: Variant;
    fsStrSoNumero: Boolean;
    fsPermiteNulo: Boolean;
    fsNome: string;
    fsTipo: TCampoTipo;
    fsTamanho: Integer;
    procedure setNome(const Value: string);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;
  published
    property Nome: string read fsNome write setNome;
    property Tipo: TCampoTipo read fsTipo write fsTipo default ctNaoDefinido;
    property Precisao: Integer read fsPrecisao write fsPrecisao;
    property Escala: Integer read fsEscala write fsEscala;
    property Tamanho: Integer read fsTamanho write fsTamanho;
    property PermiteNulo: Boolean read fsPermiteNulo write fsPermiteNulo default True;
    property Equivalente: string read fsEquivalente write fsEquivalente;
    property ValorDefault: Variant read fsValorDefault write fsValorDefault;
    property StrSoNumero: Boolean read fsStrSoNumero write fsStrSoNumero default False;
    property StrUpper: Boolean read fsStrUpper write fsStrUpper default True;
    property IgnorarZero: Boolean read FIgnorarZero write FIgnorarZero default False;
    property OnBeforeChange: TCampoBeforeChangeEvent read fsOnBeforeChange write fsOnBeforeChange;
  end;

  TDevAllCamposCollection = class(TOwnedCollection)
  private
    function GetItem(AIndex: integer): TDevAllCampoCollectionItem;
    procedure SetItem(AIndex: integer; const Value: TDevAllCampoCollectionItem);
  public

    function Add: TDevAllCampoCollectionItem;

    function IndexOf(ItemName:string):integer;
    function ValueOf(ItemName:string):String;
    function ValueOfIndex(aIndex:integer):string;

    procedure Assign(Source: TPersistent); override;

    property Items[AIndex: integer] : TDevAllCampoCollectionItem read GetItem write SetItem;
  end;

  TBancoDeDados = class(TComponent)
  private
    FConexao: TFDConnection;
    FTabela: string;
    FSQL: TStringList;
    function GetSQL: TStringList;
    procedure SetSQL(const Value: TStringList);
  protected
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
  published
    property Conexao: TFDConnection read FConexao;
    property Tabela: string read FTabela write FTabela;
    property SQL: TStringList read GetSQL write SetSQL;
  end;

  TDevAllMigracao = class(TComponent)
  private
    fCampos : TDevAllCamposCollection;
    FDestino: TBancoDeDados;
    FOrigem: TBancoDeDados;
    procedure SetCampos(const Value: TDevAllCamposCollection);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    function IndexOf(ItemName:string):integer;
    function ValueOf(ItemName:string):String;
    function ValueOfIndex(aIndex:integer):string;
  published
    property Origem: TBancoDeDados read FOrigem;
    property Destino: TBancoDeDados read FDestino;
    property Campos: TDevAllCamposCollection read fCampos write SetCampos;
  end;

procedure Register;

implementation

procedure Register;
begin
   RegisterClass(TDevAllCamposCollection);
   RegisterClass(TDevAllCampoCollectionItem);
   RegisterComponents('DevAll Migracao', [TDevAllMigracao]);
end;


{ TDevAllCampoCollectionItem }

procedure TDevAllCampoCollectionItem.Assign(Source: TPersistent);
var
  wSrc : TDevAllCampoCollectionItem;
begin
  if Source is TDevAllCampoCollectionItem then
  begin
    wSrc := TDevAllCampoCollectionItem(Source);
    Nome := wSrc.Nome;
    Tipo := wSrc.Tipo;
    Precisao := wSrc.Precisao;
    Escala := wSrc.Escala;
    Tamanho := wSrc.Tamanho;
    PermiteNulo := wSrc.PermiteNulo;
    Equivalente := wSrc.Equivalente;
    ValorDefault := wSrc.ValorDefault;
    StrSoNumero := wSrc.StrSoNumero;
    StrUpper := wSrc.StrUpper;
    IgnorarZero := wSrc.IgnorarZero;
    OnBeforeChange := wSrc.OnBeforeChange;
  end
  else
    inherited;
end;

constructor TDevAllCampoCollectionItem.Create(Collection: TCollection);
begin
  inherited;
  fCampos := TDevAllCamposCollection(Collection);
end;

destructor TDevAllCampoCollectionItem.Destroy;
begin
  inherited Destroy;
end;

function TDevAllCampoCollectionItem.GetDisplayName: string;
begin
  Result := ClassName;
  if Nome <> '' then
    Result := Nome;
end;

procedure TDevAllCampoCollectionItem.setNome(const Value: string);
begin
  if (fsNome <> Value) then
  begin
     if fCampos.IndexOf(Value) = -1 then
        fsNome := Value
     else
        raise EDevAllMigracaoNameException.Create('Item já existe');
  end;
end;

{ TDevAllCamposCollection }

function TDevAllCamposCollection.Add: TDevAllCampoCollectionItem;
begin
   result := TDevAllCampoCollectionItem(inherited Add);
end;

procedure TDevAllCamposCollection.Assign(Source: TPersistent);
var
   wSrc : TDevAllCamposCollection;
   loop : integer;
begin
  if (source is TDevAllCamposCollection)  then
  begin
     wSrc := TDevAllCamposCollection(Source);
     Clear;
     for loop := 0 to wSrc.Count - 1 do
        Add.Assign(wSrc.Items[loop]);
  end
  else
    inherited;
end;

function TDevAllCamposCollection.GetItem(
  AIndex: integer): TDevAllCampoCollectionItem;
begin
   result := TDevAllCampoCollectionItem(inherited Items[AIndex]);
end;

function TDevAllCamposCollection.IndexOf(ItemName: string): integer;
var
   loop : integer;
begin
   result := -1;
   loop := 0;
   while (result = -1) and (loop < Count) do
   begin
      if (CompareText(Items[loop].Nome, ItemName) = 0) then
         result := loop
      else
         inc(loop);
   end;
end;

procedure TDevAllCamposCollection.SetItem(AIndex: integer; const Value: TDevAllCampoCollectionItem);
begin
  inherited SetItem(AIndex, Value);
end;

function TDevAllCamposCollection.ValueOf(ItemName: string): String;
begin
   result := ValueOfIndex(IndexOf(ItemName));
end;

function TDevAllCamposCollection.ValueOfIndex(aIndex: integer): string;
begin
   if (aIndex >= 0) and (aIndex < Count) then
     result := Items[aIndex].Nome
   else
     result := '';
end;

{ TDevAllMigracao }

constructor TDevAllMigracao.Create(AOwner: TComponent);
begin
  inherited;
  FOrigem := TBancoDeDados.Create(Self);
  FDestino := TBancoDeDados.Create(Self);
  fCampos := TDevAllCamposCollection.Create(Self, TDevAllCampoCollectionItem);

  FOrigem.Name := 'Origem';
  FDestino.Name := 'Destino';
end;

destructor TDevAllMigracao.Destroy;
begin
  FreeAndNil(FOrigem);
  FreeAndNil(FDestino);
  fCampos.Free;
  inherited;
end;

function TDevAllMigracao.IndexOf(ItemName: string): integer;
begin
   result := fCampos.IndexOf(ItemName);
end;

procedure TDevAllMigracao.SetCampos(const Value: TDevAllCamposCollection);
begin
  fCampos.Assign(Value);
end;

function TDevAllMigracao.ValueOf(ItemName: string): String;
begin
   result := Campos.ValueOf(ItemName);
end;

function TDevAllMigracao.ValueOfIndex(aIndex: integer): string;
begin
   result := Campos.ValueOfIndex(aIndex);
end;

{ TBancoDeDados }

constructor TBancoDeDados.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FConexao := TFDConnection.Create(Self);
  FConexao.Name := 'Conexao';
  FSQL := TStringList.Create;
end;

destructor TBancoDeDados.Destroy;
begin
  FreeAndNil(FConexao);
  FreeAndNil(FSQL);
  inherited Destroy;
end;

function TBancoDeDados.GetSQL: TStringList;
begin
  Result := FSQL;
end;

procedure TBancoDeDados.SetSQL(const Value: TStringList);
begin
  FSQL.Assign(Value);
end;

end.
