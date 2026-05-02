Attribute VB_Name = "modText"
Option Explicit

' Text declares
Private Declare Function CreateFont Lib "gdi32" Alias "CreateFontA" (ByVal H As Long, ByVal W As Long, ByVal E As Long, ByVal O As Long, ByVal W As Long, ByVal i As Long, ByVal u As Long, ByVal S As Long, ByVal c As Long, ByVal OP As Long, ByVal CP As Long, ByVal Q As Long, ByVal PAF As Long, ByVal f As String) As Long
Private Declare Function SetBkMode Lib "gdi32" (ByVal hdc As Long, ByVal nBkMode As Long) As Long
Private Declare Function SetTextColor Lib "gdi32" (ByVal hdc As Long, ByVal crColor As Long) As Long
Private Declare Function TextOut Lib "gdi32" Alias "TextOutA" (ByVal hdc As Long, ByVal X As Long, ByVal Y As Long, ByVal lpString As String, ByVal nCount As Long) As Long
Private Declare Function SelectObject Lib "gdi32" (ByVal hdc As Long, ByVal hObject As Long) As Long
Private Declare Function DeleteObject Lib "gdi32" (ByVal hObject As Long) As Long

' Used to set a font for GDI text drawing
Public Sub SetFont(ByVal Font As String, ByVal Size As Byte)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    GameFont = CreateFont(Size, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, FONT_NAME)
    frmMain.Font = FONT_NAME
    frmMain.FontSize = Size - 8
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "SetFont", "modText", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' GDI text drawing onto buffer
' GDI text drawing onto buffer
Public Sub DrawText(ByVal hdc As Long, ByVal X, ByVal Y, ByVal text As String, color As Long)
    ' If debug mode, handle error then exit out
    Dim OldFont As Long ' HFONT
    
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    Call SetFont(FONT_NAME, FONT_SIZE)
    OldFont = SelectObject(hdc, GameFont)
    Call SetBkMode(hdc, vbTransparent)
    
    Call SetTextColor(hdc, 0)
    Call TextOut(hdc, X + 1, Y, text, Len(text))
    Call TextOut(hdc, X, Y + 1, text, Len(text))
    Call TextOut(hdc, X - 1, Y, text, Len(text))
    Call TextOut(hdc, X, Y - 1, text, Len(text))
    Call TextOut(hdc, X + 1, Y + 1, text, Len(text))
    Call TextOut(hdc, X - 1, Y - 1, text, Len(text))
    Call TextOut(hdc, X + 1, Y - 1, text, Len(text))
    Call TextOut(hdc, X + 1, Y - 1, text, Len(text))
    
    Call SetTextColor(hdc, color)
    Call TextOut(hdc, X, Y, text, Len(text))
    
    Call SelectObject(hdc, OldFont)
    Call DeleteObject(GameFont)
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "DrawText", "modText", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Sub DrawPlayerName(ByVal Index As Long)
If Player(Index).Invisivel = YES Then Exit Sub
Dim TextX As Long
Dim TextY As Long
Dim color As Long
Dim name As String

