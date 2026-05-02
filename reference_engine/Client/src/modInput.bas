Attribute VB_Name = "modInput"
Option Explicit
' keyboard input
Public Declare Function GetAsyncKeyState Lib "user32" (ByVal vKey As Long) As Integer
Public Declare Function GetKeyState Lib "user32" (ByVal nVirtKey As Long) As Integer

Public Sub CheckKeys()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    If GetAsyncKeyState(VK_UP) >= 0 Then DirUp = False
    If GetAsyncKeyState(VK_DOWN) >= 0 Then DirDown = False
    If GetAsyncKeyState(VK_LEFT) >= 0 Then DirLeft = False
    If GetAsyncKeyState(VK_RIGHT) >= 0 Then DirRight = False
    If GetAsyncKeyState(VK_CONTROL) >= 0 Then ControlDown = False
    If GetAsyncKeyState(VK_SHIFT) >= 0 Then ShiftDown = False
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "CheckKeys", "modInput", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Sub CheckInputKeys()
    
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    If COUNT_FREEZE = YES Then
        'AddText "Você não pode se mover..", Red
        Exit Sub
    End If
    
    If enableChatTmr <= 0 Then frmMain.txtMyChat.Enabled = True
    
    If GetKeyState(vbKeyShift) < 0 Then
        ShiftDown = True
    Else
        ShiftDown = False
    End If

    If GetKeyState(vbKeyReturn) < 0 Then
        CheckMapGetItem
    End If

    If GetKeyState(vbKeyControl) < 0 Then
        ControlDown = True
    Else
        ControlDown = False
    End If
    
    'vbkeymenu
    If GetKeyState(93) < 0 Then
        frmMain.txtMyChat.Enabled = False
        'If CanKick = True Then
            'AntiSpeed1 = NO
            'AntiSpeed2 = NO
            'logoutGame
            'MsgBox "Você apertou a tecla de menu(ao lado do ctrl e alt gr. Essa tecla buga o jogo e a única forma de solucionar foi kikando o jogador)."
        'End If
    End If
    
    'Move Up
    If GetKeyState(vbKeyUp) < 0 Then
        DirUp = True
        DirDown = False
        DirLeft = False
        DirRight = False
        Exit Sub
    Else
        DirUp = False
    End If

    'Move Right
    If GetKeyState(vbKeyRight) < 0 Then
        DirUp = False
        DirDown = False
        DirLeft = False
        DirRight = True
        Exit Sub
    Else
        DirRight = False
    End If

    'Move down
    If GetKeyState(vbKeyDown) < 0 Then
        DirUp = False
        DirDown = True
        DirLeft = False
        DirRight = False
        Exit Sub
    Else
        DirDown = False
    End If

    'Move left
    If GetKeyState(vbKeyLeft) < 0 Then
        DirUp = False
        DirDown = False
        DirLeft = True
        DirRight = False
        Exit Sub
    Else
        DirLeft = False
    End If
    
    'If we aren't focused on the chat, let's see if we use W/A/S/D to move
    'If ChatFocus = False Then
    If Options.WASD = YES Then
        'Move Up (W)
        If GetKeyState(vbKeyW) < 0 Then
            DirUp = True
            DirDown = False
            DirLeft = False
            DirRight = False
            Exit Sub
        Else
            DirUp = False
        End If
    
        'Move Right (D)
        If GetKeyState(vbKeyD) < 0 Then
            DirUp = False
            DirDown = False
            DirLeft = False
            DirRight = True
            Exit Sub
        Else
            DirRight = False
        End If
    
        'Move down (S)
        If GetKeyState(vbKeyS) < 0 Then
            DirUp = False
            DirDown = True
            DirLeft = False
            DirRight = False
            Exit Sub
        Else
            DirDown = False
        End If
    
        'Move left (A)
        If GetKeyState(vbKeyA) < 0 Then
            DirUp = False
            DirDown = False
            DirLeft = True
            DirRight = False
            Exit Sub
        Else
            DirLeft = False
        End If

    End If

    ' Error handler
    Exit Sub
