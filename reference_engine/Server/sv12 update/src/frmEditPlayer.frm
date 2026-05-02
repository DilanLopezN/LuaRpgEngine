VERSION 5.00
Begin VB.Form frmMain 
   BorderStyle     =   4  'Fixed ToolWindow
   Caption         =   "Eclipse Origins Account Editor v1.3"
   ClientHeight    =   9990
   ClientLeft      =   105
   ClientTop       =   315
   ClientWidth     =   9840
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   9990
   ScaleWidth      =   9840
   ShowInTaskbar   =   0   'False
   StartUpPosition =   3  'Windows Default
   Begin VB.Frame fraExtra 
      Caption         =   "Extras"
      Height          =   1935
      Left            =   120
      TabIndex        =   68
      Top             =   6120
      Width           =   4215
      Begin VB.TextBox txtRank 
         Height          =   285
         Left            =   1920
         TabIndex        =   74
         Top             =   600
         Width           =   735
      End
      Begin VB.TextBox txtVila 
         Height          =   285
         Left            =   1920
         TabIndex        =   72
         Top             =   960
         Width           =   735
      End
      Begin VB.TextBox txtVIP 
         Height          =   285
         Left            =   600
         TabIndex        =   69
         Top             =   240
         Width           =   975
      End
      Begin VB.Label lblVila 
         Caption         =   "Vila:Nenhuma"
         Height          =   255
         Left            =   120
         TabIndex        =   73
         Top             =   960
         Width           =   1695
      End
      Begin VB.Label lblRank 
         Caption         =   "Rank:Nenhum"
         Height          =   255
         Left            =   120
         TabIndex        =   71
         Top             =   600
         Width           =   1695
      End
      Begin VB.Label Label4 
         Caption         =   "VIP:"
         Height          =   255
         Left            =   240
         TabIndex        =   70
         Top             =   240
         Width           =   495
      End
   End
   Begin VB.FileListBox lstAccountNames 
      Height          =   675
      Left            =   120
      Pattern         =   "*.bin*"
      TabIndex        =   67
      Top             =   120
      Width           =   4215
   End
   Begin VB.Frame fraVitals 
      Caption         =   "Vitals"
      Height          =   1575
      Left            =   120
      TabIndex        =   60
      Top             =   4440
      Width           =   4215
      Begin VB.TextBox txtMP 
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   960
         TabIndex        =   63
         Top             =   720
         Width           =   3135
      End
      Begin VB.TextBox txtHP 
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   960
         TabIndex        =   62
         Top             =   360
         Width           =   3135
      End
      Begin VB.TextBox txtSP 
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   960
         TabIndex        =   61
         Top             =   1080
         Width           =   3135
      End
      Begin VB.Label Label32 
         Caption         =   "Mana:"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         TabIndex        =   66
         Top             =   720
         Width           =   975
      End
      Begin VB.Label Label31 
         Caption         =   "Health:"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         TabIndex        =   65
         Top             =   360
         Width           =   735
      End
      Begin VB.Label Label29 
         Caption         =   "SP:"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         TabIndex        =   64
         Top             =   1080
         Width           =   735
      End
   End
   Begin VB.Frame fraSpells 
      Caption         =   "Spells"
      Height          =   2295
      Left            =   4680
      TabIndex        =   55
      Top             =   6720
      Width           =   4935
      Begin VB.ListBox lstSpellList 
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   1620
         Left            =   2640
         TabIndex        =   57
         Top             =   480
         Width           =   2175
      End
      Begin VB.ListBox lstPlayerSpells 
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   1620
         Left            =   240
         TabIndex        =   56
         Top             =   480
         Width           =   2175
      End
      Begin VB.Label Label28 
         Caption         =   "Local Spell List:"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   2640
         TabIndex        =   59
         Top             =   240
         Width           =   1335
      End
      Begin VB.Label Label27 
         Caption         =   "Player Spells:"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   240
         TabIndex        =   58
         Top             =   240
         Width           =   1335
      End
   End
   Begin VB.Frame fraEquipment 
      Caption         =   "Equipment"
      Height          =   1935
      Left            =   4440
      TabIndex        =   41
      Top             =   4680
      Width           =   5175
      Begin VB.CommandButton cmdShieldUnequip 
         Caption         =   "Unequip"
         Height          =   255
         Left            =   4200
         TabIndex        =   53
         Top             =   1440
         Width           =   855
      End
      Begin VB.CommandButton cmdLegsUnequip 
         Caption         =   "Unequip"
         Height          =   255
         Left            =   4200
         TabIndex        =   52
         Top             =   1080
         Width           =   855
      End
      Begin VB.CommandButton cmdArmourUnequip 
         Caption         =   "Unequip"
         Height          =   255
         Left            =   4200
         TabIndex        =   51
         Top             =   720
         Width           =   855
      End
      Begin VB.CommandButton cmdWeaponUnequip 
         Caption         =   "Unequip"
         Height          =   255
         Left            =   4200
         TabIndex        =   50
         Top             =   360
         Width           =   855
      End
      Begin VB.TextBox txtLegs 
         Enabled         =   0   'False
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   960
         TabIndex        =   47
         Text            =   "--Empty--"
         Top             =   1080
         Width           =   3015
      End
      Begin VB.TextBox txtShield 
         Enabled         =   0   'False
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   960
         TabIndex        =   46
         Text            =   "--Empty--"
         Top             =   1440
         Width           =   3015
      End
      Begin VB.TextBox txtWeapon 
         Enabled         =   0   'False
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   960
         TabIndex        =   43
         Text            =   "--Empty--"
         Top             =   360
         Width           =   3015
      End
      Begin VB.TextBox txtArmour 
         Enabled         =   0   'False
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   960
         TabIndex        =   42
         Text            =   "--Empty--"
         Top             =   720
         Width           =   3015
      End
      Begin VB.Label Label24 
         Caption         =   "Legs:"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         TabIndex        =   49
         Top             =   1080
         Width           =   735
      End
      Begin VB.Label Label23 
         Caption         =   "Shield:"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         TabIndex        =   48
         Top             =   1440
         Width           =   975
      End
      Begin VB.Label Label22 
         Caption         =   "Weapon:"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         TabIndex        =   45
         Top             =   360
         Width           =   735
      End
      Begin VB.Label Label21 
         Caption         =   "Armour:"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         TabIndex        =   44
         Top             =   720
         Width           =   975
      End
   End
   Begin VB.Frame fraStats 
      Caption         =   "Stats"
      Height          =   1575
      Left            =   120
      TabIndex        =   26
      Top             =   8280
      Width           =   4455
      Begin VB.TextBox txtEnd 
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   2040
         TabIndex        =   33
         Top             =   360
         Width           =   855
      End
      Begin VB.TextBox txtStr 
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   600
         TabIndex        =   32
         Top             =   360
         Width           =   855
      End
      Begin VB.TextBox txtVit 
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   3480
         TabIndex        =   31
         Top             =   360
         Width           =   855
      End
      Begin VB.TextBox txtInt 
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   2040
         TabIndex        =   30
         Top             =   720
         Width           =   855
      End
      Begin VB.TextBox txtWill 
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   600
         TabIndex        =   29
         Top             =   720
         Width           =   855
      End
      Begin VB.TextBox txtSpr 
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   3480
         TabIndex        =   28
         Top             =   720
         Width           =   855
      End
      Begin VB.TextBox txtPoints 
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   2400
         TabIndex        =   27
         Top             =   1080
         Width           =   855
      End
      Begin VB.Label Label15 
         Caption         =   "End:"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   1560
         TabIndex        =   40
         Top             =   360
         Width           =   375
      End
      Begin VB.Label Label16 
         Caption         =   "Str:"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         TabIndex        =   39
         Top             =   360
         Width           =   375
      End
      Begin VB.Label Label17 
         Caption         =   "Vit:"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   3000
         TabIndex        =   38
         Top             =   360
         Width           =   375
      End
      Begin VB.Label lblInt 
         Caption         =   "Int:"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   1560
         TabIndex        =   37
         Top             =   720
         Width           =   375
      End
      Begin VB.Label Label19 
         Caption         =   "Will:"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         TabIndex        =   36
         Top             =   720
         Width           =   375
      End
      Begin VB.Label Label20 
         Caption         =   "Spr:"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   3000
         TabIndex        =   35
         Top             =   720
         Width           =   375
      End
      Begin VB.Label Label18 
         Caption         =   "Points:"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   1680
         TabIndex        =   34
         Top             =   1080
         Width           =   615
      End
   End
   Begin VB.Frame fraInventory 
      Caption         =   "Inventory"
      Height          =   4455
      Left            =   4440
      TabIndex        =   21
      Top             =   120
      Width           =   5175
      Begin VB.ListBox lstInventory 
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   3765
         Left            =   240
         TabIndex        =   23
         Top             =   480
         Width           =   2295
      End
      Begin VB.ListBox lstItems 
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   3765
         Left            =   2640
         TabIndex        =   22
         Top             =   480
         Width           =   2295
      End
      Begin VB.Label Label13 
         Caption         =   "Inventory:"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   240
         TabIndex        =   25
         Top             =   240
         Width           =   975
      End
      Begin VB.Label Label14 
         Caption         =   "Local Item List:"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   2640
         TabIndex        =   24
         Top             =   240
         Width           =   1335
      End
   End
   Begin VB.Frame fraPlayer 
      Caption         =   "Player Data"
      Height          =   1815
      Left            =   120
      TabIndex        =   10
      Top             =   2520
      Width           =   4215
      Begin VB.TextBox txtName 
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   1200
         TabIndex        =   15
         Top             =   360
         Width           =   2895
      End
      Begin VB.TextBox txtLevel 
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   1200
         TabIndex        =   14
         Top             =   720
         Width           =   2895
      End
      Begin VB.TextBox txtExp 
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   1200
         TabIndex        =   13
         Top             =   1080
         Width           =   2895
      End
      Begin VB.ComboBox cboAccess 
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   315
         ItemData        =   "frmEditPlayer.frx":0000
         Left            =   1200
         List            =   "frmEditPlayer.frx":0002
         TabIndex        =   12
         Top             =   1440
         Width           =   2895
      End
      Begin VB.ComboBox cboPK 
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   315
         Left            =   1320
         TabIndex        =   11
         Top             =   2160
         Width           =   2895
      End
      Begin VB.Label Label3 
         Caption         =   "Name:"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         TabIndex        =   20
         Top             =   360
         Width           =   975
      End
      Begin VB.Label Level 
         Caption         =   "Level:"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         TabIndex        =   19
         Top             =   720
         Width           =   735
      End
      Begin VB.Label Label5 
         Caption         =   "Experience:"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         TabIndex        =   18
         Top             =   1080
         Width           =   1095
      End
      Begin VB.Label Label6 
         Caption         =   "Access:"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         TabIndex        =   17
         Top             =   1440
         Width           =   975
      End
      Begin VB.Label Label7 
         Caption         =   "PK:"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         TabIndex        =   16
         Top             =   2160
         Width           =   975
      End
   End
   Begin VB.Frame fraAccount 
      Caption         =   "Account Data"
      Height          =   1215
      Left            =   120
      TabIndex        =   5
      Top             =   1200
      Width           =   4215
      Begin VB.TextBox txtLogin 
         Enabled         =   0   'False
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   1200
         TabIndex        =   7
         Top             =   360
         Width           =   2895
      End
      Begin VB.TextBox txtPassword 
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   285
         Left            =   1200
         TabIndex        =   6
         Top             =   720
         Width           =   2895
      End
      Begin VB.Label Label1 
         Caption         =   "Login:"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         TabIndex        =   9
         Top             =   360
         Width           =   735
      End
      Begin VB.Label Label2 
         Caption         =   "Password:"
         BeginProperty Font 
            Name            =   "Verdana"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   120
         TabIndex        =   8
         Top             =   720
         Width           =   975
      End
   End
   Begin VB.CommandButton cmdSavePlayer 
      Caption         =   "Save Player File"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   5880
      TabIndex        =   2
      Top             =   9480
      Width           =   1575
   End
   Begin VB.TextBox txtAccountName 
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   285
      Left            =   120
      TabIndex        =   1
      Text            =   "Account Name Here"
      Top             =   840
      Width           =   4215
   End
   Begin VB.CommandButton cmdOpen 
      Caption         =   "Open Player File"
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   7680
      TabIndex        =   0
      Top             =   9480
      Width           =   1695
   End
   Begin VB.Label Label25 
      Caption         =   "Eclipse Origins Account Editor"
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
      Left            =   4800
      TabIndex        =   54
      Top             =   9120
      Width           =   4935
   End
   Begin VB.Label lblNotify 
      Alignment       =   2  'Center
      BeginProperty Font 
         Name            =   "Verdana"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   4800
      TabIndex        =   4
      Top             =   4200
      Width           =   4695
   End
   Begin VB.Label Label12 
      Caption         =   "Version: 1.3"
      Height          =   255
      Left            =   4800
      TabIndex        =   3
      Top             =   9600
      Width           =   975
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Const NAME_LENGTH As Byte = 20
Const MAX_INV As Byte = 35
Const MAX_PLAYER_SPELLS As Byte = 35
Const MAX_NPCS As Long = 255
Const MAX_QUESTS As Long = 255
Const ACCOUNT_LENGTH As Byte = 12
Const MAX_HOTBAR As Long = 12