If GetPlayerMap(Index) = 296 And Player(Index).PKstate > 0 Then Exit Sub

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    ' Check access level
    If GetPlayerAccess(Index) > 1 Then
            color = QBColor(Magenta)
    Else
        If Player(Index).Karma >= 0 Then
            Select Case Player(Index).Karma
                Case 0 To 100
                    color = QBColor(BrightBlue)
                Case 101 To 300
                    color = QBColor(Cyan)
                Case 301 To 500
                    color = QBColor(BrightCyan)
                Case 501 To 1000
                    color = QBColor(BrightGreen)
                Case 1001 To MAX_LONG
                    color = QBColor(White)
                Case Else
                    color = QBColor(Brown)
            End Select
        Else
            Select Case Player(Index).Karma
                Case -299 To -1
                    color = QBColor(Black)
                Case -499 To -300
                    color = QBColor(Red)
                Case -MAX_LONG To -500
                    color = QBColor(BrightRed)
                Case Else
                    color = QBColor(Black)
            End Select
        End If
    End If
    
    If Options.NomeLevel = 0 Then 'Ativado
        name = "Lv." & GetPlayerLevel(Index) & " : " & Trim$(Player(Index).name)
    Else
        name = Trim$(Player(Index).name)
    End If
    
    ' calc pos
    TextX = ConvertMapX(GetPlayerX(Index) * PIC_X) + Player(Index).XOffset + (PIC_X \ 2) - getWidth(TexthDC, (Trim$(name)))
    If GetPlayerSprite(Index) < 1 Or GetPlayerSprite(Index) > NumCharacters Then
        TextY = ConvertMapY(GetPlayerY(Index) * PIC_Y) + Player(Index).YOffset - 16
    Else
        ' Determine location for text
        TextY = ConvertMapY(GetPlayerY(Index) * PIC_Y) + Player(Index).YOffset - (DDSD_Character(GetPlayerSprite(Index)).lHeight / 4) + 25
    End If

    ' Draw name
    Call DrawText(TexthDC, TextX, TextY, name, color)
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "DrawPlayerName", "modText", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Sub DrawNpcName(ByVal Index As Long)
Dim TextX As Long
Dim TextY As Long
Dim color As Long
Dim name As String
Dim npcNum As Long

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    npcNum = MapNpc(Index).num

    Select Case Npc(npcNum).Behaviour
        Case NPC_BEHAVIOUR_ATTACKONSIGHT
            color = QBColor(BrightRed)
        Case NPC_BEHAVIOUR_ATTACKWHENATTACKED
            color = QBColor(Yellow)
        Case NPC_BEHAVIOUR_GUARD
            color = QBColor(Grey)
        Case NPC_BEHAVIOUR_SUBORDINADO
            color = QBColor(Cyan)
        Case NPC_BEHAVIOUR_BOSS
            color = QBColor(White)
        Case Else
            color = QBColor(BrightGreen)
    End Select

    If Npc(npcNum).Behaviour <> NPC_BEHAVIOUR_FRIENDLY And Npc(npcNum).Behaviour <> NPC_BEHAVIOUR_SHOPKEEPER Then
        name = Trim$(Npc(npcNum).name) & " (Lv:" & Npc(npcNum).Level & ")"
    Else
        name = Trim$(Npc(npcNum).name)
    End If
    
    TextX = ConvertMapX(MapNpc(Index).X * PIC_X) + MapNpc(Index).XOffset + (PIC_X \ 2) - getWidth(TexthDC, (Trim$(name)))
    If Npc(npcNum).Sprite < 1 Or Npc(npcNum).Sprite > NumCharacters Then
        TextY = ConvertMapY(MapNpc(Index).Y * PIC_Y) + MapNpc(Index).YOffset - 16
    Else
        ' Determine location for text
        TextY = ConvertMapY(MapNpc(Index).Y * PIC_Y) + MapNpc(Index).YOffset - (DDSD_Character(Npc(npcNum).Sprite).lHeight / 4) + 16
    End If

    ' Draw name
    Call DrawText(TexthDC, TextX, TextY, name, color)
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "DrawNpcName", "modText", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Function BltMapAttributes()
    Dim X As Long
    Dim Y As Long
    Dim tX As Long
    Dim tY As Long
    
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    If frmEditor_Map.optAttribs.value Then
        For X = TileView.Left To TileView.Right
            For Y = TileView.top To TileView.Bottom
                If IsValidMapPoint(X, Y) Then
                    With MAP.Tile(X, Y)
                        tX = ((ConvertMapX(X * PIC_X)) - 4) + (PIC_X * 0.5)
                        tY = ((ConvertMapY(Y * PIC_Y)) - 7) + (PIC_Y * 0.5)
                        Select Case .Type
                            Case TILE_TYPE_BLOCKED
                                DrawText TexthDC, tX, tY, "B", QBColor(BrightRed)
                            Case TILE_TYPE_WARP
                                DrawText TexthDC, tX, tY, "W", QBColor(BrightBlue)
                            Case TILE_TYPE_ITEM
                                DrawText TexthDC, tX, tY, "I", QBColor(White)
                            Case TILE_TYPE_NPCAVOID
                                DrawText TexthDC, tX, tY, "N", QBColor(White)
                            Case TILE_TYPE_KEY
                                DrawText TexthDC, tX, tY, "K", QBColor(White)
                            Case TILE_TYPE_KEYOPEN
                                DrawText TexthDC, tX, tY, "O", QBColor(White)
                            Case TILE_TYPE_RESOURCE
                                DrawText TexthDC, tX, tY, "O", QBColor(Green)
                            Case TILE_TYPE_DOOR
                                DrawText TexthDC, tX, tY, "D", QBColor(Brown)
                            Case TILE_TYPE_NPCSPAWN
                                DrawText TexthDC, tX, tY, "S", QBColor(Yellow)
                            Case TILE_TYPE_SHOP
                                DrawText TexthDC, tX, tY, "S", QBColor(BrightBlue)
                            Case TILE_TYPE_BANK
                                DrawText TexthDC, tX, tY, "B", QBColor(Blue)
                            Case TILE_TYPE_HEAL
                                DrawText TexthDC, tX, tY, "H", QBColor(BrightGreen)
                            Case TILE_TYPE_TRAP
                                DrawText TexthDC, tX, tY, "T", QBColor(BrightRed)
                            Case TILE_TYPE_SLIDE
                                DrawText TexthDC, tX, tY, "S", QBColor(BrightCyan)
                            Case TILE_TYPE_ONCLICK
                                DrawText TexthDC, tX, tY, "C", QBColor(BrightBlue)
                            Case TILE_TYPE_SCRIPT
                                DrawText TexthDC, tX, tY, "SC", QBColor(BrightCyan)
                        
                        End Select
                    End With
                End If
            Next
        Next
    End If

    ' Error handler
    Exit Function
