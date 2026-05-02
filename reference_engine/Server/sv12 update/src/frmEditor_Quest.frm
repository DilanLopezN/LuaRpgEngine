VERSION 5.00
Begin VB.Form frmEditor_Quest 
   Caption         =   "Quest Edit"
   ClientHeight    =   7470
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   10545
   LinkTopic       =   "Form1"
   ScaleHeight     =   7470
   ScaleWidth      =   10545
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command7 
      Caption         =   "Recompensas"
      Height          =   495
      Left            =   8280
      TabIndex        =   105
      Top             =   120
      Width           =   1575
   End
   Begin VB.CommandButton Command6 
      Caption         =   "Tarefas"
      Height          =   495
      Left            =   6480
      TabIndex        =   104
      Top             =   120
      Width           =   1695
   End
   Begin VB.CommandButton Command5 
      Caption         =   "Requerimentos"
      Height          =   495
      Left            =   4680
      TabIndex        =   103
      Top             =   120
      Width           =   1695
   End
   Begin VB.CommandButton Command4 
      Caption         =   "Informações!"
      Height          =   495
      Left            =   2880
      TabIndex        =   102
      Top             =   120
      Width           =   1695
   End
   Begin VB.Frame fraRec 
      Caption         =   "Recompensas"
      Height          =   6615
      Left            =   2520
      TabIndex        =   72
      Top             =   600
      Visible         =   0   'False
      Width           =   7935
      Begin VB.Frame Frame5 
         Caption         =   "Extras"
         Height          =   2775
         Left            =   840
         TabIndex        =   94
         Top             =   3840
         Width           =   6015
         Begin VB.HScrollBar scrlElemento 
            Height          =   255
            Left            =   4320
            TabIndex        =   130
            Top             =   2040
            Width           =   1335
         End
         Begin VB.HScrollBar scrlOrg 
            Height          =   255
            Left            =   4320
            TabIndex        =   120
            Top             =   1560
            Visible         =   0   'False
            Width           =   1335
         End
         Begin VB.HScrollBar scrlRank 
            Height          =   255
            Left            =   4320
            Max             =   4
            TabIndex        =   114
            Top             =   960
            Visible         =   0   'False
            Width           =   1335
         End
         Begin VB.HScrollBar scrlRscript 
            Height          =   255
            Left            =   1680
            TabIndex        =   109
            Top             =   2280
            Width           =   1575
         End
         Begin VB.HScrollBar scrlRclass 
            Height          =   255
            Left            =   1680
            TabIndex        =   107
            Top             =   840
            Width           =   1575
         End
         Begin VB.HScrollBar scrlSpell 
            Height          =   255
            Left            =   1680
            TabIndex        =   100
            Top             =   1800
            Width           =   1575
         End
         Begin VB.HScrollBar scrlSprite 
            Height          =   255
            Left            =   1680
            TabIndex        =   98
            Top             =   1320
            Width           =   1575
         End
         Begin VB.TextBox txtEXP 
            Height          =   375
            Left            =   1680
            TabIndex        =   95
            Text            =   "EXP"
            Top             =   240
            Width           =   1575
         End
         Begin VB.Label lblElemento 
            Caption         =   "Elemento:0"
            Height          =   255
            Left            =   3360
            TabIndex        =   131
            Top             =   2040
            Width           =   975
         End
         Begin VB.Label lblOrg 
            Caption         =   "Org:Nenhuma"
            Height          =   255
            Left            =   4080
            TabIndex        =   121
            Top             =   1320
            Visible         =   0   'False
            Width           =   1815
         End
         Begin VB.Label lblRank 
            Caption         =   "Rank:Nenhum"
            Height          =   255
            Left            =   4320
            TabIndex        =   115
            Top             =   720
            Visible         =   0   'False
            Width           =   1455
         End
         Begin VB.Label lblRscript 
            Caption         =   "EndScript:Nenhum"
            Height          =   255
            Left            =   240
            TabIndex        =   110
            Top             =   2280
            Width           =   1455
         End
         Begin VB.Label lblSpell 
            Caption         =   "Spell:Nenhuma"
            Height          =   255
            Left            =   240
            TabIndex        =   101
            Top             =   1800
            Width           =   1215
         End
         Begin VB.Label lblSprite 
            Caption         =   "Sprite:Nenhuma"
            Height          =   255
            Left            =   240
            TabIndex        =   99
            Top             =   1320
            Width           =   1215
         End
         Begin VB.Label lblRclass 
            Caption         =   "Classe:Nenhuma"
            Height          =   255
            Left            =   240
            TabIndex        =   97
            Top             =   840
            Width           =   1335
         End
         Begin VB.Label lblEXP 
            Caption         =   "EXP:Nenhuma"
            Height          =   255
            Left            =   240
            TabIndex        =   96
            Top             =   360
            Width           =   1335
         End
      End
      Begin VB.Frame Frame4 
         Caption         =   "Itens"
         Height          =   3615
         Left            =   360
         TabIndex        =   73
         Top             =   240
         Width           =   7215
         Begin VB.HScrollBar scrlRecItem1 
            Height          =   255
            Left            =   120
            Max             =   255
            TabIndex        =   83
            Top             =   600
            Width           =   1455
         End
         Begin VB.HScrollBar scrlRecItem1Qnt 
            Height          =   255
            Left            =   4560
            TabIndex        =   82
            Top             =   600
            Width           =   1455
         End
         Begin VB.HScrollBar scrlRecItem2 
            Height          =   255
            Left            =   120
            Max             =   255
            TabIndex        =   81
            Top             =   1200
            Width           =   1455
         End
         Begin VB.HScrollBar scrlRecItem2Qnt 
            Height          =   255
            Left            =   4560
            TabIndex        =   80
            Top             =   1200
            Width           =   1455
         End
         Begin VB.HScrollBar scrlRecItem3 
            Height          =   255
            Left            =   120
            Max             =   255
            TabIndex        =   79
            Top             =   1800
            Width           =   1455
         End
         Begin VB.HScrollBar scrlRecItem3Qnt 
            Height          =   255
            Left            =   4560
            TabIndex        =   78
            Top             =   1800
            Width           =   1455
         End
         Begin VB.HScrollBar scrlRecItem4 
            Height          =   255
            Left            =   120
            Max             =   255
            TabIndex        =   77
            Top             =   2400
            Width           =   1455
         End
         Begin VB.HScrollBar scrlRecItem4Qnt 
            Height          =   255
            Left            =   4560
            TabIndex        =   76
            Top             =   2400
            Width           =   1455
         End
         Begin VB.HScrollBar scrlRecItem5 
            Height          =   255
            Left            =   120
            Max             =   255
            TabIndex        =   75
            Top             =   3000
            Width           =   1455
         End
         Begin VB.HScrollBar scrlRecItem5Qnt 
            Height          =   255
            Left            =   4560
            TabIndex        =   74
            Top             =   3000
            Width           =   1455
         End
         Begin VB.Label lblRecItem 
            Caption         =   "Item:Nenhum"
            Height          =   255
            Left            =   120
            TabIndex        =   93
            Top             =   360
            Width           =   3975
         End
         Begin VB.Label lblRecItemQnt 
            Caption         =   "Qnt:0"
            Height          =   255
            Left            =   4560
            TabIndex        =   92
            Top             =   360
            Width           =   2655
         End
         Begin VB.Label lblRecItem2 
            Caption         =   "Item:Nenhum"
            Height          =   255
            Left            =   120
            TabIndex        =   91
            Top             =   960
            Width           =   3975
         End
         Begin VB.Label lblRecItem2Qnt 
            Caption         =   "Qnt:0"
            Height          =   255
            Left            =   4560
            TabIndex        =   90
            Top             =   960
            Width           =   1455
         End
         Begin VB.Label lblRecItem3 
            Caption         =   "Item:Nenhum"
            Height          =   255
            Left            =   120
            TabIndex        =   89
            Top             =   1560
            Width           =   3855
         End
         Begin VB.Label lblRecItem3Qnt 
            Caption         =   "Qnt:0"
            Height          =   255
            Left            =   4560
            TabIndex        =   88
            Top             =   1560
            Width           =   1455
         End
         Begin VB.Label lblRecItem4 
            Caption         =   "Item:Nenhum"
            Height          =   255
            Left            =   120
            TabIndex        =   87
            Top             =   2160
            Width           =   3735
         End
         Begin VB.Label lblRecItem4Qnt 
            Caption         =   "Qnt:0"
            Height          =   255
            Left            =   4560
            TabIndex        =   86
            Top             =   2160
            Width           =   1455
         End
         Begin VB.Label lblRecItem5 
            Caption         =   "Item:Nenhum"
            Height          =   255
            Left            =   120
            TabIndex        =   85
            Top             =   2760
            Width           =   3735
         End
         Begin VB.Label lblRecItem5Qnt 
            Caption         =   "Qnt:0"
            Height          =   255
            Left            =   4560
            TabIndex        =   84
            Top             =   2760
            Width           =   1455
         End
      End
   End
   Begin VB.Frame fraTarefas 
      Caption         =   "Tarefas"
      Height          =   6735
      Left            =   2520
      TabIndex        =   24
      Top             =   600
      Visible         =   0   'False
      Width           =   7935
      Begin VB.Frame Frame3 
         Caption         =   "Extras"
         Height          =   2415
         Left            =   360
         TabIndex        =   67
         Top             =   4200
         Width           =   6495
         Begin VB.HScrollBar scrlUsarSpellQnt 
            Height          =   255
            Left            =   4080
            TabIndex        =   125
            Top             =   960
            Width           =   1335
         End
         Begin VB.HScrollBar scrlUsarSpell 
            Height          =   255
            Left            =   4080
            TabIndex        =   123
            Top             =   480
            Width           =   1335
         End
         Begin VB.HScrollBar scrlKillPlayerQnt 
            Height          =   255
            Left            =   960
            TabIndex        =   119
            Top             =   2160
            Width           =   1935
         End
         Begin VB.HScrollBar scrlKillPlayerClass 
            Height          =   255
            Left            =   960
            Max             =   100
            TabIndex        =   116
            Top             =   1680
            Width           =   1935
         End
         Begin VB.HScrollBar scrlMAP 
            Height          =   255
            Left            =   960
            TabIndex        =   70
            Top             =   1080
            Width           =   1935
         End
         Begin VB.HScrollBar scrlNeedLvl 
            Height          =   255
            Left            =   960
            TabIndex        =   68
            Top             =   480
            Width           =   1935
         End
         Begin VB.Label lblUsarSpellQnt 
            Caption         =   "Qnt:0"
            Height          =   255
            Left            =   4080
            TabIndex        =   124
            Top             =   720
            Width           =   855
         End
         Begin VB.Label lblUsarSpell 
            Caption         =   "Spell:Nenhuma"
            Height          =   255
            Left            =   4080
            TabIndex        =   122
            Top             =   240
            Width           =   1575
         End
         Begin VB.Label lblKillPlayerQnt 
            Caption         =   "KillPlayerQnt:0"
            Height          =   255
            Left            =   960
            TabIndex        =   118
            Top             =   1920
            Width           =   1935
         End
         Begin VB.Label lblKillPlayerClass 
            Caption         =   "KillPlayer Class:Nenhuma"
            Height          =   255
            Left            =   960
            TabIndex        =   117
            Top             =   1440
            Width           =   2775
         End
         Begin VB.Label lblMAP 
            Caption         =   "Mapa:Nenhum"
            Height          =   255
            Left            =   960
            TabIndex        =   71
            Top             =   840
            Width           =   1935
         End
         Begin VB.Label lblNeedLvl 
            Caption         =   "Level:Nenhum"
            Height          =   255
            Left            =   960
            TabIndex        =   69
            Top             =   240
            Width           =   1935
         End
      End
      Begin VB.Frame Frame2 
         Caption         =   "NPC's"
         Height          =   3615
         Left            =   3960
         TabIndex        =   46
         Top             =   240
         Width           =   3735
         Begin VB.HScrollBar scrlNpc1 
            Height          =   255
            Left            =   120
            Max             =   255
            TabIndex        =   56
            Top             =   600
            Width           =   1455
         End
         Begin VB.HScrollBar scrlNpc1Qnt 
            Height          =   255
            Left            =   2880
            TabIndex        =   55
            Top             =   600
            Width           =   735
         End
         Begin VB.HScrollBar scrlNpc2 
            Height          =   255
            Left            =   120
            Max             =   255
            TabIndex        =   54
            Top             =   1200
            Width           =   1455
         End
         Begin VB.HScrollBar scrlNpc2Qnt 
            Height          =   255
            Left            =   2880
            TabIndex        =   53
            Top             =   1200
            Width           =   735
         End
         Begin VB.HScrollBar scrlNpc3 
            Height          =   255
            Left            =   120
            Max             =   255
            TabIndex        =   52
            Top             =   1800
            Width           =   1455
         End
         Begin VB.HScrollBar scrlNpc3Qnt 
            Height          =   255
            Left            =   2880
            TabIndex        =   51
            Top             =   1800
            Width           =   735
         End
         Begin VB.HScrollBar scrlNpc4 
            Height          =   255
            Left            =   120
            Max             =   255
            TabIndex        =   50
            Top             =   2400
            Width           =   1455
         End
         Begin VB.HScrollBar scrlNpc4Qnt 
            Height          =   255
            Left            =   2880
            TabIndex        =   49
            Top             =   2400
            Width           =   735
         End
         Begin VB.HScrollBar scrlNpc5 
            Height          =   255
            Left            =   120
            Max             =   255
            TabIndex        =   48
            Top             =   3000
            Width           =   1455
         End
         Begin VB.HScrollBar scrlNpc5Qnt 
            Height          =   255
            Left            =   2880
            TabIndex        =   47
            Top             =   3000
            Width           =   735
         End
         Begin VB.Label lblNpc 
            Caption         =   "Npc:Nenhum"
            Height          =   255
            Left            =   120
            TabIndex        =   66
            Top             =   360
            Width           =   2415
         End
         Begin VB.Label lblNpcQnt 
            Caption         =   "Qnt:0"
            Height          =   255
            Left            =   2760
            TabIndex        =   65
            Top             =   360
            Width           =   1455
         End
         Begin VB.Label lblNpc2 
            Caption         =   "Npc:Nenhum"
            Height          =   255
            Left            =   120
            TabIndex        =   64
            Top             =   960
            Width           =   2415
         End
         Begin VB.Label lblNpc2Qnt 
            Caption         =   "Qnt:0"
            Height          =   255
            Left            =   2760
            TabIndex        =   63
            Top             =   960
            Width           =   1455
         End
         Begin VB.Label lblNpc3 
            Caption         =   "Npc:Nenhum"
            Height          =   255
            Left            =   120
            TabIndex        =   62
            Top             =   1560
            Width           =   2415
         End
         Begin VB.Label lblNpc3Qnt 
            Caption         =   "Qnt:0"
            Height          =   255
            Left            =   2760
            TabIndex        =   61
            Top             =   1560
            Width           =   1455
         End
         Begin VB.Label lblNpc4 
            Caption         =   "Npc:Nenhum"
            Height          =   255
            Left            =   120
            TabIndex        =   60
            Top             =   2160
            Width           =   2415
         End
         Begin VB.Label lblNpc4Qnt 
            Caption         =   "Qnt:0"
            Height          =   255
            Left            =   2760
            TabIndex        =   59
            Top             =   2160
            Width           =   1575
         End
         Begin VB.Label lblNpc5 
            Caption         =   "Npc:Nenhum"
            Height          =   255
            Left            =   120
            TabIndex        =   58
            Top             =   2760
            Width           =   2535
         End
         Begin VB.Label lblNpc5Qnt 
            Caption         =   "Qnt:0"
            Height          =   255
            Left            =   2760
            TabIndex        =   57
            Top             =   2760
            Width           =   1455
         End
      End
      Begin VB.Frame Frame1 
         Caption         =   "Itens"
         Height          =   3615
         Left            =   120
         TabIndex        =   25
         Top             =   240
         Width           =   3735
         Begin VB.HScrollBar scrlItem5Qnt 
            Height          =   255
            Left            =   2880
            TabIndex        =   45
            Top             =   3000
            Width           =   735
         End
         Begin VB.HScrollBar scrlItem5 
            Height          =   255
            Left            =   120
            Max             =   255
            TabIndex        =   43
            Top             =   3000
            Width           =   1455
         End
         Begin VB.HScrollBar scrlItem4Qnt 
            Height          =   255
            Left            =   2880
            TabIndex        =   41
            Top             =   2400
            Width           =   735
         End
         Begin VB.HScrollBar scrlItem4 
            Height          =   255
            Left            =   120
            Max             =   255
            TabIndex        =   39
            Top             =   2400
            Width           =   1455
         End
         Begin VB.HScrollBar scrlItem3Qnt 
            Height          =   255
            Left            =   2880
            TabIndex        =   37
            Top             =   1800
            Width           =   735
         End
         Begin VB.HScrollBar scrlItem3 
            Height          =   255
            Left            =   120
            Max             =   255
            TabIndex        =   36
            Top             =   1800
            Width           =   1455
         End
         Begin VB.HScrollBar scrlItem2Qnt 
            Height          =   255
            Left            =   2880
            TabIndex        =   33
            Top             =   1200
            Width           =   735
         End
         Begin VB.HScrollBar scrlItem2 
            Height          =   255
            Left            =   120
            Max             =   255
            TabIndex        =   30
            Top             =   1200
            Width           =   1455
         End
         Begin VB.HScrollBar scrlItem1Qnt 
            Height          =   255
            Left            =   2880
            TabIndex        =   28
            Top             =   600
            Width           =   735
         End
         Begin VB.HScrollBar scrlItem1 
            Height          =   255
            Left            =   120
            Max             =   255
            TabIndex        =   26
            Top             =   600
            Width           =   1455
         End
         Begin VB.Label lblItem5Qnt 
            Caption         =   "Qnt:0"
            Height          =   255
            Left            =   2640
            TabIndex        =   44
            Top             =   2760
            Width           =   1455
         End
         Begin VB.Label lblItem5 
            Caption         =   "Item:Nenhum"
            Height          =   255
            Left            =   120
            TabIndex        =   42
            Top             =   2760
            Width           =   2415
         End
         Begin VB.Label lblItem4Qnt 
            Caption         =   "Qnt:0"
            Height          =   255
            Left            =   2640
            TabIndex        =   40
            Top             =   2160
            Width           =   1575
         End
         Begin VB.Label lblItem4 
            Caption         =   "Item:Nenhum"
            Height          =   255
            Left            =   120
            TabIndex        =   38
            Top             =   2160
            Width           =   2415
         End
         Begin VB.Label lblItem3Qnt 
            Caption         =   "Qnt:0"
            Height          =   255
            Left            =   2640
            TabIndex        =   35
            Top             =   1560
            Width           =   1455
         End
         Begin VB.Label lblItem3 
            Caption         =   "Item:Nenhum"
            Height          =   255
            Left            =   120
            TabIndex        =   34
            Top             =   1560
            Width           =   2415
         End
         Begin VB.Label lblItem2Qnt 
            Caption         =   "Qnt:0"
            Height          =   255
            Left            =   2640
            TabIndex        =   32
            Top             =   960
            Width           =   1455
         End
         Begin VB.Label lblItem2 
            Caption         =   "Item:Nenhum"
            Height          =   255
            Left            =   120
            TabIndex        =   31
            Top             =   960
            Width           =   2535
         End
         Begin VB.Label lblItemQnt 
            Caption         =   "Qnt:0"
            Height          =   255
            Left            =   2640
            TabIndex        =   29
            Top             =   360
            Width           =   1455
         End
         Begin VB.Label lblItem 
            Caption         =   "Item:Nenhum"
            BeginProperty Font 
               Name            =   "Comic Sans MS"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Height          =   255
            Left            =   120
            TabIndex        =   27
            Top             =   360
            Width           =   2535
         End
      End
   End
   Begin VB.Frame fraReq 
      Caption         =   "Requerimentos"
      Height          =   4095
      Left            =   3120
      TabIndex        =   16
      Top             =   2160
      Visible         =   0   'False
      Width           =   6615
      Begin VB.HScrollBar scrlReqElemento 
         Height          =   255
         Left            =   2520
         Max             =   5
         TabIndex        =   129
         Top             =   3120
         Width           =   2415
      End
      Begin VB.HScrollBar scrlReqVila 
         Height          =   255
         Left            =   2520
         Max             =   4
         TabIndex        =   127
         Top             =   2760
         Width           =   2415
      End
      Begin VB.HScrollBar scrlClassReq 
         Height          =   255
         Left            =   2520
         TabIndex        =   106
         Top             =   960
         Width           =   2415
      End
      Begin VB.HScrollBar scrlParty 
         Height          =   255
         Left            =   2520
         Max             =   4
         TabIndex        =   22
         Top             =   2280
         Width           =   2415
      End
      Begin VB.HScrollBar scrlVIP 
         Height          =   255
         Left            =   2520
         Max             =   3
         TabIndex        =   20
         Top             =   1680
         Width           =   2415
      End
      Begin VB.TextBox txtLvlReq 
         Height          =   405
         Left            =   2520
         TabIndex        =   17
         Text            =   "Level"
         Top             =   360
         Width           =   1455
      End
      Begin VB.Label lblReqElemento 
         Caption         =   "Elemento:Nenhum"
         Height          =   255
         Left            =   1080
         TabIndex        =   128
         Top             =   3120
         Width           =   1335
      End
      Begin VB.Label lblReqVila 
         Caption         =   "Vila:Nenhuma"
         Height          =   255
         Left            =   1320
         TabIndex        =   126
         Top             =   2760
         Width           =   1215
      End
      Begin VB.Label lblParty 
         Caption         =   "PartyMembers:0"
         Height          =   255
         Left            =   1200
         TabIndex        =   23
         Top             =   2280
         Width           =   1215
      End
      Begin VB.Label lblVIP 
         Caption         =   "VIP:Não"
         Height          =   255
         Left            =   1680
         TabIndex        =   21
         Top             =   1680
         Width           =   855
      End
      Begin VB.Label lblClassReq 
         Caption         =   "Classe:Nenhuma"
         Height          =   375
         Left            =   960
         TabIndex        =   19
         Top             =   960
         Width           =   1335
      End
      Begin VB.Label lblLvlReq 
         Caption         =   "Level:0"
         Height          =   375
         Left            =   1560
         TabIndex        =   18
         Top             =   480
         Width           =   855
      End
   End
   Begin VB.Frame fraInfo 
      Caption         =   "Informações"
      Height          =   6615
      Left            =   2520
      TabIndex        =   4
      Top             =   720
      Width           =   7935
      Begin VB.CheckBox chckRep 
         Caption         =   "Repetível?"
         Height          =   255
         Left            =   840
         TabIndex        =   113
         Top             =   2280
         Width           =   2295
      End
      Begin VB.HScrollBar scrlStartScript 
         Height          =   255
         Left            =   1920
         TabIndex        =   111
         Top             =   2760
         Width           =   1695
      End
      Begin VB.HScrollBar scrlTipo 
         Height          =   255
         Left            =   3960
         Max             =   7
         TabIndex        =   108
         Top             =   720
         Width           =   1095
      End
      Begin VB.TextBox txtMsg3 
         Height          =   975
         Left            =   1920
         MultiLine       =   -1  'True
         ScrollBars      =   2  'Vertical
         TabIndex        =   13
         Text            =   "frmEditor_Quest.frx":0000
         Top             =   5160
         Width           =   5055
      End
      Begin VB.TextBox txtMsg2 
         Height          =   975
         Left            =   1920
         MultiLine       =   -1  'True
         ScrollBars      =   2  'Vertical
         TabIndex        =   11
         Text            =   "frmEditor_Quest.frx":000B
         Top             =   4080
         Width           =   5055
      End
      Begin VB.TextBox txtMsg1 
         Height          =   975
         Left            =   1920
         MultiLine       =   -1  'True
         ScrollBars      =   2  'Vertical
         TabIndex        =   9
         Text            =   "frmEditor_Quest.frx":0016
         Top             =   3000
         Width           =   5055
      End
      Begin VB.TextBox txtDesc 
         Height          =   735
         Left            =   1920
         MultiLine       =   -1  'True
         ScrollBars      =   2  'Vertical
         TabIndex        =   7
         Text            =   "frmEditor_Quest.frx":0027
         Top             =   1440
         Width           =   5055
      End
      Begin VB.TextBox txtName 
         Height          =   285
         Left            =   2160
         TabIndex        =   5
         Text            =   "Nome"
         Top             =   240
         Width           =   2895
      End
      Begin VB.Label lblStartScript 
         Caption         =   "StartScript:Nenhum"
         Height          =   255
         Left            =   360
         TabIndex        =   112
         Top             =   2760
         Width           =   1455
      End
      Begin VB.Label lblTipo 
         Caption         =   "Tipo da Quest:Nenhum"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   12
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   375
         Left            =   240
         TabIndex        =   15
         Top             =   720
         Width           =   2775
      End
      Begin VB.Label Label5 
         Caption         =   "Quest Completa!"
         Height          =   495
         Left            =   480
         TabIndex        =   14
         Top             =   5520
         Width           =   1455
      End
      Begin VB.Label Label4 
         Caption         =   "Já começou.."
         Height          =   495
         Left            =   720
         TabIndex        =   12
         Top             =   4440
         Width           =   1095
      End
      Begin VB.Label Label3 
         Caption         =   "Início Quest:"
         Height          =   375
         Left            =   720
         TabIndex        =   10
         Top             =   3360
         Width           =   1095
      End
      Begin VB.Label Label2 
         Caption         =   "Descrição:"
         Height          =   615
         Left            =   960
         TabIndex        =   8
         Top             =   1680
         Width           =   975
      End
      Begin VB.Label Label1 
         Caption         =   "Nome:"
         Height          =   255
         Left            =   1440
         TabIndex        =   6
         Top             =   240
         Width           =   735
      End
   End
   Begin VB.CommandButton Command3 
      Caption         =   "Cancelar"
      Height          =   375
      Left            =   480
      TabIndex        =   3
      Top             =   6720
      Width           =   1455
   End
   Begin VB.CommandButton Command2 
      Caption         =   "Deletar"
      Height          =   375
      Left            =   480
      TabIndex        =   2
      Top             =   6120
      Width           =   1455
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Salvar"
      Height          =   375
      Left            =   480
      TabIndex        =   1
      Top             =   5520
      Width           =   1455
   End
   Begin VB.ListBox lstIndex 
      Height          =   5130
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   2295
   End