Dim AccName As String
Dim OnePlayer As PlayerRec
Dim OneItem As ItemRec
Dim OneEq(1 To 4) As ItemRec

Private Type HotbarRec
    Slot As Long
    sType As Byte
End Type


Private Type PlayerInvRec
    Num As Byte
    Value As Long
End Type

Private Type QuestRec
     'Informações
    Name As String * NAME_LENGTH
    Desc As String * 255
    Msg(1 To 3) As String * 255
    Tipo As Byte
    Repetivel As Byte
    'Script
    StartScript As Integer
    'Requerimentos
    ReqParty As Byte 'Membros Party
    ReqLevel As Integer
    ReqClasse As Byte
    ReqVIP As Byte
    ReqVila As Byte
    ReqElemento As Byte
    'Tarefas
    Item(1 To 5) As Integer
    ItemQnt(1 To 5) As Long
    Npc(1 To 5) As Integer
    NpcQnt(1 To 5) As Long
    MAP As Integer
    NeedLevel As Integer
    KillPlayerQnt As Long
    KillPlayerClass As Byte
    UsarSpell As Integer
    UsarSpellQnt As Integer
    'Recompensa
    rItem(1 To 5) As Integer
    rItemQnt(1 To 5) As Long
    rSpell As Integer
    rEXP As Long
    rSprite As Integer
    rClasse As Byte
    rRank As Byte
    rOrg As Byte
    rElemento As Byte
    'SCRIPT
    rEndScript As Integer
    'SERVER SIDE
    Status As Byte
    QuestNpc(1 To 10) As Integer
End Type

Private Type PetRec
    SpriteNum As Byte
    Name As String * 50
    Owner As Long
    
    PetLevel(1 To MAX_NPCS) As Byte
    PetNextLevel(1 To MAX_NPCS) As Long
    PetExp(1 To MAX_NPCS) As Long
    PetDamage(1 To MAX_NPCS) As Long
    PetHP(1 To MAX_NPCS) As Long
    PetMaxHP(1 To MAX_NPCS) As Long
    'PetSpell(1 To MAX_NPCS) As Integer
End Type

Private Type PlayerRec
    ' Account
    Login As String * ACCOUNT_LENGTH
    Password As String * NAME_LENGTH
    
    ' General
    Name As String * ACCOUNT_LENGTH
    Sex As Byte
    Class As Long
    Sprite As Long
    Level As Long
    exp As Long
    Access As Byte
    PK As Byte
    
    VIP As Byte
    Rank As String * NAME_LENGTH
    Vila As Byte
    Elemento(1 To 5) As Byte
    Org As String * NAME_LENGTH
    OrgAccess As Byte
    
    Trans As Byte
    Voando As Byte
    
    QuestNum(1 To 10) As Integer
    QuestInfo(1 To 10) As QuestRec
    QuestCompleta(1 To MAX_QUESTS) As Integer
    
    ' Vitals
    Vital(1 To 2) As Long
    
    ' Stats
    Stat(1 To 5) As Long
    POINTS As Long
    
    ' Worn equipment
    Equipment(1 To 4) As Long
    
    ' Inventory
    Inv(1 To MAX_INV) As PlayerInvRec
    Spell(1 To MAX_PLAYER_SPELLS) As Long
    
    ' Hotbar
    Hotbar(1 To MAX_HOTBAR) As HotbarRec
    
    ' Position
    MAP As Long
    X As Byte
    Y As Byte
    Dir As Byte
    
    Pet As PetRec
