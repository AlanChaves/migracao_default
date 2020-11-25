unit UfrmPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.FB,
  FireDAC.Phys.FBDef, FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf,
  FireDAC.DApt, FireDAC.VCLUI.Error, FireDAC.VCLUI.Wait, Vcl.StdCtrls,
  Vcl.ComCtrls, Vcl.Buttons, FireDAC.Phys.IBBase, FireDAC.Comp.UI, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, Contnrs, Vcl.Imaging.jpeg,
  Datasnap.DBClient;

const
  cCodPessoaPadrao = 5153;

type
  TCampoTipo = (ctNaoDefinido, ctInteger, ctString, ctNumeric, ctDate);
  TCampoBeforeChangeEvent = procedure (const ACampoOrigem, ACampoDestino: string; var AValor: Variant) of object;
  TIncProgressBarEvent = procedure (const APosicao: Integer) of object;
  TMensagemEvent = procedure (const ATabela, AMsg: string) of object;
  TValidarRegistroEvent = procedure (const AOrigem: TFDQuery; var APodeMigrar: Boolean) of object;

  TCampo = class
  private
    fsEscala: Integer;
    fsPrecisao: Integer;
    fsPermiteNulo: Boolean;
    fsNome: string;
    fsTipo: TCampoTipo;
    fsTamanho: Integer;
    fsEquivalente: string;
    fsValorDefault: Variant;
    fsOnBeforeChange: TCampoBeforeChangeEvent;
    fsStrSoNumero: Boolean;
    fsStrUpper: Boolean;
    FIgnorarZero: Boolean;
  public
    constructor Create;
    function getValor(ATabela: TFDQuery): Variant;
    class function SoNumero(Str : String): String;
    class function SoNumeroVirgula(Str : String): String;
  published
    property Nome: string read fsNome write fsNome;
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

  TCampos = class(TObjectList)
  private
    fsOnMensagem: TMensagemEvent;
    fsOnIncProgressBar: TIncProgressBarEvent;
    fsTabela: string;
    fsOnValidarRegistro: TValidarRegistroEvent;
    function GetItems(Index: Integer): TCampo;
    procedure SetItems(Index: Integer; const Value: TCampo);
  public
    property Items[Index: Integer]: TCampo read GetItems write SetItems;
    property Tabela: string read fsTabela write fsTabela;
    function Novo: TCampo;
    function BuscaPorNome(ANome: string): TCampo;
    procedure BufferArrayDML(AOrigem, ADestino: TFDQuery);
  published
    property OnIncProgressBar: TIncProgressBarEvent read fsOnIncProgressBar write fsOnIncProgressBar;
    property OnMensagem: TMensagemEvent read fsOnMensagem write fsOnMensagem;
    property OnValidarRegistro: TValidarRegistroEvent read fsOnValidarRegistro write fsOnValidarRegistro;
  end;

type
  TfrmPrincipal = class(TForm)
    fdOrigem: TFDConnection;
    fdtoLer: TFDTransaction;
    fdqoLer: TFDQuery;
    fdqoLer2: TFDQuery;
    fdDestino: TFDConnection;
    fdtdGravar: TFDTransaction;
    fdqdGravar: TFDQuery;
    fdqdGravar2: TFDQuery;
    FDGUIxErrorDialog1: TFDGUIxErrorDialog;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    BitBtn1: TBitBtn;
    GroupBox1: TGroupBox;
    ProgressBar1: TProgressBar;
    chkClientes: TCheckBox;
    chkProdutos: TCheckBox;
    chkVendas: TCheckBox;
    fdtdLer: TFDTransaction;
    fdqdLer: TFDQuery;
    Memo1: TMemo;
    fdqdLer2: TFDQuery;
    BitBtn2: TBitBtn;
    Edit1: TEdit;
    BitBtn3: TBitBtn;
    chkCompras: TCheckBox;
    chkFinanceiro: TCheckBox;
    fdqdLer3: TFDQuery;
    fdOrigemFoto: TFDConnection;
    fdtdFoto: TFDTransaction;
    fdqdFoto: TFDQuery;
    cdsFoto: TClientDataSet;
    cdsFotoFOTO: TBlobField;
    chkAtendimento: TCheckBox;
    chkVendaExterna: TCheckBox;
    fdqdLer4: TFDQuery;
    Button1: TButton;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    procedure Mensagem(const ATabela, AMsg: string);
    procedure IniciaProgressBar(AMax: Integer);
    procedure IncProgressBar(const APosicao: Integer);

    function MontaTabela(ATabela: string; AQuery: TFDQuery): TCampos;
    procedure AbreOrigem(AQuery: TFDQuery; ASQL: string);

    procedure ZerarClientes;
    procedure VoltarClientes;
    procedure Pessoas;
    procedure Clientes;
    procedure Fornecedores;
    procedure Transportadores;
    procedure Funcionarios;
    procedure Produtos;
    procedure Compras;
    procedure Vendas;
    procedure Financeiro;
    procedure Atendimento;
    procedure VendaExterna;
    procedure ArrumarCEPs;
    procedure ScriptMarcaProduto;
    procedure SetGenerators;
  protected
    ID: Integer;
    mAuxiliar: TStringList;
    procedure ClienteCampoBeforeChange(const ACampoOrigem, ACampoDestino: string;
      var AValor: Variant);
    procedure FornecedorCampoBeforeChange(const ACampoOrigem, ACampoDestino: string;
      var AValor: Variant);
    procedure PessoaFornecedorCampoBeforeChange(const ACampoOrigem, ACampoDestino: string;
      var AValor: Variant);
    procedure TransportadorCampoBeforeChange(const ACampoOrigem, ACampoDestino: string;
      var AValor: Variant);
    procedure PessoaTransportadorCampoBeforeChange(const ACampoOrigem, ACampoDestino: string;
      var AValor: Variant);
    procedure FuncionarioCampoBeforeChange(const ACampoOrigem, ACampoDestino: string;
      var AValor: Variant);
    procedure PessoaFuncionarioCampoBeforeChange(const ACampoOrigem, ACampoDestino: string;
      var AValor: Variant);
    procedure MarcaCampoBeforeChange(const ACampoOrigem, ACampoDestino: string;
      var AValor: Variant);
    procedure ProdutoCampoBeforeChange(const ACampoOrigem, ACampoDestino: string;
      var AValor: Variant);
    procedure CompraBeforeChange(const ACampoOrigem, ACampoDestino: string;
      var AValor: Variant);
    procedure CompraProdutoBeforeChange(const ACampoOrigem, ACampoDestino: string;
      var AValor: Variant);
    procedure CondPagtoBeforeChange(const ACampoOrigem, ACampoDestino: string;
      var AValor: Variant);
    procedure VendaBeforeChange(const ACampoOrigem, ACampoDestino: string;
      var AValor: Variant);
    procedure VendaProdutoBeforeChange(const ACampoOrigem, ACampoDestino: string;
      var AValor: Variant);
    procedure NotaEletronicaBeforeChange(const ACampoOrigem, ACampoDestino: string;
      var AValor: Variant);
    procedure PagarHistoricoBeforeChange(const ACampoOrigem, ACampoDestino: string;
      var AValor: Variant);
    procedure PagarBeforeChange(const ACampoOrigem, ACampoDestino: string;
      var AValor: Variant);
    procedure ReceberBeforeChange(const ACampoOrigem, ACampoDestino: string;
      var AValor: Variant);
    procedure AtendimentoBeforeChange(const ACampoOrigem, ACampoDestino: string;
      var AValor: Variant);
    procedure VendaExternaBeforeChange(const ACampoOrigem, ACampoDestino: string;
      var AValor: Variant);
    procedure VendaExternaProdutoBeforeChange(const ACampoOrigem, ACampoDestino: string;
      var AValor: Variant);

    procedure ClassFiscalValidar(const AOrigem: TFDQuery; var APodeMigrar: Boolean);
    procedure VendaProdutoValidar(const AOrigem: TFDQuery; var APodeMigrar: Boolean);
    procedure PessoaFuncionarioValidar(const AOrigem: TFDQuery; var APodeMigrar: Boolean);
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

{ TForm1 }

procedure TfrmPrincipal.AbreOrigem(AQuery: TFDQuery; ASQL: string);
begin
  AQuery.Close;
  AQuery.SQL.Clear;
  AQuery.SQL.Add(ASQL);
  AQuery.Open;
end;

procedure TfrmPrincipal.ArrumarCEPs;
var t: TStringList;
begin
  AbreOrigem(fdqoLer, 'SELECT * FROM TABCLI');

  t := TStringList.Create;
  try
    fdqoLer.First;
    while not fdqoLer.Eof do
    begin
      t.Add('UPDATE PESSOA SET CEP = '''+TCampo.SoNumero(fdqoLer.FieldByName('cep').AsString)+''' WHERE COD_PESSOA = ' + fdqoLer.FieldByName('CONTROLE').AsString + ';');
      fdqoLer.Next;
    end;
    T.SaveToFile('C:\Temp\CEPs.txt');
  finally
    FreeAndNil(t);
  end;
end;

procedure TfrmPrincipal.Atendimento;
var mAtendimento: TCampos;
begin
  try
    if not fdtdGravar.Active then
      fdtdGravar.StartTransaction;

    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('INSERT INTO CLIENTE');
    fdqdGravar.SQL.Add('(COD_PESSOA)');
    fdqdGravar.SQL.Add('VALUES');
    fdqdGravar.SQL.Add('(' + cCodPessoaPadrao.ToString + ')');
    try
      Mensagem('CLIENTE', cCodPessoaPadrao.ToString);
      fdqdGravar.ExecSQL;
    except on e: Exception do
      begin
        Mensagem('CLIENTE', e.Message);
      end;
    end;

    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('INSERT INTO FUNCIONARIO');
    fdqdGravar.SQL.Add('(COD_PESSOA)');
    fdqdGravar.SQL.Add('VALUES');
    fdqdGravar.SQL.Add('(' + cCodPessoaPadrao.ToString + ')');
    try
      Mensagem('FUNCIONARIO', cCodPessoaPadrao.ToString);
      fdqdGravar.ExecSQL;
    except on e: Exception do
      begin
        Mensagem('FUNCIONARIO', e.Message);
      end;
    end;

    Mensagem('ATENDIMENTO', 'DELETANDO');
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('DELETE FROM ATENDIMENTO');
    fdqdGravar.ExecSQL;

    Mensagem('TIPO_ATENDIMENTO', 'DELETANDO');
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('DELETE FROM TIPO_ATENDIMENTO');
    fdqdGravar.ExecSQL;

    Mensagem('ORIGEM_ATENDIMENTO', 'DELETANDO');
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('DELETE FROM ORIGEM_ATENDIMENTO');
    fdqdGravar.ExecSQL;

    fdtdGravar.Commit;
    if not fdtdGravar.Active then
      fdtdGravar.StartTransaction;

    mAtendimento := MontaTabela('TIPO_ATENDIMENTO', fdqdGravar);
    AbreOrigem(fdqoLer, 'select * from grupoatividade');

    IniciaProgressBar(fdqoLer.RecordCount);
    mAtendimento.OnIncProgressBar := IncProgressBar;
    mAtendimento.OnMensagem := Mensagem;

    mAtendimento.BuscaPorNome('COD_TIPO_ATENDIMENTO').Equivalente := 'CODIGO';
    mAtendimento.BuscaPorNome('DESCRICAO').Equivalente := 'DESCRICAO';

    mAtendimento.BufferArrayDML(fdqoLer, fdqdGravar);

    mAtendimento := MontaTabela('ORIGEM_ATENDIMENTO', fdqdGravar);
    AbreOrigem(fdqoLer, 'select * from tipoatividade');

    IniciaProgressBar(fdqoLer.RecordCount);
    mAtendimento.OnIncProgressBar := IncProgressBar;
    mAtendimento.OnMensagem := Mensagem;

    mAtendimento.BuscaPorNome('COD_ORIGEM_ATENDIMENTO').Equivalente := 'CODIGO';
    mAtendimento.BuscaPorNome('DESCRICAO').Equivalente := 'DESCRICAO';

    mAtendimento.BufferArrayDML(fdqoLer, fdqdGravar);

    mAtendimento := MontaTabela('ATENDIMENTO', fdqdGravar);
    AbreOrigem(fdqoLer, 'select A.*,cast(A.observacao as varchar(20480)) obs,C.CODIGO CLIENTE'+
                        ' from controleatividade A'+
                        ' LEFT OUTER JOIN CLIFOR C ON C.OCS_ID = A.OCS_ID');
    AbreOrigem(fdqdLer, 'select p.cod_pessoa,p.fantasia from pessoa p inner join funcionario f on f.cod_pessoa = p.cod_pessoa');

    IniciaProgressBar(fdqoLer.RecordCount);
    mAtendimento.OnIncProgressBar := IncProgressBar;
    mAtendimento.OnMensagem := Mensagem;

    mAtendimento.BuscaPorNome('COD_ATENDIMENTO').Equivalente := 'CODIGO';
    mAtendimento.BuscaPorNome('COD_EMPRESA').ValorDefault := 1;
//    mAtendimento.BuscaPorNome('ST_STATUS').Equivalente := 'SITUACAO';
//    mAtendimento.BuscaPorNome('ST_STATUS').ValorDefault := 'E';
    mAtendimento.BuscaPorNome('ST_STATUS').OnBeforeChange := AtendimentoBeforeChange;
    mAtendimento.BuscaPorNome('COD_TIPO_ATENDIMENTO').Equivalente := 'GRUPOATIVIDADE';
    mAtendimento.BuscaPorNome('COD_ORIGEM_ATENDIMENTO').Equivalente := 'TIPOATIVIDADE';
    mAtendimento.BuscaPorNome('COD_FUNCIONARIO').Equivalente := '';
    mAtendimento.BuscaPorNome('COD_FUNCIONARIO').OnBeforeChange := AtendimentoBeforeChange;
    mAtendimento.BuscaPorNome('COD_FUNCIONARIO').ValorDefault := cCodPessoaPadrao;
    mAtendimento.BuscaPorNome('COD_CLIENTE').Equivalente := 'CLIENTE';
    mAtendimento.BuscaPorNome('COD_CLIENTE').ValorDefault := cCodPessoaPadrao;
    mAtendimento.BuscaPorNome('MOTIVO_CONTATO').Equivalente := 'ASSUNTO';
    mAtendimento.BuscaPorNome('RESOLUCAO').Equivalente := 'OBS';
    mAtendimento.BuscaPorNome('DT_AGENDAMENTO').Equivalente := 'DATA';
    mAtendimento.BuscaPorNome('DH_INICIO').Equivalente := 'DATAINCLUSAO';
    mAtendimento.BuscaPorNome('DH_FINALIZACAO').Equivalente := '';
    mAtendimento.BuscaPorNome('DH_FINALIZACAO').OnBeforeChange := AtendimentoBeforeChange;
    mAtendimento.BuscaPorNome('DH_INCLUSAO').Equivalente := 'DATAINCLUSAO';
    mAtendimento.BuscaPorNome('COD_PROXIMO_ATENDIMENTO').Equivalente := '';

    mAtendimento.BufferArrayDML(fdqoLer, fdqdGravar);
    fdtdGravar.Commit;
  finally
    if fdtdGravar.Active then
      fdtdGravar.Rollback;
  end;
end;

procedure TfrmPrincipal.AtendimentoBeforeChange(const ACampoOrigem,
  ACampoDestino: string; var AValor: Variant);
begin
  if ACampoDestino.ToUpper = 'ST_STATUS' then
  begin
    AValor := 'A';
    if fdqoLer.FieldByName('situacao').AsString = 'FINALIZADA' then
      AValor := 'F';
  end
  else
  if ACampoDestino.ToUpper = 'DH_FINALIZACAO' then
  begin
    if fdqoLer.FieldByName('situacao').AsString = 'FINALIZADA' then
    begin
      if fdqoLer.FieldByName('dataalteracao').IsNull then
        AValor := Now
      else
        AValor := fdqoLer.FieldByName('dataalteracao').AsDateTime;
    end;
  end
  else
  if ACampoDestino.ToUpper = 'COD_FUNCIONARIO' then
  begin
    if fdqdLer.Locate('fantasia', fdqoLer.FieldByName('usuario').AsString) then
      AValor := fdqdLer.FieldByName('cod_pessoa').AsInteger;
  end;
end;

procedure TfrmPrincipal.BitBtn1Click(Sender: TObject);
begin
  fdOrigem.Connected := False;
  fdOrigem.Connected := True;

  fdDestino.Connected := False;
  fdDestino.Connected := True;

  try
    if chkClientes.Checked then
      Pessoas;

    if chkProdutos.Checked then
      Produtos;

    if chkCompras.Checked then
      Compras;

    if chkVendas.Checked then
      Vendas;

    if chkFinanceiro.Checked then
      Financeiro;

    if chkAtendimento.Checked then
      Atendimento;

    if chkVendaExterna.Checked then
      VendaExterna;

    //ArrumarCEPs;
    //ScriptMarcaProduto;
    //SetGenerators;
  finally
    fdOrigem.Connected := False;
    fdDestino.Connected := False;
  end;
end;

procedure TfrmPrincipal.BitBtn2Click(Sender: TObject);
begin
  Memo1.Lines.Clear;
  AbreOrigem(fdqoLer, 'select distinct RDB$RELATION_NAME tabela from rdb$relation_fields');
  fdqoLer.First;
  while not fdqoLer.Eof do
  begin
    AbreOrigem(fdqoLer2, 'select count(1) from ' + fdqoLer.FieldByName('tabela').AsString);
    if fdqoLer2.Fields[0].AsInteger > 100 then
      Memo1.Lines.Add(FormatFloat('000000000', fdqoLer2.Fields[0].AsInteger) + ' ' + fdqoLer.FieldByName('tabela').AsString);
    fdqoLer.Next;
  end;
  ShowMessage(Memo1.Lines.Count.ToString);
end;

procedure TfrmPrincipal.BitBtn3Click(Sender: TObject);
begin
   Memo1.Lines.Clear;
  AbreOrigem(fdqoLer, 'select distinct RDB$RELATION_NAME tabela from rdb$relation_fields');
  fdqoLer.First;
  while not fdqoLer.Eof do
  begin
    AbreOrigem(fdqoLer2, 'select RDB$FIELD_NAME from rdb$relation_fields '+#13+
                         ' where RDB$RELATION_NAME = '''+ fdqoLer.FieldByName('tabela').AsString +''''+#13+
                         '   AND RDB$FIELD_NAME LIKE ''%'+ UpperCase(Edit1.Text) +'%''');
    if not fdqoLer2.IsEmpty then
      Memo1.Lines.Add(fdqoLer.FieldByName('tabela').AsString);
    fdqoLer.Next;
  end;
  ShowMessage(Memo1.Lines.Count.ToString);
end;

procedure TfrmPrincipal.Button1Click(Sender: TObject);
var t: TStringList;
begin
  t := TStringList.Create;
  try
    AbreOrigem(fdqoLer, 'SELECT CODIGO,VENDEDOR FROM CLIFOR WHERE VENDEDOR IS NOT NULL');
    AbreOrigem(fdqdLer, 'SELECT P.COD_PESSOA,P.COD_TRANSFERENCIA FROM PESSOA P INNER JOIN FUNCIONARIO F ON F.COD_PESSOA = P.COD_PESSOA WHERE P.COD_TRANSFERENCIA IS NOT NULL');

    fdqoLer.First;
    while not fdqoLer.Eof do
    begin
      if fdqdLer.Locate('cod_transferencia', fdqoLer.FieldByName('vendedor').AsInteger) then
        t.Add('UPDATE CLIENTE SET COD_FUNCIONARIO_CADASTRO = ' + fdqdLer.FieldByName('cod_pessoa').AsString +
              ' WHERE COD_PESSOA = ' + fdqoLer.FieldByName('codigo').AsString + ';');
      fdqoLer.Next;
    end;

    t.SaveToFile('ClienteVendedor.txt');
  finally
    FreeAndNil(t);
  end;
end;

procedure TfrmPrincipal.ClassFiscalValidar(const AOrigem: TFDQuery;
  var APodeMigrar: Boolean);
begin
  if AOrigem.FieldByName('classfiscal').AsString = '' then
    APodeMigrar := False
  else
    APodeMigrar := not fdqdLer.Locate('NCM', AOrigem.FieldByName('classfiscal').AsString);
end;

procedure TfrmPrincipal.ClienteCampoBeforeChange(const ACampoOrigem,
  ACampoDestino: string; var AValor: Variant);
begin
  if ACampoDestino.ToUpper = 'CPF_CNPJ' then
  begin
    if fdqoLer.FieldByName('CNPJ').AsString <> '' then
      AValor := TCampo.SoNumero(fdqoLer.FieldByName('CNPJ').AsString)
    else
      AValor := TCampo.SoNumero(fdqoLer.FieldByName('CPF').AsString);

    if VarToStr(AValor) = '' then
      AValor := '11111111111';
  end
  else
  if ACampoDestino.ToUpper = 'COD_CIDADE' then
  begin
    if fdqdLer.Locate('COD_IBGE', fdqoLer.FieldByName('CODIGOIBGE').AsString) then
      AValor := fdqdLer.FieldByName('cod_cidade').AsInteger
    else
    if fdqdLer.Locate('NOME;COD_ESTADO', VarArrayOf([
         fdqoLer.FieldByName('CIDADEFAT').AsString,
         fdqoLer.FieldByName('UFFAT').AsString])) then
      AValor := fdqdLer.FieldByName('cod_cidade').AsInteger
    else
    if fdqdLer.Locate('NOME', fdqoLer.FieldByName('CIDADEFAT').AsString) then
      AValor := fdqdLer.FieldByName('cod_cidade').AsInteger;
  end