End
Attribute VB_Name = "frmEditor_Quest"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub cmbClassReq_Change()
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    Quest(EditorIndex).ReqClasse = cmbClassReq.ListIndex
End Sub

Private Sub cmbRecClass_Change()
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    Quest(EditorIndex).rClasse = cmbRecClass.ListIndex
End Sub

Private Sub cmbTipo_Change()
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
Quest(EditorIndex).Tipo = cmbTipo.ListIndex


End Sub

Private Sub chckRep_Click()
Quest(EditorIndex).Repetivel = chckRep.Value
End Sub

Private Sub Command1_Click()
QuestEditorOk

End Sub

Private Sub Command2_Click()
Dim tmpIndex As Long
    
   
    If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    
    ClearQuest EditorIndex
    
    tmpIndex = lstIndex.ListIndex
    lstIndex.RemoveItem EditorIndex - 1
    lstIndex.AddItem EditorIndex & ": " & Quest(EditorIndex).Name, EditorIndex - 1
    lstIndex.ListIndex = tmpIndex
    
    QuestEditorInit
End Sub

Private Sub Command3_Click()
QuestEditorCancel

End Sub



Private Sub Command4_Click()
fraReq.Visible = False
fraInfo.Visible = True
fraRec.Visible = False
fraTarefas.Visible = False
End Sub