errorhandler:
    HandleError "BltMapAttributes", "modText", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Function
End Function

Sub BltActionMsg(ByVal Index As Long)
    Dim X As Long, Y As Long, i As Long, time As Long
    
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    ' does it exist
    If ActionMsg(Index).Created = 0 Then Exit Sub

    ' how long we want each message to appear
    Select Case ActionMsg(Index).Type
        Case ACTIONMSG_STATIC
            time = 1500

            If ActionMsg(Index).Y > 0 Then
                X = ActionMsg(Index).X + Int(PIC_X \ 2) - ((Len(Trim$(ActionMsg(Index).message)) \ 2) * 8)
                Y = ActionMsg(Index).Y - Int(PIC_Y \ 2) - 2
            Else
                X = ActionMsg(Index).X + Int(PIC_X \ 2) - ((Len(Trim$(ActionMsg(Index).message)) \ 2) * 8)
                Y = ActionMsg(Index).Y - Int(PIC_Y \ 2) + 18
            End If

        Case ACTIONMSG_SCROLL
            time = 1500
        
            If ActionMsg(Index).Y > 0 Then
                X = ActionMsg(Index).X + Int(PIC_X \ 2) - ((Len(Trim$(ActionMsg(Index).message)) \ 2) * 8)
                Y = ActionMsg(Index).Y - Int(PIC_Y \ 2) - 2 - (ActionMsg(Index).Scroll * 0.6)
                ActionMsg(Index).Scroll = ActionMsg(Index).Scroll + 1
            Else
                X = ActionMsg(Index).X + Int(PIC_X \ 2) - ((Len(Trim$(ActionMsg(Index).message)) \ 2) * 8)
                Y = ActionMsg(Index).Y - Int(PIC_Y \ 2) + 18 + (ActionMsg(Index).Scroll * 0.6)
                ActionMsg(Index).Scroll = ActionMsg(Index).Scroll + 1
            End If

        Case ACTIONMSG_SCREEN
            time = 3000

            ' This will kill any action screen messages that there in the system
            For i = MAX_BYTE To 1 Step -1
                If ActionMsg(i).Type = ACTIONMSG_SCREEN Then
                    If i <> Index Then
                        ClearActionMsg Index
                        Index = i
                    End If
                End If
            Next
            X = (frmMain.picScreen.width \ 2) - ((Len(Trim$(ActionMsg(Index).message)) \ 2) * 8)
            Y = 425

    End Select
    
    X = ConvertMapX(X)
    Y = ConvertMapY(Y)

    If GetTickCount < ActionMsg(Index).Created + time Then
        Call DrawText(TexthDC, X, Y, ActionMsg(Index).message, QBColor(ActionMsg(Index).color))
    Else
        ClearActionMsg Index
    End If

    ' Error handler
    Exit Sub
