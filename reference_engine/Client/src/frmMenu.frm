VERSION 5.00
Begin VB.Form frmMenu 
   BackColor       =   &H00E0E0E0&
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   7455
   ClientLeft      =   45
   ClientTop       =   375
   ClientWidth     =   10725
   BeginProperty Font 
      Name            =   "Verdana"
      Size            =   8.25
      Charset         =   0
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   Icon            =   "frmMenu.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   Picture         =   "frmMenu.frx":324A
   ScaleHeight     =   497
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   715
   StartUpPosition =   2  'CenterScreen
   Visible         =   0   'False
   Begin VB.PictureBox picMain 
      AutoSize        =   -1  'True
      BackColor       =   &H00C0C0C0&
      BorderStyle     =   0  'None
      Height          =   5250
      Left            =   2760
      Picture         =   "frmMenu.frx":2255D
      ScaleHeight     =   5250
      ScaleWidth      =   5250
      TabIndex        =   60
      Top             =   1920
      Visible         =   0   'False
      Width           =   5250
      Begin VB.Label lblNews 
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
         Left            =   120
         TabIndex        =   62
         Top             =   4560
         Width           =   5055
      End
      Begin VB.Label lblBack 
         BackStyle       =   0  'Transparent
         Caption         =   "X"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H000000FF&
         Height          =   375
         Index           =   4
         Left            =   4920
         TabIndex        =   61
         Top             =   120
         Width           =   375
      End
   End
   Begin VB.PictureBox picCharacter 
      AutoSize        =   -1  'True
      BackColor       =   &H00C0C0C0&
      BorderStyle     =   0  'None
      Height          =   5250
      Left            =   2760
      Picture         =   "frmMenu.frx":3F226
      ScaleHeight     =   350
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   350
      TabIndex        =   16
      Top             =   1920
      Visible         =   0   'False
      Width           =   5250
      Begin VB.PictureBox picElemento 
         Height          =   735
         Left            =   3360
         ScaleHeight     =   675
         ScaleWidth      =   675
         TabIndex        =   32
         Top             =   2520
         Width           =   735
      End
      Begin VB.PictureBox picVila 
         Height          =   735
         Left            =   960
         ScaleHeight     =   675
         ScaleWidth      =   675
         TabIndex        =   27
         Top             =   2520
         Width           =   735
      End
      Begin VB.PictureBox picSprite 
         AutoRedraw      =   -1  'True
         BackColor       =   &H00000000&
         BorderStyle     =   0  'None
         Height          =   720
         Left            =   4320
         ScaleHeight     =   48
         ScaleMode       =   3  'Pixel
         ScaleWidth      =   32
         TabIndex        =   26
         Top             =   960
         Width           =   480
      End
      Begin VB.ComboBox cmbClass 
         Appearance      =   0  'Flat
         BackColor       =   &H00FFFFFF&
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
         Height          =   330
         Left            =   1200
         Style           =   2  'Dropdown List
         TabIndex        =   20
         Top             =   1200
         Width           =   2175
      End
      Begin VB.OptionButton optMale 
         Appearance      =   0  'Flat
         BackColor       =   &H00000000&
         Caption         =   "Male"
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
         Left            =   0
         TabIndex        =   19
         Top             =   0
         Value           =   -1  'True
         Visible         =   0   'False
         Width           =   975
      End
      Begin VB.OptionButton optFemale 
         Appearance      =   0  'Flat
         BackColor       =   &H00000000&
         Caption         =   "Female"
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
         Left            =   -120
         TabIndex        =   18
         Top             =   240
         Visible         =   0   'False
         Width           =   1095
      End
      Begin VB.TextBox txtCName 
         Appearance      =   0  'Flat
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
         Height          =   225
         Left            =   1200
         MaxLength       =   12
         TabIndex        =   21
         Top             =   840
         Width           =   2775
      End
      Begin VB.Label lblBack 
         BackStyle       =   0  'Transparent
         Caption         =   "X"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H000000FF&
         Height          =   375
         Index           =   0
         Left            =   4920
         TabIndex        =   50
         Top             =   120
         Width           =   375
      End
      Begin VB.Label Label6 
         BackStyle       =   0  'Transparent
         Caption         =   "Elemento:"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   375
         Left            =   2760
         TabIndex        =   36
         Top             =   2040
         Width           =   1095
      End
      Begin VB.Label lblElemento 
         BackStyle       =   0  'Transparent
         Caption         =   "Fogo"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   12
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   375
         Left            =   4080
         TabIndex        =   35
         Top             =   2040
         Width           =   975
      End
      Begin VB.Label Label5 
         BackStyle       =   0  'Transparent
         Caption         =   ">"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   18
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   735
         Left            =   4200
         TabIndex        =   34
         Top             =   2400
         Width           =   375
      End
      Begin VB.Label Label1 
         BackStyle       =   0  'Transparent
         Caption         =   "<"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   18
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   495
         Left            =   3000
         TabIndex        =   33
         Top             =   2400
         Width           =   255
      End
      Begin VB.Label Label4 
         BackStyle       =   0  'Transparent
         Caption         =   ">"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   18
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   375
         Left            =   1800
         TabIndex        =   31
         Top             =   2400
         Width           =   255
      End
      Begin VB.Label Label3 
         BackStyle       =   0  'Transparent
         Caption         =   "<"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   18
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FFFFFF&
         Height          =   375
         Left            =   600
         TabIndex        =   30
         Top             =   2400
         Width           =   255
      End
      Begin VB.Label lblVila 
         BackStyle       =   0  'Transparent
         Caption         =   "Konoha"
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
         Height          =   255
         Left            =   1200
         TabIndex        =   29
         Top             =   2040
         Width           =   855
      End
      Begin VB.Label Label2 
         BackStyle       =   0  'Transparent
         Caption         =   "Vila:"
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
         Left            =   360
         TabIndex        =   28
         Top             =   2040
         Width           =   495
      End
      Begin VB.Label lblSprite 
         Alignment       =   2  'Center
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "[ Change Sprite ]"
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
         Left            =   2760
         TabIndex        =   25
         Top             =   120
         Visible         =   0   'False
         Width           =   2775
      End
      Begin VB.Label lblBlank 
         Alignment       =   1  'Right Justify
         BackStyle       =   0  'Transparent
         Caption         =   "Gender:"
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
         Index           =   5
         Left            =   -600
         TabIndex        =   24
         Top             =   3240
         Visible         =   0   'False
         Width           =   1095
      End
      Begin VB.Label lblBlank 
         Alignment       =   1  'Right Justify
         BackStyle       =   0  'Transparent
         Caption         =   "Clãn:"
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
         Index           =   4
         Left            =   240
         TabIndex        =   23
         Top             =   1200
         Width           =   735
      End
      Begin VB.Label lblBlank 
         Alignment       =   1  'Right Justify
         BackStyle       =   0  'Transparent
         Caption         =   "Nome:"
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
         Index           =   2
         Left            =   240
         TabIndex        =   22
         Top             =   840
         Width           =   735
      End
      Begin VB.Label lblCAccept 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Criar"
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
         Left            =   2040
         TabIndex        =   17
         Top             =   4440
         Width           =   1215
      End
   End
   Begin VB.PictureBox picRegister 
      AutoSize        =   -1  'True
      BackColor       =   &H00C0C0C0&
      BorderStyle     =   0  'None
      Height          =   5250
      Left            =   2760
      Picture         =   "frmMenu.frx":40C00
      ScaleHeight     =   350
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   350
      TabIndex        =   7
      Top             =   1920
      Visible         =   0   'False
      Width           =   5250
      Begin VB.TextBox txtSenhaSecreta 
         Appearance      =   0  'Flat
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
         Height          =   225
         IMEMode         =   3  'DISABLE
         Left            =   1080
         MaxLength       =   18
         PasswordChar    =   "•"
         TabIndex        =   44
         Top             =   2640
         Width           =   2775
      End
      Begin VB.TextBox txtRPass2 
         Appearance      =   0  'Flat
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
         Height          =   225
         IMEMode         =   3  'DISABLE
         Left            =   1080
         MaxLength       =   18
         PasswordChar    =   "•"
         TabIndex        =   13
         Top             =   2160
         Width           =   2775
      End
      Begin VB.TextBox txtRPass 
         Appearance      =   0  'Flat
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
         Height          =   225
         IMEMode         =   3  'DISABLE
         Left            =   1080
         MaxLength       =   18
         PasswordChar    =   "•"
         TabIndex        =   10
         Top             =   1680
         Width           =   2775
      End
      Begin VB.TextBox txtRUser 
         Appearance      =   0  'Flat
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
         Height          =   225
         Left            =   1080
         MaxLength       =   12
         TabIndex        =   8
         Top             =   1200
         Width           =   2775
      End
      Begin VB.Label lblBack 
         BackStyle       =   0  'Transparent
         Caption         =   "X"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H000000FF&
         Height          =   375
         Index           =   1
         Left            =   4920
         TabIndex        =   51
         Top             =   120
         Width           =   375
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Senha Secreta:"
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
         Height          =   495
         Index           =   6
         Left            =   120
         TabIndex        =   45
         Top             =   2520
         Width           =   855
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Repetir:"
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
         Index           =   11
         Left            =   120
         TabIndex        =   14
         Top             =   2160
         Width           =   855
      End
      Begin VB.Label txtRAccept 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Criar"
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
         Left            =   1800
         TabIndex        =   12
         Top             =   3120
         Width           =   1215
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Senha:"
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
         Index           =   9
         Left            =   120
         TabIndex        =   11
         Top             =   1680
         Width           =   735
      End
      Begin VB.Label lblBlank 
         BackStyle       =   0  'Transparent
         Caption         =   "Usuário:"
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
         Index           =   8
         Left            =   120
         TabIndex        =   9
         Top             =   1200
         Width           =   975
      End
   End
   Begin VB.PictureBox picLogin 
      AutoSize        =   -1  'True
      BackColor       =   &H00C0C0C0&
      BorderStyle     =   0  'None
      BeginProperty Font 
         Name            =   "Tahoma"
         Size            =   9.75
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   5250
      Left            =   2760
      Picture         =   "frmMenu.frx":423FA
      ScaleHeight     =   350
      ScaleMode       =   0  'User
      ScaleWidth      =   350
      TabIndex        =   0
      Top             =   1920
      Visible         =   0   'False
      Width           =   5250
      Begin VB.TextBox txtNewPass 
         BorderStyle     =   0  'None
         Height          =   225
         Left            =   2280
         MaxLength       =   18
         TabIndex        =   42
         Top             =   2760
         Visible         =   0   'False
         Width           =   2775
      End
      Begin VB.CheckBox chkPass 
         Appearance      =   0  'Flat
         BackColor       =   &H00404040&
         Caption         =   "Salvar Senha?"
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
         TabIndex        =   5
         Top             =   3240
         Width           =   1815
      End
      Begin VB.TextBox txtLPass 
         Appearance      =   0  'Flat
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
         ForeColor       =   &H00000000&
         Height          =   225
         IMEMode         =   3  'DISABLE
         Left            =   2280
         MaxLength       =   20
         PasswordChar    =   "•"
         TabIndex        =   3
         Top             =   2280
         Width           =   2775
      End
      Begin VB.TextBox txtLUser 
         Appearance      =   0  'Flat
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
         ForeColor       =   &H00000000&
         Height          =   225
         Left            =   2280
         MaxLength       =   12
         TabIndex        =   1
         Top             =   1800
         Width           =   2775
      End
      Begin VB.Label Label11 
         BackStyle       =   0  'Transparent
         Caption         =   "Alterar Secreta?"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FF8080&
         Height          =   255
         Left            =   2880
         TabIndex        =   59
         Top             =   960
         Width           =   1695
      End
      Begin VB.Label Label10 
         BackStyle       =   0  'Transparent
         Caption         =   "Recuperar Senha?"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FF8080&
         Height          =   255
         Left            =   2880
         TabIndex        =   58
         Top             =   600
         Width           =   1815
      End
      Begin VB.Label lblRecuperarSenha 
         BackStyle       =   0  'Transparent
         Caption         =   "Recuperar Senha"
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
         Left            =   1800
         TabIndex        =   57
         Top             =   3600
         Visible         =   0   'False
         Width           =   1815
      End
      Begin VB.Label lblMudarSsecreta 
         BackStyle       =   0  'Transparent
         Caption         =   "Mudar senha SECRETA"
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
         Left            =   1560
         TabIndex        =   56
         Top             =   3600
         Visible         =   0   'False
         Width           =   2295
      End
      Begin VB.Label lblKikarConta 
         BackStyle       =   0  'Transparent
         Caption         =   "Kikar"
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
         Left            =   2400
         TabIndex        =   55
         Top             =   3600
         Visible         =   0   'False
         Width           =   615
      End
      Begin VB.Label Label8 
         BackStyle       =   0  'Transparent
         Caption         =   "Kikar Conta"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FF8080&
         Height          =   255
         Left            =   120
         TabIndex        =   54
         Top             =   600
         Width           =   1455
      End
      Begin VB.Label lblBack 
         BackStyle       =   0  'Transparent
         Caption         =   "X"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H000000FF&
         Height          =   375
         Index           =   2
         Left            =   4920
         TabIndex        =   52
         Top             =   120
         Width           =   375
      End
      Begin VB.Label lblMudarSnormal 
         BackStyle       =   0  'Transparent
         Caption         =   "Alterar senha"
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
         Left            =   2040
         TabIndex        =   43
         Top             =   3600
         Visible         =   0   'False
         Width           =   1455
      End
      Begin VB.Label lblSenha2 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Nova Senha:"
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
         Left            =   0
         TabIndex        =   41
         Top             =   2760
         Visible         =   0   'False
         Width           =   2175
      End
      Begin VB.Label Label9 
         BackStyle       =   0  'Transparent
         Caption         =   "Alterar Senha normal?"
         BeginProperty Font 
            Name            =   "Georgia"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H00FF8080&
         Height          =   255
         Left            =   120
         TabIndex        =   40
         Top             =   960
         Width           =   2295
      End
      Begin VB.Label lblLAccept 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Entrar"
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
         Left            =   2160
         TabIndex        =   6
         Top             =   3600
         Width           =   1215
      End
      Begin VB.Label lblBlank 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Senha:"
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
         Index           =   3
         Left            =   240
         TabIndex        =   4
         Top             =   2280
         Width           =   1935
      End
      Begin VB.Label lblBlank 
         Alignment       =   2  'Center
         BackStyle       =   0  'Transparent
         Caption         =   "Usuário:"
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
         Index           =   0
         Left            =   120
         TabIndex        =   2
         Top             =   1800
         Width           =   2055
      End
   End
   Begin VB.PictureBox picCredits 
      AutoSize        =   -1  'True
      BackColor       =   &H00C0C0C0&
      BorderStyle     =   0  'None
      Height          =   5250
      Left            =   2760
      Picture         =   "frmMenu.frx":438A7
      ScaleHeight     =   5250
      ScaleWidth      =   5250
      TabIndex        =   15
      Top             =   1920
      Visible         =   0   'False
      Width           =   5250
      Begin VB.Label lblBack 
         BackStyle       =   0  'Transparent
         Caption         =   "X"
         BeginProperty Font 
            Name            =   "Comic Sans MS"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H000000FF&
         Height          =   375
         Index           =   3
         Left            =   4920
         TabIndex        =   53
         Top             =   120
         Width           =   375
      End
   End
   Begin VB.Label lblFaceBook 
      BackStyle       =   0  'Transparent
      Height          =   735
      Left            =   9360
      TabIndex        =   49
      Top             =   4320
      Width           =   735
   End
   Begin VB.Label lblTermos 
      BackStyle       =   0  'Transparent
      BeginProperty Font 
         Name            =   "Georgia"
         Size            =   11.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H00FFFF80&
      Height          =   615
      Left            =   0
      TabIndex        =   48
      Top             =   6960
      Width           =   10695
   End
   Begin VB.Label lblOrkut 
      BackStyle       =   0  'Transparent
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
      Height          =   135
      Left            =   0
      TabIndex        =   47
      Top             =   1080
      Width           =   15
   End
   Begin VB.Label lblSite 
      BackStyle       =   0  'Transparent
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
      Height          =   735
      Left            =   8520
      TabIndex        =   46
      Top             =   4320
      Width           =   735
   End
   Begin VB.Image imgButton 
      Height          =   975
      Index           =   3
      Left            =   7560
      Top             =   3240
      Width           =   2895
   End
   Begin VB.Image imgButton 
      Height          =   855
      Index           =   2
      Left            =   240
      Top             =   4440
      Width           =   3255
   End
   Begin VB.Image imgButton 
      Height          =   975
      Index           =   1
      Left            =   360
      Top             =   2160
      Width           =   3015
   End
   Begin VB.Label lblPlayersOn 
      BackStyle       =   0  'Transparent
      Caption         =   "PlayersOnline:Nenhum"
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
      Height          =   375
      Left            =   8160
      TabIndex        =   39
      Top             =   6600
      Width           =   2775
   End
   Begin VB.Label lblStatus 
      BackStyle       =   0  'Transparent
      Caption         =   "Offline"
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
      Height          =   375
      Left            =   720
      TabIndex        =   38
      Top             =   6600
      Width           =   975
   End
   Begin VB.Label Label7 
      BackStyle       =   0  'Transparent
      Caption         =   "Status:"
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
      Left            =   0
      TabIndex        =   37
      Top             =   6600
      Width           =   735
   End
   Begin VB.Image imgButton 
      Height          =   465
      Index           =   4
      Left            =   9960
      Picture         =   "frmMenu.frx":48AE4
      Top             =   0
      Visible         =   0   'False
      Width           =   450
   End
End
Attribute VB_Name = "frmMenu"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub cmbClass_Click()
    newCharClass = cmbClass.ListIndex
    newCharSprite = 0
    NewCharacterBltSprite
    
    If cmbClass.ListIndex + 1 >= SAI Then
        MsgBox "Este é um char ganho com doação. Visite o site ohyehgames.com"
        cmbClass.ListIndex = 0
        newCharClass = 0
        newCharSprite = 0
        NewCharacterBltSprite
    End If
    
End Sub

Private Sub Form_Activate()
Village = 1
picVila.Picture = LoadPicture(App.Path & "\data files\graphics\Vilas\1.jpg")
lblVila.Caption = "Konoha"
lblVila.ForeColor = &HFF&

ElementoNum = 1
picElemento.Picture = LoadPicture(App.Path & "\data files\graphics\elementos\1.jpg")
lblElemento.Caption = "Fogo"
lblElemento.ForeColor = &HFF&


If Player_HighIndex > 0 Then
    lblPlayersOn.Caption = "Players Online:" & Player_HighIndex
Else
    lblPlayersOn.Caption = "Players Online:Nenhum"
End If

If ConnectToServer(1) Then
    frmMenu.lblStatus.Caption = "Online"
    frmMenu.lblStatus.ForeColor = &H8000&