Private Sub Command5_Click()
fraReq.Visible = True
fraInfo.Visible = False
fraRec.Visible = False
fraTarefas.Visible = False
End Sub

Private Sub Command6_Click()
fraReq.Visible = False
fraInfo.Visible = False
fraRec.Visible = False
fraTarefas.Visible = True
End Sub

Private Sub Command7_Click()
fraReq.Visible = False
fraInfo.Visible = False
fraRec.Visible = True
fraTarefas.Visible = False
End Sub

Private Sub Form_Load()
scrlKillPlayerClass.Max = Max_Classes
End Sub

Private Sub lstIndex_Click()
QuestEditorInit
End Sub

Private Sub scrlValor_Change()


End Sub

Private Sub scrlClassReq_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlClassReq.Value = 0 Then
        sString = "Nenhuma"
    Else
        sString = Class(scrlClassReq.Value).Name
    End If
    lblClassReq.Caption = "Classe: " & sString
    Quest(EditorIndex).ReqClasse = scrlClassReq.Value
End Sub

Private Sub scrlElemento_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlElemento.Value = 0 Then
        sString = "-Elemento-"
    Else
        Select Case scrlElemento.Value
            
            Case 1
                sString = "Fogo"
            Case 2
                sString = "Vento"
            Case 3
                sString = "Água"
            Case 4
                sString = "Terra"
            Case 5
                sString = "Raio"
                Case Else
                Exit Sub
        End Select
    End If
    lblElemento.Caption = sString
    Quest(EditorIndex).rElemento = scrlElemento.Value
