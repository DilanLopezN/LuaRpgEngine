VERSION 5.00
Object = "{3B7C8863-D78F-101B-B9B5-04021C009402}#1.2#0"; "richtx32.ocx"
Begin VB.Form frmChatPrivado 
   BackColor       =   &H80000007&
   Caption         =   "Chat Privado"
   ClientHeight    =   5985
   ClientLeft      =   60
   ClientTop       =   435
   ClientWidth     =   5130
   LinkTopic       =   "Form1"
   ScaleHeight     =   5985
   ScaleWidth      =   5130
   StartUpPosition =   3  'Windows Default
   Visible         =   0   'False
   Begin VB.TextBox txtTextotPrivado 
      BackColor       =   &H80000002&
      BeginProperty Font 
         Name            =   "Georgia"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   120
      TabIndex        =   2
      Text            =   "Digite aqui e aperte ENTER pra enviar"
      Top             =   5520
      Width           =   4935
   End
   Begin RichTextLib.RichTextBox txtChat 
      Height          =   4560
      Left            =   120
      TabIndex        =   3
      Top             =   720
      Width           =   4860
      _ExtentX        =   8573
      _ExtentY        =   8043
      _Version        =   393217
      BackColor       =   16777215
      BorderStyle     =   0
      ReadOnly        =   -1  'True
      ScrollBars      =   2
      Appearance      =   0
      TextRTF         =   $"frmChatPrivado.frx":0000
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
   Begin VB.Label lblChatPrivado 
      AutoSize        =   -1  'True
      BackStyle       =   0  'Transparent
      Caption         =   "Enviar MSG"
      BeginProperty Font 
         Name            =   "Georgia"
         Size            =   14.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H0000C000&
      Height          =   345
      Index           =   1
      Left            =   1680
      TabIndex        =   1
      Top             =   6000
      Width           =   1755
   End
   Begin VB.Label lblChatPrivado 
      Alignment       =   2  'Center
      AutoSize        =   -1  'True
      BackStyle       =   0  'Transparent
      Caption         =   "Player"
      BeginProperty Font 
         Name            =   "Comic Sans MS"
         Size            =   12
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFFFF&
      Height          =   345
      Index           =   0
      Left            =   2160
      TabIndex        =   0
      Top             =   120
      Width           =   735
   End
End
Attribute VB_Name = "frmChatPrivado"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Sub Form_Unload(Cancel As Integer)
    SendChat CHAT_CLOSE, ChatPlayer, vbNullString
End Sub

Private Sub lblChatPrivado_Click(Index As Integer)
Select Case Index
    Case 1 'EnviarMsg
        SendChat CHAT_MSG, ChatPlayer, frmChatPrivado.txtTextotPrivado.text
        frmChatPrivado.txtTextotPrivado.text = vbNullString
    Case Else
End Select

End Sub

Private Sub txtTextotPrivado_KeyPress(KeyAscii As Integer)

If KeyAscii = vbKeyReturn Then
    SendChat CHAT_MSG, ChatPlayer, frmChatPrivado.txtTextotPrivado.text
    frmChatPrivado.txtTextotPrivado.text = vbNullString
End If

End Sub
