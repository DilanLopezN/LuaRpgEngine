VERSION 5.00
Begin VB.Form frmEditor_Spell 
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Spell Editor"
   ClientHeight    =   8745
   ClientLeft      =   45
   ClientTop       =   375
   ClientWidth     =   10335
   ControlBox      =   0   'False
   BeginProperty Font 
      Name            =   "Verdana"
      Size            =   6.75
      Charset         =   0
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   583
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   689
   StartUpPosition =   2  'CenterScreen
   Begin VB.Frame fraReqTrans 
      Caption         =   "ReqTrans"
      Height          =   735
      Left            =   3600
      TabIndex        =   72
      Top             =   6240
      Width           =   1335
      Begin VB.HScrollBar scrlReqTrans 
         Height          =   255
         Left            =   240
         Max             =   6
         TabIndex        =   73
         Top             =   480
         Width           =   735
      End
      Begin VB.Label lblReqTrans 
         Caption         =   "Trans:Nenhuma"
         Height          =   255
         Left            =   0
         TabIndex        =   74
         Top             =   240
         Width           =   1815
      End
   End
   Begin VB.Frame fraArrow 
      Caption         =   "Arrow"
      Height          =   975
      Left            =   6960
      TabIndex        =   69
      Top             =   3240
      Visible         =   0   'False
      Width           =   2895
      Begin VB.HScrollBar scrlArrow 
         Height          =   255
         Left            =   360
         TabIndex        =   70
         Top             =   600
         Width           =   2175
      End
      Begin VB.Label lblArrow 
         Caption         =   "Arrow:Nenhuma"
         Height          =   255
         Left            =   360
         TabIndex        =   71
         Top             =   360
         Width           =   2175
      End
   End
   Begin VB.Frame fraBaseStat 
      Caption         =   "Baseado Stat"
      Height          =   735
      Left            =   240
      TabIndex        =   66
      Top             =   7920
      Width           =   2775
      Begin VB.HScrollBar scrlBaseStat 
         Height          =   255
         Left            =   240
         Max             =   5
         TabIndex        =   67
         Top             =   480
         Width           =   2295
      End
      Begin VB.Label lblBaseStat 
         BackStyle       =   0  'Transparent
         Caption         =   "Stat:Nenhum"
         Height          =   255
         Left            =   360
         TabIndex        =   68
         Top             =   240
         Width           =   2055
      End
   End
   Begin VB.Frame fraScript 
      Caption         =   "Script"
      Height          =   735
      Left            =   240
      TabIndex        =   63
      Top             =   7080
      Visible         =   0   'False
      Width           =   2775
      Begin VB.HScrollBar scrlScript 
         Height          =   255
         Left            =   480
         TabIndex        =   64
         Top             =   480
         Width           =   1695
      End
      Begin VB.Label lblScript 
         Caption         =   "Script:Nenhum"
         Height          =   255
         Left            =   480
         TabIndex        =   65
         Top             =   240
         Width           =   1695
      End
   End
   Begin VB.Frame fraReta 
      Caption         =   "Spell Reta"
      Height          =   3855
      Left            =   240
      TabIndex        =   56
      Top             =   3960
      Visible         =   0   'False
      Width           =   2895
      Begin VB.HScrollBar scrlRetaAnim 
         Height          =   255
         Index           =   4
         Left            =   840
         Max             =   255
         TabIndex        =   93
         Top             =   3480
         Width           =   1815
      End
      Begin VB.HScrollBar scrlRetaAnim 
         Height          =   255
         Index           =   3
         Left            =   840
         Max             =   255
         TabIndex        =   90
         Top             =   3000
         Width           =   1815
      End
      Begin VB.HScrollBar scrlRetaAnim 
         Height          =   255
         Index           =   2
         Left            =   840
         Max             =   255
         TabIndex        =   87
         Top             =   2520
         Width           =   1815
      End
      Begin VB.HScrollBar scrlRetaAnim 
         Height          =   255
         Index           =   1
         Left            =   840
         Max             =   255
         TabIndex        =   84
         Top             =   2040
         Width           =   1815
      End
      Begin VB.CheckBox chkMultiAnim 
         Caption         =   "MultiAnim?"
         Height          =   255
         Left            =   1320
         TabIndex        =   82
         Top             =   1440
         Width           =   1215
      End
      Begin VB.CheckBox chkPush 
         Caption         =   "Push?"
         Height          =   255
         Left            =   120
         TabIndex        =   75
         Top             =   1440
         Width           =   975
      End
      Begin VB.HScrollBar scrlMultipla 
         Height          =   255
         Left            =   1440
         TabIndex        =   62
         Top             =   1080
         Width           =   975
      End
      Begin VB.HScrollBar scrlExpelir 
         Height          =   255
         Left            =   120
         Max             =   20
         TabIndex        =   60
         Top             =   1080
         Width           =   975
      End
      Begin VB.HScrollBar scrlDist 
         Height          =   255
         Left            =   480
         Max             =   20
         TabIndex        =   57
         Top             =   480
         Width           =   1935
      End
      Begin VB.Label lblAnim4 
         Caption         =   "Right"
         Height          =   255
         Left            =   240
         TabIndex        =   94
         Top             =   3480
         Width           =   495
      End
      Begin VB.Label lblRetaAnim 
         Caption         =   "AnimRight:Nenhuma"
         Height          =   255
         Index           =   4
         Left            =   480
         TabIndex        =   92
         Top             =   3240
         Width           =   2535
      End
      Begin VB.Label lblAnim3 
         Caption         =   "Left"
         Height          =   255
         Left            =   240
         TabIndex        =   91
         Top             =   3000
         Width           =   495
      End
      Begin VB.Label lblRetaAnim 
         Caption         =   "AnimLeft:Nenhuma"
         Height          =   255
         Index           =   3
         Left            =   480
         TabIndex        =   89
         Top             =   2760
         Width           =   2535
      End
      Begin VB.Label lblAnim2 
         Caption         =   "Down"
         Height          =   255
         Left            =   240
         TabIndex        =   88
         Top             =   2520
         Width           =   495
      End
      Begin VB.Label lblRetaAnim 
         Caption         =   "AnimDown:Nenhuma"
         Height          =   255
         Index           =   2
         Left            =   480
         TabIndex        =   86
         Top             =   2280
         Width           =   2535
      End
      Begin VB.Label lblAnim1 
         Caption         =   "Anim"
         Height          =   255
         Left            =   240
         TabIndex        =   85
         Top             =   2040
         Width           =   495
      End
      Begin VB.Label lblRetaAnim 
         Caption         =   "AnimUP:Nenhuma"
         Height          =   255
         Index           =   1
         Left            =   480
         TabIndex        =   83
         Top             =   1800
         Width           =   2535
      End
      Begin VB.Label lblMultipla 
         Caption         =   "Multipla:0"
         Height          =   255
         Left            =   1440
         TabIndex        =   61
         Top             =   840
         Width           =   1215
      End
      Begin VB.Label lblExpelir 
         Caption         =   "Expelir:0"
         Height          =   255
         Left            =   120
         TabIndex        =   59
         Top             =   840
         Width           =   975
      End
      Begin VB.Label lblDist 
         Caption         =   "Dist:Nenhuma"
         Height          =   255
         Left            =   480
         TabIndex        =   58
         Top             =   240
         Width           =   1935
      End
   End
   Begin VB.CommandButton cmdSave 
      Caption         =   "Save"
      Height          =   375
      Left            =   4320
      TabIndex        =   5
      Top             =   8280
      Width           =   1455
   End
   Begin VB.CommandButton cmdCancel 
      Caption         =   "Cancel"
      Height          =   375
      Left            =   7680
      TabIndex        =   4
      Top             =   8280
      Width           =   1455
   End
   Begin VB.CommandButton cmdDelete 
      Caption         =   "Delete"
      Height          =   375
      Left            =   6000
      TabIndex        =   3
      Top             =   8280
      Width           =   1455
   End
   Begin VB.Frame Frame1 
      Caption         =   "Spell Properties"
      Height          =   8055
      Left            =   3360
      TabIndex        =   2
      Top             =   120
      Width           =   6855
      Begin VB.ComboBox cmbSound 
         Height          =   300
         Left            =   120
         Style           =   2  'Dropdown List
         TabIndex        =   55
         Top             =   7680
         Width           =   1215
      End
      Begin VB.TextBox txtDesc 
         Height          =   975
         Left            =   1440
         MaxLength       =   255
         MultiLine       =   -1  'True
         ScrollBars      =   2  'Vertical
         TabIndex        =   53
         Top             =   7080
         Width           =   5295
      End
      Begin VB.Frame Frame6 
         Caption         =   "Data"
         Height          =   6735
         Left            =   3480
         TabIndex        =   13
         Top             =   240
         Width           =   3255
         Begin VB.TextBox txtVital 
            Height          =   270
            Left            =   600
            TabIndex        =   95
            Top             =   1680
            Width           =   1575
         End
         Begin VB.Frame fraPet 
            Caption         =   "PetNum"
            Height          =   975
            Left            =   120
            TabIndex        =   76
            Top             =   5760
            Width           =   2895
            Begin VB.HScrollBar scrlPet 
               Height          =   255
               Left            =   360
               TabIndex        =   77
               Top             =   600
               Width           =   2175
            End
            Begin VB.Label lblPet 
               Caption         =   "Pet:Nenhum"
               Height          =   255
               Left            =   360
               TabIndex        =   78
               Top             =   360
               Width           =   2175
            End
         End
         Begin VB.HScrollBar scrlStun 
            Height          =   255
            Left            =   120
            TabIndex        =   50
            Top             =   5520
            Width           =   2895
         End
         Begin VB.HScrollBar scrlAnim 
            Height          =   255
            Left            =   120
            TabIndex        =   48
            Top             =   4920
            Width           =   2895
         End
         Begin VB.HScrollBar scrlAnimCast 
            Height          =   255
            Left            =   120
            TabIndex        =   46
            Top             =   4320
            Width           =   2895
         End
         Begin VB.CheckBox chkAOE 
            Caption         =   "Area of Effect spell?"
            Height          =   255
            Left            =   120
            TabIndex        =   42
            Top             =   3240
            Width           =   3015
         End
         Begin VB.HScrollBar scrlAOE 
            Height          =   255
            Left            =   120
            TabIndex        =   41
            Top             =   3720
            Width           =   3015
         End
         Begin VB.HScrollBar scrlRange 
            Height          =   255
            Left            =   120
            TabIndex        =   39
            Top             =   2880
            Width           =   3015
         End
         Begin VB.HScrollBar scrlInterval 
            Height          =   255
            Left            =   1680
            Max             =   10
            TabIndex        =   37
            Top             =   2280
            Value           =   1
            Width           =   1455
         End
         Begin VB.HScrollBar scrlDuration 
            Height          =   255
            Left            =   120
            Max             =   10
            TabIndex        =   35
            Top             =   2280
            Width           =   1455
         End
         Begin VB.HScrollBar scrlVital 
            Height          =   255
            Left            =   3000
            TabIndex        =   33
            Top             =   1920
            Visible         =   0   'False
            Width           =   3015
         End
         Begin VB.HScrollBar scrlDir 
            Height          =   255
            Left            =   1680
            TabIndex        =   21
            Top             =   480
            Width           =   1455
         End
         Begin VB.HScrollBar scrlY 
            Height          =   255
            Left            =   1680
            TabIndex        =   19
            Top             =   1080
            Width           =   1455
         End
         Begin VB.HScrollBar scrlX 
            Height          =   255
            Left            =   120
            TabIndex        =   17
            Top             =   1080
            Width           =   1455
         End
         Begin VB.HScrollBar scrlMap 
            Height          =   255
            Left            =   120
            Max             =   100
            TabIndex        =   15
            Top             =   480
            Width           =   1455
         End
         Begin VB.Label lblStun 
            Caption         =   "Stun Duration: None"
            Height          =   255
            Left            =   120
            TabIndex        =   51
            Top             =   5280
            Width           =   2895
         End
         Begin VB.Label lblAnim 
            Caption         =   "Animation: None"
            Height          =   255
            Left            =   120
            TabIndex        =   47
            Top             =   4680
            Width           =   2895
         End
         Begin VB.Label lblAnimCast 
            Caption         =   "Cast Anim: None"
            Height          =   255
            Left            =   120
            TabIndex        =   45
            Top             =   4080
            Width           =   2895
         End
         Begin VB.Label lblAOE 
            Caption         =   "AoE: Self-cast"
            Height          =   255
            Left            =   120
            TabIndex        =   40
            Top             =   3480
            Width           =   3015
         End
         Begin VB.Label lblRange 
            Caption         =   "Range: Self-cast"
            Height          =   255
            Left            =   120
            TabIndex        =   38
            Top             =   2640
            Width           =   3015
         End
         Begin VB.Label lblInterval 
            Caption         =   "Interval: 0s"
            Height          =   255
            Left            =   1680
            TabIndex        =   36
            Top             =   2040
            Width           =   1455
         End
         Begin VB.Label lblDuration 
            Caption         =   "Duration: 0s"
            Height          =   255
            Left            =   120
            TabIndex        =   34
            Top             =   2040
            Width           =   1455
         End
         Begin VB.Label lblVital 
            Caption         =   "Vital: 0"
            Height          =   255
            Left            =   120
            TabIndex        =   32
            Top             =   1440
            Width           =   3015
         End
         Begin VB.Label lblDir 
            Caption         =   "Dir: Down"
            Height          =   255
            Left            =   1680
            TabIndex        =   20
            Top             =   240
            Width           =   1455
         End
         Begin VB.Label lblY 
            Caption         =   "Y: 0"
            Height          =   255
            Left            =   1680
            TabIndex        =   18
            Top             =   840
            Width           =   1455
         End
         Begin VB.Label lblX 
            Caption         =   "X: 0"
            Height          =   255
            Left            =   120
            TabIndex        =   16
            Top             =   840
            Width           =   1455
         End
         Begin VB.Label lblMap 
            Caption         =   "Map: 0"
            Height          =   255
            Left            =   120
            TabIndex        =   14
            Top             =   240
            Width           =   1455
         End
      End
      Begin VB.Frame Frame2 
         Caption         =   "Basic Information"
         Height          =   6735
         Left            =   120
         TabIndex        =   6
         Top             =   240
         Width           =   3255
         Begin VB.TextBox txtMP 
            Height          =   270
            Left            =   480
            TabIndex        =   96
            Top             =   1680
            Width           =   1455
         End
         Begin VB.Frame fraReqDojutsu 
            Caption         =   "ReqDojutsu"
            Height          =   735
            Left            =   1560
            TabIndex        =   79
            Top             =   5880
            Width           =   1455
            Begin VB.HScrollBar scrlReqDojutsu 
               Height          =   255
               Left            =   360
               Max             =   6
               TabIndex        =   80
               Top             =   480
               Width           =   735
            End
            Begin VB.Label lblReqDojutsu 
               Caption         =   "Dojutsu:Nenhum"
               Height          =   255
               Left            =   120
               TabIndex        =   81
               Top             =   240
               Width           =   1815
            End
         End
         Begin VB.PictureBox picSprite 
            AutoRedraw      =   -1  'True
            BackColor       =   &H00000000&
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
            Height          =   480
            Left            =   2640
            ScaleHeight     =   32
            ScaleMode       =   3  'Pixel
            ScaleWidth      =   32
            TabIndex        =   49
            Top             =   5160
            Width           =   480
         End
         Begin VB.HScrollBar scrlIcon 
            Height          =   255
            Left            =   120
            TabIndex        =   44
            Top             =   5400
            Width           =   2415
         End
         Begin VB.HScrollBar scrlCool 
            Height          =   255
            Left            =   120
            Max             =   60
            TabIndex        =   31
            Top             =   4680
            Width           =   3015
         End
         Begin VB.HScrollBar scrlCast 
            Height          =   255
            Left            =   120
            Max             =   60
            TabIndex        =   29
            Top             =   4080
            Width           =   3015
         End
         Begin VB.ComboBox cmbClass 
            Height          =   300
            Left            =   120
            Style           =   2  'Dropdown List
            TabIndex        =   27
            Top             =   3480
            Width           =   3015
         End
         Begin VB.HScrollBar scrlAccess 
            Height          =   255
            Left            =   120
            Max             =   5
            TabIndex        =   25
            Top             =   2880
            Width           =   3015
         End
         Begin VB.HScrollBar scrlLevel 
            Height          =   255
            Left            =   120
            Max             =   100
            TabIndex        =   23
            Top             =   2280
            Width           =   3015
         End
         Begin VB.HScrollBar scrlMP 
            Height          =   255
            Left            =   2880
            TabIndex        =   12
            Top             =   1680
            Visible         =   0   'False
            Width           =   615
         End
         Begin VB.ComboBox cmbType 
            Height          =   300
            ItemData        =   "frmEditor_Spell.frx":0000
            Left            =   120
            List            =   "frmEditor_Spell.frx":001F
            Style           =   2  'Dropdown List
            TabIndex        =   10
            Top             =   1080
            Width           =   3015
         End
         Begin VB.TextBox txtName 
            Height          =   270
            Left            =   120
            TabIndex        =   8
            Top             =   480
            Width           =   3015
         End
         Begin VB.Label lblIcon 
            Caption         =   "Icon: None"
            Height          =   255
            Left            =   120
            TabIndex        =   43
            Top             =   5160
            Width           =   3015
         End
         Begin VB.Label lblCool 
            Caption         =   "Cooldown Time: 0s"
            Height          =   255
            Left            =   120
            TabIndex        =   30
            Top             =   4440
            Width           =   2535
         End
         Begin VB.Label lblCast 
            Caption         =   "Casting Time: 0s"
            Height          =   255
            Left            =   120
            TabIndex        =   28
            Top             =   3840
            Width           =   1695
         End
         Begin VB.Label Label5 
            Caption         =   "Class Required:"
            Height          =   255
            Left            =   120
            TabIndex        =   26
            Top             =   3240
            Width           =   1815
         End
         Begin VB.Label lblAccess 
            Caption         =   "Access Required: None"
            Height          =   255
            Left            =   120
            TabIndex        =   24
            Top             =   2640
            Width           =   1815
         End
         Begin VB.Label lblLevel 
            Caption         =   "Level Required: None"
            Height          =   255
            Left            =   120
            TabIndex        =   22
            Top             =   2040
            Width           =   1815
         End
         Begin VB.Label lblMP 
            Caption         =   "MP Cost: None"
            Height          =   255
            Left            =   120
            TabIndex        =   11
            Top             =   1440
            Width           =   1815
         End
         Begin VB.Label Label2 
            Caption         =   "Type:"
            Height          =   255
            Left            =   120
            TabIndex        =   9
            Top             =   840
            Width           =   1815
         End
         Begin VB.Label Label1 
            AutoSize        =   -1  'True
            Caption         =   "Name:"
            Height          =   180
            Left            =   120
            TabIndex        =   7
            Top             =   240
            Width           =   495
         End
      End
      Begin VB.Label Label4 
         Caption         =   "Sound:"
         Height          =   255
         Left            =   240
         TabIndex        =   54
         Top             =   7320
         Width           =   1215
      End
      Begin VB.Label Label3 
         Caption         =   "Description:"
         Height          =   255
         Left            =   120
         TabIndex        =   52
         Top             =   7080
         Width           =   1215
      End
   End
   Begin VB.Frame Frame3 
      Caption         =   "Spell List"
      Height          =   4695
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   3135
      Begin VB.ListBox lstIndex 
         Height          =   4380
         Left            =   120
         TabIndex        =   1
         Top             =   240
         Width           =   2895
      End
   End