End Sub

Private Sub scrlItem1_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlItem1.Value = 0 Then
        sString = "Nenhum"
    Else
        sString = scrlItem1.Value & ":" & Item(scrlItem1.Value).Name
    End If
    lblItem.Caption = "Item: " & sString
    Quest(EditorIndex).Item(1) = scrlItem1.Value
End Sub



Private Sub scrlItem2_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlItem2.Value = 0 Then
        sString = "Nenhum"
    Else
        sString = scrlItem2.Value & ":" & Item(scrlItem2.Value).Name
    End If
    lblItem2.Caption = "Item: " & sString
    Quest(EditorIndex).Item(2) = scrlItem2.Value
End Sub

Private Sub scrlItem2Qnt_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlItem2Qnt.Value = 0 Then
        sString = "0"
    Else
        sString = scrlItem2Qnt.Value
    End If
    lblItem2Qnt.Caption = "Qnt: " & sString
    Quest(EditorIndex).ItemQnt(2) = scrlItem2Qnt.Value
End Sub

Private Sub scrlItem3_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlItem3.Value = 0 Then
        sString = "Nenhum"
    Else
        sString = scrlItem3.Value & ":" & Item(scrlItem3.Value).Name
    End If
    lblItem3.Caption = "Item: " & sString
    Quest(EditorIndex).Item(3) = scrlItem3.Value
