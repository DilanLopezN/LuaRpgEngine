VERSION 5.00
Object = "{248DD890-BB45-11CF-9ABC-0080C7E7B78D}#1.0#0"; "mswinsck.ocx"
Object = "{BDC217C8-ED16-11CD-956C-0000C04E4C0A}#1.1#0"; "tabctl32.ocx"
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.0#0"; "MsComCtl.ocx"
Begin VB.Form frmServer 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Loading..."
   ClientHeight    =   4035
   ClientLeft      =   45
   ClientTop       =   330
   ClientWidth     =   6720
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
   ScaleHeight     =   4035
   ScaleWidth      =   6720
   StartUpPosition =   2  'CenterScreen
   Begin VB.CheckBox chkOmitir 
      Caption         =   "Omitir Graduações Globais?"
      Height          =   255
      Left            =   2760
      TabIndex        =   28
      Top             =   3600
      Width           =   3735
   End
   Begin MSWinsockLib.Winsock Socket 
      Index           =   0
      Left            =   0
      Top             =   0
      _ExtentX        =   741
      _ExtentY        =   741
      _Version        =   393216
   End
   Begin TabDlg.SSTab SSTab1 
      Height          =   3375
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   6495
      _ExtentX        =   11456
      _ExtentY        =   5953
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
      Tab(2).Control(0)=   "cmdAtuTops"
      Tab(2).Control(0).Enabled=   0   'False
      Tab(2).Control(1)=   "cmdNoticias"
      Tab(2).Control(1).Enabled=   0   'False
      Tab(2).Control(2)=   "Command3"
      Tab(2).Control(2).Enabled=   0   'False
      Tab(2).Control(3)=   "cmdAnunciarTorneio"
      Tab(2).Control(3).Enabled=   0   'False
      Tab(2).Control(4)=   "scrlTorneio"
      Tab(2).Control(4).Enabled=   0   'False
      Tab(2).Control(5)=   "fraEvento"
      Tab(2).Control(5).Enabled=   0   'False
      Tab(2).Control(6)=   "fraEditores"
      Tab(2).Control(6).Enabled=   0   'False
      Tab(2).Control(7)=   "fraServer"
      Tab(2).Control(7).Enabled=   0   'False
      Tab(2).Control(8)=   "fraDatabase"
      Tab(2).Control(8).Enabled=   0   'False
      Tab(2).Control(9)=   "lblTorneio"
      Tab(2).Control(9).Enabled=   0   'False
      Tab(2).ControlCount=   10
      Begin VB.CommandButton cmdAtuTops 
         Caption         =   "Atualizar Tops"
         Height          =   255
         Left            =   -69960
         TabIndex        =   31
         Top             =   1920
         Width           =   1335
      End
      Begin VB.CommandButton cmdNoticias 
         Caption         =   "Atualizar Noticias"
         Height          =   375
         Left            =   -70080
         TabIndex        =   30
         Top             =   1560
         Width           =   1455
      End
      Begin VB.CommandButton Command3 
         Caption         =   "Checar VIP/CT"
         Height          =   255
         Left            =   -70080
         TabIndex        =   29
         Top             =   1200
         Width           =   1455
      End
      Begin VB.CommandButton cmdAnunciarTorneio 
         Caption         =   "Go"
         Height          =   255
         Left            =   -70560
         TabIndex        =   26
         Top             =   1920
         Width           =   495
      End
      Begin VB.HScrollBar scrlTorneio 
         Height          =   255
         Left            =   -71760
         Max             =   12
         TabIndex        =   24
         Top             =   1920
         Width           =   1095
      End
      Begin VB.Frame fraEvento 
         Caption         =   "Evento EXP"
         Height          =   735
         Left            =   -71880
         TabIndex        =   21
         Top             =   2400
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
         Left            =   -69960
         TabIndex        =   19
         Top             =   360
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
         Top             =   360
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
         Begin VB.CheckBox chkShutGlobal 
            Caption         =   "MuteGlobal"
            Height          =   255
            Left            =   1440
            TabIndex        =   27
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
         Left            =   120
         TabIndex        =   3
         Top             =   2880
         Width           =   6255
      End
      Begin VB.TextBox txtText 
         Height          =   2175
         Left            =   120
         MultiLine       =   -1  'True
         ScrollBars      =   2  'Vertical
         TabIndex        =   2
         Top             =   600
         Width           =   6255
      End
      Begin MSComctlLib.ListView lvwInfo 
         Height          =   2775
         Left            =   -74880
         TabIndex        =   4
         Top             =   480
         Width           =   6255
         _ExtentX        =   11033
         _ExtentY        =   4895
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
         Caption         =   "Torneio:Nenhum"
         Height          =   255
         Left            =   -71640
         TabIndex        =   25
         Top             =   1680
         Width           =   1455
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

