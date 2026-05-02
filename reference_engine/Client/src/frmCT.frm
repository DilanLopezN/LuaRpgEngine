VERSION 5.00
Begin VB.Form frmCT 
   Caption         =   "Campo de Treino"
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
      Caption         =   "Enviar"
      Height          =   735
      Left            =   1320
      TabIndex        =   4
      Top             =   1800
      Width           =   1575
   End
   Begin VB.TextBox txtNome 
      Height          =   285
      Left            =   840
      TabIndex        =   3
      Top             =   360
      Width           =   2415
   End
   Begin VB.TextBox txtData 
      Height          =   285
      Left            =   840
      TabIndex        =   2
      Top             =   840
      Width           =   2655
   End
   Begin VB.Label Label2 
      Caption         =   "Data:"
      Height          =   255
      Left            =   240
      TabIndex        =   1
      Top             =   840
      Width           =   495
   End
   Begin VB.Label Label1 
      Caption         =   "Nome:"
      Height          =   255
      Left            =   240
      TabIndex        =   0
      Top             =   360
      Width           =   615
   End
End
Attribute VB_Name = "frmCT"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