End Sub

Private Sub scrlItem3Qnt_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlItem3Qnt.Value = 0 Then
        sString = "0"
    Else
        sString = scrlItem3Qnt.Value
    End If
    lblItem3Qnt.Caption = "Qnt: " & sString
    Quest(EditorIndex).ItemQnt(3) = scrlItem3Qnt.Value
End Sub

Private Sub scrlItem4_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlItem4.Value = 0 Then
        sString = "Nenhum"
    Else
        sString = scrlItem4.Value & ":" & Item(scrlItem4.Value).Name
    End If
    lblItem4.Caption = "Item: " & sString
    Quest(EditorIndex).Item(4) = scrlItem4.Value
End Sub

Private Sub scrlItem4Qnt_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlItem4Qnt.Value = 0 Then
        sString = "0"
    Else
        sString = scrlItem4Qnt.Value
    End If
    lblItem4Qnt.Caption = "Qnt: " & sString
    Quest(EditorIndex).ItemQnt(4) = scrlItem4Qnt.Value
End Sub

Private Sub scrlItem5_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlItem5.Value = 0 Then
        sString = "Nenhum"
    Else
        sString = scrlItem5.Value & ":" & Item(scrlItem5.Value).Name
    End If
    lblItem5.Caption = "Item: " & sString
    Quest(EditorIndex).Item(5) = scrlItem5.Value
