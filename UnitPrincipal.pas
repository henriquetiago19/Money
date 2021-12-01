unit UnitPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Objects,
  FMX.Layouts, FMX.Controls.Presentation, FMX.StdCtrls, FMX.ListView.Types,
  FMX.ListView.Appearances, FMX.ListView.Adapters.Base, FMX.ListView,
  UnitCategorias, UnitLancamentos, FMX.Ani, FireDAC.Comp.Client, FireDAC.DApt,
  Data.DB, FMX.Gestures;

type
  TFrmPrincipal = class(TForm)
    Layout1: TLayout;
    img_menu: TImage;
    Layout2: TLayout;
    lbl_saldo: TLabel;
    Label3: TLabel;
    Layout3: TLayout;
    Layout4: TLayout;
    Layout5: TLayout;
    Image2: TImage;
    lbl_receitas: TLabel;
    Label5: TLabel;
    Layout6: TLayout;
    Image3: TImage;
    lbl_despesas: TLabel;
    Label7: TLabel;
    rect_lancamentos: TRectangle;
    Layout7: TLayout;
    Label8: TLabel;
    lbl_todos_lanc: TLabel;
    lv_lancamento: TListView;
    rect_menu: TRectangle;
    layout_principal: TLayout;
    AnimationMenu: TFloatAnimation;
    layout_menu_cat: TLayout;
    Label9: TLabel;
    layout_menu_logoff: TLayout;
    Label10: TLabel;
    rect_conta: TRoundRect;
    Label2: TLabel;
    GestureManager1: TGestureManager;
    Line1: TLine;
    layout_usuario: TLayout;
    c_icone: TCircle;
    lbl_nome: TLabel;
    lbl_email: TLabel;
    Layout9: TLayout;
    Layout10: TLayout;
    procedure FormShow(Sender: TObject);
    procedure lv_lancamentoUpdateObjects(const Sender: TObject;
      const AItem: TListViewItem);
    procedure lv_lancamentoItemClick(const Sender: TObject;
      const AItem: TListViewItem);
    procedure lbl_todos_lancClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure img_menuClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure AnimationMenuFinish(Sender: TObject);
    procedure AnimationMenuProcess(Sender: TObject);
    procedure layout_menu_catClick(Sender: TObject);
    procedure layout_menu_logoffClick(Sender: TObject);
    procedure rect_contaClick(Sender: TObject);
    procedure rect_menuGesture(Sender: TObject;
      const EventInfo: TGestureEventInfo; var Handled: Boolean);
    procedure FormGesture(Sender: TObject; const EventInfo: TGestureEventInfo;
      var Handled: Boolean);
  private
    procedure carregarInfoUsuario;
    procedure ListarUltLanc;
    procedure MontaPainel;
  public
    procedure AddCategoria(listview: TListView; id_categoria, categoria: string;
      foto: TStream);
    procedure AddLancamento(listview: TListView; id_lancamento, descricao,
      categoria: string; valor: double; dt: TDateTime; foto: TStream);
    procedure SetupCategoria(lv: TListView; Item: TListViewItem);
    procedure SetupLancamento(lv: TListView; Item: TListViewItem);
  end;

var
  FrmPrincipal: TFrmPrincipal;

implementation

{$R *.fmx}

uses
  cLancamento,
  UnitDM,
  UnitLancamentosCad,
  cUsuario,
  UnitLogin,
  System.DateUtils;

procedure TFrmPrincipal.AddLancamento(listview: TListView;
                                      id_lancamento, descricao,
                                      categoria: string;
                                      valor: double;
                                      dt: TDateTime;
                                      foto: TStream);
var
  txt : TListItemText;
  img : TListItemImage;
  bmp : TBitmap;
begin
  with listview.Items.Add do
  begin
    TagString := id_lancamento;

    txt := TListItemText(Objects.FindDrawable('TxtDescricao'));
    txt.Text := descricao;

    TListItemText(Objects.FindDrawable('TxtCategoria')).Text := categoria;
    TListItemText(Objects.FindDrawable('TxtValor')).Text := FormatFloat('R$ #,##0.00', valor);
    TListItemText(Objects.FindDrawable('TxtData')).Text := FormatDateTime('dd/mm/yyyy', dt);

    // Icone...
    img := TListItemImage(Objects.FindDrawable('ImgIcone'));

    if foto <> nil then
    begin
        bmp := TBitmap.Create;
        bmp.LoadFromStream(foto);

        img.OwnsBitmap := true;
        img.Bitmap := bmp;
    end;
  end;
end;

procedure TFrmPrincipal.carregarInfoUsuario;
var
  u    : TUsuario;
  qry  : TFDQuery;
  erro : string;
  foto : TStream;
