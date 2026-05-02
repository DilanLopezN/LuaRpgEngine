VERSION 5.00
Object = "{248DD890-BB45-11CF-9ABC-0080C7E7B78D}#1.0#0"; "Mswinsck.ocx"
Object = "{3B7C8863-D78F-101B-B9B5-04021C009402}#1.2#0"; "RICHTX32.OCX"
Begin VB.Form frmMain 
   BackColor       =   &H00E0E0E0&
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   9540
   ClientLeft      =   15
   ClientTop       =   -15
   ClientWidth     =   13245
   ControlBox      =   0   'False
   BeginProperty Font 
      Name            =   "Verdana"
      Size            =   8.25
      Charset         =   0
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   Icon            =   "frmMain.frx":0000
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   Picture         =   "frmMain.frx":324A
   ScaleHeight     =   636
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   883
   StartUpPosition =   2  'CenterScreen
   Visible         =   0   'False
   Begin VB.PictureBox picCaptcha 
      BackColor       =   &H00000000&
      FillStyle       =   0  'Solid
      ForeColor       =   &H00000000&
      Height          =   1935
      Left            =   120
      ScaleHeight     =   1875
      ScaleWidth      =   7155
      TabIndex        =   452
      Top             =   7320
      Visible         =   0   'False
      Width           =   7215
      Begin VB.TextBox txtCaptcha 
         Alignment       =   2  'Center
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Left            =   600
         TabIndex        =   453
         Text            =   "Text1"
         Top             =   960
         Width           =   6135
      End
      Begin VB.Label lblCaptcha 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Label2"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   15.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   615
         Left            =   360
         TabIndex        =   454
         Top             =   240
         Width           =   6495
      End
   End
   Begin VB.PictureBox picAmigos 
      BackColor       =   &H80000008&
      Height          =   4215
      Left            =   3720
      ScaleHeight     =   4155
      ScaleWidth      =   3315
      TabIndex        =   402
      Top             =   1440
      Visible         =   0   'False
      Width           =   3375
      Begin VB.ListBox lstAmigos 
         Height          =   2205
         Left            =   480
         TabIndex        =   403
         Top             =   1080
         Width           =   2415
      End
      Begin VB.Label lblBlank 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Remover"
         ForeColor       =   &H00C0FFFF&
         Height          =   255
         Index           =   84
         Left            =   480
         TabIndex        =   410
         Top             =   3360
         Width           =   2415
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "X"
         ForeColor       =   &H00FFFFFF&
         Height          =   375
         Index           =   85
         Left            =   3000
         TabIndex        =   409
         Top             =   0
         Width           =   1935
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Amigos Online"
         ForeColor       =   &H00C0FFFF&
         Height          =   255
         Index           =   86
         Left            =   240
         TabIndex        =   408
         Top             =   720
         Width           =   1335
      End
      Begin VB.Line lineblank 
         BorderColor     =   &H00FFFFC0&
         X1              =   1560
         X2              =   1680
         Y1              =   960
         Y2              =   600
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Players Online"
         ForeColor       =   &H00C0FFFF&
         Height          =   255
         Index           =   87
         Left            =   1800
         TabIndex        =   407
         Top             =   720
         Width           =   1455
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Desafiar x1"
         ForeColor       =   &H00C0FFC0&
         Height          =   255
         Index           =   88
         Left            =   480
         TabIndex        =   406
         Top             =   3840
         Width           =   1095
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Chat"
         ForeColor       =   &H00C0FFC0&
         Height          =   255
         Index           =   89
         Left            =   2280
         TabIndex        =   405
         Top             =   3840
         Width           =   615
      End
      Begin VB.Label lblBlank 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Amigos"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   14.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   495
         Index           =   90
         Left            =   1200
         TabIndex        =   404
         Top             =   120
         Width           =   1095
      End
   End
   Begin VB.PictureBox picAVISO 
      BackColor       =   &H00C0FFC0&
      Height          =   1815
      Left            =   3480
      ScaleHeight     =   1755
      ScaleWidth      =   3795
      TabIndex        =   399
      Top             =   2160
      Visible         =   0   'False
      Width           =   3855
      Begin VB.Label lblBlank 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Descrição"
         Height          =   1095
         Index           =   83
         Left            =   120
         TabIndex        =   401
         Top             =   480
         Width           =   3615
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "X"
         Height          =   375
         Index           =   82
         Left            =   3480
         TabIndex        =   400
         Top             =   0
         Width           =   375
      End
   End
   Begin VB.PictureBox picMudarNick 
      BackColor       =   &H00FFC0C0&
      Height          =   1815
      Left            =   2880
      ScaleHeight     =   1755
      ScaleWidth      =   4995
      TabIndex        =   394
      Top             =   2160
      Visible         =   0   'False
      Width           =   5055
      Begin VB.TextBox txtNovoNick 
         Alignment       =   2  'Center
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   14.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   525
         Left            =   1080
         TabIndex        =   397
         Top             =   720
         Width           =   2895
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Mudar!"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   14.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Index           =   81
         Left            =   1920
         TabIndex        =   398
         Top             =   1320
         Width           =   1215
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "X"
         Height          =   255
         Index           =   80
         Left            =   4680
         TabIndex        =   396
         Top             =   0
         Width           =   375
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Escolha o novo nickname(minimo 3 letras,máximo 12)"
         ForeColor       =   &H00C00000&
         Height          =   375
         Index           =   79
         Left            =   120
         TabIndex        =   395
         Top             =   360
         Width           =   4815
      End
   End
   Begin VB.PictureBox picPergunta 
      BackColor       =   &H00FFFFC0&
      Height          =   1335
      Left            =   2280
      ScaleHeight     =   1275
      ScaleWidth      =   6915
      TabIndex        =   389
      Top             =   2160
      Visible         =   0   'False
      Width           =   6975
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Height          =   255
         Index           =   78
         Left            =   6480
         TabIndex        =   393
         Top             =   0
         Width           =   495
      End
      Begin VB.Label lblBlank 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Pergunta"
         Height          =   375
         Index           =   77
         Left            =   120
         TabIndex        =   392
         Top             =   240
         Width           =   6255
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Não"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H000000C0&
         Height          =   495
         Index           =   76
         Left            =   3840
         TabIndex        =   391
         Top             =   840
         Width           =   615
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Sim"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00008000&
         Height          =   495
         Index           =   75
         Left            =   2400
         TabIndex        =   390
         Top             =   840
         Width           =   615
      End
   End
   Begin VB.PictureBox picExame 
      BackColor       =   &H80000007&
      Height          =   3855
      Left            =   2880
      ScaleHeight     =   3795
      ScaleWidth      =   4755
      TabIndex        =   360
      Top             =   1560
      Visible         =   0   'False
      Width           =   4815
      Begin VB.TextBox txtExame 
         Enabled         =   0   'False
         BeginProperty Font 
            Name            =   "Arial"
            Size            =   9
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Left            =   240
         Locked          =   -1  'True
         MultiLine       =   -1  'True
         TabIndex        =   365
         Top             =   1080
         Width           =   4335
      End
      Begin VB.CommandButton cmdBlank 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFC0&
         Caption         =   "Confirmar"
         Height          =   375
         Index           =   5
         Left            =   1800
         Style           =   1  'Graphical
         TabIndex        =   363
         Top             =   3240
         Width           =   1095
      End
      Begin VB.ListBox lstExame 
         Height          =   840
         ItemData        =   "frmMain.frx":6252B
         Left            =   80
         List            =   "frmMain.frx":6253B
         TabIndex        =   362
         Top             =   2280
         Width           =   4575
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Pergunta:"
         BeginProperty Font 
            Name            =   "Courier New"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H0000C0C0&
         Height          =   375
         Index           =   35
         Left            =   120
         TabIndex        =   366
         Top             =   600
         Width           =   4095
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Escolha uma resposta:"
         BeginProperty Font 
            Name            =   "Courier New"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H0000C0C0&
         Height          =   375
         Index           =   34
         Left            =   120
         TabIndex        =   364
         Top             =   1920
         Width           =   4095
      End
      Begin VB.Label lblBlank 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Teste Escrito"
         BeginProperty Font 
            Name            =   "Courier New"
            Size            =   14.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FF8080&
         Height          =   255
         Index           =   33
         Left            =   1560
         TabIndex        =   361
         Top             =   120
         Width           =   1695
      End
   End
   Begin VB.PictureBox picWAR 
      BorderStyle     =   0  'None
      Height          =   495
      Left            =   4800
      Picture         =   "frmMain.frx":6254B
      ScaleHeight     =   495
      ScaleWidth      =   540
      TabIndex        =   355
      Top             =   0
      Visible         =   0   'False
      Width           =   540
      Begin VB.Label lblWAR 
         BackStyle       =   0  'Transparent
         Height          =   2655
         Index           =   2
         Left            =   4440
         TabIndex        =   358
         Top             =   1080
         Width           =   3495
      End
      Begin VB.Label lblWAR 
         BackStyle       =   0  'Transparent
         Height          =   2655
         Index           =   1
         Left            =   120
         TabIndex        =   357
         Top             =   1200
         Width           =   3495
      End
      Begin VB.Label lblWAR 
         BackStyle       =   0  'Transparent
         Height          =   375
         Index           =   0
         Left            =   7800
         TabIndex        =   356
         Top             =   0
         Width           =   375
      End
   End
   Begin VB.PictureBox picContagem 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   3300
      Left            =   2520
      ScaleHeight     =   3270
      ScaleWidth      =   5025
      TabIndex        =   352
      Top             =   1680
      Visible         =   0   'False
      Width           =   5055
   End
   Begin VB.PictureBox picFace 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      BackColor       =   &H00FFFFFF&
      ForeColor       =   &H80000008&
      Height          =   1500
      Left            =   7800
      ScaleHeight     =   98
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   98
      TabIndex        =   346
      Top             =   7680
      Width           =   1500
   End
   Begin VB.PictureBox picChatInvite 
      BackColor       =   &H00000000&
      Height          =   3855
      Left            =   3000
      ScaleHeight     =   3795
      ScaleWidth      =   4035
      TabIndex        =   340
      Top             =   1320
      Visible         =   0   'False
      Width           =   4095
      Begin VB.ListBox lstChatInvite 
         Height          =   2790
         Left            =   840
         TabIndex        =   342
         Top             =   480
         Width           =   2415
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "X"
         ForeColor       =   &H000000FF&
         Height          =   495
         Index           =   27
         Left            =   3600
         TabIndex        =   344
         Top             =   0
         Width           =   495
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Enviar Convite"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   9
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFF80&
         Height          =   375
         Index           =   26
         Left            =   1320
         TabIndex        =   343
         Top             =   3360
         Width           =   1575
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Selecione alguém pra inciar o CHAT"
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Index           =   25
         Left            =   240
         TabIndex        =   341
         Top             =   120
         Width           =   3255
      End
   End
   Begin VB.CommandButton cmdEXTRAS 
      Appearance      =   0  'Flat
      BackColor       =   &H00808080&
      Caption         =   "EXTRAS"
      BeginProperty Font 
         Name            =   "Lucida Sans Unicode"
         Size            =   12
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   11640
      MaskColor       =   &H00FF00FF&
      Style           =   1  'Graphical
      TabIndex        =   328
      Top             =   9000
      Width           =   1215
   End
   Begin VB.PictureBox picExtras 
      Appearance      =   0  'Flat
      BackColor       =   &H00000000&
      ForeColor       =   &H80000008&
      Height          =   4050
      Left            =   10080
      ScaleHeight     =   4020
      ScaleWidth      =   2880
      TabIndex        =   325
      Top             =   4920
      Visible         =   0   'False
      Width           =   2910
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Lista de Amigos"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFC0&
         Height          =   255
         Index           =   91
         Left            =   480
         TabIndex        =   411
         Top             =   2760
         Width           =   2415
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Trocar Nickname"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFC0&
         Height          =   255
         Index           =   32
         Left            =   480
         TabIndex        =   359
         Top             =   2400
         Width           =   2415
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Sair de Torneio"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFC0&
         Height          =   255
         Index           =   29
         Left            =   480
         TabIndex        =   354
         Top             =   3240
         Width           =   2415
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Chat Privado"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFC0&
         Height          =   255
         Index           =   28
         Left            =   480
         TabIndex        =   345
         Top             =   2040
         Width           =   2415
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Modo Espectador"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFC0&
         Height          =   255
         Index           =   24
         Left            =   480
         TabIndex        =   334
         Top             =   1680
         Width           =   2535
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Desafiar"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFC0&
         Height          =   255
         Index           =   23
         Left            =   480
         TabIndex        =   333
         Top             =   1320
         Width           =   2535
      End
      Begin VB.Label Label19 
         BackStyle       =   0  'Transparent
         Caption         =   "Sair da Org"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFC0&
         Height          =   375
         Left            =   480
         TabIndex        =   331
         Top             =   3600
         Width           =   1815
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Campo de Treino"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFC0&
         Height          =   255
         Index           =   22
         Left            =   480
         TabIndex        =   330
         Top             =   960
         Width           =   2535
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Torneio"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFC0&
         Height          =   255
         Index           =   21
         Left            =   480
         TabIndex        =   329
         Top             =   600
         Width           =   2295
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Top's"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFC0&
         Height          =   255
         Index           =   0
         Left            =   480
         TabIndex        =   327
         Top             =   240
         Width           =   2295
      End
      Begin VB.Label lblBlank 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Extras"
         BeginProperty Font 
            Name            =   "Lucida Console"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Index           =   20
         Left            =   720
         TabIndex        =   326
         Top             =   0
         Width           =   1335
      End
   End
   Begin VB.PictureBox picAdminWarp 
      Height          =   5895
      Left            =   480
      ScaleHeight     =   5835
      ScaleWidth      =   11355
      TabIndex        =   312
      Top             =   720
      Visible         =   0   'False
      Width           =   11415
      Begin VB.CommandButton cmdTorneio 
         BackColor       =   &H00C0FFC0&
         Caption         =   "Desmutar Jogador"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   9.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   495
         Index           =   15
         Left            =   5520
         Style           =   1  'Graphical
         TabIndex        =   455
         Top             =   1800
         Width           =   1215
      End
      Begin VB.CommandButton cmdTorneio 
         BackColor       =   &H00C0C0FF&
         Caption         =   "Mutar Jogador"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   9.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   495
         Index           =   0
         Left            =   5520
         Style           =   1  'Graphical
         TabIndex        =   451
         Top             =   1320
         Width           =   1215
      End
      Begin VB.CommandButton cmdTorneio 
         BackColor       =   &H00FF8080&
         Caption         =   "Mandar Luta"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   9.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   855
         Index           =   14
         Left            =   3480
         Style           =   1  'Graphical
         TabIndex        =   450
         Top             =   1320
         Width           =   1215
      End
      Begin VB.TextBox txtPainelADM 
         Height          =   285
         Index           =   1
         Left            =   3840
         TabIndex        =   449
         Text            =   "0"
         Top             =   3840
         Width           =   615
      End
      Begin VB.TextBox txtPainelADM 
         Height          =   285
         Index           =   0
         Left            =   3840
         TabIndex        =   448
         Text            =   "0"
         Top             =   3000
         Width           =   615
      End
      Begin VB.CommandButton cmdBlank 
         Caption         =   "Banir por 2 dias"
         Height          =   255
         Index           =   8
         Left            =   5880
         TabIndex        =   447
         Top             =   5040
         Width           =   1695
      End
      Begin VB.CommandButton cmdBlank 
         Caption         =   "Banir por 1 dia"
         Height          =   255
         Index           =   7
         Left            =   5880
         TabIndex        =   446
         Top             =   4560
         Width           =   1695
      End
      Begin VB.CommandButton cmdBlank 
         Caption         =   "Banir por 7 dias"
         Height          =   255
         Index           =   6
         Left            =   5880
         TabIndex        =   445
         Top             =   5520
         Width           =   1695
      End
      Begin VB.CommandButton cmdTorneio 
         Caption         =   "Anunciar KS"
         Height          =   495
         Index           =   13
         Left            =   8640
         TabIndex        =   444
         Top             =   3120
         Width           =   1935
      End
      Begin VB.CommandButton cmdTorneio 
         Caption         =   "ATIVAR/DESATIVAR KS"
         Height          =   495
         Index           =   12
         Left            =   8640
         TabIndex        =   443
         Top             =   2400
         Width           =   1935
      End
      Begin VB.HScrollBar scrlPainelAdm 
         Height          =   255
         Index           =   1
         Left            =   8520
         Max             =   7
         TabIndex        =   441
         Top             =   1680
         Value           =   2
         Width           =   2295
      End
      Begin VB.CommandButton cmdTorneio 
         Caption         =   "verificar Evento"
         Height          =   495
         Index           =   11
         Left            =   9120
         TabIndex        =   440
         Top             =   600
         Width           =   1335
      End
      Begin VB.CommandButton cmdTorneio 
         Caption         =   "setar CT"
         Height          =   495
         Index           =   10
         Left            =   4560
         TabIndex        =   419
         Top             =   3720
         Width           =   855
      End
      Begin VB.CommandButton cmdTorneio 
         Caption         =   "setar OHYEH"
         Height          =   495
         Index           =   9
         Left            =   5640
         TabIndex        =   418
         Top             =   2880
         Width           =   855
      End
      Begin VB.CommandButton cmdTorneio 
         Caption         =   "setar LIGHT"
         Height          =   495
         Index           =   8
         Left            =   4560
         TabIndex        =   417
         Top             =   2880
         Width           =   855
      End
      Begin VB.CommandButton cmdTorneio 
         Caption         =   "Verificar CT"
         Height          =   495
         Index           =   7
         Left            =   6840
         TabIndex        =   416
         Top             =   3120
         Width           =   855
      End
      Begin VB.CommandButton cmdTorneio 
         Caption         =   "Verificar VIP"
         Height          =   495
         Index           =   6
         Left            =   6840
         TabIndex        =   415
         Top             =   2640
         Width           =   855
      End
      Begin VB.CommandButton cmdBlank 
         BackColor       =   &H008080FF&
         Caption         =   "Ban IP(CASO EXTREMO DEMAIS)"
         Height          =   975
         Index           =   4
         Left            =   8640
         Style           =   1  'Graphical
         TabIndex        =   349
         Top             =   4800
         Width           =   1695
      End
      Begin VB.CommandButton cmdBlank 
         Caption         =   "Setar Rank"
         Height          =   375
         Index           =   0
         Left            =   5640
         TabIndex        =   348
         Top             =   240
         Width           =   1215
      End
      Begin VB.HScrollBar scrlPainelAdm 
         Height          =   255
         Index           =   0
         Left            =   3120
         Max             =   8
         Min             =   1
         TabIndex        =   347
         Top             =   360
         Value           =   1
         Width           =   2295
      End
      Begin VB.CommandButton cmdBlank 
         Caption         =   "Kick"
         Height          =   255
         Index           =   3
         Left            =   3360
         TabIndex        =   317
         Top             =   5160
         Width           =   975
      End
      Begin VB.ListBox lstAdminWarp 
         Height          =   5520
         Left            =   120
         TabIndex        =   315
         Top             =   120
         Width           =   2775
      End
      Begin VB.CommandButton cmdBlank 
         Caption         =   "Teleportar até ele"
         Height          =   255
         Index           =   1
         Left            =   3120
         TabIndex        =   314
         Top             =   4560
         Width           =   1695
      End
      Begin VB.CommandButton cmdBlank 
         Caption         =   "Trazer pra cá(admin)"
         Height          =   255
         Index           =   2
         Left            =   5640
         TabIndex        =   313
         Top             =   3720
         Width           =   2055
      End
      Begin VB.Label lblBlank 
         Caption         =   "KS selecionado: Nenhum"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Index           =   95
         Left            =   7920
         TabIndex        =   442
         Top             =   1320
         Width           =   3375
      End
      Begin VB.Label lblBlank 
         Caption         =   "Torneios/Eventos"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Index           =   94
         Left            =   8880
         TabIndex        =   439
         Top             =   240
         Width           =   1935
      End
      Begin VB.Line Line8 
         Index           =   9
         X1              =   7800
         X2              =   7800
         Y1              =   0
         Y2              =   5880
      End
      Begin VB.Label lblBlank 
         Alignment       =   2  'Center
         Caption         =   "Dias:"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Index           =   93
         Left            =   3240
         TabIndex        =   438
         Top             =   3840
         Width           =   495
      End
      Begin VB.Label lblBlank 
         Alignment       =   2  'Center
         Caption         =   "CT"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Index           =   59
         Left            =   3120
         TabIndex        =   437
         Top             =   3600
         Width           =   375
      End
      Begin VB.Label lblBlank 
         Alignment       =   2  'Center
         Caption         =   "Dias:"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Index           =   54
         Left            =   3240
         TabIndex        =   436
         Top             =   3000
         Width           =   495
      End
      Begin VB.Label lblBlank 
         Alignment       =   2  'Center
         Caption         =   "VIP"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Index           =   53
         Left            =   3120
         TabIndex        =   435
         Top             =   2760
         Width           =   375
      End
      Begin VB.Label lblBlank 
         Alignment       =   2  'Center
         Caption         =   "Comandos ADM"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Index           =   92
         Left            =   3120
         TabIndex        =   414
         Top             =   2520
         Width           =   4095
      End
      Begin VB.Line Line8 
         Index           =   6
         X1              =   3240
         X2              =   7440
         Y1              =   4320
         Y2              =   4320
      End
      Begin VB.Label lblSetRank 
         Caption         =   "Rank:Estudante"
         Height          =   255
         Left            =   3120
         TabIndex        =   353
         Top             =   120
         Width           =   2295
      End
      Begin VB.Label lblBlank 
         Caption         =   "Comandos GM"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Index           =   31
         Left            =   4560
         TabIndex        =   351
         Top             =   4320
         Width           =   1575
      End
      Begin VB.Line Line8 
         Index           =   4
         X1              =   3120
         X2              =   7320
         Y1              =   2400
         Y2              =   2400
      End
      Begin VB.Label lblBlank 
         Caption         =   "Torneios"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Index           =   30
         Left            =   4680
         TabIndex        =   350
         Top             =   840
         Width           =   855
      End
      Begin VB.Line Line8 
         Index           =   3
         X1              =   3120
         X2              =   7320
         Y1              =   720
         Y2              =   720
      End
      Begin VB.Line Line8 
         Index           =   2
         X1              =   3000
         X2              =   3000
         Y1              =   0
         Y2              =   5880
      End
      Begin VB.Label lblBlank 
         Caption         =   "X"
         Height          =   255
         Index           =   2
         Left            =   10800
         TabIndex        =   316
         Top             =   0
         Width           =   615
      End
   End
   Begin VB.PictureBox picDesafio 
      BackColor       =   &H00000000&
      Height          =   5415
      Left            =   1680
      ScaleHeight     =   5355
      ScaleWidth      =   6075
      TabIndex        =   308
      Top             =   1200
      Visible         =   0   'False
      Width           =   6135
      Begin VB.CommandButton cmDesafio 
         BackColor       =   &H00FFC0C0&
         Caption         =   "Zerar desafio"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Index           =   1
         Left            =   4080
         MaskColor       =   &H00FFFFC0&
         Style           =   1  'Graphical
         TabIndex        =   431
         Top             =   3720
         Width           =   1815
      End
      Begin VB.CommandButton cmDesafio 
         BackColor       =   &H00FFC0C0&
         Caption         =   "Enviar Desafio"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Index           =   2
         Left            =   1320
         MaskColor       =   &H00FFFFC0&
         Style           =   1  'Graphical
         TabIndex        =   430
         Top             =   4080
         Visible         =   0   'False
         Width           =   3375
      End
      Begin VB.CommandButton cmDesafio 
         BackColor       =   &H00FFC0C0&
         Caption         =   "Selecionar oponente"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Index           =   0
         Left            =   120
         MaskColor       =   &H00FFFFC0&
         Style           =   1  'Graphical
         TabIndex        =   429
         Top             =   4080
         Width           =   5775
      End
      Begin VB.ComboBox cmbArenaTipo 
         Height          =   315
         ItemData        =   "frmMain.frx":785F9
         Left            =   1680
         List            =   "frmMain.frx":78609
         TabIndex        =   428
         Text            =   "1x1"
         Top             =   3720
         Width           =   735
      End
      Begin VB.ComboBox cmbArenaNum 
         Height          =   315
         ItemData        =   "frmMain.frx":78621
         Left            =   3360
         List            =   "frmMain.frx":78628
         TabIndex        =   426
         Text            =   "SELECIONE"
         Top             =   480
         Width           =   2535
      End
      Begin VB.PictureBox picArena 
         Height          =   1575
         Left            =   3720
         Picture         =   "frmMain.frx":78635
         ScaleHeight     =   1515
         ScaleWidth      =   1755
         TabIndex        =   338
         Top             =   1200
         Width           =   1815
      End
      Begin VB.ListBox lstDesafio 
         Height          =   2985
         ItemData        =   "frmMain.frx":797D3
         Left            =   120
         List            =   "frmMain.frx":797D5
         TabIndex        =   309
         Top             =   600
         Width           =   2655
      End
      Begin VB.Label lblDesafio 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "AWD"
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Index           =   9
         Left            =   360
         TabIndex        =   434
         Top             =   5040
         Width           =   5295
      End
      Begin VB.Label lblDesafio 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "x"
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Index           =   8
         Left            =   360
         TabIndex        =   433
         Top             =   4800
         Width           =   5295
      End
      Begin VB.Label lblDesafio 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "AWD"
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Index           =   7
         Left            =   360
         TabIndex        =   432
         Top             =   4560
         Width           =   5295
      End
      Begin VB.Label lblDesafio 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Tipo de desafio:"
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Index           =   6
         Left            =   120
         TabIndex        =   427
         Top             =   3720
         Width           =   1575
      End
      Begin VB.Line Line8 
         BorderColor     =   &H00E0E0E0&
         Index           =   7
         X1              =   3240
         X2              =   6240
         Y1              =   3600
         Y2              =   3600
      End
      Begin VB.Line Line8 
         BorderColor     =   &H00E0E0E0&
         Index           =   8
         X1              =   0
         X2              =   3000
         Y1              =   3600
         Y2              =   3600
      End
      Begin VB.Line Line8 
         BorderColor     =   &H00E0E0E0&
         Index           =   1
         X1              =   3240
         X2              =   3240
         Y1              =   120
         Y2              =   3600
      End
      Begin VB.Label lblDesafio 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Floresta"
         ForeColor       =   &H00C0C000&
         Height          =   375
         Index           =   4
         Left            =   3600
         TabIndex        =   339
         Top             =   2880
         Width           =   2055
      End
      Begin VB.Label lblDesafio 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Escolha a Arena"
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Index           =   3
         Left            =   3360
         TabIndex        =   337
         Top             =   120
         Width           =   2295
      End
      Begin VB.Line Line8 
         BorderColor     =   &H00E0E0E0&
         Index           =   0
         X1              =   3000
         X2              =   3000
         Y1              =   120
         Y2              =   3600
      End
      Begin VB.Label lblDesafio 
         BackStyle       =   0  'Transparent
         ForeColor       =   &H000000FF&
         Height          =   375
         Index           =   2
         Left            =   5640
         TabIndex        =   311
         Top             =   0
         Width           =   495
      End
      Begin VB.Label lblDesafio 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Escolha o Player"
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Index           =   0
         Left            =   480
         TabIndex        =   310
         Top             =   120
         Width           =   1695
      End
   End
   Begin VB.PictureBox picTops 
      BackColor       =   &H00C0FFC0&
      Height          =   2535
      Left            =   2760
      ScaleHeight     =   2475
      ScaleWidth      =   4035
      TabIndex        =   303
      Top             =   1920
      Visible         =   0   'False
      Width           =   4095
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "X"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000080&
         Height          =   375
         Index           =   39
         Left            =   3720
         TabIndex        =   368
         Top             =   0
         Width           =   375
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "TOP'S"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   14.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Index           =   38
         Left            =   1560
         TabIndex        =   367
         Top             =   120
         Width           =   1095
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Personagem(O player com level mais alto)"
         Height          =   255
         Index           =   49
         Left            =   0
         TabIndex        =   307
         Top             =   2160
         Width           =   3975
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Player_X_Player(Estatísticas de combate)"
         Height          =   255
         Index           =   47
         Left            =   0
         TabIndex        =   306
         Top             =   1800
         Width           =   3855
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Karma(Heros e Player Killer)"
         Height          =   255
         Index           =   46
         Left            =   0
         TabIndex        =   305
         Top             =   1440
         Width           =   3975
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Level(Quanto mais level,melhor :} )"
         Height          =   255
         Index           =   45
         Left            =   0
         TabIndex        =   304
         Top             =   1080
         Width           =   3975
      End
   End
   Begin VB.PictureBox picTopChar 
      BackColor       =   &H00000000&
      Height          =   495
      Left            =   1800
      ScaleHeight     =   435
      ScaleWidth      =   435
      TabIndex        =   302
      Top             =   0
      Visible         =   0   'False
      Width           =   495
      Begin VB.ListBox lstTopChar 
         Height          =   4740
         Index           =   1
         Left            =   3000
         TabIndex        =   425
         Top             =   1200
         Width           =   2655
      End
      Begin VB.ListBox lstTopChar 
         Height          =   4740
         Index           =   0
         Left            =   120
         TabIndex        =   424
         Top             =   1200
         Width           =   2655
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "X"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   9.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H000000FF&
         Height          =   375
         Index           =   55
         Left            =   5280
         TabIndex        =   374
         Top             =   0
         Width           =   1455
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Player/Level"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   9.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00C0FFFF&
         Height          =   375
         Index           =   52
         Left            =   3600
         TabIndex        =   373
         Top             =   480
         Width           =   1455
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Personagem"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   9.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00C0FFFF&
         Height          =   375
         Index           =   51
         Left            =   720
         TabIndex        =   372
         Top             =   480
         Width           =   1455
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "TOP PERSONAGEM"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   9
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H0000FFFF&
         Height          =   375
         Index           =   50
         Left            =   2040
         TabIndex        =   371
         Top             =   0
         Width           =   2655
      End
      Begin VB.Line Line8 
         BorderColor     =   &H80000002&
         Index           =   5
         X1              =   2880
         X2              =   2880
         Y1              =   1200
         Y2              =   7920
      End
   End
   Begin VB.PictureBox picPVP 
      BackColor       =   &H00000000&
      ForeColor       =   &H8000000E&
      Height          =   495
      Left            =   2400
      ScaleHeight     =   435
      ScaleWidth      =   435
      TabIndex        =   245
      Top             =   0
      Visible         =   0   'False
      Width           =   495
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "X"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H000000FF&
         Height          =   255
         Index           =   60
         Left            =   4680
         TabIndex        =   375
         Top             =   120
         Width           =   1695
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Derrotas:"
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Index           =   19
         Left            =   4200
         TabIndex        =   324
         Top             =   480
         Width           =   1695
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Vitórias:"
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Index           =   18
         Left            =   2160
         TabIndex        =   323
         Top             =   480
         Width           =   1695
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Nome:"
         ForeColor       =   &H00FFFFFF&
         Height          =   375
         Index           =   17
         Left            =   120
         TabIndex        =   322
         Top             =   480
         Width           =   1215
      End
      Begin VB.Label lblPvpTitulo 
         BackStyle       =   0  'Transparent
         Caption         =   "Player X Player"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   14.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00808080&
         Height          =   375
         Index           =   1
         Left            =   1680
         TabIndex        =   280
         Top             =   0
         Width           =   2295
      End
      Begin VB.Label lblPvpTitulo 
         BackStyle       =   0  'Transparent
         Caption         =   "Meu PvP:"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   9.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FF8080&
         Height          =   255
         Index           =   5
         Left            =   120
         TabIndex        =   279
         Top             =   840
         Width           =   1095
      End
      Begin VB.Label lblMyV 
         BackColor       =   &H00FFFFFF&
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   11.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H0080FF80&
         Height          =   255
         Left            =   2280
         TabIndex        =   278
         Top             =   840
         Width           =   1335
      End
      Begin VB.Label lblMyD 
         BackColor       =   &H00FFFFFF&
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   11.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H008080FF&
         Height          =   255
         Left            =   4200
         TabIndex        =   277
         Top             =   840
         Width           =   1335
      End
      Begin VB.Label lblPvpV 
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         ForeColor       =   &H0000FF00&
         Height          =   255
         Index           =   1
         Left            =   2640
         TabIndex        =   276
         Top             =   2040
         Width           =   1095
      End
      Begin VB.Label lblPvpV 
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         ForeColor       =   &H0000FF00&
         Height          =   255
         Index           =   2
         Left            =   2640
         TabIndex        =   275
         Top             =   2400
         Width           =   1095
      End
      Begin VB.Label lblPvpV 
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         ForeColor       =   &H0000FF00&
         Height          =   255
         Index           =   3
         Left            =   2640
         TabIndex        =   274
         Top             =   2760
         Width           =   1095
      End
      Begin VB.Label lblPvpV 
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         ForeColor       =   &H0000FF00&
         Height          =   255
         Index           =   4
         Left            =   2640
         TabIndex        =   273
         Top             =   3120
         Width           =   1095
      End
      Begin VB.Label lblPvpV 
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         ForeColor       =   &H0000FF00&
         Height          =   255
         Index           =   5
         Left            =   2640
         TabIndex        =   272
         Top             =   3480
         Width           =   1095
      End
      Begin VB.Label lblPvpV 
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         ForeColor       =   &H0000FF00&
         Height          =   255
         Index           =   6
         Left            =   2640
         TabIndex        =   271
         Top             =   3840
         Width           =   1095
      End
      Begin VB.Label lblPvpV 
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         ForeColor       =   &H0000FF00&
         Height          =   255
         Index           =   7
         Left            =   2640
         TabIndex        =   270
         Top             =   4200
         Width           =   1095
      End
      Begin VB.Label lblPvpV 
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         ForeColor       =   &H0000FF00&
         Height          =   255
         Index           =   8
         Left            =   2640
         TabIndex        =   269
         Top             =   4560
         Width           =   1095
      End
      Begin VB.Label lblPvpV 
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         ForeColor       =   &H0000FF00&
         Height          =   255
         Index           =   9
         Left            =   2640
         TabIndex        =   268
         Top             =   4920
         Width           =   1095
      End
      Begin VB.Label lblPvpV 
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         ForeColor       =   &H0000FF00&
         Height          =   255
         Index           =   10
         Left            =   2640
         TabIndex        =   267
         Top             =   5280
         Width           =   1095
      End
      Begin VB.Line LinhaTops 
         BorderColor     =   &H80000009&
         Index           =   0
         X1              =   0
         X2              =   5760
         Y1              =   5280
         Y2              =   5280
      End
      Begin VB.Line LinhaTops 
         BorderColor     =   &H80000009&
         Index           =   1
         X1              =   0
         X2              =   5760
         Y1              =   4920
         Y2              =   4920
      End
      Begin VB.Line LinhaTops 
         BorderColor     =   &H80000009&
         Index           =   2
         X1              =   0
         X2              =   5760
         Y1              =   4560
         Y2              =   4560
      End
      Begin VB.Line LinhaTops 
         BorderColor     =   &H80000009&
         Index           =   3
         X1              =   0
         X2              =   5760
         Y1              =   4200
         Y2              =   4200
      End
      Begin VB.Line LinhaTops 
         BorderColor     =   &H80000009&
         Index           =   4
         X1              =   0
         X2              =   5760
         Y1              =   3840
         Y2              =   3840
      End
      Begin VB.Line LinhaTops 
         BorderColor     =   &H80000009&
         Index           =   5
         X1              =   0
         X2              =   5760
         Y1              =   3480
         Y2              =   3480
      End
      Begin VB.Line LinhaTops 
         BorderColor     =   &H80000009&
         Index           =   6
         X1              =   0
         X2              =   5760
         Y1              =   3120
         Y2              =   3120
      End
      Begin VB.Line LinhaTops 
         BorderColor     =   &H80000009&
         Index           =   7
         X1              =   0
         X2              =   5760
         Y1              =   2760
         Y2              =   2760
      End
      Begin VB.Line LinhaTops 
         BorderColor     =   &H80000009&
         Index           =   8
         X1              =   0
         X2              =   5760
         Y1              =   2400
         Y2              =   2400
      End
      Begin VB.Line LinhaTops 
         BorderColor     =   &H80000009&
         Index           =   9
         X1              =   0
         X2              =   5760
         Y1              =   2040
         Y2              =   2040
      End
      Begin VB.Label lblPvpD 
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         ForeColor       =   &H008080FF&
         Height          =   255
         Index           =   1
         Left            =   4200
         TabIndex        =   266
         Top             =   2040
         Width           =   1095
      End
      Begin VB.Label lblPvpD 
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         ForeColor       =   &H008080FF&
         Height          =   255
         Index           =   2
         Left            =   4200
         TabIndex        =   265
         Top             =   2400
         Width           =   1095
      End
      Begin VB.Label lblPvpD 
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         ForeColor       =   &H008080FF&
         Height          =   255
         Index           =   3
         Left            =   4200
         TabIndex        =   264
         Top             =   2760
         Width           =   1095
      End
      Begin VB.Label lblPvpD 
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         ForeColor       =   &H008080FF&
         Height          =   255
         Index           =   4
         Left            =   4200
         TabIndex        =   263
         Top             =   3120
         Width           =   1095
      End
      Begin VB.Label lblPvpD 
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         ForeColor       =   &H008080FF&
         Height          =   255
         Index           =   5
         Left            =   4200
         TabIndex        =   262
         Top             =   3480
         Width           =   1095
      End
      Begin VB.Label lblPvpD 
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         ForeColor       =   &H008080FF&
         Height          =   255
         Index           =   6
         Left            =   4200
         TabIndex        =   261
         Top             =   3840
         Width           =   1095
      End
      Begin VB.Label lblPvpD 
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         ForeColor       =   &H008080FF&
         Height          =   255
         Index           =   7
         Left            =   4200
         TabIndex        =   260
         Top             =   4200
         Width           =   1095
      End
      Begin VB.Label lblPvpD 
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         ForeColor       =   &H008080FF&
         Height          =   255
         Index           =   8
         Left            =   4200
         TabIndex        =   259
         Top             =   4560
         Width           =   1095
      End
      Begin VB.Label lblPvpD 
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         ForeColor       =   &H008080FF&
         Height          =   255
         Index           =   9
         Left            =   4200
         TabIndex        =   258
         Top             =   4920
         Width           =   1095
      End
      Begin VB.Label lblPvpD 
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         ForeColor       =   &H008080FF&
         Height          =   255
         Index           =   10
         Left            =   4200
         TabIndex        =   257
         Top             =   5280
         Width           =   1095
      End
      Begin VB.Label lblPvpTitulo 
         BackStyle       =   0  'Transparent
         Caption         =   "Top PvP!"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   14.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00808080&
         Height          =   495
         Index           =   0
         Left            =   2160
         TabIndex        =   256
         Top             =   1440
         Width           =   1335
      End
      Begin VB.Label lblPvpName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   1
         Left            =   120
         TabIndex        =   255
         Top             =   2040
         Width           =   2055
      End
      Begin VB.Label lblPvpName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   2
         Left            =   120
         TabIndex        =   254
         Top             =   2400
         Width           =   2055
      End
      Begin VB.Label lblPvpName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   3
         Left            =   120
         TabIndex        =   253
         Top             =   2760
         Width           =   2055
      End
      Begin VB.Label lblPvpName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   4
         Left            =   120
         TabIndex        =   252
         Top             =   3120
         Width           =   2055
      End
      Begin VB.Label lblPvpName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   5
         Left            =   120
         TabIndex        =   251
         Top             =   3480
         Width           =   2055
      End
      Begin VB.Label lblPvpName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   6
         Left            =   120
         TabIndex        =   250
         Top             =   3840
         Width           =   2055
      End
      Begin VB.Label lblPvpName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   7
         Left            =   120
         TabIndex        =   249
         Top             =   4200
         Width           =   2055
      End
      Begin VB.Label lblPvpName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   8
         Left            =   120
         TabIndex        =   248
         Top             =   4560
         Width           =   2055
      End
      Begin VB.Label lblPvpName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   9
         Left            =   120
         TabIndex        =   247
         Top             =   4920
         Width           =   2055
      End
      Begin VB.Label lblPvpName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   10
         Left            =   120
         TabIndex        =   246
         Top             =   5280
         Width           =   2055
      End
   End
   Begin VB.PictureBox picKarma 
      BackColor       =   &H00404040&
      Height          =   495
      Left            =   3000
      ScaleHeight     =   435
      ScaleWidth      =   435
      TabIndex        =   194
      Top             =   0
      Visible         =   0   'False
      Width           =   495
      Begin VB.PictureBox picTopPK 
         BackColor       =   &H00000000&
         Height          =   5775
         Left            =   4440
         ScaleHeight     =   5715
         ScaleWidth      =   3795
         TabIndex        =   196
         Top             =   600
         Width           =   3855
         Begin VB.Label lblPKPts 
            BackStyle       =   0  'Transparent
            Caption         =   "1"
            ForeColor       =   &H00808080&
            Height          =   255
            Index           =   10
            Left            =   2400
            TabIndex        =   242
            Top             =   5400
            Width           =   735
         End
         Begin VB.Label lblPKPts 
            BackStyle       =   0  'Transparent
            Caption         =   "1"
            ForeColor       =   &H00808080&
            Height          =   255
            Index           =   9
            Left            =   2400
            TabIndex        =   241
            Top             =   4920
            Width           =   735
         End
         Begin VB.Label lblPKPts 
            BackStyle       =   0  'Transparent
            Caption         =   "1"
            ForeColor       =   &H00808080&
            Height          =   255
            Index           =   8
            Left            =   2400
            TabIndex        =   240
            Top             =   4440
            Width           =   735
         End
         Begin VB.Label lblPKPts 
            BackStyle       =   0  'Transparent
            Caption         =   "1"
            ForeColor       =   &H00808080&
            Height          =   255
            Index           =   7
            Left            =   2400
            TabIndex        =   239
            Top             =   3960
            Width           =   735
         End
         Begin VB.Label lblPKPts 
            BackStyle       =   0  'Transparent
            Caption         =   "1"
            ForeColor       =   &H00808080&
            Height          =   255
            Index           =   6
            Left            =   2400
            TabIndex        =   238
            Top             =   3480
            Width           =   735
         End
         Begin VB.Label lblPKPts 
            BackStyle       =   0  'Transparent
            Caption         =   "1"
            ForeColor       =   &H00808080&
            Height          =   255
            Index           =   5
            Left            =   2400
            TabIndex        =   237
            Top             =   3000
            Width           =   735
         End
         Begin VB.Label lblPKPts 
            BackStyle       =   0  'Transparent
            Caption         =   "1"
            ForeColor       =   &H00808080&
            Height          =   255
            Index           =   4
            Left            =   2400
            TabIndex        =   236
            Top             =   2520
            Width           =   735
         End
         Begin VB.Label lblPKPts 
            BackStyle       =   0  'Transparent
            Caption         =   "1"
            ForeColor       =   &H00808080&
            Height          =   255
            Index           =   3
            Left            =   2400
            TabIndex        =   235
            Top             =   2040
            Width           =   735
         End
         Begin VB.Label lblPKPts 
            BackStyle       =   0  'Transparent
            Caption         =   "1"
            ForeColor       =   &H00808080&
            Height          =   255
            Index           =   2
            Left            =   2400
            TabIndex        =   234
            Top             =   1560
            Width           =   735
         End
         Begin VB.Label lblPKPts 
            BackStyle       =   0  'Transparent
            Caption         =   "1"
            ForeColor       =   &H00808080&
            Height          =   255
            Index           =   1
            Left            =   2400
            TabIndex        =   233
            Top             =   1080
            Width           =   735
         End
         Begin VB.Label lblPKName 
            BackStyle       =   0  'Transparent
            Caption         =   "Nenhum"
            ForeColor       =   &H000000C0&
            Height          =   255
            Index           =   10
            Left            =   120
            TabIndex        =   222
            Top             =   5400
            Width           =   1935
         End
         Begin VB.Label lblPKName 
            BackStyle       =   0  'Transparent
            Caption         =   "Nenhum"
            ForeColor       =   &H000000C0&
            Height          =   255
            Index           =   9
            Left            =   120
            TabIndex        =   221
            Top             =   4920
            Width           =   1935
         End
         Begin VB.Label lblPKName 
            BackStyle       =   0  'Transparent
            Caption         =   "Nenhum"
            ForeColor       =   &H000000C0&
            Height          =   255
            Index           =   8
            Left            =   120
            TabIndex        =   220
            Top             =   4440
            Width           =   1935
         End
         Begin VB.Label lblPKName 
            BackStyle       =   0  'Transparent
            Caption         =   "Nenhum"
            ForeColor       =   &H000000C0&
            Height          =   255
            Index           =   7
            Left            =   120
            TabIndex        =   219
            Top             =   3960
            Width           =   1935
         End
         Begin VB.Label lblPKName 
            BackStyle       =   0  'Transparent
            Caption         =   "Nenhum"
            ForeColor       =   &H000000C0&
            Height          =   255
            Index           =   6
            Left            =   120
            TabIndex        =   218
            Top             =   3480
            Width           =   1935
         End
         Begin VB.Label lblPKName 
            BackStyle       =   0  'Transparent
            Caption         =   "Nenhum"
            ForeColor       =   &H000000C0&
            Height          =   255
            Index           =   5
            Left            =   120
            TabIndex        =   217
            Top             =   3000
            Width           =   1935
         End
         Begin VB.Label lblPKName 
            BackStyle       =   0  'Transparent
            Caption         =   "Nenhum"
            ForeColor       =   &H000000C0&
            Height          =   255
            Index           =   4
            Left            =   120
            TabIndex        =   216
            Top             =   2520
            Width           =   1935
         End
         Begin VB.Label lblPKName 
            BackStyle       =   0  'Transparent
            Caption         =   "Nenhum"
            ForeColor       =   &H000000C0&
            Height          =   255
            Index           =   3
            Left            =   120
            TabIndex        =   215
            Top             =   2040
            Width           =   1935
         End
         Begin VB.Label lblPKName 
            BackStyle       =   0  'Transparent
            Caption         =   "Nenhum"
            ForeColor       =   &H000000C0&
            Height          =   255
            Index           =   2
            Left            =   120
            TabIndex        =   214
            Top             =   1560
            Width           =   1935
         End
         Begin VB.Label lblPKName 
            BackStyle       =   0  'Transparent
            Caption         =   "Nenhum"
            ForeColor       =   &H000000C0&
            Height          =   255
            Index           =   1
            Left            =   120
            TabIndex        =   213
            Top             =   1080
            Width           =   1935
         End
         Begin VB.Label lblBlank 
            BackStyle       =   0  'Transparent
            Caption         =   "Nome:"
            BeginProperty Font 
               Name            =   "Georgia"
               Size            =   9.75
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            ForeColor       =   &H00FFFFFF&
            Height          =   255
            Index           =   15
            Left            =   120
            TabIndex        =   202
            Top             =   480
            Width           =   735
         End
         Begin VB.Label lblBlank 
            BackStyle       =   0  'Transparent
            Caption         =   "Pontos:"
            BeginProperty Font 
               Name            =   "Georgia"
               Size            =   9.75
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            ForeColor       =   &H00FFFFFF&
            Height          =   255
            Index           =   16
            Left            =   2400
            TabIndex        =   201
            Top             =   480
            Width           =   855
         End
         Begin VB.Label lblBlank 
            BackStyle       =   0  'Transparent
            Caption         =   "Assassinos"
            BeginProperty Font 
               Name            =   "Georgia"
               Size            =   14.25
               Charset         =   0
               Weight          =   700
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            ForeColor       =   &H000000C0&
            Height          =   375
            Index           =   14
            Left            =   1080
            TabIndex        =   198
            Top             =   0
            Width           =   1815
         End
      End
      Begin VB.PictureBox picTopHero 
         BackColor       =   &H00000000&
         Height          =   5775
         Left            =   120
         ScaleHeight     =   5715
         ScaleWidth      =   3795
         TabIndex        =   195
         Top             =   600
         Width           =   3855
         Begin VB.Label lblHeroPts 
            BackStyle       =   0  'Transparent
            Caption         =   "1"
            ForeColor       =   &H00FFFFFF&
            Height          =   255
            Index           =   10
            Left            =   2400
            TabIndex        =   232
            Top             =   5400
            Width           =   855
         End
         Begin VB.Label lblHeroPts 
            BackStyle       =   0  'Transparent
            Caption         =   "1"
            ForeColor       =   &H00FFFFFF&
            Height          =   255
            Index           =   9
            Left            =   2400
            TabIndex        =   231
            Top             =   4920
            Width           =   855
         End
         Begin VB.Label lblHeroPts 
            BackStyle       =   0  'Transparent
            Caption         =   "1"
            ForeColor       =   &H00FFFFFF&
            Height          =   255
            Index           =   8
            Left            =   2400
            TabIndex        =   230
            Top             =   4440
            Width           =   855
         End
         Begin VB.Label lblHeroPts 
            BackStyle       =   0  'Transparent
            Caption         =   "1"
            ForeColor       =   &H00FFFFFF&
            Height          =   255
            Index           =   7
            Left            =   2400
            TabIndex        =   229
            Top             =   3960
            Width           =   855
         End
         Begin VB.Label lblHeroPts 
            BackStyle       =   0  'Transparent
            Caption         =   "1"
            ForeColor       =   &H00FFFFFF&
            Height          =   255
            Index           =   6
            Left            =   2400
            TabIndex        =   228
            Top             =   3480
            Width           =   855
         End
         Begin VB.Label lblHeroPts 
            BackStyle       =   0  'Transparent
            Caption         =   "1"
            ForeColor       =   &H00FFFFFF&
            Height          =   255
            Index           =   5
            Left            =   2400
            TabIndex        =   227
            Top             =   3000
            Width           =   855
         End
         Begin VB.Label lblHeroPts 
            BackStyle       =   0  'Transparent
            Caption         =   "1"
            ForeColor       =   &H00FFFFFF&
            Height          =   255
            Index           =   4
            Left            =   2400
            TabIndex        =   226
            Top             =   2520
            Width           =   855
         End
         Begin VB.Label lblHeroPts 
            BackStyle       =   0  'Transparent
            Caption         =   "1"
            ForeColor       =   &H00FFFFFF&
            Height          =   255
            Index           =   3
            Left            =   2400
            TabIndex        =   225
            Top             =   2040
            Width           =   855
         End
         Begin VB.Label lblHeroPts 
            BackStyle       =   0  'Transparent
            Caption         =   "1"
            ForeColor       =   &H00FFFFFF&
            Height          =   255
            Index           =   2
            Left            =   2400
            TabIndex        =   224
            Top             =   1560
            Width           =   855
         End
         Begin VB.Label lblHeroPts 
            BackStyle       =   0  'Transparent
            Caption         =   "1"
            ForeColor       =   &H00FFFFFF&
            Height          =   255
            Index           =   1
            Left            =   2400
            TabIndex        =   223
            Top             =   1080
            Width           =   1335
         End
         Begin VB.Label lblHeroName 
            BackStyle       =   0  'Transparent
            Caption         =   "Nenhum"
            ForeColor       =   &H00808000&
            Height          =   255
            Index           =   10
            Left            =   120
            TabIndex        =   212
            Top             =   5400
            Width           =   2055
         End
         Begin VB.Label lblHeroName 
            BackStyle       =   0  'Transparent
            Caption         =   "Nenhum"
            ForeColor       =   &H00808000&
            Height          =   255
            Index           =   9
            Left            =   120
            TabIndex        =   211
            Top             =   4920
            Width           =   2055
         End
         Begin VB.Label lblHeroName 
            BackStyle       =   0  'Transparent
            Caption         =   "Nenhum"
            ForeColor       =   &H00808000&
            Height          =   255
            Index           =   8
            Left            =   120
            TabIndex        =   210
            Top             =   4440
            Width           =   2055
         End
         Begin VB.Label lblHeroName 
            BackStyle       =   0  'Transparent
            Caption         =   "Nenhum"
            ForeColor       =   &H00808000&
            Height          =   255
            Index           =   7
            Left            =   120
            TabIndex        =   209
            Top             =   3960
            Width           =   2055
         End
         Begin VB.Label lblHeroName 
            BackStyle       =   0  'Transparent
            Caption         =   "Nenhum"
            ForeColor       =   &H00808000&
            Height          =   255
            Index           =   6
            Left            =   120
            TabIndex        =   208
            Top             =   3480
            Width           =   2055
         End
         Begin VB.Label lblHeroName 
            BackStyle       =   0  'Transparent
            Caption         =   "Nenhum"
            ForeColor       =   &H00808000&
            Height          =   255
            Index           =   5
            Left            =   120
            TabIndex        =   207
            Top             =   3000
            Width           =   2055
         End
         Begin VB.Label lblHeroName 
            BackStyle       =   0  'Transparent
            Caption         =   "Nenhum"
            ForeColor       =   &H00808000&
            Height          =   255
            Index           =   4
            Left            =   120
            TabIndex        =   206
            Top             =   2520
            Width           =   2055
         End
         Begin VB.Label lblHeroName 
            BackStyle       =   0  'Transparent
            Caption         =   "Nenhum"
            ForeColor       =   &H00808000&
            Height          =   255
            Index           =   3
            Left            =   120
            TabIndex        =   205
            Top             =   2040
            Width           =   2055
         End
         Begin VB.Label lblHeroName 
            BackStyle       =   0  'Transparent
            Caption         =   "Nenhum"
            ForeColor       =   &H00808000&
            Height          =   255
            Index           =   2
            Left            =   120
            TabIndex        =   204
            Top             =   1560
            Width           =   2055
         End
         Begin VB.Label lblHeroName 
            BackStyle       =   0  'Transparent
            Caption         =   "Nenhum"
            ForeColor       =   &H00808000&
            Height          =   255
            Index           =   1
            Left            =   120
            TabIndex        =   203
            Top             =   1080
            Width           =   1935
         End
         Begin VB.Label lblBlank 
            BackStyle       =   0  'Transparent
            Caption         =   "Pontos:"
            BeginProperty Font 
               Name            =   "Georgia"
               Size            =   9.75
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            ForeColor       =   &H00FFFFFF&
            Height          =   255
            Index           =   13
            Left            =   2400
            TabIndex        =   200
            Top             =   480
            Width           =   855
         End
         Begin VB.Label lblBlank 
            BackStyle       =   0  'Transparent
            Caption         =   "Nome:"
            BeginProperty Font 
               Name            =   "Georgia"
               Size            =   9.75
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            ForeColor       =   &H00FFFFFF&
            Height          =   255
            Index           =   12
            Left            =   120
            TabIndex        =   199
            Top             =   480
            Width           =   735
         End
         Begin VB.Label lblBlank 
            BackStyle       =   0  'Transparent
            Caption         =   "Heróis"
            BeginProperty Font 
               Name            =   "Georgia"
               Size            =   14.25
               Charset         =   0
               Weight          =   700
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            ForeColor       =   &H00FFFFC0&
            Height          =   375
            Index           =   11
            Left            =   1320
            TabIndex        =   197
            Top             =   0
            Width           =   1095
         End
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Zerar Karma?"
         ForeColor       =   &H00C0C0FF&
         Height          =   255
         Index           =   74
         Left            =   120
         TabIndex        =   388
         Top             =   360
         Width           =   1455
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "X"
         ForeColor       =   &H000000FF&
         Height          =   375
         Index           =   63
         Left            =   7680
         TabIndex        =   378
         Top             =   120
         Width           =   735
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "X"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H000000FF&
         Height          =   495
         Index           =   62
         Left            =   4080
         TabIndex        =   377
         Top             =   2880
         Width           =   375
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Karma"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FF8080&
         Height          =   495
         Index           =   61
         Left            =   3840
         TabIndex        =   376
         Top             =   0
         Width           =   1095
      End
      Begin VB.Label lblMyKarma 
         BackStyle       =   0  'Transparent
         Caption         =   "1"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   375
         Left            =   1320
         TabIndex        =   244
         Top             =   120
         Width           =   1095
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Meu Karma:"
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Index           =   36
         Left            =   120
         TabIndex        =   243
         Top             =   120
         Width           =   1095
      End
   End
   Begin VB.PictureBox picAjuda 
      BackColor       =   &H80000007&
      Height          =   3735
      Left            =   2880
      ScaleHeight     =   3675
      ScaleWidth      =   3675
      TabIndex        =   183
      Top             =   1560
      Visible         =   0   'False
      Width           =   3735
      Begin VB.ListBox lstAjuda 
         Height          =   2595
         ItemData        =   "frmMain.frx":797D7
         Left            =   240
         List            =   "frmMain.frx":797FF
         TabIndex        =   184
         Top             =   840
         Width           =   3135
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Central de Ajuda"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   14.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   375
         Index           =   4
         Left            =   600
         TabIndex        =   186
         Top             =   120
         Width           =   2535
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "X"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H000000FF&
         Height          =   375
         Index           =   37
         Left            =   3360
         TabIndex        =   185
         Top             =   0
         Width           =   375
      End
   End
   Begin VB.PictureBox picCharacter 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      AutoSize        =   -1  'True
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   4050
      Left            =   10080
      Picture         =   "frmMain.frx":798AB
      ScaleHeight     =   270
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   194
      TabIndex        =   159
      Top             =   4920
      Visible         =   0   'False
      Width           =   2910
      Begin VB.Label lblCharName 
         Alignment       =   2  'Center
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "Empty"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00800000&
         Height          =   225
         Left            =   360
         TabIndex        =   182
         Top             =   240
         Width           =   2160
      End
      Begin VB.Label lblCharStat 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00800000&
         Height          =   210
         Index           =   1
         Left            =   1440
         TabIndex        =   181
         Top             =   720
         Width           =   120
      End
      Begin VB.Label lblCharStat 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00800000&
         Height          =   210
         Index           =   4
         Left            =   1440
         TabIndex        =   180
         Top             =   1920
         Width           =   120
      End
      Begin VB.Label lblCharStat 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00800000&
         Height          =   210
         Index           =   2
         Left            =   1440
         TabIndex        =   179
         Top             =   1650
         Width           =   120
      End
      Begin VB.Label lblCharStat 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00800000&
         Height          =   210
         Index           =   5
         Left            =   1440
         TabIndex        =   178
         Top             =   1350
         Width           =   120
      End
      Begin VB.Label lblCharStat 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00800000&
         Height          =   210
         Index           =   3
         Left            =   1440
         TabIndex        =   177
         Top             =   1035
         Width           =   120
      End
      Begin VB.Label lblTrainStat 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "+"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   210
         Index           =   1
         Left            =   2280
         TabIndex        =   176
         Top             =   720
         Width           =   105
      End
      Begin VB.Label lblTrainStat 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "+"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   210
         Index           =   4
         Left            =   2280
         TabIndex        =   175
         Top             =   1920
         Width           =   105
      End
      Begin VB.Label lblTrainStat 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "+"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   210
         Index           =   2
         Left            =   2280
         TabIndex        =   174
         Top             =   1650
         Width           =   105
      End
      Begin VB.Label lblTrainStat 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "+"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   210
         Index           =   5
         Left            =   2280
         TabIndex        =   173
         Top             =   1350
         Width           =   105
      End
      Begin VB.Label lblTrainStat 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "+"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   210
         Index           =   3
         Left            =   2280
         TabIndex        =   172
         Top             =   1035
         Width           =   105
      End
      Begin VB.Label lblPoints 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "0"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00C0FFC0&
         Height          =   210
         Left            =   2430
         TabIndex        =   171
         Top             =   2250
         Width           =   120
      End
      Begin VB.Label lblAdd10Pts 
         BackStyle       =   0  'Transparent
         Caption         =   "+"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FF0000&
         Height          =   255
         Index           =   1
         Left            =   2520
         TabIndex        =   170
         Top             =   720
         Visible         =   0   'False
         Width           =   255
      End
      Begin VB.Label lblAdd10Pts 
         BackStyle       =   0  'Transparent
         Caption         =   "+"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FF0000&
         Height          =   255
         Index           =   2
         Left            =   2520
         TabIndex        =   169
         Top             =   1650
         Visible         =   0   'False
         Width           =   255
      End
      Begin VB.Label lblAdd10Pts 
         BackStyle       =   0  'Transparent
         Caption         =   "+"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FF0000&
         Height          =   255
         Index           =   3
         Left            =   2520
         TabIndex        =   168
         Top             =   1035
         Visible         =   0   'False
         Width           =   255
      End
      Begin VB.Label lblAdd10Pts 
         BackStyle       =   0  'Transparent
         Caption         =   "+"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FF0000&
         Height          =   255
         Index           =   4
         Left            =   2520
         TabIndex        =   167
         Top             =   1920
         Visible         =   0   'False
         Width           =   255
      End
      Begin VB.Label lblAdd10Pts 
         BackStyle       =   0  'Transparent
         Caption         =   "+"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FF0000&
         Height          =   255
         Index           =   5
         Left            =   2520
         TabIndex        =   166
         Top             =   1350
         Visible         =   0   'False
         Width           =   255
      End
      Begin VB.Label lblIsCT 
         BackStyle       =   0  'Transparent
         Caption         =   "Não"
         ForeColor       =   &H00800000&
         Height          =   255
         Left            =   2280
         TabIndex        =   165
         Top             =   2520
         Width           =   375
      End
      Begin VB.Label lblIsVIP 
         BackStyle       =   0  'Transparent
         Caption         =   "Não"
         ForeColor       =   &H00800000&
         Height          =   255
         Left            =   840
         TabIndex        =   164
         Top             =   2520
         Width           =   495
      End
      Begin VB.Label lblDiasVIP 
         BackStyle       =   0  'Transparent
         Caption         =   "~"
         ForeColor       =   &H00800000&
         Height          =   255
         Left            =   1080
         TabIndex        =   163
         Top             =   2760
         Width           =   375
      End
      Begin VB.Label lblDiasCT 
         BackStyle       =   0  'Transparent
         Caption         =   "~"
         ForeColor       =   &H00800000&
         Height          =   255
         Left            =   2520
         TabIndex        =   162
         Top             =   2760
         Width           =   375
      End
      Begin VB.Label lblVila 
         BackStyle       =   0  'Transparent
         Caption         =   "Konoha"
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   2040
         TabIndex        =   161
         Top             =   480
         Width           =   1095
      End
      Begin VB.Label lblLevel 
         BackStyle       =   0  'Transparent
         Caption         =   "Level"
         ForeColor       =   &H00800000&
         Height          =   255
         Left            =   720
         TabIndex        =   160
         Top             =   480
         Width           =   615
      End
   End
   Begin VB.ComboBox cmbChatMod 
      Height          =   315
      ItemData        =   "frmMain.frx":89620
      Left            =   0
      List            =   "frmMain.frx":89636
      Style           =   2  'Dropdown List
      TabIndex        =   156
      Top             =   9240
      Width           =   1095
   End
   Begin VB.PictureBox picTopLevel 
      BackColor       =   &H80000007&
      Height          =   495
      Left            =   3600
      ScaleHeight     =   435
      ScaleWidth      =   435
      TabIndex        =   132
      Top             =   0
      Visible         =   0   'False
      Width           =   495
      Begin VB.Label lblBlank 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "X"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   11.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H000000FF&
         Height          =   375
         Index           =   64
         Left            =   5760
         TabIndex        =   379
         Top             =   120
         Width           =   1335
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Level:"
         ForeColor       =   &H00FFFFFF&
         Height          =   375
         Index           =   10
         Left            =   5280
         TabIndex        =   321
         Top             =   1080
         Width           =   855
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Nome:"
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Index           =   8
         Left            =   3240
         TabIndex        =   320
         Top             =   1080
         Width           =   975
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Level:"
         ForeColor       =   &H00FFFFFF&
         Height          =   375
         Index           =   9
         Left            =   2040
         TabIndex        =   319
         Top             =   1080
         Width           =   855
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Nome:"
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Index           =   7
         Left            =   120
         TabIndex        =   318
         Top             =   1080
         Width           =   975
      End
      Begin VB.Label lblTopLevel 
         BackStyle       =   0  'Transparent
         Caption         =   "1"
         ForeColor       =   &H00C0FFC0&
         Height          =   255
         Index           =   20
         Left            =   5640
         TabIndex        =   301
         Top             =   6000
         Width           =   855
      End
      Begin VB.Label lblTopLevel 
         BackStyle       =   0  'Transparent
         Caption         =   "1"
         ForeColor       =   &H00C0FFC0&
         Height          =   255
         Index           =   19
         Left            =   5640
         TabIndex        =   300
         Top             =   5520
         Width           =   855
      End
      Begin VB.Label lblTopLevel 
         BackStyle       =   0  'Transparent
         Caption         =   "1"
         ForeColor       =   &H00C0FFC0&
         Height          =   255
         Index           =   18
         Left            =   5640
         TabIndex        =   299
         Top             =   5040
         Width           =   855
      End
      Begin VB.Label lblTopLevel 
         BackStyle       =   0  'Transparent
         Caption         =   "1"
         ForeColor       =   &H00C0FFC0&
         Height          =   255
         Index           =   17
         Left            =   5640
         TabIndex        =   298
         Top             =   4560
         Width           =   855
      End
      Begin VB.Label lblTopLevel 
         BackStyle       =   0  'Transparent
         Caption         =   "1"
         ForeColor       =   &H00C0FFC0&
         Height          =   255
         Index           =   16
         Left            =   5640
         TabIndex        =   297
         Top             =   4080
         Width           =   855
      End
      Begin VB.Label lblTopLevel 
         BackStyle       =   0  'Transparent
         Caption         =   "1"
         ForeColor       =   &H00C0FFC0&
         Height          =   255
         Index           =   15
         Left            =   5640
         TabIndex        =   296
         Top             =   3600
         Width           =   855
      End
      Begin VB.Label lblTopLevel 
         BackStyle       =   0  'Transparent
         Caption         =   "1"
         ForeColor       =   &H00C0FFC0&
         Height          =   255
         Index           =   14
         Left            =   5640
         TabIndex        =   295
         Top             =   3120
         Width           =   855
      End
      Begin VB.Label lblTopLevel 
         BackStyle       =   0  'Transparent
         Caption         =   "1"
         ForeColor       =   &H00C0FFC0&
         Height          =   255
         Index           =   13
         Left            =   5640
         TabIndex        =   294
         Top             =   2640
         Width           =   855
      End
      Begin VB.Label lblTopLevel 
         BackStyle       =   0  'Transparent
         Caption         =   "1"
         ForeColor       =   &H00C0FFC0&
         Height          =   255
         Index           =   12
         Left            =   5640
         TabIndex        =   293
         Top             =   2160
         Width           =   855
      End
      Begin VB.Label lblTopLevel 
         BackStyle       =   0  'Transparent
         Caption         =   "1"
         ForeColor       =   &H00C0FFC0&
         Height          =   255
         Index           =   11
         Left            =   5640
         TabIndex        =   292
         Top             =   1680
         Width           =   855
      End
      Begin VB.Label lblTopName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   20
         Left            =   3240
         TabIndex        =   291
         Top             =   6000
         Width           =   2055
      End
      Begin VB.Label lblTopName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   19
         Left            =   3240
         TabIndex        =   290
         Top             =   5520
         Width           =   2055
      End
      Begin VB.Label lblTopName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   18
         Left            =   3240
         TabIndex        =   289
         Top             =   5040
         Width           =   2055
      End
      Begin VB.Label lblTopName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   17
         Left            =   3240
         TabIndex        =   288
         Top             =   4560
         Width           =   2055
      End
      Begin VB.Label lblTopName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   16
         Left            =   3240
         TabIndex        =   287
         Top             =   4080
         Width           =   2055
      End
      Begin VB.Label lblTopName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   15
         Left            =   3240
         TabIndex        =   286
         Top             =   3600
         Width           =   2055
      End
      Begin VB.Label lblTopName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   14
         Left            =   3240
         TabIndex        =   285
         Top             =   3120
         Width           =   2055
      End
      Begin VB.Label lblTopName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   13
         Left            =   3240
         TabIndex        =   284
         Top             =   2640
         Width           =   2055
      End
      Begin VB.Label lblTopName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   12
         Left            =   3240
         TabIndex        =   283
         Top             =   2160
         Width           =   2055
      End
      Begin VB.Label lblTopName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   11
         Left            =   3240
         TabIndex        =   282
         Top             =   1680
         Width           =   2055
      End
      Begin VB.Line Line7 
         BorderColor     =   &H00FFFFFF&
         X1              =   3120
         X2              =   3120
         Y1              =   1080
         Y2              =   6600
      End
      Begin VB.Line Line6 
         BorderColor     =   &H00FFFFFF&
         X1              =   3000
         X2              =   3000
         Y1              =   1080
         Y2              =   6600
      End
      Begin VB.Label lblTopLevel 
         BackStyle       =   0  'Transparent
         Caption         =   "1"
         ForeColor       =   &H00C0FFC0&
         Height          =   255
         Index           =   10
         Left            =   2400
         TabIndex        =   155
         Top             =   6000
         Width           =   855
      End
      Begin VB.Label lblTopLevel 
         BackStyle       =   0  'Transparent
         Caption         =   "1"
         ForeColor       =   &H00C0FFC0&
         Height          =   255
         Index           =   9
         Left            =   2400
         TabIndex        =   154
         Top             =   5520
         Width           =   855
      End
      Begin VB.Label lblTopLevel 
         BackStyle       =   0  'Transparent
         Caption         =   "1"
         ForeColor       =   &H00C0FFC0&
         Height          =   255
         Index           =   8
         Left            =   2400
         TabIndex        =   153
         Top             =   5040
         Width           =   855
      End
      Begin VB.Label lblTopLevel 
         BackStyle       =   0  'Transparent
         Caption         =   "1"
         ForeColor       =   &H00C0FFC0&
         Height          =   255
         Index           =   7
         Left            =   2400
         TabIndex        =   152
         Top             =   4560
         Width           =   855
      End
      Begin VB.Label lblTopLevel 
         BackStyle       =   0  'Transparent
         Caption         =   "1"
         ForeColor       =   &H00C0FFC0&
         Height          =   255
         Index           =   6
         Left            =   2400
         TabIndex        =   151
         Top             =   4080
         Width           =   855
      End
      Begin VB.Label lblTopName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   10
         Left            =   120
         TabIndex        =   150
         Top             =   6000
         Width           =   2175
      End
      Begin VB.Label lblTopName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   9
         Left            =   120
         TabIndex        =   149
         Top             =   5520
         Width           =   2175
      End
      Begin VB.Label lblTopName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   8
         Left            =   120
         TabIndex        =   148
         Top             =   5040
         Width           =   2175
      End
      Begin VB.Label lblTopName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   7
         Left            =   120
         TabIndex        =   147
         Top             =   4560
         Width           =   2175
      End
      Begin VB.Label lblTopName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   6
         Left            =   120
         TabIndex        =   146
         Top             =   4080
         Width           =   2175
      End
      Begin VB.Label lblTopLevel 
         BackStyle       =   0  'Transparent
         Caption         =   "1"
         ForeColor       =   &H00C0FFC0&
         Height          =   255
         Index           =   5
         Left            =   2400
         TabIndex        =   142
         Top             =   3600
         Width           =   855
      End
      Begin VB.Label lblTopLevel 
         BackStyle       =   0  'Transparent
         Caption         =   "1"
         ForeColor       =   &H00C0FFC0&
         Height          =   255
         Index           =   4
         Left            =   2400
         TabIndex        =   141
         Top             =   3120
         Width           =   855
      End
      Begin VB.Label lblTopLevel 
         BackStyle       =   0  'Transparent
         Caption         =   "1"
         ForeColor       =   &H00C0FFC0&
         Height          =   255
         Index           =   3
         Left            =   2400
         TabIndex        =   140
         Top             =   2640
         Width           =   855
      End
      Begin VB.Label lblTopLevel 
         BackStyle       =   0  'Transparent
         Caption         =   "1"
         ForeColor       =   &H00C0FFC0&
         Height          =   255
         Index           =   2
         Left            =   2400
         TabIndex        =   139
         Top             =   2160
         Width           =   855
      End
      Begin VB.Label lblTopLevel 
         BackStyle       =   0  'Transparent
         Caption         =   "1"
         ForeColor       =   &H00C0FFC0&
         Height          =   255
         Index           =   1
         Left            =   2400
         TabIndex        =   138
         Top             =   1680
         Width           =   855
      End
      Begin VB.Label lblTopName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   5
         Left            =   120
         TabIndex        =   137
         Top             =   3600
         Width           =   2175
      End
      Begin VB.Label lblTopName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   4
         Left            =   120
         TabIndex        =   136
         Top             =   3120
         Width           =   2175
      End
      Begin VB.Label lblTopName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   3
         Left            =   120
         TabIndex        =   135
         Top             =   2640
         Width           =   2055
      End
      Begin VB.Label lblTopName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   2
         Left            =   120
         TabIndex        =   134
         Top             =   2160
         Width           =   2055
      End
      Begin VB.Label lblTopName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nenhum"
         ForeColor       =   &H00FFC0C0&
         Height          =   255
         Index           =   1
         Left            =   120
         TabIndex        =   133
         Top             =   1680
         Width           =   2055
      End
   End
   Begin VB.PictureBox picBarras 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      AutoSize        =   -1  'True
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   870
      Left            =   10080
      Picture         =   "frmMain.frx":89663
      ScaleHeight     =   58
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   187
      TabIndex        =   131
      Top             =   1080
      Width           =   2805
      Begin VB.Label lblEXP 
         Alignment       =   1  'Right Justify
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "100/100"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   210
         Left            =   840
         TabIndex        =   145
         Top             =   600
         Width           =   1845
      End
      Begin VB.Label lblMP 
         Alignment       =   1  'Right Justify
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "100/100"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   210
         Left            =   840
         TabIndex        =   144
         Top             =   360
         Width           =   1845
      End
      Begin VB.Label lblHP 
         Alignment       =   1  'Right Justify
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "100/100"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   210
         Left            =   840
         TabIndex        =   143
         Top             =   150
         Width           =   1845
      End
      Begin VB.Image imgHPBar 
         Height          =   240
         Left            =   0
         Top             =   150
         Width           =   3615
      End
      Begin VB.Image imgMPBar 
         Height          =   240
         Left            =   0
         Top             =   390
         Width           =   3615
      End
      Begin VB.Image imgEXPBar 
         Height          =   240
         Left            =   0
         Top             =   630
         Width           =   3615
      End
   End
   Begin VB.PictureBox PetBox 
      Appearance      =   0  'Flat
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   4050
      Left            =   10080
      ScaleHeight     =   4050
      ScaleWidth      =   2895
      TabIndex        =   121
      Top             =   4920
      Visible         =   0   'False
      Width           =   2895
      Begin VB.PictureBox picPetSprite 
         BackColor       =   &H80000007&
         Height          =   1575
         Left            =   720
         ScaleHeight     =   1515
         ScaleWidth      =   1515
         TabIndex        =   127
         Top             =   720
         Width           =   1575
      End
      Begin VB.Label Label1 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Abandonar"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   6.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   495
         Index           =   3
         Left            =   960
         TabIndex        =   126
         Top             =   3480
         Width           =   1095
      End
      Begin VB.Image PetButton 
         Height          =   555
         Index           =   4
         Left            =   0
         Top             =   3600
         Width           =   675
      End
      Begin VB.Image PetButton 
         Height          =   555
         Index           =   1
         Left            =   0
         Top             =   3600
         Width           =   675
      End
      Begin VB.Label Label1 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Explorar"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   6.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   495
         Index           =   2
         Left            =   2040
         TabIndex        =   125
         Top             =   2880
         Width           =   735
      End
      Begin VB.Label Label1 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Seguir"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   6.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   495
         Index           =   1
         Left            =   1080
         TabIndex        =   124
         Top             =   2880
         Width           =   735
      End
      Begin VB.Label Label1 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Atacar"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   6.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   495
         Index           =   0
         Left            =   120
         TabIndex        =   123
         Top             =   2880
         Width           =   735
      End
      Begin VB.Image PetButton 
         Height          =   555
         Index           =   3
         Left            =   0
         Top             =   3600
         Width           =   675
      End
      Begin VB.Image PetButton 
         Height          =   555
         Index           =   2
         Left            =   0
         Top             =   3600
         Width           =   675
      End
      Begin VB.Label lblPetName 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Pet Name"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   6.75
            Charset         =   0
            Weight          =   700
            Underline       =   -1  'True
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   120
         TabIndex        =   122
         Top             =   360
         Width           =   2655
      End
   End
   Begin VB.CommandButton cmdVIP 
      Appearance      =   0  'Flat
      BackColor       =   &H00808080&
      Caption         =   "VIP"
      BeginProperty Font 
         Name            =   "Lucida Sans Unicode"
         Size            =   11.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   10200
      MaskColor       =   &H00C0FFC0&
      Style           =   1  'Graphical
      TabIndex        =   120
      Top             =   9000
      Width           =   1215
   End
   Begin VB.PictureBox picVIP 
      BackColor       =   &H00FFFFC0&
      Height          =   495
      Left            =   4200
      ScaleHeight     =   435
      ScaleWidth      =   435
      TabIndex        =   114
      Top             =   0
      Visible         =   0   'False
      Width           =   495
      Begin VB.CheckBox chkRun 
         BackColor       =   &H00FFFFC0&
         Caption         =   "Correr Automaticamente?"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         TabIndex        =   116
         Top             =   600
         Width           =   3015
      End
      Begin VB.CheckBox chkAtk 
         BackColor       =   &H00FFFFC0&
         Caption         =   "Atacar Automaticamente?"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         TabIndex        =   115
         Top             =   960
         Width           =   2775
      End
      Begin VB.Label lblBlank 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Área OHYEH"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   255
         Index           =   96
         Left            =   600
         TabIndex        =   456
         Top             =   1800
         Width           =   1815
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Ferro"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Index           =   58
         Left            =   1200
         TabIndex        =   423
         Top             =   4200
         Width           =   615
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Cachoeira"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Index           =   57
         Left            =   1200
         TabIndex        =   422
         Top             =   3960
         Width           =   975
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Som"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Index           =   56
         Left            =   1200
         TabIndex        =   421
         Top             =   3720
         Width           =   495
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Chuva"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Index           =   48
         Left            =   1200
         TabIndex        =   420
         Top             =   3480
         Width           =   615
      End
      Begin VB.Label lblBlank 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Nuvem"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   255
         Index           =   73
         Left            =   600
         TabIndex        =   387
         Top             =   3240
         Width           =   1815
      End
      Begin VB.Label lblBlank 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Névoa"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   255
         Index           =   72
         Left            =   600
         TabIndex        =   386
         Top             =   3000
         Width           =   1815
      End
      Begin VB.Label lblBlank 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Pedra"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   255
         Index           =   71
         Left            =   600
         TabIndex        =   385
         Top             =   2760
         Width           =   1815
      End
      Begin VB.Label lblBlank 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Areia"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   255
         Index           =   70
         Left            =   600
         TabIndex        =   384
         Top             =   2520
         Width           =   1815
      End
      Begin VB.Label lblBlank 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Folha"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   255
         Index           =   69
         Left            =   600
         TabIndex        =   383
         Top             =   2280
         Width           =   1815
      End
      Begin VB.Label lblBlank 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Respawn"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   255
         Index           =   68
         Left            =   600
         TabIndex        =   382
         Top             =   2040
         Width           =   1815
      End
      Begin VB.Label lblBlank 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Área VIP"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00000000&
         Height          =   255
         Index           =   67
         Left            =   600
         TabIndex        =   381
         Top             =   1560
         Width           =   1815
      End
      Begin VB.Label lblBlank 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Teleportes"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   15.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00808000&
         Height          =   495
         Index           =   65
         Left            =   720
         TabIndex        =   380
         Top             =   1200
         Width           =   1815
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Obrigado por ajudar!!N.I.P."
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00C00000&
         Height          =   375
         Index           =   3
         Left            =   240
         TabIndex        =   119
         Top             =   4440
         Width           =   2775
      End
      Begin VB.Label lblBlank 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "VIP"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   15.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00808000&
         Height          =   495
         Index           =   1
         Left            =   600
         TabIndex        =   118
         Top             =   0
         Width           =   1815
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "x"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   14.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Index           =   66
         Left            =   2640
         TabIndex        =   117
         Top             =   0
         Width           =   495
      End
   End
   Begin VB.PictureBox picTrans 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      AutoSize        =   -1  'True
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   4050
      Left            =   10080
      ScaleHeight     =   270
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   194
      TabIndex        =   106
      Top             =   4920
      Visible         =   0   'False
      Width           =   2910
      Begin VB.PictureBox picTrans0 
         BackColor       =   &H00000000&
         Height          =   855
         Left            =   360
         ScaleHeight     =   795
         ScaleWidth      =   915
         TabIndex        =   113
         Top             =   360
         Width           =   975
      End
      Begin VB.PictureBox picTrans1 
         BackColor       =   &H00000000&
         Height          =   855
         Left            =   1560
         ScaleHeight     =   795
         ScaleWidth      =   915
         TabIndex        =   112
         Top             =   360
         Width           =   975
      End
      Begin VB.PictureBox picTrans2 
         BackColor       =   &H00000000&
         Height          =   855
         Left            =   360
         ScaleHeight     =   795
         ScaleWidth      =   915
         TabIndex        =   111
         Top             =   1320
         Width           =   975
      End
      Begin VB.PictureBox picTrans3 
         BackColor       =   &H00000000&
         Height          =   855
         Left            =   1560
         ScaleHeight     =   795
         ScaleWidth      =   915
         TabIndex        =   110
         Top             =   1320
         Width           =   975
      End
      Begin VB.PictureBox picTrans4 
         BackColor       =   &H00000000&
         Height          =   855
         Left            =   360
         ScaleHeight     =   795
         ScaleWidth      =   915
         TabIndex        =   109
         Top             =   2280
         Width           =   975
      End
      Begin VB.PictureBox picTrans5 
         BackColor       =   &H00000000&
         Height          =   855
         Left            =   1560
         ScaleHeight     =   795
         ScaleWidth      =   915
         TabIndex        =   108
         Top             =   2280
         Width           =   975
      End
      Begin VB.PictureBox picTrans6 
         BackColor       =   &H00000000&
         Height          =   855
         Left            =   960
         ScaleHeight     =   795
         ScaleWidth      =   915
         TabIndex        =   107
         Top             =   3240
         Width           =   975
      End
   End
   Begin VB.PictureBox picFala 
      BackColor       =   &H00000000&
      Height          =   1800
      Left            =   120
      ScaleHeight     =   1740
      ScaleWidth      =   7080
      TabIndex        =   101
      Top             =   7440
      Visible         =   0   'False
      Width           =   7140
      Begin VB.PictureBox picFalaNPC 
         BackColor       =   &H80000007&
         Height          =   1575
         Left            =   120
         ScaleHeight     =   1515
         ScaleWidth      =   1515
         TabIndex        =   102
         Top             =   120
         Width           =   1575
      End
      Begin VB.Label lblFalaName 
         BackStyle       =   0  'Transparent
         Caption         =   "Nome do NPC"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   11.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FF8080&
         Height          =   375
         Left            =   1800
         TabIndex        =   105
         Top             =   0
         Width           =   4935
      End
      Begin VB.Label lblFalaMsg 
         BackColor       =   &H00000000&
         Caption         =   "Msg"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   1095
         Left            =   1800
         TabIndex        =   104
         Top             =   360
         Width           =   5175
      End
      Begin VB.Label lblFalaOk 
         Alignment       =   2  'Center
         BackColor       =   &H00000000&
         Caption         =   "Ok"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   3600
         TabIndex        =   103
         Top             =   1440
         Width           =   1335
      End
   End
   Begin VB.PictureBox picQuest 
      BackColor       =   &H00000000&
      Height          =   4575
      Left            =   1320
      ScaleHeight     =   4515
      ScaleWidth      =   6915
      TabIndex        =   93
      Top             =   1080
      Visible         =   0   'False
      Width           =   6975
      Begin VB.ListBox lstPlayerQuest 
         Height          =   2010
         ItemData        =   "frmMain.frx":8B164
         Left            =   120
         List            =   "frmMain.frx":8B166
         TabIndex        =   95
         Top             =   2280
         Width           =   2295
      End
      Begin VB.PictureBox picQuestPlayer 
         BackColor       =   &H80000007&
         Height          =   1575
         Left            =   480
         ScaleHeight     =   1515
         ScaleWidth      =   1515
         TabIndex        =   94
         Top             =   600
         Width           =   1575
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Descrição:"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   9.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00E0E0E0&
         Height          =   255
         Index           =   41
         Left            =   2400
         TabIndex        =   370
         Top             =   720
         Width           =   1575
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Nome:"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   9.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00E0E0E0&
         Height          =   255
         Index           =   40
         Left            =   1560
         TabIndex        =   369
         Top             =   240
         Width           =   735
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Cancelar Missão:Nenhuma"
         ForeColor       =   &H000000C0&
         Height          =   375
         Index           =   43
         Left            =   4200
         TabIndex        =   100
         Top             =   4080
         Width           =   3135
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Atualizar Missões"
         ForeColor       =   &H00FF8080&
         Height          =   255
         Index           =   42
         Left            =   2520
         TabIndex        =   99
         Top             =   4080
         Width           =   1575
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "X"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   11.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   495
         Index           =   44
         Left            =   6480
         TabIndex        =   98
         Top             =   0
         Width           =   495
      End
      Begin VB.Label lblQuestDesc 
         BackStyle       =   0  'Transparent
         Caption         =   "--"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFC0C0&
         Height          =   2655
         Left            =   2520
         TabIndex        =   97
         Top             =   1080
         Width           =   4215
      End
      Begin VB.Label lblQuestName 
         BackStyle       =   0  'Transparent
         Caption         =   "Sem Missão"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   14.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFC0C0&
         Height          =   615
         Left            =   2400
         TabIndex        =   96
         Top             =   240
         Width           =   4935
      End
   End
   Begin VB.PictureBox picItemDesc 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   3570
      Left            =   4800
      ScaleHeight     =   238
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   210
      TabIndex        =   5
      Top             =   9360
      Visible         =   0   'False
      Width           =   3150
      Begin VB.PictureBox picItemDescPic 
         Appearance      =   0  'Flat
         AutoRedraw      =   -1  'True
         BackColor       =   &H00000000&
         BorderStyle     =   0  'None
         ForeColor       =   &H80000008&
         Height          =   960
         Left            =   1095
         ScaleHeight     =   64
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   64
         TabIndex        =   71
         Top             =   720
         Width           =   960
      End
      Begin VB.Label lblItemDesc 
         BackStyle       =   0  'Transparent
         Caption         =   """This is an example of an item's description. It  can be quite big, so we have to keep it at a decent size."""
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   1530
         Left            =   240
         TabIndex        =   70
         Top             =   1920
         Width           =   2640
      End
      Begin VB.Label lblItemName 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "N/A"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   210
         Left            =   150
         TabIndex        =   6
         Top             =   240
         Width           =   2805
      End
   End
   Begin VB.PictureBox picSpellDesc 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   3570
      Left            =   1440
      ScaleHeight     =   238
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   210
      TabIndex        =   50
      Top             =   9360
      Visible         =   0   'False
      Width           =   3150
      Begin VB.PictureBox picSpellDescPic 
         Appearance      =   0  'Flat
         AutoRedraw      =   -1  'True
         BackColor       =   &H00000000&
         BorderStyle     =   0  'None
         ForeColor       =   &H80000008&
         Height          =   960
         Left            =   1095
         ScaleHeight     =   64
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   64
         TabIndex        =   76
         Top             =   720
         Width           =   960
      End
      Begin VB.Label lblSpellDesc 
         BackStyle       =   0  'Transparent
         Caption         =   """This is an example of an item's description. It  can be quite big, so we have to keep it at a decent size."""
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   1530
         Left            =   240
         TabIndex        =   75
         Top             =   1920
         Width           =   2640
      End
      Begin VB.Label lblSpellName 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "N/A"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   210
         Left            =   120
         TabIndex        =   74
         Top             =   240
         Width           =   2805
      End
   End
   Begin VB.PictureBox picAdmin 
      Appearance      =   0  'Flat
      BackColor       =   &H00B5B5B5&
      ForeColor       =   &H80000008&
      Height          =   8010
      Left            =   9960
      ScaleHeight     =   532
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   189
      TabIndex        =   7
      Top             =   9480
      Visible         =   0   'False
      Width           =   2865
      Begin VB.CommandButton cmdSSMap 
         Caption         =   "Screenshot Map"
         Height          =   255
         Left            =   240
         TabIndex        =   78
         Top             =   7560
         Width           =   2295
      End
      Begin VB.CommandButton cmdLevel 
         Caption         =   "Level Up"
         Height          =   255
         Left            =   240
         TabIndex        =   41
         Top             =   7200
         Width           =   2295
      End
      Begin VB.CommandButton cmdAAnim 
         Caption         =   "Animation"
         Height          =   255
         Left            =   1440
         TabIndex        =   40
         Top             =   4200
         Width           =   1095
      End
      Begin VB.CommandButton cmdAAccess 
         Caption         =   "Set Access"
         Height          =   255
         Left            =   240
         TabIndex        =   39
         Top             =   1800
         Width           =   2295
      End
      Begin VB.TextBox txtAAccess 
         Height          =   285
         Left            =   1440
         TabIndex        =   37
         Top             =   720
         Width           =   1095
      End
      Begin VB.TextBox txtASprite 
         Height          =   285
         Left            =   2160
         TabIndex        =   35
         Top             =   2280
         Width           =   375
      End
      Begin VB.CommandButton cmdARespawn 
         Caption         =   "Respawn"
         Height          =   255
         Left            =   1440
         TabIndex        =   34
         Top             =   5040
         Width           =   1095
      End
      Begin VB.CommandButton cmdASprite 
         Caption         =   "Set Sprite"
         Height          =   255
         Left            =   1440
         TabIndex        =   33
         Top             =   2640
         Width           =   1095
      End
      Begin VB.CommandButton cmdASpawn 
         Caption         =   "Spawn Item"
         Height          =   255
         Left            =   240
         TabIndex        =   32
         Top             =   6720
         Width           =   2295
      End
      Begin VB.HScrollBar scrlAAmount 
         Height          =   255
         Left            =   240
         Min             =   1
         TabIndex        =   31
         Top             =   6360
         Value           =   1
         Width           =   2295
      End
      Begin VB.HScrollBar scrlAItem 
         Height          =   255
         Left            =   240
         Min             =   1
         TabIndex        =   29
         Top             =   5760
         Value           =   1
         Width           =   2295
      End
      Begin VB.CommandButton cmdASpell 
         Caption         =   "Spell"
         Height          =   255
         Left            =   1440
         TabIndex        =   27
         Top             =   3840
         Width           =   1095
      End
      Begin VB.CommandButton cmdAShop 
         Caption         =   "Shop"
         Height          =   255
         Left            =   240
         TabIndex        =   26
         Top             =   4200
         Width           =   1095
      End
      Begin VB.CommandButton cmdAResource 
         Caption         =   "Resource"
         Height          =   255
         Left            =   1440
         TabIndex        =   25
         Top             =   3480
         Width           =   1095
      End
      Begin VB.CommandButton cmdANpc 
         Caption         =   "NPC"
         Height          =   255
         Left            =   240
         TabIndex        =   24
         Top             =   3840
         Width           =   1095
      End
      Begin VB.CommandButton cmdAMap 
         Caption         =   "Map"
         Height          =   255
         Left            =   1440
         TabIndex        =   23
         Top             =   3120
         Width           =   1095
      End
      Begin VB.CommandButton cmdAItem 
         Caption         =   "Item"
         Height          =   255
         Left            =   240
         TabIndex        =   21
         Top             =   3480
         Width           =   1095
      End
      Begin VB.CommandButton cmdADestroy 
         Caption         =   "Del Bans"
         Height          =   255
         Left            =   240
         TabIndex        =   20
         Top             =   5040
         Width           =   1095
      End
      Begin VB.CommandButton cmdAMapReport 
         Caption         =   "Map Report"
         Height          =   255
         Left            =   1440
         TabIndex        =   19
         Top             =   4680
         Width           =   1095
      End
      Begin VB.CommandButton cmdALoc 
         Caption         =   "Loc"
         Height          =   255
         Left            =   240
         TabIndex        =   18
         Top             =   4680
         Width           =   1095
      End
      Begin VB.CommandButton cmdAWarp 
         Caption         =   "Warp To"
         Height          =   255
         Left            =   240
         TabIndex        =   17
         Top             =   2640
         Width           =   1095
      End
      Begin VB.TextBox txtAMap 
         Height          =   285
         Left            =   960
         TabIndex        =   15
         Top             =   2280
         Width           =   375
      End
      Begin VB.CommandButton cmdAWarpMe2 
         Caption         =   "WarpMe2"
         Height          =   255
         Left            =   1440
         TabIndex        =   14
         Top             =   1440
         Width           =   1095
      End
      Begin VB.CommandButton cmdAWarp2Me 
         Caption         =   "Warp2Me"
         Height          =   255
         Left            =   240
         TabIndex        =   13
         Top             =   1440
         Width           =   1095
      End
      Begin VB.CommandButton cmdABan 
         Caption         =   "Ban"
         Height          =   255
         Left            =   1440
         TabIndex        =   12
         Top             =   1080
         Width           =   1095
      End
      Begin VB.CommandButton cmdAKick 
         Caption         =   "Kick"
         Height          =   255
         Left            =   240
         TabIndex        =   11
         Top             =   1080
         Width           =   1095
      End
      Begin VB.TextBox txtAName 
         Height          =   285
         Left            =   240
         TabIndex        =   9
         Top             =   720
         Width           =   1095
      End
      Begin VB.Line Line5 
         X1              =   16
         X2              =   168
         Y1              =   472
         Y2              =   472
      End
      Begin VB.Label Label33 
         BackStyle       =   0  'Transparent
         Caption         =   "Access:"
         Height          =   255
         Left            =   1440
         TabIndex        =   38
         Top             =   480
         Width           =   1095
      End
      Begin VB.Label Label31 
         BackStyle       =   0  'Transparent
         Caption         =   "Sprite#:"
         Height          =   255
         Left            =   1440
         TabIndex        =   36
         Top             =   2280
         Width           =   1095
      End
      Begin VB.Label lblAAmount 
         BackStyle       =   0  'Transparent
         Caption         =   "Amount: 1"
         Height          =   255
         Left            =   240
         TabIndex        =   30
         Top             =   6120
         Width           =   2295
      End
      Begin VB.Label lblAItem 
         BackStyle       =   0  'Transparent
         Caption         =   "Spawn Item: None"
         Height          =   255
         Left            =   240
         TabIndex        =   28
         Top             =   5520
         Width           =   2295
      End
      Begin VB.Line Line4 
         X1              =   16
         X2              =   168
         Y1              =   360
         Y2              =   360
      End
      Begin VB.Line Line3 
         X1              =   16
         X2              =   168
         Y1              =   304
         Y2              =   304
      End
      Begin VB.Label Label32 
         BackStyle       =   0  'Transparent
         Caption         =   "Editors:"
         Height          =   255
         Left            =   240
         TabIndex        =   22
         Top             =   3120
         Width           =   2295
      End
      Begin VB.Line Line2 
         X1              =   16
         X2              =   168
         Y1              =   200
         Y2              =   200
      End
      Begin VB.Label Label30 
         BackStyle       =   0  'Transparent
         Caption         =   "Map#:"
         Height          =   255
         Left            =   240
         TabIndex        =   16
         Top             =   2280
         Width           =   1095
      End
      Begin VB.Line Line1 
         X1              =   16
         X2              =   168
         Y1              =   144
         Y2              =   144
      End
      Begin VB.Label Label29 
         BackStyle       =   0  'Transparent
         Caption         =   "Name:"
         Height          =   255
         Left            =   240
         TabIndex        =   10
         Top             =   480
         Width           =   1095
      End
      Begin VB.Label Label28 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Admin Panel"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   14.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   120
         TabIndex        =   8
         Top             =   120
         Width           =   2865
      End
   End
   Begin VB.PictureBox picDialogue 
      Appearance      =   0  'Flat
      BackColor       =   &H000C0E10&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   2085
      Left            =   6480
      ScaleHeight     =   2085
      ScaleWidth      =   7140
      TabIndex        =   80
      Top             =   11880
      Visible         =   0   'False
      Width           =   7140
      Begin VB.Label lblDialogue_Button 
         Alignment       =   2  'Center
         AutoSize        =   -1  'True
         BackColor       =   &H00000000&
         BackStyle       =   0  'Transparent
         Caption         =   "Okay"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   210
         Index           =   1
         Left            =   3285
         TabIndex        =   85
         Top             =   1440
         Width           =   525
      End
      Begin VB.Label lblDialogue_Text 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Robin has requested a trade. Would you like to accept?"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   495
         Left            =   240
         TabIndex        =   84
         Top             =   720
         Width           =   6615
      End
      Begin VB.Label lblDialogue_Title 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Trade Request"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   120
         TabIndex        =   83
         Top             =   480
         Width           =   6855
      End
      Begin VB.Label lblDialogue_Button 
         Alignment       =   2  'Center
         AutoSize        =   -1  'True
         BackColor       =   &H00000000&
         BackStyle       =   0  'Transparent
         Caption         =   "Yes"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   210
         Index           =   2
         Left            =   3375
         TabIndex        =   82
         Top             =   1320
         Width           =   345
      End
      Begin VB.Label lblDialogue_Button 
         Alignment       =   2  'Center
         AutoSize        =   -1  'True
         BackColor       =   &H00000000&
         BackStyle       =   0  'Transparent
         Caption         =   "No"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   210
         Index           =   3
         Left            =   3405
         TabIndex        =   81
         Top             =   1560
         Width           =   285
      End
   End
   Begin VB.PictureBox picCurrency 
      Appearance      =   0  'Flat
      BackColor       =   &H000C0E10&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   2085
      Left            =   6480
      ScaleHeight     =   2085
      ScaleWidth      =   7140
      TabIndex        =   43
      Top             =   9720
      Visible         =   0   'False
      Width           =   7140
      Begin VB.TextBox txtCurrency 
         Appearance      =   0  'Flat
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   2160
         TabIndex        =   45
         Top             =   840
         Width           =   2775
      End
      Begin VB.Label lblCurrencyCancel 
         Alignment       =   2  'Center
         AutoSize        =   -1  'True
         BackColor       =   &H00000000&
         BackStyle       =   0  'Transparent
         Caption         =   "Cancel"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   210
         Left            =   3240
         TabIndex        =   47
         Top             =   1440
         Width           =   615
      End
      Begin VB.Label lblCurrencyOk 
         Alignment       =   2  'Center
         AutoSize        =   -1  'True
         BackColor       =   &H00000000&
         BackStyle       =   0  'Transparent
         Caption         =   "Okay"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   210
         Left            =   3300
         TabIndex        =   46
         Top             =   1200
         Width           =   495
      End
      Begin VB.Label lblCurrency 
         Alignment       =   2  'Center
         BackColor       =   &H00000000&
         BackStyle       =   0  'Transparent
         Caption         =   "How many do you want to drop?"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   1680
         TabIndex        =   44
         Top             =   480
         Width           =   3855
      End
   End
   Begin VB.PictureBox picTempInv 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      AutoSize        =   -1  'True
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   540
      Left            =   6480
      ScaleHeight     =   36
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   36
      TabIndex        =   4
      Top             =   9480
      Visible         =   0   'False
      Width           =   540
   End
   Begin VB.PictureBox picTempBank 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      AutoSize        =   -1  'True
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   540
      Left            =   7080
      ScaleHeight     =   36
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   36
      TabIndex        =   61
      Top             =   9480
      Visible         =   0   'False
      Width           =   540
   End
   Begin VB.PictureBox picTempSpell 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      AutoSize        =   -1  'True
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   540
      Left            =   7680
      ScaleHeight     =   36
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   36
      TabIndex        =   77
      Top             =   9480
      Visible         =   0   'False
      Width           =   540
   End
   Begin VB.PictureBox picParty 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      AutoSize        =   -1  'True
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   4050
      Left            =   10080
      ScaleHeight     =   270
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   194
      TabIndex        =   86
      Top             =   4920
      Visible         =   0   'False
      Width           =   2910
      Begin VB.Image imgPartySpirit 
         Height          =   135
         Index           =   4
         Left            =   90
         Top             =   3075
         Visible         =   0   'False
         Width           =   2730
      End
      Begin VB.Image imgPartyHealth 
         Height          =   135
         Index           =   4
         Left            =   90
         Top             =   2940
         Visible         =   0   'False
         Width           =   2730
      End
      Begin VB.Image imgPartySpirit 
         Height          =   135
         Index           =   3
         Left            =   90
         Top             =   2340
         Visible         =   0   'False
         Width           =   2730
      End
      Begin VB.Image imgPartyHealth 
         Height          =   135
         Index           =   3
         Left            =   90
         Top             =   2205
         Visible         =   0   'False
         Width           =   2730
      End
      Begin VB.Image imgPartySpirit 
         Height          =   135
         Index           =   2
         Left            =   90
         Top             =   1620
         Visible         =   0   'False
         Width           =   2730
      End
      Begin VB.Image imgPartyHealth 
         Height          =   135
         Index           =   2
         Left            =   90
         Top             =   1485
         Visible         =   0   'False
         Width           =   2730
      End
      Begin VB.Image imgPartySpirit 
         Height          =   135
         Index           =   1
         Left            =   90
         Top             =   870
         Visible         =   0   'False
         Width           =   2730
      End
      Begin VB.Image imgPartyHealth 
         Height          =   135
         Index           =   1
         Left            =   90
         Top             =   735
         Visible         =   0   'False
         Width           =   2730
      End
      Begin VB.Label lblPartyLeave 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   375
         Left            =   1560
         TabIndex        =   92
         Top             =   3480
         Width           =   1095
      End
      Begin VB.Label lblPartyInvite 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   375
         Left            =   240
         TabIndex        =   91
         Top             =   3480
         Width           =   1095
      End
      Begin VB.Label lblPartyMember 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Index           =   4
         Left            =   240
         TabIndex        =   90
         Top             =   2670
         Width           =   2415
      End
      Begin VB.Label lblPartyMember 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Index           =   3
         Left            =   240
         TabIndex        =   89
         Top             =   1935
         Width           =   2415
      End
      Begin VB.Label lblPartyMember 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Index           =   2
         Left            =   240
         TabIndex        =   88
         Top             =   1200
         Width           =   2415
      End
      Begin VB.Label lblPartyMember 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Index           =   1
         Left            =   240
         TabIndex        =   87
         Top             =   465
         Width           =   2415
      End
   End
   Begin VB.PictureBox picSSMap 
      AutoRedraw      =   -1  'True
      BorderStyle     =   0  'None
      Height          =   255
      Left            =   13320
      ScaleHeight     =   255
      ScaleWidth      =   255
      TabIndex        =   79
      Top             =   8040
      Width           =   255
   End
   Begin VB.PictureBox picTrade 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      BackColor       =   &H00E0E0E0&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   5760
      Left            =   1200
      ScaleHeight     =   384
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   480
      TabIndex        =   62
      Top             =   720
      Visible         =   0   'False
      Width           =   7200
      Begin VB.PictureBox picTheirTrade 
         Appearance      =   0  'Flat
         AutoRedraw      =   -1  'True
         BackColor       =   &H00000000&
         BorderStyle     =   0  'None
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H80000008&
         Height          =   3705
         Left            =   3855
         ScaleHeight     =   247
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   193
         TabIndex        =   64
         Top             =   465
         Width           =   2895
      End
      Begin VB.PictureBox picYourTrade 
         Appearance      =   0  'Flat
         AutoRedraw      =   -1  'True
         BackColor       =   &H00000000&
         BorderStyle     =   0  'None
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H80000008&
         Height          =   3705
         Left            =   435
         ScaleHeight     =   247
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   193
         TabIndex        =   63
         Top             =   465
         Width           =   2895
      End
      Begin VB.Image imgDeclineTrade 
         Height          =   435
         Left            =   3675
         Top             =   5040
         Width           =   1035
      End
      Begin VB.Image imgAcceptTrade 
         Height          =   435
         Left            =   2475
         Top             =   5040
         Width           =   1035
      End
      Begin VB.Label lblTradeStatus 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H000000C0&
         Height          =   255
         Left            =   600
         TabIndex        =   67
         Top             =   5520
         Width           =   5895
      End
      Begin VB.Label lblTheirWorth 
         BackStyle       =   0  'Transparent
         Caption         =   "1234567890"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   5160
         TabIndex        =   66
         Top             =   4500
         Width           =   1815
      End
      Begin VB.Label lblYourWorth 
         BackStyle       =   0  'Transparent
         Caption         =   "1234567890"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   1680
         TabIndex        =   65
         Top             =   4500
         Width           =   1815
      End
   End
   Begin VB.PictureBox picCover 
      Appearance      =   0  'Flat
      BackColor       =   &H00181C21&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   210
      Left            =   13320
      ScaleHeight     =   14
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   17
      TabIndex        =   73
      Top             =   8400
      Visible         =   0   'False
      Width           =   255
   End
   Begin VB.PictureBox picHotbar 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      AutoSize        =   -1  'True
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   540
      Left            =   180
      ScaleHeight     =   36
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   476
      TabIndex        =   72
      Top             =   7320
      Width           =   7140
   End
   Begin RichTextLib.RichTextBox txtChat 
      Height          =   1800
      Left            =   180
      TabIndex        =   1
      Top             =   7440
      Width           =   7140
      _ExtentX        =   12594
      _ExtentY        =   3175
      _Version        =   393217
      BackColor       =   790032
      BorderStyle     =   0
      ScrollBars      =   2
      Appearance      =   0
      TextRTF         =   $"frmMain.frx":8B168
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "Georgia"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
   End
   Begin VB.TextBox txtMyChat 
      Appearance      =   0  'Flat
      BackColor       =   &H00404040&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "Georgia"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   225
      Left            =   1200
      TabIndex        =   2
      Top             =   9240
      Width           =   6120
   End
   Begin VB.PictureBox picBank 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      AutoSize        =   -1  'True
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   5760
      Left            =   1080
      ScaleHeight     =   384
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   480
      TabIndex        =   60
      Top             =   720
      Visible         =   0   'False
      Width           =   7200
   End
   Begin VB.PictureBox picShop 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H00E0E0E0&
      BorderStyle     =   0  'None
      ForeColor       =   &H80000008&
      Height          =   5115
      Left            =   2520
      ScaleHeight     =   341
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   275
      TabIndex        =   48
      Top             =   1080
      Visible         =   0   'False
      Width           =   4125
      Begin VB.PictureBox picShopItems 
         Appearance      =   0  'Flat
         AutoRedraw      =   -1  'True
         BackColor       =   &H00000000&
         BorderStyle     =   0  'None
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   9.75
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H80000008&
         Height          =   3165
         Left            =   615
         ScaleHeight     =   211
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   193
         TabIndex        =   49
         Top             =   630
         Width           =   2895
      End
      Begin VB.Image imgLeaveShop 
         Height          =   435
         Left            =   2715
         Top             =   4350
         Width           =   1035
      End
      Begin VB.Image imgShopSell 
         Height          =   435
         Left            =   1545
         Top             =   4350
         Width           =   1035
      End
      Begin VB.Image imgShopBuy 
         Height          =   435
         Left            =   375
         Top             =   4350
         Width           =   1035
      End
   End
   Begin VB.PictureBox picScreen 
      Appearance      =   0  'Flat
      BackColor       =   &H00808000&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   7200
      Left            =   120
      ScaleHeight     =   480
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   640
      TabIndex        =   0
      Top             =   165
      Visible         =   0   'False
      Width           =   9600
      Begin VB.PictureBox picStun 
         Appearance      =   0  'Flat
         BackColor       =   &H80000005&
         ForeColor       =   &H80000008&
         Height          =   480
         Left            =   120
         ScaleHeight     =   450
         ScaleWidth      =   450
         TabIndex        =   281
         Top             =   6600
         Visible         =   0   'False
         Width           =   480
      End
      Begin VB.Timer tmrAntHack 
         Interval        =   1000
         Left            =   8640
         Top             =   120
      End
      Begin MSWinsockLib.Winsock Socket 
         Left            =   0
         Top             =   0
         _ExtentX        =   741
         _ExtentY        =   741
         _Version        =   393216
      End
   End
   Begin VB.PictureBox picSpells 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      AutoSize        =   -1  'True
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   4050
      Left            =   10080
      ScaleHeight     =   270
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   194
      TabIndex        =   42
      Top             =   4920
      Visible         =   0   'False
      Width           =   2910
   End
   Begin VB.PictureBox picOptions 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      AutoSize        =   -1  'True
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   4050
      Left            =   10080
      ScaleHeight     =   270
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   194
      TabIndex        =   51
      Top             =   4920
      Visible         =   0   'False
      Width           =   2910
      Begin VB.CheckBox chkWASD 
         BackColor       =   &H00000000&
         Caption         =   "Movimento WASD"
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   240
         TabIndex        =   336
         Top             =   3240
         Width           =   2415
      End
      Begin VB.CheckBox chkDesafios 
         BackColor       =   &H00000000&
         Caption         =   "Desafios:"
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   240
         TabIndex        =   335
         Top             =   3480
         Width           =   2295
      End
      Begin VB.CheckBox chkMsgPrivada 
         BackColor       =   &H00000000&
         Caption         =   "MensagemPrivada:"
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   240
         TabIndex        =   332
         Top             =   3720
         Width           =   2535
      End
      Begin VB.CheckBox chkHotbarOff 
         BackColor       =   &H00000000&
         Caption         =   "1~+"
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   1320
         TabIndex        =   193
         Top             =   2760
         Width           =   1095
      End
      Begin VB.CheckBox chkHotBar 
         BackColor       =   &H00000000&
         Caption         =   "F1~F12"
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   240
         TabIndex        =   192
         Top             =   2760
         Width           =   975
      End
      Begin VB.CheckBox chkNomeLevelOff 
         BackColor       =   &H00000000&
         Caption         =   "Off"
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   960
         TabIndex        =   191
         Top             =   2280
         Width           =   735
      End
      Begin VB.CheckBox chkNomeLevel 
         BackColor       =   &H00000000&
         Caption         =   "ON"
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   240
         TabIndex        =   190
         Top             =   2280
         Width           =   615
      End
      Begin VB.CheckBox chkAutoTileOff 
         BackColor       =   &H00000000&
         Caption         =   "Off"
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   960
         TabIndex        =   189
         Top             =   1680
         Width           =   735
      End
      Begin VB.CheckBox chkAutoTile 
         BackColor       =   &H00000000&
         Caption         =   "ON"
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   240
         TabIndex        =   188
         Top             =   1680
         Width           =   615
      End
      Begin VB.PictureBox Picture4 
         BackColor       =   &H00000000&
         BorderStyle     =   0  'None
         Height          =   255
         Left            =   240
         ScaleHeight     =   255
         ScaleWidth      =   1935
         TabIndex        =   57
         Top             =   960
         Width           =   1935
         Begin VB.OptionButton optSOn 
            Appearance      =   0  'Flat
            BackColor       =   &H00000000&
            Caption         =   "On"
            BeginProperty Font 
               Name            =   "Georgia"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            ForeColor       =   &H00FFFFFF&
            Height          =   255
            Left            =   0
            TabIndex        =   59
            Top             =   0
            Width           =   735
         End
         Begin VB.OptionButton optSOff 
            Appearance      =   0  'Flat
            BackColor       =   &H00000000&
            Caption         =   "Off"
            BeginProperty Font 
               Name            =   "Georgia"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            ForeColor       =   &H00FFFFFF&
            Height          =   255
            Left            =   720
            TabIndex        =   58
            Top             =   0
            Width           =   735
         End
      End
      Begin VB.PictureBox Picture3 
         BackColor       =   &H00000000&
         BorderStyle     =   0  'None
         Height          =   255
         Left            =   240
         ScaleHeight     =   255
         ScaleWidth      =   1935
         TabIndex        =   54
         Top             =   360
         Width           =   1935
         Begin VB.OptionButton optMOff 
            Appearance      =   0  'Flat
            BackColor       =   &H00000000&
            Caption         =   "Off"
            BeginProperty Font 
               Name            =   "Georgia"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            ForeColor       =   &H00FFFFFF&
            Height          =   255
            Left            =   720
            TabIndex        =   56
            Top             =   0
            Width           =   735
         End
         Begin VB.OptionButton optMOn 
            Appearance      =   0  'Flat
            BackColor       =   &H00000000&
            Caption         =   "On"
            BeginProperty Font 
               Name            =   "Georgia"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            ForeColor       =   &H00FFFFFF&
            Height          =   255
            Left            =   0
            TabIndex        =   55
            Top             =   0
            Width           =   735
         End
      End
      Begin VB.Label LblHotbarOpt 
         BackStyle       =   0  'Transparent
         Caption         =   "HotBar"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   240
         TabIndex        =   187
         Top             =   2520
         Width           =   1815
      End
      Begin VB.Label Label20 
         BackStyle       =   0  'Transparent
         Caption         =   "Level ao lado do Nome"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   9
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   240
         TabIndex        =   158
         Top             =   2040
         Width           =   2295
      End
      Begin VB.Label Label18 
         BackStyle       =   0  'Transparent
         Caption         =   "AutoTile"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   255
         Left            =   240
         TabIndex        =   157
         Top             =   1320
         Width           =   1335
      End
      Begin VB.Label Label49 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "Sound"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   210
         Left            =   240
         TabIndex        =   53
         Top             =   720
         Width           =   600
      End
      Begin VB.Label Label48 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "Music"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   210
         Left            =   240
         TabIndex        =   52
         Top             =   120
         Width           =   555
      End
   End
   Begin VB.PictureBox picInventory 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      BackColor       =   &H00000000&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   4050
      Left            =   10080
      ScaleHeight     =   270
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   193
      TabIndex        =   3
      Top             =   4920
      Width           =   2895
   End
   Begin VB.Label lblBlank 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H008080FF&
      BorderStyle     =   1  'Fixed Single
      Caption         =   "x"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   12
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   375
      Index           =   6
      Left            =   12840
      TabIndex        =   413
      Top             =   0
      Width           =   375
   End
   Begin VB.Label lblBlank 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H00808080&
      BorderStyle     =   1  'Fixed Single
      Caption         =   "-"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   14.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000005&
      Height          =   375
      Index           =   5
      Left            =   12360
      TabIndex        =   412
      Top             =   0
      Width           =   375
   End
   Begin VB.Image imgButton 
      Height          =   495
      Index           =   6
      Left            =   11520
      Top             =   4440
      Width           =   1695
   End
   Begin VB.Image imgButton 
      Height          =   495
      Index           =   4
      Left            =   9720
      Top             =   4440
      Width           =   1695
   End
   Begin VB.Image imgButton 
      Height          =   495
      Index           =   9
      Left            =   11520
      Top             =   3840
      Width           =   1695
   End
   Begin VB.Image imgButton 
      Height          =   495
      Index           =   5
      Left            =   9720
      Top             =   3840
      Width           =   1695
   End
   Begin VB.Image imgButton 
      Height          =   495
      Index           =   7
      Left            =   11520
      Top             =   3240
      Width           =   1695
   End
   Begin VB.Image imgButton 
      Height          =   495
      Index           =   2
      Left            =   9720
      Top             =   3240
      Width           =   1815
   End
   Begin VB.Image imgButton 
      Height          =   495
      Index           =   1
      Left            =   11520
      Top             =   2640
      Width           =   1695
   End
   Begin VB.Image imgButton 
      Height          =   495
      Index           =   8
      Left            =   9720
      Top             =   2640
      Width           =   1695
   End
   Begin VB.Image imgButton 
      Height          =   495
      Index           =   10
      Left            =   11640
      Top             =   2040
      Width           =   1575
   End
   Begin VB.Image imgButton 
      Height          =   495
      Index           =   3
      Left            =   9720
      Top             =   2040
      Width           =   1935
   End
   Begin VB.Label lblInfoChat 
      BackStyle       =   0  'Transparent
      Caption         =   "Chat"
      BeginProperty Font 
         Name            =   "Georgia"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   120
      TabIndex        =   130
      Top             =   9240
      Width           =   615
   End
   Begin VB.Label Label9 
      BackStyle       =   0  'Transparent
      Caption         =   "Ping:"
      BeginProperty Font 
         Name            =   "Comic Sans MS"
         Size            =   11.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   9960
      TabIndex        =   129
      Top             =   360
      Visible         =   0   'False
      Width           =   615
   End
   Begin VB.Label lblYens 
      BackStyle       =   0  'Transparent
      Caption         =   "Yens:"
      BeginProperty Font 
         Name            =   "Comic Sans MS"
         Size            =   11.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   9960
      TabIndex        =   128
      Top             =   720
      Visible         =   0   'False
      Width           =   735
   End
   Begin VB.Image imgButton 
      Height          =   435
      Index           =   0
      Left            =   0
      Top             =   0
      Width           =   1035
   End
   Begin VB.Label lblPing 
      AutoSize        =   -1  'True
      BackStyle       =   0  'Transparent
      Caption         =   "Local"
      BeginProperty Font 
         Name            =   "Georgia"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   210
      Left            =   11160
      TabIndex        =   69
      Top             =   1560
      Visible         =   0   'False
      Width           =   450
   End
   Begin VB.Label lblGold 
      AutoSize        =   -1  'True
      BackStyle       =   0  'Transparent
      Caption         =   "0g"
      BeginProperty Font 
         Name            =   "Georgia"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   210
      Left            =   11160
      TabIndex        =   68
      Top             =   1320
      Visible         =   0   'False
      Width           =   225
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
' ************
' ** Events **
' ************
'
Private Declare Function ExitWindowsEx Lib "user32" (ByVal uFlags As Long, ByVal dwReserved As Long) As Long