//  else
//  if ACampoDestino.ToUpper = 'TIPO_PESSOA' then
//  begin
//    if TCampo.SoNumero(fdqoLer.FieldByName('cgc').AsString).Length = 14 then
//      AValor := 'J'
//    else
//      AValor := 'F';
//  end
  else
  if ACampoDestino.ToUpper = 'COD_MOTIVO_BLOQUEIO' then
  begin
    if fdqoLer.FieldByName('MOTIVOBLOQ').AsString.Trim <> '' then
      AValor := 1;
  end
  else
  if ACampoDestino.ToUpper = 'ATIVO_INATIVO' then
  begin
    if fdqoLer.FieldByName('INATIVO').AsString = 'T' then
      AValor := 'I';
  end;
end;

procedure TfrmPrincipal.Clientes;
var mPessoas, mClientes: TCampos;
begin
  try
    if not fdtdGravar.Active then
      fdtdGravar.StartTransaction;

    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('INSERT INTO MOTIVO_BLOQUEIO');
    fdqdGravar.SQL.Add('(COD_MOTIVO_BLOQUEIO,DESCRICAO,COD_USUARIO_INCLUSAO,DH_INCLUSAO)');
    fdqdGravar.SQL.Add('VALUES');
    fdqdGravar.SQL.Add('(1,''BLOQUEIO DA MIGRACAO'',0,CURRENT_TIMESTAMP)');
    try
      Mensagem('MOTIVO_BLOQUEIO', '1');
      fdqdGravar.ExecSQL;
    except on e: Exception do
      begin
        Mensagem('MOTIVO_BLOQUEIO', e.Message);
      end;
    end;

    mPessoas := MontaTabela('PESSOA', fdqdGravar);
    AbreOrigem(fdqoLer, 'SELECT CLIFOR.*,CAST(OBSERVACAO AS VARCHAR(2024)) OBS FROM CLIFOR');
    AbreOrigem(fdqdLer, 'SELECT COD_CIDADE,NOME,COD_ESTADO,COD_IBGE FROM CIDADE');

    IniciaProgressBar(fdqoLer.RecordCount);
    mPessoas.OnIncProgressBar := IncProgressBar;
    mPessoas.OnMensagem := Mensagem;

    mPessoas.BuscaPorNome('COD_PESSOA').Equivalente := 'CODIGO';
    mPessoas.BuscaPorNome('CPF_CNPJ').OnBeforeChange := ClienteCampoBeforeChange;
    mPessoas.BuscaPorNome('CPF_CNPJ').StrSoNumero := True;
    mPessoas.BuscaPorNome('CPF_CNPJ').Tamanho := 14;
    mPessoas.BuscaPorNome('CPF_CNPJ').ValorDefault := '11111111111';
    mPessoas.BuscaPorNome('RG_INSC').Equivalente := 'RGIE';
    mPessoas.BuscaPorNome('NOME').Equivalente := 'RAZSOCIAL';
    mPessoas.BuscaPorNome('FANTASIA').Equivalente := 'FANTASIA';
    mPessoas.BuscaPorNome('ENDERECO').Equivalente := 'ENDFAT';
    mPessoas.BuscaPorNome('NUMERO').Equivalente := 'NRENDFAT';
    mPessoas.BuscaPorNome('BAIRRO').Equivalente := 'BAIRROFAT';
    mPessoas.BuscaPorNome('DT_CADASTRO').Equivalente := 'DTCAD';
    mPessoas.BuscaPorNome('DT_CADASTRO').ValorDefault := Now;
    mPessoas.BuscaPorNome('COD_CIDADE').Equivalente := '';
    mPessoas.BuscaPorNome('COD_CIDADE').ValorDefault := 1;
    mPessoas.BuscaPorNome('COD_CIDADE').OnBeforeChange := ClienteCampoBeforeChange;
    mPessoas.BuscaPorNome('CEP').Equivalente := 'CEPFAT';
    mPessoas.BuscaPorNome('CEP').StrSoNumero := True;
    mPessoas.BuscaPorNome('SITE').Equivalente := 'HOMEPAGE';
    mPessoas.BuscaPorNome('ATIVO_INATIVO').Equivalente := '';
    mPessoas.BuscaPorNome('ATIVO_INATIVO').ValorDefault := 'A';
    mPessoas.BuscaPorNome('ATIVO_INATIVO').OnBeforeChange := ClienteCampoBeforeChange;
    mPessoas.BuscaPorNome('EMAIL').Equivalente := 'EMAIL';
    mPessoas.BuscaPorNome('EMAIL').StrUpper := False;
    mPessoas.BuscaPorNome('TIPO_PESSOA').Equivalente := 'PESSOAFJ';
//    mPessoas.BuscaPorNome('TIPO_PESSOA').OnBeforeChange := ClienteCampoBeforeChange;
    mPessoas.BuscaPorNome('DT_NASC').Equivalente := 'DTNASCTO';
    mPessoas.BuscaPorNome('FONE').Equivalente := 'TELFAT';
    mPessoas.BuscaPorNome('CELULAR').Equivalente := 'CELFAT';
    mPessoas.BuscaPorNome('FAX').Equivalente := 'FAXFAT';
    mPessoas.BuscaPorNome('OBS').Equivalente := 'OBS';
    mPessoas.BuscaPorNome('CELULAR2').Equivalente := 'TELCOMPLEMENTAR';
    mPessoas.BuscaPorNome('COMPLEMENTO').Equivalente := 'COMPLFAT';
    mPessoas.BuscaPorNome('SEXO').Equivalente := '';
    mPessoas.BuscaPorNome('REFERENCIA').Equivalente := '';
    mPessoas.BuscaPorNome('DH_INCLUSAO').Equivalente := '';
    mPessoas.BuscaPorNome('DH_INCLUSAO').ValorDefault := Now;
    mPessoas.BuscaPorNome('COD_USUARIO_INCLUSAO').Equivalente := '';
    mPessoas.BuscaPorNome('COD_USUARIO_INCLUSAO').ValorDefault := 0;

    mPessoas.BufferArrayDML(fdqoLer, fdqdGravar);

    mClientes := MontaTabela('CLIENTE', fdqdGravar);
    //AbreOrigem(fdqoLer, 'SELECT * FROM TABCLI');

    IniciaProgressBar(fdqoLer.RecordCount);
    mClientes.OnIncProgressBar := IncProgressBar;
    mClientes.OnMensagem := Mensagem;

    mClientes.BuscaPorNome('COD_PESSOA').Equivalente := 'CODIGO';
    mClientes.BuscaPorNome('CONTATO').Equivalente := '';
    mClientes.BuscaPorNome('LIMITE').Equivalente := '';
    mClientes.BuscaPorNome('COD_MOTIVO_BLOQUEIO').OnBeforeChange := ClienteCampoBeforeChange;
    mClientes.BuscaPorNome('EMAIL_FATURAMENTO').Equivalente := 'EMAILDISTRIBUICAO';
    mClientes.BuscaPorNome('EMAIL_FINANCEIRO').Equivalente := 'EMAIL';
    mClientes.BuscaPorNome('SUFRAMA').Equivalente := 'SUFRAMA';

    mClientes.BufferArrayDML(fdqoLer, fdqdGravar);

    fdtdGravar.Commit;
  finally
    if fdtdGravar.Active then
      fdtdGravar.Rollback;
  end;

  VoltarClientes;
end;

procedure TfrmPrincipal.CompraBeforeChange(const ACampoOrigem, ACampoDestino: string;
  var AValor: Variant);
begin
  if ((ACampoDestino.ToUpper = 'COD_COMPRA') or (ACampoDestino.ToUpper = 'COD_COMPRA_PRODUTO')) then
  begin
    Inc(ID);
    AValor := ID;
  end
  else
  if (ACampoDestino.ToUpper = 'COD_FORNECEDOR') then
  begin
    if fdqdLer.Locate('COD_TRANSFERENCIA', fdqoLer.FieldByName('FORNECEDOR').AsInteger) then
      AValor := fdqdLer.FieldByName('cod_pessoa').AsInteger
    else
      AValor := cCodPessoaPadrao;
  end
  else
  if (ACampoDestino.ToUpper = 'COD_TRANSPORTADOR') then
  begin
    if fdqdLer3.Locate('COD_MIGRACAO', fdqoLer.FieldByName('TRANSPORTADORA').AsInteger) then
      AValor := fdqdLer3.FieldByName('COD_PESSOA').AsInteger;
  end;
end;

procedure TfrmPrincipal.CompraProdutoBeforeChange(const ACampoOrigem,
  ACampoDestino: string; var AValor: Variant);
begin
  if (ACampoDestino.ToUpper = 'COD_COMPRA_PRODUTO') then
  begin
    Inc(ID);
    AValor := ID;
  end
  else
  if (ACampoDestino.ToUpper = 'COD_COMPRA') then
  begin
    if fdqdLer.Locate('DOCUMENTO;SERIE', VarArrayOf([fdqoLer2.FieldByName('NUMERONF').AsInteger,fdqoLer2.FieldByName('SERIE').AsString])) then
      AValor := fdqdLer.FieldByName('COD_COMPRA').AsInteger;
  end;
end;