End Sub

Private Sub scrlItem5Qnt_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlItem5Qnt.Value = 0 Then
        sString = "0"
    Else
        sString = scrlItem5Qnt.Value
    End If
    lblItem5Qnt.Caption = "Qnt: " & sString
    Quest(EditorIndex).ItemQnt(5) = scrlItem5Qnt.Value
End Sub

Private Sub scrlItem1Qnt_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlItem1Qnt.Value = 0 Then
        sString = "0"
    Else
        sString = scrlItem1Qnt.Value
    End If
    lblItemQnt.Caption = "Qnt: " & sString
    Quest(EditorIndex).ItemQnt(1) = scrlItem1Qnt.Value
End Sub

Private Sub scrlKillPlayerClass_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlKillPlayerClass.Value = 0 Then
        sString = "Nenhuma"
    Else
        sString = Class(scrlKillPlayerClass.Value).Name
    End If
    lblKillPlayerClass.Caption = "KillPlayer Class: " & sString
    Quest(EditorIndex).KillPlayerClass = scrlKillPlayerClass.Value
End Sub

Private Sub scrlKillPlayerQnt_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlKillPlayerQnt.Value = 0 Then
        sString = "Nenhum"
    Else
        sString = scrlKillPlayerQnt.Value
    End If
    lblKillPlayerQnt.Caption = "KillPlayerQnt: " & sString
    Quest(EditorIndex).KillPlayerQnt = scrlKillPlayerQnt.Value
End Sub

Private Sub scrlMAP_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlMAP.Value = 0 Then
        sString = "Nenhum"
    Else
        sString = scrlMAP.Value
    End If
    lblMAP.Caption = "Mapa: " & sString
    Quest(EditorIndex).MAP = scrlMAP.Value
End Sub

Private Sub scrlNeedLvl_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlNeedLvl.Value = 0 Then
        sString = "Nenhum"
    Else
        sString = scrlNeedLvl.Value
    End If
    lblNeedLvl.Caption = "Level: " & sString
    Quest(EditorIndex).NeedLevel = scrlNeedLvl.Value
End Sub

Private Sub scrlNpc1_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlNpc1.Value = 0 Then
        sString = "Nenhum"
    Else
        sString = Npc(scrlNpc1.Value).Name
    End If
    lblNpc.Caption = "NPC: " & sString
    Quest(EditorIndex).Npc(1) = scrlNpc1.Value
End Sub

Private Sub scrlNpc1Qnt_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlNpc1Qnt.Value = 0 Then
        sString = "0"
    Else
        sString = scrlNpc1Qnt.Value
    End If
    lblNpcQnt.Caption = "Qnt: " & sString
    Quest(EditorIndex).NpcQnt(1) = scrlNpc1Qnt.Value
End Sub

Private Sub scrlNpc2_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlNpc2.Value = 0 Then
        sString = "Nenhum"
    Else
        sString = Npc(scrlNpc2.Value).Name
    End If
    lblNpc2.Caption = "NPC: " & sString
    Quest(EditorIndex).Npc(2) = scrlNpc2.Value
End Sub

Private Sub scrlNpc2Qnt_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlNpc2Qnt.Value = 0 Then
        sString = "0"
    Else
        sString = scrlNpc2Qnt.Value
    End If
    lblNpc2Qnt.Caption = "Qnt: " & sString
    Quest(EditorIndex).NpcQnt(2) = scrlNpc2Qnt.Value
End Sub

Private Sub scrlNpc3_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlNpc3.Value = 0 Then
        sString = "Nenhum"
    Else
        sString = Npc(scrlNpc3.Value).Name
    End If
    lblNpc3.Caption = "NPC: " & sString
    Quest(EditorIndex).Npc(3) = scrlNpc3.Value
End Sub

Private Sub scrlNpc3Qnt_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlNpc3Qnt.Value = 0 Then
        sString = "0"
    Else
        sString = scrlNpc3Qnt.Value
    End If
    lblNpc3Qnt.Caption = "Qnt: " & sString
    Quest(EditorIndex).NpcQnt(3) = scrlNpc3Qnt.Value
End Sub

Private Sub scrlNpc4_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlNpc4.Value = 0 Then
        sString = "Nenhum"
    Else
        sString = Npc(scrlNpc4.Value).Name
    End If
    lblNpc4.Caption = "NPC: " & sString
    Quest(EditorIndex).Npc(4) = scrlNpc4.Value
