unit UnitLancamentosResumo;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.ListView.Types, FMX.ListView.Appearances, FMX.ListView.Adapters.Base,
  FMX.ListView, FMX.Objects, FMX.Controls.Presentation, FMX.StdCtrls,
  FMX.Layouts, FireDAC.Comp.Client, FireDAC.DApt, Data.DB, cLancamento;

type
  TFrmLancamentosResumo = class(TForm)
    Layout1: TLayout;
    Label1: TLabel;
    img_voltar: TImage;
    Layout2: TLayout;
    Image3: TImage;
    lbl_mes: TLabel;
    lv_resumo: TListView;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure img_voltarClick(Sender: TObject);
  private
    procedure MontarResumo;
    procedure AddCategoria(listview: TListView; categoria: string; valor: double;
              foto: TStream);
    { Private declarations }
  public
    { Public declarations }
    dt_filtro : TDate;
  end;

var
  FrmLancamentosResumo: TFrmLancamentosResumo;

implementation

{$R *.fmx}

uses UnitPrincipal, UnitDM, System.DateUtils;

procedure TFrmLancamentosResumo.AddCategoria(listview: TListView;
                                      categoria: string;
                                      valor: double;
                                      foto: TStream);
var
    txt : TListItemText;
    img : TListItemImage;
    bmp : TBitmap;
begin
    with listview.Items.Add do
    begin
        txt := TListItemText(Objects.FindDrawable('TxtCategoria'));
        txt.Text := categoria;

        txt := TListItemText(Objects.FindDrawable('TxtValor'));
        txt.Text := FormatFloat('#,##0.00', valor);

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

procedure TFrmLancamentosResumo.MontarResumo;
var
    lanc : TLancamento;
    qry: TFDQuery;
    erro: string;
    icone: TStream;
begin
    try
        lv_resumo.Items.Clear;

        lanc := TLancamento.Create(dm.conn);
        lanc.DATA_DE := FormatDateTime('YYYY-MM-DD', StartOfTheMonth(dt_filtro));
        lanc.DATA_ATE := FormatDateTime('YYYY-MM-DD', EndOfTheMonth(dt_filtro));
        qry := lanc.ListarResumo(erro);

        while NOT qry.Eof do
        begin
            // Icone...
            if qry.FieldByName('ICONE').AsString <> '' then
                icone := qry.CreateBlobStream(qry.FieldByName('ICONE'), TBlobStreamMode.bmRead)
            else
                icone := nil;

            FrmLancamentosResumo.AddCategoria(lv_resumo,
                                              qry.FieldByName('DESCRICAO').AsString,
                                              qry.FieldByName('VALOR').AsCurrency,
                                              icone);

            if icone <> nil then
                icone.DisposeOf;

            qry.Next;
        end;

    finally
        qry.DisposeOf;
        lanc.DisposeOf;
    end;
end;

procedure TFrmLancamentosResumo.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
    Action := TCloseAction.caFree;
    FrmLancamentosResumo := nil;
end;

procedure TFrmLancamentosResumo.FormShow(Sender: TObject);
begin
    MontarResumo;
end;

procedure TFrmLancamentosResumo.img_voltarClick(Sender: TObject);
begin
    close;
end;

end.