Private MoveForm As Boolean
Private MouseX As Long
Private MouseY As Long
Private PresentX As Long
Private PresentY As Long



Private Sub chkAutoTile_Click()
If chkAutoTile.value = YES Then
    Options.AutoTile = 0
    chkAutoTileOff.value = NO
    SaveOptions
Else
    Options.AutoTile = 1
    SaveOptions
    chkAutoTile.value = NO
    chkAutoTileOff.value = YES
End If

End Sub

Private Sub chkAutoTileOff_Click()
If chkAutoTileOff.value = YES Then
    Options.AutoTile = 1
    chkAutoTile.value = NO
    SaveOptions
Else
    Options.AutoTile = 0
    chkAutoTile.value = YES
    SaveOptions
    chkAutoTileOff.value = NO
End If
End Sub

Private Sub chkDesafios_Click()
If chkDesafios.value = NO Then
    chkDesafios.Caption = "Desafios:Não"
    Options.Desafios = NO
Else
    chkDesafios.Caption = "Desafios:Sim"
    Options.Desafios = YES
End If

SaveOptions

End Sub

Private Sub chkHotBar_Click()
If chkHotBar.value = YES Then
    Options.Hotbar = 0
    chkHotbarOff.value = NO
    SaveOptions
    BltHotbar
