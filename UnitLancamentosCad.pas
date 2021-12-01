unit UnitLancamentosCad;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.Edit,
  FMX.DateTimeCtrls, FMX.ListBox, FireDAC.Comp.Client, FireDAC.DApt, uFormat,
  FMX.DialogService, FMX.ComboEdit;

{$IFDEF AUTOREFCOUNT}
type
  TIntegerWrapper = class
  public
    Value: Integer;
    constructor Create(AValue: Integer);
  end;
{$ENDIF}

type
  TFrmLancamentosCad = class(TForm)
    lay_titulo: TLayout;
    Label1: TLabel;
    img_voltar: TImage;
    img_save: TImage;
    lay_descricao: TLayout;
    Label2: TLabel;
    edt_descricao: TEdit;
    lay_valor: TLayout;
    Label3: TLabel;
    edt_valor: TEdit;
    lay_categoria: TLayout;
    Label4: TLabel;
    lay_data: TLayout;
    Label5: TLabel;
    dt_lanc: TDateEdit;
    rect_delete: TRectangle;
    img_delete: TImage;
    lbl_categoria: TLabel;
    Image1: TImage;
    img_fundo: TImage;
    rect_hoje: TRectangle;
    Label6: TLabel;
    Line1: TLine;
    lay_tipo: TLayout;
    Label7: TLabel;
    comboTipo: TComboEdit;
    rect_ontem: TRectangle;
    Label8: TLabel;
    procedure img_voltarClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure img_saveClick(Sender: TObject);
    procedure edt_valorTyping(Sender: TObject);
    procedure img_deleteClick(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure rect_ontemClick(Sender: TObject);
    procedure rect_hojeClick(Sender: TObject);
  private
    //procedure ComboCategoria;
    { Private declarations }
  public
    { Public declarations }
    modo : string; // I (Inclusao) ou A (Alteracao)
    id_lanc : Integer;
  end;


var
  FrmLancamentosCad: TFrmLancamentosCad;

implementation

{$R *.fmx}

uses UnitPrincipal, cCategoria, UnitDM, cLancamento, UnitComboCategoria;


{$IFDEF AUTOREFCOUNT}
constructor TIntegerWrapper.Create(AValue: Integer);
begin
  inherited Create;
  Value := AValue;
end;
{$ENDIF}

{
procedure TFrmLancamentosCad.ComboCategoria;
var
    c : TCategoria;
    erro : string;
    qry: TFDQuery;
begin
    try
        cmb_categoria.Items.Clear;

        c := TCategoria.Create(dm.conn);
        qry := c.ListarCategoria(erro);

        if erro <> '' then
        begin
            showmessage(erro);
            exit;
        end;

        while NOT qry.Eof do
        begin
            cmb_categoria.Items.AddObject(qry.FieldByName('DESCRICAO').AsString,

            {$IFDEF AUTOREFCOUNT}
            //TIntegerWrapper.Create(qry.FieldByName('ID_CATEGORIA').AsInteger){$ELSE}TObject(qry.FieldByName('ID_CATEGORIA').AsInteger){$ENDIF});

            {
            qry.Next;
        end;

    finally
        qry.DisposeOf;
        c.DisposeOf;
    end;
end;
         }
procedure TFrmLancamentosCad.edt_valorTyping(Sender: TObject);
begin
  Formatar(edt_valor, TFormato.Valor);
end;

procedure TFrmLancamentosCad.FormShow(Sender: TObject);
var
  lanc : TLancamento;
  qry  : TFDQuery;
  erro : string;
begin
  if modo = 'I' then
  begin
    comboTipo.ItemIndex := comboTipo.Items.IndexOf('Crédito');
    edt_descricao.Text  := '';
    dt_lanc.Date        := date;
    edt_valor.Text      := '';
    rect_delete.Visible := false;
    lbl_categoria.Text  := '';
    lbl_categoria.Tag   := 0;
  end else
  begin
    try
      lanc := TLancamento.Create(dm.conn);

      lanc.ID_LANCAMENTO := id_lanc;
      qry := lanc.ListarLancamento(0, erro);

      if qry.RecordCount = 0 then
      begin
        ShowMessage('Lançamento não encontrado.');
        exit;
      end;

      edt_descricao.Text := qry.FieldByName('DESCRICAO').AsString;
      dt_lanc.Date       := qry.FieldByName('DATA').AsDateTime;

      if qry.FieldByName('VALOR').AsFloat < 0 then  // Despesa...
      begin
        edt_valor.Text      := FormatFloat('#,##0.00', qry.FieldByName('VALOR').AsFloat * -1);
        comboTipo.ItemIndex := comboTipo.Items.IndexOf('Débito');
      end else
      begin
        edt_valor.Text      := FormatFloat('#,##0.00', qry.FieldByName('VALOR').AsFloat);
        comboTipo.ItemIndex := comboTipo.Items.IndexOf('Crédito');
      end;

      //cmb_categoria.ItemIndex := cmb_categoria.Items.IndexOf(qry.FieldByName('DESCRICAO_CATEGORIA').AsString);
      lbl_categoria.Text  := qry.FieldByName('DESCRICAO_CATEGORIA').AsString;
      lbl_categoria.Tag   := qry.FieldByName('ID_CATEGORIA').AsInteger;
      rect_delete.Visible := true;
    finally
      qry.DisposeOf;
      lanc.DisposeOf;
    end;
  end;
end;

procedure TFrmLancamentosCad.Image1Click(Sender: TObject);
begin
  if NOT Assigned(FrmComboCategoria) then
    Application.CreateForm(TFrmComboCategoria, FrmComboCategoria);

  FrmComboCategoria.ShowModal(procedure(ModalResult: TModalResult)
  begin
      if FrmComboCategoria.IdCategoriaSelecao > 0 then
      begin
          lbl_categoria.Text := FrmComboCategoria.CategoriaSelecao;
          lbl_categoria.Tag  := FrmComboCategoria.IdCategoriaSelecao;
      end;
  end);
end;

procedure TFrmLancamentosCad.img_deleteClick(Sender: TObject);
var
    lanc : TLancamento;
    erro : string;
begin
    TDialogService.MessageDialog('Confirma exclusão do lançamento?',
                     TMsgDlgType.mtConfirmation,
                     [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo],
                     TMsgDlgBtn.mbNo,
                     0,
     procedure(const AResult: TModalResult)
     var
        erro: string;
     begin
        if AResult = mrYes then
        begin
            try
                lanc := TLancamento.Create(dm.conn);
                lanc.ID_LANCAMENTO := id_lanc;

                if lanc.Excluir(erro) = false then
                begin
                    showmessage(erro);
                    exit;
                end;

                close;

            finally
                lanc.DisposeOf;
            end;
        end;
     end);
end;

function TrataValor(str: string): double;
begin
    // Recebe = 1.250,75
    str := StringReplace(str, '.', '', [rfReplaceAll]); // 1250,75
    str := StringReplace(str, ',', '', [rfReplaceAll]); // 125075

    try
        Result := StrToFloat(str) / 100;
    except
        Result := 0;
    end;
end;

procedure TFrmLancamentosCad.img_saveClick(Sender: TObject);
var
  lanc : TLancamento;
  erro : string;
begin
  try
    lanc := TLancamento.Create(dm.conn);
    lanc.DESCRICAO := edt_descricao.Text;

    if comboTipo.Text = 'Crédito' then
      lanc.VALOR := TrataValor(edt_valor.Text) else
      lanc.VALOR := TrataValor(edt_valor.Text) *-1;

    {$IFDEF AUTOREFCOUNT}
    //lanc.ID_CATEGORIA := TIntegerWrapper(cmb_categoria.Items.Objects[cmb_categoria.ItemIndex]).Value;
    {$ELSE}
    //lanc.ID_CATEGORIA := Integer(cmb_categoria.Items.Objects[cmb_categoria.ItemIndex]);
    {$ENDIF}

    lanc.ID_CATEGORIA := lbl_categoria.Tag;
    lanc.DATA         := dt_lanc.Date;

    if modo = 'I' then
        lanc.Inserir(erro)
    else
    begin
        lanc.ID_LANCAMENTO := id_lanc;
        lanc.Alterar(erro);
    end;

    if erro <> '' then
    begin
        showmessage(erro);
        exit;
    end;

    close;
  finally
    lanc.DisposeOf;
  end;
end;

procedure TFrmLancamentosCad.img_voltarClick(Sender: TObject);
begin
  close;
end;

procedure TFrmLancamentosCad.rect_hojeClick(Sender: TObject);
begin
  dt_lanc.Date := date;
end;

procedure TFrmLancamentosCad.rect_ontemClick(Sender: TObject);
begin
  dt_lanc.Date := Date - 1;
end;

end.