errorhandler:
    HandleError "BltActionMsg", "modText", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Function getWidth(ByVal DC As Long, ByVal text As String) As Long
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    getWidth = frmMain.TextWidth(text) \ 2
    
    ' Error handler
    Exit Function
errorhandler:
    HandleError "getWidth", "modText", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Function
End Function

Public Sub AddTextPrivado(ByVal Msg As String, ByVal color As Integer)
Dim S As String

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    S = vbNewLine & Msg
    frmChatPrivado.txtChat.SelStart = Len(frmChatPrivado.txtChat.text)
    frmChatPrivado.txtChat.SelColor = QBColor(color)
    frmChatPrivado.txtChat.SelText = S
    frmChatPrivado.txtChat.SelStart = Len(frmChatPrivado.txtChat.text) - 1
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "AddText", "modText", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Sub AddText(ByVal Msg As String, ByVal color As Integer)
Dim S As String

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    S = vbNewLine & Msg
    frmMain.txtChat.SelStart = Len(frmMain.txtChat.text)
    frmMain.txtChat.SelColor = QBColor(color)
    frmMain.txtChat.SelText = S
    frmMain.txtChat.SelStart = Len(frmMain.txtChat.text) - 1
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "AddText", "modText", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Sub DrawPlayerRank(ByVal Index As Long)
If Player(Index).Invisivel = YES Then Exit Sub
If Player(Index).Rank = 0 Then Exit Sub

If GetPlayerMap(Index) = 296 And Player(Index).PKstate > 0 Then Exit Sub

Dim TextX As Long
Dim TextY As Long
Dim color As Long
Dim name As String

Select Case Player(Index).Rank
    Case RANK_ESTUDANTE
        name = "Estudante"
        color = QBColor(Green)
    Case RANK_GENIN
        name = "Genin"
        color = QBColor(BrightGreen)
    Case RANK_CHUNIN
        name = "Chunin"
        color = QBColor(Blue)
    Case RANK_JOUNIN
        name = "Jounin"
        color = QBColor(BrightBlue)
    Case RANK_ANBU
        name = "ANBU"
        color = QBColor(Grey)
    Case RANK_SANNIN
        name = "Sannin"
        color = QBColor(Cyan)
    Case RANK_KAGE
        Select Case Player(Index).Vila
            Case 0 'Vila da Chuva
                name = "Líder da Chuva"
                color = QBColor(Black)
            Case 1 'Konoha
                name = "Hokage"
                color = QBColor(BrightRed)
            Case 2 'Suna
                name = "Kazekage"
                color = QBColor(Cyan)
            Case 3 'Kiri
                name = "Mizukage"
                color = QBColor(Blue)
            Case 4 'Iwa
                name = "Tsuchikage"
                color = QBColor(Brown)
            Case 5 'Kumo
                name = "Raikage"
                color = QBColor(Yellow)
            Case 6 'Vila da som
                name = "Líder do Som"
                color = QBColor(Black)
                
            Case Else
                name = "Kage"
                color = QBColor(White)
        End Select
    Case RANK_DESERTOR
        name = "Desertor"
        color = QBColor(BrightRed)
    Case Else