End Sub

Private Sub scrlNpc4Qnt_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlNpc4Qnt.Value = 0 Then
        sString = "0"
    Else
        sString = scrlNpc4Qnt.Value
    End If
    lblNpc4Qnt.Caption = "Qnt: " & sString
    Quest(EditorIndex).NpcQnt(4) = scrlNpc4Qnt.Value
End Sub

Private Sub scrlNpc5_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlNpc5.Value = 0 Then
        sString = "Nenhum"
    Else
        sString = Npc(scrlNpc5.Value).Name
    End If
    lblNpc5.Caption = "NPC: " & sString
    Quest(EditorIndex).Npc(5) = scrlNpc5.Value
End Sub

Private Sub scrlNpc5Qnt_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlNpc5Qnt.Value = 0 Then
        sString = "0"
    Else
        sString = scrlNpc5Qnt.Value
    End If
    lblNpc5Qnt.Caption = "Qnt: " & sString
    Quest(EditorIndex).NpcQnt(5) = scrlNpc5Qnt.Value
End Sub

Private Sub scrlOrg_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlOrg.Value = 0 Then
        sString = "Nenhuma"
    Else
        Select Case scrlOrg.Value
            
            Case 1
                sString = "Konoha Police"
            Case 2
                sString = "Hospital"
            Case 3
                sString = "Akatsuki"
            Case 4
                sString = "Hebi"
            Case 5
                sString = "Núcleo"
                Case Else
                Exit Sub
        End Select
    End If
    lblOrg.Caption = "Org: " & sString
    Quest(EditorIndex).rOrg = scrlOrg.Value
End Sub

Private Sub scrlParty_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlParty.Value = 0 Then
        sString = "Nenhum"
    Else
        sString = scrlParty.Value
    End If
    lblParty.Caption = "PartyMembers: " & sString
    Quest(EditorIndex).ReqParty = scrlParty.Value
End Sub

Private Sub scrlRank_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlRank.Value = 0 Then
        sString = "Nenhum"
    Else
        Select Case scrlRank.Value
            Case 1
                sString = "Estudante"
            Case 2
                sString = "Genin"
            Case 3
                sString = "Chunin"
            Case 4
                sString = "Jounin"
                Case Else
                Exit Sub
        End Select
    End If
    lblRank.Caption = "Rank: " & sString
    Quest(EditorIndex).rRank = scrlRank.Value
End Sub

Private Sub scrlRclass_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlRclass.Value = 0 Then
        sString = "Nenhuma"
    Else
        sString = Class(scrlRclass.Value).Name
    End If
    lblRclass.Caption = "Classe: " & sString
    Quest(EditorIndex).rClasse = scrlRclass.Value
End Sub

Private Sub scrlRecItem1_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlRecItem1.Value = 0 Then
        sString = "Nenhum"
    Else
        sString = Item(scrlRecItem1.Value).Name
    End If
    lblRecItem.Caption = "Item: " & sString
    Quest(EditorIndex).rItem(1) = scrlRecItem1.Value
    
End Sub

Private Sub scrlRecItem2_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlRecItem2.Value = 0 Then
        sString = "Nenhum"
    Else
        sString = Item(scrlRecItem2.Value).Name
    End If
    lblRecItem2.Caption = "Item: " & sString
    Quest(EditorIndex).rItem(2) = scrlRecItem2.Value
End Sub

Private Sub scrlRecItem2Qnt_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlRecItem2Qnt.Value = 0 Then
        sString = "0"
    Else
        sString = scrlRecItem2Qnt.Value
    End If
    lblRecItem2Qnt.Caption = "Qnt: " & sString
    Quest(EditorIndex).rItemQnt(2) = scrlRecItem2Qnt.Value
End Sub

Private Sub scrlRecItem3_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlRecItem3.Value = 0 Then
        sString = "Nenhum"
    Else
        sString = Item(scrlRecItem3.Value).Name
    End If
    lblRecItem3.Caption = "Item: " & sString
    Quest(EditorIndex).rItem(3) = scrlRecItem3.Value
End Sub

Private Sub scrlRecItem3Qnt_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlRecItem3Qnt.Value = 0 Then
        sString = "0"
    Else
        sString = scrlRecItem3Qnt.Value
    End If
    lblRecItem3Qnt.Caption = "Qnt: " & sString
    Quest(EditorIndex).rItemQnt(3) = scrlRecItem3Qnt.Value
End Sub

Private Sub scrlRecItem4_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlRecItem4.Value = 0 Then
        sString = "Nenhum"
    Else
        sString = Item(scrlRecItem4.Value).Name
    End If
    lblRecItem4.Caption = "Item: " & sString
    Quest(EditorIndex).rItem(4) = scrlRecItem4.Value
End Sub

Private Sub scrlRecItem4Qnt_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlRecItem4Qnt.Value = 0 Then
        sString = "0"
    Else
        sString = scrlRecItem4Qnt.Value
    End If
    lblRecItem4Qnt.Caption = "Qnt: " & sString
    Quest(EditorIndex).rItemQnt(4) = scrlRecItem4Qnt.Value
End Sub

Private Sub scrlRecItem5_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlRecItem5.Value = 0 Then
        sString = "Nenhum"
    Else
        sString = Item(scrlRecItem5.Value).Name
    End If
    lblRecItem5.Caption = "Item: " & sString
    Quest(EditorIndex).rItem(5) = scrlRecItem5.Value
End Sub

Private Sub scrlRecItem5Qnt_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlRecItem5Qnt.Value = 0 Then
        sString = "0"
    Else
        sString = scrlRecItem5Qnt.Value
    End If
    lblRecItem5Qnt.Caption = "Qnt: " & sString
    Quest(EditorIndex).rItemQnt(5) = scrlRecItem5Qnt.Value
End Sub

Private Sub scrlRecItem1Qnt_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlRecItem1Qnt.Value = 0 Then
        sString = "0"
    Else
        sString = scrlRecItem1Qnt.Value
    End If
    lblRecItemQnt.Caption = "Qnt: " & sString
    Quest(EditorIndex).rItemQnt(1) = scrlRecItem1Qnt.Value