errorhandler:
    HandleError "CheckInputKeys", "modInput", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Sub HandleKeyPresses(ByVal KeyAscii As Integer)
Dim ChatText As String
Dim name As String
Dim i As Long
Dim n As Long
Dim Command() As String
Dim u As Byte
Dim buffer As clsBuffer

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    ChatText = Trim$(MyText)

    If LenB(ChatText) = 0 Then Exit Sub
    MyText = LCase$(ChatText)
    
    'evita o bug do chat vaziu
    If KeyAscii = 9 Or KeyAscii = 10 Or KeyAscii = 11 Or KeyAscii = 12 Then 'ctrl+enter
        AddText "Não use CTRL quando digitar algo! Isso buga o chat!", BrightRed
        GoTo Continue
    End If
    
    ' Handle when the player presses the return key
    If KeyAscii = vbKeyReturn Then
        If ChatDelay > 0 Then
            'AddText "Sem flood por favor :)", White
            Exit Sub
        End If
        
        ChatFocus = True
        
        Select Case frmMain.cmbChatMod.text
            Case "Global"
        ' Broadcast message
                'ChatText = Mid$(ChatText, 2, Len(ChatText))
                If muteChat = True Then
                    AddText "Seu chat global está mutado! Para desmutar use novamente o comando '/mutarchat'.", BrightRed
                    MyText = vbNullString
                    frmMain.txtMyChat.text = vbNullString
                    Exit Sub
                End If
                
                If Not ChatDelay > 0 Then
                    If Len(ChatText) > 0 Then
                        ChatDelay = GetTickCount + 5000
                        Call BroadcastMsg(ChatText)
                    End If
                Else
                    'AddText "Sem flood por favor :]", White
                End If
            
                MyText = vbNullString
                frmMain.txtMyChat.text = vbNullString
                Exit Sub
            Case "Org"
                If Not ChatDelay > 0 Then
                    If Len(ChatText) > 0 Then
                        ChatDelay = GetTickCount + 2000
                        Call OrgMsg(ChatText)
                    End If
                Else
                    'AddText "Sem flood por favor :]", White
                End If
            
                MyText = vbNullString
                frmMain.txtMyChat.text = vbNullString
                Exit Sub
                
            Case "Grupo"
                If Not ChatDelay > 0 Then
                    If Len(ChatText) > 0 Then
                        ChatDelay = GetTickCount + 2000
                        Call PartyMsg(ChatText)
                    End If
                Else
                    'AddText "Sem flood por favor :]", White
                End If
            
                MyText = vbNullString
                frmMain.txtMyChat.text = vbNullString
                Exit Sub
                
            Case "Vila"
                If Not ChatDelay > 0 Then
                    If Len(ChatText) > 0 Then
                        ChatDelay = GetTickCount + 2000
                        Call VilaMsg(ChatText)
                    End If
                Else
                    'AddText "Sem flood por favor :]", White
                End If
            
                MyText = vbNullString
                frmMain.txtMyChat.text = vbNullString
                Exit Sub
            Case "Privado" ' Emote message
               SendRequestPlayerNames
                frmMain.picChatInvite.Visible = True
               
            Exit Sub
            Case Else
        End Select


        ' Player message
        'If Left$(ChatText, 1) = "!" Then
            'Exit Sub
            'ChatText = Mid$(ChatText, 2, Len(ChatText) - 1)
            'Name = vbNullString

            ' Get the desired player from the user text
            'For i = 1 To Len(ChatText)

                'If Mid$(ChatText, i, 1) <> Space(1) Then
                    'Name = Name & Mid$(ChatText, i, 1)
                'Else
                    'Exit For
                'End If

            'Next

            'ChatText = Mid$(ChatText, i, Len(ChatText) - 1)

            ' Make sure they are actually sending something
            'If Len(ChatText) - i > 0 Then
                'MyText = Mid$(ChatText, i + 1, Len(ChatText) - i)
                ' Send the message to the player
                'Call PlayerMsg(ChatText, Name)
            'Else
                'Call AddText("Usage: !playername (message)", AlertColor)
            'End If

            'MyText = vbNullString
            'frmMain.txtMyChat.text = vbNullString
            'Exit Sub
        'End If

        If Left$(MyText, 1) = "/" Then
            Command = Split(MyText, Space(1))

            Select Case Command(0)
                'emotioNs
                Case "/:]"
                    EmoteMsg 99
                Case "/fuu"
                    EmoteMsg 100
                Case "/lol"
                    EmoteMsg 101
                Case "/susto"
                    EmoteMsg 102
                Case "/megusta"
                    EmoteMsg 103
                Case "/no"
                    EmoteMsg 104
                Case "/nossa"
                    EmoteMsg 105
                Case "/o_o"
                    EmoteMsg 106
                Case "/omg"
                    EmoteMsg 107
                Case "/pokerface"
                    EmoteMsg 108
                Case "/rsrs"
                    EmoteMsg 109
                Case "/troll"
                    EmoteMsg 110
                Case "/uau"
                    EmoteMsg 111
                Case "/yao"
                    EmoteMsg 112
                Case "/semroupa"
                    EmoteMsg 113
                Case "/planobkup"
                    EmoteMsg 114
                Case "/desistirdocargo"
                    If Player(MyIndex).Rank <> RANK_KAGE Then GoTo Continue
                    
                    Q_INDEX = Q_DESISTIRKAGE
        
                    frmMain.lblBlank(77).Caption = "Tem certeza que deseja desistir do cargo? Como tudo no nip, não há volta."
                    frmMain.picPergunta.Visible = True
                    
                Case "/painelvip"
                    frmMain.picVIP.top = 48
                    frmMain.picVIP.Left = 216
                    frmMain.picVIP.height = 329
                    frmMain.picVIP.width = 209
                    
                    If Player(MyIndex).VIP < 1 And Not Player(MyIndex).VipData.VIP > 0 Then
                        AddText "Apenas membros VIP's..", BrightRed
                    Else
                        frmMain.picVIP.Visible = Not frmMain.picVIP.Visible
                    End If
                Case "/painelextras"
                    frmMain.picExtras.Visible = Not frmMain.picExtras.Visible
                Case "/itachi"
                    EmoteMsg ITACHI
                Case "/madara"
                    EmoteMsg MADARA
                Case "/pain"
                    EmoteMsg PAIN
                Case "/hashirama"
                    EmoteMsg HASHIRAMA
                Case "/raikage"
                    EmoteMsg RAIKAGE
                Case "/sasori"
                    EmoteMsg SASORI
                Case "/org"
                    If GetPlayerAccess(MyIndex) < ADMIN_CREATOR Then GoTo Continue

                    If UBound(Command) < 2 Then
                        AddText "Usage: /org (nome) (org)", AlertColor
                        GoTo Continue
                    End If

                    If IsNumeric(Command(1)) Or Not IsNumeric(Command(2)) Then
                        AddText "Usage: /org (nome) (nível)", AlertColor
                        GoTo Continue
                    End If

                    SendSetOrganization Command(1), Command(2)
                
                Case "/vip"
                    If GetPlayerAccess(MyIndex) < ADMIN_CREATOR Then GoTo Continue

                    If UBound(Command) < 2 Then
                        AddText "Usage: /vip (nome) (nível)", AlertColor
                        GoTo Continue
                    End If

                    If IsNumeric(Command(1)) Or Not IsNumeric(Command(2)) Then
                        AddText "Usage: /vip (nome) (nível)", AlertColor
                        GoTo Continue
                    End If

                    SendSetVIP Command(1), CLng(Command(2))
                    
                Case "/rank"
                    If GetPlayerAccess(MyIndex) < ADMIN_CREATOR Then GoTo Continue

                    If UBound(Command) < 2 Then
                        AddText "Usage: /rank (nome) (Rank)", AlertColor
                        GoTo Continue
                    End If

                    If IsNumeric(Command(1)) Or Not IsNumeric(Command(2)) Then
                        AddText "Usage: /rank (nome) (Rank)", AlertColor
                        GoTo Continue
                    End If

                    SendSetRank Command(1), CLng(Command(2))
                
                Case "/ninja"
                    If GetPlayerAccess(MyIndex) < 4 Then GoTo Continue
                    
                    If ModoNinja = YES Then
                        ModoNinja = NO
                        AddText "Modo Ninja desativado.", Green
                    Else
                        ModoNinja = YES
                        AddText "Modo Ninja Ativado!", BrightGreen
                    End If
                
                Case "/atendimento"
                    If GetPlayerVital(MyIndex, Vitals.HP) < GetPlayerMaxVital(MyIndex, Vitals.HP) Then
                        AddText "Você precisa estar com o HP cheio!", White
                        GoTo Continue
                    End If
                        
                    WarpTo 99
                    
                Case "/tai"
                    If UBound(Command) < 1 Then
                        AddText "Use: /tai Quantia", AlertColor
                        GoTo Continue
                    End If
                    
                    If IsNumeric(Command(1)) Then
                        SendTrainStat 1, Command(1)
                    End If
                
                Case "/res"
                    If UBound(Command) < 1 Then
                        AddText "Use: /res Quantia", AlertColor
                        GoTo Continue
                    End If
                    
                    If IsNumeric(Command(1)) Then
                        SendTrainStat 2, Command(1)
                    End If
                
                Case "/nin"
                    If UBound(Command) < 1 Then
                        AddText "Use: /nin Quantia", AlertColor
                        GoTo Continue
                    End If
                    
                    If IsNumeric(Command(1)) Then
                        SendTrainStat 3, Command(1)
                    End If
                
                Case "/agi"
                    If UBound(Command) < 1 Then
                        AddText "Use: /agi Quantia", AlertColor
                        GoTo Continue
                    End If
                    
                    If IsNumeric(Command(1)) Then
                        SendTrainStat 4, Command(1)
                    End If
                    
                Case "/gen"
                    If UBound(Command) < 1 Then
                        AddText "Use: /gen Quantia", AlertColor
                        GoTo Continue
                    End If
                    
                    If IsNumeric(Command(1)) Then
                        SendTrainStat 5, Command(1)
                    End If
                
                Case "/cash"
                    If GetPlayerAccess(MyIndex) < ADMIN_CREATOR Then GoTo Continue

                    If UBound(Command) < 2 Then
                        AddText "Usage: /cash (nome) (Qnt)", AlertColor
                        GoTo Continue
                    End If

                    If IsNumeric(Command(1)) Or Not IsNumeric(Command(2)) Then
                        AddText "Usage: /cash (nome) (qnt)", AlertColor
                        GoTo Continue
                    End If
                    
                    Cash Command(1), Command(2)
                
                Case "/blockmsg"
                    If UBound(Command) < 1 Then
                        AddText "Usar: /blockmsg nome", AlertColor
                        GoTo Continue
                    End If

                    If IsNumeric(Command(1)) Then
                        AddText "Usar: /blockmsg nome", AlertColor
                        GoTo Continue
                    End If
                    
                    'muta o cara
                    SendLuta Command(1), "2"
                    
                Case "/ct"
                    WarpTo 295
                Case "/kage"
                    WarpTo 294
                Case "/arena"
                    WarpTo 96
                    
                Case "/torneio"
                    WarpTo 98
                Case "/pvp"
                    UpdatePositions
                    
                    For u = 1 To 10
                        frmMain.lblPvpName(u).Caption = u & "°:" & TopPvP(u).Nome
                        frmMain.lblPvpV(u).Caption = TopPvP(u).V
                        frmMain.lblPvpD(u).Caption = TopPvP(u).d
                    Next
                    
                    frmMain.lblMyD.Caption = Player(MyIndex).PvP.d
                    frmMain.lblMyV.Caption = Player(MyIndex).PvP.V
                    
                    frmMain.picPVP.Visible = True
                    
                Case "/karma"
                    UpdatePositions
                    
                    For u = 1 To 10
                        frmMain.lblHeroName(u).Caption = u & "°:" & TopHero(u).Nome
                        frmMain.lblHeroPts(u).Caption = TopHero(u).Pts
                        
                        frmMain.lblPKName(u).Caption = u & "°:" & TopPK(u).Nome
                        frmMain.lblPKPts(u).Caption = TopPK(u).Pts
                    Next
                    
                    If Player(MyIndex).Karma >= 0 Then
                        frmMain.lblMyKarma.ForeColor = &H808000
                    Else
                        frmMain.lblMyKarma.ForeColor = &HC0&
                    End If
                    
                    frmMain.lblMyKarma.Caption = Player(MyIndex).Karma
                    
                    frmMain.picKarma.Visible = Not frmMain.picKarma.Visible
                
                Case "/topchar"
                    UpdatePositions
                    frmMain.lstTopChar(0).Clear
                    frmMain.lstTopChar(1).Clear
                    
                    For u = 1 To MAX_CLASS_TEMP
                        frmMain.lstTopChar(0).AddItem Class(u).name
                        frmMain.lstTopChar(1).AddItem TopChar(u).Nome & "-Level:" & TopChar(u).Level
                    Next
                    
                    frmMain.picTopChar.Visible = Not frmMain.picTopChar.Visible
                
                Case "/top"
                    UpdatePositions
                    frmMain.picTops.Visible = Not frmMain.picTops.Visible
                    
                Case "/toplvl"
                    UpdatePositions
                    
                    For u = 1 To 20
                        frmMain.lblTopLevel(u).Caption = TopLvl(u).Nivel
                        frmMain.lblTopName(u).Caption = u & "°:" & TopLvl(u).Nome
                    Next
                    
                    frmMain.picTopLevel.Visible = Not frmMain.picTopLevel.Visible
                Case "/areavip"
                    WarpTo 82
                    
                Case "/konoha"
                    WarpTo 1
                
                Case "/senhasecreta"
                    If UBound(Command) < 1 Then
                        AddText "Usage: /senhasecreta (senhaSecreta)", AlertColor
                        GoTo Continue
                    End If

                    SendSenhaSecreta Command(1)
                Case "/adm"
                    If GetPlayerAccess(MyIndex) < ADMIN_MONITOR Then GoTo Continue
                    
                    SendRequestPlayerNames
                    
                    frmMain.picAdminWarp.Visible = True
                    
                Case "/desafio"
                    SendRequestPlayerNames
                    frmMain.picDesafio.Visible = True
                    frmMain.cmDesafio(2).Visible = False
                    '############
                    frmMain.lblDesafio(7).Caption = GetPlayerName(MyIndex)
                    frmMain.cmbArenaTipo.ListIndex = 0
                    frmMain.cmDesafio(0).Visible = True
                    For i = 1 To 3
                        NomesDesafio(i) = vbNullString
                    Next
                    atualizarArena 'atualiza as arenas livres
                    '############
                Case "/spec"
                    SendSpec
                
                Case "/exp"
                    AddText "Sua experiência exata:" & GetPlayerExp(MyIndex) & "/" & MyTotalExp, BrightBlue
                'Case "/expulsar"
                    'EmoteMsg 138
                'Case "/convidar"
                    'EmoteMsg 139
                'Case "/tirarmembrosoffline"
                    'EmoteMsg 140
                'Case "/setarsub"
                    'EmoteMsg 141
                Case "/verificarjutsus"
                    EmoteMsg 142
                Case "/transferenciakarma"
                    If UBound(Command) < 1 Then
                        AddText "Digite: /transferenciakarma quantidadeDeKarma", AlertColor
                        GoTo Continue
                    End If

                    If Not IsNumeric(Command(1)) Then
                        AddText "Coloque um valor válido!", AlertColor
                        GoTo Continue
                    End If
                    
                    If Player(MyIndex).karmaTradeWarning = False Then
                        Player(MyIndex).karmaTradeWarning = True
                        AddText "ATENÇÃO: Trasferência de karma vai custar 3K CASH que será descontado de você se o outro jogador aceitar. Se você tem CERTEZA que deseja gastar 3K CASH pra isso, repita o comando.", Yellow
                        GoTo Continue
                    End If
                    
                    EmoteMsg 143, Command(1)
                Case "/aceitarkarma"
                    EmoteMsg 144
                Case "/recusarkarma"
                    EmoteMsg 145
                '######CHARS
                Case "/naruto"
                    EmoteMsg NARUTO
                Case "/sasuke"
                    EmoteMsg SASUKE
                Case "/sakura"
                    EmoteMsg SAKURA
                Case "/ino"
                    EmoteMsg INO
                Case "/shikamaru"
                    EmoteMsg SHIKAMARU
                Case "/chouji"
                    EmoteMsg CHOUJI
                Case "/lee"
                    EmoteMsg LEE
                Case "/neji"
                    EmoteMsg NEJI
                Case "/tenten"
                    EmoteMsg TENTEN
                Case "/kiba"
                    EmoteMsg KIBA
                Case "/shino"
                    EmoteMsg SHINO
                Case "/gaara"
                    EmoteMsg GAARA
                Case "/kankurou"
                    EmoteMsg KANKUROU
                Case "/temari"
                    EmoteMsg TEMARI
                Case "/hinata"
                    EmoteMsg HINATA
                Case "/sai"
                    EmoteMsg SAI
                Case "/yondaime"
                    EmoteMsg YONDAIME
                Case "/kisame"
                    EmoteMsg KISAME
                Case "/deidara"
                    EmoteMsg DEIDARA
                Case "/itachi"
                    EmoteMsg ITACHI
                Case "/kimimaro"
                    EmoteMsg KIMIMARU
                Case "/jiraya"
                    EmoteMsg JIRAYA
                Case "/tsunade"
                    EmoteMsg TSUNADE
                Case "/kakashi"
                    EmoteMsg KAKASHI
                Case "/pain"
                    EmoteMsg PAIN
                Case "/madara"
                    EmoteMsg MADARA
                Case "/tobi"
                    EmoteMsg TOBI
                Case "/orochimaru"
                    EmoteMsg OROCHIMARU
                Case "/haku"
                    EmoteMsg HAKU
                Case "/zabuza"
                    EmoteMsg ZABUZA
                Case "/bee"
                    EmoteMsg BEE
                Case "/hashirama"
                    EmoteMsg HASHIRAMA
                Case "/yamato"
                    EmoteMsg YAMATO
                Case "/konan"
                    EmoteMsg KONAN
                Case "/raikage"
                    EmoteMsg RAIKAGE
                Case "/darui"
                    EmoteMsg DARUI
                Case "/hidan"
                    EmoteMsg HIDAN
                Case "/sasori"
                    EmoteMsg SASORI
                Case "/danzou"
                    EmoteMsg DANZOU
                Case "/yugito"
                    EmoteMsg YUGITO
                Case "/tobirama"
                    EmoteMsg TOBIRAMA
                Case "/gai"
                    EmoteMsg GAI
                Case "/mei"
                    EmoteMsg MEI
                    
                '######CHARS
                Case "/mutarchat"
                    If muteChat = True Then
                        muteChat = False
                        AddText "Chat global desmutado! Agora você voltará a receber as mensagens do global.", White
                    Else
                        muteChat = True
                        AddText "Chat global mutado! Use o comando novamente para desmutar o chat.", White
                    End If
                
                Case "/berserker"
                    SendBerserkerMode
                
                Case "/evento"
                    EmoteMsg 147
                
                Case "/help"
                
                    Call AddText("Social Commands:", Blue)
                    Call AddText("'msghere = Broadcast Message", Blue)
                    Call AddText("-msghere = Emote Message", Blue)
                    Call AddText("!namehere msghere = Player Message", Blue)
                    Call AddText("Available Commands: /info, /who, /fps, /fpslock", Blue)
                Case "/puxarkage"
                    If GetPlayerAccess(MyIndex) < 2 Then GoTo Continue
                    
                    EmoteMsg 128
                Case "/info"

                    ' Checks to make sure we have more than one string in the array
                    If UBound(Command) < 1 Then
                        AddText "Usage: /info (name)", AlertColor
                        GoTo Continue
                    End If

                    If IsNumeric(Command(1)) Then
                        AddText "Usage: /info (name)", AlertColor
                        GoTo Continue
                    End If

                    Set buffer = New clsBuffer
                    buffer.WriteLong CPlayerInfoRequest
                    buffer.WriteString Command(1)
                    SendData buffer.ToArray()
                    Set buffer = Nothing
                    ' Whos Online
                Case "/who"
                    EmoteMsg 130 'whosonline
                    ' Checking fps
                Case "/fps"
                    BFPS = Not BFPS
                    ' toggle fps lock
                Case "/fpslock"
                    FPS_Lock = Not FPS_Lock
                    
                    ' // Monitor Admin Commands //
                    ' Admin Help
                Case "/admin"
                    If GetPlayerAccess(MyIndex) < ADMIN_MONITOR Then GoTo Continue
                    frmMain.picAdmin.Visible = Not frmMain.picAdmin.Visible
                    ' Kicking a player
                Case "/kick"
                    If GetPlayerAccess(MyIndex) < ADMIN_MONITOR Then GoTo Continue

                    If UBound(Command) < 1 Then
                        AddText "Usage: /kick (name)", AlertColor
                        GoTo Continue
                    End If

                    If IsNumeric(Command(1)) Then
                        AddText "Usage: /kick (name)", AlertColor
                        GoTo Continue
                    End If

                    SendKick Command(1)
                    ' // Mapper Admin Commands //
                    ' Location
                Case "/loc"
                    If GetPlayerAccess(MyIndex) < ADMIN_MAPPER Then GoTo Continue

                    BLoc = Not BLoc
                    ' Map Editor
                Case "/editmap"
                    If GetPlayerAccess(MyIndex) < ADMIN_MAPPER Then GoTo Continue
                    
                    SendRequestEditMap
                    ' Warping to a player
                Case "/warpmeto"
                    If GetPlayerAccess(MyIndex) < ADMIN_MAPPER Then GoTo Continue

                    If UBound(Command) < 1 Then
                        AddText "Usage: /warpmeto (name)", AlertColor
                        GoTo Continue
                    End If

                    If IsNumeric(Command(1)) Then
                        AddText "Usage: /warpmeto (name)", AlertColor
                        GoTo Continue
                    End If

                    WarpMeTo Command(1)
                    ' Warping a player to you
                Case "/warptome"
                    If GetPlayerAccess(MyIndex) < ADMIN_MAPPER Then GoTo Continue

                    If UBound(Command) < 1 Then
                        AddText "Usage: /warptome (name)", AlertColor
                        GoTo Continue
                    End If

                    If IsNumeric(Command(1)) Then
                        AddText "Usage: /warptome (name)", AlertColor
                        GoTo Continue
                    End If

                    WarpToMe Command(1)
                    ' Warping to a map
                Case "/warpto"
                    If GetPlayerAccess(MyIndex) < 2 Then GoTo Continue

                    If UBound(Command) < 1 Then
                        AddText "Usage: /warpto (map #)", AlertColor
                        GoTo Continue
                    End If

                    If Not IsNumeric(Command(1)) Then
                        AddText "Usage: /warpto (map #)", AlertColor
                        GoTo Continue
                    End If

                    n = CLng(Command(1))

                    ' Check to make sure its a valid map #
                    If n > 0 And n <= MAX_MAPS Then
                        Call WarpTo(n)
                    Else
                        Call AddText("Invalid map number.", Red)
                    End If

                    ' Setting sprite
                Case "/setsprite"
                    If GetPlayerAccess(MyIndex) < ADMIN_MONITOR Then GoTo Continue

                    If UBound(Command) < 1 Then
                        AddText "Usage: /setsprite (sprite #)", AlertColor
                        GoTo Continue
                    End If

                    If Not IsNumeric(Command(1)) Then
                        AddText "Usage: /setsprite (sprite #)", AlertColor
                        GoTo Continue
                    End If

                    SendSetSprite CLng(Command(1))
                    ' Map report
                Case "/mapreport"
                    If GetPlayerAccess(MyIndex) < ADMIN_MAPPER Then GoTo Continue

                    SendMapReport
                    ' Respawn request
                Case "/respawn"
                    If GetPlayerAccess(MyIndex) < ADMIN_MAPPER Then GoTo Continue

                    SendMapRespawn
                    ' Check the ban list
                Case "/banlist"
                    If GetPlayerAccess(MyIndex) < ADMIN_MAPPER Then GoTo Continue

                    SendBanList
                 
                    ' // Developer Admin Commands //
                    ' Editing item request
                Case "/edititem"
                    If GetPlayerAccess(MyIndex) < ADMIN_DEVELOPER Then GoTo Continue

                    SendRequestEditItem
                ' Editing animation request
                Case "/editanimation"
                    If GetPlayerAccess(MyIndex) < ADMIN_DEVELOPER Then GoTo Continue

                    SendRequestEditAnimation
                    ' Editing npc request
                Case "/editnpc"
                    If GetPlayerAccess(MyIndex) < ADMIN_DEVELOPER Then GoTo Continue

                    SendRequestEditNpc
                Case "/editresource"
                    If GetPlayerAccess(MyIndex) < ADMIN_DEVELOPER Then GoTo Continue

                    SendRequestEditResource
                    ' Editing shop request
                Case "/editshop"
                    If GetPlayerAccess(MyIndex) < ADMIN_DEVELOPER Then GoTo Continue

                    SendRequestEditShop
                    ' Editing spell request
                Case "/editspell"
                    If GetPlayerAccess(MyIndex) < ADMIN_DEVELOPER Then GoTo Continue

                    SendRequestEditSpell
                    ' // Creator Admin Commands //
                    ' Giving another player access
                Case "/setaccess"
                    If GetPlayerAccess(MyIndex) < ADMIN_CREATOR Then GoTo Continue

                    If UBound(Command) < 2 Then
                        AddText "Usage: /setaccess (name) (access)", AlertColor
                        GoTo Continue
                    End If

                    If IsNumeric(Command(1)) Or Not IsNumeric(Command(2)) Then
                        AddText "Usage: /setaccess (name) (access)", AlertColor
                        GoTo Continue
                    End If

                    SendSetAccess Command(1), CLng(Command(2))
                    ' Ban destroy
                Case "/destroybanlist"
                    If GetPlayerAccess(MyIndex) < ADMIN_CREATOR Then GoTo Continue

                    SendBanDestroy
                    ' Packet debug mode
                Case "/debug"
                    If GetPlayerAccess(MyIndex) < ADMIN_CREATOR Then GoTo Continue

                    DEBUG_MODE = (Not DEBUG_MODE)
                Case Else
                    AddText "Not a valid command!", Blue
            End Select

            'continue label where we go instead of exiting the sub
Continue:
            MyText = vbNullString
            frmMain.txtMyChat.text = vbNullString
            Exit Sub
        End If

        ' Say message
        
        If Not ChatDelay > 0 Then
            If Len(ChatText) > 0 Then
                ChatDelay = GetTickCount + 2000
                Call SayMsg(ChatText)
            End If
        Else
            'AddText "Sem flood por favor :]", White
        End If
        
        MyText = vbNullString
        frmMain.txtMyChat.text = vbNullString
        Exit Sub
    End If

    ' Handle when the user presses the backspace key
    If (KeyAscii = vbKeyBack) Then
        If LenB(MyText) > 0 Then MyText = Mid$(MyText, 1, Len(MyText) - 1)
    End If

    ' And if neither, then add the character to the user's text buffer
    If (KeyAscii <> vbKeyReturn) Then
        If (KeyAscii <> vbKeyBack) Then
            MyText = MyText & ChrW$(KeyAscii)
        End If
    End If

    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleKeyPresses", "modInput", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub
