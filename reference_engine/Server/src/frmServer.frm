VERSION 5.00
Object = "{248DD890-BB45-11CF-9ABC-0080C7E7B78D}#1.0#0"; "Mswinsck.ocx"
Object = "{BDC217C8-ED16-11CD-956C-0000C04E4C0A}#1.1#0"; "Tabctl32.ocx"
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.2#0"; "MSCOMCTL.OCX"
Begin VB.Form frmServer 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Loading..."
   ClientHeight    =   6945
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   8130
   BeginProperty Font 
      Name            =   "Verdana"
      Size            =   8.25
      Charset         =   0
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   Icon            =   "frmServer.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   ScaleHeight     =   6945
   ScaleWidth      =   8130
   StartUpPosition =   2  'CenterScreen
   Begin MSWinsockLib.Winsock Socket 
      Index           =   0
      Left            =   0
      Top             =   0
      _ExtentX        =   741
      _ExtentY        =   741
      _Version        =   393216
   End
   Begin TabDlg.SSTab SSTab1 
      Height          =   6735
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   7935
      _ExtentX        =   13996
      _ExtentY        =   11880
      _Version        =   393216
      Style           =   1
      TabHeight       =   503
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      TabCaption(0)   =   "Console"
      TabPicture(0)   =   "frmServer.frx":1708A
      Tab(0).ControlEnabled=   -1  'True
      Tab(0).Control(0)=   "lblCPS"
      Tab(0).Control(0).Enabled=   0   'False
      Tab(0).Control(1)=   "lblCpsLock"
      Tab(0).Control(1).Enabled=   0   'False
      Tab(0).Control(2)=   "txtText"
      Tab(0).Control(2).Enabled=   0   'False
      Tab(0).Control(3)=   "txtChat"
      Tab(0).Control(3).Enabled=   0   'False
      Tab(0).ControlCount=   4
      TabCaption(1)   =   "Players"
      TabPicture(1)   =   "frmServer.frx":170A6
      Tab(1).ControlEnabled=   0   'False
      Tab(1).Control(0)=   "lvwInfo"
      Tab(1).Control(0).Enabled=   0   'False
      Tab(1).ControlCount=   1
      TabCaption(2)   =   "Control "
      TabPicture(2)   =   "frmServer.frx":170C2
      Tab(2).ControlEnabled=   0   'False
      Tab(2).Control(0)=   "chkLiberaBan"
      Tab(2).Control(0).Enabled=   0   'False
      Tab(2).Control(1)=   "chkNoShutdown"
      Tab(2).Control(1).Enabled=   0   'False
      Tab(2).Control(2)=   "fraSemanal"
      Tab(2).Control(2).Enabled=   0   'False
      Tab(2).Control(3)=   "chkGiveCash"
      Tab(2).Control(3).Enabled=   0   'False
      Tab(2).Control(4)=   "chkOnlyGM"
      Tab(2).Control(4).Enabled=   0   'False
      Tab(2).Control(5)=   "fraLutas"
      Tab(2).Control(5).Enabled=   0   'False
      Tab(2).Control(6)=   "chkOmitir"
      Tab(2).Control(6).Enabled=   0   'False
      Tab(2).Control(7)=   "fraEventTimer"
      Tab(2).Control(7).Enabled=   0   'False
      Tab(2).Control(8)=   "cmdSortearP"
      Tab(2).Control(8).Enabled=   0   'False
      Tab(2).Control(9)=   "cmdFinalizarGuerra"
      Tab(2).Control(9).Enabled=   0   'False
      Tab(2).Control(10)=   "cmdComeçarGuerra"
      Tab(2).Control(10).Enabled=   0   'False
      Tab(2).Control(11)=   "cmdLevelUP"
      Tab(2).Control(11).Enabled=   0   'False
      Tab(2).Control(12)=   "chkIpKill"
      Tab(2).Control(12).Enabled=   0   'False
      Tab(2).Control(13)=   "lstTorneios"
      Tab(2).Control(13).Enabled=   0   'False
      Tab(2).Control(14)=   "chkFogoAmigo"
      Tab(2).Control(14).Enabled=   0   'False
      Tab(2).Control(15)=   "chkTorneioStatus"
      Tab(2).Control(15).Enabled=   0   'False
      Tab(2).Control(16)=   "cmdAtuTops"
      Tab(2).Control(16).Enabled=   0   'False
      Tab(2).Control(17)=   "cmdNoticias"
      Tab(2).Control(17).Enabled=   0   'False
      Tab(2).Control(18)=   "Command3"
      Tab(2).Control(18).Enabled=   0   'False
      Tab(2).Control(19)=   "cmdAnunciarTorneio"
      Tab(2).Control(19).Enabled=   0   'False
      Tab(2).Control(20)=   "fraEvento"
      Tab(2).Control(20).Enabled=   0   'False
      Tab(2).Control(21)=   "fraEditores"
      Tab(2).Control(21).Enabled=   0   'False
      Tab(2).Control(22)=   "fraServer"
      Tab(2).Control(22).Enabled=   0   'False
      Tab(2).Control(23)=   "fraDatabase"
      Tab(2).Control(23).Enabled=   0   'False
      Tab(2).Control(24)=   "lblTorneio"
      Tab(2).Control(24).Enabled=   0   'False
      Tab(2).ControlCount=   25
      Begin VB.CheckBox chkLiberaBan 
         Caption         =   "Liberar Banidos?"
         Height          =   375
         Left            =   -69240
         TabIndex        =   54
         Top             =   5400
         Width           =   2055
      End
      Begin VB.CheckBox chkNoShutdown 
         Caption         =   "NO SHUTDOWN!"
         Height          =   375
         Left            =   -73680
         TabIndex        =   53
         Top             =   6240
         Value           =   1  'Checked
         Width           =   2295
      End
      Begin VB.Frame fraSemanal 
         Caption         =   "Evento Semanal"
         Height          =   855
         Left            =   -71280
         TabIndex        =   49
         Top             =   5760
         Width           =   3495
         Begin VB.CommandButton cmdGanhador 
            Caption         =   "Achar Ganhador"
            Height          =   375
            Left            =   2400
            TabIndex        =   52
            Top             =   480
            Width           =   975
         End
         Begin VB.HScrollBar scrlSemanal 
            Height          =   255
            Left            =   120
            Max             =   1000
            TabIndex        =   51
            Top             =   480
            Width           =   1695
         End
         Begin VB.Label lblSemanal 
            Caption         =   "Item:Nenhum"
            Height          =   255
            Left            =   120
            TabIndex        =   50
            Top             =   240
            Width           =   3135
         End
      End
      Begin VB.CheckBox chkGiveCash 
         Caption         =   "DarCash?"
         Height          =   375
         Left            =   -74880
         TabIndex        =   48
         Top             =   3360
         Value           =   1  'Checked
         Width           =   1215
      End
      Begin VB.CheckBox chkOnlyGM 
         Caption         =   "Apenas GM?"
         Height          =   255
         Left            =   -69240
         TabIndex        =   47
         Top             =   5040
         Width           =   1935
      End
      Begin VB.Frame fraLutas 
         Caption         =   "Lutas-Torneio"
         Height          =   855
         Left            =   -71280
         TabIndex        =   44
         Top             =   4800
         Width           =   1455
         Begin VB.HScrollBar scrlFightLevel 
            Height          =   255
            Left            =   120
            Max             =   3
            Min             =   1
            TabIndex        =   45
            Top             =   480
            Value           =   1
            Width           =   1215
         End
         Begin VB.Label lblFightLevel 
            Caption         =   "Nivel:1"
            Height          =   255
            Left            =   240
            TabIndex        =   46
            Top             =   240
            Width           =   1095
         End
      End
      Begin VB.CheckBox chkOmitir 
         Caption         =   "Omitir Graduações"
         Height          =   315
         Left            =   -69240
         TabIndex        =   43
         Top             =   4560
         Width           =   1935
      End
      Begin VB.Frame fraEventTimer 
         Caption         =   "Acabar evento as"
         Height          =   1095
         Left            =   -74640
         TabIndex        =   39
         Top             =   5040
         Width           =   2295
         Begin VB.CheckBox chkEventActive 
            Caption         =   "Ativado"
            Height          =   255
            Left            =   1200
            TabIndex        =   42
            Top             =   480
            Width           =   975
         End
         Begin VB.TextBox txtEventHour 
            Height          =   375
            Left            =   120
            TabIndex        =   40
            Text            =   "0"
            Top             =   600
            Width           =   735
         End
         Begin VB.Label lblBlank 
            Caption         =   "Hora"
            Height          =   255
            Left            =   240
            TabIndex        =   41
            Top             =   240
            Width           =   495
         End
      End
      Begin VB.CommandButton cmdSortearP 
         Caption         =   "Sortear Player"
         Height          =   375
         Left            =   -73680
         TabIndex        =   38
         Top             =   3360
         Width           =   1335
      End
      Begin VB.CommandButton cmdFinalizarGuerra 
         BackColor       =   &H0080FF80&
         Caption         =   "Finalizar Guerra"
         Height          =   375
         Left            =   -69240
         MaskColor       =   &H0080FF80&
         Style           =   1  'Graphical
         TabIndex        =   37
         Top             =   3840
         Width           =   1575
      End
      Begin VB.CommandButton cmdComeçarGuerra 
         BackColor       =   &H008080FF&
         Caption         =   "Começar Guerra"
         Height          =   375
         Left            =   -69240
         Style           =   1  'Graphical
         TabIndex        =   36
         Top             =   3360
         Width           =   1575
      End
      Begin VB.CommandButton cmdLevelUP 
         Caption         =   "LevelUP"
         Height          =   375
         Left            =   -69960
         TabIndex        =   35
         Top             =   360
         Width           =   1215
      End
      Begin VB.CheckBox chkIpKill 
         Caption         =   "IP Kill"
         Height          =   255
         Left            =   -69480
         TabIndex        =   34
         Top             =   3000
         Width           =   1095
      End
      Begin VB.ListBox lstTorneios 
         Height          =   2985
         ItemData        =   "frmServer.frx":170DE
         Left            =   -71640
         List            =   "frmServer.frx":1710F
         TabIndex        =   33
         Top             =   1680
         Width           =   2175
      End
      Begin VB.CheckBox chkFogoAmigo 
         Caption         =   "Fogo Amigo: Desativado"
         Height          =   255
         Left            =   -69480
         TabIndex        =   31
         Top             =   2640
         Width           =   2535
      End
      Begin VB.CheckBox chkTorneioStatus 
         Caption         =   "Torneio Desativado"
         Height          =   255
         Left            =   -69480
         TabIndex        =   30
         Top             =   2280
         Width           =   2055
      End
      Begin VB.CommandButton cmdAtuTops 
         Caption         =   "Atualizar Tops"
         Height          =   255
         Left            =   -68640
         TabIndex        =   29
         Top             =   1800
         Width           =   1335
      End
      Begin VB.CommandButton cmdNoticias 
         Caption         =   "Atualizar Noticias"
         Height          =   375
         Left            =   -68640
         TabIndex        =   28
         Top             =   1320
         Width           =   1455
      End
      Begin VB.CommandButton Command3 
         Caption         =   "Checar VIP/CT"
         Height          =   255
         Left            =   -68640
         TabIndex        =   27
         Top             =   960
         Width           =   1455
      End
      Begin VB.CommandButton cmdAnunciarTorneio 
         BackColor       =   &H00C0FFC0&
         Caption         =   "Avisar Torneio"
         Height          =   255
         Left            =   -70920
         MaskColor       =   &H00FFFFC0&
         Style           =   1  'Graphical
         TabIndex        =   25
         Top             =   1440
         Width           =   1455
      End
      Begin VB.Frame fraEvento 
         Caption         =   "Evento EXP"
         Height          =   735
         Left            =   -74520
         TabIndex        =   21
         Top             =   3840
         Width           =   2175
         Begin VB.TextBox txtEventoEXP 
            BeginProperty Font 
               Name            =   "Comic Sans MS"
               Size            =   12
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Height          =   375
            Left            =   120
            TabIndex        =   23
            Text            =   "1"
            Top             =   240
            Width           =   1095
         End
         Begin VB.CommandButton Command2 
            Caption         =   "Anunciar"
            Height          =   375
            Left            =   1200
            TabIndex        =   22
            Top             =   240
            Width           =   975
         End
      End
      Begin VB.Frame fraEditores 
         Caption         =   "Editores"
         Height          =   735
         Left            =   -68520
         TabIndex        =   19
         Top             =   120
         Width           =   1335
         Begin VB.CommandButton Command1 
            Caption         =   "Quest"
            Height          =   255
            Left            =   120
            TabIndex        =   20
            Top             =   360
            Width           =   1095
         End
      End
      Begin VB.Frame fraServer 
         Caption         =   "Server"
         Height          =   1215
         Left            =   -72000
         TabIndex        =   1
         Top             =   0
         Width           =   1815
         Begin VB.CheckBox chkServerLog 
            Caption         =   "Server Log"
            Height          =   255
            Left            =   120
            TabIndex        =   7
            Top             =   1200
            Width           =   1575
         End
         Begin VB.CommandButton cmdExit 
            Caption         =   "Exit"
            Height          =   375
            Left            =   120
            TabIndex        =   6
            Top             =   720
            Width           =   1575
         End
         Begin VB.CommandButton cmdShutDown 
            Caption         =   "Shut Down"
            Height          =   375
            Left            =   120
            TabIndex        =   5
            Top             =   240
            Width           =   1575
         End
      End
      Begin VB.Frame fraDatabase 
         Caption         =   "Reload"
         Height          =   2775
         Left            =   -74880
         TabIndex        =   8
         Top             =   360
         Width           =   2895
         Begin VB.CheckBox chkMuteAll 
            Caption         =   "MuteAll"
            Height          =   255
            Left            =   1440
            TabIndex        =   32
            Top             =   2040
            Width           =   1335
         End
         Begin VB.CheckBox chkShutGlobal 
            Caption         =   "MuteGlobal"
            Height          =   255
            Left            =   1440
            TabIndex        =   26
            Top             =   1680
            Width           =   1335
         End
         Begin VB.CommandButton cmdReloadAnimations 
            Caption         =   "Animations"
            Height          =   375
            Left            =   1440
            TabIndex        =   16
            Top             =   1200
            Width           =   1215
         End
         Begin VB.CommandButton cmdReloadResources 
            Caption         =   "Resources"
            Height          =   375
            Left            =   1440
            TabIndex        =   15
            Top             =   720
            Width           =   1215
         End
         Begin VB.CommandButton cmdReloadItems 
            Caption         =   "Items"
            Height          =   375
            Left            =   1440
            TabIndex        =   14
            Top             =   240
            Width           =   1215
         End
         Begin VB.CommandButton cmdReloadNPCs 
            Caption         =   "Npcs"
            Height          =   375
            Left            =   120
            TabIndex        =   13
            Top             =   2160
            Width           =   1215
         End
         Begin VB.CommandButton cmdReloadShops 
            Caption         =   "Shops"
            Height          =   375
            Left            =   120
            TabIndex        =   12
            Top             =   1680
            Width           =   1215
         End
         Begin VB.CommandButton CmdReloadSpells 
            Caption         =   "Spells"
            Height          =   375
            Left            =   120
            TabIndex        =   11
            Top             =   1200
            Width           =   1215
         End
         Begin VB.CommandButton cmdReloadMaps 
            Caption         =   "Maps"
            Height          =   375
            Left            =   120
            TabIndex        =   10
            Top             =   720
            Width           =   1215
         End
         Begin VB.CommandButton cmdReloadClasses 
            Caption         =   "Classes"
            Height          =   375
            Left            =   120
            TabIndex        =   9
            Top             =   240
            Width           =   1215
         End
      End
      Begin VB.TextBox txtChat 
         Height          =   375
         Left            =   720
         TabIndex        =   3
         Top             =   6240
         Width           =   6255
      End
      Begin VB.TextBox txtText 
         Height          =   5535
         Left            =   120
         MultiLine       =   -1  'True
         ScrollBars      =   2  'Vertical
         TabIndex        =   2
         Top             =   600
         Width           =   7575
      End
      Begin MSComctlLib.ListView lvwInfo 
         Height          =   6135
         Left            =   -74880
         TabIndex        =   4
         Top             =   480
         Width           =   7575
         _ExtentX        =   13361
         _ExtentY        =   10821
         View            =   3
         Arrange         =   1
         LabelWrap       =   -1  'True
         HideSelection   =   0   'False
         AllowReorder    =   -1  'True
         FullRowSelect   =   -1  'True
         GridLines       =   -1  'True
         _Version        =   393217
         ForeColor       =   -2147483640
         BackColor       =   -2147483643
         BorderStyle     =   1
         Appearance      =   1
         BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         NumItems        =   4
         BeginProperty ColumnHeader(1) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
            Text            =   "Index"
            Object.Width           =   1147
         EndProperty
         BeginProperty ColumnHeader(2) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
            SubItemIndex    =   1
            Text            =   "IP Address"
            Object.Width           =   3175
         EndProperty
         BeginProperty ColumnHeader(3) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
            SubItemIndex    =   2
            Text            =   "Account"
            Object.Width           =   3175
         EndProperty
         BeginProperty ColumnHeader(4) {BDD1F052-858B-11D1-B16A-00C0F0283628} 
            SubItemIndex    =   3
            Text            =   "Character"
            Object.Width           =   2999
         EndProperty
      End
      Begin VB.Label lblTorneio 
         Caption         =   "Torneios;"
         Height          =   255
         Left            =   -71880
         TabIndex        =   24
         Top             =   1200
         Width           =   2415
      End
      Begin VB.Label lblCpsLock 
         Alignment       =   2  'Center
         AutoSize        =   -1  'True
         Caption         =   "[Unlock]"
         ForeColor       =   &H00FF0000&
         Height          =   195
         Left            =   120
         TabIndex        =   18
         Top             =   360
         Width           =   720
      End
      Begin VB.Label lblCPS 
         Caption         =   "CPS: 0"
         Height          =   255
         Left            =   960
         TabIndex        =   17
         Top             =   360
         Width           =   1815
      End
   End
   Begin VB.Menu mnuKick 
      Caption         =   "&Kick"
      Visible         =   0   'False
      Begin VB.Menu mnuKickPlayer 
         Caption         =   "Kick"
      End
      Begin VB.Menu mnuDisconnectPlayer 
         Caption         =   "Disconnect"
      End
      Begin VB.Menu mnuBanPlayer 
         Caption         =   "Ban"
      End
      Begin VB.Menu mnuAdminPlayer 
         Caption         =   "Make Admin"
      End
      Begin VB.Menu mnuRemoveAdmin 
         Caption         =   "Remove Admin"
      End
      Begin VB.Menu mnuVIP 
         Caption         =   "VIP"
         Begin VB.Menu mnuVip1 
            Caption         =   "Vip1"
         End
         Begin VB.Menu mnuVip2 
            Caption         =   "Vip2"
         End
         Begin VB.Menu mnuVip3 
            Caption         =   "Vip3"
         End
         Begin VB.Menu mnuTirarVIP 
            Caption         =   "Tirar VIP"
         End
      End
      Begin VB.Menu mnuRank 
         Caption         =   "Rank"
         Begin VB.Menu mnuRankDesertor 
            Caption         =   "Desertor"
         End
         Begin VB.Menu mnuRankEstudante 
            Caption         =   "Estudante"
         End
         Begin VB.Menu mnuRankGenin 
            Caption         =   "Genin"
         End
         Begin VB.Menu mnuRankChunin 
            Caption         =   "Chunin"
         End
         Begin VB.Menu mnuRankJounin 
            Caption         =   "Jounin"
         End
         Begin VB.Menu mnuRankAnbu 
            Caption         =   "ANBU"
         End
         Begin VB.Menu mnuRankSannin 
            Caption         =   "Sannin"
         End
         Begin VB.Menu mnuRankKage 
            Caption         =   "Kage"
         End
      End
      Begin VB.Menu mnuOrg 
         Caption         =   "Organização"
         Begin VB.Menu mnuOrgPoliciaKonoha 
            Caption         =   "Policia Konoha"
         End
         Begin VB.Menu mnuOrgHospital 
            Caption         =   "Hospital"
         End
         Begin VB.Menu mnuOrgAkatsuki 
            Caption         =   "Akatsuki"
         End
         Begin VB.Menu mnuOrgTaka 
            Caption         =   "Taka"
         End
         Begin VB.Menu mnuOrg7Espadachins 
            Caption         =   "7 Espadachins da Névoa"
         End
         Begin VB.Menu mnuOrg12Guardioes 
            Caption         =   "12 Guardiões Senhor Feudal"
         End
         Begin VB.Menu mnuOrgANBU 
            Caption         =   "ANBU"
         End
         Begin VB.Menu mnuOrgANBUraiz 
            Caption         =   "ANBU Raíz"
         End
         Begin VB.Menu mnuTirarOrg 
            Caption         =   "Tirar Org"
         End
         Begin VB.Menu mnuOrgUnderworld 
            Caption         =   "UnderWorld(CUSTOM)"
         End
      End
      Begin VB.Menu mnuMute 
         Caption         =   "Mutar?"
         Begin VB.Menu mnuMuteYes 
            Caption         =   "Sim"
         End
         Begin VB.Menu mnuMuteNo 
            Caption         =   "Não"
         End
      End
      Begin VB.Menu mnuBanOptions 
         Caption         =   "Ban"
         Begin VB.Menu mnuDesban 
            Caption         =   "Desbanir"
         End
         Begin VB.Menu mnuBan 
            Caption         =   "Banir pra Sempre"
         End
      End
   End
