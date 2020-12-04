unit DevAll.Migracao;

interface

uses
  System.Classes, System.SysUtils, FireDAC.Comp.Client, System.Variants,
  FireDAC.Comp.UI, FireDAC.Phys;

type
  EDevAllMigracaoNameException = Exception;
  TDevAllCamposCollection = class;

  TCampoTipo = (ctNaoDefinido, ctInteger, ctString, ctNumeric, ctDate);
  TCampoBeforeChangeEvent = procedure (const ACampoOrigem, ACampoDestino: string; var AValor: Variant) of object;
  TIncProgressBarEvent = procedure (const APosicao: Integer) of object;
  TMensagemEvent = procedure (const ATabela, AAcao, AMsg, AMsgCompleta: string) of object;
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
    function getValor(ATabela: TFDQuery): Variant;
    class function SoNumero(Str : String): String;
    class function SoNumeroVirgula(Str : String): String;
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

  TBancoDeDados = class(TPersistent)
  private
    Owner: TComponent;
    FConexao: TFDConnection;
    FTabela: string;
    FSQL: TStringList;
    FComandos: TFDQuery;
    FTransacao: TFDTransaction;
    FCaminho: TFileName;
    FDriver: TFDPhysDriverLink;
    function GetSQL: TStringList;
    procedure SetSQL(const Value: TStringList);
    function GetCaminho: TFileName;
    procedure SetCaminho(const Value: TFileName);
    procedure SetDriver(const Value: TFDPhysDriverLink);
    function GetUsuario: string;
    procedure SetUsuario(const Value: string);
    function GetSenha: string;
    procedure SetSenha(const Value: string);
  protected
  public
    constructor Create(AOwner: TComponent); virtual;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    property Conexao: TFDConnection read FConexao;
    property Transacao: TFDTransaction read FTransacao;
    property Comandos: TFDQuery read FComandos;

    procedure IniciarTransacao;
    procedure Descarregar;
    procedure Desfazer;

    procedure AbreComandos(const ASQL: string);
  published
    property Caminho: TFileName read GetCaminho write SetCaminho;
    property Driver: TFDPhysDriverLink read FDriver write SetDriver;
    property Tabela: string read FTabela write FTabela;
    property SQL: TStringList read GetSQL write SetSQL;
    property Usuario: string read GetUsuario write SetUsuario;
    property Senha: string read GetSenha write SetSenha;
  end;

  TBancoDeDadosOrigem = class(TBancoDeDados)
  private
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TBancoDeDadosDestino = class(TBancoDeDados)
  private
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TDevAllMigracao = class(TComponent)
  private
    fCampos : TDevAllCamposCollection;
    FDestino: TBancoDeDadosDestino;
    FOrigem: TBancoDeDadosOrigem;
    FOnMensagem: TMensagemEvent;
    FOnValidarRegistro: TValidarRegistroEvent;
    FOnIncProgressBar: TIncProgressBarEvent;
    FTransacaoAutomatica: Boolean;
    FDGUIxErrorDialog1: TFDGUIxErrorDialog;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    procedure SetCampos(const Value: TDevAllCamposCollection);
  protected
    procedure DoMensagem(const ATabela, AAcao, AMsg: string); virtual;
    procedure MontarComandos; virtual;
    procedure BufferArrayDML(AOrigem, ADestino: TFDQuery); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Assign(Source: TPersistent); override;

    function IndexOf(ItemName:string):integer;
    function ValueOf(ItemName:string):String;
    function ValueOfIndex(aIndex:integer):string;

    procedure IniciarTransacao;
    procedure Descarregar;
    procedure Desfazer;

    function Executar: Boolean;
  published
    property Origem: TBancoDeDadosOrigem read FOrigem write FOrigem;
    property Destino: TBancoDeDadosDestino read FDestino write FDestino;
    property Campos: TDevAllCamposCollection read fCampos write SetCampos;
    property TransacaoAutomatica: Boolean read FTransacaoAutomatica
      write FTransacaoAutomatica default True;

    property OnMensagem: TMensagemEvent read FOnMensagem write FOnMensagem;
    property OnIncProgressBar: TIncProgressBarEvent read FOnIncProgressBar write FOnIncProgressBar;
    property OnValidarRegistro: TValidarRegistroEvent read FOnValidarRegistro write FOnValidarRegistro;
  end;

procedure Register;

implementation

procedure Register;
begin
   RegisterClass(TDevAllCamposCollection);
   RegisterClass(TDevAllCampoCollectionItem);
   RegisterClass(TBancoDeDados);
   RegisterClass(TBancoDeDadosOrigem);
   RegisterClass(TBancoDeDadosDestino);
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

