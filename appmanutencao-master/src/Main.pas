unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, UGerenciadorExcecoes;

type
  TfMain = class(TForm)
    btDatasetLoop: TButton;
    btThreads: TButton;
    btStreams: TButton;
    CheckBox1: TCheckBox;
    procedure btDatasetLoopClick(Sender: TObject);
    procedure btStreamsClick(Sender: TObject);
    procedure btThreadsClick(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
  private
    FGerenciadorExcecoes: TGerenciadorExcecoes;
  public
    Constructor Create(AOwner: TComponent); override;
    Destructor Destroy; override;
  end;

var
  fMain: TfMain;

implementation

uses
  DatasetLoop, ClienteServidor, Thread;

{$R *.dfm}

procedure TfMain.btDatasetLoopClick(Sender: TObject);
begin
  with TfDatasetLoop.Create(Application) do
  try
    ShowModal;
  finally
    Free;
  end;
end;

procedure TfMain.btStreamsClick(Sender: TObject);
begin
  with TfClienteServidor.Create(Application) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

procedure TfMain.btThreadsClick(Sender: TObject);
begin
  with TfThreads.Create(Application) do
    try
      ShowModal;
    finally
      Free;
    end;
end;

procedure TfMain.CheckBox1Click(Sender: TObject);
begin
  FGerenciadorExcecoes.Ativa(TCheckBox(Sender).Checked);
end;

constructor TfMain.Create(AOwner: TComponent);
begin
  inherited;
  FGerenciadorExcecoes:= TGerenciadorExcecoes.Create;
end;

destructor TfMain.Destroy;
begin
  if Assigned(FGerenciadorExcecoes) then
    FreeAndNil(FGerenciadorExcecoes);
  inherited;
end;

end.
