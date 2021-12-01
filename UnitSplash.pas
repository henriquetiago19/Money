unit UnitSplash;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Layouts;

type
  TFrmSplash = class(TForm)
    Layout2: TLayout;
    Image2: TImage;
    Label8: TLabel;
    Timer1: TTimer;
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmSplash: TFrmSplash;

implementation

{$R *.fmx}

uses UnitLogin;

procedure TFrmSplash.FormCreate(Sender: TObject);
begin
  Timer1.Enabled := True;
end;

procedure TFrmSplash.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;

  if not Assigned(FrmLogin) then
    Application.CreateForm(TFrmLogin, FrmLogin);

  FrmLogin.Show;
end;

end.