Private Sub chkShutGlobal_Click()


If chkShutGlobal.Value = YES Then
    ShutGlobal = YES
Else
    ShutGlobal = NO
End If

End Sub

Private Sub cmdAnunciarTorneio_Click()
Dim texto As String
Select Case scrlTorneio.Value
    Case 1 'Chunin Shiken
        texto = "Chunin Shiken"
    Case 2 'Jounin
        texto = "Jounin Shiken"
    Case 3 'ANBU
        texto = "Anbu Shiken"
    Case 4 'Sannin
        texto = "Sannin Shiken"
    Case 5 'Kage Konoha
        texto = "Hokage"
    Case 6 'Kage Suna
        texto = "Kazekage"
    Case 7 'Kage Kiri
        texto = "Mizukage"
    Case 8 'Kage Iwa
        texto = "Tscuchikage"
    Case 9 'Kage Kumo
        texto = "Raikage"
    Case 10 'Orgs Desertoras
        texto = "Org Desertora"
    Case 11 'Orgs Normais
        texto = "Organização"
    Case 12 'Torneio
        texto = "Torneio"
    Case 13 'Invasão
        texto = "Invasão"
    Case Else
End Select

GlobalMsg "Torneio " & texto & " ativo !Boa sorte!!", BrightCyan
GlobalMsg "Para participar,digite no MAPA : /torneio.", BrightCyan
GlobalMsg "Vá em 'CONFIG' e bote o 'AutoTile' em 'OFF' para evitar erros.", BrightCyan
End Sub

Private Sub cmdAtuTops_Click()
AtualizarTops
GlobalMsg "Top's atualizados", Yellow
TextAdd "Top atualizado pra todos"

End Sub

Private Sub cmdNoticias_Click()
Dim Folder As String

Folder = App.Path & "\Noticias.TXT"
    Noticias_MAX = GetVar(Folder, "MAX", "MAX")
End Sub

Private Sub Command1_Click()
Dim I As Long

   
    With frmEditor_Quest
    Editor = EDITOR_QUEST
        .lstIndex.Clear

        ' Add the names
        For I = 1 To MAX_QUESTS
            .lstIndex.AddItem I & ": " & Trim$(Quest(I).Name)
        Next

        .Show
        .lstIndex.ListIndex = 0
        QuestEditorInit
    End With
End Sub

Private Sub Command2_Click()
On Error Resume Next
GlobalMsg "Evento Ativo!! Agora você ganha " & txtEventoEXP.Text & " vezes mais de EXP!Aproveite,OhYehGames.", BrightCyan

End Sub

Private Sub Command3_Click()
Dim I As Long
frmVIP.lstCT.Clear
frmVIP.lstVIP.Clear

For I = 1 To Player_HighIndex
    If Not Player(I).VipData.DiasVIP = vbNullString Then
        If Player(I).VipData.VIP > 0 And Player(I).VipData.DiasVIP > 1 Then
            frmVIP.lstVIP.AddItem GetPlayerName(I) & "[" & GetPlayerLogin(I) & "](" & Player(I).VipData.DiasVIP & " Dias)"
        End If
    End If

    If Player(I).CTdata.CT = YES Then
        frmVIP.lstCT.AddItem GetPlayerName(I) & "[" & GetPlayerLogin(I) & "](" & Player(I).CTdata.DiasCT & " Dias)"
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

