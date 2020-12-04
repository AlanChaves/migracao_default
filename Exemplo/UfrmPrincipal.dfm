object frmPrincipal: TfrmPrincipal
  Left = 0
  Top = 0
  Caption = 'Migra'#231#227'o Default'
  ClientHeight = 542
  ClientWidth = 493
  Color = clBtnFace
  DockSite = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Padding.Left = 16
  Padding.Top = 16
  Padding.Right = 16
  Padding.Bottom = 16
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object BitBtn1: TBitBtn
    Left = 16
    Top = 406
    Width = 461
    Height = 33
    Align = alBottom
    Caption = 'MIGRAR'
    TabOrder = 0
    OnClick = BitBtn1Click
    ExplicitWidth = 587
  end
  object ProgressBar1: TProgressBar
    Left = 16
    Top = 16
    Width = 461
    Height = 32
    Align = alTop
    TabOrder = 1
    ExplicitWidth = 587
  end
  object Memo1: TMemo
    Left = 16
    Top = 48
    Width = 461
    Height = 358
    Align = alClient
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssBoth
    TabOrder = 2
    ExplicitWidth = 587
  end
  object BitBtn2: TBitBtn
    Left = 16
    Top = 439
    Width = 461
    Height = 33
    Align = alBottom
    Caption = 'Verificar tabelas'
    TabOrder = 3
    ExplicitWidth = 587
  end
  object Edit1: TEdit
    Left = 16
    Top = 472
    Width = 461
    Height = 21
    Align = alBottom
    TabOrder = 4
    TextHint = 'Pesquisar por campo em tabela...'
    ExplicitWidth = 587
  end
  object BitBtn3: TBitBtn
    Left = 16
    Top = 493
    Width = 461
    Height = 33
    Align = alBottom
    Caption = 'Verificar campo'
    TabOrder = 5
    ExplicitWidth = 587
  end
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    Left = 192
    Top = 152
  end
  object DevAllMigracao1: TDevAllMigracao
    Origem.Caminho = 'C:\Desenvolvimento\Dados\DADOS_OLD.FDB'
    Origem.Driver = FDPhysFBDriverLink1
    Origem.Tabela = 'FORMA_PAGAMENTO'
    Origem.SQL.Strings = (
      'SELECT * FROM FORMA_PAGAMENTO')
    Origem.Usuario = 'SYSDBA'
    Origem.Senha = 'masterkey'
    Destino.Caminho = 'C:\Desenvolvimento\Dados\DADOS.FDB'
    Destino.Driver = FDPhysFBDriverLink1
    Destino.Tabela = 'FORMA_PAGAMENTO'
    Destino.Usuario = 'SYSDBA'
    Destino.Senha = 'masterkey'
    Campos = <
      item
        Nome = 'COD_FORMA_PAGAMENTO'
        Precisao = 0
        Escala = 0
        Tamanho = 0
        PermiteNulo = False
        Equivalente = 'COD_FORMA_PAGAMENTO'
        StrUpper = False
      end
      item
        Nome = 'DESCRICAO'
        Precisao = 0
        Escala = 0
        Tamanho = 0
        PermiteNulo = False
        Equivalente = 'DESCRICAO'
        StrUpper = False
      end>
    OnMensagem = DevAllMigracao1Mensagem
    OnIncProgressBar = DevAllMigracao1IncProgressBar
    Left = 104
    Top = 88
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 80
    Top = 152
  end
end