End Select
    
    ' calc pos
    TextX = ConvertMapX(GetPlayerX(Index) * PIC_X) + Player(Index).XOffset + (PIC_X \ 2) - getWidth(TexthDC, (Trim$(name)))
    If GetPlayerSprite(Index) < 1 Or GetPlayerSprite(Index) > NumCharacters Then
        TextY = ConvertMapY(GetPlayerY(Index) * PIC_Y) + Player(Index).YOffset - 10
    Else
        ' Determine location for text
        TextY = ConvertMapY(GetPlayerY(Index) * PIC_Y) + Player(Index).YOffset - (DDSD_Character(GetPlayerSprite(Index)).lHeight / 4) + 5
    End If

    ' Draw name
    Call DrawText(TexthDC, TextX, TextY, name, color)
    
   
End Sub

Public Sub DrawPlayerLendario(ByVal Index As Long)
If Player(Index).Invisivel = YES Then Exit Sub
If Player(Index).MAP = 296 Then Exit Sub 'temos que pegar
If Player(Index).Lendario = NO Then Exit Sub

Dim TextX As Long
Dim TextY As Long
Dim color As Long
Dim name As String


    name = "Lendário"
    color = QBColor(White)
   

    ' calc pos
    TextX = ConvertMapX(GetPlayerX(Index) * PIC_X) + Player(Index).XOffset + (PIC_X \ 2) - getWidth(TexthDC, (Trim$(name)))
    If GetPlayerSprite(Index) < 1 Or GetPlayerSprite(Index) > NumCharacters Then
        TextY = ConvertMapY(GetPlayerY(Index) * PIC_Y) + Player(Index).YOffset + 8
    Else
        ' Determine location for text
        TextY = ConvertMapY(GetPlayerY(Index) * PIC_Y) + Player(Index).YOffset - (DDSD_Character(GetPlayerSprite(Index)).lHeight / 4) + 110
    End If

    ' Draw name
    Call DrawText(TexthDC, TextX, TextY, name, color)
    
   
End Sub

Public Sub DrawPlayerBerserker(ByVal Index As Long)
If Player(Index).Invisivel = YES Then Exit Sub
If Player(Index).MAP = 296 Then Exit Sub 'temos que pegar
If Player(Index).Berserker <> YES Then Exit Sub

Dim TextX As Long
Dim TextY As Long
Dim color As Long
Dim name As String


    name = ">>BERSERKER<<"
    color = QBColor(BrightRed)
   

    ' calc pos
    TextX = ConvertMapX(GetPlayerX(Index) * PIC_X) + Player(Index).XOffset + (PIC_X \ 2) - getWidth(TexthDC, (Trim$(name)))
    If GetPlayerSprite(Index) < 1 Or GetPlayerSprite(Index) > NumCharacters Then
        TextY = ConvertMapY(GetPlayerY(Index) * PIC_Y) + Player(Index).YOffset + 8
    Else
        ' Determine location for text
        TextY = ConvertMapY(GetPlayerY(Index) * PIC_Y) + Player(Index).YOffset - (DDSD_Character(GetPlayerSprite(Index)).lHeight / 4) + 110
    End If

    ' Draw name
    Call DrawText(TexthDC, TextX, TextY, name, color)
    
   
End Sub

Public Sub DrawPlayerOrg(ByVal Index As Long)
If Player(Index).Invisivel = YES Then Exit Sub
If Player(Index).War = NO Then
    If Player(Index).Org < 1 Then Exit Sub
End If

If Player(Index).MAP = 296 Then Exit Sub 'temos que pegar

Dim TextX As Long
Dim TextY As Long
Dim color As Long
Dim name As String