End
Attribute VB_Name = "frmServer"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub chkFogoAmigo_Click()
If chkFogoAmigo.Value = YES Then
    chkFogoAmigo.Caption = "Fogo Amigo: Ativado"
Else
    chkFogoAmigo.Caption = "Fogo Amigo: Desativado"
End If

End Sub

Private Sub chkMuteAll_Click()

If chkMuteAll.Value = YES Then
    chkShutGlobal.Value = YES
    ShutAll = YES
Else
    ShutAll = NO
End If

End Sub

Private Sub chkShutGlobal_Click()


If chkShutGlobal.Value = YES Then
    ShutGlobal = YES
Else
    ShutGlobal = NO
    chkMuteAll.Value = NO
End If

End Sub

Private Sub chkTorneioStatus_Click()
If chkTorneioStatus.Value = 0 Then
    chkTorneioStatus.Caption = "Torneio Desativado"
    TorneioAtivo = NO
Else
    chkTorneioStatus.Caption = "Torneio ATIVADO"
    TorneioAtivo = YES
End If

End Sub

Private Sub cmdAnunciarTorneio_Click()
If chkTorneioStatus.Value = NO Then
    MsgBox "Marque pra ativar o torneio"
    Exit Sub
End If

Dim i As Long
Dim texto As String
Select Case lstTorneios.ListIndex
    Case NO 'Nenhum
        MsgBox "Nenhum torneio.."
        Exit Sub
    Case TORNEIO_CS 'Chunin Shiken
        texto = "Chunin Shiken"
    Case TORNEIO_POKEMON 'temos que pegar
        texto = "Temos que pegar"
    Case TORNEIO_DESAFIOS '6 desafios
        texto = "Desafios"
    Case TORNEIO_SEMANAL 'Semanal
        texto = "Semanal"
    Case TORNEIO_KAGE_KONOHA 'Kage Konoha
        texto = "Hokage"
        
        For i = 1 To Player_HighIndex
            If GetPlayerLogin(i) = GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(1)) Then
                If Player(i).Vila = 1 Then
                    PlayerWarp i, 98, 7, 7
                    MapMsg 98, GetPlayerName(i) & " foi puxado.", Yellow
                Else
                    MapMsg 98, GetPlayerName(i) & " desistiu.", Yellow
                End If
                Exit For
            End If
            If i = Player_HighIndex Then MapMsg 98, "Parece que ele ta off....", White
        Next
    Case TORNEIO_KAGE_SUNA 'Kage Suna
        texto = "Kazekage"
        
        For i = 1 To Player_HighIndex
            If GetPlayerLogin(i) = GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(2)) Then
                If Player(i).Vila = 2 Then
                    PlayerWarp i, 98, 7, 7
                    MapMsg 98, GetPlayerName(i) & " foi puxado.", Yellow
                Else
                    MapMsg 98, GetPlayerName(i) & " desistiu.", Yellow
                End If
                Exit For
            End If
            If i = Player_HighIndex Then MapMsg 98, "Parece que ele ta off....", White
        Next
    Case TORNEIO_KAGE_KIRI 'Kage Kiri
        texto = "Mizukage"
        
        For i = 1 To Player_HighIndex
            If GetPlayerLogin(i) = GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(3)) Then
                If Player(i).Vila = 3 Then
                    PlayerWarp i, 98, 7, 7
                    MapMsg 98, GetPlayerName(i) & " foi puxado.", Yellow
                Else
                    MapMsg 98, GetPlayerName(i) & " desistiu.", Yellow
                End If
                Exit For
            End If
            If i = Player_HighIndex Then MapMsg 98, "Parece que ele ta off....", White
        Next
    Case TORNEIO_KAGE_IWA 'Kage Iwa
        texto = "Tsuchikage"
        
        For i = 1 To Player_HighIndex
            If GetPlayerLogin(i) = GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(4)) Then
                If Player(i).Vila = 4 Then
                    PlayerWarp i, 98, 7, 7
                    MapMsg 98, GetPlayerName(i) & " foi puxado.", Yellow
                Else
                    MapMsg 98, GetPlayerName(i) & " desistiu.", Yellow
                End If
                Exit For
            End If
            If i = Player_HighIndex Then MapMsg 98, "Parece que ele ta off....", White
        Next
    Case TORNEIO_KAGE_KUMO 'Kage Kumo
        texto = "Raikage"
        
        For i = 1 To Player_HighIndex
            If GetPlayerLogin(i) = GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(5)) Then
                If Player(i).Vila = 5 Then
                    PlayerWarp i, 98, 7, 7
                    MapMsg 98, GetPlayerName(i) & " foi puxado.", Yellow
                Else
                    MapMsg 98, GetPlayerName(i) & " desistiu.", Yellow
                End If
                Exit For
            End If
            If i = Player_HighIndex Then MapMsg 98, "Parece que ele ta off....", White
        Next
    Case TORNEIO_KAGE_CHUVA 'Lider Chuva
        texto = "Líder da Chuva"
        
        For i = 1 To Player_HighIndex
            If GetPlayerLogin(i) = GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(0)) Then
                If Player(i).Vila = 0 Then
                    PlayerWarp i, 98, 7, 7
                    MapMsg 98, GetPlayerName(i) & " foi puxado.", Yellow
                Else
                    MapMsg 98, GetPlayerName(i) & " desistiu.", Yellow
                End If
                Exit For
            End If
            
            If i = Player_HighIndex Then MapMsg 98, "Parece que ele ta off....", White
        Next
    Case TORNEIO_LENDARIO '
        texto = "Lendário"
    Case TORNEIO_LUTA 'Torneio
        Select Case frmServer.scrlFightLevel.Value
            Case 1 'até 300
                texto = "Luta level 1(lvl até 300)"
            Case 2 '301 e 500
                texto = "Luta level 2(lvl 301 até 500)"
            Case 3 '501 pra cima
                texto = "Luta level 3(a partir do level 501)"
        End Select
    Case TORNEIO_KAGE_SOM 'Invasão
        texto = "Líder do Som"
        
        For i = 1 To Player_HighIndex
            If GetPlayerLogin(i) = GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(6)) Then
                If Player(i).Vila = 6 Then 'som
                    PlayerWarp i, 98, 7, 7
                    MapMsg 98, GetPlayerName(i) & " foi puxado.", Yellow
                Else
                    MapMsg 98, GetPlayerName(i) & " desistiu.", Yellow
                End If
                Exit For
            End If
            
            If i = Player_HighIndex Then MapMsg 98, "Parece que ele ta off....", White
        Next
        
    Case TORNEIO_GUERRA 'Guera
        texto = "Guerra Shinobi"
    Case Else