End Type

Private Type ItemRec
    Name As String * NAME_LENGTH
    Desc As String * 255
    Sound As String * NAME_LENGTH
    
    Pic As Long

    Type As Byte
    Data1 As Long
    Data2 As Long
    Data3 As Long
    ClassReq As Long
    AccessReq As Long
    LevelReq As Long
    Mastery As Byte
    price As Long
    Add_Stat(1 To 5) As Byte
    Rarity As Byte
    Speed As Long
    Handed As Long
    BindType As Byte
    Stat_Req(1 To 5) As Byte
    Animation As Long
    Paperdoll As Long
    
    AddHP As Long
    AddMP As Long
    AddEXP As Long
    CastSpell As Long
    instaCast As Byte
    
    Script As Long
    StunDuration As Long
    ExpExtra As Long
    'Arrow As Long
End Type

Private Type SpellRec
    Name As String * NAME_LENGTH
    Desc As String * 255
    Sound As String * NAME_LENGTH
    
    Type As Byte
    MPCost As Long
    LevelReq As Long
    AccessReq As Long
    ClassReq As Long
    CastTime As Long
    CDTime As Long
    Icon As Long
    MAP As Long
    X As Long
    Y As Long
    Dir As Byte
    Vital As Long
    Duration As Long
    Interval As Long
    Range As Byte
    IsAoE As Boolean
    AoE As Long
    CastAnim As Long
    SpellAnim As Long
    StunDuration As Long
    'SPELLRETA
    Dist As Byte
    Expelir As Byte
    Multipla As Byte
    RetaAnim(1 To 4) As Long
    MultiAnim As Byte
    'ARROW
    'Arrow As Long
    'Script
    Script As Long
    'Stats Baseados
    BaseStat As Byte
    ReqTrans As Byte
    ReqDojutsu As Byte
    ReqVila As Byte
    IsPush As Byte
    PetNum As Long