Private Sub scrlTorneio_Change()
Select Case scrlTorneio.Value
    Case 0
        Torneio = vbNullString
        lblTorneio.Caption = "Torneio:Nenhum"
    Case 1 'Chunin Shiken
        Torneio = "cs"
        lblTorneio.Caption = "Chunin"
    Case 2 'Jounin Shiken
        Torneio = "js"
        lblTorneio.Caption = "Jounin"
    Case 3 'ANBU
        Torneio = "as"
        lblTorneio.Caption = "ANBU"
    Case 4 'Sannin
        Torneio = "ss"
        lblTorneio.Caption = "Sannin"
    Case 5 'Kage Konoha
        Torneio = "KageKonoha"
        lblTorneio.Caption = "KageKonoha"
    Case 6 'Kage Suna
        Torneio = "KageSuna"
        lblTorneio.Caption = "KageSuna"
    Case 7 'Kage Kiri
        Torneio = "KageKiri"
        lblTorneio.Caption = "KageKiri"
    Case 8 'Kage Iwa
        Torneio = "KageIwa"
        lblTorneio.Caption = "KageIwa"
    Case 9 'Kage Kumo
        Torneio = "KageKumo"
        lblTorneio.Caption = "KageKumo"
    Case 10 'Líder da Chuva
        Torneio = "KageChuva"
        lblTorneio.Caption = "KageChuva"
    Case 11 'Evento normal mata mata,etc..
        Torneio = "Torneio"
        lblTorneio.Caption = "Torneio"
    
        
    Case Else
End Select

End Sub

' ********************
' ** Winsock object **
' ********************
Private Sub Socket_ConnectionRequest(index As Integer, ByVal requestID As Long)
    Call AcceptConnection(index, requestID)
End Sub

Private Sub Socket_Accept(index As Integer, SocketId As Integer)
    Call AcceptConnection(index, SocketId)
End Sub

Private Sub Socket_DataArrival(index As Integer, ByVal bytesTotal As Long)

    If IsConnected(index) Then
        Call IncomingData(index, bytesTotal)
    End If

End Sub

Private Sub Socket_Close(index As Integer)
    Call CloseSocket(index)
End Sub

' ********************
Private Sub chkServerLog_Click()

    ' if its not 0, then its true
    If Not chkServerLog.Value Then
        ServerLog = True
    End If

End Sub

Private Sub cmdExit_Click()
    Call DestroyServer
End Sub

Private Sub cmdReloadClasses_Click()
Dim I As Long
    Call LoadClasses
    Call TextAdd("All classes reloaded.")
    For I = 1 To Player_HighIndex
        If IsPlaying(I) Then
            SendClasses I
        End If
    Next
End Sub

Private Sub cmdReloadItems_Click()
Dim I As Long
    Call LoadItems
    Call TextAdd("All items reloaded.")
    For I = 1 To Player_HighIndex
        If IsPlaying(I) Then
            SendItems I
        End If
    Next
End Sub

Private Sub cmdReloadMaps_Click()
Dim I As Long
    Call LoadMaps
    Call TextAdd("All maps reloaded.")
    For I = 1 To Player_HighIndex
        If IsPlaying(I) Then
            PlayerWarp I, GetPlayerMap(I), GetPlayerX(I), GetPlayerY(I)
        End If
    Next
End Sub

Private Sub cmdReloadNPCs_Click()
Dim I As Long
    Call LoadNpcs
    Call TextAdd("All npcs reloaded.")
    For I = 1 To Player_HighIndex
        If IsPlaying(I) Then
            SendNpcs I
        End If
    Next
End Sub

Private Sub cmdReloadShops_Click()
Dim I As Long
    Call LoadShops
    Call TextAdd("All shops reloaded.")
    For I = 1 To Player_HighIndex
        If IsPlaying(I) Then
            SendShops I
        End If
    Next
End Sub

Private Sub cmdReloadSpells_Click()
Dim I As Long
    Call LoadSpells
    Call TextAdd("All spells reloaded.")
    For I = 1 To Player_HighIndex
        If IsPlaying(I) Then
            SendSpells I
        End If
    Next