End Select

GlobalMsg "Torneio " & texto & " ativo !Boa sorte!!", BrightCyan
GlobalMsg "Para participar,digite no MAPA : /torneio.", BrightCyan
GlobalMsg "Vá em 'CONFIG' e bote o 'AutoTile' em 'OFF' para evitar erros.", BrightCyan
End Sub

Private Sub cmdAtuTops_Click()
AtualizarTops
'GlobalMsg "Top's atualizados", Yellow
TextAdd "Top atualizado pra todos"

End Sub

Private Sub cmdComeçarGuerra_Click()
Dim i As Long

If frmServer.chkTorneioStatus.Value = NO Then
    MsgBox "Torneio não ta ativado!", vbOKOnly
    Exit Sub
End If

Select Case Torneio
    Case TORNEIO_GUERRA

        For i = 1 To Player_HighIndex
            If Player(i).War > 0 Then
                TempPlayer(i).Contagem = 6
                PlayerMsg i, "A GUERRA COMEÇOU,PREPARE-SE PARA A BATALHA!!", White
                
                If Player(i).War = 1 Then 'Bem
                    SetPlayerDir i, DIR_RIGHT
                    PlayerWarp i, 299, 2, RAND(2, 59)
                Else 'maledito
                    SetPlayerDir i, DIR_LEFT
                    PlayerWarp i, 299, 29, RAND(2, 59)
                End If
            End If
        Next
        
            frmServer.chkTorneioStatus.Value = NO
    
    Case TORNEIO_POKEMON 'temos que pegar,seleciona o echi e começa os briks
        If GetTotalMapPlayers(296) < 2 Then Exit Sub
        
        SortearEchi
        
        If PlayerEchi > 0 Then
            If IsPlaying(PlayerEchi) And GetPlayerMap(PlayerEchi) = 296 Then
                TempPlayer(PlayerEchi).Contagem = 6
                SendAnimation 296, 20, GetPlayerX(PlayerEchi), GetPlayerY(PlayerEchi)
                Player(PlayerEchi).PKstate = 2
                SendPlayerData PlayerEchi
            Else
                GlobalMsg "Player off ou não ta no mapa do evento", Grey
            End If
        Else
                GlobalMsg "Player off ou não ta no mapa do evento", BrightRed
        End If
        
        frmServer.chkTorneioStatus.Value = NO
    
    Case TORNEIO_DESAFIOS
        desafioNum = 0
        frmServer.chkTorneioStatus.Value = NO
        GlobalMsg "Começando o Torneio dos Desafios!", Yellow
        AtualizarEvento
        
    Case Else
        MsgBox "Nenhum torneio que necessite disso..", vbOKOnly
