object frmPrincipal: TfrmPrincipal
  Left = 0
  Top = 0
  Caption = 'Migra'#231#227'o Default'
  ClientHeight = 542
  ClientWidth = 619
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
    Width = 587
    Height = 33
    Align = alBottom
    Caption = 'MIGRAR'
    TabOrder = 0
    OnClick = BitBtn1Click
  end
  object GroupBox1: TGroupBox
    Left = 16
    Top = 16
    Width = 587
    Height = 57
    Align = alTop
    Caption = ' Tabelas '
    TabOrder = 1
    object chkClientes: TCheckBox
      Left = 32
      Top = 14
      Width = 97
      Height = 17
      Caption = 'Pessoas'
      TabOrder = 0
    end
    object chkProdutos: TCheckBox
      Left = 135
      Top = 14
      Width = 97
      Height = 17
      Caption = 'Produtos'
      TabOrder = 1
    end
    object chkVendas: TCheckBox
      Left = 341
      Top = 14
      Width = 97
      Height = 17
      Caption = 'Vendas'
      TabOrder = 2
    end
    object chkCompras: TCheckBox
      Left = 238
      Top = 14
      Width = 97
      Height = 17
      Caption = 'Compras'
      TabOrder = 3
    end
    object chkFinanceiro: TCheckBox
      Left = 444
      Top = 14
      Width = 97
      Height = 17
      Caption = 'Financeiro'
      TabOrder = 4
    end
    object chkAtendimento: TCheckBox
      Left = 32
      Top = 37
      Width = 97
      Height = 17
      Caption = 'Atendimento'
      TabOrder = 5
    end
    object chkVendaExterna: TCheckBox
      Left = 135
      Top = 37
      Width = 97
      Height = 17
      Caption = 'Venda Externa'
      TabOrder = 6
    end
  end
  object ProgressBar1: TProgressBar
    Left = 16
    Top = 73
    Width = 587
    Height = 32
    Align = alTop
    TabOrder = 2
  end
  object Memo1: TMemo
    Left = 16
    Top = 105
    Width = 587
    Height = 301
    Align = alClient
    Lines.Strings = (
      'Memo1')
    ScrollBars = ssBoth
    TabOrder = 3
  end
  object BitBtn2: TBitBtn
    Left = 16
    Top = 439
    Width = 587
    Height = 33
    Align = alBottom
    Caption = 'Verificar tabelas'
    TabOrder = 4
    OnClick = BitBtn2Click
  end
  object Edit1: TEdit
    Left = 16
    Top = 472
    Width = 587
    Height = 21
    Align = alBottom
    TabOrder = 5
    TextHint = 'Pesquisar por campo em tabela...'
  end
  object BitBtn3: TBitBtn
    Left = 16
    Top = 493
    Width = 587
    Height = 33
    Align = alBottom
    Caption = 'Verificar campo'
    TabOrder = 6
    OnClick = BitBtn3Click
  end
  object fdOrigem: TFDConnection
    Params.Strings = (
      'Database=C:\Transferencia\Dados\ORIGEM.FDB'
      'User_Name=SYSDBA'
      'Password=masterkey'
      'DriverID=FB')
    LoginPrompt = False
    Left = 40
    Top = 8
  end
  object fdtoLer: TFDTransaction
    Connection = fdOrigem
    Left = 40
    Top = 56
  end
  object fdqoLer: TFDQuery
    Connection = fdOrigem
    Transaction = fdtoLer
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    Left = 40
    Top = 104
  end
  object fdqoLer2: TFDQuery
    Connection = fdOrigem
    Transaction = fdtoLer
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    Left = 40
    Top = 152
  end
  object fdDestino: TFDConnection
    Params.Strings = (
      'Database=C:\Transferencia\Dados\DADOS.FDB'
      'User_Name=SYSDBA'
      'Password=masterkey'
      'DriverID=FB')
    LoginPrompt = False
    Left = 520
    Top = 8
  end
  object fdtdGravar: TFDTransaction
    Connection = fdDestino
    Left = 520
    Top = 56
  end
  object fdqdGravar: TFDQuery
    Connection = fdDestino
    Transaction = fdtdGravar
    Left = 520
    Top = 104
  end
  object fdqdGravar2: TFDQuery
    Connection = fdDestino
    Transaction = fdtdGravar
    Left = 520
    Top = 152
  end
  object FDGUIxErrorDialog1: TFDGUIxErrorDialog
    Provider = 'Forms'
    Left = 128
    Top = 24
  end
  object FDGUIxWaitCursor1: TFDGUIxWaitCursor
    Provider = 'Forms'
    Left = 272
    Top = 24
  end
  object FDPhysFBDriverLink1: TFDPhysFBDriverLink
    Left = 400
    Top = 24
  end
  object fdtdLer: TFDTransaction
    Connection = fdDestino
    Left = 568
    Top = 8
  end
  object fdqdLer: TFDQuery
    Connection = fdDestino
    Transaction = fdtdLer
    Left = 568
    Top = 56
  end
  object fdqdLer2: TFDQuery
    Connection = fdDestino
    Transaction = fdtdLer
    Left = 568
    Top = 112
  end
  object fdqdLer3: TFDQuery
    Connection = fdDestino
    Transaction = fdtdLer
    Left = 576
    Top = 160
  end
  object fdOrigemFoto: TFDConnection
    Params.Strings = (
      'Database=D:\Transferencia\Dados\ORIGEM_SDF_FOTO.GDB'
      'User_Name=SYSDBA'
      'Password=masterkey'
      'DriverID=FB')
    LoginPrompt = False
    Left = 144
    Top = 112
  end
  object fdtdFoto: TFDTransaction
    Connection = fdOrigemFoto
    Left = 144
    Top = 160
  end
  object fdqdFoto: TFDQuery
    Connection = fdOrigemFoto
    Transaction = fdtdFoto
    FetchOptions.AssignedValues = [evMode]
    FetchOptions.Mode = fmAll
    Left = 144
    Top = 208
  end
  object cdsFoto: TClientDataSet
    Aggregates = <>
    FieldDefs = <
      item
        Name = 'FOTO'
        DataType = ftBlob
      end>
    IndexDefs = <>
    Params = <>
    StoreDefs = True
    Left = 304
    Top = 280
    object cdsFotoFOTO: TBlobField
      FieldName = 'FOTO'
    end
  end
  object fdqdLer4: TFDQuery
    Connection = fdDestino
    Transaction = fdtdLer
    Left = 576
    Top = 208
  end
end
