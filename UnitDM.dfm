object dm: Tdm
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 157
  Width = 316
  object conn: TFDConnection
    Params.Strings = (
      'Database=D:\99Coders\Curso99Money2\Fontes\DB\banco.db'
      'OpenMode=ReadWrite'
      'LockingMode=Normal'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 112
    Top = 40
  end
end