End Select

End Sub

Private Sub cmdFinalizarGuerra_Click()
Dim i As Long

If Torneio = NO Then
    MsgBox "Nenhum torneio ativado..", vbOKOnly
    Exit Sub
End If

Select Case Torneio
    Case TORNEIO_GUERRA
    
        If War.Pts(1) > War.Pts(2) Then 'Bem ganho
            GlobalMsg "ALIANÇA SHINOBI GANHOU(" & War.Pts(1) & " pts)!!", White
            If War.Killer(1) > 0 Then
                GlobalMsg "Destaque(AliançaShinobi):" & GetPlayerName(War.Killer(1)) & "(" & Player(War.Killer(1)).WarPoints & " pts)", BrightCyan
                GiveInvItem War.Killer(1), 254, 3000
                PlayerMsg War.Killer(1), "Bonus por ser destaque: 3K CASH!", Yellow
            End If
            
            For i = 1 To Player_HighIndex
                If Player(i).War = 1 Then 'bem
                    If Player(i).WarPoints >= 3 Then
                        GiveInvItem i, 254, 1000, True
                        PlayerMsg i, "Você ganhou 1k CASH por sua bravura na guerra Shinobi!", White
                    Else
                        PlayerMsg i, "Você não fez muita diferença na batalha,que decepção..", Red
                    End If
                    
                    PlayerWarp i, 297, 7, 7
                End If
            Next
        Else 'Mal ganho
            GlobalMsg "TSUKI NO ME GANHOU(" & War.Pts(2) & " pts)!!", BrightRed
            If War.Killer(2) > 0 Then
                GlobalMsg "Destaque(TsukiNoMe):" & GetPlayerName(War.Killer(2)) & "(" & Player(War.Killer(2)).WarPoints & " pts)", BrightCyan
                GiveInvItem War.Killer(2), 254, 3000
                PlayerMsg War.Killer(2), "Bonus por ser destaque: 3K CASH!", Yellow
            End If
            
            For i = 1 To Player_HighIndex
                If Player(i).War = 2 Then 'mal
                    If Player(i).WarPoints >= 3 Then
                        GiveInvItem i, 254, 1000, True
                        PlayerMsg i, "Você ganhou 1k CASH por sua bravura na guerra Shinobi!", White
                    Else
                        PlayerMsg i, "Você não fez muita diferença na batalha,que decepção..", Red
                    End If
                    
                    PlayerWarp i, 297, 7, 7
                End If
            Next
        End If
        
        For i = 1 To Player_HighIndex
            If Player(i).WarPoints > 0 Then
                PlayerMsg i, "Você fechou a guerra com a seguinte pontuação:" & Player(i).WarPoints, White
            End If
            
            Player(i).WarPoints = NO
        Next
        
        War.Killer(1) = NO
        War.Killer(2) = NO
        War.Pts(1) = NO
        War.Pts(2) = NO
        War.PlayerCount(1) = NO
        War.PlayerCount(2) = NO
    
    Case TORNEIO_POKEMON 'temos que pegar
        PlayerEchi = NO
        
        For i = 1 To Player_HighIndex
            If IsPlaying(i) Then
                If GetPlayerMap(i) = 296 Then 'temos que pegar
                    If Player(i).PKstate = 1 Then 'poquemão
                        GiveInvItem i, 254, 1000, True '1k cash
                        PlayerMsg i, "Você ganhou " & 1000 & " CASH por ser um poquemão raro!", Yellow
                        Player(i).InTorneio = NO
                        Player(i).PKstate = NO
                        PlayerWarp i, 99, 10, 6 'Atendimento
                    ElseIf Player(i).PKstate = 2 Then 'echí
                        PlayerMsg i, "Ótima caçada oh mestre treinador.", White
                        Player(i).InTorneio = NO
                        Player(i).PKstate = NO
                        PlayerWarp i, 99, 10, 6 'Atendimento
                    End If
                End If
            End If
        Next
    
    Case Else
        MsgBox "Nenhum torneio que necessite disso.."
