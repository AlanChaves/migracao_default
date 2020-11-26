unit DevAll.Migracao;

interface

uses
  System.Classes, System.Contnrs, FireDAC.Comp.Client, System.SysUtils;

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

    class function MontaTabela(ATabela: string; AQuery: TFDQuery): TCampos;
    class procedure AbreOrigem(AQuery: TFDQuery; ASQL: string);
  published
    property OnIncProgressBar: TIncProgressBarEvent read fsOnIncProgressBar write fsOnIncProgressBar;
    property OnMensagem: TMensagemEvent read fsOnMensagem write fsOnMensagem;
    property OnValidarRegistro: TValidarRegistroEvent read fsOnValidarRegistro write fsOnValidarRegistro;
  end;

implementation

uses
  Data.DB, System.Variants;

{ TCampos }

class procedure TCampos.AbreOrigem(AQuery: TFDQuery; ASQL: string);
begin
  AQuery.Close;
  AQuery.SQL.Clear;
  AQuery.SQL.Add(ASQL);
  AQuery.Open;
end;

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

class function TCampos.MontaTabela(ATabela: string; AQuery: TFDQuery): TCampos;
var
  sql, mCampos: string;
  i: Integer;
begin
  Result := TCampos.Create;
  Result.Tabela := ATabela;

//  Mensagem(ATabela, 'MontandoTabela');
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

  AQuery.Close;
  AQuery.SQL.Clear;
  AQuery.SQL.Add(sql);
  AQuery.Open;

  AQuery.First;
  while not AQuery.Eof do
  begin
    with Result.Novo do
    begin
      Nome := AQuery.FieldByName('field_name').AsString;

      if AQuery.FieldByName('FIELD_TYPE_ID').AsInteger in [7,8,16] then
      begin
        if AQuery.FieldByName('FIELD_SUB_TYPE').AsInteger = 0 then
          Tipo := ctInteger
        else
          Tipo := ctNumeric;
      end
      else
      if AQuery.FieldByName('FIELD_TYPE_ID').AsInteger in [10,27] then
        Tipo := ctNumeric
      else
      if (AQuery.FieldByName('FIELD_TYPE_ID').AsInteger in [14,37,40,45]) then
//         (fdqdLer.FieldByName('FIELD_TYPE_ID').AsInteger = 261) then
        Tipo := ctString
      else
      if AQuery.FieldByName('FIELD_TYPE_ID').AsInteger in [12,13,35] then
        Tipo := ctDate
      else
        Tipo := ctNaoDefinido;

      Precisao := 0;
      Escala := 0;
      Tamanho := 0;

      if (AQuery.FieldByName('FIELD_TYPE_ID').AsInteger <> 45) and
         (AQuery.FieldByName('FIELD_TYPE_ID').AsInteger <> 261) then
      begin
        Precisao := AQuery.FieldByName('FIELD_PRECISION').AsInteger;
        Escala := AQuery.FieldByName('FIELD_SCALE').AsInteger;
        Tamanho := AQuery.FieldByName('FIELD_LENGTH').AsInteger;
      end;

      if AQuery.FieldByName('FIELD_NULL').AsString = 'NOT NULL' then
        PermiteNulo := False
      else
        PermiteNulo := True;
    end;
    AQuery.Next;
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