Else
    Options.Hotbar = 1
    SaveOptions
    chkHotBar.value = NO
    chkHotbarOff.value = YES
    BltHotbar
End If
End Sub

Private Sub chkHotBaroff_Click()

If chkHotbarOff.value = YES Then
    Options.Hotbar = 1
    chkHotBar.value = NO
    SaveOptions
    BltHotbar
Else
    Options.Hotbar = 0
    SaveOptions
    chkHotbarOff.value = NO
    chkHotBar.value = YES
    BltHotbar
End If
End Sub

Private Sub chkMsgPrivada_Click()
If chkMsgPrivada.value = NO Then
    chkMsgPrivada.Caption = "MensagemPrivada:Não"
    Options.MsgPrivada = NO
Else
    chkMsgPrivada.Caption = "MensagemPrivada:Sim"
    Options.MsgPrivada = YES
End If

SaveOptions

End Sub

Private Sub chkNomeLevel_Click()
If chkNomeLevel.value = YES Then
    Options.NomeLevel = 0
    chkNomeLevelOff.value = NO
    SaveOptions
Else
    Options.NomeLevel = 1
    SaveOptions
    chkNomeLevel.value = NO
    chkNomeLevelOff.value = YES
End If
End Sub

Private Sub chkNomeLevelOFF_Click()
If chkNomeLevelOff.value = YES Then
    Options.NomeLevel = 1
    chkNomeLevel.value = NO
    SaveOptions