End Select

Torneio = NO
frmServer.lstTorneios.ListIndex = 0
frmServer.chkTorneioStatus.Value = NO

End Sub

Private Sub cmdGanhador_Click()
Dim i As Long
Dim n As Byte

Dim LastValue As Long
Dim LastIndex As Long
Dim itemNome As String

If scrlSemanal.Value < 1 Then Exit Sub

itemNome = Trim$(Item(scrlSemanal.Value).Name)


For i = 1 To Player_HighIndex
    If IsPlaying(i) Then
        If GetPlayerAccess(i) < ADMIN_MONITOR Then
            For n = 1 To MAX_INV
                If GetPlayerInvItemNum(i, n) = scrlSemanal.Value Then
                    If GetPlayerInvItemValue(i, n) > LastValue Then
                        LastValue = GetPlayerInvItemValue(i, n)
                        LastIndex = i
                    End If
                End If
            Next
        End If
    End If
Next

If LastIndex < 1 Then
    GlobalMsg "Não houve ganhador", Red
    Exit Sub
End If

If IsPlaying(LastIndex) = False Then
    GlobalMsg "Player offline", BrightRed
    Exit Sub
End If

GlobalMsg GetPlayerName(LastIndex) & " ganhou o evento semanal com exatos: " & LastValue & " " & itemNome & " !", White
PlayerMsg LastIndex, "Você ganhou o evento semanal,fale alguma coisa no global para sabermos se está online", Yellow

End Sub

Private Sub cmdLevelUP_Click()
Dim i As Byte

For i = 1 To Player_HighIndex
    TempPlayer(i).SetExp = YES
    SetPlayerExp i, GetPlayerNextLevel(i)
    CheckPlayerLevelUp i
Next

GlobalMsg "Foi dado 1 level como presente a todos online!", BrightGreen

End Sub

Private Sub cmdNoticias_Click()
Dim Folder As String

Folder = App.Path & "\Noticias.TXT"
    Noticias_MAX = GetVar(Folder, "MAX", "MAX")
End Sub

Private Sub cmdSortearP_Click()
Dim i As Long
Dim randP As Long

randP = RAND(1, Player_HighIndex)

If IsPlaying(randP) Then
    If GetPlayerAccess(randP) = 1 Then 'Player
        If chkGiveCash.Value = YES Then
            GlobalMsg GetPlayerName(randP) & " foi o player sorteado e ganhou 500 CASH!", BrightGreen
            PlayerMsg randP, "Você ganhou 500 CASH por ser sorteado!", BrightGreen
            GiveInvItem randP, 254, 500, True
        Else
            GlobalMsg GetPlayerName(randP) & " foi o player sorteado!", BrightGreen
        End If
    End If
End If

End Sub

Private Sub Command1_Click()
Dim i As Long

   
    With frmEditor_Quest
    Editor = EDITOR_QUEST
        .lstIndex.Clear

        ' Add the names
        For i = 1 To MAX_QUESTS
            .lstIndex.AddItem i & ": " & Trim$(Quest(i).Name)
        Next

        .Show
        .lstIndex.ListIndex = 0
        QuestEditorInit
    End With
End Sub

Private Sub Command2_Click()

GlobalMsg "Evento Ativo!! Agora você ganha " & txtEventoEXP.Text & " vezes mais de EXP!Aproveite,OhYehGames.", BrightCyan
GlobalMsg "Evento ativo até as :" & frmServer.txtEventHour & " hrs", White
frmServer.chkEventActive.Value = YES

End Sub

Private Sub Command3_Click()
Dim i As Long
frmVIP.lstCT.Clear
frmVIP.lstVIP.Clear

For i = 1 To Player_HighIndex
    If Not Player(i).VipData.DiasVIP = vbNullString Then
        If Player(i).VipData.VIP > 0 And Player(i).VipData.DiasVIP > 1 Then
            frmVIP.lstVIP.AddItem GetPlayerName(i) & "[VIP:" & Player(i).VipData.VIP & "][" & GetPlayerLogin(i) & "](" & Player(i).VipData.DiasVIP & " Dias)"
        End If
    End If

    If Player(i).CTdata.CT = YES Then
        frmVIP.lstCT.AddItem GetPlayerName(i) & "[" & GetPlayerLogin(i) & "](" & Player(i).CTdata.DiasCT & " Dias)"
    End If
    
Next

frmVIP.Show

End Sub

Private Sub lblCPSLock_Click()
    If CPSUnlock Then
        CPSUnlock = False
        lblCpsLock.Caption = "[Unlock]"
    Else
        CPSUnlock = True
        lblCpsLock.Caption = "[Lock]"
    End If
End Sub

Private Sub lstTorneios_Click()
Dim i As Long

kageLutou = NO 'zera a checagem do kage
For i = 1 To MAX_LIMIT_TIP
    SemTip(i) = vbNullString
Next