End Type



Private Sub cboDir_Change()

End Sub

Private Sub cboAccess_Change()

End Sub

Private Sub cmdArmourUnequip_Click()
If OnePlayer.Equipment(2) <> 0 Then
    For i = 1 To 35
        If OnePlayer.Inv(i).Num = 0 Then
            OnePlayer.Inv(i).Num = OnePlayer.Equipment(2)
            OnePlayer.Inv(i).Value = 1
            OnePlayer.Equipment(2) = 0
            UpdateInventory
            txtArmour.Text = "--Empty--"
            Exit Sub
        End If
    Next
Else
    MsgBox ("There is no item here!")
End If
End Sub

Private Sub cmdLegsUnequip_Click()
If OnePlayer.Equipment(3) <> 0 Then
    For i = 1 To 35
        If OnePlayer.Inv(i).Num = 0 Then
            OnePlayer.Inv(i).Num = OnePlayer.Equipment(3)
            OnePlayer.Inv(i).Value = 1
            OnePlayer.Equipment(3) = 0
            UpdateInventory
            txtLegs.Text = "--Empty--"
            Exit Sub
        End If
    Next
ElseIf unequipped = False Then
    MsgBox ("There is no space in your inventory!")
Else
    MsgBox ("There is no item here!")
End If
End Sub