procedure TfrmPrincipal.Compras;
var mTabela, mTabela2: TCampos;
begin
  if not fdtdGravar.Active then
    fdtdGravar.StartTransaction;

  try
    Mensagem('COMPRA_PRODUTO', 'DELETANDO');
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('DELETE FROM COMPRA_PRODUTO');
    fdqdGravar.ExecSQL;

    Mensagem('COMPRA', 'DELETANDO');
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('DELETE FROM COMPRA');
    fdqdGravar.ExecSQL;

    mTabela := MontaTabela('COMPRA', fdqdGravar);
    AbreOrigem(fdqoLer, 'SELECT CNFE.*,CAST(OBSERVACAO AS VARCHAR(2024)) OBS,N.NATUREZA FROM CNFE LEFT OUTER JOIN NATOPERACAO N ON N.CODIGO = CNFE.CFOP');
    AbreOrigem(fdqdLer, 'SELECT COD_PESSOA,COD_TRANSFERENCIA FROM PESSOA');

    ID := 0;
    IniciaProgressBar(fdqoLer.RecordCount);
    mTabela.OnIncProgressBar := IncProgressBar;
    mTabela.OnMensagem := Mensagem;

    mTabela.BuscaPorNome('COD_COMPRA').Equivalente := '';
    mTabela.BuscaPorNome('COD_COMPRA').OnBeforeChange := CompraBeforeChange;
    mTabela.BuscaPorNome('COD_EMPRESA').Equivalente := 'EMPRESA';
    mTabela.BuscaPorNome('COD_EMPRESA').ValorDefault := 1;
    //mTabela.BuscaPorNome('TIPO_DOCUMENTO').Equivalente := 'TIPOCOMPRA';
    mTabela.BuscaPorNome('TIPO_DOCUMENTO').ValorDefault := 'N';
    mTabela.BuscaPorNome('DOCUMENTO').Equivalente := 'NRNOTA';
    mTabela.BuscaPorNome('SERIE').Equivalente := 'SERIE';
    mTabela.BuscaPorNome('COD_FORNECEDOR').Equivalente := 'FORNECEDOR';
    mTabela.BuscaPorNome('COD_FORNECEDOR').OnBeforeChange := CompraBeforeChange;
    mTabela.BuscaPorNome('COD_FUNCIONARIO').Equivalente := '';
    mTabela.BuscaPorNome('COD_FUNCIONARIO').ValorDefault := cCodPessoaPadrao;
    mTabela.BuscaPorNome('COD_CFOP').Equivalente := 'NATUREZA';
    mTabela.BuscaPorNome('COD_CFOP').ValorDefault := '1102';
    mTabela.BuscaPorNome('COD_CFOP').StrSoNumero := True;
    mTabela.BuscaPorNome('COD_REGRA').Equivalente := '';
    mTabela.BuscaPorNome('COD_REGRA').ValorDefault := 4;
    mTabela.BuscaPorNome('COD_CONDICAO_PAGTO').Equivalente := '';
    mTabela.BuscaPorNome('COD_CONDICAO_PAGTO').ValorDefault := 'AV';
    mTabela.BuscaPorNome('DT_EMISSAO').Equivalente := 'DTEMISSAO';
    mTabela.BuscaPorNome('DT_ENTRADA').Equivalente := 'DTENTRADA';
    mTabela.BuscaPorNome('VL_ICMS_BASE').Equivalente := 'VRBICMS';
    mTabela.BuscaPorNome('VL_ICMS').Equivalente := 'VRICMS';
    mTabela.BuscaPorNome('VL_ICMS_BASE_SUBST').Equivalente := 'VRBICMSS';
    mTabela.BuscaPorNome('VL_ICMS_SUBST').Equivalente := 'VRICMSS';
    mTabela.BuscaPorNome('VL_PRODUTO').Equivalente := 'VRPRODUTOS';
    mTabela.BuscaPorNome('VL_FRETE').Equivalente := 'VRFRETE';
    mTabela.BuscaPorNome('VL_SEGURO').Equivalente := 'VRSEGURO';
    mTabela.BuscaPorNome('VL_OUTRAS').Equivalente := 'VROUTRASDESP';
    mTabela.BuscaPorNome('VL_IPI').Equivalente := 'VRIPI';
    mTabela.BuscaPorNome('VL_DESC_ACRES').Equivalente := '';
    mTabela.BuscaPorNome('VL_TOTAL').Equivalente := 'VRTOTAL';
    mTabela.BuscaPorNome('OBS').Equivalente := 'OBS';
    mTabela.BuscaPorNome('SN_TRANSFERENCIA').Equivalente := '';
    mTabela.BuscaPorNome('ARQUIVO_XML').Equivalente := 'ARQUIVO';
    mTabela.BuscaPorNome('CHAVE_NFE').Equivalente := 'CHAVENFE';
    mTabela.BuscaPorNome('COD_CONTA').Equivalente := '';
    mTabela.BuscaPorNome('COD_CONTA').ValorDefault := 1;
    mTabela.BuscaPorNome('EXTRAS').Equivalente := '';
    mTabela.BuscaPorNome('VL_DESCONTO').Equivalente := 'VRDESCONTO';
    mTabela.BuscaPorNome('VL_PRODUTOS').Equivalente := 'VRPRODUTOS';
    mTabela.BuscaPorNome('MOD_FRETE').Equivalente := 'FRETECONTA';
    mTabela.BuscaPorNome('COD_TRANSPORTADOR').Equivalente := '';
    mTabela.BuscaPorNome('DT_VENCIMENTO_FRETE').Equivalente := '';
    mTabela.BuscaPorNome('DH_INCLUSAO').Equivalente := '';
    mTabela.BuscaPorNome('DH_INCLUSAO').ValorDefault := Now;

    mTabela.BufferArrayDML(fdqoLer, fdqdGravar);
    fdtdGravar.Commit;

    if not fdtdGravar.Active then
      fdtdGravar.StartTransaction;

    mTabela2 := MontaTabela('COMPRA_PRODUTO', fdqdGravar);
    AbreOrigem(fdqoLer2, 'SELECT * FROM INFE I LEFT OUTER JOIN NATOPERACAO N ON N.CODIGO = I.NATOPERACAO');
    AbreOrigem(fdqdLer, 'SELECT COD_COMPRA,DOCUMENTO,SERIE FROM COMPRA');

    ID := 0;
    IniciaProgressBar(fdqoLer2.RecordCount);
    mTabela2.OnIncProgressBar := IncProgressBar;
    mTabela2.OnMensagem := Mensagem;

    mTabela2.BuscaPorNome('COD_COMPRA_PRODUTO').Equivalente := '';
    mTabela2.BuscaPorNome('COD_COMPRA_PRODUTO').OnBeforeChange := CompraProdutoBeforeChange;
    mTabela2.BuscaPorNome('COD_COMPRA').Equivalente := '';
    mTabela2.BuscaPorNome('COD_COMPRA').OnBeforeChange := CompraProdutoBeforeChange;
    mTabela2.BuscaPorNome('COD_PRODUTO').Equivalente := 'CODPROD';
    mTabela2.BuscaPorNome('QTDE').Equivalente := 'QTDE';
    mTabela2.BuscaPorNome('SITUACAO_TRIB').Equivalente := 'ST';
    mTabela2.BuscaPorNome('CSOSN').Equivalente := '';
    mTabela2.BuscaPorNome('COD_CFOP').Equivalente := 'NATUREZA';
    mTabela2.BuscaPorNome('COD_CFOP').StrSoNumero := True;
    mTabela2.BuscaPorNome('CST_IPI').Equivalente := 'IPI_CST';
    mTabela2.BuscaPorNome('CST_COFINS').Equivalente := 'COFINS_CST';
    mTabela2.BuscaPorNome('VL_CUSTO').Equivalente := 'CUSTOCHEIO';
    mTabela2.BuscaPorNome('VL_PIS').Equivalente := 'VRPIS';
    mTabela2.BuscaPorNome('VL_PIS_BASE').Equivalente := 'VRBASEPISCOFINS';
    mTabela2.BuscaPorNome('VL_COFINS').Equivalente := 'VRCOFINS';
    mTabela2.BuscaPorNome('VL_COFINS_BASE').Equivalente := 'VRBASEPISCOFINS';
    mTabela2.BuscaPorNome('VL_ICMS_REDUCAO').Equivalente := 'REDUCAO';
    mTabela2.BuscaPorNome('VL_ICMS_REDUCAO_SUBST').Equivalente := 'PERCREDICMSSTCOMPRA';
    mTabela2.BuscaPorNome('VL_ICMS').Equivalente := 'ICMS';
    mTabela2.BuscaPorNome('VL_ICMS_BASE').Equivalente := 'BASECALCULO';
    mTabela2.BuscaPorNome('VL_ICMS_SUBST').Equivalente := 'VRICMSS';
    mTabela2.BuscaPorNome('VL_ICMS_BASE_SUBST').Equivalente := '';
    mTabela2.BuscaPorNome('VL_ICMS_ISENTO').Equivalente := '';
    mTabela2.BuscaPorNome('VL_ICMS_OUTRAS').Equivalente := '';
    mTabela2.BuscaPorNome('VL_IPI').Equivalente := 'VRIPI';
    mTabela2.BuscaPorNome('VL_IPI_BASE').Equivalente := 'BASEIPI';
    mTabela2.BuscaPorNome('VL_FRETE').Equivalente := 'VRFRETE';
    mTabela2.BuscaPorNome('VL_SEGURO').Equivalente := 'VRSEGURO';
    mTabela2.BuscaPorNome('VL_OUTRAS').Equivalente := 'VROUTRASDESP';
    mTabela2.BuscaPorNome('PE_PIS').Equivalente := '';
    mTabela2.BuscaPorNome('PE_ICMS').Equivalente := 'ALIQICMS';
    mTabela2.BuscaPorNome('PE_IPI').Equivalente := 'ALIQIPI';
    mTabela2.BuscaPorNome('PE_IVA').Equivalente := 'IVA';
    mTabela2.BuscaPorNome('PE_COFINS').Equivalente := '';
    mTabela2.BuscaPorNome('PE_ICMS_SUBS').Equivalente := 'ALIQSUBST';
    mTabela2.BuscaPorNome('SN_ATUALIZA_CUSTO').Equivalente := '';
    mTabela2.BuscaPorNome('SN_ATUALIZA_CUSTO').ValorDefault := 'S';
    mTabela2.BuscaPorNome('COD_UNIDADE_ENTRADA').Equivalente := '';
    mTabela2.BuscaPorNome('FATOR_ENTRADA').Equivalente := '';
    mTabela2.BuscaPorNome('VL_UNITARIO').Equivalente := 'VRUNITARIO';
    mTabela2.BuscaPorNome('NCM').Equivalente := 'NCM';
    mTabela2.BuscaPorNome('VL_DESCONTO').Equivalente := 'DESCONTO';
    mTabela2.BuscaPorNome('VOLUME').Equivalente := '';
    mTabela2.BuscaPorNome('OBS').Equivalente := '';

    mTabela2.BufferArrayDML(fdqoLer2, fdqdGravar);
    fdtdGravar.Commit;

    Mensagem('COMPRA_PRODUTO', 'NCM');
    fdtdGravar.StartTransaction;
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('MERGE');
    fdqdGravar.SQL.Add('INTO COMPRA_PRODUTO C');
    fdqdGravar.SQL.Add('USING (SELECT P.COD_PRODUTO,F.NCM');
    fdqdGravar.SQL.Add('         FROM PRODUTO P');
    fdqdGravar.SQL.Add('        INNER JOIN CLASS_FISCAL F');
    fdqdGravar.SQL.Add('           ON F.COD_CLASS_FISCAL = P.COD_CLASS_FISCAL) P');
    fdqdGravar.SQL.Add('ON (C.COD_PRODUTO = P.COD_PRODUTO) AND ((C.NCM IS NULL) OR (C.NCM = ''''))');
    fdqdGravar.SQL.Add('WHEN MATCHED THEN');
    fdqdGravar.SQL.Add('UPDATE SET');
    fdqdGravar.SQL.Add('NCM = P.NCM');
    fdqdGravar.ExecSQL;
    fdtdGravar.Commit;
  finally
    if fdtdGravar.Active then
      fdtdGravar.Rollback;
  end;
end;

procedure TfrmPrincipal.CondPagtoBeforeChange(const ACampoOrigem,
  ACampoDestino: string; var AValor: Variant);
var
  mAux: string;
  t: TStringList;
begin
  if ACampoDestino.ToUpper = 'DIAS_PARCELA' then
  begin
    mAux := fdqoLer.FieldByName('DSCONDPAGTO').AsString;
    mAux := mAux.Replace('À VISTA', '0');
    if mAux.Contains('/') then
    begin
      t := TStringList.Create;
      try
        t.Delimiter := '/';
        t.DelimitedText := mAux;
        AValor := Abs(StrToIntDef(t.Strings[1], 0) - StrToIntDef(t.Strings[0], 0));
      finally
        FreeAndNil(t);
      end;
    end
    else
      AValor := StrToIntDef(mAux, 0);
  end
  else
  if ACampoDestino.ToUpper = 'DIA_PARCELA1' then
  begin
    mAux := fdqoLer.FieldByName('DSCONDPAGTO').AsString;
    mAux := mAux.Replace('À VISTA', '0');
    if mAux.StartsWith('0/') then
      AValor := '0'
    else
    begin
      if mAux.Contains('/') then
      begin
        t := TStringList.Create;
        try
          t.Delimiter := '/';
          t.DelimitedText := mAux;
          AValor := Abs(StrToIntDef(t.Strings[1], 0) - StrToIntDef(t.Strings[0], 0));
        finally
          FreeAndNil(t);
        end;
      end
      else
        AValor := StrToIntDef(mAux, 0);
    end;
  end
  else
  if ACampoDestino.ToUpper = 'SN_BAIXA_PRIMEIRA' then
  begin
    mAux := fdqoLer.FieldByName('DSCONDPAGTO').AsString;
    mAux := mAux.Replace('À VISTA', '0');
    if mAux.StartsWith('0') then
      AValor := 'S'
    else
      AValor := 'N'
  end
  else
  if ACampoDestino.ToUpper = 'PRAZO_VISTA' then
  begin
    if fdqoLer.FieldByName('QTPARCELAS').AsInteger > 1 then
      AValor := 'P'
    else
      AValor := 'V';
  end;
end;

procedure TfrmPrincipal.Financeiro;
var mTabela, mTabela2: TCampos;
begin
  if not fdtdGravar.Active then
    fdtdGravar.StartTransaction;

  try
    Mensagem('CONTAS_PAGAR', 'DELETANDO');
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('DELETE FROM CONTAS_PAGAR');
    fdqdGravar.ExecSQL;

    Mensagem('CONTAS_RECEBER', 'DELETANDO');
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('DELETE FROM CONTAS_RECEBER');
    fdqdGravar.ExecSQL;

    Mensagem('HISTORICO', 'COD_TRANSFERENCIA');
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('ALTER TABLE HISTORICO ADD COD_TRANSFERENCIA INTEGER');
    try
      fdqdGravar.ExecSQL;
    except
    end;

    fdtdGravar.Commit;
    if not fdtdGravar.Active then
      fdtdGravar.StartTransaction;

    Mensagem('HISTORICO', 'DELETANDO');
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('DELETE FROM HISTORICO WHERE COD_TRANSFERENCIA IS NOT NULL');
    fdqdGravar.ExecSQL;

    fdtdGravar.Commit;
    if not fdtdGravar.Active then
      fdtdGravar.StartTransaction;

    mTabela := MontaTabela('HISTORICO', fdqdGravar);
    AbreOrigem(fdqoLer, 'select * from ccusto');

    ID := 0;
    IniciaProgressBar(fdqoLer.RecordCount);
    mTabela.OnIncProgressBar := IncProgressBar;
    mTabela.OnMensagem := Mensagem;

    mTabela.BuscaPorNome('COD_HISTORICO').Equivalente := '';
    mTabela.BuscaPorNome('COD_HISTORICO').OnBeforeChange := PagarHistoricoBeforeChange;
    mTabela.BuscaPorNome('DESCRICAO').Equivalente := 'DESCRCCUSTO';
    mTabela.BuscaPorNome('DEBITO_CREDITO').ValorDefault := 'D';
    mTabela.BuscaPorNome('ATIVO_INATIVO').ValorDefault := 'A';
    mTabela.BuscaPorNome('TIPO').ValorDefault := 'C';
    mTabela.BuscaPorNome('COD_HISTORICO_GRUPO').ValorDefault := '020100000';
    mTabela.BuscaPorNome('TP_DESPESA').ValorDefault := 'V';
    mTabela.BuscaPorNome('COD_TRANSFERENCIA').Equivalente := 'CCUSTO';

    mTabela.BufferArrayDML(fdqoLer, fdqdGravar);

    fdtdGravar.Commit;
    if not fdtdGravar.Active then
      fdtdGravar.StartTransaction;

    mTabela := MontaTabela('CONTAS_PAGAR', fdqdGravar);
    AbreOrigem(fdqoLer,
      'select serie,nrdocumento,fornecedor,parcela,dtemissao,dtvencto,valor, '+#13+
      '       sum(vrpago) vrpago, max(dtpagto) dtpagto, count(1) parcelas, codigoccusto'+#13+
      '  from icp '+#13+
      ' group by serie,nrdocumento,fornecedor,parcela,dtemissao,dtvencto,valor,codigoccusto');
    AbreOrigem(fdqdLer, 'SELECT P.COD_PESSOA,P.COD_TRANSFERENCIA '+#13+
                        '  FROM PESSOA P '+#13+
                        ' INNER JOIN FORNECEDOR F '+#13+
                        '    ON F.COD_PESSOA = P.COD_PESSOA');
    AbreOrigem(fdqdLer2, 'SELECT COD_COMPRA,DOCUMENTO,SERIE,COD_FORNECEDOR FROM COMPRA');
    AbreOrigem(fdqdLer3, 'SELECT COD_HISTORICO,COD_TRANSFERENCIA FROM HISTORICO');

    ID := 0;
    IniciaProgressBar(fdqoLer.RecordCount);
    mTabela.OnIncProgressBar := IncProgressBar;
    mTabela.OnMensagem := Mensagem;

    mTabela.BuscaPorNome('COD_CONTAS_PAGAR').Equivalente := '';
    mTabela.BuscaPorNome('COD_CONTAS_PAGAR').OnBeforeChange := PagarBeforeChange;
    mTabela.BuscaPorNome('COD_EMPRESA').Equivalente := '';
    mTabela.BuscaPorNome('COD_EMPRESA').ValorDefault := 1;
    mTabela.BuscaPorNome('COD_EMPRESA_PAGAMENTO').Equivalente := '';
    mTabela.BuscaPorNome('COD_EMPRESA_PAGAMENTO').ValorDefault := 1;
    mTabela.BuscaPorNome('DOCUMENTO').Equivalente := 'nrdocumento';
    mTabela.BuscaPorNome('TIPO_DOCUMENTO').Equivalente := '';
    mTabela.BuscaPorNome('TIPO_DOCUMENTO').ValorDefault := 'N';
    mTabela.BuscaPorNome('COD_FORNECEDOR').Equivalente := 'FORNECEDOR';
    mTabela.BuscaPorNome('COD_FORNECEDOR').OnBeforeChange := PagarBeforeChange;
    mTabela.BuscaPorNome('DT_EMISSAO').Equivalente := 'DTEMISSAO';
    mTabela.BuscaPorNome('DT_VENCIMENTO').Equivalente := 'dtvencto';
    mTabela.BuscaPorNome('DT_PAGAMENTO').Equivalente := 'dtpagto';
    mTabela.BuscaPorNome('VALOR').Equivalente := 'valor';
    mTabela.BuscaPorNome('VL_PAGO').Equivalente := 'vrpago';
    mTabela.BuscaPorNome('PARCELA').Equivalente := 'parcela';
    mTabela.BuscaPorNome('PARCELA').OnBeforeChange := PagarBeforeChange;
    mTabela.BuscaPorNome('COD_CONTA').Equivalente := '';
    mTabela.BuscaPorNome('COD_CONTA').OnBeforeChange := PagarBeforeChange;
    mTabela.BuscaPorNome('COD_HISTORICO').Equivalente := '';
    mTabela.BuscaPorNome('COD_HISTORICO').OnBeforeChange := PagarBeforeChange;
    mTabela.BuscaPorNome('OBS').Equivalente := '';
    mTabela.BuscaPorNome('COD_COMPRA').Equivalente := '';
    mTabela.BuscaPorNome('COD_COMPRA').OnBeforeChange := PagarBeforeChange;
    mTabela.BuscaPorNome('COD_CARTEIRA').Equivalente := '';
    mTabela.BuscaPorNome('COD_CARTEIRA').OnBeforeChange := PagarBeforeChange;
    mTabela.BuscaPorNome('COD_VENDA').Equivalente := '';
    mTabela.BuscaPorNome('COD_LOTE').Equivalente := '';
    mTabela.BuscaPorNome('COD_PRODUTO').Equivalente := '';
    mTabela.BuscaPorNome('VL_CHEQUE').Equivalente := '';
    mTabela.BuscaPorNome('DT_ESTORNO').Equivalente := '';
    mTabela.BuscaPorNome('VL_DESCONTO').Equivalente := '';
    mTabela.BuscaPorNome('VL_JUROS').Equivalente := '';

    mTabela.BufferArrayDML(fdqoLer, fdqdGravar);

    mTabela := MontaTabela('CONTAS_RECEBER', fdqdGravar);
    AbreOrigem(fdqoLer,
      'select serie,nrdocumento,cliente,parcela,dtemissao,dtvencto,valor, '+#13+
      '       sum(vrpago) vrpago, max(dtpagto) dtpagto, count(1) parcelas, EMPRESA '+#13+
      '  from icr '+#13+
      ' group by serie,nrdocumento,cliente,parcela,dtemissao,dtvencto,valor,EMPRESA');
    AbreOrigem(fdqdLer, 'SELECT P.COD_PESSOA '+#13+
                        '  FROM PESSOA P '+#13+
                        ' INNER JOIN CLIENTE C '+#13+
                        '    ON C.COD_PESSOA = P.COD_PESSOA');
    AbreOrigem(fdqdLer2, 'SELECT COD_VENDA,DOCUMENTO,SERIE,COD_CLIENTE FROM VENDA');

    ID := 0;
    IniciaProgressBar(fdqoLer.RecordCount);
    mTabela.OnIncProgressBar := IncProgressBar;
    mTabela.OnMensagem := Mensagem;

    mTabela.BuscaPorNome('COD_CONTAS_RECEBER').Equivalente := '';
    mTabela.BuscaPorNome('COD_CONTAS_RECEBER').OnBeforeChange := ReceberBeforeChange;
    mTabela.BuscaPorNome('COD_EMPRESA').Equivalente := 'EMPRESA';
    mTabela.BuscaPorNome('COD_EMPRESA').ValorDefault := 1;
    mTabela.BuscaPorNome('COD_EMPRESA_RECEBIMENTO').Equivalente := 'EMPRESA';
    mTabela.BuscaPorNome('COD_EMPRESA_RECEBIMENTO').ValorDefault := 1;
    mTabela.BuscaPorNome('DOCUMENTO').Equivalente := 'nrdocumento';
    mTabela.BuscaPorNome('TIPO_DOCUMENTO').Equivalente := '';
    mTabela.BuscaPorNome('TIPO_DOCUMENTO').ValorDefault := 'N';
    mTabela.BuscaPorNome('COD_CLIENTE').Equivalente := 'CLIENTE';
    mTabela.BuscaPorNome('COD_CLIENTE').OnBeforeChange := ReceberBeforeChange;
    mTabela.BuscaPorNome('DT_EMISSAO').Equivalente := 'DTEMISSAO';
    mTabela.BuscaPorNome('DT_VENCIMENTO').Equivalente := 'dtvencto';
    mTabela.BuscaPorNome('DT_PAGAMENTO').Equivalente := 'dtpagto';
    mTabela.BuscaPorNome('VALOR').Equivalente := 'valor';
    mTabela.BuscaPorNome('VL_PAGO').Equivalente := 'vrpago';
    mTabela.BuscaPorNome('PARCELA').Equivalente := 'parcela';
    mTabela.BuscaPorNome('PARCELA').OnBeforeChange := ReceberBeforeChange;
    mTabela.BuscaPorNome('COD_CONTA').Equivalente := '';
    mTabela.BuscaPorNome('COD_CONTA').OnBeforeChange := ReceberBeforeChange;
    mTabela.BuscaPorNome('COD_HISTORICO').Equivalente := '';
    mTabela.BuscaPorNome('COD_HISTORICO').OnBeforeChange := ReceberBeforeChange;
//    mTabela.BuscaPorNome('OBS').Equivalente := '';
//    mTabela.BuscaPorNome('COD_COMPRA').Equivalente := '';
    mTabela.BuscaPorNome('COD_VENDA').OnBeforeChange := ReceberBeforeChange;
    mTabela.BuscaPorNome('COD_CARTEIRA').Equivalente := '';
    mTabela.BuscaPorNome('COD_CARTEIRA').OnBeforeChange := ReceberBeforeChange;
//    mTabela.BuscaPorNome('COD_VENDA').Equivalente := '';
//    mTabela.BuscaPorNome('COD_LOTE').Equivalente := '';
//    mTabela.BuscaPorNome('COD_PRODUTO').Equivalente := '';
//    mTabela.BuscaPorNome('VL_CHEQUE').Equivalente := '';
//    mTabela.BuscaPorNome('DT_ESTORNO').Equivalente := '';
//    mTabela.BuscaPorNome('VL_DESCONTO').Equivalente := '';
//    mTabela.BuscaPorNome('VL_JUROS').Equivalente := '';
    mTabela.BuscaPorNome('SN_FATURADO').ValorDefault := 'N';

    mTabela.BufferArrayDML(fdqoLer, fdqdGravar);
    fdtdGravar.Commit;
  finally
    if fdtdGravar.Active then
      fdtdGravar.Rollback;
  end;
end;

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  mAuxiliar := TStringList.Create;
  Memo1.Lines.Clear;
end;

procedure TfrmPrincipal.FormDestroy(Sender: TObject);
begin
  FreeAndNil(mAuxiliar);
end;

procedure TfrmPrincipal.FornecedorCampoBeforeChange(const ACampoOrigem,
  ACampoDestino: string; var AValor: Variant);
begin
  if ACampoDestino.ToUpper = 'COD_PESSOA' then
  begin
    Inc(ID);
    AValor := ID;
  end
  else
  if ACampoDestino.ToUpper = 'CPF_CNPJ' then
  begin
    if fdqoLer.FieldByName('CNPJ').AsString <> '' then
      AValor := TCampo.SoNumero(fdqoLer.FieldByName('CNPJ').AsString)
    else
      AValor := TCampo.SoNumero(fdqoLer.FieldByName('CPF').AsString);

    if VarToStr(AValor) = '' then
      AValor := '11111111111';
  end
  else
  if ACampoDestino.ToUpper = 'COD_CIDADE' then
  begin
    if fdqdLer.Locate('COD_IBGE', fdqoLer.FieldByName('CODIGOIBGE').AsString) then
      AValor := fdqdLer.FieldByName('cod_cidade').AsInteger
    else
    if fdqdLer.Locate('NOME;COD_ESTADO', VarArrayOf([
         fdqoLer.FieldByName('CIDADEFAT').AsString,
         fdqoLer.FieldByName('UFFAT').AsString])) then
      AValor := fdqdLer.FieldByName('cod_cidade').AsInteger
    else
    if fdqdLer.Locate('NOME', fdqoLer.FieldByName('CIDADEFAT').AsString) then
      AValor := fdqdLer.FieldByName('cod_cidade').AsInteger;
  end
  else
  if ACampoDestino.ToUpper = 'EMAIL' then
  begin
    if fdqoLer.FieldByName('email').IsNull then
      AValor := fdqoLer.FieldByName('emailnfe').AsString;
  end
  else
  if ACampoDestino.ToUpper = 'COD_MOTIVO_BLOQUEIO' then
  begin
    if fdqoLer.FieldByName('MOTIVOBLOQ').AsString.Trim <> '' then
      AValor := 1;
  end
  else
  if ACampoDestino.ToUpper = 'ATIVO_INATIVO' then
  begin
    if fdqoLer.FieldByName('INATIVO').AsString = 'T' then
      AValor := 'I';
  end;
end;

procedure TfrmPrincipal.Fornecedores;
var
  mPessoas, mFornecedor: TCampos;
  mMax: Integer;
begin
  try
    if not fdtdGravar.Active then
      fdtdGravar.StartTransaction;

    Mensagem('PESSOA', 'COD_TRANSFERENCIA');
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('ALTER TABLE PESSOA ADD COD_TRANSFERENCIA INTEGER');
    try
      fdqdGravar.ExecSQL;
    except
      Mensagem('PESSOA', 'JÁ CRIADO');
    end;

    fdtdGravar.Commit;
    if not fdtdGravar.Active then
      fdtdGravar.StartTransaction;

    AbreOrigem(fdqdLer, 'SELECT MAX(COD_PESSOA) FROM PESSOA');
    mMax := fdqdLer.Fields[0].AsInteger;
    ID := mMax;

    mPessoas := MontaTabela('PESSOA', fdqdGravar);
    AbreOrigem(fdqoLer, 'SELECT FORNEC.*,CAST(OBSERVACAO AS VARCHAR(2024)) OBS FROM FORNEC');
    AbreOrigem(fdqdLer, 'SELECT COD_CIDADE,NOME,COD_ESTADO,COD_IBGE FROM CIDADE');

    IniciaProgressBar(fdqoLer.RecordCount);
    mPessoas.OnIncProgressBar := IncProgressBar;
    mPessoas.OnMensagem := Mensagem;

    mPessoas.BuscaPorNome('COD_PESSOA').Equivalente := 'CODIGO';
    mPessoas.BuscaPorNome('COD_PESSOA').OnBeforeChange := FornecedorCampoBeforeChange;
    mPessoas.BuscaPorNome('COD_TRANSFERENCIA').Equivalente := 'CODIGO';
    mPessoas.BuscaPorNome('CPF_CNPJ').OnBeforeChange := FornecedorCampoBeforeChange;
    mPessoas.BuscaPorNome('CPF_CNPJ').StrSoNumero := True;
    mPessoas.BuscaPorNome('CPF_CNPJ').Tamanho := 14;
    mPessoas.BuscaPorNome('CPF_CNPJ').ValorDefault := '11111111111';
    mPessoas.BuscaPorNome('RG_INSC').Equivalente := 'RGIE';
    mPessoas.BuscaPorNome('NOME').Equivalente := 'RAZSOCIAL';
    mPessoas.BuscaPorNome('FANTASIA').Equivalente := 'FANTASIA';
    mPessoas.BuscaPorNome('ENDERECO').Equivalente := 'ENDFAT';
    mPessoas.BuscaPorNome('NUMERO').Equivalente := 'NRENDFAT';
    mPessoas.BuscaPorNome('BAIRRO').Equivalente := 'BAIRROFAT';
    mPessoas.BuscaPorNome('DT_CADASTRO').Equivalente := 'DTCAD';
    mPessoas.BuscaPorNome('DT_CADASTRO').ValorDefault := Now;
    mPessoas.BuscaPorNome('COD_CIDADE').Equivalente := '';
    mPessoas.BuscaPorNome('COD_CIDADE').ValorDefault := 1;
    mPessoas.BuscaPorNome('COD_CIDADE').OnBeforeChange := FornecedorCampoBeforeChange;
    mPessoas.BuscaPorNome('CEP').Equivalente := 'CEPFAT';
    mPessoas.BuscaPorNome('CEP').StrSoNumero := True;
    mPessoas.BuscaPorNome('SITE').Equivalente := 'HOMEPAGE';
    mPessoas.BuscaPorNome('ATIVO_INATIVO').Equivalente := '';
    mPessoas.BuscaPorNome('ATIVO_INATIVO').ValorDefault := 'A';
    mPessoas.BuscaPorNome('ATIVO_INATIVO').OnBeforeChange := FornecedorCampoBeforeChange;
    mPessoas.BuscaPorNome('EMAIL').Equivalente := 'EMAIL';
    mPessoas.BuscaPorNome('EMAIL').StrUpper := False;
    mPessoas.BuscaPorNome('EMAIL').OnBeforeChange := FornecedorCampoBeforeChange;
    mPessoas.BuscaPorNome('TIPO_PESSOA').Equivalente := 'PESSOAFJ';
//    mPessoas.BuscaPorNome('TIPO_PESSOA').OnBeforeChange := ClienteCampoBeforeChange;
    mPessoas.BuscaPorNome('DT_NASC').Equivalente := 'DTNASCTO';
    mPessoas.BuscaPorNome('FONE').Equivalente := 'TELFAT';
    mPessoas.BuscaPorNome('CELULAR').Equivalente := 'CELFAT';
    mPessoas.BuscaPorNome('FAX').Equivalente := 'FAXFAT';
    mPessoas.BuscaPorNome('OBS').Equivalente := 'OBS';
//    mPessoas.BuscaPorNome('CELULAR2').Equivalente := 'TELCOMPLEMENTAR';
    mPessoas.BuscaPorNome('COMPLEMENTO').Equivalente := 'COMPLFAT';
    mPessoas.BuscaPorNome('SEXO').Equivalente := '';
    mPessoas.BuscaPorNome('REFERENCIA').Equivalente := '';
    mPessoas.BuscaPorNome('DH_INCLUSAO').Equivalente := '';
    mPessoas.BuscaPorNome('DH_INCLUSAO').ValorDefault := Now;
    mPessoas.BuscaPorNome('COD_USUARIO_INCLUSAO').Equivalente := '';
    mPessoas.BuscaPorNome('COD_USUARIO_INCLUSAO').ValorDefault := 0;

    mPessoas.BufferArrayDML(fdqoLer, fdqdGravar);

    fdtdGravar.Commit;
    if not fdtdGravar.Active then
      fdtdGravar.StartTransaction;

    ID := mMax;
    mFornecedor := MontaTabela('FORNECEDOR', fdqdGravar);
    AbreOrigem(fdqdLer, 'SELECT COD_PESSOA,COD_TRANSFERENCIA FROM PESSOA');

    IniciaProgressBar(fdqoLer.RecordCount);
    mFornecedor.OnIncProgressBar := IncProgressBar;
    mFornecedor.OnMensagem := Mensagem;

    mFornecedor.BuscaPorNome('COD_PESSOA').Equivalente := 'CODIGO';
    mFornecedor.BuscaPorNome('COD_PESSOA').OnBeforeChange := PessoaFornecedorCampoBeforeChange;
    mFornecedor.BuscaPorNome('CONTATO').Equivalente := 'CONTATO';
    mFornecedor.BuscaPorNome('SN_TRANSPORTADOR').ValorDefault := 'N';

    mFornecedor.BufferArrayDML(fdqoLer, fdqdGravar);

    fdtdGravar.Commit;
  finally
    if fdtdGravar.Active then
      fdtdGravar.Rollback;
  end;
end;

procedure TfrmPrincipal.PessoaFornecedorCampoBeforeChange(const ACampoOrigem,
  ACampoDestino: string; var AValor: Variant);
begin
  if UpperCase(ACampoDestino) = 'COD_PESSOA' then
  begin
    if fdqdLer.Locate('COD_TRANSFERENCIA', fdqoLer.FieldByName('codigo').AsInteger) then
      AValor := fdqdLer.FieldByName('COD_PESSOA').AsInteger;
  end;
end;

procedure TfrmPrincipal.FuncionarioCampoBeforeChange(const ACampoOrigem,
  ACampoDestino: string; var AValor: Variant);
begin
  if ACampoDestino.ToUpper = 'COD_PESSOA' then
  begin
    Inc(ID);
    AValor := ID;
  end
  else
  if ACampoDestino.ToUpper = 'COD_CIDADE' then
  begin
//    if fdqdLer.Locate('COD_IBGE', fdqoLer.FieldByName('CODIGOIBGE').AsString) then
//      AValor := fdqdLer.FieldByName('cod_cidade').AsInteger
//    else
    if fdqdLer.Locate('NOME;COD_ESTADO', VarArrayOf([
         fdqoLer.FieldByName('cidade').AsString,
         fdqoLer.FieldByName('UF').AsString])) then
      AValor := fdqdLer.FieldByName('cod_cidade').AsInteger
    else
    if fdqdLer.Locate('NOME', fdqoLer.FieldByName('cidade').AsString) then
      AValor := fdqdLer.FieldByName('cod_cidade').AsInteger;
  end
  else
  if ACampoDestino.ToUpper = 'TIPO_PESSOA' then
  begin
    if TCampo.SoNumero(fdqoLer.FieldByName('cpf').AsString).Length = 14 then
      AValor := 'J'
    else
      AValor := 'F';
  end;
end;

procedure TfrmPrincipal.Funcionarios;
var
  mPessoas, mFornecedor: TCampos;
  mMax: Integer;
begin
  try
    mAuxiliar.Clear;
    if not fdtdGravar.Active then
      fdtdGravar.StartTransaction;

    AbreOrigem(fdqdLer, 'SELECT MAX(COD_PESSOA) FROM PESSOA');
    mMax := fdqdLer.Fields[0].AsInteger;
    ID := mMax;

    mPessoas := MontaTabela('PESSOA', fdqdGravar);
    AbreOrigem(fdqoLer, 'SELECT FUNCIONARIO.*,CAST(OBSERVACAO AS VARCHAR(2024)) OBS FROM FUNCIONARIO');
    AbreOrigem(fdqdLer, 'SELECT COD_CIDADE,NOME,COD_ESTADO,COD_IBGE FROM CIDADE');

    IniciaProgressBar(fdqoLer.RecordCount);
    mPessoas.OnIncProgressBar := IncProgressBar;
    mPessoas.OnMensagem := Mensagem;

    mPessoas.BuscaPorNome('COD_PESSOA').Equivalente := '';
    mPessoas.BuscaPorNome('COD_PESSOA').OnBeforeChange := FuncionarioCampoBeforeChange;
    mPessoas.BuscaPorNome('COD_TRANSFERENCIA').Equivalente := 'FUNCIONARIO';
    mPessoas.BuscaPorNome('CPF_CNPJ').OnBeforeChange := FuncionarioCampoBeforeChange;
    mPessoas.BuscaPorNome('CPF_CNPJ').StrSoNumero := True;
    mPessoas.BuscaPorNome('CPF_CNPJ').Tamanho := 14;
    mPessoas.BuscaPorNome('CPF_CNPJ').ValorDefault := '11111111111';
    mPessoas.BuscaPorNome('RG_INSC').Equivalente := 'RG';
    mPessoas.BuscaPorNome('NOME').Equivalente := 'NOME';
    mPessoas.BuscaPorNome('FANTASIA').Equivalente := 'FANTASIA';
    mPessoas.BuscaPorNome('ENDERECO').Equivalente := 'ENDERECO';
//    mPessoas.BuscaPorNome('NUMERO').Equivalente := 'NRENDFAT';
    mPessoas.BuscaPorNome('BAIRRO').Equivalente := 'BAIRRO';
//    mPessoas.BuscaPorNome('DT_CADASTRO').Equivalente := 'DTCAD';
    mPessoas.BuscaPorNome('DT_CADASTRO').ValorDefault := Now;
    mPessoas.BuscaPorNome('COD_CIDADE').Equivalente := '';
    mPessoas.BuscaPorNome('COD_CIDADE').ValorDefault := 1;
    mPessoas.BuscaPorNome('COD_CIDADE').OnBeforeChange := FuncionarioCampoBeforeChange;
    mPessoas.BuscaPorNome('CEP').Equivalente := 'CEP';
//    mPessoas.BuscaPorNome('SITE').Equivalente := 'HOMEPAGE';
    mPessoas.BuscaPorNome('ATIVO_INATIVO').Equivalente := '';
    mPessoas.BuscaPorNome('ATIVO_INATIVO').ValorDefault := 'A';
    mPessoas.BuscaPorNome('ATIVO_INATIVO').OnBeforeChange := FuncionarioCampoBeforeChange;
    mPessoas.BuscaPorNome('EMAIL').Equivalente := 'EMAIL';
    mPessoas.BuscaPorNome('EMAIL').StrUpper := False;
    mPessoas.BuscaPorNome('TIPO_PESSOA').Equivalente := 'PESSOAFJ';
//    mPessoas.BuscaPorNome('TIPO_PESSOA').OnBeforeChange := ClienteCampoBeforeChange;
    mPessoas.BuscaPorNome('DT_NASC').Equivalente := 'DTNASCTO';
    mPessoas.BuscaPorNome('FONE').Equivalente := 'FONE_1';
    mPessoas.BuscaPorNome('CELULAR').Equivalente := 'CELULAR';
    mPessoas.BuscaPorNome('FAX').Equivalente := 'FAX';
    mPessoas.BuscaPorNome('OBS').Equivalente := 'OBS';
    mPessoas.BuscaPorNome('CELULAR2').Equivalente := 'FONE_2';
//    mPessoas.BuscaPorNome('COMPLEMENTO').Equivalente := 'COMPL';
    mPessoas.BuscaPorNome('SEXO').Equivalente := '';
    mPessoas.BuscaPorNome('REFERENCIA').Equivalente := '';
    mPessoas.BuscaPorNome('DH_INCLUSAO').Equivalente := '';
    mPessoas.BuscaPorNome('DH_INCLUSAO').ValorDefault := Now;
    mPessoas.BuscaPorNome('COD_USUARIO_INCLUSAO').Equivalente := '';
    mPessoas.BuscaPorNome('COD_USUARIO_INCLUSAO').ValorDefault := 0;

    mPessoas.BufferArrayDML(fdqoLer, fdqdGravar);

    fdtdGravar.Commit;
    if not fdtdGravar.Active then
      fdtdGravar.StartTransaction;

    ID := mMax;
    mFornecedor := MontaTabela('FUNCIONARIO', fdqdGravar);
    AbreOrigem(fdqdLer, 'SELECT P.COD_PESSOA,P.COD_TRANSFERENCIA '+#13+
                        '  FROM PESSOA P '+#13+
                        ' WHERE NOT EXISTS (SELECT F.COD_PESSOA FROM FORNECEDOR F WHERE F.COD_PESSOA = P.COD_PESSOA)');

    IniciaProgressBar(fdqoLer.RecordCount);
    mFornecedor.OnIncProgressBar := IncProgressBar;
    mFornecedor.OnMensagem := Mensagem;
    mFornecedor.OnValidarRegistro := PessoaFuncionarioValidar;

    mFornecedor.BuscaPorNome('COD_PESSOA').Equivalente := '';
    mFornecedor.BuscaPorNome('COD_PESSOA').OnBeforeChange := PessoaFuncionarioCampoBeforeChange;
    mFornecedor.BuscaPorNome('ATIVO_INATIVO').ValorDefault := 'A';
//    mFornecedor.BuscaPorNome('CONTATO').Equivalente := 'CONTATO';

    mFornecedor.BufferArrayDML(fdqoLer, fdqdGravar);

    fdtdGravar.Commit;
  finally
    if fdtdGravar.Active then
      fdtdGravar.Rollback;
  end;
end;

procedure TfrmPrincipal.IncProgressBar(const APosicao: Integer);
begin
  ProgressBar1.Position := APosicao;

  if (ProgressBar1.Position mod 500) = 0 then
    Application.ProcessMessages;
end;

procedure TfrmPrincipal.IniciaProgressBar(AMax: Integer);
begin
  ProgressBar1.Position := 0;
  ProgressBar1.Max := AMax;
end;

procedure TfrmPrincipal.MarcaCampoBeforeChange(const ACampoOrigem,
  ACampoDestino: string; var AValor: Variant);
begin
  if (ACampoDestino.ToUpper = 'COD_MARCA') or (ACampoDestino.ToUpper = 'COD_CLASS_FISCAL') then
  begin
    Inc(ID);
    AValor := ID;
  end;
end;

procedure TfrmPrincipal.Mensagem(const ATabela, AMsg: string);
begin
  Memo1.Lines.Add(FormatDateTime('dd/mm/yy hh:nn:ss', Now) + ' | ' + ATabela + ' | ' + AMsg);
end;

function TfrmPrincipal.MontaTabela(ATabela: string; AQuery: TFDQuery): TCampos;
var
  sql, mCampos: string;
  i: Integer;
begin
  Result := TCampos.Create;
  Result.Tabela := ATabela;

  Mensagem(ATabela, 'MontandoTabela');
  sql := 'SELECT '+#13+
         '  RF.RDB$FIELD_NAME FIELD_NAME, '+#13+
         '  F.RDB$FIELD_TYPE FIELD_TYPE_ID, '+#13+
         '  CASE F.RDB$FIELD_TYPE '+#13+
         '    WHEN 7 THEN '+#13+
         '      CASE F.RDB$FIELD_SUB_TYPE '+#13+
         '        WHEN 0 THEN ''SMALLINT'' '+#13+
         '        WHEN 1 THEN ''NUMERIC('' || F.RDB$FIELD_PRECISION || '', '' || (-F.RDB$FIELD_SCALE) || '')'' '+#13+
         '        WHEN 2 THEN ''DECIMAL'' '+#13+
         '      END '+#13+
         '    WHEN 8 THEN '+#13+
         '      CASE F.RDB$FIELD_SUB_TYPE '+#13+
         '        WHEN 0 THEN ''INTEGER'' '+#13+
         '        WHEN 1 THEN ''NUMERIC(''  || F.RDB$FIELD_PRECISION || '', '' || (-F.RDB$FIELD_SCALE) || '')'' '+#13+
         '        WHEN 2 THEN ''DECIMAL'' '+#13+
         '      END '+#13+
         '    WHEN 9 THEN ''QUAD'' '+#13+
         '    WHEN 10 THEN ''FLOAT'' '+#13+
         '    WHEN 12 THEN ''DATE'' '+#13+
         '    WHEN 13 THEN ''TIME'' '+#13+
         '    WHEN 14 THEN ''CHAR('' || (TRUNC(F.RDB$FIELD_LENGTH / CH.RDB$BYTES_PER_CHARACTER)) || '')'' '+#13+
         '    WHEN 16 THEN '+#13+
         '      CASE F.RDB$FIELD_SUB_TYPE '+#13+
         '        WHEN 0 THEN ''BIGINT'' '+#13+
         '        WHEN 1 THEN ''NUMERIC('' || F.RDB$FIELD_PRECISION || '', '' || (-F.RDB$FIELD_SCALE) || '')'' '+#13+
         '        WHEN 2 THEN ''DECIMAL'' '+#13+
         '      END '+#13+
         '    WHEN 27 THEN ''DOUBLE'' '+#13+
         '    WHEN 35 THEN ''TIMESTAMP'' '+#13+
         '    WHEN 37 THEN ''VARCHAR('' || (TRUNC(F.RDB$FIELD_LENGTH / CH.RDB$BYTES_PER_CHARACTER)) || '')'' '+#13+
         '    WHEN 40 THEN ''CSTRING'' || (TRUNC(F.RDB$FIELD_LENGTH / CH.RDB$BYTES_PER_CHARACTER)) || '')'' '+#13+
         '    WHEN 45 THEN ''BLOB_ID'' '+#13+
         '    WHEN 261 THEN ''BLOB SUB_TYPE '' || F.RDB$FIELD_SUB_TYPE '+#13+
         '    ELSE ''RDB$FIELD_TYPE: '' || F.RDB$FIELD_TYPE || ''?'' '+#13+
         '  END FIELD_TYPE, '+#13+
         '  F.RDB$FIELD_SUB_TYPE FIELD_SUB_TYPE, '+#13+
         '  F.RDB$FIELD_PRECISION FIELD_PRECISION, '+#13+
         '  -F.RDB$FIELD_SCALE FIELD_SCALE, '+#13+
         '  TRUNC(F.RDB$FIELD_LENGTH / CH.RDB$BYTES_PER_CHARACTER) FIELD_LENGTH, '+#13+
         '  IIF(COALESCE(RF.RDB$NULL_FLAG, 0) = 0, NULL, ''NOT NULL'') FIELD_NULL, '+#13+
         '  CH.RDB$CHARACTER_SET_NAME FIELD_CHARSET, '+#13+
         '  DCO.RDB$COLLATION_NAME FIELD_COLLATION, '+#13+
         '  COALESCE(RF.RDB$DEFAULT_SOURCE, F.RDB$DEFAULT_SOURCE) FIELD_DEFAULT, '+#13+
         '  F.RDB$VALIDATION_SOURCE FIELD_CHECK, '+#13+
         '  RF.RDB$DESCRIPTION FIELD_DESCRIPTION '+#13+
         'FROM RDB$RELATION_FIELDS RF '+#13+
         'LEFT OUTER JOIN RDB$FIELDS F ON (F.RDB$FIELD_NAME = RF.RDB$FIELD_SOURCE) '+#13+
         'LEFT OUTER JOIN RDB$CHARACTER_SETS CH ON (CH.RDB$CHARACTER_SET_ID = F.RDB$CHARACTER_SET_ID) '+#13+
         'LEFT OUTER JOIN RDB$COLLATIONS DCO ON ((DCO.RDB$COLLATION_ID = F.RDB$COLLATION_ID) AND (DCO.RDB$CHARACTER_SET_ID = F.RDB$CHARACTER_SET_ID)) '+#13+
         'WHERE (RF.RDB$RELATION_NAME = ''' + ATabela + ''') AND (COALESCE(RF.RDB$SYSTEM_FLAG, 0) = 0) '+#13+
         'AND RDB$COMPUTED_SOURCE IS NULL '+#13+
         'ORDER BY RF.RDB$FIELD_POSITION';

  fdqdLer.Close;
  fdqdLer.SQL.Clear;
  fdqdLer.SQL.Add(sql);
  fdqdLer.Open;

  fdqdLer.First;
  while not fdqdLer.Eof do
  begin
    with Result.Novo do
    begin
      Nome := fdqdLer.FieldByName('field_name').AsString;

      if fdqdLer.FieldByName('FIELD_TYPE_ID').AsInteger in [7,8,16] then
      begin
        if fdqdLer.FieldByName('FIELD_SUB_TYPE').AsInteger = 0 then
          Tipo := ctInteger
        else
          Tipo := ctNumeric;
      end
      else
      if fdqdLer.FieldByName('FIELD_TYPE_ID').AsInteger in [10,27] then
        Tipo := ctNumeric
      else
      if (fdqdLer.FieldByName('FIELD_TYPE_ID').AsInteger in [14,37,40,45]) then
//         (fdqdLer.FieldByName('FIELD_TYPE_ID').AsInteger = 261) then
        Tipo := ctString
      else
      if fdqdLer.FieldByName('FIELD_TYPE_ID').AsInteger in [12,13,35] then
        Tipo := ctDate
      else
        Tipo := ctNaoDefinido;

      Precisao := 0;
      Escala := 0;
      Tamanho := 0;

      if (fdqdLer.FieldByName('FIELD_TYPE_ID').AsInteger <> 45) and
         (fdqdLer.FieldByName('FIELD_TYPE_ID').AsInteger <> 261) then
      begin
        Precisao := fdqdLer.FieldByName('FIELD_PRECISION').AsInteger;
        Escala := fdqdLer.FieldByName('FIELD_SCALE').AsInteger;
        Tamanho := fdqdLer.FieldByName('FIELD_LENGTH').AsInteger;
      end;

      if fdqdLer.FieldByName('FIELD_NULL').AsString = 'NOT NULL' then
        PermiteNulo := False
      else
        PermiteNulo := True;
    end;
    fdqdLer.Next;
  end;

  mCampos := '';
  for i := 0 to Result.Count -1 do
  begin
    if mCampos = '' then
      mCampos := Result.Items[i].Nome
    else
      mCampos := mCampos + ',' + Result.Items[i].Nome;
  end;

  AQuery.SQL.Clear;
  AQuery.SQL.Add('INSERT INTO ' + ATabela);
  AQuery.SQL.Add('(' + mCampos + ')');
  AQuery.SQL.Add('VALUES');
  AQuery.SQL.Add('(:' + mCampos.Replace(',', ',:') + ')');

  for i := 0 to Result.Count -1 do
  begin
    case Result.Items[i].Tipo of
      ctInteger: AQuery.Params[i].DataType := ftInteger;
      ctString: AQuery.Params[i].DataType := ftString;
      ctNumeric: AQuery.Params[i].DataType := ftFloat;
      ctDate: AQuery.Params[i].DataType := ftDateTime;
    end;

    AQuery.Params[i].Precision := Result.Items[i].Precisao;
    AQuery.Params[i].NumericScale := Result.Items[i].Escala;
    AQuery.Params[i].Size := Result.Items[i].Tamanho;
  end;
end;

procedure TfrmPrincipal.NotaEletronicaBeforeChange(const ACampoOrigem,
  ACampoDestino: string; var AValor: Variant);
begin
  if (ACampoDestino.ToUpper = 'COD_VENDA') then
  begin
    if fdqdLer.Locate('DOCUMENTO;SERIE', VarArrayOf([fdqoLer2.FieldByName('NRNFCF').AsInteger,fdqoLer2.FieldByName('SERIE').AsString])) then
      AValor := fdqdLer.FieldByName('COD_VENDA').AsInteger;
  end
  else
  if (ACampoDestino.ToUpper = 'CHAVE_NFE') then
  begin
    if fdqdLer.Locate('DOCUMENTO;SERIE', VarArrayOf([fdqoLer2.FieldByName('NRNFCF').AsInteger,fdqoLer2.FieldByName('SERIE').AsString])) then
      AValor := fdqdLer.FieldByName('CHAVE_NFE').AsString;
  end;
end;

procedure TfrmPrincipal.PagarBeforeChange(const ACampoOrigem, ACampoDestino: string;
  var AValor: Variant);
var
  mValor: Variant;
  mDoc: Integer;
begin
  if (ACampoDestino.ToUpper = 'COD_CONTAS_PAGAR') then
  begin
    Inc(ID);
    AValor := ID;
  end
  else
  if (ACampoDestino.ToUpper = 'COD_FORNECEDOR') then
  begin
    if fdqdLer.Locate('COD_TRANSFERENCIA', fdqoLer.FieldByName('FORNECEDOR').AsInteger) then
      AValor := fdqdLer.FieldByName('cod_pessoa').AsInteger
    else
      AValor := cCodPessoaPadrao;
  end
  else
  if (ACampoDestino.ToUpper = 'COD_COMPRA') then
  begin
    PagarBeforeChange('', 'COD_FORNECEDOR', mValor);
    mDoc := StrToIntDef(TCampo.SoNumero(fdqoLer.FieldByName('nrdocumento').AsString),0);
    if fdqdLer2.Locate('DOCUMENTO;SERIE;COD_FORNECEDOR',
        VarArrayOf([mDoc,
                    fdqoLer.FieldByName('serie').AsString,
                    mValor])) then
      AValor := fdqdLer2.FieldByName('cod_compra').AsInteger;
  end
  else
  if (ACampoDestino.ToUpper = 'PARCELA') then
  begin
//    AValor := Copy(FormatFloat('00', fdqoLer.FieldByName('parcela').AsInteger), 1, 2) + '/' +
//      Copy(FormatFloat('00', fdqoLer.FieldByName('parcelas').AsInteger), 1, 2);
    AValor := '01/01';
  end
  else
  if (ACampoDestino.ToUpper = 'COD_HISTORICO') then
  begin
    AValor := null;
    if fdqdLer3.Locate('cod_transferencia', fdqoLer.FieldByName('codigoccusto').AsInteger) then
      AValor := fdqdLer3.FieldByName('cod_historico').AsString;

    if VarIsNull(AValor) then
      if fdqoLer.FieldByName('dtpagto').AsDateTime > 0 then
        AValor := '020100000';
  end
  else
  if ((ACampoDestino.ToUpper = 'COD_CONTA') or (ACampoDestino.ToUpper = 'COD_CARTEIRA')) then
  begin
    if fdqoLer.FieldByName('dtpagto').AsDateTime > 0 then
      AValor := 1;
  end;
end;

procedure TfrmPrincipal.PagarHistoricoBeforeChange(const ACampoOrigem,
  ACampoDestino: string; var AValor: Variant);
begin
  if UpperCase(ACampoDestino) = 'COD_HISTORICO' then
  begin
    AValor := '0201' + FormatFloat('00000', fdqoLer.FieldByName('ccusto').AsInteger + 10);
  end;
end;

procedure TfrmPrincipal.PessoaFuncionarioCampoBeforeChange(const ACampoOrigem,
  ACampoDestino: string; var AValor: Variant);
var mCpfCnpj: string;
begin
  if UpperCase(ACampoDestino) = 'COD_PESSOA' then
  begin
//    mCpfCnpj := TCampo.SoNumero(fdqoLer.FieldByName('CPF').AsString).Trim;
//    if mCpfCnpj = '' then
//      mCpfCnpj := TCampo.SoNumero(fdqoLer.FieldByName('CNPJ').AsString).Trim;

//    if mCpfCnpj <> '' then
//      if fdqdLer.Locate('CPF_CNPJ', mCpfCnpj) then
//        AValor := fdqdLer.FieldByName('COD_PESSOA').AsInteger;
    if fdqdLer.Locate('COD_TRANSFERENCIA', fdqoLer.FieldByName('funcionario').AsInteger) then
      AValor := fdqdLer.FieldByName('COD_PESSOA').AsInteger;
  end;
end;

procedure TfrmPrincipal.PessoaFuncionarioValidar(const AOrigem: TFDQuery;
  var APodeMigrar: Boolean);
var
  mCpfCnpj: string;
  i: Integer;
begin
  APodeMigrar := fdqdLer.Locate('COD_TRANSFERENCIA', fdqoLer.FieldByName('funcionario').AsInteger);
end;

procedure TfrmPrincipal.Pessoas;
begin
  try
    ZerarClientes;
    Clientes;
    Fornecedores;
    Transportadores;
    Funcionarios;
  finally
    VoltarClientes;
  end;
end;

procedure TfrmPrincipal.PessoaTransportadorCampoBeforeChange(const ACampoOrigem,
  ACampoDestino: string; var AValor: Variant);
begin
  if UpperCase(ACampoDestino) = 'COD_PESSOA' then
  begin
    if fdqdLer.Locate('COD_MIGRACAO', fdqoLer.FieldByName('codigo').AsInteger) then
      AValor := fdqdLer.FieldByName('COD_PESSOA').AsInteger;
  end;
end;

function ImageToBmp(Caminho: String): Vcl.Graphics.TBitmap;
var
  Picture: TPicture;
  jpg: TJPEGImage;
begin
  Picture := TPicture.Create;
  try
    Picture.LoadFromFile(Caminho);
    Result := Vcl.Graphics.TBitmap.Create;
    Result.Width := Picture.Width;
    Result.Height := Picture.Height;
    Result.Canvas.Draw(0, 0, Picture.Graphic);
  finally
    Picture.Free;
  end;
end;
//var
//  jpg: TJPEGImage;
//begin
//  jpg := TJPEGImage.Create;
//  try
//    jpg.LoadFromFile(Caminho);
//    Result := Vcl.Graphics.TBitmap.Create;
//    Result.Assign(jpg);
//  finally
//    jpg.Free;
//  end;
//end;

procedure TfrmPrincipal.ProdutoCampoBeforeChange(const ACampoOrigem,
  ACampoDestino: string; var AValor: Variant);
  function RemoveMaisDeUmaVirgula(ANumero: string): string;
  var
    i: Integer;
    AchouPrimeira: Boolean;
  begin
    Result := ANumero;
    if ANumero.CountChar(',') > 1 then
    begin
      AchouPrimeira := False;
      for i := Result.Length downto 1 do
      begin
        if Result[i] = ',' then
        begin
          if not AchouPrimeira then
            AchouPrimeira := True
          else
            Delete(Result, i, 1);
        end;
      end;
    end;

    if (Result.CountChar(',') > 0) and (Result.CountChar('.') > 0) then
      Result := Result.Replace('.', '');

    if (Result.CountChar('.') > 1) then
    begin
      AchouPrimeira := False;
      for i := Result.Length downto 1 do
      begin
        if Result[i] = '.' then
        begin
          if not AchouPrimeira then
            AchouPrimeira := True
          else
            Delete(Result, i, 1);
        end;
      end;
    end;

    if (Result.CountChar('.') = 1) then
      Result := Result.Replace('.', ',');
  end;
var
  t: TStringList;
  i: Integer;
  mValor,mCaminho: string;
  bmp: TBitmap;
  stream: TMemoryStream;
begin
  if ACampoDestino.ToUpper = 'COD_MARCA' then
  begin
    if fdqdLer.Locate('DESCRICAO', fdqoLer.FieldByName('fabricante').AsString) then
      AValor := fdqdLer.FieldByName('cod_marca').AsInteger;
  end
  else
  if ACampoDestino.ToUpper = 'PE_ALIQUOTA' then
  begin
    if fdqoLer.FieldByName('icms').AsCurrency <= 0 then
      AValor := 'F'
    else
      AValor := FormatFloat('#,##0.00', fdqoLer.FieldByName('icms').AsCurrency);
  end
  else
  if ACampoDestino.ToUpper = 'SN_SUBSTITUICAO' then
  begin
    if fdqoLer.FieldByName('icms').AsCurrency <= 0 then
      AValor := 'S'
  end
  else
  if ACampoDestino.ToUpper = 'ATIVO_INATIVO' then
  begin
    if fdqoLer.FieldByName('inativo').AsString = 'T' then
      AValor := 'I'
  end
  else
  if ACampoDestino.ToUpper = 'COD_CLASS_FISCAL' then
  begin
    if fdqdLer2.Locate('NCM', TCampo.SoNumero(fdqoLer.FieldByName('CLASS_FISCAL').AsString)) then
      AValor := fdqdLer2.FieldByName('cod_class_fiscal').AsInteger;
  end
  else
  if ACampoDestino.ToUpper = 'IMAGEM' then
  begin
    if fdqdFoto.Locate('nomefoto', fdqoLer.FieldByName('dirfoto').AsString) then
    begin
      try
        mCaminho := ExtractFileDir(Application.ExeName);
        mCaminho := IncludeTrailingPathDelimiter(mCaminho) + 'foto\';
        if not DirectoryExists(mCaminho) then
          ForceDirectories(mCaminho);
        TBlobField(fdqdFoto.FieldByName('foto')).SaveToFile(mCaminho + fdqoLer.FieldByName('dirfoto').AsString + fdqdFoto.FieldByName('extfoto').AsString);
        bmp := ImageToBmp(mCaminho + fdqoLer.FieldByName('dirfoto').AsString + fdqdFoto.FieldByName('extfoto').AsString);
        stream := TMemoryStream.Create;
        try
          cdsFoto.Close;
          cdsFoto.CreateDataSet;

          bmp.SaveToStream(stream);
          cdsFoto.Append;
          cdsFotoFOTO.LoadFromStream(stream);
          cdsFoto.Post;
          AValor := cdsFotoFOTO.Value;
        finally
          FreeAndNil(bmp);
          FreeAndNil(stream);
        end;
      except on e: Exception do
        begin
          Mensagem('PRODUTO', fdqoLer.FieldByName('codprod').AsString + '|' + fdqoLer.FieldByName('dirfoto').AsString + '|' + e.Message);
        end;
      end;
    end;
  end
  else
  if ACampoDestino.ToUpper = 'VL_AVISTA' then
  begin
    t := TStringList.Create;
    try
      t.Text := fdqoLer.FieldByName('obs').AsString;
      for i := 0 to t.Count -1 do
      begin
        if t.Strings[i].ToUpper.Contains('VISTA') then
        begin
          mValor := t.Strings[i];
          mValor := Copy(mValor, mValor.ToUpper.IndexOf('VISTA') +5, mValor.Length);
          mValor := TCampo.SoNumeroVirgula(mValor);
          mValor := RemoveMaisDeUmaVirgula(mValor);

          if mValor = '' then
            Exit;

          try
            AValor := StrToFloat(mValor);
          except on e: Exception do
            begin
              Mensagem('PRODUTO_CUSTO', 'VL_AVISTA = "' + t.Strings[i] + '" ' + e.Message);
            end;
          end;
          Break;
        end;
      end;
    finally
      FreeAndNil(t);
    end;
  end;
end;

procedure TfrmPrincipal.Produtos;
var
  mMarca, mProdutos, mCusto, mEstado, mCodBarras, mClassFiscal: TCampos;
  i: Integer;
begin
  if not fdtdGravar.Active then
    fdtdGravar.StartTransaction;
  try
    Mensagem('ACERTO_ESTOQUE_PRODUTO', 'DELETANDO');
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('DELETE FROM ACERTO_ESTOQUE_PRODUTO');
    fdqdGravar.ExecSQL;

    Mensagem('ACERTO_ESTOQUE', 'DELETANDO');
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('DELETE FROM ACERTO_ESTOQUE');
    fdqdGravar.ExecSQL;

    Mensagem('PRODUTO_CUSTO_ESTADO', 'DELETANDO');
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('DELETE FROM PRODUTO_CUSTO_ESTADO');
    fdqdGravar.ExecSQL;

    Mensagem('PRODUTO_UNIDADE_ENTRADA', 'DELETANDO');
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('DELETE FROM PRODUTO_UNIDADE_ENTRADA');
    fdqdGravar.ExecSQL;

    Mensagem('MARCA', 'DELETANDO');
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('DELETE FROM MARCA');
    fdqdGravar.ExecSQL;

    Mensagem('GRUPO', 'DELETANDO');
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('DELETE FROM GRUPO');
    fdqdGravar.ExecSQL;

    Mensagem('SUBGRUPO', 'DELETANDO');
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('DELETE FROM SUBGRUPO');
    fdqdGravar.ExecSQL;

    Mensagem('PRODUTO', 'DELETANDO');
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('DELETE FROM PRODUTO');
    fdqdGravar.ExecSQL;


//    AbreOrigem(fdqdLer, 'SELECT COALESCE(MAX(COD_MARCA), 0) FROM MARCA');
//    ID := fdqdLer.Fields[0].AsInteger;

    mMarca := MontaTabela('MARCA', fdqdGravar);
    AbreOrigem(fdqoLer, 'SELECT FABRICANTE,DESCRFABRICANTE FROM FABRICANTE');

    IniciaProgressBar(fdqoLer.RecordCount);
    mMarca.OnIncProgressBar := IncProgressBar;
    mMarca.OnMensagem := Mensagem;

    mMarca.BuscaPorNome('COD_MARCA').Equivalente := 'FABRICANTE';
    mMarca.BuscaPorNome('DESCRICAO').Equivalente := 'DESCRFABRICANTE';

    mMarca.BufferArrayDML(fdqoLer, fdqdGravar);

//    AbreOrigem(fdqdLer, 'SELECT COALESCE(MAX(COD_MARCA), 0) FROM GRUPO');
//    ID := fdqdLer.Fields[0].AsInteger;

    mMarca := MontaTabela('GRUPO', fdqdGravar);
    AbreOrigem(fdqoLer, 'SELECT DEPARTAMENTO,DESCRDEPTO FROM DEPARTAMENTO');

    IniciaProgressBar(fdqoLer.RecordCount);
    mMarca.OnIncProgressBar := IncProgressBar;
    mMarca.OnMensagem := Mensagem;

    mMarca.BuscaPorNome('COD_GRUPO').Equivalente := 'DEPARTAMENTO';
    mMarca.BuscaPorNome('DESCRICAO').Equivalente := 'DESCRDEPTO';

    mMarca.BufferArrayDML(fdqoLer, fdqdGravar);

//    AbreOrigem(fdqdLer, 'SELECT COALESCE(MAX(COD_MARCA), 0) FROM SUBGRUPO');
//    ID := fdqdLer.Fields[0].AsInteger;

    mMarca := MontaTabela('SUBGRUPO', fdqdGravar);
    AbreOrigem(fdqoLer, 'SELECT SECAO,DESCRSECAO FROM SECAO');

    IniciaProgressBar(fdqoLer.RecordCount);
    mMarca.OnIncProgressBar := IncProgressBar;
    mMarca.OnMensagem := Mensagem;

    mMarca.BuscaPorNome('COD_SUBGRUPO').Equivalente := 'SECAO';
    mMarca.BuscaPorNome('DESCRICAO').Equivalente := 'DESCRSECAO';

    mMarca.BufferArrayDML(fdqoLer, fdqdGravar);

    AbreOrigem(fdqdLer, 'SELECT COALESCE(MAX(COD_CLASS_FISCAL), 0) FROM CLASS_FISCAL');
    ID := fdqdLer.Fields[0].AsInteger;

    mClassFiscal := MontaTabela('CLASS_FISCAL', fdqdGravar);
    AbreOrigem(fdqoLer, 'SELECT CLASSFISCAL FROM CLASSFISCAL');
    AbreOrigem(fdqdLer, 'SELECT COD_CLASS_FISCAL,NCM FROM CLASS_FISCAL');

    IniciaProgressBar(fdqoLer.RecordCount);
    mClassFiscal.OnIncProgressBar := IncProgressBar;
    mClassFiscal.OnMensagem := Mensagem;
    mClassFiscal.OnValidarRegistro := ClassFiscalValidar;

    mClassFiscal.BuscaPorNome('COD_CLASS_FISCAL').OnBeforeChange := MarcaCampoBeforeChange;
    mClassFiscal.BuscaPorNome('NCM').Equivalente := 'CLASSFISCAL';
    mClassFiscal.BuscaPorNome('NCM').StrSoNumero := True;
    mClassFiscal.BuscaPorNome('DESCRICAO').Equivalente := 'CLASSFISCAL';

    mClassFiscal.BufferArrayDML(fdqoLer, fdqdGravar);


    mProdutos := MontaTabela('PRODUTO', fdqdGravar);
    AbreOrigem(fdqoLer, 'SELECT P.*,C.CLASSFISCAL CLASS_FISCAL,T.*,CAST(P.OBSERVACAO AS VARCHAR(2024)) OBS FROM PRODUTO P'+
                        '  LEFT OUTER JOIN CLASSFISCAL C '+
                        '    ON C.LETRA = P.LCLASSFISCAL '+
                        '  LEFT OUTER JOIN TAB00001 T '+
                        '    ON T.CODBARRA = P.CODBARRA');
//    AbreOrigem(fdqoLer2, 'SELECT CODBARRA,PRECOVAR,MARGEM,PRECOSUGESTAO FROM TAB00001');
//    AbreOrigem(fdqdLer, 'SELECT COD_MARCA,DESCRICAO FROM MARCA');
    AbreOrigem(fdqdLer2, 'SELECT COD_CLASS_FISCAL,NCM FROM CLASS_FISCAL');
    AbreOrigem(fdqdFoto, 'SELECT * FROM FOTO');

    IniciaProgressBar(fdqoLer.RecordCount);
    mProdutos.OnIncProgressBar := IncProgressBar;
    mProdutos.OnMensagem := Mensagem;

    mProdutos.BuscaPorNome('COD_PRODUTO').Equivalente := 'CODPROD';
    mProdutos.BuscaPorNome('COD_EXTERNO').Equivalente := 'CODBARRA';
    mProdutos.BuscaPorNome('DESCRICAO').Equivalente := 'DESCRICAO';
    mProdutos.BuscaPorNome('COD_MARCA').Equivalente := 'FABRICANTE';
    mProdutos.BuscaPorNome('COD_MARCA').IgnorarZero := True;
    //mProdutos.BuscaPorNome('COD_MARCA').OnBeforeChange := ProdutoCampoBeforeChange;
    mProdutos.BuscaPorNome('COD_GRUPO').Equivalente := 'DEPARTAMENTO';
    mProdutos.BuscaPorNome('COD_GRUPO').IgnorarZero := True;
    mProdutos.BuscaPorNome('COD_SUBGRUPO').Equivalente := 'SECAO';
    mProdutos.BuscaPorNome('COD_SUBGRUPO').IgnorarZero := True;
    mProdutos.BuscaPorNome('UNIDADE').Equivalente := 'UNID_VAREJO';
    mProdutos.BuscaPorNome('ATIVO_INATIVO').ValorDefault := 'A';
    mProdutos.BuscaPorNome('ATIVO_INATIVO').OnBeforeChange := ProdutoCampoBeforeChange;
    mProdutos.BuscaPorNome('SIT_TRIB').Equivalente := 'ICMSSP';
    mProdutos.BuscaPorNome('COD_CLASS_FISCAL').OnBeforeChange := ProdutoCampoBeforeChange;
    mProdutos.BuscaPorNome('CSOSN').Equivalente := '';
    mProdutos.BuscaPorNome('PESO_LIQUIDO').Equivalente := 'PESOLIQ';
    mProdutos.BuscaPorNome('PESO_BRUTO').Equivalente := 'PESOBRU';
    mProdutos.BuscaPorNome('OBS').Equivalente := 'OBS';
    mProdutos.BuscaPorNome('IMAGEM').OnBeforeChange := ProdutoCampoBeforeChange;
    mProdutos.BuscaPorNome('TIPO_PRODUTO').ValorDefault := 'P';
    mProdutos.BuscaPorNome('SN_MONOFASICO').ValorDefault := 'N';
    mProdutos.BuscaPorNome('SN_PATRIMONIO_QTDE').ValorDefault := 'N';
    mProdutos.BuscaPorNome('COD_ANP').Equivalente := '';
    mProdutos.BuscaPorNome('SN_ARMA').ValorDefault := 'N';
    mProdutos.BuscaPorNome('COD_CLASS_FISCAL_CEST').Equivalente := '';
    mProdutos.BuscaPorNome('SN_VACINA').ValorDefault := 'N';
    mProdutos.BuscaPorNome('SN_ESTOQUE').ValorDefault := 'S';
    mProdutos.BuscaPorNome('QTDE_EMBALAGEM').Equivalente := 'EMBAL_VAREJO';
    mProdutos.BuscaPorNome('DESCRICAO_ANP').Equivalente := '';
    mProdutos.BuscaPorNome('SN_OBRIGA_COMPLEMENTO').ValorDefault := 'N';
    mProdutos.BuscaPorNome('COD_USUARIO_INCLUSAO').ValorDefault := 0;
    mProdutos.BuscaPorNome('DH_INCLUSAO').ValorDefault := Now;

    mProdutos.BufferArrayDML(fdqoLer, fdqdGravar);

    for i := 1 to 2 do
    begin
      mCusto := MontaTabela('PRODUTO_CUSTO', fdqdGravar);

      IniciaProgressBar(fdqoLer.RecordCount);
      mCusto.OnIncProgressBar := IncProgressBar;
      mCusto.OnMensagem := Mensagem;

      mCusto.BuscaPorNome('COD_PRODUTO').Equivalente := 'CODPROD';
      mCusto.BuscaPorNome('ATIVO_INATIVO').ValorDefault := 'A';
      mCusto.BuscaPorNome('COD_EMPRESA').ValorDefault := i;
      mCusto.BuscaPorNome('VL_CUSTO').Equivalente := 'CUSTOVAR';
      mCusto.BuscaPorNome('VL_CUSTO_MEDIO').Equivalente := 'CUSTOMEDIO';
      mCusto.BuscaPorNome('VL_PRAZO').Equivalente := 'PRECOVAR';
      mCusto.BuscaPorNome('VL_PRAZO').ValorDefault := 0;
      mCusto.BuscaPorNome('VL_AVISTA').Equivalente := 'PRECOVAR';
      mCusto.BuscaPorNome('VL_AVISTA').ValorDefault := 0;
  //    mCusto.BuscaPorNome('VL_AVISTA').OnBeforeChange := ProdutoCampoBeforeChange;
      mCusto.BuscaPorNome('QTDE_ESTQ').Equivalente := 'ESTATUAL';
      mCusto.BuscaPorNome('QTDE_ESTQ').ValorDefault := 0;
      mCusto.BuscaPorNome('ESTQ_MINIMO').Equivalente := 'ESTMINIMO';
  //    mCusto.BuscaPorNome('COMISSAO').Equivalente := 'COMISSAO';
      mCusto.BuscaPorNome('PE_IPI').Equivalente := 'IPI';
      mCusto.BuscaPorNome('CST_IPI').Equivalente := 'CSTIPINFE';

      mCusto.BufferArrayDML(fdqoLer, fdqdGravar);


      mEstado := MontaTabela('PRODUTO_CUSTO_ESTADO', fdqdGravar);

      IniciaProgressBar(fdqoLer.RecordCount);
      mEstado.OnIncProgressBar := IncProgressBar;
      mEstado.OnMensagem := Mensagem;

      mEstado.BuscaPorNome('COD_PRODUTO').Equivalente := 'CODPROD';
      mEstado.BuscaPorNome('COD_EMPRESA').ValorDefault := i;
      mEstado.BuscaPorNome('COD_ESTADO').ValorDefault := 'SP';
  //    mEstado.BuscaPorNome('CST').Equivalente := 'CST';
      mEstado.BuscaPorNome('CSOSN').ValorDefault := '0101';
      mEstado.BuscaPorNome('PE_ALIQUOTA').Equivalente := 'ICMSSP';
  //    mEstado.BuscaPorNome('PE_ALIQUOTA').OnBeforeChange := ProdutoCampoBeforeChange;
      mEstado.BuscaPorNome('SN_SUBSTITUICAO').ValorDefault := 'N';
  //    mEstado.BuscaPorNome('SN_SUBSTITUICAO').OnBeforeChange := ProdutoCampoBeforeChange;

      mEstado.BufferArrayDML(fdqoLer, fdqdGravar);

      IniciaProgressBar(fdqoLer.RecordCount);
      mEstado.OnIncProgressBar := IncProgressBar;
      mEstado.OnMensagem := Mensagem;

      mEstado.BuscaPorNome('COD_PRODUTO').Equivalente := 'CODPROD';
      mEstado.BuscaPorNome('COD_EMPRESA').ValorDefault := i;
      mEstado.BuscaPorNome('COD_ESTADO').ValorDefault := 'PR';
  //    mEstado.BuscaPorNome('CST').Equivalente := 'CST';
      mEstado.BuscaPorNome('CSOSN').ValorDefault := '0101';
      mEstado.BuscaPorNome('PE_ALIQUOTA').Equivalente := 'ICMSPR';
  //    mEstado.BuscaPorNome('PE_ALIQUOTA').OnBeforeChange := ProdutoCampoBeforeChange;
      mEstado.BuscaPorNome('SN_SUBSTITUICAO').ValorDefault := 'N';
  //    mEstado.BuscaPorNome('SN_SUBSTITUICAO').OnBeforeChange := ProdutoCampoBeforeChange;

      mEstado.BufferArrayDML(fdqoLer, fdqdGravar);

      IniciaProgressBar(fdqoLer.RecordCount);
      mEstado.OnIncProgressBar := IncProgressBar;
      mEstado.OnMensagem := Mensagem;

      mEstado.BuscaPorNome('COD_PRODUTO').Equivalente := 'CODPROD';
      mEstado.BuscaPorNome('COD_EMPRESA').ValorDefault := i;
      mEstado.BuscaPorNome('COD_ESTADO').ValorDefault := 'DF';
  //    mEstado.BuscaPorNome('CST').Equivalente := 'CST';
      mEstado.BuscaPorNome('CSOSN').ValorDefault := '0101';
      mEstado.BuscaPorNome('PE_ALIQUOTA').Equivalente := 'ICMSDF';
  //    mEstado.BuscaPorNome('PE_ALIQUOTA').OnBeforeChange := ProdutoCampoBeforeChange;
      mEstado.BuscaPorNome('SN_SUBSTITUICAO').ValorDefault := 'N';
  //    mEstado.BuscaPorNome('SN_SUBSTITUICAO').OnBeforeChange := ProdutoCampoBeforeChange;

      mEstado.BufferArrayDML(fdqoLer, fdqdGravar);
    end;

    mCodBarras := MontaTabela('PRODUTO_CODBARRA', fdqdGravar);

    IniciaProgressBar(fdqoLer.RecordCount);
    mCodBarras.OnIncProgressBar := IncProgressBar;
    mCodBarras.OnMensagem := Mensagem;

    mCodBarras.BuscaPorNome('COD_PRODUTO').Equivalente := 'CODPROD';
    mCodBarras.BuscaPorNome('COD_BARRA').Equivalente := 'CODBARRA';
    mCodBarras.BuscaPorNome('SN_AUTOMATICO').ValorDefault := 'N';

    mCodBarras.BufferArrayDML(fdqoLer, fdqdGravar);

    Mensagem('PRODUTO_UNIDADE_ENTRADA', 'ADICIONANDO...');
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('insert into PRODUTO_UNIDADE_ENTRADA');
    fdqdGravar.SQL.Add('(');
    fdqdGravar.SQL.Add('  COD_PRODUTO');
    fdqdGravar.SQL.Add(', COD_UNIDADE');
    fdqdGravar.SQL.Add(', NM_UNIDADE');
    fdqdGravar.SQL.Add(', FATOR');
    fdqdGravar.SQL.Add(', SN_PADRAO');
    fdqdGravar.SQL.Add(')');
    fdqdGravar.SQL.Add('SELECT COD_PRODUTO,1,''UN'',1,''S'' FROM PRODUTO');
    fdqdGravar.ExecSQL;

    {Mensagem('ACERTO_ESTOQUE', 'ADICIONANDO...');
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('INSERT INTO ACERTO_ESTOQUE');
    fdqdGravar.SQL.Add('(COD_ACERTO_ESTOQUE,COD_EMPRESA,DT_EMISSAO,COD_FUNCIONARIO)');
    fdqdGravar.SQL.Add('VALUES');
    fdqdGravar.SQL.Add('(1,1,CURRENT_DATE,1)');
    fdqdGravar.ExecSQL;

    Mensagem('ACERTO_ESTOQUE_PRODUTO', 'ADICIONANDO...');
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('INSERT INTO ACERTO_ESTOQUE_PRODUTO');
    fdqdGravar.SQL.Add('(COD_ACERTO_ESTOQUE_PRODUTO,COD_ACERTO_ESTOQUE,COD_PRODUTO,QTDE)');
    fdqdGravar.SQL.Add('SELECT (SELECT COALESCE(MAX(COD_ACERTO_ESTOQUE_PRODUTO),0) +1 FROM ACERTO_ESTOQUE_PRODUTO),');
    fdqdGravar.SQL.Add('       1,');
    fdqdGravar.SQL.Add('       COD_PRODUTO,');
    fdqdGravar.SQL.Add('       QTDE_ESTQ');
    fdqdGravar.SQL.Add('  FROM PRODUTO_CUSTO');
    fdqdGravar.SQL.Add(' WHERE QTDE_ESTQ <> 0');
    fdqdGravar.ExecSQL;}

    fdtdGravar.Commit;
  finally
    if fdtdGravar.Active then
      fdtdGravar.Rollback;
  end;
end;

procedure TfrmPrincipal.ReceberBeforeChange(const ACampoOrigem, ACampoDestino: string;
  var AValor: Variant);
begin
  if (ACampoDestino.ToUpper = 'COD_CONTAS_RECEBER') then
  begin
    Inc(ID);
    AValor := ID;
  end
  else
  if (ACampoDestino.ToUpper = 'COD_CLIENTE') then
  begin
    if not fdqdLer.Locate('COD_PESSOA', fdqoLer.FieldByName('CLIENTE').AsInteger) then
      AValor := cCodPessoaPadrao;
  end
  else
  if (ACampoDestino.ToUpper = 'COD_VENDA') then
  begin
    if fdqdLer2.Locate('DOCUMENTO;SERIE;COD_CLIENTE',
        VarArrayOf([StrToIntDef(TCampo.SoNumero(fdqoLer.FieldByName('nrdocumento').AsString),0),
                    fdqoLer.FieldByName('serie').AsString,
                    fdqoLer.FieldByName('CLIENTE').AsInteger])) then
      AValor := fdqdLer2.FieldByName('COD_VENDA').AsInteger;
  end
  else
  if (ACampoDestino.ToUpper = 'PARCELA') then
  begin
//    AValor := Copy(FormatFloat('000', fdqoLer.FieldByName('parcela').AsInteger), 1, 3) + '/' +
//      Copy(FormatFloat('000', fdqoLer.FieldByName('parcelas').AsInteger), 1, 3);
    AValor := '001/001';
  end
  else
  if (ACampoDestino.ToUpper = 'COD_HISTORICO') then
  begin
    if fdqoLer.FieldByName('dtpagto').AsDateTime > 0 then
      AValor := '010100000';
  end
  else
  if ((ACampoDestino.ToUpper = 'COD_CONTA') or (ACampoDestino.ToUpper = 'COD_CARTEIRA')) then
  begin
    if fdqoLer.FieldByName('dtpagto').AsDateTime > 0 then
      AValor := 1;
  end;
end;

procedure TfrmPrincipal.ScriptMarcaProduto;
var t: TStringList;
begin
  AbreOrigem(fdqoLer, 'SELECT * FROM TABEST1');
  AbreOrigem(fdqdLer, 'SELECT COD_MARCA,DESCRICAO FROM MARCA');

  t := TStringList.Create;
  try
    fdqoLer.First;
    while not fdqoLer.Eof do
    begin
      if fdqdLer.Locate('DESCRICAO', fdqoLer.FieldByName('FABRICANTE').AsString) then
        t.Add('UPDATE PRODUTO SET'+
          ' COD_MARCA = '+fdqdLer.FieldByName('cod_marca').AsString+
          ' WHERE COD_PRODUTO = ' + fdqoLer.FieldByName('CONTROLE').AsString + ';');
      fdqoLer.Next;
    end;
    T.SaveToFile('C:\Temp\ProdutoMarca.txt');
  finally
    FreeAndNil(t);
  end;
end;

procedure TfrmPrincipal.SetGenerators;
begin
  try
    if not fdtdGravar.Active then
      fdtdGravar.StartTransaction;

    Mensagem('GENERATORS', 'SET TO');

    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('SELECT GEN_ID(GEN_VENDA, (SELECT COALESCE(MAX(COD_VENDA), 0) FROM VENDA)) FROM RDB$DATABASE;');
    try
      fdqdGravar.ExecSQL;
    except
      Mensagem('GENERATORS', 'ERRO');
    end;

    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('SELECT GEN_ID(GEN_CONTAS_RECEBER, (SELECT COALESCE(MAX(COD_CONTAS_RECEBER), 0) FROM CONTAS_RECEBER)) FROM RDB$DATABASE;');
    fdqdGravar.ExecSQL;

    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('SELECT GEN_ID(GEN_VENDA_PRODUTO, (SELECT COALESCE(MAX(COD_VENDA_PRODUTO), 0) FROM VENDA_PRODUTO)) FROM RDB$DATABASE;');
    fdqdGravar.ExecSQL;

    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('SELECT GEN_ID(GEN_VENDA_PRODUTO_COMPLEMENTO, (SELECT COALESCE(MAX(COD_VENDA_PRODUTO_COMPLEMENTO), 0) FROM VENDA_PRODUTO_COMPLEMENTO)) FROM RDB$DATABASE;');
    fdqdGravar.ExecSQL;

    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('SELECT GEN_ID(GEN_VENDA_PRODUTOTMP, (SELECT COALESCE(MAX(COD_VENDA_PRODUTOTMP), 0) FROM VENDA_PRODUTOTMP)) FROM RDB$DATABASE;');
    fdqdGravar.ExecSQL;

    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('SELECT GEN_ID(GEN_VENDA_PRODUTO_COMPLETMP, (SELECT COALESCE(MAX(COD_VENDA_PRODUTO_COMPLETMP), 0) FROM VENDA_PRODUTO_COMPLETMP)) FROM RDB$DATABASE;');
    fdqdGravar.ExecSQL;

    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('SELECT GEN_ID(GEN_COMPRA_PRODUTO, (SELECT COALESCE(MAX(COD_COMPRA_PRODUTO), 0) FROM COMPRA_PRODUTO)) FROM RDB$DATABASE;');
    fdqdGravar.ExecSQL;

    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('SELECT GEN_ID(GEN_COMPRA, (SELECT COALESCE(MAX(COD_COMPRA), 0) FROM COMPRA)) FROM RDB$DATABASE;');
    fdqdGravar.ExecSQL;

    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('SELECT GEN_ID(GEN_ACERTO_ESTOQUE_PRODUTO, (SELECT COALESCE(MAX(COD_ACERTO_ESTOQUE_PRODUTO), 0) FROM ACERTO_ESTOQUE_PRODUTO)) FROM RDB$DATABASE;');
    fdqdGravar.ExecSQL;

    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('SELECT GEN_ID(GEN_ORCAMENTO_PRODUTO, (SELECT COALESCE(MAX(COD_ORCAMENTO_PRODUTO), 0) FROM ORCAMENTO_PRODUTO)) FROM RDB$DATABASE;');
    fdqdGravar.ExecSQL;

    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('SELECT GEN_ID(GEN_ORDEM_PRODUTO, (SELECT COALESCE(MAX(COD_ORDEM_PRODUTO), 0) FROM ORDEM_PRODUTO)) FROM RDB$DATABASE;');
    fdqdGravar.ExecSQL;

    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('SELECT GEN_ID(GEN_CONDICIONAL_PRODUTO, (SELECT COALESCE(MAX(COD_CONDICIONAL_PRODUTO), 0) FROM CONDICIONAL_PRODUTO)) FROM RDB$DATABASE;');
    fdqdGravar.ExecSQL;

    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('SELECT GEN_ID(GEN_ORIGEM_ATENDIMENTO, (SELECT COALESCE(MAX(COD_ORIGEM_ATENDIMENTO), 0) FROM ORIGEM_ATENDIMENTO)) FROM RDB$DATABASE;');
    fdqdGravar.ExecSQL;

    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('SELECT GEN_ID(GEN_TIPO_ATENDIMENTO, (SELECT COALESCE(MAX(COD_TIPO_ATENDIMENTO), 0) FROM TIPO_ATENDIMENTO)) FROM RDB$DATABASE;');
    fdqdGravar.ExecSQL;

    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('SELECT GEN_ID(GEN_ATENDIMENTO, (SELECT COALESCE(MAX(COD_ATENDIMENTO), 0) FROM ATENDIMENTO)) FROM RDB$DATABASE;');
    fdqdGravar.ExecSQL;

    fdtdGravar.Commit;
  finally
    if fdtdGravar.Active then
      fdtdGravar.Rollback;
  end;
end;

procedure TfrmPrincipal.TransportadorCampoBeforeChange(const ACampoOrigem,
  ACampoDestino: string; var AValor: Variant);
begin
  if ACampoDestino.ToUpper = 'COD_PESSOA' then
  begin
    Inc(ID);
    AValor := ID;
  end
  else
  if ACampoDestino.ToUpper = 'CPF_CNPJ' then
  begin
    if fdqoLer.FieldByName('CNPJ').AsString <> '' then
      AValor := TCampo.SoNumero(fdqoLer.FieldByName('CNPJ').AsString)
    else
      AValor := TCampo.SoNumero(fdqoLer.FieldByName('CPF').AsString);

    if VarToStr(AValor) = '' then
      AValor := '11111111111';
  end
  else
  if ACampoDestino.ToUpper = 'COD_CIDADE' then
  begin
    if fdqdLer.Locate('NOME;COD_ESTADO', VarArrayOf([
         fdqoLer.FieldByName('CIDADEFAT').AsString,
         fdqoLer.FieldByName('UFFAT').AsString])) then
      AValor := fdqdLer.FieldByName('cod_cidade').AsInteger
    else
    if fdqdLer.Locate('NOME', fdqoLer.FieldByName('CIDADEFAT').AsString) then
      AValor := fdqdLer.FieldByName('cod_cidade').AsInteger;
  end
  else
  if ACampoDestino.ToUpper = 'EMAIL' then
  begin
    if fdqoLer.FieldByName('email').IsNull then
      AValor := fdqoLer.FieldByName('emailnfe').AsString;
  end
  else
  if ACampoDestino.ToUpper = 'COD_MOTIVO_BLOQUEIO' then
  begin
    if fdqoLer.FieldByName('MOTIVOBLOQ').AsString.Trim <> '' then
      AValor := 1;
  end
  else
  if ACampoDestino.ToUpper = 'ATIVO_INATIVO' then
  begin
    if fdqoLer.FieldByName('INATIVO').AsString = 'T' then
      AValor := 'I';
  end;
end;

procedure TfrmPrincipal.Transportadores;
var
  mPessoas, mFornecedor: TCampos;
  mMax: Integer;
begin
  try
    if not fdtdGravar.Active then
      fdtdGravar.StartTransaction;

    Mensagem('PESSOA', 'COD_MIGRACAO');
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('ALTER TABLE PESSOA ADD COD_MIGRACAO INTEGER');
    try
      fdqdGravar.ExecSQL;
    except
      Mensagem('PESSOA', 'JÁ CRIADO');
    end;

    fdtdGravar.Commit;
    if not fdtdGravar.Active then
      fdtdGravar.StartTransaction;

    AbreOrigem(fdqdLer, 'SELECT MAX(COD_PESSOA) FROM PESSOA');
    mMax := fdqdLer.Fields[0].AsInteger;
    ID := mMax;

    mPessoas := MontaTabela('PESSOA', fdqdGravar);
    AbreOrigem(fdqoLer, 'SELECT TRANSPORTADORA.*,CAST(OBSERVACAO AS VARCHAR(2024)) OBS FROM TRANSPORTADORA');
    AbreOrigem(fdqdLer, 'SELECT COD_CIDADE,NOME,COD_ESTADO,COD_IBGE FROM CIDADE');

    IniciaProgressBar(fdqoLer.RecordCount);
    mPessoas.OnIncProgressBar := IncProgressBar;
    mPessoas.OnMensagem := Mensagem;

    mPessoas.BuscaPorNome('COD_PESSOA').Equivalente := 'CODIGO';
    mPessoas.BuscaPorNome('COD_PESSOA').OnBeforeChange := TransportadorCampoBeforeChange;
    mPessoas.BuscaPorNome('COD_MIGRACAO').Equivalente := 'CODIGO';
    mPessoas.BuscaPorNome('CPF_CNPJ').OnBeforeChange := TransportadorCampoBeforeChange;
    mPessoas.BuscaPorNome('CPF_CNPJ').StrSoNumero := True;
    mPessoas.BuscaPorNome('CPF_CNPJ').Tamanho := 14;
    mPessoas.BuscaPorNome('CPF_CNPJ').ValorDefault := '11111111111';
    mPessoas.BuscaPorNome('RG_INSC').Equivalente := 'RGIE';
    mPessoas.BuscaPorNome('NOME').Equivalente := 'RAZSOCIAL';
    mPessoas.BuscaPorNome('FANTASIA').Equivalente := 'FANTASIA';
    mPessoas.BuscaPorNome('ENDERECO').Equivalente := 'ENDFAT';
//    mPessoas.BuscaPorNome('NUMERO').Equivalente := 'NRENDFAT';
    mPessoas.BuscaPorNome('BAIRRO').Equivalente := 'BAIRROFAT';
    mPessoas.BuscaPorNome('DT_CADASTRO').Equivalente := 'DTCAD';
    mPessoas.BuscaPorNome('DT_CADASTRO').ValorDefault := Now;
    mPessoas.BuscaPorNome('COD_CIDADE').Equivalente := '';
    mPessoas.BuscaPorNome('COD_CIDADE').ValorDefault := 1;
    mPessoas.BuscaPorNome('COD_CIDADE').OnBeforeChange := TransportadorCampoBeforeChange;
    mPessoas.BuscaPorNome('CEP').Equivalente := 'CEPFAT';
    mPessoas.BuscaPorNome('CEP').StrSoNumero := True;
//    mPessoas.BuscaPorNome('SITE').Equivalente := 'HOMEPAGE';
    mPessoas.BuscaPorNome('ATIVO_INATIVO').Equivalente := '';
    mPessoas.BuscaPorNome('ATIVO_INATIVO').ValorDefault := 'A';
    mPessoas.BuscaPorNome('ATIVO_INATIVO').OnBeforeChange := TransportadorCampoBeforeChange;
    mPessoas.BuscaPorNome('EMAIL').Equivalente := 'EMAIL';
    mPessoas.BuscaPorNome('EMAIL').StrUpper := False;
//    mPessoas.BuscaPorNome('EMAIL').OnBeforeChange := TransportadorCampoBeforeChange;
    mPessoas.BuscaPorNome('TIPO_PESSOA').Equivalente := 'PESSOAFJ';
//    mPessoas.BuscaPorNome('TIPO_PESSOA').OnBeforeChange := ClienteCampoBeforeChange;
//    mPessoas.BuscaPorNome('DT_NASC').Equivalente := 'DTNASCTO';
    mPessoas.BuscaPorNome('FONE').Equivalente := 'TELFAT';
//    mPessoas.BuscaPorNome('CELULAR').Equivalente := 'CELFAT';
    mPessoas.BuscaPorNome('FAX').Equivalente := 'FAXFAT';
    mPessoas.BuscaPorNome('OBS').Equivalente := 'OBS';
//    mPessoas.BuscaPorNome('CELULAR2').Equivalente := 'TELCOMPLEMENTAR';
//    mPessoas.BuscaPorNome('COMPLEMENTO').Equivalente := 'COMPLFAT';
    mPessoas.BuscaPorNome('SEXO').Equivalente := '';
    mPessoas.BuscaPorNome('REFERENCIA').Equivalente := '';
    mPessoas.BuscaPorNome('DH_INCLUSAO').Equivalente := '';
    mPessoas.BuscaPorNome('DH_INCLUSAO').ValorDefault := Now;
    mPessoas.BuscaPorNome('COD_USUARIO_INCLUSAO').Equivalente := '';
    mPessoas.BuscaPorNome('COD_USUARIO_INCLUSAO').ValorDefault := 0;

    mPessoas.BufferArrayDML(fdqoLer, fdqdGravar);

    fdtdGravar.Commit;
    if not fdtdGravar.Active then
      fdtdGravar.StartTransaction;

    ID := mMax;
    mFornecedor := MontaTabela('FORNECEDOR', fdqdGravar);
    AbreOrigem(fdqdLer, 'SELECT COD_PESSOA,COD_MIGRACAO FROM PESSOA');

    IniciaProgressBar(fdqoLer.RecordCount);
    mFornecedor.OnIncProgressBar := IncProgressBar;
    mFornecedor.OnMensagem := Mensagem;

    mFornecedor.BuscaPorNome('COD_PESSOA').Equivalente := 'CODIGO';
    mFornecedor.BuscaPorNome('COD_PESSOA').OnBeforeChange := PessoaTransportadorCampoBeforeChange;
    mFornecedor.BuscaPorNome('CONTATO').Equivalente := 'CONTATO';
    mFornecedor.BuscaPorNome('SN_TRANSPORTADOR').ValorDefault := 'S';

    mFornecedor.BufferArrayDML(fdqoLer, fdqdGravar);

    fdtdGravar.Commit;
  finally
    if fdtdGravar.Active then
      fdtdGravar.Rollback;
  end;
end;

procedure TfrmPrincipal.VendaBeforeChange(const ACampoOrigem, ACampoDestino: string;
  var AValor: Variant);
var mCpfCnpj: string;
begin
  if ((ACampoDestino.ToUpper = 'COD_VENDA') or (ACampoDestino.ToUpper = 'COD_VENDA_PRODUTO')) then
  begin
    Inc(ID);
    AValor := ID;
  end
  else
  if (ACampoDestino.ToUpper = 'COD_CLIENTE') then
  begin
    if not fdqdLer.Locate('COD_PESSOA', fdqoLer.FieldByName('CLIENTE').AsInteger) then
      AValor := cCodPessoaPadrao;
  end
  else
  if (ACampoDestino.ToUpper = 'COD_FUNCIONARIO') then
  begin
    if fdqdLer.Locate('COD_TRANSFERENCIA', fdqoLer.FieldByName('VENDEDOR').AsInteger) then
      AValor := fdqdLer.FieldByName('COD_PESSOA').AsInteger;
  end
  else
  if (ACampoDestino.ToUpper = 'COD_CONDICAO_PAGTO') then
  begin
    if not fdqdLer2.Locate('COD_CONDICAO_PAGTO', fdqoLer.FieldByName('CDCONDPAGTO').AsInteger) then
      AValor := 'AV';
  end
  else
  if (ACampoDestino.ToUpper = 'COD_TRANSPORTADOR') then
  begin
    if fdqdLer3.Locate('COD_MIGRACAO', fdqoLer.FieldByName('TRANSPORTADORA').AsInteger) then
      AValor := fdqdLer3.FieldByName('COD_PESSOA').AsInteger;
  end;
end;

procedure TfrmPrincipal.VendaExterna;
var mTabela, mTabela2: TCampos;
begin
  if not fdtdGravar.Active then
    fdtdGravar.StartTransaction;

  try
    Mensagem('VENDA_PRODUTO_EXTERNO', 'DELETANDO');
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('DELETE FROM VENDA_PRODUTO_EXTERNO');
    fdqdGravar.ExecSQL;

    Mensagem('VENDA_EXTERNO', 'DELETANDO');
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('DELETE FROM VENDA_EXTERNO');
    fdqdGravar.ExecSQL;

    fdtdGravar.Commit;
    if not fdtdGravar.Active then
      fdtdGravar.StartTransaction;

    mTabela := MontaTabela('VENDA_EXTERNO', fdqdGravar);
    AbreOrigem(fdqoLer, 'SELECT * FROM CPED WHERE TIPO IN (''O'',''P'')');
    AbreOrigem(fdqdLer, 'SELECT P.COD_PESSOA,P.COD_TRANSFERENCIA,P.COD_MIGRACAO '+#13+
                        '  FROM PESSOA P '+#13+
                        ' WHERE NOT EXISTS (SELECT F.COD_PESSOA FROM FORNECEDOR F WHERE F.COD_PESSOA = P.COD_PESSOA)');
    AbreOrigem(fdqdLer2, 'SELECT COD_CONDICAO_PAGTO FROM CONDICAO_PAGTO');
    AbreOrigem(fdqdLer3, 'SELECT COD_PESSOA,COD_MIGRACAO FROM PESSOA WHERE COD_MIGRACAO IS NOT NULL');
    AbreOrigem(fdqdLer4, 'select p.cod_pessoa,p.fantasia from pessoa p inner join funcionario f on f.cod_pessoa = p.cod_pessoa');

    ID := 0;
    IniciaProgressBar(fdqoLer.RecordCount);
    mTabela.OnIncProgressBar := IncProgressBar;
    mTabela.OnMensagem := Mensagem;

    mTabela.BuscaPorNome('COD_VENDA_EXTERNO').Equivalente := 'NRPEDIDO';
    mTabela.BuscaPorNome('COD_EMPRESA').Equivalente := 'EMPRESA';
    mTabela.BuscaPorNome('COD_EMPRESA').ValorDefault := 1;
    mTabela.BuscaPorNome('COD_CLIENTE').Equivalente := 'CLIENTE';
    mTabela.BuscaPorNome('COD_CLIENTE').OnBeforeChange := VendaExternaBeforeChange;
    mTabela.BuscaPorNome('COD_FUNCIONARIO').Equivalente := 'VENDEDOR';
    mTabela.BuscaPorNome('COD_FUNCIONARIO').OnBeforeChange := VendaExternaBeforeChange;
    mTabela.BuscaPorNome('COD_FUNCIONARIO').ValorDefault := cCodPessoaPadrao;
    mTabela.BuscaPorNome('COD_CONDICAO_PAGTO').Equivalente := 'CDCONDPAGTO';
    mTabela.BuscaPorNome('COD_CONDICAO_PAGTO').OnBeforeChange := VendaExternaBeforeChange;
    mTabela.BuscaPorNome('COD_TRANSPORTADORA').Equivalente := '';
    mTabela.BuscaPorNome('COD_TRANSPORTADORA').OnBeforeChange := VendaExternaBeforeChange;
    mTabela.BuscaPorNome('ENDERECO').Equivalente := 'ENDERECO';
    mTabela.BuscaPorNome('NUMERO').Equivalente := 'NRENDERECO';
    mTabela.BuscaPorNome('BAIRRO').Equivalente := 'BAIRRO';
    mTabela.BuscaPorNome('REFERENCIA').Equivalente := 'PONTOREFERENCIA';
    mTabela.BuscaPorNome('CEP').Equivalente := 'CEP';
    mTabela.BuscaPorNome('DT_PREVISAO').Equivalente := '';
    mTabela.BuscaPorNome('HR_INICIAL').Equivalente := '';
    mTabela.BuscaPorNome('HR_FINAL').Equivalente := '';
    mTabela.BuscaPorNome('TP_MODALIDADE_FRETE').Equivalente := 'MODALIDADETRANSPORTE';
    mTabela.BuscaPorNome('OBSERVACAO_ENTREGA').Equivalente := 'OBSENTREGA';
    mTabela.BuscaPorNome('OBSERVACAO').Equivalente := 'OBSORCA;OBSERVACAO1;OBSERVACAO2;OBSERVACAO3;OBSINDUSTRIA;MOTIVODESBLOQUEIO';
    mTabela.BuscaPorNome('ST_VENDA').Equivalente := '';
    mTabela.BuscaPorNome('ST_VENDA').OnBeforeChange := VendaExternaBeforeChange;
    mTabela.BuscaPorNome('COD_FUNCIONARIO_STATUS').Equivalente := '';
    mTabela.BuscaPorNome('COD_FUNCIONARIO_STATUS').OnBeforeChange := VendaExternaBeforeChange;
    mTabela.BuscaPorNome('DH_STATUS').Equivalente := 'DTALTERACAO';
    mTabela.BuscaPorNome('DH_INCLUSAO').Equivalente := 'DHGRAVACAO';
    mTabela.BuscaPorNome('DH_INCLUSAO').ValorDefault:= Now;
    mTabela.BuscaPorNome('VL_TOTAL').Equivalente := 'VRTOTALPRODUTOS';
    mTabela.BuscaPorNome('VL_TOTAL_PENDENTE').Equivalente := 'VRTOTALPRODUTOS';
    mTabela.BuscaPorNome('GUID').Equivalente := '';
    mTabela.BuscaPorNome('COD_CONTA').Equivalente := '';
    mTabela.BuscaPorNome('COD_CONTA').ValorDefault := 1;
    mTabela.BuscaPorNome('VL_FRETE').Equivalente := 'VRFRETE';
    mTabela.BuscaPorNome('PESO').ValorDefault := 'PESOBRUTO';
    mTabela.BuscaPorNome('COD_ATENDIMENTO').Equivalente := '';

    mTabela.BufferArrayDML(fdqoLer, fdqdGravar);
    fdtdGravar.Commit;

    if not fdtdGravar.Active then
      fdtdGravar.StartTransaction;

    mTabela2 := MontaTabela('VENDA_PRODUTO_EXTERNO', fdqdGravar);
    AbreOrigem(fdqoLer2, 'SELECT I.* FROM CPED P INNER JOIN IPED I ON I.NRPEDIDO = P.NRPEDIDO WHERE P.TIPO IN (''O'',''P'')');
//    AbreOrigem(fdqdLer, 'SELECT COD_VENDA,DOCUMENTO,SERIE,CHAVE_NFE FROM VENDA');

    ID := 0;
    IniciaProgressBar(fdqoLer2.RecordCount);
    mTabela2.OnIncProgressBar := IncProgressBar;
    mTabela2.OnMensagem := Mensagem;

    mTabela2.BuscaPorNome('COD_VENDA_PRODUTO_EXTERNO').Equivalente := '';
    mTabela2.BuscaPorNome('COD_VENDA_PRODUTO_EXTERNO').OnBeforeChange := VendaExternaProdutoBeforeChange;
    mTabela2.BuscaPorNome('COD_VENDA_EXTERNO').Equivalente := 'NRPEDIDO';
    mTabela2.BuscaPorNome('COD_VENDA_EXTERNO').OnBeforeChange := VendaExternaProdutoBeforeChange;
    mTabela2.BuscaPorNome('COD_PRODUTO').Equivalente := 'CODPROD';
    mTabela2.BuscaPorNome('QTDE').Equivalente := 'QTDE';
    mTabela2.BuscaPorNome('VL_UNITARIO').Equivalente := 'VRUNITARIO';
    mTabela2.BuscaPorNome('VL_DESCONTO').Equivalente := 'DESCONTO';
    mTabela2.BuscaPorNome('VL_ACRESCIMO').Equivalente := 'ACRESCIMO';
    mTabela2.BuscaPorNome('VL_TOTAL').Equivalente := '';
    mTabela2.BuscaPorNome('VL_TOTAL').OnBeforeChange:= VendaExternaProdutoBeforeChange;
    mTabela2.BuscaPorNome('OBSERVACAO').Equivalente := 'COMPLEMENTO';
    mTabela2.BuscaPorNome('QTDE_GERADO').Equivalente := '';
    mTabela2.BuscaPorNome('QTDE_GERADO').ValorDefault := 0;
    mTabela2.BuscaPorNome('VL_PENDENTE').Equivalente := '';
    mTabela2.BuscaPorNome('VL_PENDENTE').OnBeforeChange:= VendaExternaProdutoBeforeChange;

    mTabela2.BufferArrayDML(fdqoLer2, fdqdGravar);
    fdtdGravar.Commit;
  finally
    if fdtdGravar.Active then
      fdtdGravar.Rollback;
  end;
end;

procedure TfrmPrincipal.VendaExternaBeforeChange(const ACampoOrigem,
  ACampoDestino: string; var AValor: Variant);
var mCpfCnpj: string;
begin
  if (ACampoDestino.ToUpper = 'COD_CLIENTE') then
  begin
    if not fdqdLer.Locate('COD_PESSOA', fdqoLer.FieldByName('CLIENTE').AsInteger) then
      AValor := cCodPessoaPadrao;
  end
  else
  if (ACampoDestino.ToUpper = 'COD_FUNCIONARIO') then
  begin
    if fdqdLer.Locate('COD_TRANSFERENCIA', fdqoLer.FieldByName('VENDEDOR').AsInteger) then
      AValor := fdqdLer.FieldByName('COD_PESSOA').AsInteger;
  end
  else
  if (ACampoDestino.ToUpper = 'COD_CONDICAO_PAGTO') then
  begin
    if not fdqdLer2.Locate('COD_CONDICAO_PAGTO', fdqoLer.FieldByName('CDCONDPAGTO').AsInteger) then
      AValor := 'AV';
  end
  else
  if (ACampoDestino.ToUpper = 'COD_TRANSPORTADORA') then
  begin
    if fdqdLer3.Locate('COD_MIGRACAO', fdqoLer.FieldByName('TRANSPORTADORA').AsInteger) then
      AValor := fdqdLer3.FieldByName('COD_PESSOA').AsInteger;
  end
  else
  if (ACampoDestino.ToUpper = 'ST_VENDA') then
  begin
    if fdqoLer.FieldByName('MOTIVOBLOQ').AsString.Trim <> '' then
      AValor := 'N'
    else
    if fdqoLer.FieldByName('TIPO').AsString = 'O' then
      AValor := 'P'
    else
    if fdqoLer.FieldByName('TIPO').AsString = 'P' then
      AValor := 'A';
  end
  else
  if ACampoDestino.ToUpper = 'COD_FUNCIONARIO_STATUS' then
  begin
    if fdqdLer4.Locate('fantasia', fdqoLer.FieldByName('usuario').AsString) then
      AValor := fdqdLer4.FieldByName('cod_pessoa').AsInteger;
  end;
end;

procedure TfrmPrincipal.VendaExternaProdutoBeforeChange(const ACampoOrigem,
  ACampoDestino: string; var AValor: Variant);
begin
  if (ACampoDestino.ToUpper = 'COD_VENDA_PRODUTO_EXTERNO') then
  begin
    Inc(ID);
    AValor := ID;
  end
  else
  if (ACampoDestino.ToUpper = 'VL_TOTAL') then
  begin
    AValor := (fdqoLer2.FieldByName('QTDE').AsCurrency *
      fdqoLer2.FieldByName('VRUNITARIO').AsCurrency) -
      fdqoLer2.FieldByName('DESCONTO').AsCurrency +
      fdqoLer2.FieldByName('ACRESCIMO').AsCurrency;
  end
  else
  if (ACampoDestino.ToUpper = 'VL_PENDENTE') then
  begin
    AValor := (fdqoLer2.FieldByName('QTDE').AsCurrency *
      fdqoLer2.FieldByName('VRUNITARIO').AsCurrency) -
      fdqoLer2.FieldByName('DESCONTO').AsCurrency +
      fdqoLer2.FieldByName('ACRESCIMO').AsCurrency;
  end;
//  else
//  if (ACampoDestino.ToUpper = 'COD_VENDA') then
//  begin
//    if fdqdLer.Locate('DOCUMENTO;SERIE', VarArrayOf([fdqoLer2.FieldByName('NRNFCF').AsInteger,fdqoLer2.FieldByName('SERIE').AsString])) then
//      AValor := fdqdLer.FieldByName('COD_VENDA').AsInteger;
//  end;
end;

procedure TfrmPrincipal.VendaProdutoBeforeChange(const ACampoOrigem,
  ACampoDestino: string; var AValor: Variant);
begin
  if (ACampoDestino.ToUpper = 'COD_VENDA_PRODUTO') then
  begin
    Inc(ID);
    AValor := ID;
  end
  else
  if (ACampoDestino.ToUpper = 'COD_VENDA') then
  begin
    if fdqdLer.Locate('DOCUMENTO;SERIE', VarArrayOf([fdqoLer2.FieldByName('NRNFCF').AsInteger,fdqoLer2.FieldByName('SERIE').AsString])) then
      AValor := fdqdLer.FieldByName('COD_VENDA').AsInteger;
  end;
end;

procedure TfrmPrincipal.VendaProdutoValidar(const AOrigem: TFDQuery;
  var APodeMigrar: Boolean);
begin
  APodeMigrar := fdqdLer.Locate('DOCUMENTO;SERIE',
    VarArrayOf([fdqoLer2.FieldByName('NRNFCF').AsInteger,
                fdqoLer2.FieldByName('SERIE').AsString]));

  if not APodeMigrar then
    Mensagem('VENDA_PRODUTO', fdqoLer2.FieldByName('NRNFCF').AsString + '-' +
                              fdqoLer2.FieldByName('SERIE').AsString +
                              ': não encontrato...');
end;

procedure TfrmPrincipal.Vendas;
var mTabela, mTabela2: TCampos;
begin
  if not fdtdGravar.Active then
    fdtdGravar.StartTransaction;

  try
    Mensagem('CONDICAO_PAGTO', 'DELETANDO');
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('DELETE FROM CONDICAO_PAGTO WHERE COD_CONDICAO_PAGTO NOT IN (''AV'',''30D'')');
    fdqdGravar.ExecSQL;

    Mensagem('VENDA_PRODUTO', 'DELETANDO');
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('DELETE FROM VENDA_PRODUTO');
    fdqdGravar.ExecSQL;

    Mensagem('VENDA', 'DELETANDO');
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('DELETE FROM VENDA');
    fdqdGravar.ExecSQL;

    mTabela := MontaTabela('CONDICAO_PAGTO', fdqdGravar);
    AbreOrigem(fdqoLer, 'SELECT * FROM TABCONDPAGTO');

    ID := 0;
    IniciaProgressBar(fdqoLer.RecordCount);
    mTabela.OnIncProgressBar := IncProgressBar;
    mTabela.OnMensagem := Mensagem;

    mTabela.BuscaPorNome('COD_CONDICAO_PAGTO').Equivalente := 'CDCONDPAGTO';
    mTabela.BuscaPorNome('DESCRICAO').Equivalente := 'DSCONDPAGTO';
    mTabela.BuscaPorNome('DIA_PARCELA1').Equivalente := '';
    mTabela.BuscaPorNome('DIA_PARCELA1').OnBeforeChange := CondPagtoBeforeChange;
    mTabela.BuscaPorNome('DIAS_PARCELA').Equivalente := '';
    mTabela.BuscaPorNome('DIAS_PARCELA').OnBeforeChange := CondPagtoBeforeChange;
    mTabela.BuscaPorNome('QTDE_PARCELA').Equivalente := 'QTPARCELAS';
    mTabela.BuscaPorNome('QTDE_PARCELA').ValorDefault := 1;
    mTabela.BuscaPorNome('PRAZO_VISTA').Equivalente := '';
    mTabela.BuscaPorNome('PRAZO_VISTA').OnBeforeChange := CondPagtoBeforeChange;
    mTabela.BuscaPorNome('PE_VALOR').Equivalente := '';
    mTabela.BuscaPorNome('SN_BAIXA_PRIMEIRA').Equivalente := '';
    mTabela.BuscaPorNome('SN_BAIXA_PRIMEIRA').OnBeforeChange := CondPagtoBeforeChange;
    mTabela.BuscaPorNome('SN_PARCELA_ENTRADA').Equivalente := '';
    mTabela.BuscaPorNome('QTDE_PARCELAMENTO_ENTRADA').Equivalente := '';
    mTabela.BuscaPorNome('SN_VENCIMENTO_ATRASADO').Equivalente := '';
    mTabela.BuscaPorNome('SN_VENCIMENTO_ATRASADO').ValorDefault := 'N';
    mTabela.BuscaPorNome('PE_REAJUSTE').Equivalente := '';
    mTabela.BuscaPorNome('SN_OUTROS').Equivalente := '';
    mTabela.BuscaPorNome('SN_OUTROS').ValorDefault := 'N';
    mTabela.BuscaPorNome('TP_PAGTO').Equivalente := '';
    mTabela.BuscaPorNome('SN_PRAZO').Equivalente := '';
    mTabela.BuscaPorNome('DIA_VENCIMENTO').Equivalente := '';
    mTabela.BuscaPorNome('ST_USO').Equivalente := '';
    mTabela.BuscaPorNome('SN_ALTERA_DESCONTO').Equivalente := '';
    mTabela.BuscaPorNome('SN_VENCIMENTO_MENSAL').Equivalente := '';
    mTabela.BuscaPorNome('ST_PAGAMENTO').Equivalente := '';
    mTabela.BuscaPorNome('COD_USUARIO_INCLUSAO').Equivalente := '';
    mTabela.BuscaPorNome('COD_USUARIO_INCLUSAO').ValorDefault := cCodPessoaPadrao;
    mTabela.BuscaPorNome('DH_INCLUSAO').Equivalente := '';
    mTabela.BuscaPorNome('DH_INCLUSAO').ValorDefault := Now;

    mTabela.BufferArrayDML(fdqoLer, fdqdGravar);
    fdtdGravar.Commit;

    if not fdtdGravar.Active then
      fdtdGravar.StartTransaction;

    mTabela := MontaTabela('VENDA', fdqdGravar);
    AbreOrigem(fdqoLer, 'SELECT CNF.*,CAST(CNF.OBSPEDIDO AS VARCHAR(20240)) OBS,N.NATUREZA FROM CNF  LEFT OUTER JOIN NATOPERACAO N ON N.CODIGO = CNF.NATOPERACAO');
    AbreOrigem(fdqdLer, 'SELECT P.COD_PESSOA,P.COD_TRANSFERENCIA,P.COD_MIGRACAO '+#13+
                        '  FROM PESSOA P '+#13+
                        ' WHERE NOT EXISTS (SELECT F.COD_PESSOA FROM FORNECEDOR F WHERE F.COD_PESSOA = P.COD_PESSOA)');
    AbreOrigem(fdqdLer2, 'SELECT COD_CONDICAO_PAGTO FROM CONDICAO_PAGTO');
    AbreOrigem(fdqdLer3, 'SELECT COD_PESSOA,COD_MIGRACAO FROM PESSOA WHERE COD_MIGRACAO IS NOT NULL');

    ID := 0;
    IniciaProgressBar(fdqoLer.RecordCount);
    mTabela.OnIncProgressBar := IncProgressBar;
    mTabela.OnMensagem := Mensagem;

    mTabela.BuscaPorNome('COD_VENDA').Equivalente := '';
    mTabela.BuscaPorNome('COD_VENDA').OnBeforeChange := VendaBeforeChange;
    mTabela.BuscaPorNome('COD_EMPRESA').Equivalente := 'EMPRESA';
    mTabela.BuscaPorNome('COD_EMPRESA').ValorDefault := 1;
    mTabela.BuscaPorNome('TIPO_DOCUMENTO').Equivalente := 'TIPODOC';
    mTabela.BuscaPorNome('TIPO_DOCUMENTO').ValorDefault := 'N';
    mTabela.BuscaPorNome('DOCUMENTO').Equivalente := 'NRNFCF';
    mTabela.BuscaPorNome('SERIE').Equivalente := 'SERIE';
    mTabela.BuscaPorNome('DT_EMISSAO').Equivalente := 'DATA';
    mTabela.BuscaPorNome('DT_SAIDA').Equivalente := 'DATASAIDA';
    mTabela.BuscaPorNome('HR_SAIDA').Equivalente := '';
    mTabela.BuscaPorNome('COD_CLIENTE').Equivalente := 'CLIENTE';
    mTabela.BuscaPorNome('COD_CLIENTE').OnBeforeChange := VendaBeforeChange;
    mTabela.BuscaPorNome('COD_FUNCIONARIO').Equivalente := '';
    mTabela.BuscaPorNome('COD_FUNCIONARIO').OnBeforeChange := VendaBeforeChange;
    mTabela.BuscaPorNome('COD_FUNCIONARIO').ValorDefault := cCodPessoaPadrao;
    mTabela.BuscaPorNome('COD_CFOP').Equivalente := 'NATUREZA';
    mTabela.BuscaPorNome('COD_CFOP').ValorDefault := '5101';
    mTabela.BuscaPorNome('COD_CFOP').StrSoNumero := True;
    mTabela.BuscaPorNome('COD_REGRA').Equivalente := '';
    mTabela.BuscaPorNome('COD_REGRA').ValorDefault := 1;
    mTabela.BuscaPorNome('COD_CONDICAO_PAGTO').Equivalente := 'CDCONDPAGTO';
    mTabela.BuscaPorNome('COD_CONDICAO_PAGTO').OnBeforeChange := VendaBeforeChange;
//    mTabela.BuscaPorNome('COD_CONDICAO_PAGTO').ValorDefault := 'AV';
    mTabela.BuscaPorNome('VL_ICMS_BASE').Equivalente := 'VRBASEICMS';
    mTabela.BuscaPorNome('VL_ICMS').Equivalente := 'VRICMS';
    mTabela.BuscaPorNome('VL_ICMS_BASE_SUBST').Equivalente := 'VRBASESUBST';
    mTabela.BuscaPorNome('VL_ICMS_SUBST').Equivalente := 'VRSUBST';
    mTabela.BuscaPorNome('VL_FRETE').Equivalente := 'VRFRETE';
    mTabela.BuscaPorNome('VL_PRODUTO').Equivalente := 'VRTOTALPRODUTOS';
    mTabela.BuscaPorNome('VL_SEGURO').Equivalente := 'VRSEGURO';
    mTabela.BuscaPorNome('VL_OUTROS').Equivalente := '';
    mTabela.BuscaPorNome('VL_OUTROS').ValorDefault := 0;
    mTabela.BuscaPorNome('VL_IPI').Equivalente := 'VRIPI';
    mTabela.BuscaPorNome('VL_PIS').Equivalente := 'VRPIS';
    mTabela.BuscaPorNome('VL_COFINS').Equivalente := 'VRCOFINS';
    mTabela.BuscaPorNome('VL_PIS_SUBST').Equivalente := '';
    mTabela.BuscaPorNome('VL_COFINS_SUBST').Equivalente := '';
    mTabela.BuscaPorNome('VL_CREDITO').Equivalente := '';
    mTabela.BuscaPorNome('VL_DESCONTO_ACRESCIMO').Equivalente := '';
    mTabela.BuscaPorNome('VL_TOTAL').Equivalente := 'VRNOTAFISCAL';
    mTabela.BuscaPorNome('OBS').Equivalente := 'NRCONHECIMENTOFRETE;OBSERVACAO;OBSERVACAO2;OBSERVACAO3;OBSERVACAO4;OBSERVACAO5;OBSERVACAO6;OBS;LOCALENTREGA';
    mTabela.BuscaPorNome('CPF_CNPJ').Equivalente := 'CONSUMIDOR_CPF';
    mTabela.BuscaPorNome('COD_ECF').Equivalente := '';
    mTabela.BuscaPorNome('CCF').Equivalente := 'NUMERO_ECF';
    mTabela.BuscaPorNome('SN_TRANSFERENCIA').Equivalente := '';
    mTabela.BuscaPorNome('SN_TRANSFERENCIA').ValorDefault := 'I';
    mTabela.BuscaPorNome('PESO_BRUTO').Equivalente := 'PESOBRUTO';
    mTabela.BuscaPorNome('PESO_LIQUIDO').Equivalente := 'PESOLIQ';
    mTabela.BuscaPorNome('ST_FRETE').Equivalente := '';
    mTabela.BuscaPorNome('CHAVE_NFE').Equivalente := 'PROTCHNFE';
    mTabela.BuscaPorNome('PLACA').Equivalente := 'PLACAVEICULO';
    mTabela.BuscaPorNome('COD_CUPOM_VINC').Equivalente := '';
    mTabela.BuscaPorNome('ST_MODELONF').Equivalente := '';
    mTabela.BuscaPorNome('VL_CREDITO_ICMS').Equivalente := '';
    mTabela.BuscaPorNome('COD_VEICULO').Equivalente := '';
    mTabela.BuscaPorNome('VL_ENTRADA').Equivalente := '';
    mTabela.BuscaPorNome('QUADRA').Equivalente := '';
    mTabela.BuscaPorNome('LOTE').Equivalente := '';
    mTabela.BuscaPorNome('UF_PLACA').Equivalente := 'UFPLACA';
    mTabela.BuscaPorNome('PLACA_TRANSP').Equivalente := '';
    mTabela.BuscaPorNome('COD_TRANSPORTADOR').Equivalente := '';
    mTabela.BuscaPorNome('COD_TRANSPORTADOR').OnBeforeChange := VendaBeforeChange;
    mTabela.BuscaPorNome('MOD_FRETE').Equivalente := 'FRETECONTA';
    mTabela.BuscaPorNome('VOLUMES').Equivalente := 'VOLUMES';
    mTabela.BuscaPorNome('ESP_CARGA').Equivalente := 'CARGA';
    mTabela.BuscaPorNome('DT_VENCIMENTO_FRETE').Equivalente := '';
    mTabela.BuscaPorNome('DI_NUMERO').Equivalente := '';
    mTabela.BuscaPorNome('DI_DATA_IMPORTACAO').Equivalente := '';
    mTabela.BuscaPorNome('DI_LOCAL_DE').Equivalente := '';
    mTabela.BuscaPorNome('DI_UF_DE').Equivalente := '';
    mTabela.BuscaPorNome('DI_DATA_DE').Equivalente := '';
    mTabela.BuscaPorNome('DI_EXPORTADOR').Equivalente := '';
    mTabela.BuscaPorNome('DI_FABRICANTE').Equivalente := '';
    mTabela.BuscaPorNome('VL_II').Equivalente := '';
    mTabela.BuscaPorNome('VL_II').ValorDefault := 0;
    mTabela.BuscaPorNome('VL_COMISSAO').Equivalente := 'VRCOMISSAO';
    mTabela.BuscaPorNome('COD_CONTA').Equivalente := '';
    mTabela.BuscaPorNome('COD_CONTA').ValorDefault := 1;
    mTabela.BuscaPorNome('SN_GERADO').Equivalente := '';
    mTabela.BuscaPorNome('SN_GERADO').ValorDefault := 'N';
//    mTabela.BuscaPorNome('CHAVE_NFE_REF').Equivalente := '';
    mTabela.BuscaPorNome('COD_SAT').Equivalente := '';
    mTabela.BuscaPorNome('ST_VENDA').Equivalente := '';
    mTabela.BuscaPorNome('ST_VENDA').ValorDefault := 'V';
    mTabela.BuscaPorNome('VL_ACRESCIMO').Equivalente := 'VRACRESCIMO';
    mTabela.BuscaPorNome('ST_ORIGEM').Equivalente := '';
    mTabela.BuscaPorNome('EXTRAS').Equivalente := '';
    mTabela.BuscaPorNome('VL_FCP').Equivalente := '';
    mTabela.BuscaPorNome('VL_DIFAL_DEST').Equivalente := '';
    mTabela.BuscaPorNome('VL_DIFAL_ORIG').Equivalente := '';
    mTabela.BuscaPorNome('SN_CONSUMIDOR').Equivalente := '';
    mTabela.BuscaPorNome('COD_VENDA_DESTINO').Equivalente := '';
    mTabela.BuscaPorNome('VL_TOTAL_FUNRURAL').Equivalente := '';
    mTabela.BuscaPorNome('PE_FUNRURAL').Equivalente := '';
    mTabela.BuscaPorNome('COD_CONDICIONAL').Equivalente := '';
    mTabela.BuscaPorNome('COD_AGREGADO').Equivalente := '';
    mTabela.BuscaPorNome('TP_FINALIDADE_NOTA').Equivalente := '';
    mTabela.BuscaPorNome('TP_FINALIDADE_NOTA').ValorDefault := 'N';
    mTabela.BuscaPorNome('CCF_REF').Equivalente := '';
    mTabela.BuscaPorNome('SEQUENCIA_ECF_REF').Equivalente := '';
    mTabela.BuscaPorNome('MARCA').Equivalente := '';
    mTabela.BuscaPorNome('SN_TROCA').Equivalente := '';
    mTabela.BuscaPorNome('SN_TROCA').ValorDefault := 'N';
    mTabela.BuscaPorNome('COD_VENDA_ORIGEM').Equivalente := '';
    mTabela.BuscaPorNome('SN_SAT_ENVIADO').Equivalente := '';
    mTabela.BuscaPorNome('SN_SAT_ENVIADO').ValorDefault := 'N';
    mTabela.BuscaPorNome('COD_ERRO_SAT').Equivalente := '';
    mTabela.BuscaPorNome('VL_DESCONTO_RATEADO').Equivalente := '';
    mTabela.BuscaPorNome('VL_CREDITO_GERADO').Equivalente := '';
    mTabela.BuscaPorNome('NO_SENHA').Equivalente := '';
    mTabela.BuscaPorNome('SN_FATURADO').Equivalente := '';
    mTabela.BuscaPorNome('SN_FATURADO').ValorDefault := 'S';
    mTabela.BuscaPorNome('COD_ENTREGADOR').Equivalente := '';
    mTabela.BuscaPorNome('TP_INDICADOR_PRESENCA').Equivalente := '';
    mTabela.BuscaPorNome('VL_IPI_DEVOLUCAO').Equivalente := '';
    mTabela.BuscaPorNome('PE_CARGA_MEDIA').Equivalente := '';
    mTabela.BuscaPorNome('SN_NOTA_OFFLINE').Equivalente := '';
    mTabela.BuscaPorNome('SN_NOTA_OFFLINE').ValorDefault := 'N';
    mTabela.BuscaPorNome('COD_NFSE').Equivalente := '';
    mTabela.BuscaPorNome('VL_DESCONTO').Equivalente := 'VRDESCONTO';
    mTabela.BuscaPorNome('DH_INCLUSAO').Equivalente := '';
    mTabela.BuscaPorNome('DH_INCLUSAO').ValorDefault := Now;

    mTabela.BufferArrayDML(fdqoLer, fdqdGravar);
    fdtdGravar.Commit;

    if not fdtdGravar.Active then
      fdtdGravar.StartTransaction;

    mTabela2 := MontaTabela('VENDA_PRODUTO', fdqdGravar);
    AbreOrigem(fdqoLer2, 'SELECT * FROM INF I LEFT OUTER JOIN NATOPERACAO N ON N.CODIGO = I.NATOPERACAO');
    AbreOrigem(fdqdLer, 'SELECT COD_VENDA,DOCUMENTO,SERIE,CHAVE_NFE FROM VENDA');

    ID := 0;
    IniciaProgressBar(fdqoLer2.RecordCount);
    mTabela2.OnIncProgressBar := IncProgressBar;
    mTabela2.OnMensagem := Mensagem;
    mTabela2.OnValidarRegistro := VendaProdutoValidar;

    mTabela2.BuscaPorNome('COD_VENDA_PRODUTO').Equivalente := '';
    mTabela2.BuscaPorNome('COD_VENDA_PRODUTO').OnBeforeChange := VendaProdutoBeforeChange;
    mTabela2.BuscaPorNome('COD_VENDA').Equivalente := '';
    mTabela2.BuscaPorNome('COD_VENDA').OnBeforeChange := VendaProdutoBeforeChange;
    mTabela2.BuscaPorNome('COD_PRODUTO').Equivalente := 'CODPROD';
    mTabela2.BuscaPorNome('QTDE').Equivalente := 'QTDE';
    mTabela2.BuscaPorNome('SITUACAO_TRIB').Equivalente := '';
    mTabela2.BuscaPorNome('CSOSN').Equivalente := '';
    mTabela2.BuscaPorNome('COD_CFOP').Equivalente := 'NATUREZA';
    mTabela2.BuscaPorNome('COD_CFOP').StrSoNumero := True;
    mTabela2.BuscaPorNome('IPI_CST').Equivalente := 'IPI_CST';
    mTabela2.BuscaPorNome('COFINS_CST').Equivalente := 'COFINS_CST';
    mTabela2.BuscaPorNome('VL_CUSTO').Equivalente := 'CUSTO';
    mTabela2.BuscaPorNome('VL_PIS').Equivalente := 'VRPISRETIDO';
    mTabela2.BuscaPorNome('VL_PIS_BASE').Equivalente := 'PIS_BASECALCULO';
    mTabela2.BuscaPorNome('VL_COFINS').Equivalente := 'VRCOFINSRETIDO';
    mTabela2.BuscaPorNome('VL_COFINS_BASE').Equivalente := 'COFINS_BASECALCULO';
    mTabela2.BuscaPorNome('PE_REDUCAO_ICMS').Equivalente := 'REDUCAO';
    mTabela2.BuscaPorNome('PE_REDUCAO_ICMS_SUBST').Equivalente := 'REDUCAO';
    mTabela2.BuscaPorNome('VL_ICMS').Equivalente := 'VRICMS';
    mTabela2.BuscaPorNome('VL_ICMS_BASE').Equivalente := 'BASECALCULO';
    mTabela2.BuscaPorNome('VL_ICMS_SUBST').Equivalente := 'VRSUBSTICMS';
    mTabela2.BuscaPorNome('VL_ICMS_BASE_SUBST').Equivalente := '';
    mTabela2.BuscaPorNome('VL_ICMS_ISENTO').Equivalente := '';
    mTabela2.BuscaPorNome('VL_ICMS_OUTRAS').Equivalente := '';
    mTabela2.BuscaPorNome('VL_IPI').Equivalente := 'VRIPI';
    mTabela2.BuscaPorNome('VL_IPI_BASE_CALCULO').Equivalente := 'BASECALCULOIPI';
    mTabela2.BuscaPorNome('VL_FRETE').Equivalente := 'VRFRETE';
    mTabela2.BuscaPorNome('VL_SEGURO').Equivalente := 'VRSEGURO';
    mTabela2.BuscaPorNome('VL_OUTRAS').Equivalente := '';
    mTabela2.BuscaPorNome('PE_PIS_ALIQUOTA').Equivalente := '';
    mTabela2.BuscaPorNome('PE_ICMS').Equivalente := 'ALIQICMS';
    mTabela2.BuscaPorNome('PE_IPI').Equivalente := 'ALIQIPI';
    mTabela2.BuscaPorNome('PE_IVA').Equivalente := '';
    mTabela2.BuscaPorNome('PE_COFINS_ALIQUOTA').Equivalente := '';
    mTabela2.BuscaPorNome('PE_ICMS_SUBST').Equivalente := 'ALIQSUBST';
    mTabela2.BuscaPorNome('VL_UNITARIO').Equivalente := 'VRUNITARIO';
    mTabela2.BuscaPorNome('VL_DESCONTO').Equivalente := 'DESCONTO';
    mTabela2.BuscaPorNome('OBS_PRODUTO').Equivalente := '';
    mTabela2.BuscaPorNome('VL_II').ValorDefault := 0;
    mTabela2.BuscaPorNome('VL_OUTRAS').ValorDefault := 0;

    mTabela2.BufferArrayDML(fdqoLer2, fdqdGravar);
    fdtdGravar.Commit;

    if not fdtdGravar.Active then
      fdtdGravar.StartTransaction;

    FreeAndNil(mTabela2);
    mTabela2 := MontaTabela('NOTA_ELETRONICA', fdqdGravar);
    AbreOrigem(fdqoLer2, 'SELECT N.*,CAST(N.ARQUIVO AS VARCHAR(20480)) XML FROM NFE_ARQUIVOS N WHERE TIPO IN (8,15)');
    AbreOrigem(fdqdLer, 'SELECT COD_VENDA,DOCUMENTO,SERIE,CHAVE_NFE FROM VENDA');

    ID := 0;
    IniciaProgressBar(fdqoLer2.RecordCount);
    mTabela2.OnIncProgressBar := IncProgressBar;
    mTabela2.OnMensagem := Mensagem;
//    mTabela2.OnValidarRegistro := VendaProdutoValidar;

    mTabela2.BuscaPorNome('COD_NOTA_ELETRONICA').Equivalente := 'CODIGO';
    mTabela2.BuscaPorNome('COD_VENDA').Equivalente := '';
    mTabela2.BuscaPorNome('COD_VENDA').OnBeforeChange := NotaEletronicaBeforeChange;
    mTabela2.BuscaPorNome('XML').Equivalente := 'XML';
    mTabela2.BuscaPorNome('TIPO').Equivalente := '';
    mTabela2.BuscaPorNome('TIPO').ValorDefault := 'E';
    mTabela2.BuscaPorNome('NO_SEQUENCIA').Equivalente := '';
    mTabela2.BuscaPorNome('NO_SEQUENCIA').ValorDefault := 1;
    mTabela2.BuscaPorNome('ST_NOTA').ValorDefault := 'N';
    mTabela2.BuscaPorNome('CHAVE_NFE').Equivalente := 'CHNFE';
//    mTabela2.BuscaPorNome('CHAVE_NFE').OnBeforeChange := NotaEletronicaBeforeChange;
    mTabela2.BuscaPorNome('DH_INCLUSAO').Equivalente := 'DATAHORA';

    mTabela2.BufferArrayDML(fdqoLer2, fdqdGravar);
    fdtdGravar.Commit;

    Mensagem('VENDA_PRODUTO', 'NCM');
    fdtdGravar.StartTransaction;
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('MERGE');
    fdqdGravar.SQL.Add('INTO VENDA_PRODUTO C');
    fdqdGravar.SQL.Add('USING (SELECT P.COD_PRODUTO,P.COD_CLASS_FISCAL');
    fdqdGravar.SQL.Add('         FROM PRODUTO P');
    fdqdGravar.SQL.Add('        INNER JOIN CLASS_FISCAL F');
    fdqdGravar.SQL.Add('           ON F.COD_CLASS_FISCAL = P.COD_CLASS_FISCAL) P');
    fdqdGravar.SQL.Add('ON (C.COD_PRODUTO = P.COD_PRODUTO) AND (C.COD_CLASS_FISCAL IS NULL)');
    fdqdGravar.SQL.Add('WHEN MATCHED THEN');
    fdqdGravar.SQL.Add('UPDATE SET');
    fdqdGravar.SQL.Add('COD_CLASS_FISCAL = P.COD_CLASS_FISCAL');
    fdqdGravar.ExecSQL;
    fdtdGravar.Commit;
  finally
    if fdtdGravar.Active then
      fdtdGravar.Rollback;
  end;
end;

procedure TfrmPrincipal.VoltarClientes;
begin
  if not fdtdGravar.Active then
    fdtdGravar.StartTransaction;
  try
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('UPDATE PESSOA SET COD_PESSOA = (SELECT MAX(COD_PESSOA) +1 FROM PESSOA) WHERE COD_PESSOA < 0');
    fdqdGravar.ExecSQL;

    fdtdGravar.Commit;
  finally
    if fdtdGravar.Active then
      fdtdGravar.Rollback;
  end;
end;

procedure TfrmPrincipal.ZerarClientes;
begin
  if not fdtdGravar.Active then
    fdtdGravar.StartTransaction;
  try
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('UPDATE PESSOA SET COD_PESSOA = COD_PESSOA * -1 WHERE COD_PESSOA > 0');
    fdqdGravar.ExecSQL;

    fdtdGravar.Commit;
  finally
    if fdtdGravar.Active then
      fdtdGravar.Rollback;
  end;
end;

{ TCampos }

procedure TCampos.BufferArrayDML(AOrigem, ADestino: TFDQuery);
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

    if Assigned(fsOnValidarRegistro) then
      fsOnValidarRegistro(AOrigem, mPodeMigrar);

    if mPodeMigrar then
    begin
      Inc(i);
      for x := 0 to Count -1 do
      begin
        mValor := Items[x].getValor(AOrigem);

        if not Items[x].PermiteNulo then
        begin
          if VarIsNull(mValor) then
          begin
            if Assigned(fsOnMensagem) then
              fsOnMensagem(fsTabela, 'Row ' + (i +1).ToString + ' | ' + Items[x].Nome + ' IS NULL');
            Abort;
          end;
        end;

        if not VarIsNull(mValor) then
        begin
          case Items[x].Tipo of
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

    if Assigned(fsOnIncProgressBar) then
      fsOnIncProgressBar(i +1);

    AOrigem.Next;
  end;

  //ADestino.Execute(AOrigem.RecordCount);
  ADestino.Params.ArraySize := i +1;
  ADestino.Execute(i +1);

  if Assigned(fsOnMensagem) then
  begin
    fsOnMensagem(fsTabela, 'Concluído | ' + FormatDateTime('hh:nn:ss', Now - Inicio));
    Sleep(500);
  end;
end;

function TCampos.BuscaPorNome(ANome: string): TCampo;
var i: Integer;
begin
  Result := nil;
  for i := 0 to Count -1 do
  begin
    if Items[i].Nome.ToUpper = ANome.ToUpper then
    begin
      Result := Items[i];
      Break;
    end;
  end;

  if Result = nil then
    raise Exception.Create('Campo ' + ANome + ' não encontrado...');
end;

function TCampos.GetItems(Index: Integer): TCampo;
begin
  Result := TCampo(inherited Items[Index]);
end;

function TCampos.Novo: TCampo;
begin
  Result := TCampo.Create;
  inherited Add(Result);
end;

procedure TCampos.SetItems(Index: Integer; const Value: TCampo);
begin
  Put(Index, Value);
end;

{ TCampo }

constructor TCampo.Create;
begin
  inherited Create;
  fsTipo := ctNaoDefinido;
  fsPermiteNulo := False;
  fsValordefault := Null;
  fsStrSoNumero := False;
  fsStrUpper := True;
  FIgnorarZero := False;
end;

function TCampo.getValor(ATabela: TFDQuery): Variant;
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

class function TCampo.SoNumero(Str: String): String;
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

class function TCampo.SoNumeroVirgula(Str: String): String;
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

end.