Select Case lstTorneios.ListIndex
    Case NO
        Torneio = NO
        lblTorneio.Caption = "Torneio:Nenhum"
    Case TORNEIO_CS 'Chunin Shiken
        Torneio = TORNEIO_CS
        lblTorneio.Caption = "Chunin"
    Case TORNEIO_POKEMON 'Temos que pegar
        Torneio = TORNEIO_POKEMON
        lblTorneio.Caption = "Pokemon"
    Case TORNEIO_DESAFIOS 'os desafios
        Torneio = TORNEIO_DESAFIOS
        lblTorneio.Caption = "Desafios"
    Case TORNEIO_SEMANAL 'Semanal
        Torneio = TORNEIO_SEMANAL
        lblTorneio.Caption = "Semanal"
    Case TORNEIO_KAGE_KONOHA 'Kage Konoha
        Torneio = TORNEIO_KAGE_KONOHA
        lblTorneio.Caption = "KageKonoha"
    Case TORNEIO_KAGE_SUNA 'Kage Suna
        Torneio = TORNEIO_KAGE_SUNA
        lblTorneio.Caption = "KageSuna"
    Case TORNEIO_KAGE_KIRI 'Kage Kiri
        Torneio = TORNEIO_KAGE_KIRI
        lblTorneio.Caption = "KageKiri"
    Case TORNEIO_KAGE_IWA
        Torneio = TORNEIO_KAGE_IWA
        lblTorneio.Caption = "KageIwa"
    Case TORNEIO_KAGE_KUMO
        Torneio = TORNEIO_KAGE_KUMO
        lblTorneio.Caption = "KageKumo"
    Case TORNEIO_KAGE_CHUVA 'Líder da Chuva
        Torneio = TORNEIO_KAGE_CHUVA
        lblTorneio.Caption = "KageChuva"
    Case TORNEIO_LENDARIO 'lendário
        Torneio = TORNEIO_LENDARIO
        lblTorneio.Caption = "Lendário"
    Case TORNEIO_LUTA 'Campeonatinho
        Torneio = TORNEIO_LUTA
        lblTorneio.Caption = "Luta"
    Case TORNEIO_KAGE_SOM 'Kage som
        Torneio = TORNEIO_KAGE_SOM
        lblTorneio.Caption = "KageSom"
    Case TORNEIO_GUERRA 'guerra Shinobi
        Torneio = TORNEIO_GUERRA
        lblTorneio.Caption = "Guerra"
        
    Case Else
End Select

End Sub



Private Sub scrlFightLevel_Change()
lblFightLevel.Caption = "Nível:" & scrlFightLevel.Value

End Sub

Private Sub scrlSemanal_Change()

If scrlSemanal.Value > 0 Then
    lblSemanal.Caption = scrlSemanal.Value & ":" & Trim$(Item(scrlSemanal.Value).Name)
Else
    lblSemanal.Caption = "Item:Nenhum"
End If


End Sub

' ********************
' ** Winsock object **
' ********************
Private Sub Socket_ConnectionRequest(index As Integer, ByVal requestID As Long)
    On Error GoTo errorhandler
    
    If GameCPS < 15 Then Exit Sub
    If Player_HighIndex >= MAX_PLAYERS - 1 Then Exit Sub
    If index > MAX_PLAYERS Then Exit Sub
    If requestID > MAX_LONG Then Exit Sub
    
    Call AcceptConnection(index, requestID)
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "Socket_ConnectionRequest", "frmServer", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub Socket_Accept(index As Integer, SocketId As Integer)
    On Error GoTo errorhandler
    
    If index > MAX_PLAYERS Then Exit Sub
    If SocketId > MAX_INTEGER Then Exit Sub
    
    Call AcceptConnection(index, SocketId)
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "Socket_Accept", "frmServer", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub Socket_DataArrival(index As Integer, ByVal bytesTotal As Long)
    On Error GoTo errorhandler
    
    If index < 1 Or index > MAX_PLAYERS Then Exit Sub
    
    If IsConnected(index) Then
        Call IncomingData(index, bytesTotal)
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "Socket_DataArrival", "frmServer", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub Socket_Close(index As Integer)
    On Error GoTo errorhandler
    
    If index > MAX_PLAYERS Then Exit Sub
    
    Call CloseSocket(index)
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "Socket_Close", "frmServer", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' ********************
Private Sub chkServerLog_Click()

    ' if its not 0, then its true
    If Not chkServerLog.Value Then
        ServerLog = True
    End If

End Sub

Private Sub cmdExit_Click()
    Call desligarServ
End Sub

Private Sub cmdReloadClasses_Click()
Dim i As Long
    Call LoadClasses
    Call TextAdd("All classes reloaded.")
    For i = 1 To Player_HighIndex
        If IsPlaying(i) Then
            SendClasses i
        End If
    Next
End Sub

Private Sub cmdReloadItems_Click()
Dim i As Long
    Call LoadItems
    Call TextAdd("All items reloaded.")
    For i = 1 To Player_HighIndex
        If IsPlaying(i) Then
            SendItems i
        End If
    Next
End Sub

Private Sub cmdReloadMaps_Click()
Dim i As Long
    Call LoadMaps
    Call TextAdd("All maps reloaded.")
    For i = 1 To Player_HighIndex
        If IsPlaying(i) Then
            PlayerWarp i, GetPlayerMap(i), GetPlayerX(i), GetPlayerY(i)
        End If
    Next
End Sub

Private Sub cmdReloadNPCs_Click()
Dim i As Long
    Call LoadNpcs
    Call TextAdd("All npcs reloaded.")
    For i = 1 To Player_HighIndex
        If IsPlaying(i) Then
            SendNpcs i
        End If
    Next
End Sub

Private Sub cmdReloadShops_Click()
Dim i As Long
    Call LoadShops
    Call TextAdd("All shops reloaded.")
    For i = 1 To Player_HighIndex
        If IsPlaying(i) Then
            SendShops i
        End If
    Next
End Sub

Private Sub cmdReloadSpells_Click()
Dim i As Long
    Call LoadSpells
    Call TextAdd("All spells reloaded.")
    For i = 1 To Player_HighIndex
        If IsPlaying(i) Then
            SendSpells i
        End If
    Next
End Sub

Private Sub cmdReloadResources_Click()
Dim i As Long
    Call LoadResources
    Call TextAdd("All Resources reloaded.")
    For i = 1 To Player_HighIndex
        If IsPlaying(i) Then
            SendResources i
        End If
    Next
End Sub

Private Sub cmdReloadAnimations_Click()
Dim i As Long
    Call LoadAnimations
    Call TextAdd("All Animations reloaded.")
    For i = 1 To Player_HighIndex
        If IsPlaying(i) Then
            SendAnimations i
        End If
    Next
End Sub

Private Sub cmdShutDown_Click()
    If isShuttingDown Then
        isShuttingDown = False
        cmdShutDown.Caption = "Shutdown"
        GlobalMsg "Shutdown canceled.", BrightBlue
    Else
        isShuttingDown = True
        cmdShutDown.Caption = "Cancel"
        AtualizarTops
    End If
End Sub

Private Sub Form_Load()
    Call UsersOnline_Start
    scrlSemanal.Max = MAX_ITEMS
    
End Sub

Private Sub Form_Resize()

    If frmServer.WindowState = vbMinimized Then
        frmServer.Hide
    End If

End Sub

Private Sub Form_Unload(Cancel As Integer)
    Cancel = True
    Call desligarServ
End Sub

Private Sub lvwInfo_ColumnClick(ByVal ColumnHeader As MSComctlLib.ColumnHeader)

    'When a ColumnHeader object is clicked, the ListView control is sorted by the subitems of that column.
    'Set the SortKey to the Index of the ColumnHeader - 1
    'Set Sorted to True to sort the list.
    If lvwInfo.SortOrder = lvwAscending Then
        lvwInfo.SortOrder = lvwDescending
    Else
        lvwInfo.SortOrder = lvwAscending
    End If

    lvwInfo.SortKey = ColumnHeader.index - 1
    lvwInfo.Sorted = True
End Sub



Private Sub txtEventHour_Change()
If Not IsNumeric(txtEventHour.Text) Then
   txtEventHour.Text = "0"
End If
End Sub


Private Sub txtEventoEXP_Change()
If Not IsNumeric(txtEventoEXP.Text) Then
   txtEventoEXP.Text = "0"
End If
End Sub

Private Sub txtText_GotFocus()
    txtChat.SetFocus
End Sub

Private Sub txtChat_KeyPress(KeyAscii As Integer)

    If KeyAscii = vbKeyReturn Then
        If LenB(Trim$(txtChat.Text)) > 0 Then
            Call GlobalMsg("Servidor:" & txtChat.Text, BrightCyan)
            Call TextAdd("Server: " & txtChat.Text)
            txtChat.Text = vbNullString
        End If

        KeyAscii = 0
    End If

End Sub

