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
  Datasnap.DBClient, DevAll.Migracao;

const
  cCodPessoaPadrao = 5153;

type
  TfrmPrincipal = class(TForm)
    FDPhysFBDriverLink1: TFDPhysFBDriverLink;
    BitBtn1: TBitBtn;
    ProgressBar1: TProgressBar;
    Memo1: TMemo;
    BitBtn2: TBitBtn;
    Edit1: TEdit;
    BitBtn3: TBitBtn;
    DevAllMigracao1: TDevAllMigracao;
    FDGUIxWaitCursor1: TFDGUIxWaitCursor;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure DevAllMigracao1IncProgressBar(const APosicao: Integer);
    procedure DevAllMigracao1Mensagem(const ATabela, AAcao, AMsg,
      AMsgCompleta: string);
  private
    { Private declarations }
    procedure IniciaProgressBar(AMax: Integer);
  protected
    ID: Integer;
    mAuxiliar: TStringList;
  public
    { Public declarations }
  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.dfm}

{ TForm1 }

procedure TfrmPrincipal.BitBtn1Click(Sender: TObject);
begin
  DevAllMigracao1.Executar;
end;

procedure TfrmPrincipal.DevAllMigracao1IncProgressBar(const APosicao: Integer);
begin
  ProgressBar1.Position := APosicao;

  if (ProgressBar1.Position mod 500) = 0 then
    Application.ProcessMessages;
end;

procedure TfrmPrincipal.DevAllMigracao1Mensagem(const ATabela, AAcao, AMsg,
  AMsgCompleta: string);
begin
  Memo1.Lines.Add(AMsgCompleta);
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

procedure TfrmPrincipal.IniciaProgressBar(AMax: Integer);
begin
  ProgressBar1.Position := 0;
  ProgressBar1.Max := AMax;
end;

end.