End Sub

Private Sub cmdReloadResources_Click()
Dim I As Long
    Call LoadResources
    Call TextAdd("All Resources reloaded.")
    For I = 1 To Player_HighIndex
        If IsPlaying(I) Then
            SendResources I
        End If
    Next
End Sub

Private Sub cmdReloadAnimations_Click()
Dim I As Long
    Call LoadAnimations
    Call TextAdd("All Animations reloaded.")
    For I = 1 To Player_HighIndex
        If IsPlaying(I) Then
            SendAnimations I
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
    End If
End Sub

Private Sub Form_Load()
    Call UsersOnline_Start
End Sub

Private Sub Form_Resize()

    If frmServer.WindowState = vbMinimized Then
        frmServer.Hide
    End If

End Sub

Private Sub Form_Unload(Cancel As Integer)
    Cancel = True
    Call DestroyServer
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
            Call GlobalMsg(txtChat.Text, Cyan)
            Call TextAdd("Server: " & txtChat.Text)
            txtChat.Text = vbNullString
        End If

        KeyAscii = 0
    End If

End Sub

Sub UsersOnline_Start()
    Dim I As Long

    For I = 1 To MAX_PLAYERS
        frmServer.lvwInfo.ListItems.Add (I)

        If I < 10 Then
            frmServer.lvwInfo.ListItems(I).Text = "00" & I
        ElseIf I < 100 Then
            frmServer.lvwInfo.ListItems(I).Text = "0" & I
        Else
            frmServer.lvwInfo.ListItems(I).Text = I
        End If

        frmServer.lvwInfo.ListItems(I).SubItems(1) = vbNullString
        frmServer.lvwInfo.ListItems(I).SubItems(2) = vbNullString
        frmServer.lvwInfo.ListItems(I).SubItems(3) = vbNullString
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
        Call ServerBanIndex(FindPlayer(Name))
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
    
        Player(FindPlayer(Name)).Org = ORG_UNDERWORLD
        Call SendPlayerData(FindPlayer(Name))
        Call PlayerMsg(FindPlayer(Name), "Você acaba entrou para a UnderWorld.", BrightCyan)
        If frmServer.chkOmitir = 0 Then
            GlobalMsg Name & " acaba de entrar para a Organização:UnderWorld!", White
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
        Call PlayerMsg(FindPlayer(Name), "Você acaba entrou para a Renegados.", BrightCyan)
        If frmServer.chkOmitir = 0 Then
            GlobalMsg Name & " acaba de entrar para a Organização:Renegados!", White
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
    Dim I As Byte
    
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
    
    If MsgBox(Name, vbYesNo) = vbNo Then Exit Sub
    
        Player(FindPlayer(Name)).Ban.Ban = NO
        Player(FindPlayer(Name)).Ban.Data = vbNullString
        Player(FindPlayer(Name)).Ban.Dias = vbNullString
        
        Call SendPlayerData(FindPlayer(Name))
        SavePlayer FindPlayer(Name)
        
        For I = 1 To Player_HighIndex
            If IsPlaying(I) Then
                If Player(I).Access > 1 Then
                    PlayerMsg I, Name & " foi desbanido !", Green
                End If
            End If
        Next
    End If

End Sub

Sub mnuBan_click()
    Dim Name As String
    Dim I As Byte
    
    Name = frmServer.lvwInfo.SelectedItem.SubItems(3)

    If Not Name = "Not Playing" Then
    
    If MsgBox(Name, vbYesNo) = vbNo Then Exit Sub
    
        Player(FindPlayer(Name)).Ban.Ban = YES
        Player(FindPlayer(Name)).Ban.Data = vbNullString
        Player(FindPlayer(Name)).Ban.Dias = vbNullString
        
        Call SendPlayerData(FindPlayer(Name))
        SavePlayer FindPlayer(Name)
        
        AlertMsg FindPlayer(Name), "Você foi BANIDO!"
        
        For I = 1 To Player_HighIndex
            If IsPlaying(I) Then
                If Player(I).Access > 1 Then
                    PlayerMsg I, Name & " foi banido !", Green
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
