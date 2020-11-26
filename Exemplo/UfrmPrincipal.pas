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
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    procedure Mensagem(const ATabela, AMsg: string);
    procedure IniciaProgressBar(AMax: Integer);
    procedure IncProgressBar(const APosicao: Integer);

    procedure Produtos;
  protected
    ID: Integer;
    mAuxiliar: TStringList;
    procedure ProdutoCampoBeforeChange(const ACampoOrigem, ACampoDestino: string;
      var AValor: Variant);
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

uses
  DevAll.Migracao;

{$R *.dfm}

{ TForm1 }

procedure TfrmPrincipal.BitBtn1Click(Sender: TObject);
begin
  fdOrigem.Connected := False;
  fdOrigem.Connected := True;

  fdDestino.Connected := False;
  fdDestino.Connected := True;

  try
//    if chkClientes.Checked then
//      Pessoas;

    if chkProdutos.Checked then
      Produtos;

//    if chkCompras.Checked then
//      Compras;

//    if chkVendas.Checked then
//      Vendas;

//    if chkFinanceiro.Checked then
//      Financeiro;

//    if chkAtendimento.Checked then
//      Atendimento;

//    if chkVendaExterna.Checked then
//      VendaExterna;

  finally
    fdOrigem.Connected := False;
    fdDestino.Connected := False;
  end;
end;

procedure TfrmPrincipal.BitBtn2Click(Sender: TObject);
begin
  Memo1.Lines.Clear;
  TCampos.AbreOrigem(fdqoLer, 'select distinct RDB$RELATION_NAME tabela from rdb$relation_fields');
  fdqoLer.First;
  while not fdqoLer.Eof do
  begin
    TCampos.AbreOrigem(fdqoLer2, 'select count(1) from ' + fdqoLer.FieldByName('tabela').AsString);
    if fdqoLer2.Fields[0].AsInteger > 100 then
      Memo1.Lines.Add(FormatFloat('000000000', fdqoLer2.Fields[0].AsInteger) + ' ' + fdqoLer.FieldByName('tabela').AsString);
    fdqoLer.Next;
  end;
  ShowMessage(Memo1.Lines.Count.ToString);
end;

procedure TfrmPrincipal.BitBtn3Click(Sender: TObject);
begin
  Memo1.Lines.Clear;
  TCampos.AbreOrigem(fdqoLer, 'select distinct RDB$RELATION_NAME tabela from rdb$relation_fields');
  fdqoLer.First;
  while not fdqoLer.Eof do
  begin
    TCampos.AbreOrigem(fdqoLer2, 'select RDB$FIELD_NAME from rdb$relation_fields '+#13+
                         ' where RDB$RELATION_NAME = '''+ fdqoLer.FieldByName('tabela').AsString +''''+#13+
                         '   AND RDB$FIELD_NAME LIKE ''%'+ UpperCase(Edit1.Text) +'%''');
    if not fdqoLer2.IsEmpty then
      Memo1.Lines.Add(fdqoLer.FieldByName('tabela').AsString);
    fdqoLer.Next;
  end;
  ShowMessage(Memo1.Lines.Count.ToString);
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

procedure TfrmPrincipal.Mensagem(const ATabela, AMsg: string);
begin
  Memo1.Lines.Add(FormatDateTime('dd/mm/yy hh:nn:ss', Now) + ' | ' + ATabela + ' | ' + AMsg);
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
var mGrupo, mProdutos: TCampos;
begin
  if not fdtdGravar.Active then
    fdtdGravar.StartTransaction;
  try
    Mensagem('PRODUTO', 'DELETANDO');
    fdqdGravar.Close;
    fdqdGravar.SQL.Clear;
    fdqdGravar.SQL.Add('DELETE FROM PRODUTO');
    fdqdGravar.ExecSQL;

    mGrupo := TCampos.MontaTabela('GRUPO', fdqdGravar);
    TCampos.AbreOrigem(fdqoLer, 'SELECT DEPARTAMENTO,DESCRDEPTO FROM DEPARTAMENTO');

    IniciaProgressBar(fdqoLer.RecordCount);
    mGrupo.OnIncProgressBar := IncProgressBar;
    mGrupo.OnMensagem := Mensagem;

    mGrupo.BuscaPorNome('COD_GRUPO').Equivalente := 'DEPARTAMENTO';
    mGrupo.BuscaPorNome('DESCRICAO').Equivalente := 'DESCRDEPTO';

    mGrupo.BufferArrayDML(fdqoLer, fdqdGravar);

    mProdutos := TCampos.MontaTabela('PRODUTO', fdqdGravar);
    TCampos.AbreOrigem(fdqoLer,
      'SELECT P.*,C.CLASSFISCAL CLASS_FISCAL,T.*,CAST(P.OBSERVACAO AS VARCHAR(2024)) OBS FROM PRODUTO P'+
      '  LEFT OUTER JOIN CLASSFISCAL C '+
      '    ON C.LETRA = P.LCLASSFISCAL '+
      '  LEFT OUTER JOIN TAB00001 T '+
      '    ON T.CODBARRA = P.CODBARRA');

    IniciaProgressBar(fdqoLer.RecordCount);
    mProdutos.OnIncProgressBar := IncProgressBar;
    mProdutos.OnMensagem := Mensagem;

    mProdutos.BuscaPorNome('COD_PRODUTO').Equivalente := 'CODPROD';
    mProdutos.BuscaPorNome('COD_EXTERNO').Equivalente := 'CODBARRA';
    mProdutos.BuscaPorNome('DESCRICAO').Equivalente := 'DESCRICAO';
    mProdutos.BuscaPorNome('COD_MARCA').Equivalente := 'FABRICANTE';
    mProdutos.BuscaPorNome('COD_MARCA').IgnorarZero := True;
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
    fdtdGravar.Commit;
  finally
    if fdtdGravar.Active then
      fdtdGravar.Rollback;
  end;
end;

end.