End
Attribute VB_Name = "frmEditor_Spell"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub chkAOE_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If chkAOE.value = 0 Then
        Spell(EditorIndex).IsAoE = False
    Else
        Spell(EditorIndex).IsAoE = True
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "chkAOE_Click", "frmEditor_Spell", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub chkMultiAnim_Click()
Dim i As Byte
For i = 2 To 4
    If chkMultiAnim.value = YES Then
        lblAnim1.Caption = "UP"
        
        If scrlRetaAnim(i).value > 0 Then
            lblRetaAnim(i).Caption = scrlRetaAnim(i).value & ":" & Animation(scrlRetaAnim(i).value).name
        Else
            lblRetaAnim(i).Caption = "Anim:Nenhuma"
        End If
        
        scrlRetaAnim(i).Visible = True
        lblRetaAnim(i).Visible = True
        lblAnim2.Visible = True
        lblAnim3.Visible = True
        lblAnim4.Visible = True
        
        fraReta.height = 257
    Else
        lblAnim1.Caption = "Anim"
        scrlRetaAnim(i).Visible = False
        lblRetaAnim(i).Visible = False
        lblAnim2.Visible = False
        lblAnim3.Visible = False
        lblAnim4.Visible = False
        fraReta.height = 153
    End If
Next

