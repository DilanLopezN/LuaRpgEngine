VERSION 5.00
Begin VB.Form frmVIP 
   Caption         =   "VIPS/CT"
   ClientHeight    =   5385
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   7605
   LinkTopic       =   "Form1"
   ScaleHeight     =   5385
   ScaleWidth      =   7605
   StartUpPosition =   3  'Windows Default
   Begin VB.CommandButton Command2 
      Caption         =   "Retirar CT"
      Height          =   375
      Left            =   4800
      TabIndex        =   7
      Top             =   4680
      Width           =   1335
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Retirar VIP"
      Height          =   375
      Left            =   3120
      TabIndex        =   6
      Top             =   4680
      Width           =   1455
   End
   Begin VB.TextBox txtNome 
      Height          =   285
      Left            =   240
      TabIndex        =   4
      Top             =   4920
      Width           =   2295
   End
   Begin VB.ListBox lstCT 
      Height          =   3180
      Left            =   3960
      TabIndex        =   1
      Top             =   840
      Width           =   3495
   End
   Begin VB.ListBox lstVIP 
      Height          =   3180
      Left            =   240
      TabIndex        =   0
      Top             =   840
      Width           =   3375
   End
   Begin VB.Label lblInfoVIP 
      Caption         =   "Info:Nenhum"
      Height          =   375
      Left            =   600
      TabIndex        =   8
      Top             =   4080
      Width           =   6735
   End
   Begin VB.Label Label3 
      Caption         =   "Nome:"
      Height          =   255
      Left            =   240
      TabIndex        =   5
      Top             =   4680
      Width           =   1095
   End
   Begin VB.Label Label2 
      Caption         =   "CT's"
      BeginProperty Font 
         Name            =   "Comic Sans MS"
         Size            =   18
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   4320
      TabIndex        =   3
      Top             =   120
      Width           =   2295
   End
   Begin VB.Label Label1 
      Caption         =   "VIPS Online"
      BeginProperty Font 
         Name            =   "Comic Sans MS"
         Size            =   18
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   600
      TabIndex        =   2
      Top             =   120
      Width           =   1935
   End
End
Attribute VB_Name = "frmVIP"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()
If frmVIP.txtNome.Text = vbNullString Then Exit Sub
Dim i As Long

i = FindPlayer(txtNome.Text)
If i < 1 Or i > MAX_PLAYERS Then
    lblInfoVIP.Caption = "Info: Player não ta online!"
    Exit Sub
End If

Player(i).VipData.VIP = NO
Player(i).VipData.DiasVIP = vbNullString
Player(i).VipData.DataVIP = vbNullString
PlayerMsg i, "Seu VIP Acabou!", Magenta
lblInfoVIP.Caption = "Info:SUCESSO!" & GetPlayerName(i) & " está sem VIP!"

End Sub

Private Sub Command2_Click()
If frmVIP.txtNome.Text = vbNullString Then Exit Sub
Dim i As Long

i = FindPlayer(txtNome.Text)
If i < 1 Or i > MAX_PLAYERS Then
    lblInfoVIP.Caption = "Info: Player não ta online!"
    Exit Sub
End If

Player(i).CTdata.CT = NO
Player(i).CTdata.DiasCT = vbNullString
Player(i).CTdata.DataCT = vbNullString
PlayerMsg i, "Seu Passe CT Acabou!", Magenta
lblInfoVIP.Caption = "Info:SUCESSO!" & GetPlayerName(i) & " está sem Passe CT!"
End Sub