begin
  try
    u   := TUsuario.Create(dm.conn);
    qry := u.ListarUsuario(erro);

    if qry.FieldByName('FOTO').AsString <> '' then
      foto := qry.CreateBlobStream(qry.FieldByName('FOTO'), TBlobStreamMode.bmRead) else
      foto := nil;

    lbl_nome.Text  := qry.FieldByName('NOME').AsString;
    lbl_email.Text := qry.FieldByName('EMAIL').AsString;

    if foto <> nil then
    begin
      c_icone.Fill.Bitmap.Bitmap.LoadFromStream(foto);
      foto.DisposeOf;
    end;
  finally
    qry.DisposeOf;
    u.DisposeOf;
  end;
end;

procedure TFrmPrincipal.MontaPainel;
var
  lanc : TLancamento;
  qry: TFDQuery;
  erro: string;

  vl_receita, vl_despesa : double;
begin
  try
    lanc := TLancamento.Create(dm.conn);

    lanc.DATA_DE  := FormatDateTime('YYYY-MM-DD', StartOfTheMonth(date));
    lanc.DATA_ATE := FormatDateTime('YYYY-MM-DD', EndOfTheMonth(date));
    qry := lanc.ListarLancamento(0, erro);

    if erro <> '' then
    begin
      showmessage(erro);
      exit;
    end;

    vl_receita := 0;
    vl_despesa := 0;

    while NOT qry.Eof do
    begin
        if qry.FieldByName('VALOR').AsFloat > 0 then
            vl_receita := vl_receita + qry.FieldByName('VALOR').AsFloat
        else
            vl_despesa := vl_despesa + qry.FieldByName('VALOR').AsFloat;

        qry.Next;
    end;

    lbl_receitas.Text := FormatFloat('R$ #,##0.00', vl_receita);
    lbl_despesas.Text := FormatFloat('R$ #,##0.00', vl_despesa);
    lbl_saldo.Text    := FormatFloat('R$ #,##0.00', vl_receita + vl_despesa); // Somamos pq o vl_desp já esta negativo...
  finally
    qry.DisposeOf;
    lanc.DisposeOf;
  end;
end;

procedure TFrmPrincipal.rect_contaClick(Sender: TObject);
begin
  if not Assigned(FrmLancamentosCad) then
    Application.CreateForm(TFrmLancamentosCad, FrmLancamentosCad);

  FrmLancamentosCad.modo    := 'I';
  FrmLancamentosCad.id_lanc := 0;
  FrmLancamentosCad.ShowModal(procedure(ModalResult: TModalResult)
  begin
    ListarUltLanc;
  end);
end;

procedure TFrmPrincipal.rect_menuGesture(Sender: TObject;
  const EventInfo: TGestureEventInfo; var Handled: Boolean);
var
  Gesto : string;
begin
  if GestureToIdent(EventInfo.GestureID, Gesto) then
  begin
    case EventInfo.GestureID of
      sgiLeft  : AnimationMenu.Start;
    end;
  end;
end;

procedure TFrmPrincipal.AnimationMenuFinish(Sender: TObject);
begin
  layout_principal.Enabled := AnimationMenu.Inverse;
  AnimationMenu.Inverse    := NOT AnimationMenu.Inverse;
end;

procedure TFrmPrincipal.AnimationMenuProcess(Sender: TObject);
begin
  layout_principal.Margins.Right := -260 - rect_menu.Margins.Left;
end;

procedure TFrmPrincipal.SetupLancamento(lv: TListView; Item: TListViewItem);
var
    txt : TListItemText;
    //img : TListItemImage;
begin
    txt := TListItemText(Item.Objects.FindDrawable('TxtDescricao'));
    txt.Width := lv.Width - txt.PlaceOffset.X - 100;

    {
    img := TListItemImage(AItem.Objects.FindDrawable('ImgIcone'));

    if lv_lancamento.Width < 200 then
    begin
        img.Visible := false;
        txt.PlaceOffset.X := 2;
    end;
    }
end;

procedure TFrmPrincipal.AddCategoria(listview: TListView;
                                      id_categoria,
                                      categoria: string;
                                      foto: TStream);
var
    txt : TListItemText;
    img : TListItemImage;
    bmp : TBitmap;
begin
    with listview.Items.Add do
    begin
        TagString := id_categoria;

        txt := TListItemText(Objects.FindDrawable('TxtCategoria'));
        txt.Text := categoria;

        // Icone...
        img := TListItemImage(Objects.FindDrawable('ImgIcone'));

        if foto <> nil then
        begin
            bmp := TBitmap.Create;
            bmp.LoadFromStream(foto);

            img.OwnsBitmap := true;
            img.Bitmap := bmp;
        end;

    end;