function TDevAllCampoCollectionItem.getValor(ATabela: TFDQuery): Variant;
  function RetornaValor(AValor: Variant): Variant;
  begin
    Result := ValorDefault;

    if Assigned(fsOnBeforeChange) then
      fsOnBeforeChange(fsEquivalente, fsNome, Result);

    if Result <> ValorDefault then
      Exit;

    if VarIsNull(AValor) then
    begin
      if VarIsNull(Result) then
        Result := AValor;
      Exit;
    end;

    try
      case fsTipo of
        ctInteger, ctNumeric:
          begin
            if (AValor = 0) and (IgnorarZero) then
              Result := null
            else
              Result := AValor;
          end;
        ctString:
          begin
            AValor := VarToStr(AValor).Trim();

            if fsStrSoNumero then
              AValor := SoNumero(AValor);

            if Tamanho > 0 then
              Result := VarToStr(AValor).Substring(0, Tamanho)
            else
              Result := AValor;

            if fsStrUpper then
              Result := VarToStr(Result).ToUpper;
          end;
        ctDate: Result := VarToDateTime(AValor);
        else
          Result := AValor;
      end;
    except on e: Exception do
      begin
        raise Exception.Create('Erro ' + fsNome + ' ' + fsEquivalente + ' ' + VarToStrDef(AValor, '')
          + sLineBreak + e.Message);
      end;
    end;
  end;
var
  i: Integer;
  t: TStringList;
  mValor: Variant;
begin
  Result := null;
  if fsEquivalente.Contains(';') then
  begin
    t := TStringList.Create;
    try
      t.Delimiter := ';';
      t.DelimitedText := fsEquivalente;
      for i := 0 to t.Count -1 do
      begin
        mValor := RetornaValor(ATabela.FieldByName(t.Strings[i]).AsVariant);
        if VarIsNull(mValor) then
          Continue;

        if fsTipo in [ctNaoDefinido, ctString] then
        begin
          if VarIsStr(mValor) then
            if VarToStr(mValor) = '' then
              Continue;

          if VarIsNull(Result) then
            Result := t.Strings[i] + ': ' + mValor
          else
            Result := Result + sLineBreak + t.Strings[i] + ': ' + mValor;
        end
        else
        begin
          if VarIsNull(Result) then
            Result := mValor
          else
            Result := Result + mValor;
        end;
      end;
    finally
      FreeAndNil(t);
    end;
  end
  else
  if fsEquivalente <> '' then
    Result := RetornaValor(ATabela.FieldByName(fsEquivalente).AsVariant)
  else
    Result := RetornaValor(null);
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

class function TDevAllCampoCollectionItem.SoNumero(Str: String): String;
var
  i: integer;
  strtemp: string;
  a: char;
begin
  strtemp := '';
  for i := 1 to Length(str) do
  begin
    a := str[i];
    if a in ['0','1','2','3','4','5','6','7','8','9']  then
      strtemp := strtemp + copy(str,i,1);
    Result := strtemp;
  end;
end;

class function TDevAllCampoCollectionItem.SoNumeroVirgula(Str: String): String;
var
  i: integer;
  strtemp: string;
  a: char;
begin
  strtemp := '';
  for i := 1 to Length(str) do
  begin
    a := str[i];
    if  a in ['0'..'9', ',', '.']  then
      strtemp := strtemp + Copy(str,i,1);
    result := strtemp;
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

procedure TDevAllMigracao.Assign(Source: TPersistent);
begin
  if Source is TDevAllMigracao then
    with TDevAllMigracao(Source) do
    begin
      fCampos := Self.fCampos;
      FDestino := Self.FDestino;
      FOrigem := Self.FOrigem;
      FOnMensagem := Self.FOnMensagem;
      FOnValidarRegistro := Self.FOnValidarRegistro;
      FOnIncProgressBar := Self.FOnIncProgressBar;
      FTransacaoAutomatica := Self.FTransacaoAutomatica;
      FDGUIxErrorDialog1 := Self.FDGUIxErrorDialog1;
      FDGUIxWaitCursor1 := Self.FDGUIxWaitCursor1;
    end
  else
    inherited Assign(Source);
end;

procedure TDevAllMigracao.BufferArrayDML(AOrigem, ADestino: TFDQuery);
var
  i,x: Integer;
  mValor: Variant;
  Inicio: TDateTime;
  mPodeMigrar: Boolean;