If Player(Index).War = NO Then

Select Case Player(Index).Org
    Case ORG_POLICIAKONOHA
        name = "Polícia de Konoha"
        color = QBColor(Red)
    Case ORG_HOSPITAL
        name = "Hospital"
        color = QBColor(BrightGreen)
    Case ORG_TAKA
        name = "Taka"
        color = QBColor(BrightBlue)
    Case ORG_AKATSUKI
        name = "Akatsuki"
        color = QBColor(BrightRed)
    'Case ORG_ANBU
        'Name = "ANBU"
        'color = QBColor(DarkGrey)
    Case ORG_ANBURAIZ
        name = "ANBU Raíz"
        color = QBColor(DarkGrey)
    Case ORG_7ESPADACHINS
        name = "Espadachins da Névoa"
        color = QBColor(Cyan)
    Case ORG_12GUARDIOES
        name = "Guardiões"
        color = QBColor(Blue)
    'Case ORG_ALIANÇA
        'Name = "Aliança Shinobi"
        'color = QBColor(White)
    Case ORG_FREE
        name = "Laços Ninja"
        color = QBColor(White)
    Case ORG_ESQUADRAO
        name = "Esquadrão Shinobi"
        color = QBColor(Magenta)
    Case ORG_RENEGADOS
        name = "Elite Shinobi"
        color = QBColor(White)
    Case Else
        Exit Sub
End Select

Else
    If Player(Index).War = 1 Then 'bem
        name = "Aliança Shinobi"
        color = QBColor(White)
    Else
        name = "Tsuki no Me"
        color = QBColor(Black)
    End If
End If

    ' calc pos
    TextX = ConvertMapX(GetPlayerX(Index) * PIC_X) + Player(Index).XOffset + (PIC_X \ 2) - getWidth(TexthDC, (Trim$(name)))
    If GetPlayerSprite(Index) < 1 Or GetPlayerSprite(Index) > NumCharacters Then
        TextY = ConvertMapY(GetPlayerY(Index) * PIC_Y) + Player(Index).YOffset + 8
    Else
        ' Determine location for text
        TextY = ConvertMapY(GetPlayerY(Index) * PIC_Y) + Player(Index).YOffset - (DDSD_Character(GetPlayerSprite(Index)).lHeight / 4) - 8
    End If

    ' Draw name
    Call DrawText(TexthDC, TextX, TextY, name, color)
    
   
End Sub

Public Sub DrawPlayerPK(ByVal Index As Long)
If Player(Index).Invisivel = YES Then Exit Sub
If Player(Index).PKstate = 0 Then Exit Sub

Dim TextX As Long
Dim TextY As Long
Dim color As Long
Dim name As String


        name = "PK" & Player(Index).PKstate
        color = QBColor(BrightRed)
        
        If Player(Index).MAP = 296 Then 'temos que pegar
            If Player(Index).PKstate = 1 Then 'pokemon
                name = "POQUEMÃO"
                color = QBColor(White)
            ElseIf Player(Index).PKstate = 2 Then 'ash
                name = "ÉCHI"
                color = QBColor(BrightRed)
            End If
        End If
    
    ' calc pos
    TextX = ConvertMapX(GetPlayerX(Index) * PIC_X) + Player(Index).XOffset + (PIC_X \ 2) - getWidth(TexthDC, (Trim$(name)))
    If GetPlayerSprite(Index) < 1 Or GetPlayerSprite(Index) > NumCharacters Then
        TextY = ConvertMapY(GetPlayerY(Index) * PIC_Y) + Player(Index).YOffset - 10
    Else
        ' Determine location for text
        TextY = ConvertMapY(GetPlayerY(Index) * PIC_Y) + Player(Index).YOffset - (DDSD_Character(GetPlayerSprite(Index)).lHeight / 4) + 95
    End If

    ' Draw name
    Call DrawText(TexthDC, TextX, TextY, name, color)
    
   
End Sub