Sub UsersOnline_Start()
    Dim i As Long

    For i = 1 To MAX_PLAYERS
        frmServer.lvwInfo.ListItems.Add (i)

        If i < 10 Then
            frmServer.lvwInfo.ListItems(i).Text = "00" & i
        ElseIf i < 100 Then
            frmServer.lvwInfo.ListItems(i).Text = "0" & i
        Else
            frmServer.lvwInfo.ListItems(i).Text = i
        End If

        frmServer.lvwInfo.ListItems(i).SubItems(1) = vbNullString
        frmServer.lvwInfo.ListItems(i).SubItems(2) = vbNullString
        frmServer.lvwInfo.ListItems(i).SubItems(3) = vbNullString
    Next

End Sub

Private Sub lvwInfo_MouseDown(Button As Integer, Shift As Integer, X As Single, Y As Single)

    If Button = vbRightButton Then
        PopupMenu mnuKick
    End If

End Sub

Private Sub mnuKickPlayer_Click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
        Call AlertMsg(FindPlayer(Name), "You have been kicked by the server owner!")
    End If

End Sub

Sub mnuDisconnectPlayer_Click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
        CloseSocket (FindPlayer(Name))
    End If

End Sub

Sub mnuBanPlayer_click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
        'Call ServerBanIndex(FindPlayer(Name))
    End If

End Sub

Sub mnuAdminPlayer_click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
        Call SetPlayerAccess(FindPlayer(Name), 5)
        Call SendPlayerData(FindPlayer(Name))
        Call PlayerMsg(FindPlayer(Name), "You have been granted administrator access.", BrightCyan)
        SavePlayer FindPlayer(Name)
    End If

End Sub

Sub mnuRemoveAdmin_click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
        Call SetPlayerAccess(FindPlayer(Name), 1)
        Call SendPlayerData(FindPlayer(Name))
        Call PlayerMsg(FindPlayer(Name), "You have had your administrator access revoked.", BrightRed)
    End If

End Sub

Sub mnuVip1_click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
    
    If MsgBox(Name, vbYesNo) = vbNo Then Exit Sub
    
        Player(FindPlayer(Name)).VIP = 1
        Call SendPlayerData(FindPlayer(Name))
        Call PlayerMsg(FindPlayer(Name), "Parabéns!Agora você é VIP nível 1!.", BrightCyan)
    End If

End Sub

Sub mnuVip2_click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
    
    If MsgBox(Name, vbYesNo) = vbNo Then Exit Sub
    
        Player(FindPlayer(Name)).VIP = 2
        Call SendPlayerData(FindPlayer(Name))
        Call PlayerMsg(FindPlayer(Name), "Parabéns!Agora você é VIP nível 2!.", BrightCyan)
    End If

End Sub

Sub mnuVip3_click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
    
    If MsgBox(Name, vbYesNo) = vbNo Then Exit Sub
    
        Player(FindPlayer(Name)).VIP = 3
        Call SendPlayerData(FindPlayer(Name))
        Call PlayerMsg(FindPlayer(Name), "Parabéns!Agora você é VIP nível 3!.", BrightCyan)
    End If

End Sub

Sub mnuTirarVip_click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
    
    If MsgBox(Name, vbYesNo) = vbNo Then Exit Sub
    
        Player(FindPlayer(Name)).VIP = 0
        Call SendPlayerData(FindPlayer(Name))
        Call PlayerMsg(FindPlayer(Name), "Seu tempo como Player VIP acabou.Obrigado por ter ajudado a família NIP!", BrightRed)
    End If

End Sub

Sub mnuRankDesertor_click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
    
    If MsgBox(Name, vbYesNo) = vbNo Then Exit Sub
    
        Player(FindPlayer(Name)).Rank = RANK_DESERTOR
        Call SendPlayerData(FindPlayer(Name))
        Call PlayerMsg(FindPlayer(Name), "Você acaba de virar um Desertor.", BrightCyan)
    End If

End Sub

Sub mnuRankEstudante_click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
    
    If MsgBox(Name, vbYesNo) = vbNo Then Exit Sub
    
        Player(FindPlayer(Name)).Rank = RANK_ESTUDANTE
        Call SendPlayerData(FindPlayer(Name))
        Call PlayerMsg(FindPlayer(Name), "Você acaba de virar um Estudante.", BrightCyan)
    End If

End Sub

Sub mnuRankGenin_click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
    
    If MsgBox(Name, vbYesNo) = vbNo Then Exit Sub
    
        Player(FindPlayer(Name)).Rank = RANK_GENIN
        Call SendPlayerData(FindPlayer(Name))
        Call PlayerMsg(FindPlayer(Name), "Você acaba de virar um Genin.", BrightCyan)
    End If

End Sub

Sub mnuRankChunin_click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
    
    If MsgBox(Name, vbYesNo) = vbNo Then Exit Sub
    
        Player(FindPlayer(Name)).Rank = RANK_CHUNIN
        Call SendPlayerData(FindPlayer(Name))
        Call PlayerMsg(FindPlayer(Name), "Você acaba de virar um Chunin.", BrightCyan)
        If frmServer.chkOmitir = 0 Then
            GlobalMsg Name & " acaba de se tornar Chunin!", White
        End If
    End If

End Sub

Sub mnuRankJounin_click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
    
    If MsgBox(Name, vbYesNo) = vbNo Then Exit Sub
    
        Player(FindPlayer(Name)).Rank = RANK_JOUNIN
        Call SendPlayerData(FindPlayer(Name))
        Call PlayerMsg(FindPlayer(Name), "Você acaba de virar um Jounin.", BrightCyan)
        If frmServer.chkOmitir = 0 Then
            GlobalMsg Name & " acaba de se tornar Jounin!", White
        End If
    End If

End Sub

Sub mnuRankAnbu_click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
    
    If MsgBox(Name, vbYesNo) = vbNo Then Exit Sub
        'Player(FindPlayer(Name)).Org = ORG_ANBU
        'Player(FindPlayer(Name)).Rank = RANK_ANBU
        Call SendPlayerData(FindPlayer(Name))
        Call PlayerMsg(FindPlayer(Name), "Você acaba de virar um ANBU.", BrightCyan)
        If frmServer.chkOmitir = 0 Then
            GlobalMsg Name & " acaba de se tornar ANBU!", White
        End If
    End If

End Sub

Sub mnuRanksannin_click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
    
    If MsgBox(Name, vbYesNo) = vbNo Then Exit Sub
    
        Player(FindPlayer(Name)).Rank = RANK_SANNIN
        Call SendPlayerData(FindPlayer(Name))
        Call PlayerMsg(FindPlayer(Name), "Você acaba de virar um Sannin.", BrightCyan)
        If frmServer.chkOmitir = 0 Then
            GlobalMsg Name & " acaba de se tornar Sannin!", White
        End If
    End If

End Sub

Sub mnuRankKage_click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
    
    If MsgBox(Name, vbYesNo) = vbNo Then Exit Sub
    
        Player(FindPlayer(Name)).Rank = RANK_KAGE
        Call SendPlayerData(FindPlayer(Name))
        Call PlayerMsg(FindPlayer(Name), "Você acaba de virar um Kage.", BrightCyan)
        If frmServer.chkOmitir = 0 Then
            GlobalMsg Name & " acaba de se tornar Kage!", White
        End If
    End If

End Sub

Sub mnuOrgPoliciaKonoha_click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
    
    If MsgBox(Name, vbYesNo) = vbNo Then Exit Sub
    
        Player(FindPlayer(Name)).Org = ORG_POLICIAKONOHA
        Call SendPlayerData(FindPlayer(Name))
        Call PlayerMsg(FindPlayer(Name), "Você entrou para a Policia de Konoha.", BrightCyan)
        If frmServer.chkOmitir = 0 Then
            GlobalMsg Name & " acaba de entrar para a Organização:Policiais de Konoha!", White
        End If
    End If

End Sub

