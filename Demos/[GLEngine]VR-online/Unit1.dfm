object Form1: TForm1
  Left = 211
  Top = 139
  Width = 1116
  Height = 634
  Caption = 'MultiView'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1100
    Height = 596
    Align = alClient
    BevelOuter = bvNone
    Ctl3D = False
    ParentCtl3D = False
    TabOrder = 0
    object Memo1: TMemo
      Left = 8
      Top = 56
      Width = 185
      Height = 233
      Lines.Strings = (
        'Delphi'
        'Drupal'
        'Perl'
        'Python'
        'Pascal'
        'PHP'
        'C#'
        'Visual Basic'
        'Delphi'
        'Java'
        'JavaScript'
        'QT'
        'C++'
        'Assembler'
        'VR-Online')
      TabOrder = 0
      Visible = False
    end
  end
  object Timer1: TTimer
    Interval = 25
    OnTimer = Timer1Timer
    Left = 8
    Top = 8
  end
end