begin
  i := -1;
  Inicio := Now;
  ADestino.Params.ArraySize := AOrigem.RecordCount;

  AOrigem.First;
  while not AOrigem.Eof do
  begin
    mPodeMigrar := True;

    if Assigned(FOnValidarRegistro) then
      FOnValidarRegistro(AOrigem, mPodeMigrar);

    if mPodeMigrar then
    begin
      Inc(i);
      for x := 0 to Campos.Count -1 do
      begin
        mValor := Campos.Items[x].getValor(AOrigem);

        if not Campos.Items[x].PermiteNulo then
        begin
          if VarIsNull(mValor) then
          begin
            DoMensagem(Destino.Tabela, 'VALIDACAO', 'Row ' + (i +1).ToString + ' | ' + Campos.Items[x].Nome + ' IS NULL');
            Abort;
          end;
        end;

        if not VarIsNull(mValor) then
        begin
          case Campos.Items[x].Tipo of
             ctString: ADestino.Params[x].AsStrings[i]   := mValor;
            ctInteger: ADestino.Params[x].AsIntegers[i]  := mValor;
            ctNumeric: ADestino.Params[x].AsFloats[i]    := mValor;
               ctDate: ADestino.Params[x].AsDateTimes[i] := mValor;
            else
            begin
              if VarIsStr(mValor) then
                ADestino.Params[x].AsStrings[i] := VarToStr(mValor)
              else
                ADestino.Params[x].Values[i] := mValor;
            end;
          end;
        end
        else
          ADestino.Params[x].Clear(i);
      end;
    end;

    if Assigned(FOnIncProgressBar) then
      FOnIncProgressBar(i +1);

    AOrigem.Next;
  end;

  ADestino.Params.ArraySize := i +1;
  ADestino.Execute(ADestino.Params.ArraySize);

  DoMensagem(Destino.Tabela, 'CONCLUIDO', FormatDateTime('hh:nn:ss', Now - Inicio));
  Sleep(500);
end;

constructor TDevAllMigracao.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FOrigem := TBancoDeDadosOrigem.Create(AOwner);
  FDestino := TBancoDeDadosDestino.Create(AOwner);
  fCampos := TDevAllCamposCollection.Create(Self, TDevAllCampoCollectionItem);

  TransacaoAutomatica := True;
//  FOrigem.Name := 'Origem';
//  FDestino.Name := 'Destino';
end;

procedure TDevAllMigracao.Descarregar;
begin
  Destino.Descarregar;
end;

procedure TDevAllMigracao.Desfazer;
begin
  Destino.Desfazer;
end;

destructor TDevAllMigracao.Destroy;
begin
  FreeAndNil(FOrigem);
  FreeAndNil(FDestino);
  fCampos.Free;
  inherited;
end;

procedure TDevAllMigracao.DoMensagem(const ATabela, AAcao, AMsg: string);
var mMsgCompleta: string;
begin
  if Assigned(FOnMensagem) then
  begin
    mMsgCompleta := '[' + FormatDateTime('dd/mm/yy hh:nn:ss', Now) + ']' +
      '[' + ATabela + ']' + '[' + AAcao + '] ' + AMsg;
    FOnMensagem(ATabela, AAcao, AMsg, mMsgCompleta);
  end;
end;

function TDevAllMigracao.Executar: Boolean;
begin
  Result := False;
  DoMensagem(Destino.Tabela, 'EXECUTAR', 'Iniciando');
  DoMensagem(Destino.Conexao.DriverName, 'EXECUTAR', 'Iniciando');

  if not Origem.Conexao.Connected then
    Origem.Conexao.Connected := True;

  if not Destino.Conexao.Connected then
    Destino.Conexao.Connected := True;

  if TransacaoAutomatica then
    Destino.IniciarTransacao;
  try
    MontarComandos;
    BufferArrayDML(Origem.Comandos, Destino.Comandos);

    if TransacaoAutomatica then
      Destino.Descarregar;
  finally
    if TransacaoAutomatica then
      Destino.Desfazer;
  end;
end;

function TDevAllMigracao.IndexOf(ItemName: string): integer;
begin
   result := fCampos.IndexOf(ItemName);
end;

procedure TDevAllMigracao.IniciarTransacao;
begin
  Destino.IniciarTransacao;
end;

procedure TDevAllMigracao.MontarComandos;
var
  i: Integer;
  mCampos: string;