Spell(EditorIndex).MultiAnim = chkMultiAnim.value
End Sub

Private Sub chkPush_Click()
Spell(EditorIndex).IsPush = chkPush.value
End Sub

Private Sub cmbClass_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    Spell(EditorIndex).ClassReq = cmbClass.ListIndex
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "cmbClass_Click", "frmEditor_Spell", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub cmbType_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    If cmbType.ListIndex = SPELL_TYPE_RETA Or cmbType.ListIndex = SPELL_TYPE_AREA Then
       fraReta.Visible = True
       lblDist.Visible = Visible
       scrlDist.Visible = Visible
       scrlMultipla.Visible = Visible
       lblMultipla.Visible = Visible
    Else
       fraReta.Visible = False
    End If
    
    
    
    If cmbType.ListIndex = SPELL_TYPE_SCRIPT Then
       fraScript.Visible = True
    Else
       fraScript.Visible = False
    End If
    
    Spell(EditorIndex).Type = cmbType.ListIndex
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "cmbType_Click", "frmEditor_Spell", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub cmdDelete_Click()
Dim tmpIndex As Long

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    ClearSpell EditorIndex
    
    tmpIndex = lstIndex.ListIndex
    lstIndex.RemoveItem EditorIndex - 1
    lstIndex.AddItem EditorIndex & ": " & Spell(EditorIndex).name, EditorIndex - 1
    lstIndex.ListIndex = tmpIndex
    
    SpellEditorInit
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "cmdDelete_Click", "frmEditor_Spell", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub cmdSave_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    SpellEditorOk
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "cmdSave_Click", "frmEditor_Spell", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub Form_Activate()
If GetPlayerAccess(MyIndex) < ADMIN_MONITOR Then
        'MsgBox "nonon"
        Unload frmEditor_Spell
        Exit Sub
    End If
End Sub

Private Sub Form_Load()
scrlPet.max = MAX_NPCS
End Sub

Private Sub lstIndex_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    SpellEditorInit
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "lstIndex_Click", "frmEditor_Spell", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub cmdCancel_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    SpellEditorCancel
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "cmdCancel_Click", "frmEditor_Spell", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub scrlAccess_Change()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If scrlAccess.value > 0 Then
        lblAccess.Caption = "Access Required: " & scrlAccess.value
    Else
        lblAccess.Caption = "Access Required: None"
    End If
    Spell(EditorIndex).AccessReq = scrlAccess.value
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "scrlAccess_Change", "frmEditor_Spell", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub scrlAnim_Change()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If scrlAnim.value > 0 Then
        lblAnim.Caption = "Animation: " & Trim$(Animation(scrlAnim.value).name)
    Else
        lblAnim.Caption = "Animation: None"
    End If
    Spell(EditorIndex).SpellAnim = scrlAnim.value
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "scrlAnim_Change", "frmEditor_Spell", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub scrlAnimCast_Change()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If scrlAnimCast.value > 0 Then
        lblAnimCast.Caption = "Cast Anim: " & Trim$(Animation(scrlAnimCast.value).name)
    Else
        lblAnimCast.Caption = "Cast Anim: None"
    End If
    Spell(EditorIndex).CastAnim = scrlAnimCast.value
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "scrlAnimCast_Change", "frmEditor_Spell", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub scrlAOE_Change()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If scrlAOE.value > 0 Then
        lblAOE.Caption = "AoE: " & scrlAOE.value & " tiles."
    Else
        lblAOE.Caption = "AoE: Self-cast"
    End If
    Spell(EditorIndex).AoE = scrlAOE.value
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "scrlAOE_Change", "frmEditor_Spell", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub scrlArrow_Change()
If scrlArrow.value > 0 Then
        'lblArrow.Caption = scrlArrow.Value & ":" & Arrows(scrlArrow.Value).Name
    Else
       ' lblArrow.Caption = "Arrow:Nenhuma"
    End If
   ' Spell(EditorIndex).Arrow = scrlArrow.Value
End Sub

Private Sub scrlBaseStat_Change()
'
Select Case scrlBaseStat.value
  Case 0
    lblBaseStat.Caption = "Stat:Nenhum"
  Case 1
    lblBaseStat.Caption = "Stat:Strength"
  Case 2
    lblBaseStat.Caption = "Stat:Intelligence"
  Case 3
    lblBaseStat.Caption = "Stat:Agillity"
  Case 4
    lblBaseStat.Caption = "Stat:Endurance"
  Case 5
    lblBaseStat.Caption = "Stat:WillPower"
End Select

    Spell(EditorIndex).BaseStat = scrlBaseStat.value
End Sub

Private Sub scrlCast_Change()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    lblCast.Caption = "Casting Time: " & scrlCast.value & "s"
    Spell(EditorIndex).CastTime = scrlCast.value
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "scrlCast_Change", "frmEditor_Spell", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub scrlCool_Change()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    lblCool.Caption = "Cooldown Time: " & scrlCool.value & "s"
    Spell(EditorIndex).CDTime = scrlCool.value
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "scrlCool_Change", "frmEditor_Spell", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub scrlDir_Change()
Dim sDir As String
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    Select Case scrlDir.value
        Case DIR_UP
            sDir = "Up"
        Case DIR_DOWN
            sDir = "Down"
        Case DIR_RIGHT
            sDir = "Right"
        Case DIR_LEFT
            sDir = "Left"
    End Select
    lblDir.Caption = "Dir: " & sDir
    Spell(EditorIndex).Dir = scrlDir.value
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "scrlDir_Change", "frmEditor_Spell", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub scrlDist_Change()
If scrlDist.value > 0 Then
        lblDist.Caption = "Dist:" & scrlDist.value
    Else
        lblDist.Caption = "Dist:Nenhuma"
    End If
    Spell(EditorIndex).Dist = scrlDist.value
End Sub

Private Sub scrlDuration_Change()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    If scrlDuration.value > 10 Then
        scrlDuration.value = 10
        MsgBox "A duração máxima é 10 segundos"
    End If
    
    lblDuration.Caption = "Duration: " & scrlDuration.value & "s"
    Spell(EditorIndex).Duration = scrlDuration.value
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "scrlDuration_Change", "frmEditor_Spell", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub scrlExpelir_Change()
If scrlExpelir.value > 0 Then
        lblExpelir.Caption = "Expelir:" & scrlExpelir.value
    Else
        lblExpelir.Caption = "Expelir:0"
    End If
    Spell(EditorIndex).Expelir = scrlExpelir.value
End Sub

Private Sub scrlIcon_Change()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If scrlIcon.value > 0 Then
        lblIcon.Caption = "Icon: " & scrlIcon.value
    Else
        lblIcon.Caption = "Icon: None"
    End If
    Spell(EditorIndex).Icon = scrlIcon.value
    EditorSpell_BltIcon
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "scrlIcon_Change", "frmEditor_Spell", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub scrlInterval_Change()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    If scrlInterval.value < 1 Then
        scrlInterval.value = 1
    End If
    
    lblInterval.Caption = "Interval: " & scrlInterval.value & "s"
    Spell(EditorIndex).Interval = scrlInterval.value
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "scrlInterval_Change", "frmEditor_Spell", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub scrlLevel_Change()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If scrlLevel.value > 0 Then
        lblLevel.Caption = "Level Required: " & scrlLevel.value
    Else
        lblLevel.Caption = "Level Required: None"
    End If
    Spell(EditorIndex).LevelReq = scrlLevel.value
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "scrlLevel_Change", "frmEditor_Spell", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub scrlMap_Change()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    lblMap.Caption = "Map: " & scrlMap.value
    Spell(EditorIndex).MAP = scrlMap.value
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "scrlMap_Change", "frmEditor_Spell", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub scrlMP_Change()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If scrlMP.value > 0 Then
        lblMP.Caption = "MP Cost: " & scrlMP.value
    Else
        lblMP.Caption = "MP Cost: None"
    End If
    Spell(EditorIndex).MPCost = scrlMP.value
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "scrlMP_Change", "frmEditor_Spell", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub scrlMultipla_Change()
If scrlMultipla.value > 0 Then
        lblMultipla.Caption = "Multipla:" & scrlMultipla.value
    Else
        lblMultipla.Caption = "Multipla:0"
    End If
    Spell(EditorIndex).Multipla = scrlMultipla.value
End Sub

Private Sub scrlPet_Change()
If EditorIndex < 1 Or EditorIndex > MAX_SPELLS Then Exit Sub

If scrlPet.value > 0 Then
        lblPet.Caption = "Pet:" & Npc(scrlPet.value).name
    Else
        lblPet.Caption = "Pet:Nenhum"
    End If
    Spell(EditorIndex).PetNum = scrlPet.value
End Sub

Private Sub scrlRange_Change()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If scrlRange.value > 0 Then
        lblRange.Caption = "Range: " & scrlRange.value & " tiles."
    Else
        lblRange.Caption = "Range: Self-cast"
    End If
    Spell(EditorIndex).Range = scrlRange.value
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "scrlRange_Change", "frmEditor_Spell", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub scrlReqDojutsu_Change()
If EditorIndex < 1 Or EditorIndex > MAX_SPELLS Then Exit Sub

If scrlReqDojutsu.value > 0 Then
        lblReqDojutsu.Caption = "Dojutsu:" & scrlReqDojutsu.value
    Else
        lblReqDojutsu.Caption = "Dojutsu:Nenhum"
    End If
    Spell(EditorIndex).ReqDojutsu = scrlReqDojutsu.value
End Sub

Private Sub scrlReqTrans_Change()
If EditorIndex < 1 Or EditorIndex > MAX_SPELLS Then Exit Sub

If scrlReqTrans.value > 0 Then
        lblReqTrans.Caption = "Trans:" & scrlReqTrans.value
    Else
        lblReqTrans.Caption = "Trans:Nenhuma"
    End If
    Spell(EditorIndex).ReqTrans = scrlReqTrans.value
