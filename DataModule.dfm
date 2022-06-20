object DM: TDM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  OnDestroy = DataModuleDestroy
  Height = 515
  Width = 520
  object FDConnection: TFDConnection
    Params.Strings = (
      'Database=C:\Users\test9\Documents\bazar3.db'
      'DriverID=SQLite')
    LoginPrompt = False
    Left = 80
    Top = 136
  end
  object FDQueryMain: TFDQuery
    AfterDelete = FDQueryMainAfterDelete
    Connection = FDConnection
    FetchOptions.AssignedValues = [evRecordCountMode]
    FetchOptions.RecordCountMode = cmTotal
    SQL.Strings = (
      
        'select *, BRANDS.ZNACKA, BRANDS.LOGO, COLORS.SKOD, COLORS.BARVA,' +
        ' MODELS.MODEL, PHOTOS.FOTKA from CARS'
      'left join BRANDS on CARS.ZNACKAID = BRANDS.ID'
      'left join MODELS on CARS.MODELID = MODELS.ID'
      'left join COLORS on CARS.BARVAID = COLORS.ID'
      'left join PHOTOS on CARS.VIN = PHOTOS.VIN')
    Left = 304
    Top = 184
  end
end