Private Sub cmdOpen_Click()
    LoadPlayer
End Sub

Private Sub cmdSavePlayer_Click()
Dim Filename As String
Dim i As Integer

Filename = App.Path & "\data\accounts\" & AccName & ".bin"

If Not IsNumeric(txtVIP.Text) Then
    MsgBox ("VIP must be a number!")
    Exit Sub
End If

If Not IsNumeric(txtRank.Text) Then
    MsgBox ("Rank must be a number!")
    Exit Sub
End If

If Not IsNumeric(txtVila.Text) Then
    MsgBox ("Vila must be a number!")
    Exit Sub
End If

If Not IsNumeric(txtExp.Text) Then
    MsgBox ("Experience must be a number!")
    Exit Sub
End If

If Not IsNumeric(txtLevel.Text) Then
    MsgBox ("Level must be a number!")
    Exit Sub
End If

If Not IsNumeric(txtX.Text) Then
    MsgBox ("X coordinate must be a number!")
    Exit Sub
End If

If Not IsNumeric(txtY.Text) Then
    MsgBox ("Y coordinate must be a number!")
    Exit Sub
End If

If Not IsNumeric(txtStr.Text) Then
    MsgBox ("Str variable must be a number!")
    Exit Sub
End If

If Not IsNumeric(txtEnd.Text) Then
    MsgBox ("End variable must be a number!")
    Exit Sub
End If


If Not IsNumeric(txtVit.Text) Then
    MsgBox ("Vit variable must be a number!")
    Exit Sub
End If


If Not IsNumeric(txtWill.Text) Then
    MsgBox ("Will variable must be a number!")
    Exit Sub
End If


If Not IsNumeric(txtInt.Text) Then
    MsgBox ("Int variable must be a number!")
    Exit Sub
End If

If Not IsNumeric(txtPoints.Text) Then
    MsgBox ("Points variable must be a number!")
    Exit Sub
End If

If Not IsNumeric(txtHP.Text) Then
    MsgBox ("HP variable must be a number!")
    Exit Sub
End If

If Not IsNumeric(txtMP.Text) Then
    MsgBox ("MP variable must be a number!")
    Exit Sub
End If

If Not IsNumeric(txtSP.Text) Then
    MsgBox ("SP variable must be a number!")
    Exit Sub
End If

With OnePlayer
    '.Login = txtLogin.Text
    .Password = txtPassword.Text
    .Name = txtName.Text
    '.Sex = cboGender.ListIndex
    .Level = txtLevel.Text
    .exp = txtExp.Text
    '.Access = cboAccess.ListIndex
    '.PK = cboPK.ListIndex
    '.MAP = txtMap.Text
    '.X = txtX.Text
    '.Y = txtY.Text
    '.Dir = cboDir.ListIndex
    .Stat(1) = txtStr.Text
    .Stat(2) = txtEnd.Text
    .Stat(3) = txtVit.Text
    .Stat(4) = txtWill.Text
    .Stat(5) = txtInt.Text
    '.Stat(6) = txtSpr.Text
    .POINTS = txtPoints.Text
    .Vital(1) = txtHP.Text
    .Vital(2) = txtMP.Text
    '.Vital(3) = txtSP.Text
    
    'For i = 1 To 35
        '.Inv(i).Num =
End With

Open Filename For Binary As #1
    Put #1, , OnePlayer
Close #1

cmdSavePlayer.Enabled = False
MsgBox ("Account " & AccName & " saved.")
cmdOpen.Enabled = True
txtAccountName.Enabled = True
fraAccount.Enabled = False
fraPlayer.Enabled = False
fraLocation.Enabled = False
fraStats.Enabled = False
fraInventory.Enabled = False
fraEquipment.Enabled = False
fraSpells.Enabled = False
fraVitals.Enabled = False
    
End Sub

Sub UpdateInventory()
Dim i As Integer
Dim itemfilename As String, ItemNumber As String