Sub mnuOrgAkatsuki_click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
    
    If MsgBox(Name, vbYesNo) = vbNo Then Exit Sub
    
        Player(FindPlayer(Name)).Org = ORG_AKATSUKI
        Player(FindPlayer(Name)).Rank = RANK_DESERTOR
        Player(FindPlayer(Name)).Vila = 0
        Call SendPlayerData(FindPlayer(Name))
        Call PlayerMsg(FindPlayer(Name), "Você entrou para a Akatsuki.", BrightCyan)
        If frmServer.chkOmitir = 0 Then
            GlobalMsg Name & " acaba de entrar para a Organização:Akatsuki!", White
        End If
        SavePlayer FindPlayer(Name)
    End If

End Sub

Sub mnuOrgTakA_click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
    
    If MsgBox(Name, vbYesNo) = vbNo Then Exit Sub
    
        Player(FindPlayer(Name)).Org = ORG_TAKA
        Player(FindPlayer(Name)).Rank = RANK_DESERTOR
        Player(FindPlayer(Name)).Vila = 0
        Call SendPlayerData(FindPlayer(Name))
        Call PlayerMsg(FindPlayer(Name), "Você entrou para a TaKa.", BrightCyan)
        If frmServer.chkOmitir = 0 Then
            GlobalMsg Name & " acaba de entrar para a Organização:Taka!", White
        End If
        SavePlayer FindPlayer(Name)
    End If

End Sub

Sub mnuorg7espadachins_click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
    
    If MsgBox(Name, vbYesNo) = vbNo Then Exit Sub
    
        Player(FindPlayer(Name)).Org = ORG_7ESPADACHINS
        Player(FindPlayer(Name)).Rank = RANK_DESERTOR
        Player(FindPlayer(Name)).Vila = 0
        Call SendPlayerData(FindPlayer(Name))
        Call PlayerMsg(FindPlayer(Name), "Você entrou para os 7 Espadachins da Névoa.", BrightCyan)
        If frmServer.chkOmitir = 0 Then
            GlobalMsg Name & " acaba de entrar para a Organização:7 Espadachins da Névoa!", White
        End If
        SavePlayer FindPlayer(Name)
    End If

End Sub

Sub mnuOrg12guardioes_click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
    
    If MsgBox(Name, vbYesNo) = vbNo Then Exit Sub
    
        Player(FindPlayer(Name)).Org = ORG_12GUARDIOES
        Call SendPlayerData(FindPlayer(Name))
        Call PlayerMsg(FindPlayer(Name), "Você entrou para os 12 Guardiões do Senhor Feudal.", BrightCyan)
        If frmServer.chkOmitir = 0 Then
            GlobalMsg Name & " acaba de entrar para a Organização:12 Guardiões do Senhor Feudal!", White
        End If
    End If

End Sub

Sub mnuOrgANBu_click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
    
    If MsgBox(Name, vbYesNo) = vbNo Then Exit Sub
    
        'Player(FindPlayer(Name)).Org = ORG_ANBU
        Call SendPlayerData(FindPlayer(Name))
        Call PlayerMsg(FindPlayer(Name), "Você entrou para a ANBU.", BrightCyan)
        If frmServer.chkOmitir = 0 Then
            GlobalMsg Name & " acaba de entrar para a Organização:ANBU!", White
        End If
    End If

End Sub

Sub mnuOrgANBURaiz_click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
    
    If MsgBox(Name, vbYesNo) = vbNo Then Exit Sub
    
        Player(FindPlayer(Name)).Org = ORG_ANBURAIZ
        Call SendPlayerData(FindPlayer(Name))
        Call PlayerMsg(FindPlayer(Name), "Você acaba entrou para a ANBU Raíz.", BrightCyan)
        If frmServer.chkOmitir = 0 Then
            GlobalMsg Name & " acaba de entrar para a Organização:ANBU Raiz!", White
        End If
    End If

End Sub

Sub mnuOrgUnderworld_click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
    
    If MsgBox(Name, vbYesNo) = vbNo Then Exit Sub
    
        Player(FindPlayer(Name)).Org = ORG_FREE
        Call SendPlayerData(FindPlayer(Name))
        Call PlayerMsg(FindPlayer(Name), "Você acaba entrou para a Laços Ninja.", BrightCyan)
        If frmServer.chkOmitir = 0 Then
            GlobalMsg Name & " acaba de entrar para a Organização:Laços Ninja!", White
        End If
    End If

End Sub

Sub mnuOrgRenegados_click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
    
    If MsgBox(Name, vbYesNo) = vbNo Then Exit Sub
    
        'Player(FindPlayer(Name)).Org = ORG_RENEGADOS
        Call SendPlayerData(FindPlayer(Name))
        Call PlayerMsg(FindPlayer(Name), "Você acaba entrou para a Elite Shinobi.", BrightCyan)
        If frmServer.chkOmitir = 0 Then
            GlobalMsg Name & " acaba de entrar para a Organização:Elite Shinobi!", White
        End If
    End If

End Sub

Sub mnuTirarOrg_click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
    
    If MsgBox(Name, vbYesNo) = vbNo Then Exit Sub
    
        Player(FindPlayer(Name)).Org = 0
        Call SendPlayerData(FindPlayer(Name))
        Call PlayerMsg(FindPlayer(Name), "Você não têm mais uma Org.", BrightCyan)
        SavePlayer FindPlayer(Name)
        
    End If

End Sub


Sub mnuOrgHospital_click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
    
    If MsgBox(Name, vbYesNo) = vbNo Then Exit Sub
    
        Player(FindPlayer(Name)).Org = ORG_HOSPITAL
        Call SendPlayerData(FindPlayer(Name))
        Call PlayerMsg(FindPlayer(Name), "Você acaba entrou para o Hospital.", BrightCyan)
        If frmServer.chkOmitir = 0 Then
            GlobalMsg Name & " acaba de entrar para a Organização:Hospital!", White
        End If
    End If

End Sub

Sub mnuMuteYes_click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
    
    If MsgBox(Name, vbYesNo) = vbNo Then Exit Sub
    
        Player(FindPlayer(Name)).Mute = YES
        Call SendPlayerData(FindPlayer(Name))
        PlayerMsg FindPlayer(Name), "Você foi mutado!", BrightRed
    End If

End Sub

Sub mnuMuteNo_click()
    Dim Name As String
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
    
    If MsgBox(Name, vbYesNo) = vbNo Then Exit Sub
    
        Player(FindPlayer(Name)).Mute = NO
        Call SendPlayerData(FindPlayer(Name))
        PlayerMsg FindPlayer(Name), "Você não está mais mutado!", BrightGreen
    End If

End Sub

Sub mnuDesBan_click()
    Dim Name As String
    Dim i As Byte
    
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
    
    If MsgBox(Name, vbYesNo) = vbNo Then Exit Sub
    
        Player(FindPlayer(Name)).Ban.Ban = NO
        Player(FindPlayer(Name)).Ban.Data = vbNullString
        Player(FindPlayer(Name)).Ban.Dias = vbNullString
        
        Call SendPlayerData(FindPlayer(Name))
        SavePlayer FindPlayer(Name)
        
        For i = 1 To Player_HighIndex
            If IsPlaying(i) Then
                If Player(i).Access > 1 Then
                    PlayerMsg i, Name & " foi desbanido !", Green
                End If
            End If
        Next
    End If

End Sub

Sub mnuBan_click()
    Dim Name As String
    Dim i As Byte
    
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
    
    If MsgBox(Name, vbYesNo) = vbNo Then Exit Sub
    
        Player(FindPlayer(Name)).Ban.Ban = YES
        Player(FindPlayer(Name)).Ban.Data = vbNullString
        Player(FindPlayer(Name)).Ban.Dias = vbNullString
        
        Call SendPlayerData(FindPlayer(Name))
        SavePlayer FindPlayer(Name)
        
        AlertMsg FindPlayer(Name), "Você foi BANIDO!"
        
        For i = 1 To Player_HighIndex
            If IsPlaying(i) Then
                If Player(i).Access > 1 Then
                    PlayerMsg i, Name & " foi banido !", Green
                End If
            End If
        Next
    End If

End Sub


Private Sub Form_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    Dim lmsg As Long
    lmsg = X / Screen.TwipsPerPixelX

    Select Case lmsg
        Case WM_LBUTTONDBLCLK
            frmServer.WindowState = vbNormal
            frmServer.Show
            txtText.SelStart = Len(txtText.Text)
    End Select

End Sub