begin
  if Origem.SQL.Text.Trim = '' then
  begin
    for i := 0 to Campos.Count -1 do
    begin
      if mCampos = '' then
        mCampos := Campos.Items[i].Equivalente
      else
        mCampos := mCampos + ',' + Campos.Items[i].Equivalente;
    end;

    Origem.SQL.Text := 'SELECT ' + mCampos + ' FROM ' + Origem.Tabela;
  end;

  Origem.Comandos.Close;
  Origem.Comandos.SQL.Text := Origem.SQL.Text;
  Origem.Comandos.Open();

  if Destino.SQL.Text.Trim = '' then
  begin
    for i := 0 to Campos.Count -1 do
    begin
      if mCampos = '' then
        mCampos := Campos.Items[i].Nome
      else
        mCampos := mCampos + ',' + Campos.Items[i].Nome;
    end;

    Destino.SQL.Text := 'INSERT INTO ' +
      Destino.Tabela + '(' + mCampos + ') VALUES (:' + mCampos.Replace(',',',:') + ')';
  end;

  Destino.Comandos.Close;
  Destino.Comandos.SQL.Text := Destino.SQL.Text;
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

procedure TBancoDeDados.AbreComandos(const ASQL: string);
begin
  FComandos.Close;
  FComandos.SQL.Clear;
  FComandos.SQL.Add(ASQL);
  FComandos.Open;
end;

procedure TBancoDeDados.Assign(Source: TPersistent);
begin
  if Source is TBancoDeDados then
    with TBancoDeDados(Source) do
    begin
      FConexao.Assign(Self.FConexao);
      FTabela := Self.FTabela;
      FSQL.Assign(Self.FSQL);
      FComandos.Assign(Self.FComandos);
      FTransacao.Assign(Self.FTransacao);
    end
  else
    inherited Assign(Source);
end;

constructor TBancoDeDados.Create(AOwner: TComponent);
begin
  inherited Create();
  Owner := AOwner;
  FConexao := TFDConnection.Create(nil);
  FConexao.LoginPrompt := False;
//  FConexao.Name := 'Conexao';

  FTransacao := TFDTransaction.Create(nil);
//  FTransacao.Name := 'Transacao';
  FTransacao.Connection := FConexao;
  FConexao.Transaction := FTransacao;
  FConexao.UpdateTransaction := FTransacao;

  FComandos := TFDQuery.Create(nil);
//  FComandos.Name := 'Comandos';
  FComandos.Connection := FConexao;
  FComandos.Transaction := FTransacao;
  FComandos.UpdateTransaction := FTransacao;

  FSQL := TStringList.Create;
end;

procedure TBancoDeDados.Descarregar;
begin
  if FTransacao.Active then
    FTransacao.Commit;
end;

procedure TBancoDeDados.Desfazer;
begin
  if FTransacao.Active then
    FTransacao.Rollback;
end;

destructor TBancoDeDados.Destroy;
begin
  FreeAndNil(FConexao);
  FreeAndNil(FTransacao);
  FreeAndNil(FComandos);
  FreeAndNil(FSQL);
  inherited Destroy;
end;

function TBancoDeDados.GetCaminho: TFileName;
begin
  Result := FConexao.Params.Database;
end;

function TBancoDeDados.GetSenha: string;
begin
  Result := FConexao.Params.Password;
end;

function TBancoDeDados.GetSQL: TStringList;
begin
  Result := FSQL;
end;

function TBancoDeDados.GetUsuario: string;
begin
  Result := FConexao.Params.UserName;
end;

procedure TBancoDeDados.IniciarTransacao;
begin
  if not FTransacao.Active then
    FTransacao.StartTransaction;
end;

procedure TBancoDeDados.SetCaminho(const Value: TFileName);
begin
  FConexao.Params.Database := Value;
end;

procedure TBancoDeDados.SetDriver(const Value: TFDPhysDriverLink);
begin
  FDriver := Value;
  FConexao.Connected := False;
  FConexao.DriverName := FDriver.BaseDriverID;
  FConexao.Params.DriverID := FDriver.BaseDriverID;
end;

procedure TBancoDeDados.SetSenha(const Value: string);
begin
  FConexao.Params.Password := Value;
end;

procedure TBancoDeDados.SetSQL(const Value: TStringList);
begin
  FSQL.Assign(Value);
end;

procedure TBancoDeDados.SetUsuario(const Value: string);
begin
  FConexao.Params.UserName := Value;
end;

{ TBancoDeDadosOrigem }

constructor TBancoDeDadosOrigem.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
//  Name := 'Origem';
//  Conexao.Name := 'ConexaoOrigem';
//  Transacao.Name := 'TransacaoOrigem';
//  Comandos.Name := 'ComandosOrigem';
end;

{ TBancoDeDadosDestino }

constructor TBancoDeDadosDestino.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
//  Name := 'Destino';
//  Conexao.Name := 'ConexaoDestino';
//  Transacao.Name := 'TransacaoDestino';
//  Comandos.Name := 'ComandosDestino';
end;

end.