lstInventory.Clear
    For i = 1 To MAX_INV
            ItemNumber = OnePlayer.Inv(i).Num
            itemfilename = App.Path & "\data\items\Item" & ItemNumber & ".dat"
            Open itemfilename For Binary As #1
                Get #1, , OneItem
                lstInventory.AddItem (i & ": " & OneItem.Name)
            Close #1
    Next
    
    'MsgBox OnePlayer.Inv(35).Num & " " & OnePlayer.Inv(35).Value
        
End Sub

Sub LoadItemList()
Dim i As Integer
Dim Filename As String

lstItems.Clear
lstItems.AddItem ("--None--")
    For i = 1 To 255
        Filename = App.Path & "\data\items\Item" & i & ".dat"
        
        Open Filename For Binary As #1
            Get #1, , OneItem
            lstItems.AddItem (i & ": " & OneItem.Name)
        Close #1
    Next
End Sub


Private Sub cmdShieldUnequip_Click()
If OnePlayer.Equipment(4) <> 0 Then
    For i = 1 To 35
        If OnePlayer.Inv(i).Num = 0 Then
            OnePlayer.Inv(i).Num = OnePlayer.Equipment(4)
            OnePlayer.Inv(i).Value = 1
            OnePlayer.Equipment(4) = 0
            UpdateInventory
            txtWeapon.Text = "--Empty--"
            unequipped = True
            Exit Sub
        End If
    Next
Else
    MsgBox ("There is no item here!")
End If
End Sub

Private Sub cmdWeaponUnequip_Click()
If OnePlayer.Equipment(1) <> 0 Then
    For i = 1 To 35
        If OnePlayer.Inv(i).Num = 0 Then
            OnePlayer.Inv(i).Num = OnePlayer.Equipment(1)
            OnePlayer.Inv(i).Value = 1
            OnePlayer.Equipment(1) = 0
            UpdateInventory
            txtWeapon.Text = "--Empty--"
            unequipped = True
        End If
    Next
Else
    MsgBox ("There is no item here!")
End If
End Sub

Private Sub Form_Load()
Dim Filename As String, store As String, iStore As Integer
Dim i As Integer

fraAccount.Enabled = False
fraPlayer.Enabled = False
fraLocation.Enabled = False
fraStats.Enabled = False
fraInventory.Enabled = False
fraEquipment.Enabled = False
fraVitals.Enabled = False
fraSpells.Enabled = False

'Editing
lstAccountNames.Path = App.Path & "\data\accounts"

Filename = App.Path & "\data\accounts\charlist.txt"

Open Filename For Input As #1

Do Until EOF(1)
    Input #1, store
    i = i + 1
Loop
iStore = i
Close #1

Filename = App.Path & "\data\accounts\"
For i = 1 To iStore
    
Next


End Sub

Private Sub lstAccountNames_Click()
    Dim Name() As String
    
    Name = Split(lstAccountNames.Filename, ".")
    txtAccountName.Text = Name(0)
    
    LoadPlayer
End Sub

Private Sub lstItems_Click()
Dim ItmIndex As Integer

ItmIndex = lstItems.ListIndex

If lstInventory.ListIndex >= 0 Then
    If ItmIndex = 0 Then
        OnePlayer.Inv(lstInventory.ListIndex + 1).Num = 0
        OnePlayer.Inv(lstInventory.ListIndex + 1).Value = 1
        lblNotify.Caption = "Item removed."
    Else
        OnePlayer.Inv(lstInventory.ListIndex + 1).Num = ItmIndex
        OnePlayer.Inv(lstInventory.ListIndex + 1).Value = 1
        lblNotify.Caption = "Item added."
    End If
    
    UpdateInventory
End If
End Sub

Private Sub lstPlayers_Click()
    LoadPlayer
End Sub

Sub LoadPlayer()
Dim Filename As String

AccName = txtAccountName.Text
Filename = App.Path & "\data\accounts\" & AccName & ".bin"