Else
    Options.NomeLevel = 0
    SaveOptions
    chkNomeLevelOff.value = NO
    chkNomeLevel.value = YES
End If
End Sub

Private Sub chkWASD_Click()
If chkWASD.value = NO Then
    chkWASD.Caption = "Movimento WASD:Não"
    Options.WASD = NO
Else
    chkWASD.Caption = "Movimento WASD:Sim"
    Options.WASD = YES
End If

SaveOptions
End Sub



Private Sub cmbArenaNum_Click()
        Select Case cmbArenaNum.text
            Case "Floresta"
                DesafioArena = 1
            Case "Vale do Fim"
                DesafioArena = 2
            Case "Campo de Treino"
                DesafioArena = 3
            Case "Deserto"
                 DesafioArena = 4
            Case "Arena Livre"
                DesafioArena = 5
            Case "Floresta da Morte"
                DesafioArena = 6
            Case "Arena Livre 2"
                DesafioArena = 7
            Case "Esconderijo Akatsuki"
                DesafioArena = 8
            Case "Esconderijo Orochimaru"
                DesafioArena = 9
            Case Else
                DesafioArena = NO
                cmbArenaNum.text = "NENHUMA LIVRE"
        End Select
        
        lblDesafio(4).Caption = cmbArenaNum.text
        frmMain.picArena.Picture = LoadPicture(App.Path & "\data files\graphics\Arenas\" & DesafioArena & ".jpg")
    

End Sub



Private Sub cmbArenaTipo_Click()
Dim i As Byte

lblDesafio(9).Caption = vbNullString
cmDesafio(2).Visible = False

For i = 1 To 3
    NomesDesafio(i) = vbNullString
Next
cmDesafio(0).Visible = True

Select Case cmbArenaTipo.ListIndex
    Case 0 '1x1
        cmDesafio(0).Caption = "Selecionar oponente"
    Case 1 '1x2
        cmDesafio(0).Caption = "Selecionar oponente número 1"
    Case 2, 3 '2x1 2x2
        cmDesafio(0).Caption = "Selecionar seu parceiro"
    Case Else
End Select

End Sub

Private Sub cmbChatMod_Click()

If cmbChatMod.text = "Privado" Then
    SendRequestPlayerNames
    frmMain.picChatInvite.Visible = True
End If


End Sub



Private Sub cmdAAnim_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If GetPlayerAccess(MyIndex) < ADMIN_DEVELOPER Then
        
        Exit Sub
    End If

    SendRequestEditAnimation
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "cmdAAnim_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub



Private Sub cmdBlank_Click(Index As Integer)
Select Case Index
    Case 0 'setarrank
        If GetPlayerAccess(MyIndex) < ADMIN_CREATOR Then Exit Sub
        
        If MsgBox("Mudar rank do: " & Trim$(lstAdminWarp.text) & " ?", vbYesNo) = vbYes Then
            SendSetRank lstAdminWarp.text, scrlPainelAdm(0).value
        End If
    Case 1 'warpMeTo
        If GetPlayerAccess(MyIndex) < ADMIN_MONITOR Then
        
            Exit Sub
        End If

        If Len(Trim$(frmMain.lstAdminWarp.text)) < 1 Then
            Exit Sub
        End If

        If IsNumeric(Trim$(lstAdminWarp.text)) Then
            Exit Sub
        End If

        WarpMeTo Trim$(lstAdminWarp.text)
    Case 2 'warpToMe
        If GetPlayerAccess(MyIndex) < ADMIN_CREATOR Then
        
            Exit Sub
        End If

        If Len(Trim$(frmMain.lstAdminWarp.text)) < 1 Then
            Exit Sub
        End If

        If IsNumeric(Trim$(lstAdminWarp.text)) Then
            Exit Sub
        End If

        WarpToMe Trim$(lstAdminWarp.text)
    Case 3 'kick
        If lstAdminWarp.text = vbNullString Then Exit Sub

        SendKick lstAdminWarp.text
    Case 4 'ban pra sempre
        If Trim$(lstAdminWarp.text) = vbNullString Then
            MsgBox "Selecione o jogador antes.", vbCritical
            Exit Sub
        End If
        
        If MsgBox("Têm CERTEZA que quer banir o IP do " & frmMain.lstAdminWarp.text & "?", vbYesNo, "BAN IP") = vbYes Then
            If MsgBox("Ban IP é só para casos EXTREMOS. Tu tem certeza absoluta mesmo???", vbYesNo, "BAN IP") = vbYes Then
                If MsgBox("Tudo tem uma consequência. O único da equipe que vai se foder se der alguma merda vai ser o adm, pensa bem caralho.", vbYesNo, "BAN IP") = vbYes Then
                    SendBAN Trim$(lstAdminWarp.text), 60
                End If
            End If
        End If
    Case 5 'Confirmar pergunta-EXAME ESCRITO
        If frmMain.lstExame.text = Trim$(ExameEscrito(PerguntaIndex).RespostaCerta) Then
            RespostasCertas = RespostasCertas + 1
            
            If PerguntasCount < TotalPerguntas Then
                SortearPergunta
            Else
                If RespostasCertas >= RespostasCertasRequeridas Then
                    AddText "PARABÉNS! Você acertou " & RespostasCertas & " de " & TotalPerguntas & " !", Magenta
                    EnviarExameEscrito YES
                Else
                    AddText "Você não conseguiu passar! Você acertou " & RespostasCertas & " de " & TotalPerguntas & " !", BrightRed
                    EnviarExameEscrito NO
                End If
                
                TotalPerguntas = NO
                PerguntasCount = NO
                PerguntaIndex = NO
                RespostasCertasRequeridas = NO
                RespostasCertas = NO
                
                frmMain.picExame.Visible = False
            End If
        Else
            'AddText "erro e.e", BrightRed
            
            If PerguntasCount < TotalPerguntas Then
                SortearPergunta
            Else
                If RespostasCertas >= RespostasCertasRequeridas Then
                    AddText "PARABÉNS! Você acertou " & RespostasCertas & " de " & TotalPerguntas & " !", Magenta
                    EnviarExameEscrito YES
                Else
                    AddText "Você não conseguiu passar! Você acertou " & RespostasCertas & " de " & TotalPerguntas & " !", BrightRed
                    EnviarExameEscrito NO
                End If
                
                TotalPerguntas = NO
                PerguntasCount = NO
                PerguntaIndex = NO
                RespostasCertasRequeridas = NO
                RespostasCertas = NO
                
                frmMain.picExame.Visible = False
            End If
        End If
    
    Case 6 'ban de 7 dias
        If Trim$(lstAdminWarp.text) = vbNullString Then
            MsgBox "Selecione o jogador antes.", vbCritical
            Exit Sub
        End If
        
        If MsgBox("Têm CERTEZA que quer banir por 7(SETE) dias o " & frmMain.lstAdminWarp.text & "?", vbYesNo, "BAN 7 DIAS") = vbYes Then
            If MsgBox("Tu deu os avisos e os kicks antes??? pense bem antes de banir.", vbYesNo, "BAN 7 DIAS") = vbYes Then
                SendBAN Trim$(lstAdminWarp.text), 7
            End If
        End If
        
    Case 7 'ban de 1 dia
        If Trim$(lstAdminWarp.text) = vbNullString Then
            MsgBox "Selecione o jogador antes.", vbCritical
            Exit Sub
        End If
        
        If MsgBox("Têm CERTEZA que quer banir por 1(UM) dia o " & frmMain.lstAdminWarp.text & "?", vbYesNo, "BAN 1 DIA") = vbYes Then
            If MsgBox("Tu deu os avisos e os kicks antes??? pense bem antes de banir.", vbYesNo, "BAN 1 DIA") = vbYes Then
                SendBAN Trim$(lstAdminWarp.text), 1
            End If
        End If
    
    Case 8 'ban de 2 dias
        If Trim$(lstAdminWarp.text) = vbNullString Then
            MsgBox "Selecione o jogador antes.", vbCritical
            Exit Sub
        End If
        
        If MsgBox("Têm CERTEZA que quer banir por 2(DOIS) dias o " & frmMain.lstAdminWarp.text & "?", vbYesNo, "BAN 2 DIAS") = vbYes Then
            If MsgBox("Tu deu os avisos e os kicks antes??? pense bem antes de banir.", vbYesNo, "BAN 2 DIAS") = vbYes Then
                SendBAN Trim$(lstAdminWarp.text), 2
            End If
        End If
        
    Case Else
End Select

End Sub





Private Sub cmDesafio_Click(Index As Integer)
Dim i As Long
    
Select Case Index
    Case 0 'setar jogadores
        Select Case cmbArenaTipo.ListIndex
            Case 0 '1x1
                If Not NomesDesafio(1) = vbNullString Then
                    AddText "Você já selecionou teu oponente. Se quiser mudar,zere os dados do desafio e faça denovo!", White
                    Exit Sub
                End If
                
                If lstDesafio.ListIndex >= 0 And lstDesafio.text <> vbNullString Then
                    NomesDesafio(1) = Trim$(lstDesafio.text)
                Else
                    AddText "Escolha um nome na lista antes..", White
                    Exit Sub
                End If
            Case 1 '1x2
                If pegarDesafioIndex() > 2 Then
                    AddText "Você já selecionou seu desafio. Se quiser mudar,zere os dados do desafio e faça denovo!", White
                    Exit Sub
                End If
                
                For i = 1 To 2
                    If jaTemDesafio(Trim$(lstDesafio.text)) = YES Then
                        AddText "Você já selecionou esse oponente. Se quiser mudar,zere os dados do desafio e faça denovo!", White
                        Exit Sub
                    End If
                Next
                
                If lstDesafio.ListIndex >= 0 And lstDesafio.text <> vbNullString And pegarDesafioIndex() > 0 Then
                    NomesDesafio(pegarDesafioIndex()) = Trim$(lstDesafio.text)
                Else
                    AddText "Escolha um nome na lista antes..Se errou em algo pode zerar o desafio e começar denovo.", White
                    Exit Sub
                End If
            Case 2 '2x1
                If pegarDesafioIndex() > 2 Then
                    AddText "Você já selecionou seu desafio. Se quiser mudar,zere os dados do desafio e faça denovo!", White
                    Exit Sub
                End If
                
                For i = 1 To 2
                    If jaTemDesafio(Trim$(lstDesafio.text)) = YES Then
                        AddText "Você já selecionou esse oponente. Se quiser mudar,zere os dados do desafio e faça denovo!", White
                        Exit Sub
                    End If
                Next
                
                If lstDesafio.ListIndex >= 0 And lstDesafio.text <> vbNullString And pegarDesafioIndex() > 0 Then
                    NomesDesafio(pegarDesafioIndex()) = Trim$(lstDesafio.text)
                Else
                    AddText "Escolha um nome na lista antes..Se errou em algo pode zerar o desafio e começar denovo.", White
                    Exit Sub
                End If
            Case 3 '2x2
                If pegarDesafioIndex() = 0 Then
                    AddText "Você já selecionou seu desafio. Se quiser mudar,zere os dados do desafio e faça denovo!", White
                    Exit Sub
                End If
                
                For i = 1 To 3
                    If jaTemDesafio(Trim$(lstDesafio.text)) = YES Then
                        AddText "Você já selecionou esse oponente. Se quiser mudar,zere os dados do desafio e faça denovo!", White
                        Exit Sub
                    End If
                Next
                
                If lstDesafio.ListIndex >= 0 And lstDesafio.text <> vbNullString And pegarDesafioIndex() > 0 Then
                    NomesDesafio(pegarDesafioIndex()) = Trim$(lstDesafio.text)
                Else
                    AddText "Escolha um nome na lista antes..Se errou em algo pode zerar o desafio e começar denovo.", White
                    Exit Sub
                End If
            
            Case Else
        
        End Select
    Case 1 'zerar tudo
        lblDesafio(7).Caption = GetPlayerName(MyIndex)
        For i = 1 To 3
            NomesDesafio(i) = vbNullString
        Next
        
        cmDesafio(0).Visible = True
        cmDesafio(2).Visible = False
        cmbArenaTipo.ListIndex = 0
        cmDesafio(0).Caption = "Selecionar oponente"
    Case 2 'enviar
                    
        If frmMain.cmbArenaNum.text = "SELECIONE" Then
            AddText "Selecione uma arena antes!", White
            Exit Sub
        End If
        
        If DesafioArena < 1 Or DesafioArena > 9 Then
            AddText "Não há arenas livres no momento. Tente outra hora!", White
            Exit Sub
        End If
        
        If frmMain.cmbArenaTipo.ListIndex < 0 Or frmMain.cmbArenaTipo.ListIndex > 3 Then
            frmMain.cmbArenaTipo.ListIndex = 0
        End If
        
        SendDesafio DesafioArena, frmMain.cmbArenaTipo.ListIndex, NomesDesafio(1), NomesDesafio(2), NomesDesafio(3)
        cmDesafio_Click (1)
        
        cmDesafio(2).Visible = False
        picDesafio.Visible = False
        DesafioArena = 0
    Case Else
End Select

Select Case cmbArenaTipo.ListIndex
    Case 0 '1x1
        lblDesafio(7).Caption = GetPlayerName(MyIndex)
        cmDesafio(0).Caption = "Selecionar oponente"
        lblDesafio(9).Caption = NomesDesafio(1)
        If pegarDesafioIndex() = 2 Then
            cmDesafio(0).Visible = False
            cmDesafio(2).Visible = True
        End If
    Case 1 '1x2
        lblDesafio(7).Caption = GetPlayerName(MyIndex)
        Select Case pegarDesafioIndex()
            Case 1
                cmDesafio(0).Caption = "Selecionar oponente número 1"
            Case 2
                cmDesafio(0).Caption = "Selecionar oponente número 2"
                lblDesafio(9).Caption = NomesDesafio(1)
            Case 3
                lblDesafio(9).Caption = NomesDesafio(1) & " e " & NomesDesafio(2)
                cmDesafio(0).Visible = False
                cmDesafio(2).Visible = True
            Case Else
        End Select
    Case 2 '2x1
        Select Case pegarDesafioIndex()
            Case 1
                cmDesafio(0).Caption = "Selecionar seu parceiro"
                lblDesafio(7).Caption = GetPlayerName(MyIndex)
            Case 2
                cmDesafio(0).Caption = "Selecionar o oponente de vocês"
                lblDesafio(7).Caption = GetPlayerName(MyIndex) & " e " & NomesDesafio(1)
            Case 3
                lblDesafio(7).Caption = GetPlayerName(MyIndex) & " e " & NomesDesafio(1)
                lblDesafio(9).Caption = NomesDesafio(2)
                cmDesafio(0).Visible = False
                cmDesafio(2).Visible = True
            Case Else
        End Select
    Case 3 '2x2
        Select Case pegarDesafioIndex()
            Case 1
                cmDesafio(0).Caption = "Selecionar seu parceiro"
                lblDesafio(7).Caption = GetPlayerName(MyIndex)
            Case 2
                cmDesafio(0).Caption = "Selecionar oponente número 1"
                lblDesafio(7).Caption = GetPlayerName(MyIndex) & " e " & NomesDesafio(1)
            Case 3
                cmDesafio(0).Caption = "Selecionar oponente número 2"
                lblDesafio(9).Caption = NomesDesafio(2)
            Case 0
                lblDesafio(7).Caption = GetPlayerName(MyIndex) & " e " & NomesDesafio(1)
                lblDesafio(9).Caption = NomesDesafio(2) & " & " & NomesDesafio(3)
                cmDesafio(0).Visible = False
                cmDesafio(2).Visible = True
            Case Else
        End Select
    Case Else
End Select
End Sub

Private Sub cmdEXTRAS_Click()
picExtras.Visible = Not picExtras.Visible
End Sub

Private Sub cmdLevel_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If GetPlayerAccess(MyIndex) < 2 Then
        
        Exit Sub
    End If

    SendRequestLevelUp
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "cmdLevel_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub



Private Sub cmdSSMap_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    ' render the map temp
    ScreenshotMap
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "cmdLevel_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub Command1_Click()
Dim i As Long

lstPlayerQuest.Clear

For i = 1 To 10
    If Player(MyIndex).QuestNum(i) > 0 Then
       lstPlayerQuest.AddItem i & ":" & Player(MyIndex).QuestInfo(i).name
       'lstPlayerQuest.ListIndex = 0
    Else
       lstPlayerQuest.AddItem i & ":"
    End If
Next
frmMain.picQuestPlayer.Picture = LoadPicture(App.Path & "\data files\graphics\faces\" & GetPlayerSprite(MyIndex) & ".jpg")
picQuest.Visible = True
End Sub

Private Sub cmdTorneio_Click(Index As Integer)
Dim i As Byte

Select Case Index
    Case 0 'p1
        If Trim$(lstAdminWarp.text) = vbNullString Then
            MsgBox "Selecione um jogador!", vbExclamation
            Exit Sub
        End If
        
        SendLuta Trim$(lstAdminWarp.text), "0"
        
    Case 1 'p2
        Lutadores(2) = lstAdminWarp.text
    Case 2 'p3
        Lutadores(3) = lstAdminWarp.text
    Case 3 'Enviar Luta
        If Lutadores(1) = vbNullString Then
            AddText "Selecione o player1 antes!", Red
            Exit Sub
        End If
        
        If Lutadores(2) = vbNullString Then
            AddText "Selecione o player2 antes!", Red
            Exit Sub
        End If
        
        If Lutadores(1) = Lutadores(2) Or Lutadores(2) = Lutadores(1) Then
            AddText "Lutadores 1 e 2 são iguais,selecione outro!", Red
            Exit Sub
        End If
        
        If Lutadores(1) = Lutadores(3) Or Lutadores(3) = Lutadores(1) Then
            AddText "Lutadores 1 e 3 são iguais,selecione outro!", Red
            Exit Sub
        End If
        
        If Lutadores(2) = Lutadores(3) Or Lutadores(3) = Lutadores(2) Then
            AddText "Lutadores 2 e 3 são iguais,selecione outro!", Red
            Exit Sub
        End If
        
        SendLuta Lutadores(1), Lutadores(2), Lutadores(3)
        For i = 1 To 3
            Lutadores(i) = vbNullString
        Next
    Case 4 'limpar lutadores
        For i = 1 To 3
            Lutadores(i) = vbNullString
        Next
    Case 5 'Puxar todos da sala de espera 2
        If GetPlayerAccess(MyIndex) < 2 Then Exit Sub
        
        If MsgBox("Puxar mesmo todos da sala de espera 2?", vbYesNo) = vbYes Then
            EmoteMsg 119
        End If
    Case 6 'Checar VIP
        If GetPlayerAccess(MyIndex) < 4 Then Exit Sub
        
        If frmMain.txtPainelADM(0).text = vbNullString Or IsNumeric(frmMain.txtPainelADM(0)) = False Then
            MsgBox "Algo errado com os dias vip!"
            Exit Sub
        End If
        
        If frmMain.lstAdminWarp.text = vbNullString Then
            MsgBox "Selecione um jogador antes!", vbCritical
            Exit Sub
        End If
        
        SendVIP frmMain.lstAdminWarp.text, 1, frmMain.txtPainelADM(0).text, 0
    Case 7 'Checar  CT
        If GetPlayerAccess(MyIndex) < 4 Then Exit Sub
        
        If frmMain.txtPainelADM(1).text = vbNullString Or IsNumeric(frmMain.txtPainelADM(1)) = False Then
            MsgBox "Algo errado com os dias CT!"
            Exit Sub
        End If
        
        If frmMain.lstAdminWarp.text = vbNullString Then
            MsgBox "Selecione um jogador antes!", vbCritical
            Exit Sub
        End If
        
        SendCT frmMain.lstAdminWarp.text, frmMain.txtPainelADM(1).text, 0
    Case 8 'setar LIGHT
        If GetPlayerAccess(MyIndex) < 4 Then Exit Sub
        
        If frmMain.txtPainelADM(0).text = vbNullString Or IsNumeric(frmMain.txtPainelADM(0)) = False Then
            MsgBox "Algo errado com os dias vip!"
            Exit Sub
        End If
        
        If frmMain.lstAdminWarp.text = vbNullString Then
            MsgBox "Selecione um jogador antes!", vbCritical, "SET VIP LIGHT"
            Exit Sub
        End If
        
        If MsgBox(frmMain.txtPainelADM(0).text & " dias vip LIGHT para o " & frmMain.lstAdminWarp.text & "?", vbYesNo, "SET VIP LIGHT") = vbNo Then
            Exit Sub
        End If
        
        SendVIP frmMain.lstAdminWarp.text, 1, frmMain.txtPainelADM(0).text, 1

    Case 9 'setar OHYEH
        If GetPlayerAccess(MyIndex) < 4 Then Exit Sub
        
        If frmMain.txtPainelADM(0).text = vbNullString Or IsNumeric(frmMain.txtPainelADM(0)) = False Then
            MsgBox "Algo errado com os dias vip!"
            Exit Sub
        End If
        
        If frmMain.lstAdminWarp.text = vbNullString Then
            MsgBox "Selecione um jogador antes!", vbCritical, "SET VIP OHYEH"
            Exit Sub
        End If
        
        If MsgBox(frmMain.txtPainelADM(0).text & " dias vip OHYEH para o " & frmMain.lstAdminWarp.text & "?", vbYesNo, "SET VIP oHYEh") = vbNo Then
            Exit Sub
        End If
        
        SendVIP frmMain.lstAdminWarp.text, 2, frmMain.txtPainelADM(0).text, 1
    Case 10 'dar o ct
        If GetPlayerAccess(MyIndex) < 4 Then Exit Sub
        
        If frmMain.txtPainelADM(1).text = vbNullString Or IsNumeric(frmMain.txtPainelADM(1)) = False Then
            MsgBox "Algo errado com os dias CT!"
            Exit Sub
        End If
        
        If frmMain.lstAdminWarp.text = vbNullString Then
            MsgBox "Selecione um jogador antes!", vbCritical
            Exit Sub
        End If
        
        SendCT frmMain.lstAdminWarp.text, frmMain.txtPainelADM(1).text, 1
    
    Case 11 'checar torneio
        If GetPlayerAccess(MyIndex) < 4 Then Exit Sub
        
        EmoteMsg 115
        
    Case 12 'ativar/desativar ks
        If GetPlayerAccess(MyIndex) < 4 Then Exit Sub
        
        If frmMain.scrlPainelAdm(1).value < 1 Then
            If MsgBox("Você quer desativar todos os torneios?", vbYesNo) = vbNo Then
                Exit Sub
            End If
        End If
        
        EmoteMsg 116, frmMain.scrlPainelAdm(1).value
        
    Case 13 'anunciar
        If GetPlayerAccess(MyIndex) < 4 Then Exit Sub
        
        EmoteMsg 117
    
    Case 14 'mandar luta ks
        If GetPlayerAccess(MyIndex) < 2 Then Exit Sub
        
        EmoteMsg 118
    
    Case 15 'desmutar
        If Trim$(lstAdminWarp.text) = vbNullString Then
            MsgBox "Selecione um jogador!", vbExclamation
            Exit Sub
        End If
        
        SendLuta Trim$(lstAdminWarp.text), "1"
        
    Case Else
End Select

End Sub

Private Sub cmdVIP_Click()
frmMain.picVIP.top = 48
frmMain.picVIP.Left = 216
frmMain.picVIP.height = 329
frmMain.picVIP.width = 209

If Player(MyIndex).VIP < 1 And Not Player(MyIndex).VipData.VIP > 0 Then
    AddText "Apenas membros VIP's..", BrightRed
Else
    picVIP.Visible = Not picVIP.Visible
End If

End Sub





Private Sub Form_Load()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    ' move GUI
    picAdmin.Left = 664
    picAdmin.top = 24
    picCurrency.Left = txtChat.Left
    picCurrency.top = txtChat.top
    picDialogue.top = txtChat.top
    picDialogue.Left = txtChat.Left
    picCover.top = picScreen.top - 1
    picCover.Left = picScreen.Left - 1
    picCover.height = picScreen.height + 2
    picCover.width = picScreen.width + 2
    picWAR.height = 265
    picWAR.width = 540
    picWAR.top = 64
    picWAR.Left = 56
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "Form_Load", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub Form_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)

If Button = 1 Then
    MoveX = X
    MoveY = Y
End If
    
End Sub

Private Sub Form_Unload(Cancel As Integer)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    Cancel = True
    logoutGame
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "Form_Unload", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub Form_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    ' hide the descriptions
    picItemDesc.Visible = False
    picSpellDesc.Visible = False
    
    If Button = 1 Then
        Me.Left = (Me.Left - MoveX) + X
        Me.top = (Me.top - MoveY) + Y
    End If
    
    ' reset all buttons
    resetButtons_Main
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "Form_MouseMove", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub imgAcceptTrade_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    AcceptTrade
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "imgAcceptTrade_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub imgButton_Click(Index As Integer)
Dim buffer As clsBuffer
Dim i As Long
    
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    Select Case Index
        Case 1
            If Not picInventory.Visible Then
                ' show the window
                picInventory.Visible = True
                picCharacter.Visible = False
                picSpells.Visible = False
                picOptions.Visible = False
                picParty.Visible = False
                picTrans.Visible = False
                PetBox.Visible = False
                picExtras.Visible = False
            
                BltInventory
                ' play sound
                PlaySound Sound_ButtonClick
            End If
        Case 2
            If Not picSpells.Visible Then
                ' send packet
                Set buffer = New clsBuffer
                buffer.WriteLong CSpells
                SendData buffer.ToArray()
                Set buffer = Nothing
                ' show the window
                picSpells.Visible = True
                picInventory.Visible = False
                picCharacter.Visible = False
                picOptions.Visible = False
                picParty.Visible = False
                picTrans.Visible = False
                PetBox.Visible = False
                picExtras.Visible = False
                ' play sound
                PlaySound Sound_ButtonClick
            End If
        Case 3
            If Not picCharacter.Visible Then
                ' send packet
                EmoteMsg 131
                ' show the window
                picCharacter.Visible = True
                picInventory.Visible = False
                picSpells.Visible = False
                picOptions.Visible = False
                picParty.Visible = False
                picTrans.Visible = False
                PetBox.Visible = False
                picExtras.Visible = False
                ' play sound
                PlaySound Sound_ButtonClick
                ' Render
                BltEquipment
                BltFace
            End If
        Case 4
            If Not picOptions.Visible Then
                ' show the window
                picCharacter.Visible = False
                picInventory.Visible = False
                picSpells.Visible = False
                picOptions.Visible = True
                picParty.Visible = False
                picTrans.Visible = False
                PetBox.Visible = False
                picExtras.Visible = False
                ' play sound
                PlaySound Sound_ButtonClick
            End If
        Case 5
            If myTargetType = TARGET_TYPE_PLAYER And myTarget <> MyIndex Then
                SendTradeRequest
                ' play sound
                PlaySound Sound_ButtonClick
            Else
                AddText "Invalid trade target.", BrightRed
            End If
        Case 6
            ' show the window
            picCharacter.Visible = False
            picInventory.Visible = False
            picSpells.Visible = False
            picOptions.Visible = False
            picParty.Visible = True
            picTrans.Visible = False
            PetBox.Visible = False
            picExtras.Visible = False
            ' play sound
            PlaySound Sound_ButtonClick
        Case 7
           'Dim i As Long

        lstPlayerQuest.Clear

        For i = 1 To 10
            If Player(MyIndex).QuestNum(i) > 0 Then
                lstPlayerQuest.AddItem i & ":" & Player(MyIndex).QuestInfo(i).name
                'lstPlayerQuest.ListIndex = 0
            Else
                lstPlayerQuest.AddItem i & ":"
            End If
        Next
            If FileExist(App.Path & "\data files\graphics\faces\" & GetPlayerSprite(MyIndex) & ".jpg", True) Then
                frmMain.picQuestPlayer.Picture = LoadPicture(App.Path & "\data files\graphics\faces\" & GetPlayerSprite(MyIndex) & ".jpg")
                picQuestPlayer.Visible = True
            Else
                picQuestPlayer.Visible = False
            End If
                
            picQuest.Visible = True
            PlaySound Sound_ButtonClick
        Case 8
            If Not picTrans.Visible Then
                ' show the window
                picInventory.Visible = False
                picCharacter.Visible = False
                picSpells.Visible = False
                picOptions.Visible = False
                picParty.Visible = False
                UpdateTransPic
                picTrans.Visible = True
                PetBox.Visible = False
                picExtras.Visible = False
                
                ' play sound
                PlaySound Sound_ButtonClick
            End If
            
        Case 9
            If Not PetBox.Visible Then
                picInventory.Visible = False
                picCharacter.Visible = False
                picSpells.Visible = False
                picOptions.Visible = False
                picParty.Visible = False
                UpdateTransPic
                picTrans.Visible = False
                PetBox.Visible = True
                picExtras.Visible = False
                
                ' play sound
                PlaySound Sound_ButtonClick
            End If
        Case 10
            If Not picAjuda.Visible Then
                picAjuda.Visible = True
                ' play sound
                PlaySound Sound_ButtonClick
            End If
        
    End Select
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "imgButton_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub imgButton_MouseMove(Index As Integer, Button As Integer, Shift As Integer, X As Single, Y As Single)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    On Error Resume Next
    ' reset other buttons
    'resetButtons_Main Index
    
    ' change the button we're hovering on
    'If Not MainButton(Index).state = 2 Then ' make sure we're not clicking
        'changeButtonState_Main Index, 1 ' hover
    'End If
    
    ' play sound
    If Not LastButtonSound_Main = Index Then
        PlaySound Sound_ButtonHover
        LastButtonSound_Main = Index
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "imgButton_MouseMove", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub imgButton_MouseUp(Index As Integer, Button As Integer, Shift As Integer, X As Single, Y As Single)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
        
    ' reset all buttons
    'resetButtons_Main -1
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "imgButton_MouseUp", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub imgButton_MouseDown(Index As Integer, Button As Integer, Shift As Integer, X As Single, Y As Single)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    ' reset other buttons
    'resetButtons_Main Index
    
    ' change the button we're hovering on
    'changeButtonState_Main Index, 2 ' clicked
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "imgButton_MouseDown", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub



Private Sub Label1_Click(Index As Integer)
Select Case Index

Case 0
PetAttack MyIndex
Case 1
PetFollow MyIndex
Case 2
PetWander MyIndex
Case 3
PetDisband MyIndex
End Select

End Sub


Private Sub Label19_Click()

picPergunta.Visible = True
lblBlank(77).Caption = "Têm CERTEZA que deseja sair da Org??Não terá como voltar então pense bem!"
Q_INDEX = Q_ORG


End Sub



Private Sub Label35_Click()
SendRequestPlayerNames
End Sub



Private Sub lblAdd10Pts_Click(Index As Integer)
If GetPlayerPOINTS(MyIndex) < 10 Then Exit Sub

SendTrainStat Index, 10
End Sub




Private Sub lblBlank_Click(Index As Integer)
Dim nickChoice As String
Dim i As Long

Select Case Index
    Case 0 'Top's
        If frmMain.picTops.Visible = True Then Exit Sub
        
        EmoteMsg 127 'recebe os tops
        UpdatePositions
        frmMain.picTops.Visible = True
    Case 2 'PicAdminWarp
        picAdminWarp.Visible = False
    Case 5 'minimizar
        frmMain.WindowState = vbMinimized
    Case 6 'fechar game
        EmoteMsg 146
        'Unload frmMain
        
    Case 21 'Torneios
        WarpTo 98
    Case 22 'CT
        WarpTo 295
    Case 23 'Desafio
        SendRequestPlayerNames
        frmMain.picDesafio.Visible = True
        cmDesafio(2).Visible = False
        '############
        lblDesafio(7).Caption = GetPlayerName(MyIndex)
        frmMain.cmbArenaTipo.ListIndex = 0
        cmDesafio(0).Visible = True
        For i = 1 To 3
            NomesDesafio(i) = vbNullString
        Next
        atualizarArena 'atualiza as arenas livres
        '############
    Case 24 'Espectador Mod
        SendSpec
    Case 28 'Extras- chat privado
        SendRequestPlayerNames
        frmMain.picChatInvite.Visible = True
    Case 26 'Enviar Pedido Chat
        ChatPlayer = frmMain.lstChatInvite.text
        
        If ChatPlayer = vbNullString Then
            AddText "Selecione um player antes!", Red
            Exit Sub
        End If
        
        SendChat CHAT_PEDIDO, ChatPlayer, vbNullString
    Case 27 'Fechar pedido de Chat
        ChatPlayer = vbNullString
        picChatInvite.Visible = False
    Case 29 'Sair torneio
        Q_INDEX = Q_TORNEIO
        lblBlank(77).Caption = "Têm CERTEZA que deseja sair?Não têm como voltar.."
        picPergunta.Visible = True
        
    Case 32 'Mudar nick
        Q_INDEX = Q_NICK
        
        lblBlank(77).Caption = "Mudar o nick custa 5k CASH,caso tenha certeza de que queira mudar,vá em frente."
        picPergunta.Visible = True
        
        'If MsgBox("Mudar o nick custa 5k CASH,caso tenha certeza de que queira mudar,vá em frente.", vbYesNo, "Naruto Inner Power") = vbNo Then Exit Sub
        'nickChoice = InputBox("Digite o nick que você quer colocar(máximo de 12 caracteres).", "MUDANÇA DE NICKNAME")
        
        'If nickChoice = vbNullString Then Exit Sub
        'If Len(nickChoice) < 3 Or Len(nickChoice) > 12 Then
            'MsgBox "O tamanho do nick precisa ser entre 3 à 12 characteres", vbCritical
            'Exit Sub
        'End If
        
        'TrocarNick nickChoice
    Case 37 'fechar ajuda
        picAjuda.Visible = False
    Case 39 'fechar janela tops
        picTops.Visible = False
    Case 42 'atualizar missões
        lstPlayerQuest.Clear

        For i = 1 To 10
            If Player(MyIndex).QuestNum(i) > 0 Then
                lstPlayerQuest.AddItem i & ":" & Player(MyIndex).QuestInfo(i).name
                lstPlayerQuest.ListIndex = 0
            Else
                lstPlayerQuest.AddItem i & ":"
            End If
        Next
            frmMain.picQuestPlayer.Picture = LoadPicture(App.Path & "\data files\graphics\faces\" & GetPlayerSprite(MyIndex) & ".jpg")
    Case 43 'cancelar missão
        If Not lstPlayerQuest.ListIndex >= 0 Then Exit Sub
        If Player(MyIndex).QuestNum(lstPlayerQuest.ListIndex + 1) < 1 Then Exit Sub

        picFala.Visible = False
        SendQuestPic lstPlayerQuest.ListIndex + 1

        Player(MyIndex).QuestInfo(lstPlayerQuest.ListIndex + 1).name = ""

        lstPlayerQuest.Clear
        For i = 1 To 10
            If Player(MyIndex).QuestNum(i) > 0 Then
                lstPlayerQuest.AddItem i & ":" & Player(MyIndex).QuestInfo(i).name
            Else
                lstPlayerQuest.AddItem i & ":"
            End If
        Next
    Case 44 'fechar painel quest
        picQuest.Visible = False
        picFala.Visible = False
    Case 45 'top level click
        For i = 1 To 20
            frmMain.lblTopLevel(i).Caption = TopLvl(i).Nivel
            frmMain.lblTopName(i).Caption = i & "°:" & TopLvl(i).Nome
        Next
                    
        frmMain.picTopLevel.Visible = Not frmMain.picTopLevel.Visible
    
        frmMain.picTops.Visible = False
    Case 46 'top karma cliques
        For i = 1 To 10
            frmMain.lblHeroName(i).Caption = i & "°:" & TopHero(i).Nome
            frmMain.lblHeroPts(i).Caption = TopHero(i).Pts
                        
            frmMain.lblPKName(i).Caption = i & "°:" & TopPK(i).Nome
            frmMain.lblPKPts(i).Caption = TopPK(i).Pts
        Next
                    
        If Player(MyIndex).Karma >= 0 Then
            frmMain.lblMyKarma.ForeColor = &H808000
        Else
            frmMain.lblMyKarma.ForeColor = &HC0&
        End If
                    
        frmMain.lblMyKarma.Caption = Player(MyIndex).Karma
                    
        frmMain.picKarma.Visible = Not frmMain.picKarma.Visible
        
        frmMain.picTops.Visible = False
    Case 47 'top pvp click
        For i = 1 To 10
            frmMain.lblPvpName(i).Caption = i & "°:" & TopPvP(i).Nome
            frmMain.lblPvpV(i).Caption = TopPvP(i).V
            frmMain.lblPvpD(i).Caption = TopPvP(i).d
        Next
                    
        frmMain.lblMyD.Caption = Player(MyIndex).PvP.d
        frmMain.lblMyV.Caption = Player(MyIndex).PvP.V
                    
        frmMain.picPVP.Visible = True
    
        frmMain.picTops.Visible = False
    Case 48 'chuva
        WarpTo 173
    Case 49 'top char
        frmMain.lstTopChar(0).Clear
        frmMain.lstTopChar(1).Clear
        
        For i = 1 To MAX_CLASS_TEMP
            frmMain.lstTopChar(0).AddItem Class(i).name
            frmMain.lstTopChar(1).AddItem TopChar(i).Nome & "-Level:" & TopChar(i).Level
        Next
                    
        frmMain.picTopChar.Visible = Not frmMain.picTopChar.Visible
    
        frmMain.picTops.Visible = False
    Case 55 'fechar top char
        frmMain.picTopChar.Visible = False
    Case 56 'som
        WarpTo 123
    Case 57 'cachoeira
        WarpTo 208
    Case 58 'ferro
        WarpTo 226
    Case 59
        
    Case 60 'fechar top pvp
        frmMain.picPVP.Visible = False
    Case 63 'fechar top karma
        frmMain.picKarma.Visible = False
    Case 64 'fechar top leveu
        frmMain.picTopLevel.Visible = False
    Case 66
        frmMain.picVIP.Visible = False
    Case 67 'painel vip-area vip
        WarpTo 82
    Case 68 'painel vip-atendimento
        WarpTo 99
    Case 69 'painel vip- konoha
        WarpTo 1
    Case 70 'painel vip-suna
        WarpTo 50
    Case 71 'iwa
        WarpTo 22
    Case 72 'kiri
        WarpTo 32
    Case 73 'kumo
        WarpTo 151
    Case 74 'zerar karma
        lblBlank(77).Caption = "Têm certeza que quer zerar teu karma?"
        picPergunta.Visible = True
        Q_INDEX = Q_KARMA
        
    Case 75 'Sim picpergunta
        picPergunta.Visible = False
        
        Select Case Q_INDEX
            Case Q_NICK
                frmMain.picMudarNick.Visible = True
                frmMain.txtNovoNick.text = vbNullString
                
            Case Q_KARMA
                ZerarKarma
            Case Q_TORNEIO
                SairTorneio
            Case Q_ORG
                SairDaOrg
            Case Q_AMIGO
                SendAmigo 2, lstAmigos.text 'deletar amigo
            Case Q_USARITEM
                If Q_ITEMINVNUM > 0 Then
                    SendUseItem Q_ITEMINVNUM
                End If
            Case Q_DESISTIRKAGE
                EmoteMsg 125
            Case Q_DROPAR
                If tmpInvNum < 1 Or tmpInvNum > MAX_INV Then Exit Sub
                enviarDropItem tmpInvNum
                tmpInvNum = 0
            Case Else
                picPergunta.Visible = False
                Q_INDEX = 0
        End Select
    Case 76 'Não picpergunta
        picPergunta.Visible = False
        Q_INDEX = NO
        
    Case 78 'fechar picPergunta
        picPergunta.Visible = False
    Case 80 'fechar picMudarNick
        picMudarNick.Visible = False
    Case 81 'enviar troca de nick
        nickChoice = Trim$(frmMain.txtNovoNick.text)
        
        If nickChoice = vbNullString Then Exit Sub
                
        If Len(nickChoice) < 3 Or Len(nickChoice) > 12 Then
            lblBlank(83).Caption = "O tamanho do nick precisa ser entre 3 à 12 digitos"
            picAVISO.Visible = True
            Exit Sub
        End If
        
        'previnir GM no nick
        If InStr(nickChoice, "gm") Or InStr(nickChoice, "Gm") Or InStr(nickChoice, "GM") Or InStr(nickChoice, "gM") Then
            lblBlank(83).Caption = "Não use GM no nick!"
            picAVISO.Visible = True
            Exit Sub
        End If
        
        TrocarNick nickChoice
        picMudarNick.Visible = False
    Case 82 'fechar picaviso
        picAVISO.Visible = False
    Case 84 'picAmigos remover/adicionar amigo
        If lstAmigos.text = vbNullString Then
            AddText "Selecione um player antes", BrightRed
            Exit Sub
        End If
        
        picAmigos.Visible = False
        
        If FriendState = 1 Then
            picPergunta.Visible = True
            lblBlank(77).Caption = "Deseja deletar esse amigo?"
            Q_INDEX = Q_AMIGO
            Exit Sub
        End If
        
        SendAmigo 1, lstAmigos.text 'adicionar amigo
        
    Case 85 'fechar picAmigos
        picAmigos.Visible = False
    Case 86 'picAmigos AMIGOS ONLINE
        lblBlank(86).ForeColor = &HC0FFFF
        lblBlank(87).ForeColor = &HC0C0&
        FriendState = 1
        SendRequestPlayerNames
        lblBlank(84).Caption = "Remover Amigo"
    Case 87 'picAmigos TODOS online
        lblBlank(87).ForeColor = &HC0FFFF
        lblBlank(86).ForeColor = &HC0C0&
        FriendState = 2
        SendRequestPlayerNames
        lblBlank(84).Caption = "Adicionar Amigo"
    Case 88 'picAmigos enviar desafio
        lblBlank_Click (23)
        
        picAmigos.Visible = False
        
    Case 89 'enviar pedido chat PicAmigos
        ChatPlayer = frmMain.lstAmigos.text
        
        If ChatPlayer = vbNullString Then
            AddText "Selecione um player antes!", Red
            Exit Sub
        End If
        
        SendChat CHAT_PEDIDO, ChatPlayer, vbNullString
    Case 91 'botão extras LISTA DE AMIGOS
        If picAmigos.Visible = True Then
            picAmigos.Visible = False
            Exit Sub
        End If
        
        lblBlank(86).ForeColor = &HC0FFFF
        lblBlank(87).ForeColor = &HC0C0&
        
        FriendState = 1
        SendRequestPlayerNames
        picAmigos.Visible = True
    Case 96 'area ohyeh
        WarpTo 260
        
    Case Else
End Select

End Sub

Private Sub lblCurrencyCancel_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    picCurrency.Visible = False
    txtCurrency.text = vbNullString
    tmpCurrencyItem = 0
    CurrencyMenu = 0 ' clear
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "lblCurrencyCancel_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub imgDeclineTrade_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    DeclineTrade
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "imgDeclineTrade_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub imgLeaveShop_Click()
    
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    EmoteMsg 132 'fechar no server
    
    picCover.Visible = False
    picShop.Visible = False
    InShop = 0
    ShopAction = 0
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "imgLeaveShop_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub lblCurrencyOk_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If IsNumeric(txtCurrency.text) Then
        If Val(txtCurrency.text) > 0 Then
            Select Case CurrencyMenu
                Case 1 ' drop item
                    SendDropItem tmpCurrencyItem, Val(txtCurrency.text)
                Case 2 ' deposit item
                    DepositItem tmpCurrencyItem, Val(txtCurrency.text)
                Case 3 ' withdraw item
                    WithdrawItem tmpCurrencyItem, Val(txtCurrency.text)
                Case 4 ' offer trade item
                    TradeItem tmpCurrencyItem, Val(txtCurrency.text)
            End Select
        Else
            AddText "Coloque um valor válido", BrightRed
            Exit Sub
        End If
    Else
        AddText "Coloque um valor válido", BrightRed
        Exit Sub
    End If
    
    picCurrency.Visible = False
    tmpCurrencyItem = 0
    txtCurrency.text = vbNullString
    CurrencyMenu = 0 ' clear
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "lblCurrencyOk_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub imgShopBuy_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If ShopAction = 1 Then Exit Sub
    ShopAction = 1 ' buying an item
    AddText "Clique no item que deseja comprar.", White
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "imgShopBuy_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub imgShopSell_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If ShopAction = 2 Then Exit Sub
    ShopAction = 2 ' selling an item
    AddText "Clique 2x no item da sua mochila que você queira vender.", White
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "imgShopSell_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub lblDesafioOk_Click()

End Sub

Private Sub lblDesafio_Click(Index As Integer)

    Select Case Index
        Case 1
            
        Case 2 'Close
            picDesafio.Visible = False
            DesafioPlayer = vbNullString
            DesafioArena = 0
        
        Case Else
    End Select

End Sub

Private Sub lblDialogue_Button_Click(Index As Integer)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    ' call the handler
    dialogueHandler Index
    
    picDialogue.Visible = False
    dialogueIndex = 0
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "lblDialogue_Button_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub lblFalaOk_Click()
picFala.Visible = False

End Sub

Private Sub lblPartyInvite_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    If myTargetType = TARGET_TYPE_PLAYER And myTarget <> MyIndex Then
        SendPartyRequest
    Else
        AddText "Invalid invitation target.", BrightRed
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "lblPartyInvite_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub lblPartyLeave_Click()
        ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    If Party.Leader > 0 Then
        SendPartyLeave
    Else
        AddText "You are not in a party.", BrightRed
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "lblPartyInvite_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub



Private Sub lblTrainStat_Click(Index As Integer)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If GetPlayerPOINTS(MyIndex) = 0 Then Exit Sub
    SendTrainStat Index, 1
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "lblTrainStat_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub lblWAR_Click(Index As Integer)

Select Case Index
    Case 0
        frmMain.picWAR.Visible = False
    Case 1 'bem
        SendWar 1
        frmMain.picWAR.Visible = False
    Case 2 'mal
        SendWar 2
        frmMain.picWAR.Visible = False
    Case Else
End Select

End Sub

Private Sub lstAjuda_Click()
Dim folder As String
Dim foto As String
Dim H, W As Integer

H = 9480
W = 12045
folder = App.Path & "\data files\graphics\ajuda\"

Select Case lstAjuda.ListIndex + 1
    Case 1 'Ajuda principal
        foto = "principal.jpg"
    Case 2 'Começando
        foto = "começando.jpg"
    Case 3 'Top's
        foto = "top.jpg"
    Case 4 'Chunin Shiken
        foto = "cs.jpg"
    Case 5 'Organizações
        foto = "organizações.jpg"
    Case 6 'Shikens
        foto = "shikens.jpg"
    Case 7 'Karma
        foto = "karma.jpg"
    Case 8 'FAQ
        foto = "FAQ.jpg"
    Case 9 'Regras/Punições
        foto = "Regras.jpg"
    Case 10 'troca
        foto = "troca.jpg"
    Case 11 'dicionario
        foto = "dicionario.jpg"
    Case 12 'horarios dos eventos
        foto = "horarios.jpg"
    Case Else
End Select

FrmAjuda.Picture = LoadPicture(folder & foto)
FrmAjuda.height = H
FrmAjuda.width = W
FrmAjuda.Show
End Sub

Private Sub lstDesafio_Click()
DesafioPlayer = lstDesafio.text
End Sub

Private Sub lstPlayerQuest_Click()
Dim i As Long
If lstPlayerQuest.ListIndex < 0 Then Exit Sub
If Player(MyIndex).QuestNum(lstPlayerQuest.ListIndex + 1) < 1 Then
picFala.Visible = False
lblQuestDesc.Caption = "--"
lblQuestName.Caption = "Sem Missão"
lblBlank(43).Caption = "Cancelar Missão:Nenhuma"
       
Exit Sub
End If

On Error Resume Next

For i = 1 To 10
    If Player(MyIndex).QuestNum(i) > 0 Then
       lblQuestDesc.Caption = Player(MyIndex).QuestInfo(lstPlayerQuest.ListIndex + 1).Desc
       lblQuestName.Caption = Player(MyIndex).QuestInfo(lstPlayerQuest.ListIndex + 1).name
       lblBlank(43).Caption = "Cancelar:" & Player(MyIndex).QuestInfo(lstPlayerQuest.ListIndex + 1).name
       
        If FileExist(App.Path & GFX_PATH & "Faces\" & Npc(Player(MyIndex).QuestInfo(lstPlayerQuest.ListIndex + 1).QuestNpc(lstPlayerQuest.ListIndex + 1)).Sprite & ".jpg", True) Then
            picFalaNPC.Picture = LoadPicture(App.Path & "\data files\graphics\faces\" & Npc(Player(MyIndex).QuestInfo(lstPlayerQuest.ListIndex + 1).QuestNpc(lstPlayerQuest.ListIndex + 1)).Sprite & ".jpg")
            picFalaNPC.Visible = True
        Else
            picFalaNPC.Visible = False
        End If
        
       lblFalaMsg.Caption = Player(MyIndex).QuestInfo(lstPlayerQuest.ListIndex + 1).Msg(2)
       lblFalaName.Caption = Npc(Player(MyIndex).QuestInfo(lstPlayerQuest.ListIndex + 1).QuestNpc(lstPlayerQuest.ListIndex + 1)).name
       picFala.Visible = True
    End If
Next
End Sub

Private Sub optAutoTile_Click()
Options.AutoTile = 0
SaveOptions
End Sub

Private Sub optAutoTileOFF_Click()
Options.AutoTile = 1
SaveOptions
End Sub

Private Sub optHotBar0_Click()
Options.Hotbar = 0
SaveOptions
BltHotbar

End Sub

Private Sub optHotbarNum_Click()
Options.Hotbar = 1
SaveOptions
BltHotbar
End Sub



Private Sub optLevelName_Click()
Options.NomeLevel = 0
SaveOptions
End Sub

Private Sub optLevelNameOFF_Click()
Options.NomeLevel = 1
SaveOptions
End Sub

Private Sub lstTopChar_Click(Index As Integer)
Select Case Index
    Case 0 'chars
        If lstTopChar(0).ListIndex < 0 Then Exit Sub
        lstTopChar(1).ListIndex = lstTopChar(0).ListIndex
    Case 1 'nomes
        If lstTopChar(1).ListIndex < 0 Then Exit Sub
        lstTopChar(0).ListIndex = lstTopChar(1).ListIndex
    Case Else
End Select

End Sub

Private Sub optMOff_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    Options.Music = 0
    ' stop music playing
    StopMidi
    ' save to config.ini
    SaveOptions
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "optMOff_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub optMOn_Click()
Dim MusicFile As String
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    Options.Music = 1
    ' start music playing
    MusicFile = Trim$(MAP.Music)
    If Not MusicFile = "None." Then
        PlayMidi MusicFile
    Else
        StopMidi
    End If
    ' save to config.ini
    SaveOptions
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "optMOn_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub optSOff_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    Options.Sound = 0
    ' save to config.ini
    SaveOptions
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "optSOff_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub optSOn_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    Options.Sound = 1
    ' save to config.ini
    SaveOptions
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "optSOn_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub



Private Sub picAdminWarp_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
'SOffsetY = y
'SOffsetX = x
End Sub

Private Sub picAdminWarp_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
'MovePicture frmMain.picAdminWarp, Button, Shift, x, y
End Sub

Private Sub picBarras_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
SOffsetY = Y
SOffsetX = X
'
End Sub

Private Sub picBarras_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
MovePicture frmMain.picBarras, Button, Shift, X, Y

End Sub

Private Sub picCover_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    ' hide the descriptions
    picItemDesc.Visible = False
    picSpellDesc.Visible = False
    
    ' reset all buttons
    resetButtons_Main
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picCover_MouseMove", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub



Private Sub picHotbar_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
If HotBarDelay > 0 Then Exit Sub

Dim SlotNum As Long

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    SOffsetX = X
    SOffsetY = Y
    SlotNum = IsHotbarSlot(X, Y)

    If Button = 1 Then
        If SlotNum <> 0 Then
            'SendHotbarUse SlotNum
            'HotBarDelay = GetTickCount + 1000
        End If
    ElseIf Button = 2 Then
        If SlotNum <> 0 Then
            SendHotbarChange 0, 0, SlotNum
            HotBarDelay = GetTickCount + 1000
        End If
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picHotbar_MouseDown", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub picHotbar_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
Dim SlotNum As Long

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    SlotNum = IsHotbarSlot(X, Y)
    MovePicture frmMain.picHotbar, Button, Shift, X, Y
    If SlotNum <> 0 Then
        If Hotbar(SlotNum).sType = 1 Then ' item
            X = X + picHotbar.Left + 1
            Y = Y + picHotbar.top - picItemDesc.height - 1
            UpdateDescWindow Hotbar(SlotNum).Slot, X, Y
            LastItemDesc = Hotbar(SlotNum).Slot ' set it so you don't re-set values
            Exit Sub
        ElseIf Hotbar(SlotNum).sType = 2 Then ' spell
            X = X + picHotbar.Left + 1
            Y = Y + picHotbar.top - picSpellDesc.height - 1
            UpdateSpellWindow Hotbar(SlotNum).Slot, X, Y
            LastSpellDesc = Hotbar(SlotNum).Slot  ' set it so you don't re-set values
            Exit Sub
        End If
    End If
    
    picItemDesc.Visible = False
    LastItemDesc = 0 ' no item was last loaded
    picSpellDesc.Visible = False
    LastSpellDesc = 0 ' no spell was last loaded
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picHotbar_MouseMove", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub picScreen_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    

    If InMapEditor Then
        Call MapEditorMouseDown(Button, X, Y, False)
    Else
        ' left click
        If Button = vbLeftButton Then
            ' targetting
            Call PlayerSearch(CurX, CurY)
        ' right click
        ElseIf Button = vbRightButton Then
            If ShiftDown Then
                ' admin warp if we're pressing shift and right clicking
                If GetPlayerAccess(MyIndex) >= 2 Then AdminWarp CurX, CurY
            End If
        End If
    End If

    'Call SetFocusOnChat
    ChatFocus = False
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picScreen_MouseDown", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub picScreen_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    CurX = TileView.Left + ((X + Camera.Left) \ PIC_X)
    CurY = TileView.top + ((Y + Camera.top) \ PIC_Y)

    If InMapEditor Then
        frmEditor_Map.shpLoc.Visible = False

        If Button = vbLeftButton Or Button = vbRightButton Then
            Call MapEditorMouseDown(Button, X, Y)
        End If
    End If
    
    ' hide the descriptions
    picItemDesc.Visible = False
    picSpellDesc.Visible = False
    
    ' reset all buttons
    resetButtons_Main
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picScreen_MouseMove", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Function IsShopItem(ByVal X As Single, ByVal Y As Single) As Long
Dim tempRec As RECT
Dim i As Long
    
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    IsShopItem = 0

    For i = 1 To MAX_TRADES

        If Shop(InShop).TradeItem(i).Item > 0 And Shop(InShop).TradeItem(i).Item <= MAX_ITEMS Then
            With tempRec
                .top = ShopTop + ((ShopOffsetY + 32) * ((i - 1) \ ShopColumns))
                .Bottom = .top + PIC_Y
                .Left = ShopLeft + ((ShopOffsetX + 32) * (((i - 1) Mod ShopColumns)))
                .Right = .Left + PIC_X
            End With

            If X >= tempRec.Left And X <= tempRec.Right Then
                If Y >= tempRec.top And Y <= tempRec.Bottom Then
                    IsShopItem = i
                    Exit Function
                End If
            End If
        End If
    Next
    
    ' Error handler
    Exit Function
errorhandler:
    HandleError "IsShopItem", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Function
End Function

Private Sub picShop_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    ' hide the descriptions
    picItemDesc.Visible = False
    picSpellDesc.Visible = False
    
    ' reset all buttons
    resetButtons_Main
End Sub

Private Sub picShopItems_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
Dim shopItem As Long

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    shopItem = IsShopItem(X, Y)
    
    If shopItem > 0 Then
        Select Case ShopAction
            Case 0 ' no action, give cost
                With Shop(InShop).TradeItem(shopItem)
                    AddText "Você pode comprar este item por " & .CostValue & " " & Trim$(Item(.CostItem).name) & ".", White
                End With
            Case 1 ' buy item
                ' buy item code
                BuyItem shopItem
        End Select
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picShopItems_MouseDown", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub picShopItems_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
Dim shopslot As Long
Dim x2 As Long, y2 As Long

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    shopslot = IsShopItem(X, Y)

    If shopslot <> 0 Then
        x2 = X + picShop.Left + picShopItems.Left + 1
        y2 = Y + picShop.top + picShopItems.top + 1
        UpdateDescWindow Shop(InShop).TradeItem(shopslot).Item, x2, y2
        LastItemDesc = Shop(InShop).TradeItem(shopslot).Item
        Exit Sub
    End If
    
    picItemDesc.Visible = False
    LastItemDesc = 0
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picShopItems_MouseMove", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub picSpellDesc_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    picSpellDesc.Visible = False
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picSpellDesc_MouseMove", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub picSpells_Click()
AddText "Para usar jutsus,clique e segure no jutsu que você quer usar e arraste pra um atalho da HOTBAR(F1-F12)", White

End Sub

Private Sub picSpells_DblClick()
'Desativei isso porq tava dando pra usar jutsu 2x seguidas. BUG!
Exit Sub

Dim spellnum As Long
    If HotBarDelay > 0 Then Exit Sub
    
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    spellnum = IsPlayerSpell(SpellX, SpellY)

    If spellnum <> 0 Then
        Call CastSpell(spellnum)
        Exit Sub
    End If
    HotBarDelay = GetTickCount + 1000
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picSpells_DblClick", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub picSpells_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
Dim spellnum As Long
    
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    spellnum = IsPlayerSpell(SpellX, SpellY)
    If Button = 1 Then ' left click
        If spellnum <> 0 Then
            DragSpell = spellnum
            Exit Sub
        End If
    ElseIf Button = 2 Then ' right click
        If spellnum <> 0 Then
            Dialogue "Deletar Jutsu", "Você tem certeza que deseja deletar o jutsu: " & Trim$(Spell(PlayerSpells(spellnum)).name) & "? Obs: Não tem como recuperar novamente.", DIALOGUE_TYPE_FORGET, True, spellnum
            Exit Sub
        End If
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picSpells_MouseDown", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub picSpells_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
Dim spellslot As Long
Dim x2 As Long, y2 As Long

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    SpellX = X
    SpellY = Y
    
    spellslot = IsPlayerSpell(X, Y)
    
    If DragSpell > 0 Then
        Call BltDraggedSpell(X + picSpells.Left, Y + picSpells.top)
    Else
        If spellslot <> 0 Then
            x2 = X + picSpells.Left - picSpellDesc.width - 1
            y2 = Y + picSpells.top - picSpellDesc.height - 1
            UpdateSpellWindow PlayerSpells(spellslot), x2, y2
            LastSpellDesc = PlayerSpells(spellslot)
            Exit Sub
        End If
    End If
    
    picSpellDesc.Visible = False
    LastSpellDesc = 0
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picSpells_MouseMove", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub picSpells_MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)
Dim i As Long
Dim rec_pos As RECT

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If DragSpell > 0 Then
        ' drag + drop
        For i = 1 To MAX_PLAYER_SPELLS
            With rec_pos
                .top = SpellTop + ((SpellOffsetY + 32) * ((i - 1) \ SpellColumns))
                .Bottom = .top + PIC_Y
                .Left = SpellLeft + ((SpellOffsetX + 32) * (((i - 1) Mod SpellColumns)))
                .Right = .Left + PIC_X
            End With

            If X >= rec_pos.Left And X <= rec_pos.Right Then
                If Y >= rec_pos.top And Y <= rec_pos.Bottom Then
                    If DragSpell <> i Then
                        SendChangeSpellSlots DragSpell, i
                        Exit For
                    End If
                End If
            End If
        Next
        ' hotbar
        For i = 1 To MAX_HOTBAR
            With rec_pos
                .top = picHotbar.top - picSpells.top
                .Left = picHotbar.Left - picSpells.Left + (HotbarOffsetX * (i - 1)) + (32 * (i - 1))
                .Right = .Left + 32
                .Bottom = picHotbar.top - picSpells.top + 32
            End With
            
            If X >= rec_pos.Left And X <= rec_pos.Right Then
                If Y >= rec_pos.top And Y <= rec_pos.Bottom Then
                    SendHotbarChange 2, DragSpell, i
                    DragSpell = 0
                    picTempSpell.Visible = False
                    Exit Sub
                End If
            End If
        Next
    End If

    DragSpell = 0
    picTempSpell.Visible = False
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picSpells_MouseUp", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub



Private Sub picTrade_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    ' hide the descriptions
    picItemDesc.Visible = False
    picSpellDesc.Visible = False
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picTrade_MouseMove", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub picTrans0_Click()
SendTransPic 0

End Sub

Private Sub picTrans1_Click()
SendTransPic 1
End Sub

Private Sub picTrans2_Click()
SendTransPic 2

End Sub

Private Sub picTrans3_Click()
SendTransPic 3

End Sub

Private Sub picTrans4_Click()
SendTransPic 4

End Sub

Private Sub picTrans5_Click()
SendTransPic 5

End Sub

Private Sub picTrans6_Click()
SendTransPic 6

End Sub

Private Sub picYourTrade_DblClick()
Dim TradeNum As Long

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    TradeNum = IsTradeItem(TradeX, TradeY, True)

    If TradeNum <> 0 Then
        UntradeItem TradeNum
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picYourTrade_DlbClick", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub picYourTrade_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Dim TradeNum As Long
    
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    TradeX = X
    TradeY = Y
    
    TradeNum = IsTradeItem(X, Y, True)
    
    If TradeNum <> 0 Then
        X = X + picTrade.Left + picYourTrade.Left + 4
        Y = Y + picTrade.top + picYourTrade.top + 4
        UpdateDescWindow GetPlayerInvItemNum(MyIndex, TradeYourOffer(TradeNum).num), X, Y
        LastItemDesc = GetPlayerInvItemNum(MyIndex, TradeYourOffer(TradeNum).num) ' set it so you don't re-set values
        Exit Sub
    End If
    
    picItemDesc.Visible = False
    LastItemDesc = 0 ' no item was last loaded
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picYourTrade_MouseMove", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub picTheirTrade_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Dim TradeNum As Long
    
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    TradeNum = IsTradeItem(X, Y, False)
    
    If TradeNum <> 0 Then
        X = X + picTrade.Left + picTheirTrade.Left + 4
        Y = Y + picTrade.top + picTheirTrade.top + 4
        UpdateDescWindow TradeTheirOffer(TradeNum).num, X, Y
        LastItemDesc = TradeTheirOffer(TradeNum).num ' set it so you don't re-set values
        Exit Sub
    End If
    
    picItemDesc.Visible = False
    LastItemDesc = 0 ' no item was last loaded
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picTheirTrade_MouseMove", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub scrlAAmount_Change()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    lblAAmount.Caption = "Amount: " & scrlAAmount.value
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "scrlAAmount_Change", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub scrlAItem_Change()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    lblAItem.Caption = "Item: " & Trim$(Item(scrlAItem.value).name)
    If Item(scrlAItem.value).Type = ITEM_TYPE_CURRENCY Then
        scrlAAmount.Enabled = True
        Exit Sub
    End If
    scrlAAmount.Enabled = False
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "scrlAItem_Change", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub



Private Sub scrlPainelAdm_Change(Index As Integer)
    Select Case Index
        Case 0 'setar rank
            Select Case scrlPainelAdm(0).value
                Case 1 'Estudante
                    lblSetRank.Caption = "Rank:Estudante"
                Case 2 'Gennin
                    lblSetRank.Caption = "Rank:Gennin"
                Case 3 'Chunin
                    lblSetRank.Caption = "Rank:Chunnin"
                Case 4 'Jounin
                    lblSetRank.Caption = "Rank:Jounin"
                Case 5 'ANBU
                    lblSetRank.Caption = "Rank:ANBU"
                Case 6 'Sannin
                    lblSetRank.Caption = "Rank:Sannin"
                Case 7 'Kage
                    lblSetRank.Caption = "Rank:Kage"
                Case 8 'Desertor
                    lblSetRank.Caption = "Rank:Desertor"
                Case Else
                    lblSetRank.Caption = " Rank: Nenhum"
            End Select
        
        Case 1 'selecionar torneios/eventos
            Select Case scrlPainelAdm(1).value
                Case 1
                    lblBlank(95).Caption = "KS:1-HOKAGE"
                Case 2
                    lblBlank(95).Caption = "KS:2-KAZEKAGE"
                Case 3
                    lblBlank(95).Caption = "KS:3-MIZUKAGE"
                Case 4
                    lblBlank(95).Caption = "KS:4-TSUCHIKAGE"
                Case 5
                    lblBlank(95).Caption = "KS:5-RAIKAGE"
                Case 6
                    lblBlank(95).Caption = "KS:6-LIDER DA CHUVA"
                Case 7
                    lblBlank(95).Caption = "KS:6-LIDER DO SOM"
                Case Else
                    lblBlank(95).Caption = "KS selecionado: Nenhum"
            End Select
        
        Case Else
    End Select
    
End Sub

' Winsock event
Private Sub Socket_DataArrival(ByVal bytesTotal As Long)

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If IsConnected Then
        Call IncomingData(bytesTotal)
    End If

    ' Error handler
    Exit Sub
errorhandler:
    HandleError "Socket_DataArrival", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub Form_KeyPress(KeyAscii As Integer)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    Call HandleKeyPresses(KeyAscii)

    ' prevents textbox on error ding sound
    If KeyAscii = vbKeyReturn Or KeyAscii = vbKeyEscape Then
        KeyAscii = 0
    End If

    ' Error handler
    Exit Sub
errorhandler:
    HandleError "Form_KeyPress", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub Form_KeyUp(KeyCode As Integer, Shift As Integer)
Dim i As Long
Dim buffer As clsBuffer

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If KeyCode = vbKeyI And Shift And vbAltMask Then
            'Mochila
            If Not picInventory.Visible Then
                ' show the window
                picInventory.Visible = True
                picCharacter.Visible = False
                picSpells.Visible = False
                picOptions.Visible = False
                picParty.Visible = False
                picTrans.Visible = False
                PetBox.Visible = False
                BltInventory
                ' play sound
                PlaySound Sound_ButtonClick
            End If
    End If
    
    If KeyCode = vbKeyQ And Shift And vbAltMask Then
            'Quest
            lstPlayerQuest.Clear

        For i = 1 To 10
            If Player(MyIndex).QuestNum(i) > 0 Then
                lstPlayerQuest.AddItem i & ":" & Player(MyIndex).QuestInfo(i).name
                'lstPlayerQuest.ListIndex = 0
            Else
                lstPlayerQuest.AddItem i & ":"
            End If
        Next
            If FileExist(App.Path & "\data files\graphics\faces\" & GetPlayerSprite(MyIndex) & ".bmp", True) Then
                frmMain.picQuestPlayer.Picture = LoadPicture(App.Path & "\data files\graphics\faces\" & GetPlayerSprite(MyIndex) & ".bmp")
                picQuestPlayer.Visible = True
            Else
                picQuestPlayer.Visible = False
            End If
                
            picQuest.Visible = True
            PlaySound Sound_ButtonClick
            
    End If
    
    If KeyCode = vbKeyJ And Shift And vbAltMask Then
            'Jutsus
            Set buffer = New clsBuffer
                buffer.WriteLong CSpells
                SendData buffer.ToArray()
                Set buffer = Nothing
                ' show the window
                picSpells.Visible = True
                picInventory.Visible = False
                picCharacter.Visible = False
                picOptions.Visible = False
                picParty.Visible = False
                picTrans.Visible = False
                PetBox.Visible = False
                ' play sound
                PlaySound Sound_ButtonClick
    End If
    
    If KeyCode = vbKeyT And Shift And vbAltMask Then
            'Transformações
            If Not picTrans.Visible Then
                ' show the window
                picInventory.Visible = False
                picCharacter.Visible = False
                picSpells.Visible = False
                picOptions.Visible = False
                picParty.Visible = False
                UpdateTransPic
                picTrans.Visible = True
                PetBox.Visible = False
                
                ' play sound
                PlaySound Sound_ButtonClick
            End If
    End If
    
    If KeyCode = vbKeyA And Shift And vbAltMask Then
            'Personagem
            ' send packet
                EmoteMsg 131
                ' show the window
                picCharacter.Visible = True
                picInventory.Visible = False
                picSpells.Visible = False
                picOptions.Visible = False
                picParty.Visible = False
                picTrans.Visible = False
                PetBox.Visible = False
                ' play sound
                PlaySound Sound_ButtonClick
                ' Render
                BltEquipment
                BltFace
    End If
    
    If KeyCode = vbKeyO And Shift And vbAltMask Then
            'Opções
            If Not picOptions.Visible Then
                ' show the window
                picCharacter.Visible = False
                picInventory.Visible = False
                picSpells.Visible = False
                picOptions.Visible = True
                picParty.Visible = False
                picTrans.Visible = False
                PetBox.Visible = False
                ' play sound
                PlaySound Sound_ButtonClick
            End If
    End If
    
    If KeyCode = vbKeyG And Shift And vbAltMask Then
            'Grupo
            ' show the window
            picCharacter.Visible = False
            picInventory.Visible = False
            picSpells.Visible = False
            picOptions.Visible = False
            picParty.Visible = True
            picTrans.Visible = False
            PetBox.Visible = False
            ' play sound
            PlaySound Sound_ButtonClick
    End If
    
    If KeyCode = vbKeyP And Shift And vbAltMask Then
            'Pet
            picInventory.Visible = False
                picCharacter.Visible = False
                picSpells.Visible = False
                picOptions.Visible = False
                picParty.Visible = False
                'UpdateTransPic
                picTrans.Visible = False
                PetBox.Visible = True
                
                ' play sound
                PlaySound Sound_ButtonClick
    End If

    Select Case KeyCode
        Case vbKeyInsert
            SendPK
        Case vbKeyPageDown
            If Player(MyIndex).Access > ADMIN_MONITOR Then
                picAdmin.Visible = Not picAdmin.Visible
                
                'PerguntaIndex = NO
                'PerguntasCount = NO
                'RespostasCertas = NO
                'RespostasCertasRequeridas = 7
                'TotalPerguntas = 10
                
                'CarregarExame
                'SortearPergunta
                'frmMain.picExame.Visible = True
            End If
        Case vbKeyPageUp
            If Player(MyIndex).Access > 1 Then
                frmMain.scrlPainelAdm(1).value = 0
                SendRequestPlayerNames
                picAdminWarp.Visible = Not picAdminWarp.Visible
            End If
    End Select
    
    ' hotbar
    If Not HotBarDelay > 0 Then
        If Options.Hotbar = 0 Then
            For i = 1 To MAX_HOTBAR
                If KeyCode = 111 + i Then
                    SendHotbarUse i
                    HotBarDelay = GetTickCount + 1000
                End If
            Next
        Else
            
            For i = 1 To 9
                If KeyCode = 48 + i Then
                    SendHotbarUse i
                    HotBarDelay = GetTickCount + 1000
                End If
            Next
            
            If KeyCode = 48 Then ' 0
                SendHotbarUse 10
                HotBarDelay = GetTickCount + 1000
            ElseIf KeyCode = 189 Then ' -
                SendHotbarUse 11
                HotBarDelay = GetTickCount + 1000
            ElseIf KeyCode = 187 Then ' =
                SendHotbarUse 12
                HotBarDelay = GetTickCount + 1000
            End If
        
        End If
    End If

    ' Error handler
    Exit Sub
errorhandler:
    HandleError "Form_KeyUp", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub



Private Sub tmrAntHack_Timer()
If InGame = False Then Exit Sub

    verificarCheat YES

If AntiSpeed1 = NO Then
    AntiSpeed1 = AntiSpeed2
Else
    AntiSpeed1 = AntiSpeed1 + 1
End If

If AntiSpeedDif < 1 Then AntiSpeedDif = 1

If AntiSpeed1 + AntiSpeedDif < AntiSpeed2 Then
    AntiSpeed1 = NO
    AntiSpeed2 = NO
    logoutGame
    MsgBox "CHEAT!FUHAEUUHAE. REINICIA O PC FERA!"
End If

If AntiSpeed1 > 20 And AntiSpeed2 > 20 Then
    cheatTimer = NO
    AntiSpeed2 = NO
    AntiSpeed1 = NO
End If

End Sub

Private Sub txtCaptcha_Change()
If captcha = vbNullString Then Exit Sub

If frmMain.txtCaptcha.text = captcha Then
    AddText "Verificação completa!", Yellow
    frmMain.picCaptcha.Visible = False
    captchaTmr = NO
    captcha = vbNullString
End If
End Sub

Private Sub txtCaptcha_Click()

frmMain.txtCaptcha.text = vbNullString

End Sub

Private Sub txtMyChat_Change()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    If Options.WASD = YES Then
        txtMyChat = vbNullString
        MyText = vbNullString
        ChatFocus = False
        Exit Sub
    End If
    
    MyText = txtMyChat
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "txtMyChat_Change", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub txtChat_GotFocus()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    SetFocusOnChat
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "txtChat_GotFocus", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' ***************
' ** Inventory **
' ***************
Private Sub picInventory_DblClick()
    Dim InvNum As Long
    Dim value As Long
    Dim multiplier As Double
    Dim i As Long
    
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    DragInvSlotNum = 0
    InvNum = IsInvItem(InvX, InvY)

    If InvNum <> 0 Then
    
        ' are we in a shop?
        If InShop > 0 Then
            Select Case ShopAction
                Case 0 ' nothing, give value
                    'Value = Item(GetPlayerInvItemNum(MyIndex, InvNum)).Price
                    
                    'If Value > 0 Then
                        'If Item(GetPlayerInvItemNum(MyIndex, InvNum)).Rarity > 0 Then
                            'AddText "Você pode vender por " & Value & " CASH.", White
                        'Else
                            'AddText "Você pode vender por " & Value & " YEN.", White
                        'End If
                    'Else
                        'AddText "A loja não aceita esse item.", White
                    'End If
                Case 2 ' 2 = sell
                    SellItem InvNum
            End Select
            
            Exit Sub
        End If
        
        ' in bank?
        If InBank Then
            If Item(GetPlayerInvItemNum(MyIndex, InvNum)).Type = ITEM_TYPE_CURRENCY Then
                CurrencyMenu = 2 ' deposit
                lblCurrency.Caption = "Quanto você quer depositar?"
                tmpCurrencyItem = InvNum
                txtCurrency.text = vbNullString
                picCurrency.Visible = True
                txtCurrency.SetFocus
                Exit Sub
            End If
                
            Call DepositItem(InvNum, 0)
            Exit Sub
        End If
        
        ' in trade?
        If InTrade > 0 Then
            ' exit out if we're offering that item
            For i = 1 To MAX_INV
                If TradeYourOffer(i).num = InvNum Then
                    ' is currency?
                    If Item(GetPlayerInvItemNum(MyIndex, TradeYourOffer(i).num)).Type = ITEM_TYPE_CURRENCY Then
                        ' only exit out if we're offering all of it
                        If TradeYourOffer(i).value = GetPlayerInvItemValue(MyIndex, TradeYourOffer(i).num) Then
                            Exit Sub
                        End If
                    Else
                        Exit Sub
                    End If
                End If
            Next
            
            If Item(GetPlayerInvItemNum(MyIndex, InvNum)).Type = ITEM_TYPE_CURRENCY Then
                CurrencyMenu = 4 ' offer in trade
                lblCurrency.Caption = "Qual a quantia que você quer negociar?"
                tmpCurrencyItem = InvNum
                txtCurrency.text = vbNullString
                picCurrency.Visible = True
                txtCurrency.SetFocus
                Exit Sub
            End If
            
            Call TradeItem(InvNum, 0)
            Exit Sub
        End If
        
        ' use item if not doing anything else
        If Item(GetPlayerInvItemNum(MyIndex, InvNum)).Type = ITEM_TYPE_NONE Then Exit Sub
        
        If Item(GetPlayerInvItemNum(MyIndex, InvNum)).Script < 25 Then
            Call SendUseItem(InvNum)
            Exit Sub
        Else
            picPergunta.Visible = True
            lblBlank(77).Caption = Trim$(Item(GetPlayerInvItemNum(MyIndex, InvNum)).name) & ": Quer mesmo usar esse item? Não há volta.."
            Q_ITEMINVNUM = InvNum
            Q_INDEX = Q_USARITEM
            Exit Sub
        End If
    End If

    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picInventory_DblClick", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Function IsEqItem(ByVal X As Single, ByVal Y As Single) As Long
    Dim tempRec As RECT
    Dim i As Long
    
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    IsEqItem = 0

    For i = 1 To Equipment.Equipment_Count - 1

        If GetPlayerEquipment(MyIndex, i) > 0 And GetPlayerEquipment(MyIndex, i) <= MAX_ITEMS Then

            With tempRec
                .top = EqTop
                .Bottom = .top + PIC_Y
                .Left = EqLeft + ((EqOffsetX + 32) * (((i - 1) Mod EqColumns)))
                .Right = .Left + PIC_X
            End With

            If X >= tempRec.Left And X <= tempRec.Right Then
                If Y >= tempRec.top And Y <= tempRec.Bottom Then
                    IsEqItem = i
                    Exit Function
                End If
            End If
        End If

    Next

    ' Error handler
    Exit Function
errorhandler:
    HandleError "IsEqItem", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Function
End Function

Private Function IsInvItem(ByVal X As Single, ByVal Y As Single) As Long
    Dim tempRec As RECT
    Dim i As Long
    
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    IsInvItem = 0

    For i = 1 To MAX_INV

        If GetPlayerInvItemNum(MyIndex, i) > 0 And GetPlayerInvItemNum(MyIndex, i) <= MAX_ITEMS Then

            With tempRec
                .top = InvTop + ((InvOffsetY + 32) * ((i - 1) \ InvColumns))
                .Bottom = .top + PIC_Y
                .Left = InvLeft + ((InvOffsetX + 32) * (((i - 1) Mod InvColumns)))
                .Right = .Left + PIC_X
            End With

            If X >= tempRec.Left And X <= tempRec.Right Then
                If Y >= tempRec.top And Y <= tempRec.Bottom Then
                    IsInvItem = i
                    Exit Function
                End If
            End If
        End If

    Next

    ' Error handler
    Exit Function
errorhandler:
    HandleError "IsInvItem", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Function
End Function

Private Function IsPlayerSpell(ByVal X As Single, ByVal Y As Single) As Long
    Dim tempRec As RECT
    Dim i As Long
    
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    IsPlayerSpell = 0

    For i = 1 To MAX_PLAYER_SPELLS

        If PlayerSpells(i) > 0 And PlayerSpells(i) <= MAX_SPELLS Then

            With tempRec
                .top = SpellTop + ((SpellOffsetY + 32) * ((i - 1) \ SpellColumns))
                .Bottom = .top + PIC_Y
                .Left = SpellLeft + ((SpellOffsetX + 32) * (((i - 1) Mod SpellColumns)))
                .Right = .Left + PIC_X
            End With

            If X >= tempRec.Left And X <= tempRec.Right Then
                If Y >= tempRec.top And Y <= tempRec.Bottom Then
                    IsPlayerSpell = i
                    Exit Function
                End If
            End If
        End If

    Next

    ' Error handler
    Exit Function
errorhandler:
    HandleError "IsPlayerSpell", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Function
End Function

Private Function IsTradeItem(ByVal X As Single, ByVal Y As Single, ByVal Yours As Boolean) As Long
    Dim tempRec As RECT
    Dim i As Long
    Dim itemnum As Long
    
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    IsTradeItem = 0

    For i = 1 To MAX_INV
    
        If Yours Then
            itemnum = GetPlayerInvItemNum(MyIndex, TradeYourOffer(i).num)
        Else
            itemnum = TradeTheirOffer(i).num
        End If

        If itemnum > 0 And itemnum <= MAX_ITEMS Then

            With tempRec
                .top = InvTop - 24 + ((InvOffsetY + 32) * ((i - 1) \ InvColumns))
                .Bottom = .top + PIC_Y
                .Left = InvLeft + ((InvOffsetX + 32) * (((i - 1) Mod InvColumns)))
                .Right = .Left + PIC_X
            End With

            If X >= tempRec.Left And X <= tempRec.Right Then
                If Y >= tempRec.top And Y <= tempRec.Bottom Then
                    IsTradeItem = i
                    Exit Function
                End If
            End If
        End If

    Next

    ' Error handler
    Exit Function
errorhandler:
    HandleError "IsTradeItem", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Function
End Function

Private Sub picInventory_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Dim InvNum As Long
    Dim value As Long
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    InvNum = IsInvItem(X, Y)

    If Button = 1 Then
        If InvNum <> 0 Then
            
            If InShop > 0 Then
                Select Case ShopAction
                    Case 0 ' nothing, give value
                        value = Item(GetPlayerInvItemNum(MyIndex, InvNum)).Price
                        
                        If value > 0 Then
                            If Item(GetPlayerInvItemNum(MyIndex, InvNum)).Rarity > 0 Then
                                AddText "Você pode vender por " & value & " CASH.", White
                            Else
                                AddText "Você pode vender por " & value & " YEN.", White
                            End If
                        Else
                            AddText "A loja não aceita esse item.", White
                        End If
                    Case Else
                End Select
                Exit Sub
            End If
            
            If InTrade > 0 Then Exit Sub
            If InBank Or InShop Then Exit Sub
            DragInvSlotNum = InvNum
        End If

    ElseIf Button = 2 Then
        If Not InBank And Not InShop And Not InTrade > 0 Then
            If InvNum <> 0 Then
                Q_INDEX = Q_DROPAR
                tmpInvNum = InvNum
                
                lblBlank(77).Caption = Trim$(Item(GetPlayerInvItemNum(MyIndex, InvNum)).name) & ": Deseja realmente jogar fora esse item?"
                picPergunta.Visible = True
            End If
        End If
    End If

    SetFocusOnChat
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picInventory_MouseDown", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub picInventory_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Dim InvNum As Long
    Dim i As Long
    
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    InvX = X
    InvY = Y

    If DragInvSlotNum > 0 Then
        If InTrade > 0 Then Exit Sub
        If InBank Or InShop Then Exit Sub
        Call BltInventoryItem(X + picInventory.Left, Y + picInventory.top)
    Else
        InvNum = IsInvItem(X, Y)

        If InvNum <> 0 Then
            ' exit out if we're offering that item
            If InTrade Then
                For i = 1 To MAX_INV
                    If TradeYourOffer(i).num = InvNum Then
                        ' is currency?
                        If Item(GetPlayerInvItemNum(MyIndex, TradeYourOffer(i).num)).Type = ITEM_TYPE_CURRENCY Then
                            ' only exit out if we're offering all of it
                            If TradeYourOffer(i).value = GetPlayerInvItemValue(MyIndex, TradeYourOffer(i).num) Then
                                Exit Sub
                            End If
                        Else
                            Exit Sub
                        End If
                    End If
                Next
            End If
            X = X + picInventory.Left - picItemDesc.width - 1
            Y = Y + picInventory.top - picItemDesc.height - 1
            UpdateDescWindow GetPlayerInvItemNum(MyIndex, InvNum), X, Y
            LastItemDesc = GetPlayerInvItemNum(MyIndex, InvNum) ' set it so you don't re-set values
            Exit Sub
        End If
    End If

    picItemDesc.Visible = False
    LastItemDesc = 0 ' no item was last loaded
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picInventory_MouseMove", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub picInventory_MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Dim i As Long
    Dim rec_pos As RECT
    
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    If InTrade > 0 Then Exit Sub
    If InBank Or InShop Then Exit Sub

    If DragInvSlotNum > 0 Then
        ' drag + drop
        For i = 1 To MAX_INV
            With rec_pos
                .top = InvTop + ((InvOffsetY + 32) * ((i - 1) \ InvColumns))
                .Bottom = .top + PIC_Y
                .Left = InvLeft + ((InvOffsetX + 32) * (((i - 1) Mod InvColumns)))
                .Right = .Left + PIC_X
            End With

            If X >= rec_pos.Left And X <= rec_pos.Right Then
                If Y >= rec_pos.top And Y <= rec_pos.Bottom Then '
                    If DragInvSlotNum <> i Then
                        SendChangeInvSlots DragInvSlotNum, i
                        Exit For
                    End If
                End If
            End If
        Next
        ' hotbar
        For i = 1 To MAX_HOTBAR
            With rec_pos
                .top = picHotbar.top - picInventory.top
                .Left = picHotbar.Left - picInventory.Left + (HotbarOffsetX * (i - 1)) + (32 * (i - 1))
                .Right = .Left + 32
                .Bottom = picHotbar.top - picInventory.top + 32
            End With
            
            If X >= rec_pos.Left And X <= rec_pos.Right Then
                If Y >= rec_pos.top And Y <= rec_pos.Bottom Then
                    SendHotbarChange 1, DragInvSlotNum, i
                    DragInvSlotNum = 0
                    picTempInv.Visible = False
                    BltHotbar
                    Exit Sub
                End If
            End If
        Next
    End If

    DragInvSlotNum = 0
    picTempInv.Visible = False
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picInventory_MouseUp", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub picItemDesc_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    picItemDesc.Visible = False
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picItemDesc_MouseMove", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' *****************
' ** Char window **
' *****************

Private Sub picCharacter_Click()
    Dim EqNum As Long
    
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    EqNum = IsEqItem(EqX, EqY)

    If EqNum <> 0 Then
        SendUnequip EqNum
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picCharacter_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub picCharacter_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Dim EqNum As Long
    Dim x2 As Long, y2 As Long
    
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    EqX = X
    EqY = Y
    EqNum = IsEqItem(X, Y)

    If EqNum <> 0 Then
        y2 = Y + picCharacter.top - frmMain.picItemDesc.height - 1
        x2 = X + picCharacter.Left - frmMain.picItemDesc.width - 1
        UpdateDescWindow GetPlayerEquipment(MyIndex, EqNum), x2, y2
        LastItemDesc = GetPlayerEquipment(MyIndex, EqNum) ' set it so you don't re-set values
        Exit Sub
    End If

    picItemDesc.Visible = False
    LastItemDesc = 0 ' no item was last loaded
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picCharacter_MouseMove", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' ****************
' ** Admin Menu **
' ****************

Private Sub cmdALoc_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If GetPlayerAccess(MyIndex) < ADMIN_MAPPER Then
        
        Exit Sub
    End If
    
    BLoc = Not BLoc
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "cmdALoc_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub cmdAMap_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If GetPlayerAccess(MyIndex) < ADMIN_MAPPER Then
        
        Exit Sub
    End If
    
    SendRequestEditMap
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "cmdAMap_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub cmdAWarp2Me_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If GetPlayerAccess(MyIndex) < 2 Then
        
        Exit Sub
    End If

    If Len(Trim$(txtAName.text)) < 1 Then
        Exit Sub
    End If

    If IsNumeric(Trim$(txtAName.text)) Then
        Exit Sub
    End If

    WarpToMe Trim$(txtAName.text)
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "cmdAWarp2Me_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub cmdAWarpMe2_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If GetPlayerAccess(MyIndex) < 2 Then
        
        Exit Sub
    End If

    If Len(Trim$(txtAName.text)) < 1 Then
        Exit Sub
    End If

    If IsNumeric(Trim$(txtAName.text)) Then
        Exit Sub
    End If

    WarpMeTo Trim$(txtAName.text)
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "cmdAWarpMe2_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub cmdAWarp_Click()
Dim n As Long

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If GetPlayerAccess(MyIndex) < 2 Then
        
        Exit Sub
    End If

    If Len(Trim$(txtAMap.text)) < 1 Then
        Exit Sub
    End If

    If Not IsNumeric(Trim$(txtAMap.text)) Then
        Exit Sub
    End If

    n = CLng(Trim$(txtAMap.text))

    ' Check to make sure its a valid map #
    If n > 0 And n <= MAX_MAPS Then
        Call WarpTo(n)
    Else
        Call AddText("Invalid map number.", Red)
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "cmdAWarp_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub cmdASprite_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If GetPlayerAccess(MyIndex) < ADMIN_MONITOR Then
        
        Exit Sub
    End If

    If Len(Trim$(txtASprite.text)) < 1 Then
        Exit Sub
    End If

    If Not IsNumeric(Trim$(txtASprite.text)) Then
        Exit Sub
    End If

    SendSetSprite CLng(Trim$(txtASprite.text))
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "cmdASprite_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub cmdAMapReport_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If GetPlayerAccess(MyIndex) < ADMIN_MAPPER Then
        
        Exit Sub
    End If

    SendMapReport
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "cmdAMapReport_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub cmdARespawn_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If GetPlayerAccess(MyIndex) < ADMIN_MAPPER Then
        
        Exit Sub
    End If
    
    SendMapRespawn
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "cmdARespawn_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub cmdABan_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If GetPlayerAccess(MyIndex) < ADMIN_MONITOR Then
        
        Exit Sub
    End If

    If Len(Trim$(txtAName.text)) < 1 Then
        Exit Sub
    End If

    'SendBAN Trim$(txtAName.text), vbNullString
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "cmdABan_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub cmdAItem_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If GetPlayerAccess(MyIndex) < ADMIN_CREATOR Then
        
        Exit Sub
    End If

    SendRequestEditItem
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "cmdAItem_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub cmdANpc_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If GetPlayerAccess(MyIndex) < ADMIN_DEVELOPER Then
        
        Exit Sub
    End If

    SendRequestEditNpc
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "cmdANpc_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub cmdAResource_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If GetPlayerAccess(MyIndex) < ADMIN_DEVELOPER Then
        
        Exit Sub
    End If

    SendRequestEditResource
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "cmdAResource_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub cmdAShop_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If GetPlayerAccess(MyIndex) < ADMIN_DEVELOPER Then
        
        Exit Sub
    End If

    SendRequestEditShop
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "cmdAShop_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub cmdASpell_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If GetPlayerAccess(MyIndex) < ADMIN_DEVELOPER Then
        
        Exit Sub
    End If

    SendRequestEditSpell
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "cmdASpell_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub cmdAAccess_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If GetPlayerAccess(MyIndex) < ADMIN_CREATOR Then
        
        Exit Sub
    End If

    If Len(Trim$(txtAName.text)) < 2 Then
        Exit Sub
    End If

    If IsNumeric(Trim$(txtAName.text)) Or Not IsNumeric(Trim$(txtAAccess.text)) Then
        Exit Sub
    End If

    SendSetAccess Trim$(txtAName.text), CLng(Trim$(txtAAccess.text))
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "cmdAAccess_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub cmdADestroy_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If GetPlayerAccess(MyIndex) < ADMIN_CREATOR Then
        
        Exit Sub
    End If

    SendBanDestroy
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "cmdADestroy_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub cmdASpawn_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If GetPlayerAccess(MyIndex) < ADMIN_CREATOR Then
        
        Exit Sub
    End If
    
    SendSpawnItem scrlAItem.value, scrlAAmount.value
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "cmdASpawn_Click", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' bank
Private Sub picBank_DblClick()
Dim bankNum As Long

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    DragBankSlotNum = 0

    bankNum = IsBankItem(BankX, BankY)
    If bankNum <> 0 Then
         If GetBankItemNum(bankNum) = ITEM_TYPE_NONE Then Exit Sub
         
             If Item(GetBankItemNum(bankNum)).Type = ITEM_TYPE_CURRENCY Then
                CurrencyMenu = 3 ' withdraw
                lblCurrency.Caption = "How many do you want to withdraw?"
                tmpCurrencyItem = bankNum
                txtCurrency.text = vbNullString
                picCurrency.Visible = True
                txtCurrency.SetFocus
                Exit Sub
            End If
            
         WithdrawItem bankNum, 0
         Exit Sub
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picBank_DlbClick", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub picBank_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)
Dim bankNum As Long
                        
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    bankNum = IsBankItem(X, Y)
    
    If bankNum <> 0 Then
        
        If Button = 1 Then
            DragBankSlotNum = bankNum
        End If
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picBank_MouseDown", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub picBank_MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)
Dim i As Long
Dim rec_pos As RECT
    
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

' TODO : Add sub to change bankslots client side first so there's no delay in switching
    If DragBankSlotNum > 0 Then
        For i = 1 To MAX_BANK
            With rec_pos
                .top = BankTop + ((BankOffsetY + 32) * ((i - 1) \ BankColumns))
                .Bottom = .top + PIC_Y
                .Left = BankLeft + ((BankOffsetX + 32) * (((i - 1) Mod BankColumns)))
                .Right = .Left + PIC_X
            End With

            If X >= rec_pos.Left And X <= rec_pos.Right Then
                If Y >= rec_pos.top And Y <= rec_pos.Bottom Then
                    If DragBankSlotNum <> i Then
                        ChangeBankSlots DragBankSlotNum, i
                        Exit For
                    End If
                End If
            End If
        Next
    End If

    DragBankSlotNum = 0
    picTempBank.Visible = False
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picBank_MouseUp", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub picBank_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
Dim bankNum As Long, itemnum As Long, ItemType As Long
Dim x2 As Long, y2 As Long

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    BankX = X
    BankY = Y
    
    If DragBankSlotNum > 0 Then
        Call BltBankItem(X + picBank.Left, Y + picBank.top)
    Else
        bankNum = IsBankItem(X, Y)
        
        If bankNum <> 0 Then
            
            x2 = X + picBank.Left + 1
            y2 = Y + picBank.top + 1
            UpdateDescWindow Bank.Item(bankNum).num, x2, y2
            Exit Sub
        End If
    End If
    
    frmMain.picItemDesc.Visible = False
    LastBankDesc = 0
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picBank_MouseMove", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Function IsBankItem(ByVal X As Single, ByVal Y As Single) As Long
Dim tempRec As RECT
Dim i As Long

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    IsBankItem = 0
    
    For i = 1 To MAX_BANK
        If GetBankItemNum(i) > 0 And GetBankItemNum(i) <= MAX_ITEMS Then
        
            With tempRec
                .top = BankTop + ((BankOffsetY + 32) * ((i - 1) \ BankColumns))
                .Bottom = .top + PIC_Y
                .Left = BankLeft + ((BankOffsetX + 32) * (((i - 1) Mod BankColumns)))
                .Right = .Left + PIC_X
            End With
            
            If X >= tempRec.Left And X <= tempRec.Right Then
                If Y >= tempRec.top And Y <= tempRec.Bottom Then
                    
                    IsBankItem = i
                    Exit Function
                End If
            End If
        End If
    Next
    
    ' Error handler
    Exit Function
errorhandler:
    HandleError "IsBankItem", "frmMain", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Function
End Function

Private Sub txtMyChat_Click()
If Options.WASD = YES Then
    picAVISO.Visible = True
    lblBlank(83).Caption = "Movimento WASD está ativado,se quizer digitar,desative-o(Config>Movimento WASD)"
    ChatFocus = False
    Exit Sub
End If

ChatFocus = True
End Sub

Private Sub txtMyChat_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)

If Button = 2 Then 'direito
    enableChatTmr = GetTickCount + 1000
    txtMyChat.Enabled = False
    txtChat.Locked = True
End If

End Sub