end;


procedure TFrmPrincipal.SetupCategoria(lv: TListView;
                                       Item: TListViewItem);
var
    txt : TListItemText;
begin
    txt := TListItemText(Item.Objects.FindDrawable('TxtCategoria'));
    txt.Width := lv.Width - txt.PlaceOffset.X - 20;
end;


//***************************************************

procedure TFrmPrincipal.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if Assigned(FrmLancamentos) then
  begin
    FrmLancamentos.DisposeOf;
    FrmLancamentos := nil;
  end;

  Action := TCloseAction.caFree;
  FrmPrincipal := nil;
end;

procedure TFrmPrincipal.FormCreate(Sender: TObject);
begin
  rect_menu.Margins.Left := -260;
  rect_menu.Align        := TAlignLayout.Left;
  rect_menu.Visible      := true;
end;

procedure TFrmPrincipal.FormGesture(Sender: TObject;
  const EventInfo: TGestureEventInfo; var Handled: Boolean);
var
  Gesto : string;
begin
  if GestureToIdent(EventInfo.GestureID, Gesto) then
  begin
    case EventInfo.GestureID of
      sgiRight : AnimationMenu.Start;
    end;
  end;
end;

procedure TFrmPrincipal.ListarUltLanc;
var
  lanc : TLancamento;
  qry  : TFDQuery;
  erro : string;
  foto : TStream;
begin
  try
    lv_lancamento.Items.Clear;

    lanc := TLancamento.Create(dm.conn);
    qry := lanc.ListarLancamento(10, erro);

    if erro <> '' then
    begin
        ShowMessage(erro);
        exit;
    end;

    qry.First;
    while NOT qry.Eof do
    begin
      if qry.FieldByName('ICONE').AsString <> '' then
        foto := qry.CreateBlobStream(qry.FieldByName('ICONE'), TBlobStreamMode.bmRead) else
        foto := nil;

      AddLancamento(FrmPrincipal.lv_lancamento,
        qry.FieldByName('ID_LANCAMENTO').AsString,
        qry.FieldByName('DESCRICAO').AsString,
        qry.FieldByName('DESCRICAO_CATEGORIA').AsString,
        qry.FieldByName('VALOR').AsFloat,
        qry.FieldByName('DATA').AsDateTime,
        foto);

      qry.Next;

      foto.DisposeOf;
    end;
  finally
    lanc.DisposeOf;
  end;

  MontaPainel;
end;

procedure TFrmPrincipal.FormShow(Sender: TObject);
begin
  ListarUltLanc;
  carregarInfoUsuario;
end;

procedure TFrmPrincipal.img_menuClick(Sender: TObject);
begin
  AnimationMenu.Start;
end;

procedure TFrmPrincipal.layout_menu_catClick(Sender: TObject);
begin
  AnimationMenu.Start;

  if NOT Assigned(FrmCategorias) then
    Application.CreateForm(TFrmCategorias, FrmCategorias);

  FrmCategorias.Show;
end;

procedure TFrmPrincipal.layout_menu_logoffClick(Sender: TObject);
var
    u : TUsuario;
    erro : string;
begin
    try
        u := TUsuario.Create(dm.conn);

        if NOT u.Logout(erro) then
        begin
            showmessage(erro);
            exit;
        end;

    finally
        u.DisposeOf;
    end;

    if NOT Assigned(FrmLogin) then
        Application.CreateForm(TFrmLogin, FrmLogin);

    Application.MainForm := FrmLogin;
    FrmLogin.Show;
    FrmPrincipal.Close;
end;

procedure TFrmPrincipal.lbl_todos_lancClick(Sender: TObject);
begin
    if NOT Assigned(FrmLancamentos) then
        Application.CreateForm(TFrmLancamentos, FrmLancamentos);

    FrmLancamentos.Show;
end;

procedure TFrmPrincipal.lv_lancamentoItemClick(const Sender: TObject;
  const AItem: TListViewItem);
begin
    if NOT Assigned(FrmLancamentosCad) then
        Application.CreateForm(TFrmLancamentosCad, FrmLancamentosCad);

    FrmLancamentosCad.modo := 'A';
    FrmLancamentosCad.id_lanc := Aitem.TagString.ToInteger;

    FrmLancamentosCad.ShowModal(procedure(ModalResult: TModalResult)
        begin
            ListarUltLanc;
        end);
end;

procedure TFrmPrincipal.lv_lancamentoUpdateObjects(const Sender: TObject;
  const AItem: TListViewItem);
begin
  SetupLancamento(FrmPrincipal.lv_lancamento, AItem);
end;

end.