If LenB(Dir(Filename)) > 0 Then
    Open Filename For Binary As #1
    Get #1, , OnePlayer
    Close #1
    
    With OnePlayer
    Dim i As Byte
        'account data
        txtLogin.Text = .Login
        txtPassword.Text = .Password
        
        'player data
        txtName.Text = .Name
        
        
        
        txtLevel.Text = .Level
        txtExp.Text = .exp
        
        'other player data
        
    
        'cboAccess.ListIndex = .Access
        'cboPK.AddItem .PK
        
        'coordinates
        'txtMap.Text = .MAP
        'txtX.Text = .X
        'txtY.Text = .Y
        
        'stats
        txtStr.Text = .Stat(1)
        txtEnd.Text = .Stat(2)
        txtVit.Text = .Stat(3)
        txtWill.Text = .Stat(4)
        txtInt.Text = .Stat(5)
        'txtSpr.Text = .Stat(6)
        txtPoints.Text = .POINTS
        
        'vitals
        txtHP.Text = .Vital(1)
        txtMP.Text = .Vital(2)
        'txtSP.Text = .Vital(3)
        
        'equipment
        LoadEquipment
        
        'inventories
        UpdateInventory
        LoadItemList
        
        'spells
        LoadPlayerSpells
        LoadSpellList
        
        fraAccount.Enabled = True
        fraPlayer.Enabled = True
        fraLocation.Enabled = True
        fraStats.Enabled = True
        fraInventory.Enabled = True
        fraEquipment.Enabled = True
        fraSpells.Enabled = True
        fraVitals.Enabled = True
        cmdSavePlayer.Enabled = True
        txtAccountName.Enabled = False
        cmdOpen.Enabled = False
        
    End With
Else
    MsgBox ("Player File does not exist!")
    Exit Sub
End If
End Sub

Sub LoadEquipment()
Dim i As Integer

txtWeapon.Text = "--Empty--"
txtArmour.Text = "--Empty--"
txtLegs.Text = "--Empty--"
txtShield.Text = "--Empty--"

For i = 1 To 4
    ItemNumber = OnePlayer.Equipment(i)
    
    If ItemNumber = 0 Then
        OneEq(i).Name = "--Empty--"
    Else
        itemfilename = App.Path & "\data\items\Item" & ItemNumber & ".dat"
        Open itemfilename For Binary As #1
            Get #1, , OneEq(i)
        Close #1
    End If
Next

txtWeapon.Text = OneEq(1).Name
txtArmour.Text = OneEq(2).Name
txtLegs.Text = OneEq(3).Name
txtShield.Text = OneEq(4).Name
        

End Sub

Sub LoadSpellList()
Dim Filename As String
Dim i As Integer
Dim OneSpell As SpellRec

lstSpellList.Clear

lstSpellList.AddItem ("--None--")

For i = 1 To 255
    Filename = App.Path & "\data\spells\spells" & i & ".dat"
    Open Filename For Binary As #1
        Get #1, , OneSpell
    Close #1
    
    lstSpellList.AddItem i & ": " & OneSpell.Name
Next
End Sub

Sub LoadPlayerSpells()
Dim Filename As String
Dim i As Integer
Dim OneSpell As SpellRec

lstPlayerSpells.Clear

For i = 1 To MAX_PLAYER_SPELLS
            SpellNumber = OnePlayer.Spell(i)
            itemfilename = App.Path & "\data\spells\spells" & SpellNumber & ".dat"
            Open itemfilename For Binary As #1
                Get #1, , OneSpell
                lstPlayerSpells.AddItem (i & ": " & OneSpell.Name)
            Close #1
    Next
End Sub

Private Sub lstSpellList_Click()
Dim SpellIndex As Integer

SpellIndex = lstSpellList.ListIndex

If lstPlayerSpells.ListIndex >= 0 Then
    If ItmIndex = 0 Then
        OnePlayer.Spell(lstPlayerSpells.ListIndex + 1) = SpellIndex
    Else
        OnePlayer.Inv(lstPlayerSpells.ListIndex + 1).Num = SpellIndex
    End If
    
    LoadPlayerSpells
End If
End Sub

Private Sub txtMap_Change()

End Sub
