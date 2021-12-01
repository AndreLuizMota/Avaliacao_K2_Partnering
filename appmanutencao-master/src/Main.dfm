object fMain: TfMain
  Left = 0
  Top = 0
  Caption = 'Foo'
  ClientHeight = 208
  ClientWidth = 390
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object btDatasetLoop: TButton
    Left = 64
    Top = 47
    Width = 169
    Height = 25
    Caption = 'Dataset Loop'
    TabOrder = 0
    OnClick = btDatasetLoopClick
  end
  object btThreads: TButton
    Left = 64
    Top = 109
    Width = 169
    Height = 25
    Caption = 'Threads'
    TabOrder = 1
    OnClick = btThreadsClick
  end
  object btStreams: TButton
    Left = 64
    Top = 78
    Width = 169
    Height = 25
    Caption = 'ClienteServidor'
    TabOrder = 2
    OnClick = btStreamsClick
  end
  object CheckBox1: TCheckBox
    Left = 180
    Top = 177
    Width = 173
    Height = 17
    Caption = 'Ativa Gerenciador de Exce'#231#245'es'
    TabOrder = 3
    OnClick = CheckBox1Click
  end
end