End Sub

Private Sub scrlRetaAnim_Change(Index As Integer)
Dim i As Byte

If chkMultiAnim.value = YES Then
    If scrlRetaAnim(Index).value > 0 Then
        lblRetaAnim(Index).Caption = scrlRetaAnim(Index).value & ":" & Animation(scrlRetaAnim(Index).value).name
    Else
        lblRetaAnim(Index).Caption = "Anim:Nenhuma"
    End If
    
Else

    For i = 2 To 4
        lblRetaAnim(i).Visible = False
        scrlRetaAnim(i).Visible = False
    Next
        If scrlRetaAnim(1).value > 0 Then
            lblRetaAnim(1).Caption = scrlRetaAnim(1).value & ":" & Animation(scrlRetaAnim(1).value).name
        Else
            lblRetaAnim(1).Caption = "Anim:Nenhuma"
        End If
End If

Spell(EditorIndex).RetaAnim(Index) = scrlRetaAnim(Index).value
End Sub

Private Sub scrlScript_Change()
If scrlScript.value > 0 Then
        lblScript.Caption = "Script:" & scrlScript.value
    Else
        lblScript.Caption = "Script:0"
    End If
    Spell(EditorIndex).Script = scrlScript.value
End Sub

Private Sub scrlStun_Change()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If scrlStun.value > 0 Then
        lblStun.Caption = "Stun Duration: " & scrlStun.value & "s"
    Else
        lblStun.Caption = "Stun Duration: None"
    End If
    Spell(EditorIndex).StunDuration = scrlStun.value
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "scrlStun_Change", "frmEditor_Spell", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub scrlVital_Change()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    lblVital.Caption = "Vital: " & scrlVital.value
    Spell(EditorIndex).Vital = scrlVital.value
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "scrlVital_Change", "frmEditor_Spell", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub scrlX_Change()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    lblX.Caption = "X: " & scrlX.value
    Spell(EditorIndex).X = scrlX.value
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "scrlX_Change", "frmEditor_Spell", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub scrlY_Change()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    lblY.Caption = "Y: " & scrlY.value
    Spell(EditorIndex).Y = scrlY.value
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "scrlY_Change", "frmEditor_Spell", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub txtDesc_Change()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    Spell(EditorIndex).Desc = txtDesc.text
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "txtDesc_Change", "frmEditor_Spell", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub txtMP_Change()
If EditorIndex < 1 Or EditorIndex > MAX_SPELLS Then Exit Sub
    If IsNumeric(txtMP.text) Then
        If txtMP.text > 0 Then
            lblMP.Caption = "MP:" & txtMP.text
        Else
            lblMP.Caption = "MP:Nenhum"
        End If
        
        Spell(EditorIndex).MPCost = txtMP.text
    Else
        MsgBox "O MP precisa ser somente número"
        txtMP.text = vbNullString
    End If
    
End Sub

Private Sub txtName_Validate(Cancel As Boolean)
Dim tmpIndex As Long

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If EditorIndex = 0 Then Exit Sub
    tmpIndex = lstIndex.ListIndex
    Spell(EditorIndex).name = Trim$(txtName.text)
    lstIndex.RemoveItem EditorIndex - 1
    lstIndex.AddItem EditorIndex & ": " & Spell(EditorIndex).name, EditorIndex - 1
    lstIndex.ListIndex = tmpIndex
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "txtName_Validate", "frmEditor_Spell", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub cmbSound_Click()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    If cmbSound.ListIndex >= 0 Then
        Spell(EditorIndex).Sound = cmbSound.List(cmbSound.ListIndex)
    Else
        Spell(EditorIndex).Sound = "None."
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "cmdSound_Click", "frmEditor_Spell", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub txtVital_Change()
If EditorIndex < 1 Or EditorIndex > MAX_SPELLS Then Exit Sub

If IsNumeric(txtVital.text) Then
    If txtVital.text > 0 Then
        lblVital.Caption = "Vital:" & txtVital.text
    Else
        lblVital.Caption = "Vital:Nenhuma"
    End If
    
    If Val(txtVital.text) > 3000 Then
        MsgBox "O limite vital é 3k"
        txtVital.text = "3000"
        Unload frmEditor_Spell
        Exit Sub
    End If
    
    Spell(EditorIndex).Vital = txtVital.text
Else
    txtVital.text = vbNullString
    MsgBox "A vital precisa ser número"
End If

End Sub