End Sub

Private Sub scrlReqElemento_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlReqElemento.Value = 0 Then
        sString = "Nenhum"
    Else
        Select Case scrlReqElemento.Value
            
            Case 1
                sString = "Fogo"
            Case 2
                sString = "Vento"
            Case 3
                sString = "Água"
            Case 4
                sString = "Terra"
            Case 5
                sString = "Raio"
                Case Else
                Exit Sub
        End Select
    End If
    lblReqElemento.Caption = "Elemento: " & sString
    Quest(EditorIndex).ReqElemento = scrlReqElemento.Value
End Sub

Private Sub scrlReqVila_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlReqVila.Value = 0 Then
        sString = "Nenhuma"
    Else
        Select Case scrlReqVila.Value
            
            Case 1
                sString = "Folha"
            Case 2
                sString = "Areia"
            Case 3
                sString = "Água"
            Case 4
                sString = "Terra"

                Case Else
                Exit Sub
        End Select
    End If
    lblReqVila.Caption = "Vila: " & sString
    Quest(EditorIndex).ReqVila = scrlReqVila.Value
End Sub

Private Sub scrlRscript_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlRscript.Value = 0 Then
        sString = "Nenhum"
    Else
        sString = scrlRscript.Value
    End If
    lblRscript.Caption = "EndScript: " & sString
    Quest(EditorIndex).rEndScript = scrlRscript.Value
End Sub

Private Sub scrlSpell_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlSpell.Value = 0 Then
        sString = "Nenhuma"
    Else
        sString = Spell(scrlSpell.Value).Name
    End If
    lblSpell.Caption = "Spell: " & sString
    Quest(EditorIndex).rSpell = scrlSpell.Value
End Sub

Private Sub scrlSprite_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlSprite.Value = 0 Then
        sString = "Nenhuma"
    Else
        sString = scrlSprite.Value
    End If
    lblSprite.Caption = "Sprite: " & sString
    Quest(EditorIndex).rSprite = scrlSprite.Value
End Sub

Private Sub scrlStartScript_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlStartScript.Value = 0 Then
        sString = "Nenhum"
    Else
        sString = scrlStartScript.Value
    End If
    lblStartScript.Caption = "StartScript: " & sString
    Quest(EditorIndex).StartScript = scrlStartScript.Value
End Sub

Private Sub scrlTipo_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
   Select Case scrlTipo.Value
   Case 0
     sString = "Nenhum"
     lblTipo.ForeColor = &H0&
   Case 1
     sString = "Item"
     lblTipo.ForeColor = &HC0C0&
   Case 2
     sString = "KillNpc"
     lblTipo.ForeColor = &H808080
   Case 3
     sString = "TalkTo"
     lblTipo.ForeColor = &HC000&
   Case 4
     sString = "Mapa"
     lblTipo.ForeColor = &H800080
   Case 5
     sString = "Level"
     lblTipo.ForeColor = &H808000
   Case 6
    sString = "KillPlayer"
    lblTipo.ForeColor = &HC0&
   
   Case 7
    sString = "UsarMagia"
    lblTipo.ForeColor = &HFFC0C0
   End Select
   
    lblTipo.Caption = "TipoDaQuest:" & sString
    Quest(EditorIndex).Tipo = scrlTipo.Value
End Sub

Private Sub scrlUsarSpell_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlUsarSpell.Value = 0 Then
        sString = "Nenhuma"
    Else
        sString = EditorIndex & ":" & Spell(scrlUsarSpell.Value).Name
    End If
    lblUsarSpell.Caption = "Spell: " & sString
    Quest(EditorIndex).UsarSpell = scrlUsarSpell.Value
End Sub

Private Sub scrlUsarSpellQnt_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlUsarSpellQnt.Value = 0 Then
        sString = "0"
    Else
        sString = scrlUsarSpellQnt.Value
    End If
    lblUsarSpellQnt.Caption = "Qnt: " & sString
    Quest(EditorIndex).UsarSpellQnt = scrlUsarSpellQnt.Value
End Sub

Private Sub scrlVIP_Change()
Dim sString As String
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    If scrlVIP.Value = 0 Then
        sString = "Não"
    Else
        sString = scrlVIP.Value
    End If
    lblVIP.Caption = "VIP: " & sString
    Quest(EditorIndex).ReqVIP = scrlVIP.Value
End Sub

Private Sub txtDesc_Change()
    If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub

    Quest(EditorIndex).Desc = txtDesc.Text
End Sub

Private Sub txtEXP_Change()
If Not Len(txtEXP.Text) > 0 Then Exit Sub
    If IsNumeric(txtEXP.Text) Then Quest(EditorIndex).rEXP = Val(txtEXP.Text)
    lblEXP.Caption = "EXP:" & txtEXP.Text

End Sub

Private Sub txtLvlReq_Change()
If Not Len(txtLvlReq.Text) > 0 Then Exit Sub
    If IsNumeric(txtLvlReq.Text) Then Quest(EditorIndex).ReqLevel = Val(txtLvlReq.Text)
      lblLvlReq.Caption = "Level:" & txtLvlReq.Text
      
End Sub

Private Sub txtMsg1_Change()
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub

    Quest(EditorIndex).Msg(1) = txtMsg1.Text
End Sub

Private Sub txtMsg2_Change()
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub

    Quest(EditorIndex).Msg(2) = txtMsg2.Text
End Sub

Private Sub txtMsg3_Change()
If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub

    Quest(EditorIndex).Msg(3) = txtMsg3.Text
End Sub

Private Sub txtName_Validate(Cancel As Boolean)
Dim tmpIndex As Long

    If EditorIndex = 0 Or EditorIndex > MAX_QUESTS Then Exit Sub
    tmpIndex = lstIndex.ListIndex
    Quest(EditorIndex).Name = Trim$(txtName.Text)
    lstIndex.RemoveItem EditorIndex - 1
    lstIndex.AddItem EditorIndex & ": " & Quest(EditorIndex).Name, EditorIndex - 1
    lstIndex.ListIndex = tmpIndex
End Sub
