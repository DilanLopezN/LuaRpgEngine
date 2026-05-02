VERSION 5.00
Begin VB.Form frmBAN 
   Caption         =   "Banir Player"
   ClientHeight    =   3090
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   4680
   LinkTopic       =   "Form1"
   ScaleHeight     =   3090
   ScaleWidth      =   4680
   StartUpPosition =   3  'Windows Default
   Visible         =   0   'False
   Begin VB.CommandButton Command1 
      Caption         =   "Enviar BAN"
      Height          =   495
      Left            =   1680
      TabIndex        =   5
      Top             =   2400
      Width           =   1335
   End
   Begin VB.TextBox txtNome 
      Height          =   375
      Left            =   120
      TabIndex        =   4
      Top             =   720
      Width           =   3135
   End
   Begin VB.TextBox txtData 
      Height          =   375
      Left            =   120
      TabIndex        =   1
      Top             =   1680
      Width           =   3135
   End
   Begin VB.CheckBox chkBanTempo 
      Caption         =   "Banir pra sempre?"
      Height          =   255
      Left            =   2520
      TabIndex        =   0
      Top             =   1320
      Width           =   1815
   End
   Begin VB.Label Label1 
      Caption         =   "Nome do player:"
      Height          =   255
      Left            =   120
      TabIndex        =   3
      Top             =   240
      Width           =   1215
   End
   Begin VB.Label lblData 
      Caption         =   "Digite a data:"
      Height          =   255
      Left            =   120
      TabIndex        =   2
      Top             =   1440
      Width           =   2055
   End
End
Attribute VB_Name = "frmBAN"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
