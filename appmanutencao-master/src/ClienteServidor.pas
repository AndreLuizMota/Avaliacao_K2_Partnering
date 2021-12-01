unit ClienteServidor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.ComCtrls, Vcl.StdCtrls, Datasnap.DBClient, Data.DB,
  UThreadBase;

type

  TThreaEnviarParalelo = class(TThreadBase)
  private
  protected
    procedure ExecutaAcao; override;
  public
  end;

  TServidor = class
  private
    //FPath: AnsiString;
    FPath: String;
  public
    constructor Create;
    //Tipo do parâmetro não pode ser alterado
    function SalvarArquivos(AData: OleVariant): Boolean;
    procedure RemoverArquivos(APath, AMascara: string);
  end;

  TfClienteServidor = class(TForm)
    ProgressBar: TProgressBar;
    btEnviarSemErros: TButton;
    btEnviarComErros: TButton;
    btEnviarParalelo: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btEnviarSemErrosClick(Sender: TObject);
    procedure btEnviarComErrosClick(Sender: TObject);
    procedure btEnviarParaleloClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    //FPath: AnsiString;
    FPath: String;
    FServidor: TServidor;
    FThreaEnviarParalelo: TThreaEnviarParalelo;
    function InitDataset: TClientDataset;
  public
    procedure Enviar(Sender: TObject);
  end;

var
  fClienteServidor: TfClienteServidor;
  iContadorArquivos: integer = 1;

const
  QTD_ARQUIVOS_ENVIAR = 100;
  QTD_ARQUIVOS_ENVIAR_LOTE = 5; //a forma que utilizei para contornar o problema de memória insuficiente, foi quebrar o processo em lotes.
                                //nesse notebook tem 16 gb de ram. lotes de 5 arquivos por vez passa.

implementation

uses
  IOUtils, Vcl.Dialogs;

{$R *.dfm}

procedure TfClienteServidor.btEnviarComErrosClick(Sender: TObject);
begin
  Enviar(Sender);
end;

procedure TfClienteServidor.btEnviarParaleloClick(Sender: TObject);
begin
  FThreaEnviarParalelo:= TThreaEnviarParalelo.Create(self, false);
end;

procedure TfClienteServidor.btEnviarSemErrosClick(Sender: TObject);
begin
  Enviar(Sender);
end;

procedure TfClienteServidor.Enviar(Sender: TObject);
var
  cds: TClientDataset;
  i, j: Integer;
  iContadorIteracoesEnvioLote: integer;
begin
  ProgressBar.Min:= 0;
  ProgressBar.Max:= QTD_ARQUIVOS_ENVIAR;

  cds := InitDataset;
  //cds.Open;
  iContadorIteracoesEnvioLote:= 1;
  i:= iContadorIteracoesEnvioLote;

  while i <= QTD_ARQUIVOS_ENVIAR  do
  begin
    for j:= 1 to QTD_ARQUIVOS_ENVIAR_LOTE do
    begin
      cds.Append;
      TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(FPath);
      cds.Post;
    end;

    //*************************************************************************//
    //essa condição para gerar o erro é incompatível com a soluão que eu implementei (baseando-me no envio de lotes de arquivo)
    //o pode receber incrementos diferentes de i, a depender da quantidade do lote. Logo, precisei alterar.....
    (*
    {$REGION Simulação de erro, não alterar}
    if i = (QTD_ARQUIVOS_ENVIAR/2) then
      FServidor.SalvarArquivos(NULL);
    {$ENDREGION}
    *)


    //salva o lote
    if i >= QTD_ARQUIVOS_ENVIAR/2  then
      if Assigned(Sender) then
        if TButton(Sender).Tag = 1 then {btEnviarComErros}
          FServidor.SalvarArquivos(NULL);

    FServidor.SalvarArquivos(cds.Data);

    //limpa e destrói o dataset, criando uma nova instância para o próximo lote
    cds.EmptyDataSet;
    cds.Free;
    cds := InitDataset;

    Application.ProcessMessages;
    ProgressBar.StepBy(QTD_ARQUIVOS_ENVIAR_LOTE);


    iContadorIteracoesEnvioLote:= iContadorIteracoesEnvioLote + QTD_ARQUIVOS_ENVIAR_LOTE;
    i:= iContadorIteracoesEnvioLote + 1;
  end;

  showmessage('Envio concluído com sucesso.');
end;

procedure TfClienteServidor.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  if Assigned(FThreaEnviarParalelo) then
    FreeAndNil(FThreaEnviarParalelo);
end;

procedure TfClienteServidor.FormCreate(Sender: TObject);
begin
  inherited;
  //FPath := IncludeTrailingBackslash(ExtractFilePath(ParamStr(0))) + 'pdf.pdf';
  FPath := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'pdf.pdf';
  FServidor := TServidor.Create;

  btEnviarComErros.Tag:= 1
end;

function TfClienteServidor.InitDataset: TClientDataset;
begin
  Result := TClientDataset.Create(nil);
  Result.FieldDefs.Add('Arquivo', ftBlob);
  Result.CreateDataSet;
end;

{ TServidor }

constructor TServidor.Create;
begin
  FPath := ExtractFilePath(ParamStr(0)) + 'Servidor\';
end;

procedure TServidor.RemoverArquivos(APath, AMascara: string);
Var
  vDir : TsearchRec;
  vErro: Integer;
  vArquivoNomeCompleto: string;
Begin
  vArquivoNomeCompleto:= APath + AMascara;
  vErro := FindFirst(vArquivoNomeCompleto, faArchive, vDir);
  While vErro = 0 do Begin
    DeleteFile(ExtractFilePAth(vArquivoNomeCompleto)+vDir.Name);
    //showmessage(ExtractFilePAth(vArquivoNomeCompleto)+vDir.Name);
    vErro := FindNext(vDir);
  End;
  FindClose(vDir);
End;

function TServidor.SalvarArquivos(AData: OleVariant): Boolean;
var
  cds: TClientDataSet;
  FileName: string;
begin
  try
    Result:= false;
    cds := TClientDataset.Create(nil);
    cds.Data := AData;

    {$REGION Simulação de erro, não alterar}
    if cds.RecordCount = 0 then
      Exit;
    {$ENDREGION}

    cds.First;

    while not cds.Eof do
    begin
      //FileName := FPath + cds.RecNo.ToString + '.pdf';
      FileName := FPath + iContadorArquivos.ToString + '.pdf';
      inc(iContadorArquivos);

      if TFile.Exists(FileName) then
        TFile.Delete(FileName);

      TBlobField(cds.FieldByName('Arquivo')).SaveToFile(FileName);
      cds.Next;
    end;

    cds.Free;

    Result := True;
  except
    //Result := False;
    RemoverArquivos(FPath, '*.pdf');
    raise;
  end;
end;

{ TThreaEnviarParalelo }

procedure TThreaEnviarParalelo.ExecutaAcao;
begin
  inherited;
  TfClienteServidor(FOwner).Enviar(nil);
  if iContadorArquivos =  QTD_ARQUIVOS_ENVIAR then
    Terminate;
end;


end.