End If

End Sub

Private Sub Form_Load()
    Dim tmpTxt As String, tmpArray() As String, i As Long

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    ' general menu stuff
    Me.Caption = Options.Game_Name
    
    ' load news
    'Open App.Path & "\data files\news.txt" For Input As #1
        'Line Input #1, tmpTxt
    'Close #1
    ' split breaks
    'tmpArray() = Split(tmpTxt, "<br />")
    'lblNews.Caption = vbNullString
    'For i = 0 To UBound(tmpArray)
        'lblNews.Caption = lblNews.Caption & tmpArray(i) & vbNewLine
    'Next

    ' Load the username + pass
    txtLUser.text = Trim$(Options.Username)
    If Options.SavePass = 1 Then
        txtLPass.text = Trim$(Options.Password)
        chkPass.value = Options.SavePass
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "Form_Load", "frmMenu", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub Form_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    resetButtons_Menu
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "Form_MouseMove", "frmMenu", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub Form_Unload(Cancel As Integer)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    If Not EnteringGame Then DestroyGame
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "Form_Unload", "frmMenu", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub imgButton_Click(Index As Integer)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    Select Case Index
        Case 1
            If Not picLogin.Visible Then
                picMain.Visible = True
                
                ' destroy socket, change visiblity
                DestroyTCP
                picCredits.Visible = False
                picLogin.Visible = True
                picRegister.Visible = False
                picCharacter.Visible = False
                'picMain.Visible = False
                ' play sound
                PlaySound Sound_ButtonClick
            End If
        Case 2
            If Not picRegister.Visible Then
                picMain.Visible = True
                ' destroy socket, change visiblity
                DestroyTCP
                picCredits.Visible = False
                picLogin.Visible = False
                picRegister.Visible = True
                picCharacter.Visible = False
                'picMain.Visible = False
                ' play sound
                PlaySound Sound_ButtonClick
            End If
        Case 3
            If Not picCredits.Visible Then
                ' destroy socket, change visiblity
                DestroyTCP
                picCredits.Visible = True
                picLogin.Visible = False
                picRegister.Visible = False
                picCharacter.Visible = False
                picMain.Visible = False
                ' play sound
                PlaySound Sound_ButtonClick
            End If
        Case 4
            Call DestroyGame
    End Select
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "imgButton_Click", "frmMenu", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub imgButton_MouseDown(Index As Integer, Button As Integer, Shift As Integer, X As Single, Y As Single)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    ' reset other buttons
    'resetButtons_Menu Index
    
    ' change the button we're hovering on
    'changeButtonState_Menu Index, 2 ' clicked
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "imgButton_MouseDown", "frmMenu", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub imgButton_MouseMove(Index As Integer, Button As Integer, Shift As Integer, X As Single, Y As Single)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    ' reset other buttons
    'resetButtons_Menu Index
    
    ' change the button we're hovering on
    'If Not MenuButton(Index).state = 2 Then ' make sure we're not clicking
        'changeButtonState_Menu Index, 1 ' hover
    'End If
    
    ' play sound
    If Not LastButtonSound_Menu = Index Then
        PlaySound Sound_ButtonHover
        LastButtonSound_Menu = Index
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "imgButton_MouseMove", "frmMenu", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub imgButton_MouseUp(Index As Integer, Button As Integer, Shift As Integer, X As Single, Y As Single)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
        
    ' reset all buttons
    'resetButtons_Menu -1
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "imgButton_MouseUp", "frmMenu", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub Label1_Click()
If ElementoNum = 1 Then
ElementoNum = 5
Else
ElementoNum = ElementoNum - 1
End If
picElemento.Picture = LoadPicture(App.Path & "\data files\graphics\elementos\" & ElementoNum & ".jpg")

If ElementoNum = 1 Then
    lblElemento.Caption = "Fogo"
    lblElemento.ForeColor = &HFF&
ElseIf ElementoNum = 2 Then
    lblElemento.Caption = "Vento"
    lblElemento.ForeColor = &HFFFFFF
ElseIf ElementoNum = 3 Then
    lblElemento.Caption = "Água"
    lblElemento.ForeColor = &HC0C000
ElseIf ElementoNum = 4 Then
    lblElemento.Caption = "Terra"
    lblElemento.ForeColor = &HC0C0C0
ElseIf ElementoNum = 5 Then
    lblElemento.Caption = "Raio"
    lblElemento.ForeColor = &HFFC0C0
End If
End Sub

Private Sub Label10_Click()

If MsgBox("Deseja recuperar senha atual usando a secreta?", vbYesNo) = vbYes Then
    txtNewPass.Visible = False
    'lblSenha2.Caption = "Senha secreta:"
    lblSenha2.Visible = False
    chkPass.Visible = False
    lblLAccept.Visible = False
    lblMudarSnormal.Visible = False
    lblKikarConta.Visible = False
    lblMudarSsecreta.Visible = False
    lblRecuperarSenha.Visible = True
    lblBlank(3).Caption = "Senha Secreta:"
    txtLPass.Visible = True
Else
    lblSenha2.Visible = False
    txtNewPass.Visible = False
    chkPass.Visible = True
    lblLAccept.Visible = True
    lblMudarSnormal.Visible = False
    lblKikarConta.Visible = False
    lblMudarSsecreta.Visible = False
    lblRecuperarSenha.Visible = False
    lblBlank(3).Caption = "Senha:"
    txtLPass.Visible = True
End If

End Sub

Private Sub Label11_Click()
MsgBox "Muita ATENÇÃO: A senha secreta é a chave da conta,tenha certeza absoluta de que queira mudar.", vbExclamation
MsgBox "Se quizer mesmo mudar,NÃO coloque senha fácil mas precisa ser algo que você não se esqueça e que NINGUEM saiba. Tire uma print e anote em um caderno só por precaução.", vbExclamation

If MsgBox("Deseja realmente mudar a senha SECRETA?", vbYesNo) = vbYes Then
    txtNewPass.Visible = True
    lblBlank(3).Caption = "Secreta Atual:"
    lblSenha2.Caption = "Nova senha SECRETA:"
    lblSenha2.Visible = True
    chkPass.Visible = False
    lblLAccept.Visible = False
    lblMudarSnormal.Visible = False
    lblKikarConta.Visible = False
    lblMudarSsecreta.Visible = True
    lblRecuperarSenha.Visible = False
Else
    lblSenha2.Visible = False
    txtNewPass.Visible = False
    chkPass.Visible = True
    lblLAccept.Visible = True
    lblMudarSnormal.Visible = False
    lblKikarConta.Visible = False
    lblMudarSsecreta.Visible = False
    lblRecuperarSenha.Visible = False
    lblBlank(3).Caption = "Senha:"
    txtLPass.Visible = True
End If
End Sub

Private Sub LblMudarSnormal_Click()
      ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    SenhaSecreta = InputBox("Digite a Senha Secreta!", "Senha Secreta")
    If isLoginLegal(txtLUser.text, txtLPass.text) Then
        Call MenuState(MENU_STATE_CHANGEPASS)
    End If

    ' Error handler
    Exit Sub
errorhandler:
    HandleError "lblChangePass", "frmMenu", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub LblKikarConta_Click()
' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    If isLoginLegal(txtLUser.text, txtLPass.text) Then
        Call MenuState(MENU_STATE_KICK)
    End If

    ' Error handler
    Exit Sub
errorhandler:
    HandleError "lblKikarConta", "frmMenu", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub Label3_Click()
If Village = 1 Then
Village = 5
Else
Village = Village - 1
End If
picVila.Picture = LoadPicture(App.Path & "\data files\graphics\Vilas\" & Village & ".jpg")

If Village = 1 Then
    lblVila.Caption = "Konoha"
    lblVila.ForeColor = &HFF&
ElseIf Village = 2 Then
    lblVila.Caption = "Suna"
    lblVila.ForeColor = &HC0E0FF
ElseIf Village = 3 Then
    lblVila.Caption = "Kiri"
    lblVila.ForeColor = &HC0C000
ElseIf Village = 4 Then
    lblVila.Caption = "Iwa"
    lblVila.ForeColor = &HC0C0C0
ElseIf Village = 5 Then
    lblVila.Caption = "Kumo"
    lblVila.ForeColor = &HE0E0E0
End If

End Sub

Private Sub Label4_Click()

If Village = 5 Then
Village = 1
Else
Village = Village + 1
End If
picVila.Picture = LoadPicture(App.Path & "\data files\graphics\Vilas\" & Village & ".jpg")

If Village = 1 Then
    lblVila.Caption = "Konoha"
    lblVila.ForeColor = &HFF&
ElseIf Village = 2 Then
    lblVila.Caption = "Suna"
    lblVila.ForeColor = &HC0E0FF
ElseIf Village = 3 Then
    lblVila.Caption = "Kiri"
    lblVila.ForeColor = &HC0C000
ElseIf Village = 4 Then
    lblVila.Caption = "Iwa"
    lblVila.ForeColor = &HC0C0C0
ElseIf Village = 5 Then
    lblVila.Caption = "Kumo"
    lblVila.ForeColor = &HE0E0E0
End If

End Sub

Private Sub Label5_Click()
If ElementoNum = 5 Then
ElementoNum = 1
Else
ElementoNum = ElementoNum + 1
End If
picElemento.Picture = LoadPicture(App.Path & "\data files\graphics\elementos\" & ElementoNum & ".jpg")

If ElementoNum = 1 Then
    lblElemento.Caption = "Fogo"
    lblElemento.ForeColor = &HFF&
ElseIf ElementoNum = 2 Then
    lblElemento.Caption = "Vento"
    lblElemento.ForeColor = &HFFFFFF
ElseIf ElementoNum = 3 Then
    lblElemento.Caption = "Água"
    lblElemento.ForeColor = &HC0C000
ElseIf ElementoNum = 4 Then
    lblElemento.Caption = "Terra"
    lblElemento.ForeColor = &HC0C0C0
ElseIf ElementoNum = 5 Then
    lblElemento.Caption = "Raio"
    lblElemento.ForeColor = &HFFC0C0
End If
End Sub

Private Sub Label8_Click()
If MsgBox("Use essa função caso sua conta esteja dando 'Multiple account'. Coloque o login,senha e clique em 'Kikar'", vbYesNo) = vbYes Then
    lblKikarConta.Visible = True
    lblLAccept.Visible = False
    lblSenha2.Visible = False
    lblMudarSnormal.Visible = False
    txtNewPass.Visible = False
    lblMudarSsecreta.Visible = False
    lblRecuperarSenha.Visible = False
    lblBlank(3).Caption = "Senha:"
Else
    lblKikarConta.Visible = False
    lblLAccept.Visible = True
    lblSenha2.Visible = False
    lblMudarSnormal.Visible = False
    txtNewPass.Visible = False
    lblMudarSsecreta.Visible = False
    lblRecuperarSenha.Visible = False
    lblBlank(3).Caption = "Senha:"
    txtLPass.Visible = True
End If

End Sub

Private Sub Label9_Click()

If MsgBox("Deseja trocar senha?", vbYesNo) = vbYes Then
    lblSenha2.Caption = "Nova senha:"
    lblSenha2.Visible = True
    txtNewPass.Visible = True
    chkPass.Visible = False
    lblLAccept.Visible = False
    lblMudarSnormal.Visible = True
    lblKikarConta.Visible = False
    lblMudarSsecreta.Visible = False
    lblRecuperarSenha.Visible = False
    lblBlank(3).Caption = "Senha:"
Else
    lblSenha2.Visible = False
    txtNewPass.Visible = False
    chkPass.Visible = True
    lblLAccept.Visible = True
    lblMudarSnormal.Visible = False
    lblKikarConta.Visible = False
    lblMudarSsecreta.Visible = False
    lblRecuperarSenha.Visible = False
    lblBlank(3).Caption = "Senha:"
    txtLPass.Visible = True
End If

End Sub

Private Sub lblBack_Click(Index As Integer)
If Index <> 4 Then
    picRegister.Visible = False
    picLogin.Visible = False
    picCredits.Visible = False
    picCharacter.Visible = False
Else
    picMain.Visible = False
End If

End Sub

Private Sub lblFaceBook_Click()
GoToWebsite "http://www.facebook.com/ohyehgames"
End Sub

Private Sub lblLAccept_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    If isLoginLegal(txtLUser.text, txtLPass.text) Then
        Call MenuState(MENU_STATE_LOGIN)
    End If

    ' Error handler
    Exit Sub
errorhandler:
    HandleError "lblLAccept_Click", "frmMenu", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub


Private Sub lblMudarSsecreta_Click()

If isLoginLegal(txtLUser.text, txtLPass.text) = False Then
    MsgBox "Usuário ou senha secreta nova inválidos."
    Exit Sub
End If

If isLoginLegal(txtLUser.text, txtLUser.text) = False Or LenB(Trim$(txtNewPass.text)) < 1 Then
    MsgBox "Usuário ou senha secreta nova inválidos."
    Exit Sub
End If

If ConnectToServer(1) Then
    SendChangeSecretPass txtLUser.text, txtLPass.text, txtNewPass.text
End If

    lblSenha2.Visible = False
    txtNewPass.Visible = False
    chkPass.Visible = True
    lblLAccept.Visible = True
    lblMudarSnormal.Visible = False
    lblKikarConta.Visible = False
    lblMudarSsecreta.Visible = False
    lblRecuperarSenha.Visible = False
    lblBlank(3).Caption = "Senha:"
    txtLPass.Visible = True
End Sub

Private Sub lblNews_Click()
picMain.Visible = False
GoToWebsite "http://ohyehgames.com/NIP-TermosRegras.html"
End Sub

Private Sub lblOrkut_Click()
MsgBox "Orkut desativado.Use a pagina do facebook"

End Sub



Private Sub lblRecuperarSenha_Click()
If isLoginLegal(txtLUser.text, txtLUser.text) = False Or LenB(Trim$(txtLPass.text)) < 1 Then
    MsgBox "Usuário ou senha secreta inválidos."
    Exit Sub
End If

If ConnectToServer(1) Then
    SendGetPass txtLUser.text, txtLPass.text
End If

    lblSenha2.Visible = False
    txtNewPass.Visible = False
    chkPass.Visible = True
    lblLAccept.Visible = True
    lblMudarSnormal.Visible = False
    lblKikarConta.Visible = False
    lblMudarSsecreta.Visible = False
    lblRecuperarSenha.Visible = False
    lblBlank(3).Caption = "Senha:"
    txtLPass.Visible = True
End Sub

Private Sub lblSite_Click()
GoToWebsite "http://ohyehgames.com/"
End Sub

Private Sub lblSprite_Click()
Dim spritecount As Long
    
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    If optMale.value Then
        spritecount = UBound(Class(cmbClass.ListIndex + 1).MaleSprite)
    Else
        spritecount = UBound(Class(cmbClass.ListIndex + 1).FemaleSprite)
    End If

    If newCharSprite >= spritecount Then
        newCharSprite = 0
    Else
        newCharSprite = newCharSprite + 1
    End If
    
    NewCharacterBltSprite
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "lblSprite_Click", "frmMenu", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub lblTermos_Click()
GoToWebsite "http://ohyehgames.com/NIP-TermosRegras.html"
End Sub

Private Sub optFemale_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    newCharClass = cmbClass.ListIndex
    newCharSprite = 0
    NewCharacterBltSprite
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "optFemale_Click", "frmMenu", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub optMale_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    newCharClass = cmbClass.ListIndex
    newCharSprite = 0
    NewCharacterBltSprite
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "optMale_Click", "frmMenu", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub picCharacter_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    resetButtons_Menu
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picCharacter_MouseMove", "frmMenu", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub picCredits_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    resetButtons_Menu
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picCredits_MouseMove", "frmMenu", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub picLogin_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    resetButtons_Menu
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picLogin_MouseMove", "frmMenu", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub picMain_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    resetButtons_Menu
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picMain_MouseMove", "frmMenu", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub picRegister_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    resetButtons_Menu
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "picRegister_MouseMove", "frmMenu", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' Register
Private Sub txtRAccept_Click()
    Dim name As String
    Dim Password As String
    Dim PasswordAgain As String
    
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    name = Trim$(txtRUser.text)
    Password = Trim$(txtRPass.text)
    PasswordAgain = Trim$(txtRPass2.text)
    SenhaSecreta = txtSenhaSecreta.text
    SenhaSecreta2 = InputBox("Repita denovo a Senha Secreta!", "Repetir Senha Secreta")
    If isLoginLegal(name, Password) Then
        If Password <> PasswordAgain Then
            Call MsgBox("Passwords don't match.")
            Exit Sub
        End If
        
        If Not SenhaSecreta = SenhaSecreta2 Then
            MsgBox "Senhas Secretas não combinam!"
            Exit Sub
        End If

        If Not isStringLegal(name) Then
            Exit Sub
        End If

        Call MenuState(MENU_STATE_NEWACCOUNT)
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "txtRAccept_Click", "frmMenu", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' New Char
Private Sub lblCAccept_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    If Not isStringLegal(txtCName.text) Then Exit Sub
    
    'previnir GM no nick
    If InStr(txtCName.text, "gm") Or InStr(txtCName.text, "Gm") Or InStr(txtCName.text, "GM") Or InStr(txtCName.text, "gM") Then
        MsgBox "Não use GM no nick!"
        Exit Sub
    End If
    
    Call MenuState(MENU_STATE_ADDCHAR)
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "lblCAccept_Click", "frmMenu", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub
