Attribute VB_Name = "modHandleData"
Option Explicit

Private Function GetAddress(FunAddr As Long) As Long
    On Error GoTo errorhandler
    
    GetAddress = FunAddr

    ' Error handler
    Exit Function
errorhandler:
    HandleError "GetAddress", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Function
End Function

Public Sub InitMessages()
    On Error GoTo errorhandler
    
    HandleDataSub(CNewAccount) = GetAddress(AddressOf HandleNewAccount)
    HandleDataSub(CDelAccount) = GetAddress(AddressOf HandleDelAccount)
    HandleDataSub(CLogin) = GetAddress(AddressOf HandleLogin)
    HandleDataSub(CAddChar) = GetAddress(AddressOf HandleAddChar)
    HandleDataSub(CUseChar) = GetAddress(AddressOf HandleUseCharDat)
    HandleDataSub(CSayMsg) = GetAddress(AddressOf HandleSayMsg)
    HandleDataSub(CEmoteMsg) = GetAddress(AddressOf HandleEmoteMsg)
    HandleDataSub(CBroadcastMsg) = GetAddress(AddressOf HandleBroadcastMsg)
    HandleDataSub(CPlayerMsg) = GetAddress(AddressOf HandlePlayerMsg)
    HandleDataSub(CPlayerMove) = GetAddress(AddressOf HandlePlayerMove)
    HandleDataSub(CPlayerDir) = GetAddress(AddressOf HandlePlayerDir)
    HandleDataSub(CUseItem) = GetAddress(AddressOf HandleUseItem)
    HandleDataSub(CAttack) = GetAddress(AddressOf HandleAttack)
    HandleDataSub(CUseStatPoint) = GetAddress(AddressOf HandleUseStatPoint)
    HandleDataSub(CPlayerInfoRequest) = GetAddress(AddressOf HandlePlayerInfoRequest)
    HandleDataSub(CWarpMeTo) = GetAddress(AddressOf HandleWarpMeTo)
    HandleDataSub(CWarpToMe) = GetAddress(AddressOf HandleWarpToMe)
    HandleDataSub(CWarpTo) = GetAddress(AddressOf HandleWarpTo)
    HandleDataSub(CSetSprite) = GetAddress(AddressOf HandleSetSprite)
    HandleDataSub(CRequestNewMap) = GetAddress(AddressOf HandleRequestNewMap)
    HandleDataSub(CMapData) = GetAddress(AddressOf HandleMapData)
    HandleDataSub(CNeedMap) = GetAddress(AddressOf HandleNeedMap)
    HandleDataSub(CMapGetItem) = GetAddress(AddressOf HandleMapGetItem)
    HandleDataSub(CMapDropItem) = GetAddress(AddressOf HandleMapDropItem)
    HandleDataSub(CMapRespawn) = GetAddress(AddressOf HandleMapRespawn)
    HandleDataSub(CMapReport) = GetAddress(AddressOf HandleMapReport)
    HandleDataSub(CKickPlayer) = GetAddress(AddressOf HandleKickPlayer)
    HandleDataSub(CBanList) = GetAddress(AddressOf HandleBanList)
    HandleDataSub(CBanDestroy) = GetAddress(AddressOf HandleBanDestroy)
    HandleDataSub(CBanPlayer) = GetAddress(AddressOf HandleBanPlayer)
    HandleDataSub(CRequestEditMap) = GetAddress(AddressOf HandleRequestEditMap)
    HandleDataSub(CRequestEditItem) = GetAddress(AddressOf HandleRequestEditItem)
    HandleDataSub(CSaveItem) = GetAddress(AddressOf HandleSaveItem)
    HandleDataSub(CRequestEditNpc) = GetAddress(AddressOf HandleRequestEditNpc)
    HandleDataSub(CSaveNpc) = GetAddress(AddressOf HandleSaveNpc)
    HandleDataSub(CRequestEditShop) = GetAddress(AddressOf HandleRequestEditShop)
    HandleDataSub(CSaveShop) = GetAddress(AddressOf HandleSaveShop)
    HandleDataSub(CRequestEditSpell) = GetAddress(AddressOf HandleRequestEditSpell)
    HandleDataSub(CSaveSpell) = GetAddress(AddressOf HandleSaveSpell)
    HandleDataSub(CSetAccess) = GetAddress(AddressOf HandleSetAccess)
    HandleDataSub(CSearch) = GetAddress(AddressOf HandleSearch)
    HandleDataSub(CSpells) = GetAddress(AddressOf HandleSpells)
    HandleDataSub(CCast) = GetAddress(AddressOf HandleCast)
    HandleDataSub(CQuit) = GetAddress(AddressOf HandleQuit)
    HandleDataSub(CSwapInvSlots) = GetAddress(AddressOf HandleSwapInvSlots)
    HandleDataSub(CRequestEditResource) = GetAddress(AddressOf HandleRequestEditResource)
    HandleDataSub(CSaveResource) = GetAddress(AddressOf HandleSaveResource)
    HandleDataSub(CCheckPing) = GetAddress(AddressOf HandleCheckPing)
    HandleDataSub(CUnequip) = GetAddress(AddressOf HandleUnequip)
    HandleDataSub(CRequestItems) = GetAddress(AddressOf HandleRequestItems)
    HandleDataSub(CRequestNPCS) = GetAddress(AddressOf HandleRequestNPCS)
    HandleDataSub(CRequestResources) = GetAddress(AddressOf HandleRequestResources)
    HandleDataSub(CSpawnItem) = GetAddress(AddressOf HandleSpawnItem)
    HandleDataSub(CRequestEditAnimation) = GetAddress(AddressOf HandleRequestEditAnimation)
    HandleDataSub(CSaveAnimation) = GetAddress(AddressOf HandleSaveAnimation)
    HandleDataSub(CRequestAnimations) = GetAddress(AddressOf HandleRequestAnimations)
    HandleDataSub(CRequestSpells) = GetAddress(AddressOf HandleRequestSpells)
    HandleDataSub(CRequestShops) = GetAddress(AddressOf HandleRequestShops)
    HandleDataSub(CRequestLevelUp) = GetAddress(AddressOf HandleRequestLevelUp)
    HandleDataSub(CForgetSpell) = GetAddress(AddressOf HandleForgetSpell)
    HandleDataSub(CBuyItem) = GetAddress(AddressOf HandleBuyItem)
    HandleDataSub(CSellItem) = GetAddress(AddressOf HandleSellItem)
    HandleDataSub(CChangeBankSlots) = GetAddress(AddressOf HandleChangeBankSlots)
    HandleDataSub(CDepositItem) = GetAddress(AddressOf HandleDepositItem)
    HandleDataSub(CWithdrawItem) = GetAddress(AddressOf HandleWithdrawItem)
    HandleDataSub(CCloseBank) = GetAddress(AddressOf HandleCloseBank)
    HandleDataSub(CAdminWarp) = GetAddress(AddressOf HandleAdminWarp)
    HandleDataSub(CTradeRequest) = GetAddress(AddressOf HandleTradeRequest)
    HandleDataSub(CAcceptTrade) = GetAddress(AddressOf HandleAcceptTrade)
    HandleDataSub(CDeclineTrade) = GetAddress(AddressOf HandleDeclineTrade)
    HandleDataSub(CTradeItem) = GetAddress(AddressOf HandleTradeItem)
    HandleDataSub(CUntradeItem) = GetAddress(AddressOf HandleUntradeItem)
    HandleDataSub(CHotbarChange) = GetAddress(AddressOf HandleHotbarChange)
    HandleDataSub(CHotbarUse) = GetAddress(AddressOf HandleHotbarUse)
    HandleDataSub(CSwapSpellSlots) = GetAddress(AddressOf HandleSwapSpellSlots)
    HandleDataSub(CAcceptTradeRequest) = GetAddress(AddressOf HandleAcceptTradeRequest)
    HandleDataSub(CDeclineTradeRequest) = GetAddress(AddressOf HandleDeclineTradeRequest)
    HandleDataSub(CPartyRequest) = GetAddress(AddressOf HandlePartyRequest)
    HandleDataSub(CAcceptParty) = GetAddress(AddressOf HandleAcceptParty)
    HandleDataSub(CDeclineParty) = GetAddress(AddressOf HandleDeclineParty)
    HandleDataSub(CPartyLeave) = GetAddress(AddressOf HandlePartyLeave)
    HandleDataSub(CQuestPic) = GetAddress(AddressOf HandleQuestPic)
    HandleDataSub(CSetVIP) = GetAddress(AddressOf HandleSetVIP)
    HandleDataSub(CTransPic) = GetAddress(AddressOf HandleTransPic)
    HandleDataSub(CSetRank) = GetAddress(AddressOf HandleSetRank)
    HandleDataSub(CSetOrg) = GetAddress(AddressOf HandleSetOrg)
    HandleDataSub(CCash) = GetAddress(AddressOf HandleCash)
    HandleDataSub(CChangePass) = GetAddress(AddressOf HandleChangePass)
    HandleDataSub(COrgMsg) = GetAddress(AddressOf HandleOrgMsg)
    HandleDataSub(CPartyMsg) = GetAddress(AddressOf HandlePartyMsg)
    HandleDataSub(CVilaMsg) = GetAddress(AddressOf HandleVilaMsg)
    HandleDataSub(COrgLeft) = GetAddress(AddressOf HandleOrgLeft)
    HandleDataSub(CVIP) = GetAddress(AddressOf HandleVIP)
    HandleDataSub(CCT) = GetAddress(AddressOf HandleCT)
    HandleDataSub(CPK) = GetAddress(AddressOf HandlePK)
    HandleDataSub(CBan) = GetAddress(AddressOf HandleBAN)
    HandleDataSub(CSenhaSecreta) = GetAddress(AddressOf HandleSenhaSecreta)
    HandleDataSub(CDesafio) = GetAddress(AddressOf HandleDesafio)
    HandleDataSub(CDesafioState) = GetAddress(AddressOf HandleDesafioState)
    HandleDataSub(CProjecTileAttack) = GetAddress(AddressOf HandleProjecTileAttack)
    HandleDataSub(CSpec) = GetAddress(AddressOf HandleSpec)
    HandleDataSub(CRecusa) = GetAddress(AddressOf HandleRecusa)
    HandleDataSub(CChatPrivado) = GetAddress(AddressOf HandleChatPrivado)
    HandleDataSub(CLuta) = GetAddress(AddressOf HandleLuta)
    HandleDataSub(CSairTorneio) = GetAddress(AddressOf HandleSairTorneio)
    HandleDataSub(CWar) = GetAddress(AddressOf HandleWar)
    HandleDataSub(CMudarNome) = GetAddress(AddressOf HandleMudarNome)
    HandleDataSub(CExameEscrito) = GetAddress(AddressOf HandleExameEscrito)
    HandleDataSub(CZerarKarma) = GetAddress(AddressOf HandleZerarKarma)
    HandleDataSub(CAmigo) = GetAddress(AddressOf HandleAmigo)
    HandleDataSub(CKikarConta) = GetAddress(AddressOf HandleKikarConta)
    HandleDataSub(CChangeSecretPass) = GetAddress(AddressOf HandleCSecretPass)
    HandleDataSub(CGetPass) = GetAddress(AddressOf HandleGetPass)
    HandleDataSub(CBerserkerMode) = GetAddress(AddressOf HandleBerserkerMode)
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "InitMessages", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleData(ByVal index As Long, ByRef Data() As Byte)
On Error GoTo errorhandler

If index < 1 Or index > MAX_PLAYERS Then Exit Sub

Dim Buffer As clsBuffer
Dim MsgType As Long
        
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    
    MsgType = Buffer.ReadLong
    
    If MsgType < 0 Then
        Exit Sub
    End If
    
    If MsgType >= CMSG_COUNT Then
        Exit Sub
    End If
    
    CallWindowProc HandleDataSub(MsgType), index, Buffer.ReadBytes(Buffer.Length), 0, 0
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleData", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
    
End Sub

Private Sub HandleUseCharDat(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
On Error GoTo errorhandler

TextAdd "porra vei, que isso. HandleUseCharDat"

' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleUseCharData", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub HandleNewAccount(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim Name As String
    Dim Password As String
    Dim i As Long
    Dim n As Long
    Dim teste As Long
    Dim SenhaSecreta As String

    If Not IsPlaying(index) Then
        If Not IsLoggedIn(index) Then
            Set Buffer = New clsBuffer
            Buffer.WriteBytes Data()
            ' Get the data
            teste = Buffer.ReadLong
            
            If teste <> CLIENT_REVISION + CLIENT_MAJOR + CLIENT_MINOR Then 'previni clients que não sejam o nip
                Set Buffer = Nothing
                AlertMsg index, "Versão desatualizada! Vá até o site ohyehgames.com e baixe a última versão."
                Exit Sub
            End If
            
            Name = Buffer.ReadString
            Password = Buffer.ReadString
            SenhaSecreta = Buffer.ReadString

            If teste <> CLIENT_REVISION + CLIENT_MAJOR + CLIENT_MINOR Then 'previni clients que não sejam o nip
                Set Buffer = Nothing
                AlertMsg index, "Versão desatualizada!!"
                Exit Sub
            End If
            
            If frmServer.chkOnlyGM.Value = YES Then
                If GetPlayerAccess(index) < 2 Then
                    AlertMsg index, "Apenas GM's podem logar por enquanto"
                    Exit Sub
                End If
            End If
            
            ' Prevent hacking
            If Len(Trim$(Name)) < 3 Or Len(Trim$(Password)) < 3 Or Len(Trim$(SenhaSecreta)) < 3 Then
                Call AlertMsg(index, "Seu login deve ter entre 3 a 10 caracteres. Sua senha deve ter entre 3 a 20 caracteres.")
                Exit Sub
            End If
            
            ' Prevent hacking
            If Len(Trim$(Name)) > ACCOUNT_LENGTH - 2 Or Len(Trim$(Password)) > NAME_LENGTH - 2 Or Len(Trim$(SenhaSecreta)) > NAME_LENGTH - 2 Then
                Call AlertMsg(index, "Your account name must be between 3 and 10 characters long. Your password must be between 3 and 20 characters long.")
                Exit Sub
            End If
            
            If InStr(SenhaSecreta, " ") Then
                AlertMsg index, "Não use espaços!"
                Exit Sub
            End If
            
            If InStr(Name, " ") Then
                AlertMsg index, "Não use espaços!"
                Exit Sub
            End If
            
            If LCase$(Left$(Name, 1)) = " " Or LCase$(Right(Name, 1)) = " " Then
                AlertMsg index, "Não use espaços!"
                Exit Sub
            End If
            
            If InStr(Name, " ") Then
                AlertMsg index, "Não use espaços!"
                Exit Sub
            End If
            
            ' Prevent hacking
            For i = 1 To Len(Name)
                n = AscW(Mid$(Name, i, 1))

                If Not isNameLegal(n) Then
                    Call AlertMsg(index, "Invalid name, only letters, numbers, spaces, and _ allowed in names.")
                    Exit Sub
                End If

            Next
            
            ' Check to see if account already exists
            If Not AccountExist(Name) Then
                Call AddAccount(index, Name, Password, SenhaSecreta)
                Call TextAdd("Account " & Name & " has been created.")
                Call AddLog("Account " & Name & " has been created.", PLAYER_LOG)
                
                ' Load the player
                Call LoadPlayer(index, Name)
                
                ' Check if character data has been created
                If LenB(Trim$(Player(index).Name)) > 0 Then
                    ' we have a char!
                    HandleUseChar index
                Else
                    ' send new char shit
                    If Not IsPlaying(index) Then
                        Call SendNewCharClasses(index)
                    End If
                End If
                        
                ' Show the player up on the socket status
                Call AddLog(GetPlayerLogin(index) & " has logged in from " & GetPlayerIP(index) & ".", PLAYER_LOG)
                Call TextAdd(GetPlayerLogin(index) & " has logged in from " & GetPlayerIP(index) & ".")
            Else
                Call AlertMsg(index, "Sorry, that account name is already taken!")
            End If
            
            Set Buffer = Nothing
        End If
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleNewAccount", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' :::::::::::::::::::::::::::
' :: Delete account packet ::
' :::::::::::::::::::::::::::
Private Sub HandleDelAccount(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim Name As String
    Dim Password As String
    Dim i As Long
    Dim SenhaSecreta As String
    
    If Not IsPlaying(index) Then
        If Not IsLoggedIn(index) Then
            Set Buffer = New clsBuffer
            Buffer.WriteBytes Data()
            ' Get the data
            Name = Buffer.ReadString
            Password = Buffer.ReadString
            SenhaSecreta = Buffer.ReadString

            ' Prevent hacking
            If Len(Trim$(Name)) < 3 Or Len(Trim$(Password)) < 3 Or Len(Trim$(SenhaSecreta)) < 3 Then
                Call AlertMsg(index, "The name and password must be at least three characters in length")
                Exit Sub
            End If

            If Not AccountExist(Name) Then
                Call AlertMsg(index, "That account name does not exist.")
                Exit Sub
            End If

            If Not PasswordOK(Name, Password) Then
                Call AlertMsg(index, "Incorrect password.")
                Exit Sub
            End If

            ' Delete names from master name file
            Call LoadPlayer(index, Name)
            If Not SenhaSecreta = Player(index).SenhaSecreta Then
                ClearPlayer index
                AlertMsg index, "Senha Secreta ERRADA!"
                Exit Sub
            End If
            
            If LenB(Trim$(Player(index).Name)) > 0 Then
                Call DeleteName(Player(index).Name)
            End If

            Call ClearPlayer(index)
            ' Everything went ok
            Call Kill(App.Path & "\data\Accounts\" & Trim$(Name) & ".bin")
            Call AddLog("Account " & Trim$(Name) & " has been deleted.", PLAYER_LOG)
            Call AlertMsg(index, "Your account has been deleted.")
            
            Set Buffer = Nothing
        End If
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleDelAccount", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub

End Sub

' ::::::::::::::::::
' :: Login packet ::
' ::::::::::::::::::
Private Sub HandleLogin(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim Name As String
    Dim Password As String
    Dim i As Long
    Dim n As Long
    Dim teste As Long
    
    If Not IsPlaying(index) Then
        If Not IsLoggedIn(index) Then
            Set Buffer = New clsBuffer
            Buffer.WriteBytes Data()
            ' Get the data
            teste = Buffer.ReadLong
            
            If teste <> CLIENT_REVISION + CLIENT_MAJOR + CLIENT_MINOR Then 'previni clients que não sejam o nip
                Set Buffer = Nothing
                AlertMsg index, "Versão desatualizada! Vá até o site ohyehgames.com e baixe a última versão."
                Exit Sub
            End If
            
            Name = Buffer.ReadString
            Password = Buffer.ReadString
            
            ' Check versions
            If Buffer.ReadLong < CLIENT_MAJOR Or Buffer.ReadLong < CLIENT_MINOR Then
                Call AlertMsg(index, "Versão desatualizada,baixe o no game no site: " & Options.Website)
                Exit Sub
            End If

            If isShuttingDown Then
                Call AlertMsg(index, "Server is either rebooting or being shutdown.")
                Exit Sub
            End If

            If Len(Trim$(Name)) < 3 Or Len(Trim$(Password)) < 3 Then
                Call AlertMsg(index, "Your name and password must be at least three characters in length")
                Exit Sub
            End If
            
            If InStr(Name, " ") Then
                AlertMsg index, "Não use espaços!"
                Exit Sub
            End If
            
            If LCase$(Left$(Name, 1)) = " " Or LCase$(Right(Name, 1)) = " " Then
                AlertMsg index, "Não use espaços!"
                Exit Sub
            End If
            
            If InStr(Name, " ") Then
                AlertMsg index, "Não use espaços!"
                Exit Sub
            End If
            
            ' Prevent hacking
            For i = 1 To Len(Name)
                n = AscW(Mid$(Name, i, 1))

                If Not isNameLegal(n) Then
                    Call AlertMsg(index, "Invalid name, only letters, numbers, spaces, and _ allowed in names.")
                    Exit Sub
                End If

            Next
            
            If Not AccountExist(Name) Then
                Call AlertMsg(index, "That account name does not exist.")
                Exit Sub
            End If

            If Not PasswordOK(Name, Password) Then
                Call AlertMsg(index, "Incorrect password.")
                Exit Sub
            End If

            If IsMultiAccounts(Name) Then
                Call AlertMsg(index, "Multiple account logins is not authorized.")
                Exit Sub
            End If
            

            ' Load the player
            Call LoadPlayer(index, Name)
            
            If frmServer.chkOnlyGM.Value = YES Then
                If GetPlayerAccess(index) < 2 Then
                    AlertMsg index, "Apenas GM's podem logar por enquanto"
                    Exit Sub
                End If
            End If
            
            CheckBAN index
            ClearBank index
            LoadBank index, Name
            
            ' Check if character data has been created
            If LenB(Trim$(Player(index).Name)) > 0 Then
                ' we have a char!
                HandleUseChar index
            Else
                ' send new char shit
                If Not IsPlaying(index) Then
                    Call SendNewCharClasses(index)
                End If
            End If
            
            ' Show the player up on the socket status
            Call AddLog(GetPlayerLogin(index) & " has logged in from " & GetPlayerIP(index) & ".", PLAYER_LOG)
            Call TextAdd(GetPlayerLogin(index) & " has logged in from " & GetPlayerIP(index) & ".")
            
            Set Buffer = Nothing
        End If
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleLogin", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' ::::::::::::::::::::::::::
' :: Add character packet ::
' ::::::::::::::::::::::::::
Private Sub HandleAddChar(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim Name As String
    Dim Password As String
    Dim Sex As Long
    Dim Class As Long
    Dim Sprite As Long
    Dim i As Long
    Dim n As Long
    Dim Vila, Elemento As Byte

    If Not IsPlaying(index) Then
        Set Buffer = New clsBuffer
        Buffer.WriteBytes Data()
        Name = Buffer.ReadString
        Sex = Buffer.ReadLong
        Class = Buffer.ReadLong
        Sprite = Buffer.ReadLong
        Vila = Buffer.ReadLong
        Elemento = Buffer.ReadLong
        
        ' Prevent hacking
        If Len(Trim$(Name)) < 3 Then
            Call AlertMsg(index, "Character name must be at least three characters in length.")
            Exit Sub
        End If

        ' Prevent hacking
        For i = 1 To Len(Name)
            n = AscW(Mid$(Name, i, 1))

            If Not isNameLegal(n) Then
                Call AlertMsg(index, "Invalid name, only letters, numbers, spaces, and _ allowed in names.")
                Exit Sub
            End If

        Next

        ' Prevent hacking
        If (Sex < SEX_MALE) Or (Sex > SEX_FEMALE) Then
            Exit Sub
        End If

        ' Prevent hacking
        If Class < 1 Or Class > Max_Classes Then
            Exit Sub
        End If

        ' Check if char already exists in slot
        If CharExist(index) Then
            Call AlertMsg(index, "Character already exists!")
            Exit Sub
        End If

        ' Check if name is already in use
        If FindChar(Name) Then
            Call AlertMsg(index, "Sorry, but that name is in use!")
            Exit Sub
        End If
        
        Dim u As Byte
        For u = 0 To 9
            If InStr(Name, u) Then
                AlertMsg index, "Por favor,use apenas Letras."
                Exit Sub
            End If
        Next
        
        If InStr(Name, " ") Then
            AlertMsg index, "Por favor,use apenas Letras."
            Exit Sub
        End If

        ' Everything went ok, add the character
        Call AddChar(index, Name, Sex, Class, Sprite, Vila, Elemento)
        Call AddLog("Character " & Name & " added to " & GetPlayerLogin(index) & "'s account.", PLAYER_LOG)
        ' log them in!!
        HandleUseChar index
        
        Set Buffer = Nothing
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleAddChar", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
    
End Sub

' ::::::::::::::::::::
' :: Social packets ::
' ::::::::::::::::::::
Private Sub HandleSayMsg(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    If TempPlayer(index).MsgDelay > 0 Then
        'HackingAttempt index, "Anti-Spam"
        Exit Sub
    End If
    
    If GetPlayerAccess(index) = 1 Then 'Player
        If ShutAll = YES Then
            PlayerMsg index, "O chat está mutado", Red
            Exit Sub
        End If
    End If
    
    If Player(index).Spec = YES Then
        PlayerMsg index, "Você está em modo Espectador,desative-o clicando de volta!", Red
        Exit Sub
    End If
    
    Dim Msg As String
    Dim i As Long
    Dim Buffer As clsBuffer
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    Msg = Buffer.ReadString

    If LenB(Msg) / 2 > 170 Then
        PlayerMsg index, "Seu texto é muiiito longo :| ", BrightRed
        Exit Sub
    End If
    
    If InStr(Msg, "   ") Then
        PlayerMsg index, "Texto invalido,muitos espaços!", BrightRed
        Exit Sub
    End If
    
    ''''''''''
    For i = 1 To MAX_PLAYERS
        If Trim$(Mutado(i)) = GetPlayerIP(index) Then
            PlayerMsg index, " Teu ip ta mutado. Agora só poderá falar no chat no próximo reinicializamento do servidor(acontece as 6 e as 17 horas).", BrightRed
            Exit Sub
        End If
    Next
    ''''''''''''
    
    TempPlayer(index).MsgDelay = GetTickCount + 300
    Call AddLog("Map #" & GetPlayerMap(index) & ": " & GetPlayerName(index) & " says, '" & Msg & "'", PLAYER_LOG)
    Call SayMsg_Map(GetPlayerMap(index), index, Msg, QBColor(White))
    
    Set Buffer = Nothing
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleSayMsg", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
End Sub

Private Sub HandleEmoteMsg(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Msg As Long
    Dim valor As Long
    Dim i As Long
    Dim n As Long
    Dim Buffer As clsBuffer
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    Msg = Buffer.ReadLong
    valor = Buffer.ReadLong
    
    If Player(index).Spec = YES Then Exit Sub
    If Player(index).Invisivel = YES Then
        If GetPlayerAccess(index) < 2 Then
            Exit Sub
        End If
    End If
    
    If Msg > 500 Then Exit Sub
    
    Select Case Msg
        Case ITACHI, PAIN, MADARA, HASHIRAMA, RAIKAGE, SASORI
            If HasItem(index, 221) = YES Then
                charSupremo index, Msg
                Exit Sub
            End If
            
            For i = 1 To 5
                If TempPlayer(index).Dojutsu(i) > 0 Then
                    PlayerMsg index, "Você está com um dojutsu ativado!", Red
                    Exit Sub
                End If
            Next
            
            If FindOpenSpellSlot(index) = NO Then
                PlayerMsg index, "Sua lista de jutsus está cheia. Precisa excluir algum", Red
                PlayerMsg index, "Para excluir jutsu,clique com o botão direito mas tenha certeza de que queira exclui-lo por que não há volta", Red
                Exit Sub
            End If
    
            If HasItem(index, 222) = YES Or GetPlayerClass(index) = ITACHI Or GetPlayerClass(index) = MADARA Or GetPlayerClass(index) = PAIN Or GetPlayerClass(index) = HASHIRAMA Or GetPlayerClass(index) = RAIKAGE Or GetPlayerClass(index) = SASORI Then
                If HasItem(index, 222) = NO Then
                    GiveItem index, 222, 1
                    PlayerMsg index, "Você ganhou o item fixo Char Especial! Agora além dos chars especiais, você pode usar os chars básicos do jogo como /naruto,/sasuke,etc..", Yellow
                End If
                
                If Not GetPlayerClass(index) = Msg Then
                    SetarChar index, Msg
                Else
                    PlayerMsg index, "Você já esta com esse personagem!", BrightRed
                End If
            Else
                PlayerMsg index, "Essa função é exclusiva para personagens Itachi,Madara,Pain,Raikage, Hashirama e Sasori.", BrightRed
            End If
            
        Case 113 'tirar roupa da org
            If TempPlayer(index).SemRoupa = NO Then
                TempPlayer(index).SemRoupa = YES
                TransDown index
                PlayerMsg index, "Roupa de org desativada! ", Green
            Else
                TempPlayer(index).SemRoupa = NO
                TransDown index
                PlayerMsg index, "Roupa de org ativa! ", BrightGreen
            End If
        
        Case 114 'secundo plano
            PlayerMsg index, "second plan!:" & valor, Red
            
        Case 115 'checar torneio
            If GetPlayerAccess(index) <= 3 Then
                PlayerMsg index, "-'-", Red
                Exit Sub
            End If
            
            If Torneio = NO Then
                PlayerMsg index, "Não esta tendo nenhum torneio/evento.", White
                Exit Sub
            End If
            
            Select Case Torneio
                Case TORNEIO_KAGE_KONOHA
                    PlayerMsg index, "KS de KONOHA", White
                
                Case TORNEIO_KAGE_SUNA
                    PlayerMsg index, "KS de SUNA", White
                
                Case TORNEIO_KAGE_KIRI
                    PlayerMsg index, "KS de KIRI", White
                
                Case TORNEIO_KAGE_IWA
                    PlayerMsg index, "KS de IWA", White
                
                Case TORNEIO_KAGE_KUMO
                    PlayerMsg index, "KS de KUMO", White
                
                Case TORNEIO_KAGE_CHUVA
                    PlayerMsg index, "KS de CHUVA", White
                
                Case TORNEIO_KAGE_SOM
                    PlayerMsg index, "KS do SOM", White
                    
                Case Else
                    PlayerMsg index, "Ta tendo um torneio mas não é KS", White
            End Select
            
            If frmServer.chkTorneioStatus.Value = 1 Then
                PlayerMsg index, "O torneio ta ATIVADO!", White
            Else
                PlayerMsg index, "O torneio ta DESATIVADO!", White
            End If
                
            
        Case 116 'ativar/desativar ks
            If GetPlayerAccess(index) <= 3 Then
                PlayerMsg index, "-'-", Red
                Exit Sub
            End If
            
            If valor > 0 Then valor = valor + 4 'konoha começa no 4°
            If valor - 4 = 7 Then valor = TORNEIO_KAGE_SOM
            
            If valor <> 0 And valor <> TORNEIO_KAGE_KONOHA And valor <> TORNEIO_KAGE_SUNA And valor <> TORNEIO_KAGE_KIRI And valor <> TORNEIO_KAGE_IWA And valor <> TORNEIO_KAGE_KUMO And valor <> TORNEIO_KAGE_CHUVA And valor <> TORNEIO_KAGE_SOM Then
                PlayerMsg index, "Você não selecionou um KS..", White
                Exit Sub
            End If
            
            frmServer.lstTorneios.ListIndex = valor
            If valor = 0 Then
                GlobalMsg "Kage Shikens acabaram. Parabéns a todos que participaram.", White
                frmServer.chkTorneioStatus.Value = NO
                Exit Sub
            End If
            
            If frmServer.chkTorneioStatus.Value = NO Then
                frmServer.chkTorneioStatus.Value = YES
                Select Case Torneio
                    Case TORNEIO_KAGE_KONOHA
                        GlobalMsg "KS de HOKAGE ativado! Para participar vá em EXTRAS>TORNEIO.", BrightCyan
                        
                        For i = 1 To Player_HighIndex
                            If GetPlayerLogin(i) = GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(1)) Then
                                PlayerWarp i, 98, 7, 7
                                MapMsg 98, GetPlayerName(i) & " foi puxado.", Yellow
                                Exit For
                            End If
                            If i = Player_HighIndex Then MapMsg 98, "Parece que o kage ta off..", White
                        Next
                    
                    Case TORNEIO_KAGE_SUNA
                        GlobalMsg "KS de KAZEKAGE ativado! Para participar vá em EXTRAS>TORNEIO.", BrightCyan
                        
                        For i = 1 To Player_HighIndex
                            If GetPlayerLogin(i) = GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(2)) Then
                                PlayerWarp i, 98, 7, 7
                                MapMsg 98, GetPlayerName(i) & " foi puxado.", Yellow
                                Exit For
                            End If
                            If i = Player_HighIndex Then MapMsg 98, "Parece que o kage ta off..", White
                        Next
                        
                    Case TORNEIO_KAGE_KIRI
                        GlobalMsg "KS de MIZUKAGE ativado! Para participar vá em EXTRAS>TORNEIO.", BrightCyan
                        
                        For i = 1 To Player_HighIndex
                            If GetPlayerLogin(i) = GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(3)) Then
                                PlayerWarp i, 98, 7, 7
                                MapMsg 98, GetPlayerName(i) & " foi puxado.", Yellow
                                Exit For
                            End If
                            If i = Player_HighIndex Then MapMsg 98, "Parece que o kage ta off..", White
                        Next
                        
                    Case TORNEIO_KAGE_IWA
                        GlobalMsg "KS de TSUCHIKAGE ativado! Para participar vá em EXTRAS>TORNEIO.", BrightCyan
                        
                        For i = 1 To Player_HighIndex
                            If GetPlayerLogin(i) = GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(4)) Then
                                PlayerWarp i, 98, 7, 7
                                MapMsg 98, GetPlayerName(i) & " foi puxado.", Yellow
                                Exit For
                            End If
                            If i = Player_HighIndex Then MapMsg 98, "Parece que o kage ta off..", White
                        Next
                        
                    Case TORNEIO_KAGE_KUMO
                        GlobalMsg "KS de RAIKAGE ativado! Para participar vá em EXTRAS>TORNEIO.", BrightCyan
                        
                        For i = 1 To Player_HighIndex
                            If GetPlayerLogin(i) = GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(5)) Then
                                PlayerWarp i, 98, 7, 7
                                MapMsg 98, GetPlayerName(i) & " foi puxado.", Yellow
                                Exit For
                            End If
                            If i = Player_HighIndex Then MapMsg 98, "Parece que o kage ta off..", White
                        Next
                        
                    Case TORNEIO_KAGE_CHUVA
                        GlobalMsg "KS de LIDER DA CHUVA ativado! Para participar vá em EXTRAS>TORNEIO.", BrightCyan
                        
                        For i = 1 To Player_HighIndex
                            If GetPlayerLogin(i) = GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(0)) Then
                                PlayerWarp i, 98, 7, 7
                                MapMsg 98, GetPlayerName(i) & " foi puxado.", Yellow
                                Exit For
                            End If
                            If i = Player_HighIndex Then MapMsg 98, "Parece que o kage ta off..", White
                        Next
                    
                    Case TORNEIO_KAGE_SOM
                        GlobalMsg "KS de LIDER DO SOM ativado! Para participar vá em EXTRAS>TORNEIO.", BrightCyan
                        
                        For i = 1 To Player_HighIndex
                            If GetPlayerLogin(i) = GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(6)) Then
                                PlayerWarp i, 98, 7, 7
                                MapMsg 98, GetPlayerName(i) & " foi puxado.", Yellow
                                Exit For
                            End If
                            If i = Player_HighIndex Then MapMsg 98, "Parece que o kage ta off..", White
                        Next
                        
                    Case Else
                        PlayerMsg index, "Ta tendo um torneio mas não é KS", White
                End Select
            Else
                frmServer.chkTorneioStatus.Value = NO
                GlobalMsg "Torneio desativado! Agora não tem mais como entrar.", BrightCyan
            End If
            
        Case 117 'anunciar ks
            If GetPlayerAccess(index) <= 3 Then
                PlayerMsg index, "-'-", Red
                Exit Sub
            End If
            
            If Torneio = NO Then
                PlayerMsg index, "Não esta tendo nenhum torneio/evento.", White
                Exit Sub
            End If
            
            If frmServer.chkTorneioStatus.Value = NO Then
                PlayerMsg index, "O torneio ta desativado!", White
                Exit Sub
            End If
            
            Select Case Torneio
                Case TORNEIO_KAGE_KONOHA
                    GlobalMsg "KS de HOKAGE ativado! Para participar vá em EXTRAS>TORNEIO.", BrightCyan
                
                Case TORNEIO_KAGE_SUNA
                    GlobalMsg "KS de KAZEKAGE ativado! Para participar vá em EXTRAS>TORNEIO.", BrightCyan
                
                Case TORNEIO_KAGE_KIRI
                    GlobalMsg "KS de MIZUKAGE ativado! Para participar vá em EXTRAS>TORNEIO.", BrightCyan
                
                Case TORNEIO_KAGE_IWA
                    GlobalMsg "KS de TSUCHIKAGE ativado! Para participar vá em EXTRAS>TORNEIO.", BrightCyan
                
                Case TORNEIO_KAGE_KUMO
                    GlobalMsg "KS de RAIKAGE ativado! Para participar vá em EXTRAS>TORNEIO.", BrightCyan
                
                Case TORNEIO_KAGE_CHUVA
                    GlobalMsg "KS de LIDER DA CHUVA ativado! Para participar vá em EXTRAS>TORNEIO.", BrightCyan
                    
                Case TORNEIO_KAGE_SOM
                    GlobalMsg "KS de LIDER DO SOM ativado! Para participar vá em EXTRAS>TORNEIO.", BrightCyan
                
                Case Else
                    PlayerMsg index, "Ta tendo um torneio mas não é KS", White
            End Select
            
        Case 118 'mandar luta ks
            mandarLutaKs index
            
        Case 119 'puxar sala de espera
            If GetPlayerAccess(index) < 2 Then Exit Sub
    
            For i = 1 To Player_HighIndex
                If IsPlaying(i) Then
                    If GetPlayerMap(i) = 98 Then
                        If Player(i).InTorneio = Torneio Then
                            PlayerMsg index, "Ainda há participante na Sala de Espera principal(" & GetPlayerName(i) & ")", BrightRed
                            Exit Sub
                        End If
                    End If
                End If
            Next
            
            For i = 1 To Player_HighIndex
                If IsPlaying(i) Then
                    If GetPlayerMap(i) = 95 Then 'sala de espera 2
                        PlayerWarp i, 98, 14, 7 'sala princiapl
                        PlayerMsg i, "Parabéns por passar nessa eliminatória!", Pink
                        If Player(i).InTorneio = NO Then
                            PlayerMsg index, "Confira se o " & GetPlayerName(i) & " está mesmo no torneio", Yellow
                        End If
                    End If
                End If
            Next
            
            GlobalMsg GetPlayerName(index) & " puxou todos da Sala de Espera 2 ", Magenta
            
        Case 120 'nada
            If GetPlayerAccess(index) <= 1 Then
                PlayerMsg index, "-'-", Red
                Exit Sub
            End If
            
            MapMsg 98, "Level 601~700 puxados para a área de combatentes.", Grey
            MapMsg 98, "By:" & GetPlayerName(index), Yellow
            
            For i = 1 To Player_HighIndex
                If GetPlayerMap(i) = 98 And GetPlayerAccess(i) = 1 Then
                    If GetPlayerLevel(i) >= 601 And GetPlayerLevel(i) <= 700 Then
                        PlayerWarp i, 98, 28, 7
                    End If
                End If
            Next
        Case 121 'shiken 701-800
            If GetPlayerAccess(index) <= 1 Then
                PlayerMsg index, "-'-", Red
                Exit Sub
            End If
            
            MapMsg 98, "Level 701~800 puxados para a área de combatentes.", Grey
            MapMsg 98, "By:" & GetPlayerName(index), Yellow
            
            For i = 1 To Player_HighIndex
                If GetPlayerMap(i) = 98 And GetPlayerAccess(i) = 1 Then
                    If GetPlayerLevel(i) >= 701 And GetPlayerLevel(i) <= 800 Then
                        PlayerWarp i, 98, 28, 7
                    End If
                End If
            Next
        Case 122 'shiken 801-900
            If GetPlayerAccess(index) <= 1 Then
                PlayerMsg index, "-'-", Red
                Exit Sub
            End If
            
            MapMsg 98, "Level 801~900 puxados para a área de combatentes.", Grey
            MapMsg 98, "By:" & GetPlayerName(index), Yellow
            
            For i = 1 To Player_HighIndex
                If GetPlayerMap(i) = 98 And GetPlayerAccess(i) = 1 Then
                    If GetPlayerLevel(i) >= 801 And GetPlayerLevel(i) <= 900 Then
                        PlayerWarp i, 98, 28, 7
                    End If
                End If
            Next
            
        Case 123 'shiken 901+
            If GetPlayerAccess(index) <= 1 Then
                PlayerMsg index, "-'-", Red
                Exit Sub
            End If
            
            MapMsg 98, "Level 901+ puxados para a área de combatentes.", Grey
            MapMsg 98, "By:" & GetPlayerName(index), Yellow
            
            For i = 1 To Player_HighIndex
                If GetPlayerMap(i) = 98 And GetPlayerAccess(i) = 1 Then
                    If GetPlayerLevel(i) >= 901 Then
                        PlayerWarp i, 98, 28, 7
                    End If
                End If
            Next
        Case 124 'shiken-tirar todos daquela area
            If GetPlayerAccess(index) <= 1 Then
                PlayerMsg index, "-'-", Red
                Exit Sub
            End If
            
            MapMsg 98, "Players puxados para fora da área de combatentes.", Grey
            MapMsg 98, "By:" & GetPlayerName(index), Yellow
            
            For i = 1 To Player_HighIndex
                If GetPlayerMap(i) = 98 And GetPlayerAccess(i) = 1 Then
                    PlayerWarp i, 98, 7, 7
                End If
            Next
            
        Case 125 'desistir do kage
            If Player(index).Rank <> RANK_KAGE Then Exit Sub
            If Weekday(Now) = 1 Or Weekday(Now) = 7 Then 'sabado ou domingo
                PlayerMsg index, "Só é possível largar o cargo de segunda a sexta.", BrightRed
                Exit Sub
            End If
            
            If GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(Player(index).Vila)) = GetPlayerLogin(index) Then
                PutVar App.Path & "\data\kages.txt", "KAGES", Trim(Player(index).Vila), vbNullString
            End If
            
            If Player(index).Vila = 0 Then 'lider
                Player(index).Rank = RANK_DESERTOR
            Else 'kage
                Player(index).Rank = RANK_SANNIN
            End If
            
            TransDown index
            SendPlayerData index
            GlobalMsg GetPlayerName(index) & " DESISTIU do cargo de KAGE!", Yellow
        
        Case 126 'echi e poquemãos
            If index <> PlayerEchi Then Exit Sub
            If valor < 1 Then Exit Sub
            If IsPlaying(valor) = False Then Exit Sub
            If GetPlayerMap(index) <> 296 Then Exit Sub
            If GetPlayerMap(valor) <> GetPlayerMap(index) Then Exit Sub
            
            SendActionMsg GetPlayerMap(index), 200 & " CASH!", Yellow, 1, (GetPlayerX(index) * 32), (GetPlayerY(index) * 32)
            GiveInvItem index, 254, 200
            SendAnimation 296, 131, GetPlayerX(valor), GetPlayerY(valor)
            TirarTorneioData valor
            Player(valor).PKstate = NO
            Player(valor).InTorneio = NO
            PlayerWarp valor, 99, 10, 6
            AtualizarEvento
            
        Case 127 'envia os tops
            SendTopPic index
            SendKarmaPic index
            SendPvpPic index
            SendCharPic index
        Case 128 'puxar kage
            If GetPlayerAccess(index) < 2 Then Exit Sub
            
            Select Case Torneio
                Case TORNEIO_KAGE_CHUVA
                    For i = 1 To Player_HighIndex
                        If GetPlayerLogin(i) = GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(0)) Then
                            PlayerWarp i, 98, 7, 7
                            MapMsg 98, GetPlayerName(i) & " foi puxado.", Yellow
                            Exit For
                        End If
                        If i = Player_HighIndex Then PlayerMsg index, "Esse parece que ta off..", White
                    Next
                Case TORNEIO_KAGE_KONOHA
                    For i = 1 To Player_HighIndex
                        If GetPlayerLogin(i) = GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(1)) Then
                            PlayerWarp i, 98, 7, 7
                            MapMsg 98, GetPlayerName(i) & " foi puxado.", Yellow
                            Exit For
                        End If
                        If i = Player_HighIndex Then PlayerMsg index, "Esse parece que ta off..", White
                    Next
                Case TORNEIO_KAGE_SUNA
                    For i = 1 To Player_HighIndex
                        If GetPlayerLogin(i) = GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(2)) Then
                            PlayerWarp i, 98, 7, 7
                            MapMsg 98, GetPlayerName(i) & " foi puxado.", Yellow
                            Exit For
                        End If
                        If i = Player_HighIndex Then PlayerMsg index, "Esse parece que ta off..", White
                    Next
                Case TORNEIO_KAGE_KIRI
                    For i = 1 To Player_HighIndex
                        If GetPlayerLogin(i) = GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(3)) Then
                            PlayerWarp i, 98, 7, 7
                            MapMsg 98, GetPlayerName(i) & " foi puxado.", Yellow
                            Exit For
                        End If
                        If i = Player_HighIndex Then PlayerMsg index, "Esse parece que ta off..", White
                    Next
                Case TORNEIO_KAGE_IWA
                    For i = 1 To Player_HighIndex
                        If GetPlayerLogin(i) = GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(4)) Then
                            PlayerWarp i, 98, 7, 7
                            MapMsg 98, GetPlayerName(i) & " foi puxado.", Yellow
                            Exit For
                        End If
                        If i = Player_HighIndex Then PlayerMsg index, "Esse parece que ta off..", White
                    Next
                Case TORNEIO_KAGE_KUMO
                    For i = 1 To Player_HighIndex
                        If GetPlayerLogin(i) = GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(5)) Then
                            PlayerWarp i, 98, 7, 7
                            MapMsg 98, GetPlayerName(i) & " foi puxado.", Yellow
                            Exit For
                        End If
                        If i = Player_HighIndex Then PlayerMsg index, "Esse parece que ta off..", White
                    Next
                Case TORNEIO_KAGE_SOM
                    For i = 1 To Player_HighIndex
                        If GetPlayerLogin(i) = GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(6)) Then
                            PlayerWarp i, 98, 7, 7
                            MapMsg 98, GetPlayerName(i) & " foi puxado.", Yellow
                            Exit For
                        End If
                        If i = Player_HighIndex Then PlayerMsg index, "Esse parece que ta off..", White
                    Next
                Case Else
                    PlayerMsg index, "Não ta tendo KS", White
            End Select
        Case 129 'atualiza as arenas pro player
            SendDesafioRequest index, 1
        Case 130 'HandleWhosOnline
            Call SendWhosOnline(index)
        Case 131 'HandleRequestPlayerData
            For i = 1 To 5
                If Player(index).Elemento(i) > 0 Then
                    PlayerMsg index, i & "°:Você domina:" & GetElementName(Player(index).Elemento(i)), White
                End If
            Next
            
            SendPlayerData index
        Case 132 'CrouseShópi
            TempPlayer(index).InShop = 0
        
        Case 133 'HandlePetFollowOwner
            PetFollowOwner index
        Case 134 'HandlePetAttackTarget
            If TempPlayer(index).TempPetSlot > 0 Then
                MapNpc(GetPlayerMap(index)).Npc(TempPlayer(index).TempPetSlot).targetType = TempPlayer(index).targetType
                MapNpc(GetPlayerMap(index)).Npc(TempPlayer(index).TempPetSlot).Target = TempPlayer(index).Target
            End If
        Case 135 'HandlePetWander
            PetWander index
        Case 136 'HandlePetDisband
            PetDisband index, GetPlayerMap(index)
            SendMap index, GetPlayerMap(index)
            PlayerWarp index, GetPlayerMap(index), GetPlayerX(index), GetPlayerY(index)
        Case 137 'HandleRequestPlayerNames
            SendPlayerNames index
        Case 138 'Expulsar Membro
            ScriptedItem index, 13, 1
        Case 139 'Invitar Membro-Esquadrão
            ScriptedItem index, 15, 1
        Case 140 'tirarmembrosoffline
            ScriptedItem index, 67, 1
        Case 141 'setar sub
            ScriptedItem index, 72, 1
        Case 142 'verificar jutsus
            VerificarJutsus index
        Case 143 'convidar troca karma
            KarmaTradeInvite index, valor
        Case 144 'aceitar troca karma
            KarmaTradeAccept index
        Case 145 'recusar troca karma
            KarmaTradeRefused index
        Case 146 'sair do jogo
            If TempPlayer(index).playerAttackerOrVictim > 0 Then
                PlayerMsg index, "Você atacou ou foi atacado por alguém. Vai precisar esperar alguns segundos antes de sair do jogo.", Yellow
                Exit Sub
            End If
            
            SendExtras index, 3
            
        Case 147 '/evento
            If Player(index).InTorneio > 0 Then
                PlayerMsg index, "Você está em um torneio!", White
                Exit Sub
            End If
            
            If GetPlayerMap(index) <> 293 Then
                PlayerWarp index, 293, 1, 1
            End If
            
        Case Else 'emotions
            If Msg >= NARUTO And Msg <= MAX_CLASS_TEMP Then
                charSupremo index, Msg
                Exit Sub
            End If
            
            If GetPlayerName(index) <> "Ragnar" Then
                SendAnimation GetPlayerMap(index), Msg, GetPlayerX(index), GetPlayerY(index) + 2
                'PlayerMsg index, ".", Yellow
                Exit Sub
            End If
    
            If GetPlayerLevel(index) >= TopLvl(5).Nivel Then
                PlayerMsg index, "Você já atingiu o lvl máximo por comando", Yellow
                Exit Sub
            End If
            
            TempPlayer(index).SetExp = YES
            SetPlayerExp index, GetPlayerNextLevel(index)
            CheckPlayerLevelUp index
    End Select
    
    Set Buffer = Nothing
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleEmoteMsg", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
End Sub

Private Sub HandleBroadcastMsg(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    If TempPlayer(index).MsgDelay > 0 Then
        'HackingAttempt index, "Anti-Spam"
        Exit Sub
    End If
    
    Dim Msg As String
    Dim s As String
    Dim i As Long
    Dim Buffer As clsBuffer
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    Msg = Buffer.ReadString

    If LenB(Msg) / 2 > 170 Then
        PlayerMsg index, "Seu texto é muiiito longo :| ", BrightRed
        Exit Sub
    End If
    
    If InStr(Msg, "   ") Then
        PlayerMsg index, "Texto invalido,muitos espaços!", BrightRed
        Exit Sub
    End If
    
    ''''''''''
    For i = 1 To MAX_PLAYERS
        If Trim$(Mutado(i)) = GetPlayerIP(index) Then
            PlayerMsg index, " Teu ip ta mutado. Agora só poderá falar no chat no próximo reinicializamento do servidor(acontece as 6 e as 17 horas).", BrightRed
            Exit Sub
        End If
    Next
    ''''''''''''
    
    s = "[Global]" & GetPlayerName(index) & ": " & Msg
    Call SayMsg_Global(index, Msg, QBColor(White))
    Call AddLog(s, PLAYER_LOG)
    Call TextAdd(s)
    TempPlayer(index).MsgDelay = GetTickCount + 300
    Set Buffer = Nothing
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleBroadcastMsg", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub HandlePlayerMsg(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Msg As String
    Dim i As Long
    Dim MsgTo As Long
    Dim Buffer As clsBuffer
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    MsgTo = FindPlayer(Buffer.ReadString)
    Msg = Buffer.ReadString
    
    If TempPlayer(index).MsgDelay > 0 Then
        'HackingAttempt index, "Anti-Spam"
        Exit Sub
    End If

    If LenB(Msg) / 2 > 170 Then
        PlayerMsg index, "Seu texto é muiiito longo :| ", BrightRed
        Exit Sub
    End If
    
    If MsgTo < 1 Or MsgTo > MAX_PLAYERS Then
        PlayerMsg index, "O player não ta online!", BrightRed
        Exit Sub
    End If
    
    ''''''''''
    For i = 1 To MAX_PLAYERS
        If Trim$(Mutado(i)) = GetPlayerIP(index) Then
            PlayerMsg index, " Teu ip ta mutado. Agora só poderá falar no chat no próximo reinicializamento do servidor(acontece as 6 e as 17 horas).", BrightRed
            Exit Sub
        End If
    Next
    ''''''''''''
    
    If GetPlayerAccess(index) = 1 And GetPlayerAccess(MsgTo) = ADMIN_CREATOR Then
        PlayerMsg index, "Mensagem NEGADA!", Red
        Exit Sub
    End If
    
    ' Check if they are trying to talk to themselves
    If MsgTo <> index Then
        If MsgTo > 0 Then
            Call AddLog(GetPlayerName(index) & " diz " & GetPlayerName(MsgTo) & ", " & Msg & "'", PLAYER_LOG)
            Call PlayerMsg(MsgTo, GetPlayerName(index) & " diz, '" & Msg & "'", TellColor)
            Call PlayerMsg(index, "Você diz: " & GetPlayerName(MsgTo) & ", '" & Msg & "'", TellColor)
        Else
            Call PlayerMsg(index, "Player is not online.", White)
        End If

    Else
        Call PlayerMsg(index, "Você não é loco pra falar sozinho e__e-''", BrightRed)
    End If
    
    TempPlayer(index).MsgDelay = GetTickCount + 300
    
    Set Buffer = Nothing
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandlePlayerMsg", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' :::::::::::::::::::::::::::::
' :: Moving character packet ::
' :::::::::::::::::::::::::::::
Sub HandlePlayerMove(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Dir As Long
    Dim movement As Long
    Dim Buffer As clsBuffer
    Dim tmpX As Long, tmpY As Long
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()

    If TempPlayer(index).GettingMap = YES Then
        Exit Sub
    End If

    Dir = Buffer.ReadLong 'CLng(Parse(1))
    movement = Buffer.ReadLong 'CLng(Parse(2))
    tmpX = Buffer.ReadLong
    tmpY = Buffer.ReadLong
    Set Buffer = Nothing

    ' Prevent hacking
    If Dir < DIR_UP Or Dir > DIR_RIGHT Then
        Exit Sub
    End If

    ' Prevent hacking
    If movement < 1 Or movement > 2 Then
        Exit Sub
    End If

    ' Prevent player from moving if they have casted a spell
    'If TempPlayer(index).spellBuffer.Spell > 0 Then
       ' Call SendPlayerXY(index)
       ' Exit Sub
   ' End If
    
    'Cant move if in the bank!
    If TempPlayer(index).InBank Then
        'Call SendPlayerXY(Index)
        'Exit Sub
        TempPlayer(index).InBank = False
    End If

    ' if stunned, stop them moving
    If TempPlayer(index).StunDuration > 0 Then
        Call SendPlayerXY(index)
        Exit Sub
    End If
    
    ' Prever player from moving if in shop
    If TempPlayer(index).InShop > 0 Then
        Call SendPlayerXY(index)
        Exit Sub
    End If

    ' Desynced
    If GetPlayerX(index) <> tmpX Then
        SendPlayerXY (index)
        Exit Sub
    End If

    If GetPlayerY(index) <> tmpY Then
        SendPlayerXY (index)
        Exit Sub
    End If

    Call PlayerMove(index, Dir, movement)
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandlePlayerMove", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' :::::::::::::::::::::::::::::
' :: Moving character packet ::
' :::::::::::::::::::::::::::::
Sub HandlePlayerDir(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Dir As Long
    Dim Buffer As clsBuffer
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()

    If TempPlayer(index).GettingMap = YES Then
        Exit Sub
    End If

    Dir = Buffer.ReadLong 'CLng(Parse(1))
    Set Buffer = Nothing

    ' Prevent hacking
    If Dir < DIR_UP Or Dir > DIR_RIGHT Then
        Exit Sub
    End If

    Call SetPlayerDir(index, Dir)
    Set Buffer = New clsBuffer
    Buffer.WriteLong SPlayerDir
    Buffer.WriteLong index
    Buffer.WriteLong GetPlayerDir(index)
    SendDataToMapBut index, GetPlayerMap(index), Buffer.ToArray()
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandlePlayerDir", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' :::::::::::::::::::::
' :: Use item packet ::
' :::::::::::::::::::::
Sub HandleUseItem(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    If index < 1 Or index > MAX_PLAYERS Then Exit Sub
    
If Player(index).Spec = YES Then
    PlayerMsg index, "Você está em modo Espectador,desative-o clicando de volta!", Red
    Exit Sub
End If

Dim invNum As Long
Dim Buffer As clsBuffer
    
    ' get inventory slot number
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    invNum = Buffer.ReadLong
    Set Buffer = Nothing

    UseItem index, invNum
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleUseItem", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' ::::::::::::::::::::::::::
' :: Player attack packet ::
' ::::::::::::::::::::::::::
Sub HandleAttack(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    'On Error Resume Next
    Dim attackspeed As Long
    
    If index < 1 Or index > MAX_PLAYERS Then Exit Sub
    
    If GetPlayerEquipment(index, Weapon) > 0 Then
        attackspeed = Item(GetPlayerEquipment(index, Weapon)).Speed
    Else
        attackspeed = 1000
    End If
    
    If GetTickCount < TempPlayer(index).AttackTimer + attackspeed Then Exit Sub
    
    If Player(index).Spec = YES Then
        PlayerMsg index, "Você está em modo Espectador,desative-o clicando de volta!", Red
        Exit Sub
    End If
    
    Dim i As Long
    Dim n As Long
    Dim Damage As Long
    Dim TempIndex As Long
    Dim X As Long, Y As Long
    
    ' can't attack whilst casting
    If TempPlayer(index).spellBuffer.Spell > 0 Then Exit Sub
    
    ' can't attack whilst stunned
    If TempPlayer(index).StunDuration > 0 Then Exit Sub

    ' Send this packet so they can see the person attacking
    'SendAttack Index
    
    ' Try to attack a player
    For i = 1 To Player_HighIndex
        TempIndex = i

        ' Make sure we dont try to attack ourselves
        If TempIndex <> index Then
            TryPlayerAttackPlayer index, i
        End If
    Next

    ' Try to attack a npc
    For i = 1 To MAX_MAP_NPCS
        TryPlayerAttackNpc index, i
    Next

    ' Check tradeskills
    Select Case GetPlayerDir(index)
        Case DIR_UP

            If GetPlayerY(index) = 0 Then Exit Sub
            X = GetPlayerX(index)
            Y = GetPlayerY(index) - 1
        Case DIR_DOWN

            If GetPlayerY(index) = Map(GetPlayerMap(index)).MaxY Then Exit Sub
            X = GetPlayerX(index)
            Y = GetPlayerY(index) + 1
        Case DIR_LEFT

            If GetPlayerX(index) = 0 Then Exit Sub
            X = GetPlayerX(index) - 1
            Y = GetPlayerY(index)
        Case DIR_RIGHT

            If GetPlayerX(index) = Map(GetPlayerMap(index)).MaxX Then Exit Sub
            X = GetPlayerX(index) + 1
            Y = GetPlayerY(index)
    End Select
    
    Select Case GetPlayerEquipment(index, Equipment.Weapon)
        Case 104 'Shuriken Attacks
            SendArrow index, 4, GetPlayerX(index), GetPlayerY(index), 4, GetPlayerDamage(index), 100
        Case 105 'Fuuma Shuriken
            SendArrow index, 9, GetPlayerX(index), GetPlayerY(index), 6, GetPlayerDamage(index), 100
        Case 106 'Kunai com Chakra
            SendArrow index, 26, GetPlayerX(index), GetPlayerY(index), 8, GetPlayerDamage(index), 100
        Case 107 'Shuriken Lendária
            SendArrow index, 12, GetPlayerX(index), GetPlayerY(index), 10, GetPlayerDamage(index), 100
        Case 108 'Shuriken Lendária NIN
            SendArrow index, 12, GetPlayerX(index), GetPlayerY(index), 10, GetPlayerDamage(index, True), 100
        Case Else
            If GetPlayerClass(index) = SASUKE Then
                If TempPlayer(index).Reflect > 0 Then
                    If GetPlayerLevel(index) >= 750 Then
                        SendArrow index, 2, GetPlayerX(index), GetPlayerY(index), 10, GetPlayerDamage(index) / 2, 100
                    End If
                End If
            End If
    End Select
    
    CheckResource index, X, Y
    TempPlayer(index).AttackTimer = GetTickCount
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleAttack", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' ::::::::::::::::::::::
' :: Use stats packet ::
' ::::::::::::::::::::::
Sub HandleUseStatPoint(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
On Error GoTo errorhandler

Dim PointType As Byte
Dim qnt As Long
Dim Buffer As clsBuffer
Dim sMes As String
    
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    qnt = Buffer.ReadLong
    PointType = Buffer.ReadByte 'CLng(Parse(1))
    Set Buffer = Nothing

    ' Prevent hacking
    If (PointType < 0) Or (PointType > Stats.Stat_Count) Then
        Exit Sub
    End If
    
    If qnt < 1 Then Exit Sub
    

    ' Make sure they have points
    If GetPlayerPOINTS(index) >= qnt Then
        ' make sure they're not maxed#
        If GetPlayerRawStat(index, PointType) >= MAX_LONG Then
            PlayerMsg index, "You cannot spend any more points on that stat.", BrightRed
            Exit Sub
        End If
        
        ' Take away a stat point
        TempPlayer(index).SetPoints = YES
        Call SetPlayerPOINTS(index, GetPlayerPOINTS(index) - qnt)

        ' Everything is ok
        Select Case PointType
            Case Stats.strength
                Call SetPlayerStat(index, Stats.strength, GetPlayerRawStat(index, Stats.strength) + qnt)
                sMes = "Taijutsu"
            Case Stats.Endurance
                Call SetPlayerStat(index, Stats.Endurance, GetPlayerRawStat(index, Stats.Endurance) + qnt)
                sMes = "Resistência"
            Case Stats.Intelligence
                Call SetPlayerStat(index, Stats.Intelligence, GetPlayerRawStat(index, Stats.Intelligence) + qnt)
                sMes = "Ninjutsu"
            Case Stats.Agility
                Call SetPlayerStat(index, Stats.Agility, GetPlayerRawStat(index, Stats.Agility) + qnt)
                sMes = "Agilidade"
            Case Stats.Willpower
                Call SetPlayerStat(index, Stats.Willpower, GetPlayerRawStat(index, Stats.Willpower) + qnt)
                sMes = "Genjutsu"
        End Select
        
        SendActionMsg GetPlayerMap(index), "+" & qnt & " " & sMes, White, 1, (GetPlayerX(index) * 32), (GetPlayerY(index) * 32)

    Else
        Exit Sub
    End If

    ' Send the update
    'Call SendStats(Index)
    SendPlayerData index
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleUseStatPoint", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' ::::::::::::::::::::::::::::::::
' :: Player info request packet ::
' ::::::::::::::::::::::::::::::::
Sub HandlePlayerInfoRequest(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    'função inutel?
    Dim Name As String
    Dim i As Long
    Dim n As Long
    Dim Buffer As clsBuffer
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    Name = Buffer.ReadString 'Parse(1)
    Set Buffer = Nothing
    i = FindPlayer(Name)
    
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandlePlayerInfoRequest", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' :::::::::::::::::::::::
' :: Warp me to packet ::
' :::::::::::::::::::::::
Sub HandleWarpMeTo(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim n As Long
    Dim Buffer As clsBuffer
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()

    ' Prevent hacking
    If GetPlayerAccess(index) < ADMIN_MONITOR Then
        Exit Sub
    End If

    ' The player
    n = FindPlayer(Buffer.ReadString) 'Parse(1))
    Set Buffer = Nothing

    If n <> index Then
        If n > 0 Then
            Call PlayerWarp(index, GetPlayerMap(n), GetPlayerX(n), GetPlayerY(n))
            If GetPlayerAccess(n) = ADMIN_CREATOR Then
                Call PlayerMsg(n, GetPlayerName(index) & " has warped to you.", BrightBlue)
            End If
            Call PlayerMsg(index, "You have been warped to " & GetPlayerName(n) & ".", BrightBlue)
            Call AddLog(GetPlayerName(index) & " has warped to " & GetPlayerName(n) & ", map #" & GetPlayerMap(n) & ".", ADMIN_LOG)
        Else
            Call PlayerMsg(index, "Player is not online.", White)
        End If

    Else
        Call PlayerMsg(index, "You cannot warp to yourself!", White)
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleWarpMeTo", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
    
End Sub

' :::::::::::::::::::::::
' :: Warp to me packet ::
' :::::::::::::::::::::::
Sub HandleWarpToMe(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim n As Long
    Dim Buffer As clsBuffer
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()

    ' Prevent hacking
    If GetPlayerAccess(index) < 3 Then
        Exit Sub
    End If

    ' The player
    n = AcharPlayer(Buffer.ReadString) 'Parse(1))
    Set Buffer = Nothing
    
    If n <> index Then
        If n > 0 Then
            If GetPlayerAccess(index) <= ADMIN_DEVELOPER Then
                If Weekday(Now) = 7 Or Weekday(Now) = 1 Then
                   If GetPlayerMap(index) = 98 Or GetPlayerMap(index) = 95 Or GetPlayerMap(index) = 100 Then Exit Sub
                   If GetPlayerMap(n) = 98 Or GetPlayerMap(n) = 95 Or GetPlayerMap(n) = 100 Then Exit Sub
                   If GetPlayerMap(index) >= 57 And GetPlayerMap(index) <= 68 Then Exit Sub
                   If GetPlayerMap(n) >= 57 And GetPlayerMap(n) <= 68 Then Exit Sub
                End If
            End If
            
            If GetPlayerAccess(index) = ADMIN_CREATOR Then
                If GetPlayerMap(index) = 98 Or GetPlayerMap(index) = 100 Then
                    'Player(n).InTorneio = Torneio
                End If
            End If
            
            Call PlayerWarp(n, GetPlayerMap(index), GetPlayerX(index), GetPlayerY(index))
            'Call PlayerMsg(n, "You have been summoned by " & GetPlayerName(index) & ".", BrightBlue)
            Call PlayerMsg(index, GetPlayerName(n) & " has been summoned.", BrightBlue)
            Call AddLog(GetPlayerName(index) & " has warped " & GetPlayerName(n) & " to self, map #" & GetPlayerMap(index) & ".", ADMIN_LOG)
        Else
            Call PlayerMsg(index, "Player is not online.", White)
        End If

    Else
        Call PlayerMsg(index, "You cannot warp yourself to yourself!", White)
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleWarpToMe", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' ::::::::::::::::::::::::
' :: Warp to map packet ::
' ::::::::::::::::::::::::
Sub HandleWarpTo(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim n, i As Long
    Dim Buffer As clsBuffer
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()

    ' Prevent hacking
    'If GetPlayerAccess(index) < ADMIN_MAPPER Then
        'Exit Sub
    'End If
    If Player(index).Spec = YES Then
        PlayerMsg index, "Você está em modo Espectador,desative-o clicando de volta!", Red
        Exit Sub
    End If
    
    'If Torneio = TORNEIO_CS Then
        If Player(index).InTorneio > 0 Then
            PlayerMsg index, "Você já está em um torneio,negado!(Para sair vá em Extras>Sair Torneio)", BrightRed
            Exit Sub
        End If
    'End If
                
    ' The map
    n = Buffer.ReadLong 'CLng(Parse(1))
    Set Buffer = Nothing

    ' Prevent hacking
    If n < 0 Or n > MAX_MAPS Then
        Exit Sub
    End If
    
    If GetPlayerAccess(index) <= 1 And Map(GetPlayerMap(index)).Moral <> MAP_MORAL_SAFE Then
        If GetPlayerVital(index, Vitals.HP) < GetPlayerMaxVital(index, Vitals.HP) Then
            PlayerMsg index, "Você precisa estar com a vida cheia OU em zona segura.", White
            Exit Sub
        End If
    End If
    
    Select Case n
        Case 1 'Konoha
            PlayerWarp index, 1, 13, 37
        Case 22 'Iwa
            If Player(index).VipData.VIP > 0 Then
                PlayerWarp index, 22, 11, 25
            End If
        Case 32 'Kiri
            If Player(index).VipData.VIP > 0 Then
                PlayerWarp index, 34, 12, 11
            End If
        Case 50 'Suna
            If Player(index).VipData.VIP > 0 Then
                PlayerWarp index, 50, 15, 10
            End If
        Case 82 'Area VIP
            'If Player(index).VipData.VIP > 0 Then
                PlayerWarp index, 82, 9, 13
                PlayerMsg index, "Bem vindo à àrea vip!", BrightGreen
            'Else
                'PlayerMsg index, "Apenas vips..", BrightRed
                
            'End If
        Case 96 'arena
            PlayerWarp index, 96, 1, 1
            
        Case 98 'Torneios
            If GetPlayerAccess(index) > 1 Then
                PlayerWarp index, 98, 5, 5
            Else
                Torneios index
            End If
        Case 99 'Atendimento
            PlayerWarp index, 99, 10, 6
        Case 123 'som
            If Player(index).VipData.VIP > 0 Then
                PlayerWarp index, 123, 10, 8
            End If
        Case 151 'Kumo
            If Player(index).VipData.VIP > 0 Then
                PlayerWarp index, 151, 16, 11
            End If
        Case 173 'chuva
            If Player(index).VipData.VIP > 0 Then
                PlayerWarp index, 173, 14, 9
            End If
        Case 208 'takigakure
            If Player(index).VipData.VIP > 0 Then
                PlayerWarp index, 208, 19, 12
            End If
        Case 226 'ferro
            If Player(index).VipData.VIP > 0 Then
                PlayerWarp index, 226, 11, 2
            End If
            
        Case 260 To 279
            If Player(index).VipData.VIP > 1 Or GetPlayerAccess(index) > 1 Then
                PlayerWarp index, RAND(260, 279), 11, 2
            Else
                PlayerMsg index, "comando vip ohyeh", White
            End If
        
        Case 294 'ct kage
            If GetPlayerAccess(index) < 2 Then 'player
                If Player(index).Rank = RANK_KAGE Then
                    PlayerWarp index, 294, 7, 1
                Else
                    PlayerMsg index, "Você é fraco demais para ir lá..", BrightRed
                    Exit Sub
                End If
            Else 'gm
                PlayerWarp index, 294, 7, 1
            End If
            
        Case 295 'CT
            If Player(index).CTdata.CT = YES Then
                PlayerWarp index, 295, 6, 11
            Else
                PlayerMsg index, "Você não têm a Chave pro CT!", Red
            End If
        Case Else
            If GetPlayerAccess(index) >= ADMIN_MONITOR Then
                Call PlayerWarp(index, n, GetPlayerX(index), 50)
            End If
    End Select
    
    If GetPlayerAccess(index) > 3 Then
        Call PlayerMsg(index, "You have been warped to map #" & n, BrightBlue)
    End If
    
    'Call AddLog(GetPlayerName(index) & " warped to map #" & n & ".", ADMIN_LOG)
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleWarpTo", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' :::::::::::::::::::::::
' :: Set sprite packet ::
' :::::::::::::::::::::::
Sub HandleSetSprite(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim n As Long
    Dim Buffer As clsBuffer
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()

    ' Prevent hacking
    If GetPlayerAccess(index) < ADMIN_MONITOR Then
        Exit Sub
    End If

    ' The sprite
    n = Buffer.ReadLong 'CLng(Parse(1))
    Set Buffer = Nothing
    Call SetPlayerSprite(index, n)
    Call SendPlayerData(index)
    Exit Sub
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleSetSprite", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub


' ::::::::::::::::::::::::::::::::::
' :: Player request for a new map ::
' ::::::::::::::::::::::::::::::::::
Sub HandleRequestNewMap(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Dir As Long
    Dim Buffer As clsBuffer
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    Dir = Buffer.ReadLong 'CLng(Parse(1))
    Set Buffer = Nothing

    ' Prevent hacking
    If Dir < DIR_UP Or Dir > DIR_RIGHT Then
        Exit Sub
    End If

    Call PlayerMove(index, Dir, 1)
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleRequestNewMap", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' :::::::::::::::::::::
' :: Map data packet ::
' :::::::::::::::::::::
Sub HandleMapData(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim i As Long
    Dim mapNum As Long
    Dim X As Long
    Dim Y As Long
    Dim Buffer As clsBuffer
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()

    ' Prevent hacking
    If GetPlayerAccess(index) < ADMIN_CREATOR Then
        Exit Sub
    End If

    mapNum = GetPlayerMap(index)
    i = Map(mapNum).Revision + 1
    Call ClearMap(mapNum)
    
    Map(mapNum).Name = Buffer.ReadString
    Map(mapNum).Music = Buffer.ReadString
    Map(mapNum).Weather = Buffer.ReadLong 'temperatura
    Map(mapNum).Revision = i
    Map(mapNum).Moral = Buffer.ReadByte
    Map(mapNum).Up = Buffer.ReadLong
    Map(mapNum).Down = Buffer.ReadLong
    Map(mapNum).Left = Buffer.ReadLong
    Map(mapNum).Right = Buffer.ReadLong
    Map(mapNum).BootMap = Buffer.ReadLong
    Map(mapNum).BootX = Buffer.ReadByte
    Map(mapNum).BootY = Buffer.ReadByte
    Map(mapNum).MaxX = Buffer.ReadByte
    Map(mapNum).MaxY = Buffer.ReadByte
    ReDim Map(mapNum).Tile(0 To Map(mapNum).MaxX, 0 To Map(mapNum).MaxY)

    For X = 0 To Map(mapNum).MaxX
        For Y = 0 To Map(mapNum).MaxY
            For i = 1 To MapLayer.Layer_Count - 1
                Map(mapNum).Tile(X, Y).Layer(i).X = Buffer.ReadLong
                Map(mapNum).Tile(X, Y).Layer(i).Y = Buffer.ReadLong
                Map(mapNum).Tile(X, Y).Layer(i).Tileset = Buffer.ReadLong
            Next
            Map(mapNum).Tile(X, Y).Type = Buffer.ReadByte
            Map(mapNum).Tile(X, Y).Data1 = Buffer.ReadLong
            Map(mapNum).Tile(X, Y).Data2 = Buffer.ReadLong
            Map(mapNum).Tile(X, Y).Data3 = Buffer.ReadLong
            Map(mapNum).Tile(X, Y).DirBlock = Buffer.ReadByte
            Map(mapNum).Tile(X, Y).Animation = Buffer.ReadLong 'animação
        Next
    Next

    For X = 1 To MAX_MAP_NPCS
        Map(mapNum).Npc(X) = Buffer.ReadLong
        Call ClearMapNpc(X, mapNum)
    Next

    Call SendMapNpcsToMap(mapNum)
    Call SpawnMapNpcs(mapNum)

    ' Clear out it all
    For i = 1 To MAX_MAP_ITEMS
        Call SpawnItemSlot(i, 0, 0, GetPlayerMap(index), MapItem(GetPlayerMap(index), i).X, MapItem(GetPlayerMap(index), i).Y)
        Call ClearMapItem(i, GetPlayerMap(index))
    Next

    ' Respawn
    Call SpawnMapItems(GetPlayerMap(index))
    ' Save the map
    Call SaveMap(mapNum)
    Call MapCache_Create(mapNum)
    Call ClearTempTile(mapNum)
    Call CacheResources(mapNum)

    ' Refresh map for everyone online
    For i = 1 To Player_HighIndex
        If IsPlaying(i) And GetPlayerMap(i) = mapNum Then
            Call PlayerWarp(i, mapNum, GetPlayerX(i), GetPlayerY(i))
        End If
    Next i

    Set Buffer = Nothing
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleMapData", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' ::::::::::::::::::::::::::::
' :: Need map yes/no packet ::
' ::::::::::::::::::::::::::::
Sub HandleNeedMap(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    If GetPlayerMap(index) < 1 Or GetPlayerMap(index) > MAX_MAPS Then Exit Sub
    
    Dim s As String
    Dim Buffer As clsBuffer
    Dim i As Long
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    ' Get yes/no value
    s = Buffer.ReadLong 'Parse(1)
    Set Buffer = Nothing

    ' Check if map data is needed to be sent
    If s = 1 Then
        Call SendMap(index, GetPlayerMap(index))
    End If

    Call SendMapItemsTo(index, GetPlayerMap(index))
    Call SendMapNpcsTo(index, GetPlayerMap(index))
    Call SendJoinMap(index)

    'send Resource cache
    For i = 0 To ResourceCache(GetPlayerMap(index)).Resource_Count
        SendResourceCacheTo index, i
    Next

    TempPlayer(index).GettingMap = NO
    Set Buffer = New clsBuffer
    Buffer.WriteLong SMapDone
    SendDataTo index, Buffer.ToArray()
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleNeedMap", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' :::::::::::::::::::::::::::::::::::::::::::::::
' :: Player trying to pick up something packet ::
' :::::::::::::::::::::::::::::::::::::::::::::::
Sub HandleMapGetItem(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    If Player(index).Invisivel = YES Then Exit Sub
    
    Call PlayerMapGetItem(index)
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleMapGetItem", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' ::::::::::::::::::::::::::::::::::::::::::::
' :: Player trying to drop something packet ::
' ::::::::::::::::::::::::::::::::::::::::::::
Sub HandleMapDropItem(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim invNum As Long
    Dim amount As Long
    Dim Buffer As clsBuffer
    Set Buffer = New clsBuffer
    
    Buffer.WriteBytes Data()
    invNum = Buffer.ReadLong 'CLng(Parse(1))
    amount = Buffer.ReadLong 'CLng(Parse(2))
    Set Buffer = Nothing
    
    If TempPlayer(index).InBank Or TempPlayer(index).InShop Then Exit Sub
    If Player(index).Spec = YES Then Exit Sub
    If Player(index).Invisivel = YES Then Exit Sub
    If Player(index).InTorneio > 0 Then Exit Sub
    
    ' Prevent hacking
    If invNum < 1 Or invNum > MAX_INV Then Exit Sub
    
    If GetPlayerInvItemNum(index, invNum) < 1 Or GetPlayerInvItemNum(index, invNum) > MAX_ITEMS Then Exit Sub
    
    If Item(GetPlayerInvItemNum(index, invNum)).Type = ITEM_TYPE_CURRENCY Then
        If amount < 1 Or amount > GetPlayerInvItemValue(index, invNum) Then Exit Sub
    End If
    
    ' everything worked out fine
    Call PlayerMapDropItem(index, invNum, amount)
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleMapDropItem", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' ::::::::::::::::::::::::
' :: Respawn map packet ::
' ::::::::::::::::::::::::
Sub HandleMapRespawn(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim i As Long

    ' Prevent hacking
    If GetPlayerAccess(index) < ADMIN_CREATOR Then
        Exit Sub
    End If

    ' Clear out it all
    For i = 1 To MAX_MAP_ITEMS
        Call SpawnItemSlot(i, 0, 0, GetPlayerMap(index), MapItem(GetPlayerMap(index), i).X, MapItem(GetPlayerMap(index), i).Y)
        Call ClearMapItem(i, GetPlayerMap(index))
    Next

    ' Respawn
    Call SpawnMapItems(GetPlayerMap(index))

    ' Respawn NPCS
    For i = 1 To MAX_MAP_NPCS
        Call SpawnNpc(i, GetPlayerMap(index))
    Next

    CacheResources GetPlayerMap(index)
    Call PlayerMsg(index, "Map respawned.", Blue)
    Call AddLog(GetPlayerName(index) & " has respawned map #" & GetPlayerMap(index), ADMIN_LOG)
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleMapRespawn", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' :::::::::::::::::::::::
' :: Map report packet ::
' :::::::::::::::::::::::
Sub HandleMapReport(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim s As String
    Dim i As Long
    Dim tMapStart As Long
    Dim tMapEnd As Long

    ' Prevent hacking
    If GetPlayerAccess(index) < ADMIN_MAPPER Then
        Exit Sub
    End If

    s = "Free Maps: "
    tMapStart = 1
    tMapEnd = 1

    For i = 1 To MAX_MAPS

        If LenB(Trim$(Map(i).Name)) = 0 Then
            tMapEnd = tMapEnd + 1
        Else

            If tMapEnd - tMapStart > 0 Then
                s = s & Trim$(CStr(tMapStart)) & "-" & Trim$(CStr(tMapEnd - 1)) & ", "
            End If

            tMapStart = i + 1
            tMapEnd = i + 1
        End If

    Next

    s = s & Trim$(CStr(tMapStart)) & "-" & Trim$(CStr(tMapEnd - 1)) & ", "
    s = Mid$(s, 1, Len(s) - 2)
    s = s & "."
    Call PlayerMsg(index, s, Brown)
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleMapReport", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' ::::::::::::::::::::::::
' :: Kick player packet ::
' ::::::::::::::::::::::::
Sub HandleKickPlayer(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim n As Long
    Dim Buffer As clsBuffer
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()

    ' Prevent hacking
    If GetPlayerAccess(index) <= 1 Then
        Exit Sub
    End If

    ' The player index
    n = FindPlayer(Buffer.ReadString) 'Parse(1))
    Set Buffer = Nothing
    
    If GetPlayerAccess(n) >= 5 Then
        AlertMsg index, "Nawb"
        Exit Sub
    End If
    
    If n <> index Then
        If n > 0 Then
            If GetPlayerAccess(n) < GetPlayerAccess(index) Then
                Call GlobalMsg(GetPlayerName(n) & " has been kicked from " & Options.Game_Name & " by " & GetPlayerName(index) & "!", White)
                Call AddLog(GetPlayerName(index) & " has kicked " & GetPlayerName(n) & ".", ADMIN_LOG)
                Call AlertMsg(n, "You have been kicked by " & GetPlayerName(index) & "!")
            Else
                Call PlayerMsg(index, "That is a higher or same access admin then you!", White)
            End If

        Else
            Call PlayerMsg(index, "Player is not online.", White)
        End If

    Else
        Call PlayerMsg(index, "You cannot kick yourself!", White)
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleKickPlayer", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' :::::::::::::::::::::
' :: Ban list packet ::
' :::::::::::::::::::::
Sub HandleBanList(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim n As Long
    Dim F As Long
    Dim s As String
    Dim Name As String

    ' Prevent hacking
    If GetPlayerAccess(index) < 3 Then
        Exit Sub
    End If

    n = 1
    F = FreeFile
    Open App.Path & "\data\banlist.txt" For Input As #F

    Do While Not EOF(F)
        Input #F, s
        Input #F, Name
        Call PlayerMsg(index, n & ": Banned IP " & s & " by " & Name, White)
        n = n + 1
    Loop

    Close #F
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleBanList", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' ::::::::::::::::::::::::
' :: Ban destroy packet ::
' ::::::::::::::::::::::::
Sub HandleBanDestroy(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim filename As String
    Dim File As Long
    Dim F As Long

    ' Prevent hacking
    If GetPlayerAccess(index) < ADMIN_CREATOR Then
        Exit Sub
    End If

    filename = App.Path & "\data\banlist.txt"

    If Not FileExist("data\banlist.txt") Then
        F = FreeFile
        Open filename For Output As #F
        Close #F
    End If

    Kill filename
    Call PlayerMsg(index, "Ban list destroyed.", White)
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleBanDestroy", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' :::::::::::::::::::::::
' :: Ban player packet ::
' :::::::::::::::::::::::
Sub HandleBanPlayer(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    Exit Sub
    Dim n As Long
    Dim Buffer As clsBuffer
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()

    ' Prevent hacking
    If GetPlayerAccess(index) < ADMIN_MAPPER Then
        Exit Sub
    End If

    ' The player index
    n = FindPlayer(Buffer.ReadString) 'Parse(1))
    Set Buffer = Nothing

    If n <> index Then
        If n > 0 Then
            If GetPlayerAccess(n) < GetPlayerAccess(index) Then
                Call BanIndex(n, index)
            Else
                Call PlayerMsg(index, "That is a higher or same access admin then you!", White)
            End If

        Else
            Call PlayerMsg(index, "Player is not online.", White)
        End If

    Else
        Call PlayerMsg(index, "You cannot ban yourself!", White)
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleBanPlayer", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' :::::::::::::::::::::::::::::
' :: Request edit map packet ::
' :::::::::::::::::::::::::::::
Sub HandleRequestEditMap(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer

    ' Prevent hacking
    If GetPlayerAccess(index) < ADMIN_MAPPER Then
        Exit Sub
    End If

    Set Buffer = New clsBuffer
    Buffer.WriteLong SEditMap
    SendDataTo index, Buffer.ToArray()
    Set Buffer = Nothing
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleRequestEditMap", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' ::::::::::::::::::::::::::::::
' :: Request edit item packet ::
' ::::::::::::::::::::::::::::::
Sub HandleRequestEditItem(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer

    ' Prevent hacking
    If GetPlayerAccess(index) < ADMIN_DEVELOPER Then
        Exit Sub
    End If

    Set Buffer = New clsBuffer
    Buffer.WriteLong SItemEditor
    SendDataTo index, Buffer.ToArray()
    Set Buffer = Nothing
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleRequestEditItem", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' ::::::::::::::::::::::
' :: Save item packet ::
' ::::::::::::::::::::::
Sub HandleSaveItem(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim n As Long
    Dim Buffer As clsBuffer
    Dim ItemSize As Long
    Dim ItemData() As Byte
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()

    ' Prevent hacking
    If GetPlayerAccess(index) < ADMIN_CREATOR Then
        Exit Sub
    End If

    n = Buffer.ReadLong 'CLng(Parse(1))

    If n < 0 Or n > MAX_ITEMS Then
        Exit Sub
    End If

    ' Update the item
    ItemSize = LenB(Item(n))
    ReDim ItemData(ItemSize - 1)
    ItemData = Buffer.ReadBytes(ItemSize)
    CopyMemory ByVal VarPtr(Item(n)), ByVal VarPtr(ItemData(0)), ItemSize
    Set Buffer = Nothing
    
    ' Save it
    Call SendUpdateItemToAll(n)
    Call SaveItem(n)
    Call AddLog(GetPlayerName(index) & " saved item #" & n & ".", ADMIN_LOG)
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleSaveItem", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' ::::::::::::::::::::::::::::::
' :: Request edit Animation packet ::
' ::::::::::::::::::::::::::::::
Sub HandleRequestEditAnimation(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer

    ' Prevent hacking
    If GetPlayerAccess(index) < ADMIN_DEVELOPER Then
        Exit Sub
    End If

    Set Buffer = New clsBuffer
    Buffer.WriteLong SAnimationEditor
    SendDataTo index, Buffer.ToArray()
    Set Buffer = Nothing
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleRequestEditAnimation", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' ::::::::::::::::::::::
' :: Save Animation packet ::
' ::::::::::::::::::::::
Sub HandleSaveAnimation(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim n As Long
    Dim Buffer As clsBuffer
    Dim AnimationSize As Long
    Dim AnimationData() As Byte
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()

    ' Prevent hacking
    If GetPlayerAccess(index) < ADMIN_CREATOR Then
        Exit Sub
    End If

    n = Buffer.ReadLong 'CLng(Parse(1))

    If n < 0 Or n > MAX_ANIMATIONS Then
        Exit Sub
    End If

    ' Update the Animation
    AnimationSize = LenB(Animation(n))
    ReDim AnimationData(AnimationSize - 1)
    AnimationData = Buffer.ReadBytes(AnimationSize)
    CopyMemory ByVal VarPtr(Animation(n)), ByVal VarPtr(AnimationData(0)), AnimationSize
    Set Buffer = Nothing
    
    ' Save it
    Call SendUpdateAnimationToAll(n)
    Call SaveAnimation(n)
    Call AddLog(GetPlayerName(index) & " saved Animation #" & n & ".", ADMIN_LOG)
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleSaveAnimation", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' :::::::::::::::::::::::::::::
' :: Request edit npc packet ::
' :::::::::::::::::::::::::::::
Sub HandleRequestEditNpc(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer

    ' Prevent hacking
    If GetPlayerAccess(index) < ADMIN_DEVELOPER Then
        Exit Sub
    End If

    Set Buffer = New clsBuffer
    Buffer.WriteLong SNpcEditor
    SendDataTo index, Buffer.ToArray()
    Set Buffer = Nothing
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleRequestEditNpc", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' :::::::::::::::::::::
' :: Save npc packet ::
' :::::::::::::::::::::
Private Sub HandleSaveNpc(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim NpcNum As Long
    Dim Buffer As clsBuffer
    Dim NPCSize As Long
    Dim NPCData() As Byte

    ' Prevent hacking
    If GetPlayerAccess(index) < ADMIN_CREATOR Then
        Exit Sub
    End If

    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    NpcNum = Buffer.ReadLong

    ' Prevent hacking
    If NpcNum < 0 Or NpcNum > MAX_NPCS Then
        Exit Sub
    End If

    NPCSize = LenB(Npc(NpcNum))
    ReDim NPCData(NPCSize - 1)
    NPCData = Buffer.ReadBytes(NPCSize)
    CopyMemory ByVal VarPtr(Npc(NpcNum)), ByVal VarPtr(NPCData(0)), NPCSize
    ' Save it
    Call SendUpdateNpcToAll(NpcNum)
    Call SaveNpc(NpcNum)
    Call AddLog(GetPlayerName(index) & " saved Npc #" & NpcNum & ".", ADMIN_LOG)
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleSaveNpc", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' :::::::::::::::::::::::::::::
' :: Request edit Resource packet ::
' :::::::::::::::::::::::::::::
Sub HandleRequestEditResource(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer

    ' Prevent hacking
    If GetPlayerAccess(index) < ADMIN_DEVELOPER Then
        Exit Sub
    End If

    Set Buffer = New clsBuffer
    Buffer.WriteLong SResourceEditor
    SendDataTo index, Buffer.ToArray()
    Set Buffer = Nothing
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleRequestEditResource", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' :::::::::::::::::::::
' :: Save Resource packet ::
' :::::::::::::::::::::
Private Sub HandleSaveResource(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim ResourceNum As Long
    Dim Buffer As clsBuffer
    Dim ResourceSize As Long
    Dim ResourceData() As Byte

    ' Prevent hacking
    If GetPlayerAccess(index) < ADMIN_CREATOR Then
        Exit Sub
    End If

    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    ResourceNum = Buffer.ReadLong

    ' Prevent hacking
    If ResourceNum < 0 Or ResourceNum > MAX_RESOURCES Then
        Exit Sub
    End If

    ResourceSize = LenB(Resource(ResourceNum))
    ReDim ResourceData(ResourceSize - 1)
    ResourceData = Buffer.ReadBytes(ResourceSize)
    CopyMemory ByVal VarPtr(Resource(ResourceNum)), ByVal VarPtr(ResourceData(0)), ResourceSize
    ' Save it
    Call SendUpdateResourceToAll(ResourceNum)
    Call SaveResource(ResourceNum)
    Call AddLog(GetPlayerName(index) & " saved Resource #" & ResourceNum & ".", ADMIN_LOG)
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleSaveResource", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' ::::::::::::::::::::::::::::::
' :: Request edit shop packet ::
' ::::::::::::::::::::::::::::::
Sub HandleRequestEditShop(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer

    ' Prevent hacking
    If GetPlayerAccess(index) < ADMIN_CREATOR Then
        Exit Sub
    End If

    Set Buffer = New clsBuffer
    Buffer.WriteLong SShopEditor
    SendDataTo index, Buffer.ToArray()
    Set Buffer = Nothing
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleRequestEditShop", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' ::::::::::::::::::::::
' :: Save shop packet ::
' ::::::::::::::::::::::
Sub HandleSaveShop(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim shopNum As Long
    Dim i As Long
    Dim Buffer As clsBuffer
    Dim ShopSize As Long
    Dim ShopData() As Byte
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()

    ' Prevent hacking
    If GetPlayerAccess(index) < ADMIN_CREATOR Then
        Exit Sub
    End If

    shopNum = Buffer.ReadLong

    ' Prevent hacking
    If shopNum < 0 Or shopNum > MAX_SHOPS Then
        Exit Sub
    End If

    ShopSize = LenB(Shop(shopNum))
    ReDim ShopData(ShopSize - 1)
    ShopData = Buffer.ReadBytes(ShopSize)
    CopyMemory ByVal VarPtr(Shop(shopNum)), ByVal VarPtr(ShopData(0)), ShopSize

    Set Buffer = Nothing
    ' Save it
    Call SendUpdateShopToAll(shopNum)
    Call SaveShop(shopNum)
    Call AddLog(GetPlayerName(index) & " saving shop #" & shopNum & ".", ADMIN_LOG)
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleSaveShop", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' :::::::::::::::::::::::::::::
' :: Request edit spell packet ::
' :::::::::::::::::::::::::::::
Sub HandleRequestEditSpell(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer

    ' Prevent hacking
    If GetPlayerAccess(index) < ADMIN_DEVELOPER Then
        Exit Sub
    End If

    Set Buffer = New clsBuffer
    Buffer.WriteLong SSpellEditor
    SendDataTo index, Buffer.ToArray()
    Set Buffer = Nothing
    
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleRequestEditSpell", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' :::::::::::::::::::::::
' :: Save spell packet ::
' :::::::::::::::::::::::
Sub HandleSaveSpell(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim SpellNum As Long
    Dim Buffer As clsBuffer
    Dim SpellSize As Long
    Dim SpellData() As Byte

    ' Prevent hacking
    If GetPlayerAccess(index) < ADMIN_CREATOR Then
        Exit Sub
    End If

    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    SpellNum = Buffer.ReadLong

    ' Prevent hacking
    If SpellNum < 0 Or SpellNum > MAX_SPELLS Then
        Exit Sub
    End If

    SpellSize = LenB(Spell(SpellNum))
    ReDim SpellData(SpellSize - 1)
    SpellData = Buffer.ReadBytes(SpellSize)
    CopyMemory ByVal VarPtr(Spell(SpellNum)), ByVal VarPtr(SpellData(0)), SpellSize
    ' Save it
    Call SendUpdateSpellToAll(SpellNum)
    Call SaveSpell(SpellNum)
    Call AddLog(GetPlayerName(index) & " saved Spell #" & SpellNum & ".", ADMIN_LOG)
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleSaveSpell", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' :::::::::::::::::::::::
' :: Set access packet ::
' :::::::::::::::::::::::
Sub HandleSetAccess(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim n As Long
    Dim i As Long
    Dim Buffer As clsBuffer
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()

    ' Prevent hacking
    If GetPlayerAccess(index) < ADMIN_CREATOR Then
        Exit Sub
    End If

    ' The index
    n = FindPlayer(Buffer.ReadString) 'Parse(1))
    ' The access
    i = Buffer.ReadLong 'CLng(Parse(2))
    Set Buffer = Nothing

    ' Check for invalid access level
    If i >= 0 Or i <= 3 Then

        ' Check if player is on
        If n > 0 Then

            'check to see if same level access is trying to change another access of the very same level and boot them if they are.
            If GetPlayerAccess(n) = GetPlayerAccess(index) Then
                Call PlayerMsg(index, "Invalid access level.", Red)
                Exit Sub
            End If

            If GetPlayerAccess(n) <= 0 Then
                Call GlobalMsg(GetPlayerName(n) & " has been blessed with administrative access.", BrightBlue)
            End If

            Call SetPlayerAccess(n, i)
            Call SendPlayerData(n)
            Call AddLog(GetPlayerName(index) & " has modified " & GetPlayerName(n) & "'s access.", ADMIN_LOG)
        Else
            Call PlayerMsg(index, "Player is not online.", White)
        End If

    Else
        Call PlayerMsg(index, "Invalid access level.", Red)
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleSetAccess", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub


' :::::::::::::::::::
' :: Search packet ::
' :::::::::::::::::::
Sub HandleSearch(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    If GetPlayerMap(index) < 1 Or GetPlayerMap(index) > MAX_MAPS Then Exit Sub
    
    Dim X As Long
    Dim Y As Long
    Dim i As Long
    Dim Buffer As clsBuffer
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    X = Buffer.ReadLong 'CLng(Parse(1))
    Y = Buffer.ReadLong 'CLng(Parse(2))
    Set Buffer = Nothing

    ' Prevent subscript out of range
    If X < 0 Or X > Map(GetPlayerMap(index)).MaxX Or Y < 0 Or Y > Map(GetPlayerMap(index)).MaxY Then
        Exit Sub
    End If

    ' Check for a player
    For i = 1 To Player_HighIndex

        If IsPlaying(i) Then
            If GetPlayerMap(index) = GetPlayerMap(i) Then
                If GetPlayerX(i) = X Then
                    If GetPlayerY(i) = Y Then
                        ' Change target
                        If TempPlayer(index).targetType = TARGET_TYPE_PLAYER And TempPlayer(index).Target = i Then
                            TempPlayer(index).Target = 0
                            TempPlayer(index).targetType = TARGET_TYPE_NONE
                            ' send target to player
                            SendTarget index
                        Else
                            TempPlayer(index).Target = i
                            TempPlayer(index).targetType = TARGET_TYPE_PLAYER
                            ' send target to player
                            SendTarget index
                        End If
                        Exit Sub
                    End If
                End If
            End If
        End If
    Next

    ' Check for an npc
    For i = 1 To MAX_MAP_NPCS
        If MapNpc(GetPlayerMap(index)).Npc(i).num > 0 Then
            If MapNpc(GetPlayerMap(index)).Npc(i).X = X Then
                If MapNpc(GetPlayerMap(index)).Npc(i).Y = Y Then
                If MapNpc(GetPlayerMap(index)).Npc(i).IsPet = NO Then
                    If TempPlayer(index).Target = i And TempPlayer(index).targetType = TARGET_TYPE_NPC Then
                        ' Change target
                        TempPlayer(index).Target = 0
                        TempPlayer(index).targetType = TARGET_TYPE_NONE
                        ' send target to player
                        SendTarget index
                    Else
                        ' Change target
                        TempPlayer(index).Target = i
                        TempPlayer(index).targetType = TARGET_TYPE_NPC
                        ' send target to player
                        SendTarget index
                        Exit Sub
                    End If
                End If
                End If
            End If
        End If
    Next
    
    If Map(GetPlayerMap(index)).Tile(X, Y).Type = TILE_TYPE_ONCLICK Then
       Call ScriptedClick(index, Map(GetPlayerMap(index)).Tile(X, Y).Data1)
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleSearch", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' :::::::::::::::::::
' :: Spells packet ::
' :::::::::::::::::::
Sub HandleSpells(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    
    On Error GoTo errorhandler
    
    Call SendPlayerSpells(index)
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleSpells", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' :::::::::::::::::
' :: Cast packet ::
' :::::::::::::::::
Sub HandleCast(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim n As Long
    Dim Buffer As clsBuffer
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    ' Spell slot
    n = Buffer.ReadLong 'CLng(Parse(1))
    Set Buffer = Nothing
    ' set the spell buffer before castin
    Call BufferSpell(index, n)
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleCast", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' ::::::::::::::::::::::
' :: Quit game packet ::
' ::::::::::::::::::::::
Sub HandleQuit(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Call CloseSocket(index)
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleQuit", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' ::::::::::::::::::::::::::
' :: Swap Inventory Slots ::
' ::::::::::::::::::::::::::
Sub HandleSwapInvSlots(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim n As Long
    Dim Buffer As clsBuffer
    Dim oldSlot As Long, newSlot As Long
    
    If TempPlayer(index).InTrade > 0 Or TempPlayer(index).InBank Or TempPlayer(index).InShop Then Exit Sub
    
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    ' Old Slot
    oldSlot = Buffer.ReadLong
    newSlot = Buffer.ReadLong
    Set Buffer = Nothing
    PlayerSwitchInvSlots index, oldSlot, newSlot
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleSwapInvSlots", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
    
End Sub

Sub HandleSwapSpellSlots(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim oldSlot As Long, newSlot As Long, n As Long
    
    If TempPlayer(index).InTrade > 0 Or TempPlayer(index).InBank Or TempPlayer(index).InShop Then Exit Sub
    
    If TempPlayer(index).spellBuffer.Spell > 0 Then
        PlayerMsg index, "You cannot swap spells whilst casting.", BrightRed
        Exit Sub
    End If
    
    For n = 1 To MAX_PLAYER_SPELLS
        If TempPlayer(index).SpellCD(n) > GetTickCount Then
            PlayerMsg index, "You cannot swap spells whilst they're cooling down.", BrightRed
            Exit Sub
        End If
    Next
    
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    ' Old Slot
    oldSlot = Buffer.ReadLong
    newSlot = Buffer.ReadLong
    Set Buffer = Nothing
    PlayerSwitchSpellSlots index, oldSlot, newSlot
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleSwapSpellSlots", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
    
End Sub

' ::::::::::::::::
' :: Check Ping ::
' ::::::::::::::::
Sub HandleCheckPing(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    Exit Sub

    On Error GoTo errorhandler
    
    Dim n As Long
    Dim Buffer As clsBuffer
    Set Buffer = New clsBuffer
    Buffer.WriteLong SSendPing
    SendDataTo index, Buffer.ToArray()
    Set Buffer = Nothing
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleCheckPing", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleUnequip(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    PlayerUnequipItem index, Buffer.ReadLong
    Set Buffer = Nothing
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleUnequip", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub


Sub HandleRequestItems(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    SendItems index
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleRequestItems", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleRequestAnimations(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    SendAnimations index
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleRequestAnimations", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleRequestNPCS(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    SendNpcs index
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleRequestNPCS", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleRequestResources(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    SendResources index
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleRequestResources", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleRequestSpells(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    SendSpells index
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleRequestSpells", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleRequestShops(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    SendShops index
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleRequestShops", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleSpawnItem(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim tmpItem As Long
    Dim tmpAmount As Long
    
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    
    ' item
    tmpItem = Buffer.ReadLong
    tmpAmount = Buffer.ReadLong
        
    If GetPlayerAccess(index) < ADMIN_CREATOR Then Exit Sub
    
    SpawnItem tmpItem, tmpAmount, GetPlayerMap(index), GetPlayerX(index), GetPlayerY(index), GetPlayerName(index)
    Set Buffer = Nothing
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleSpawnItem", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleRequestLevelUp(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    If GetPlayerAccess(index) < ADMIN_MONITOR Then
        BanIndex index, 0
        Exit Sub
    End If
    
    TempPlayer(index).SetExp = YES
    SetPlayerExp index, GetPlayerNextLevel(index)
    CheckPlayerLevelUp index
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleRequestLevelUp", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleForgetSpell(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim spellslot As Long
    
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    
    spellslot = Buffer.ReadLong
    
    If FindOpenSpellSlot(index) > 0 Then
        PlayerMsg index, "Esse recurso é só para quem lotou a lista de jutsus", Red
        Exit Sub
    End If
    
    ' Check for subscript out of range
    If spellslot < 1 Or spellslot > MAX_PLAYER_SPELLS Then
        Exit Sub
    End If
    
    ' dont let them forget a spell which is in CD
    If TempPlayer(index).SpellCD(spellslot) > GetTickCount Then
        PlayerMsg index, "Cannot forget a spell which is cooling down!", BrightRed
        Exit Sub
    End If
    
    ' dont let them forget a spell which is buffered
    If TempPlayer(index).spellBuffer.Spell = spellslot Then
        PlayerMsg index, "Cannot forget a spell which you are casting!", BrightRed
        Exit Sub
    End If
    
    Player(index).Spell(spellslot) = 0
    SendPlayerSpells index
    
    Set Buffer = Nothing
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleForgetSpell", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleBuyItem(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim shopslot As Long
    Dim shopNum As Long
    Dim itemamount As Long
    
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    
    shopslot = Buffer.ReadLong
    
    ' not in shop, exit out
    shopNum = TempPlayer(index).InShop
    If shopNum < 1 Or shopNum > MAX_SHOPS Then Exit Sub
    
    With Shop(shopNum).TradeItem(shopslot)
        ' check trade exists
        If .Item < 1 Then Exit Sub
            
        ' check has the cost item
        itemamount = HasItem(index, .costitem)
        If itemamount = 0 Or itemamount < .costvalue Then
            PlayerMsg index, "You do not have enough to buy this item.", BrightRed
            ResetShopAction index
            Exit Sub
        End If
        
        If EmptyInvSlots(index) < 1 Then
            PlayerMsg index, "Sem espaço na mochila.", BrightRed
            ResetShopAction index
            Exit Sub
        End If
        
        ' it's fine, let's go ahead
        TakeInvItem index, .costitem, .costvalue
        GiveInvItem index, .Item, .ItemValue
    End With
    
    ' send confirmation message & reset their shop action
    PlayerMsg index, "Trade successful.", BrightGreen
    ResetShopAction index
    
    Set Buffer = Nothing
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleBuyItem", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleSellItem(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim invSlot As Long
    Dim itemNum As Long
    Dim price As Long
    Dim multiplier As Double
    Dim amount As Long
    
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    
    invSlot = Buffer.ReadLong
    
    ' if invalid, exit out
    If invSlot < 1 Or invSlot > MAX_INV Then Exit Sub
    
    ' has item?
    If GetPlayerInvItemNum(index, invSlot) < 1 Or GetPlayerInvItemNum(index, invSlot) > MAX_ITEMS Then Exit Sub
    
    ' seems to be valid
    itemNum = GetPlayerInvItemNum(index, invSlot)
    
    ' work out price
    multiplier = Shop(TempPlayer(index).InShop).BuyRate / 100
    If multiplier = 0 Then multiplier = 1
    price = Item(itemNum).price * multiplier
    
    ' item has cost?
    If price <= 0 Then
        PlayerMsg index, "Não aceitamos esse item.", BrightRed
        ResetShopAction index
        Exit Sub
    End If

    ' take item and give gold
    TakeInvItem index, itemNum, 1
    
    If Item(itemNum).Rarity > 0 Then
        GiveInvItem index, 254, price, True
        PlayerMsg index, "Você recebeu " & price & " cash!", Yellow
    Else
        GiveInvItem index, 1, price, True
        PlayerMsg index, "Você recebeu " & price & " YEN!", Yellow
    End If
    
    ' send confirmation message & reset their shop action
    PlayerMsg index, "Trade successful.", BrightGreen
    ResetShopAction index
    
    Set Buffer = Nothing
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleSellItem", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleChangeBankSlots(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim newSlot As Long
    Dim oldSlot As Long
    
    If TempPlayer(index).InBank = False Then
        PlayerMsg index, "Você não ta no  banco.", BrightRed
        Exit Sub
    End If
    
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    
    oldSlot = Buffer.ReadLong
    newSlot = Buffer.ReadLong
    
    PlayerSwitchBankSlots index, oldSlot, newSlot
    
    Set Buffer = Nothing
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleChangeBankSlots", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
    
End Sub

Sub HandleWithdrawItem(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim BankSlot As Long
    Dim amount As Long
    
    If TempPlayer(index).InBank = False Then
        PlayerMsg index, "Você não ta no  banco.", BrightRed
        Exit Sub
    End If
    
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    
    BankSlot = Buffer.ReadLong
    amount = Buffer.ReadLong
    
    TakeBankItem index, BankSlot, amount
    
    Set Buffer = Nothing
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleWithdrawItem", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
    
End Sub

Sub HandleDepositItem(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim invSlot As Long
    Dim amount As Long
    
    If TempPlayer(index).InBank = False Then
        PlayerMsg index, "Você não ta no  banco.", BrightRed
        Exit Sub
    End If
    
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    
    invSlot = Buffer.ReadLong
    amount = Buffer.ReadLong
    
    GiveBankItem index, invSlot, amount
    
    Set Buffer = Nothing
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleDepositItem", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleCloseBank(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    
    If TempPlayer(index).InBank = False Then
        PlayerMsg index, "Você não ta no  banco.", BrightRed
        Exit Sub
    End If
    
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    
    SaveBank index
    SavePlayer index
    
    TempPlayer(index).InBank = False
    
    Set Buffer = Nothing
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleCloseBank", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleAdminWarp(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim X As Long
    Dim Y As Long
    
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    
    X = Buffer.ReadLong
    Y = Buffer.ReadLong
    
    If GetPlayerAccess(index) >= ADMIN_MONITOR Then
        'PlayerWarp index, GetPlayerMap(index), x, y
        SetPlayerX index, X
        SetPlayerY index, Y
        SendPlayerXYToMap index
    End If
    
    Set Buffer = Nothing
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleAdminWarp", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleTradeRequest(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
Dim tradeTarget As Long, sX As Long, sY As Long, tX As Long, tY As Long
    ' can't trade npcs
    'PlayerMsg index, "Função TROCA esta bugada,troque SÓ em quem confie.", Red
    'Exit Sub
    
    If TempPlayer(index).targetType <> TARGET_TYPE_PLAYER Then Exit Sub

    ' find the target
    tradeTarget = TempPlayer(index).Target
    
    ' make sure we don't error
    If tradeTarget <= 0 Or tradeTarget > MAX_PLAYERS Then Exit Sub
    
    ' can't trade with yourself..
    If tradeTarget = index Then
        PlayerMsg index, "You can't trade with yourself.", BrightRed
        Exit Sub
    End If
    
    ' make sure they're on the same map
    If Not Player(tradeTarget).Map = Player(index).Map Then Exit Sub
    
    'invisivel
    If Player(index).Invisivel = YES Then Exit Sub
    If TempPlayer(index).InShop > 0 Or TempPlayer(tradeTarget).InShop > 0 Then
        PlayerMsg index, "alguém ta no shop!", BrightRed
        Exit Sub
    End If
    
    ' make sure they're stood next to each other
    tX = Player(tradeTarget).X
    tY = Player(tradeTarget).Y
    sX = Player(index).X
    sY = Player(index).Y
    
    ' within range?
    If tX < sX - 1 Or tX > sX + 1 Then
        PlayerMsg index, "You need to be standing next to someone to request a trade.", BrightRed
        Exit Sub
    End If
    If tY < sY - 1 Or tY > sY + 1 Then
        PlayerMsg index, "You need to be standing next to someone to request a trade.", BrightRed
        Exit Sub
    End If
    
    ' make sure not already got a trade request
    If TempPlayer(tradeTarget).TradeRequest > 0 Then
        PlayerMsg index, "Ele ja ta no meio de uma troca.", BrightRed
        Exit Sub
    End If
    
    If TempPlayer(index).TradeRequest > 0 Then
        PlayerMsg index, "Você ja enviou um convite a alguem,caso queira cancelar,re-logue.", BrightRed
        Exit Sub
    End If
    
    If TempPlayer(index).InBank = True Or TempPlayer(tradeTarget).InBank = True Then
        PlayerMsg index, "Alguem esta com o banco aberto. O banco precisa ser fechado.", BrightRed
        Exit Sub
    End If
    
    If TempPlayer(tradeTarget).InTrade > 0 Then
        PlayerMsg index, "Ele ja ta no meio de uma troca.", BrightRed
        Exit Sub
    End If
    
    If TempPlayer(index).InTrade > 0 Then
        PlayerMsg index, "Você ja ta no meio de uma troca.", BrightRed
        Exit Sub
    End If
    
    ' send the trade request
    TempPlayer(tradeTarget).AcceptTrade = False
    TempPlayer(index).AcceptTrade = False
    
    TempPlayer(tradeTarget).TradeRequest = index
    TempPlayer(index).TradeRequest = tradeTarget
    
    SendTradeRequest tradeTarget, index
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleTradeRequest", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleAcceptTradeRequest(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
Dim tradeTarget As Long
Dim i As Long
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
'If tradeTarget < 1 Or tradeTarget > MAX_PLAYERS Then Exit Sub

    tradeTarget = TempPlayer(index).TradeRequest
    
    If tradeTarget < 1 Or tradeTarget > MAX_PLAYERS Then Exit Sub
    
    If TempPlayer(tradeTarget).TradeRequest <> index Then
        PlayerMsg index, "Este player não está mais negociando com você.", BrightRed
        TempPlayer(index).InTrade = NO
        TempPlayer(index).TradeRequest = NO
        TempPlayer(index).AcceptTrade = False
        Exit Sub
    End If
    
    If TempPlayer(index).InBank = True Or TempPlayer(tradeTarget).InBank = True Then
        PlayerMsg index, "Alguem esta com o banco aberto. O banco precisa ser fechado.", BrightRed
        TempPlayer(index).InTrade = NO
        TempPlayer(index).TradeRequest = NO
        TempPlayer(index).AcceptTrade = False
        TempPlayer(tradeTarget).InTrade = NO
        TempPlayer(tradeTarget).TradeRequest = NO
        TempPlayer(tradeTarget).AcceptTrade = False
        Exit Sub
    End If
    
    If TempPlayer(index).InShop > 0 Or TempPlayer(tradeTarget).InShop > 0 Then
        PlayerMsg index, "Alguem esta com o shopping aberto. O banco precisa ser fechado.", BrightRed
        TempPlayer(index).InTrade = NO
        TempPlayer(index).TradeRequest = NO
        TempPlayer(index).AcceptTrade = False
        TempPlayer(tradeTarget).InTrade = NO
        TempPlayer(tradeTarget).TradeRequest = NO
        TempPlayer(tradeTarget).AcceptTrade = False
        Exit Sub
    End If
    
    ' let them know they're trading
    PlayerMsg index, "You have accepted " & Trim$(GetPlayerName(tradeTarget)) & "'s trade request.", BrightGreen
    PlayerMsg tradeTarget, Trim$(GetPlayerName(index)) & " has accepted your trade request.", BrightGreen
    ' clear the tradeRequest server-side
    TempPlayer(index).TradeRequest = 0
    TempPlayer(tradeTarget).TradeRequest = 0
    ' set that they're trading with each other
    TempPlayer(index).InTrade = tradeTarget
    TempPlayer(tradeTarget).InTrade = index
    ' clear out their trade offers
    For i = 1 To MAX_INV
        TempPlayer(index).TradeOffer(i).num = 0
        TempPlayer(index).TradeOffer(i).Value = 0
        TempPlayer(tradeTarget).TradeOffer(i).num = 0
        TempPlayer(tradeTarget).TradeOffer(i).Value = 0
    Next
    ' Used to init the trade window clientside
    SendTrade index, tradeTarget
    SendTrade tradeTarget, index
    ' Send the offer data - Used to clear their client
    SendTradeUpdate index, 0
    SendTradeUpdate index, 1
    SendTradeUpdate tradeTarget, 0
    SendTradeUpdate tradeTarget, 1
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleAcceptTradeRequest", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleDeclineTradeRequest(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    If IsPlaying(TempPlayer(index).TradeRequest) = False Then Exit Sub
    
    PlayerMsg TempPlayer(index).TradeRequest, GetPlayerName(index) & " has declined your trade request.", BrightRed
    TempPlayer(TempPlayer(index).TradeRequest).TradeRequest = NO
    PlayerMsg index, "You decline the trade request.", BrightRed
    ' clear the tradeRequest server-side
    TempPlayer(index).TradeRequest = 0
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleDeclineTradeRequest", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleAcceptTrade(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim tradeTarget As Long
    Dim i As Long
    Dim tmpTradeItem(1 To MAX_INV) As PlayerInvRec
    Dim tmpTradeItem2(1 To MAX_INV) As PlayerInvRec
    Dim itemNum As Long
    Dim InvQnt As Byte
    
    If TempPlayer(index).AcceptTrade = True Then Exit Sub
    
    TempPlayer(index).AcceptTrade = True
    
    tradeTarget = TempPlayer(index).InTrade
    If tradeTarget < 1 Then Exit Sub
    
    If TempPlayer(index).TempoTroca > 1 Then
        PlayerMsg index, "Espere alguns segundos para aceitar,verifique se está tudo como combinado.", Grey
        Exit Sub
    End If
    
    If TempPlayer(tradeTarget).TempoTroca > 1 Then
        PlayerMsg tradeTarget, "Espere alguns segundos para aceitar,verifique se está tudo como combinado.", Grey
        Exit Sub
    End If
    
    If TempPlayer(index).InShop > 0 Or TempPlayer(tradeTarget).InShop > 0 Then
        PlayerMsg index, "Alguem esta com o banco aberto. O banco precisa ser fechado.", BrightRed
        Exit Sub
    End If
    
    ' if not both of them accept, then exit
    If Not TempPlayer(tradeTarget).AcceptTrade Then
        SendTradeStatus index, 2
        SendTradeStatus tradeTarget, 1
        Exit Sub
    End If
    
    For i = 1 To MAX_INV
        If TempPlayer(index).TradeOffer(i).num > 0 Then
            InvQnt = InvQnt + 1
        End If
    Next
    
    If InvQnt > EmptyInvSlots(tradeTarget) Then
        PlayerMsg index, "Seu negociante não têm espaço suficiente na mochila..", Red
        PlayerMsg tradeTarget, "Você não têm espaço suficiente na mochila..", Red
        
        'SendTradeStatus index, 2
        'SendTradeStatus tradeTarget, 1
        Exit Sub
    End If
    
    For i = 1 To MAX_INV
        If TempPlayer(tradeTarget).TradeOffer(i).num > 0 Then
            InvQnt = InvQnt + 1
        End If
    Next
    
    If InvQnt > EmptyInvSlots(index) Then
        PlayerMsg tradeTarget, "Seu negociante não têm espaço suficiente na mochila..", Red
        PlayerMsg index, "Você não têm espaço suficiente na mochila..", Red
        
        'SendTradeStatus index, 2
        'SendTradeStatus tradeTarget, 1
        Exit Sub
    End If
    
    ' take their items
    For i = 1 To MAX_INV
        ' player
        If TempPlayer(index).TradeOffer(i).num > 0 Then
            itemNum = Player(index).Inv(TempPlayer(index).TradeOffer(i).num).num
            If itemNum > 0 Then
                
                ' store temp
                tmpTradeItem(i).num = itemNum
                tmpTradeItem(i).Value = TempPlayer(index).TradeOffer(i).Value
                ' take item
                TakeInvSlot index, TempPlayer(index).TradeOffer(i).num, tmpTradeItem(i).Value
            End If
        End If
        ' target
        If TempPlayer(tradeTarget).TradeOffer(i).num > 0 Then
            itemNum = GetPlayerInvItemNum(tradeTarget, TempPlayer(tradeTarget).TradeOffer(i).num)
            If itemNum > 0 Then
                ' store temp
                tmpTradeItem2(i).num = itemNum
                tmpTradeItem2(i).Value = TempPlayer(tradeTarget).TradeOffer(i).Value
                ' take item
                TakeInvSlot tradeTarget, TempPlayer(tradeTarget).TradeOffer(i).num, tmpTradeItem2(i).Value
            End If
        End If
    Next
    
    ' taken all items. now they can't not get items because of no inventory space.
    For i = 1 To MAX_INV
        ' player
        If tmpTradeItem2(i).num > 0 Then
            ' give away!
            GiveInvItem index, tmpTradeItem2(i).num, tmpTradeItem2(i).Value, False
        End If
        ' target
        If tmpTradeItem(i).num > 0 Then
            ' give away!
            GiveInvItem tradeTarget, tmpTradeItem(i).num, tmpTradeItem(i).Value, False
        End If
    Next
    
    SendInventory index
    SendInventory tradeTarget
    
    SalvarConta index
    SalvarConta tradeTarget
    ' they now have all the items. Clear out values + let them out of the trade.
    For i = 1 To MAX_INV
        TempPlayer(index).TradeOffer(i).num = 0
        TempPlayer(index).TradeOffer(i).Value = 0
        TempPlayer(tradeTarget).TradeOffer(i).num = 0
        TempPlayer(tradeTarget).TradeOffer(i).Value = 0
    Next

    TempPlayer(index).InTrade = 0
    TempPlayer(tradeTarget).InTrade = 0
    
    PlayerMsg index, "Troca completada.", BrightGreen
    PlayerMsg tradeTarget, "Troca completada.", BrightGreen
    
    SendCloseTrade index
    SendCloseTrade tradeTarget
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleAcceptTrade", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleDeclineTrade(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
Dim i As Long
Dim tradeTarget As Long

    tradeTarget = TempPlayer(index).InTrade
    If tradeTarget < 1 Or tradeTarget > MAX_PLAYERS Then Exit Sub
    
    For i = 1 To MAX_INV
        TempPlayer(index).TradeOffer(i).num = 0
        TempPlayer(index).TradeOffer(i).Value = 0
        TempPlayer(tradeTarget).TradeOffer(i).num = 0
        TempPlayer(tradeTarget).TradeOffer(i).Value = 0
    Next

    TempPlayer(index).InTrade = 0
    TempPlayer(tradeTarget).InTrade = 0
    
    PlayerMsg index, "You declined the trade.", BrightRed
    PlayerMsg tradeTarget, GetPlayerName(index) & " has declined the trade.", BrightRed
    
    SendCloseTrade index
    SendCloseTrade tradeTarget
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleDeclineTrade", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleTradeItem(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim invSlot As Long
    Dim amount As Long
    Dim EmptySlot As Long
    Dim itemNum As Long
    Dim i As Long
    
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    
    invSlot = Buffer.ReadLong
    amount = Buffer.ReadLong
    
    Set Buffer = Nothing
    
    If invSlot <= 0 Or invSlot > MAX_INV Then Exit Sub
    
    itemNum = GetPlayerInvItemNum(index, invSlot)
    If itemNum <= 0 Or itemNum > MAX_ITEMS Then Exit Sub
    
    ' make sure they have the amount they offer
    If amount < 0 Or amount > GetPlayerInvItemValue(index, invSlot) Then
        Exit Sub
    End If
    
    If itemNum >= 200 And itemNum <= 230 Then
        PlayerMsg index, "Não pôde negociar o item:" & Item(itemNum).Name & "!", BrightRed
        Exit Sub
    End If
    
    If TempPlayer(index).InShop > 0 Then
        PlayerMsg index, "alguém ta no shop!", BrightRed
        Exit Sub
    End If

    If Item(itemNum).Type = ITEM_TYPE_CURRENCY Then
        ' check if already offering same currency item
        For i = 1 To MAX_INV
            If TempPlayer(index).TradeOffer(i).num = invSlot Then
                ' add amount
                TempPlayer(index).TradeOffer(i).Value = TempPlayer(index).TradeOffer(i).Value + amount
                ' clamp to limits
                If TempPlayer(index).TradeOffer(i).Value > GetPlayerInvItemValue(index, invSlot) Then
                    TempPlayer(index).TradeOffer(i).Value = GetPlayerInvItemValue(index, invSlot)
                End If
                ' cancel any trade agreement
                TempPlayer(index).AcceptTrade = False
                TempPlayer(TempPlayer(index).InTrade).AcceptTrade = False
                
                SendTradeStatus index, 0
                SendTradeStatus TempPlayer(index).InTrade, 0
                
                SendTradeUpdate index, 0
                SendTradeUpdate TempPlayer(index).InTrade, 1
                ' exit early
                Exit Sub
            End If
        Next
    Else
        ' make sure they're not already offering it
        For i = 1 To MAX_INV
            If TempPlayer(index).TradeOffer(i).num = invSlot Then
                PlayerMsg index, "You've already offered this item.", BrightRed
                Exit Sub
            End If
        Next
    End If
    
    ' not already offering - find earliest empty slot
    For i = 1 To MAX_INV
        If TempPlayer(index).TradeOffer(i).num = 0 Then
            EmptySlot = i
            Exit For
        End If
    Next
    TempPlayer(index).TradeOffer(EmptySlot).num = invSlot
    TempPlayer(index).TradeOffer(EmptySlot).Value = amount
    
    ' cancel any trade agreement and send new data
    TempPlayer(index).AcceptTrade = False
    TempPlayer(TempPlayer(index).InTrade).AcceptTrade = False
    
    SendTradeStatus index, 0
    SendTradeStatus TempPlayer(index).InTrade, 0
    
    SendTradeUpdate index, 0
    SendTradeUpdate TempPlayer(index).InTrade, 1
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleTradeItem", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleUntradeItem(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim tradeSlot As Long
    
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    
    tradeSlot = Buffer.ReadLong
    
    Set Buffer = Nothing
    
    If tradeSlot <= 0 Or tradeSlot > MAX_INV Then Exit Sub
    If TempPlayer(index).TradeOffer(tradeSlot).num <= 0 Then Exit Sub
    
    TempPlayer(index).TradeOffer(tradeSlot).num = 0
    TempPlayer(index).TradeOffer(tradeSlot).Value = 0
    
    If TempPlayer(index).AcceptTrade Then TempPlayer(index).AcceptTrade = False
    If TempPlayer(TempPlayer(index).InTrade).AcceptTrade Then TempPlayer(TempPlayer(index).InTrade).AcceptTrade = False
    
    SendTradeStatus index, 0
    SendTradeStatus TempPlayer(index).InTrade, 0
    
    SendTradeUpdate index, 0
    SendTradeUpdate TempPlayer(index).InTrade, 1
    
    TempPlayer(index).TempoTroca = 11
    TempPlayer(TempPlayer(index).InTrade).TempoTroca = 11
    PlayerMsg index, "Você tirou um item da troca,espere alguns segundos para aceitar denovo.", Grey
    PlayerMsg TempPlayer(index).InTrade, "A pessoa tirou um item da troca,espere alguns segundos para aceitar denovo.", Grey
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleUntradeItem", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub


Sub HandleHotbarChange(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim sType As Long
    Dim Slot As Long
    Dim hotbarNum As Long
    
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    
    sType = Buffer.ReadLong
    Slot = Buffer.ReadLong
    hotbarNum = Buffer.ReadLong
    
    Select Case sType
        Case 0 ' clear
            Player(index).Hotbar(hotbarNum).Slot = 0
            Player(index).Hotbar(hotbarNum).sType = 0
        Case 1 ' inventory
            If Slot > 0 And Slot <= MAX_INV Then
                If Player(index).Inv(Slot).num > 0 Then
                    If Len(Trim$(Item(GetPlayerInvItemNum(index, Slot)).Name)) > 0 Then
                        Player(index).Hotbar(hotbarNum).Slot = Player(index).Inv(Slot).num
                        Player(index).Hotbar(hotbarNum).sType = sType
                    End If
                End If
            End If
        Case 2 ' spell
            If Slot > 0 And Slot <= MAX_PLAYER_SPELLS Then
                If Player(index).Spell(Slot) > 0 Then
                    If Len(Trim$(Spell(Player(index).Spell(Slot)).Name)) > 0 Then
                        Player(index).Hotbar(hotbarNum).Slot = Player(index).Spell(Slot)
                        Player(index).Hotbar(hotbarNum).sType = sType
                    End If
                End If
            End If
    End Select
    
    SendHotbar index
    
    Set Buffer = Nothing
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleHotbarChange", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleHotbarUse(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    If Player(index).Spec = YES Then
        PlayerMsg index, "Você está em modo Espectador,desative-o clicando de volta!", Red
        Exit Sub
    End If
    
    Dim Buffer As clsBuffer
    Dim Slot As Long
    Dim i As Long
    
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    
    Slot = Buffer.ReadLong
    
    Select Case Player(index).Hotbar(Slot).sType
        Case 1 ' inventory
            For i = 1 To MAX_INV
                If Player(index).Inv(i).num > 0 Then
                    If Player(index).Inv(i).num = Player(index).Hotbar(Slot).Slot Then
                        UseItem index, i
                        Exit Sub
                    End If
                End If
            Next
        Case 2 ' spell
            For i = 1 To MAX_PLAYER_SPELLS
                If Player(index).Spell(i) > 0 Then
                    If Player(index).Spell(i) = Player(index).Hotbar(Slot).Slot Then
                        BufferSpell index, i
                        Exit Sub
                    End If
                End If
            Next
    End Select
    
    Set Buffer = Nothing
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleHotbarUse", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandlePartyRequest(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    ' make sure it's a valid target
    If TempPlayer(index).targetType <> TARGET_TYPE_PLAYER Then Exit Sub
    If TempPlayer(index).Target = index Then Exit Sub
    
    ' make sure they're connected and on the same map
    If Not IsConnected(TempPlayer(index).Target) Or Not IsPlaying(TempPlayer(index).Target) Then Exit Sub
    If GetPlayerMap(TempPlayer(index).Target) <> GetPlayerMap(index) Then Exit Sub
    
    ' init the request
    Party_Invite index, TempPlayer(index).Target
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandlePartyRequest", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleAcceptParty(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Party_InviteAccept TempPlayer(index).partyInvite, index
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleAcceptParty", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleDeclineParty(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Party_InviteDecline TempPlayer(index).partyInvite, index
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleDeclineParty", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandlePartyLeave(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Party_PlayerLeave index
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandlePartyLeave", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleQuestPic(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim questSlot As Byte
    
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    
    questSlot = Buffer.ReadByte
    
    Set Buffer = Nothing
    If questSlot < 1 Then Exit Sub
    If Player(index).QuestNum(questSlot) < 1 Then Exit Sub

    PlayerMsg index, "Missão:" & Trim$(Quest(Player(index).QuestNum(questSlot)).Name) & " cancelada!", Cyan
    ClearQuestSlot index, questSlot
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleQuestPic", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleSetVIP(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim n As Long
    Dim i As Long
    Dim Buffer As clsBuffer
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()

    ' Prevent hacking
    If GetPlayerAccess(index) < ADMIN_CREATOR Then
        Exit Sub
    End If

    ' The index
    n = FindPlayer(Buffer.ReadString) 'Parse(1))
    ' The access
    i = Buffer.ReadLong 'CLng(Parse(2))
    Set Buffer = Nothing

If n < 1 Or n > MAX_PLAYERS Then
    PlayerMsg index, "Player não tá online.", BrightRed
    Exit Sub
End If

If i < 0 Then
    PlayerMsg index, "O mínimo é 1", BrightRed
    Exit Sub
End If

If i > 3 Then
    PlayerMsg index, "O limite é 3", BrightRed
    Exit Sub
End If

Player(n).VIP = i
SendPlayerData n
SavePlayer n

If i > 0 Then
    PlayerMsg n, "Parabens!Agora você é VIP Nível: " & i, BrightCyan
Else
    PlayerMsg n, "Seu tempo como player VIP acabou.Obrigado por ter ajudado!", Yellow
End If

If Player(n).VIP = i Then
    PlayerMsg index, "Tudo ocorreu bem." & FindPlayer(n), BrightGreen
Else
    PlayerMsg index, "Ele ainda não é VIP " & i, BrightRed
End If

    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleSetVip", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub

End Sub

Sub HandleTransPic(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
Dim Number As Byte
    
    Dim Buffer As clsBuffer
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    
    Number = Buffer.ReadByte

    Set Buffer = Nothing

Select Case Number
    Case 0 'Destransformar
        TransDown index
    Case 1
        If GetPlayerClass(index) < SAI Then
            TransUp index, 1
        Else
            TransUp index, 5
        End If
        
    Case 2
        TransUp index, 2
    Case 3
        TransUp index, 3
    Case 4
        Select Case GetPlayerClass(index)
            Case 1, 2 'Naruto
                TransUp index, 4, 1
            Case Else
        End Select
    Case 5
        Select Case GetPlayerClass(index)
            Case 1, 2 'Naruto
                TransUp index, 5, 1
            Case Else
        End Select
    Case 6
        If GetPlayerClass(index) = 1 Then 'Naruto
            TransUp index, 6, 2
        End If
    Case Else
End Select
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleTransPic", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleSetRank(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim n As Long
    Dim i As Long
    Dim Y As Long
    Dim CanChange As Byte
    Dim Buffer As clsBuffer
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()

    ' Prevent hacking
    If GetPlayerAccess(index) < ADMIN_MONITOR Then
        Exit Sub
    End If

    ' The index
    n = AcharPlayer(Buffer.ReadString) 'Parse(1))
    ' The access
    i = Buffer.ReadByte 'CLng(Parse(2))
    Set Buffer = Nothing

If GetPlayerAccess(index) = ADMIN_MONITOR Then
    For Y = 1 To 3
        If n = Luta.Player(Y) Then
            CanChange = YES
        End If
    Next
    
    If CanChange = NO Then
        PlayerMsg index, "Esse player não está em um torneio e nem venceu ;/", Red
        Exit Sub
    End If
End If

If n < 1 Or n > MAX_PLAYERS Then Exit Sub

SetarRank n, i

If frmServer.chkOmitir.Value = NO Then
    GlobalMsg "By:" & GetPlayerName(index), Yellow
End If

    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleSetRank", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
    
End Sub

Sub HandleSetOrg(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim u As String
    Dim n As Long
    Dim i As Long
    Dim Buffer As clsBuffer
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()

    ' Prevent hacking
    If GetPlayerAccess(index) < ADMIN_CREATOR Then
        Exit Sub
    End If

    ' The index
    n = FindPlayer(Buffer.ReadString) 'Parse(1))
    ' The access
    i = Buffer.ReadByte 'CLng(Parse(2))
    Set Buffer = Nothing

If n < 1 Or n > MAX_PLAYERS Then
    PlayerMsg index, "Player não está online.", BrightRed
    Exit Sub
End If

If i < 1 Or i > 8 Then
    PlayerMsg index, "O minimo é 1 e o máximo 8", BrightRed
    Exit Sub
End If

Player(n).Org = i
SendPlayerData n
SavePlayer n

Select Case i
    Case ORG_POLICIAKONOHA
        u = "Konoha Military Police Corps"
    Case ORG_HOSPITAL
        u = "Hospital"
    Case ORG_AKATSUKI
        u = "Akatsuki"
    Case ORG_TAKA
        u = "Taka"
    'Case ORG_ANBU
        'u = "ANBU"
    Case ORG_ANBURAIZ
        u = "ANBU Raíz"
    Case ORG_7ESPADACHINS
        u = "7 espadachins da Névoa"
    Case ORG_12GUARDIOES
        u = "12 Guardiões do Senhor Feudal"
    
Case Else
    Exit Sub
End Select
'If Player(index).Org = i Then
    GlobalMsg GetPlayerName(n) & " entrou para a Organização : " & u & "!", BrightCyan
'End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleSetOrg", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
    
End Sub


Sub HandleCash(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim qnt, i As Long, Name As String * NAME_LENGTH
    
    Dim Buffer As clsBuffer
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()

    ' Prevent hacking
    If GetPlayerAccess(index) < ADMIN_CREATOR Then
        Exit Sub
    End If
    
    Name = Buffer.ReadString
    qnt = Buffer.ReadLong 'CLng(Parse(2))
    Set Buffer = Nothing
i = FindPlayer(Name)

If i > 0 Then
    If qnt > 0 Then
        GiveInvItem i, 254, qnt, True
        PlayerMsg i, "Você ganhou " & qnt & " de CASH!", White
        SavePlayer i
        PlayerMsg i, "Sua conta foi salva!!", Green
        PlayerMsg index, "Tudo ocorreu bem com o player " & GetPlayerName(i), BrightGreen
        PlayerMsg index, qnt & " CASH", BrightGreen
    Else
        PlayerMsg index, "A quantidade tem q ser maior que 0", BrightRed
    End If
Else
    PlayerMsg index, "O player não ta online", BrightRed
End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleCash", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
    
End Sub

Private Sub HandleChangePass(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim Name As String
    Dim Password As String
    Dim NewPass As String
    Dim i As Long
    Dim SenhaSecreta As String
    Dim teste As Long

    If Not IsPlaying(index) Then
        If Not IsLoggedIn(index) Then
            Set Buffer = New clsBuffer
            Buffer.WriteBytes Data()
            ' Get the data
            teste = Buffer.ReadLong
            
            If teste <> CLIENT_REVISION + CLIENT_MAJOR + CLIENT_MINOR Then 'previni clients que não sejam o nip
                Set Buffer = Nothing
                AlertMsg index, "Versão desatualizada!!"
                Exit Sub
            End If
            
            Name = Buffer.ReadString
            Password = Buffer.ReadString
            NewPass = Buffer.ReadString
            SenhaSecreta = Buffer.ReadString
            
            If teste <> CLIENT_REVISION + CLIENT_MAJOR + CLIENT_MINOR Then 'previni clients que não sejam o nip
                AlertMsg index, "Versão desatualizada!!"
                Exit Sub
            End If
            
            ' Prevent hacking
            If Len(Trim$(Name)) < 3 Or Len(Trim$(Password)) < 3 Or Len(Trim$(NewPass)) < 3 Or Len(Trim$(SenhaSecreta)) < 3 Then
                Call AlertMsg(index, "A senha precisa ter pelo menos 3 caracteres e no maximo 20")
                Exit Sub
            End If
            
            ' Prevent hacking
            If Len(Trim$(Name)) > ACCOUNT_LENGTH Or Len(Trim$(Password)) > NAME_LENGTH Or Len(Trim$(NewPass)) > NAME_LENGTH Or Len(Trim$(SenhaSecreta)) > NAME_LENGTH Then
                Call AlertMsg(index, "A senha precisa ter pelo menos 3 caracteres e no maximo 20 .")
                Exit Sub
            End If

            If Not AccountExist(Name) Then
                Call AlertMsg(index, "A conta não existe.")
                Exit Sub
            End If
            
            If InStr(NewPass, " ") Then
                AlertMsg index, "Não use espaços!"
                Exit Sub
            End If

            If Not PasswordOK(Name, Password) Then
                Call AlertMsg(index, "Senha incorreta.")
                Exit Sub
            End If
            
            
            If IsMultiAccounts(Name) Then
                Call AlertMsg(index, "Já tem alguém com a conta logado.")
                Exit Sub
            End If

            LoadPlayer index, Name
            If Not SenhaSecreta = Player(index).SenhaSecreta Then
                ClearPlayer index
                AlertMsg index, "Senha Secreta ERRADA!"
                Exit Sub
            End If
                
            SetPlayerPassword index, NewPass
            SavePlayer index
            
            Call AddLog("Account " & Trim$(Name) & " alterou a senha.", PLAYER_LOG)
            Call AlertMsg(index, "Senha alterada com sucesso:" & NewPass)
            
            Set Buffer = Nothing
        End If
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleChangePass", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub HandleOrgMsg(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    If Player(index).Org = 0 Then
        PlayerMsg index, "Você não têm uma Organização!", BrightRed
        Exit Sub
    End If
    
    If TempPlayer(index).MsgDelay > 0 Then
        'HackingAttempt index, "Anti-Spam"
        Exit Sub
    End If
    
    Dim Msg As String
    Dim i As Long
    Dim Buffer As clsBuffer
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    Msg = Buffer.ReadString

If LenB(Msg) / 2 > 170 Then
    PlayerMsg index, "Seu texto é muiiito longo :| ", BrightRed
    Exit Sub
End If
    
    ''''''''''
    For i = 1 To MAX_PLAYERS
        If Trim$(Mutado(i)) = GetPlayerIP(index) Then
            PlayerMsg index, " Teu ip ta mutado. Agora só poderá falar no chat no próximo reinicializamento do servidor(acontece as 6 e as 17 horas).", BrightRed
            Exit Sub
        End If
    Next
    ''''''''''''
    
    TempPlayer(index).MsgDelay = GetTickCount + 300
    Call AddLog("Map #" & GetPlayerMap(index) & ": " & GetPlayerName(index) & " says, '" & Msg & "'", PLAYER_LOG)
    Call SayMsg_Org(index, Msg, QBColor(Cyan))
    
    Set Buffer = Nothing
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleOrgMsg", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub HandlePartyMsg(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    If Not TempPlayer(index).inParty > 0 Then
        PlayerMsg index, "Você não está em um Grupo!", BrightRed
        Exit Sub
    End If
    
    If TempPlayer(index).MsgDelay > 0 Then
        'HackingAttempt index, "Anti-Spam"
        Exit Sub
    End If
    
    Dim Msg As String
    Dim i As Long
    Dim Buffer As clsBuffer
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    Msg = Buffer.ReadString

    If LenB(Msg) / 2 > 170 Then
        PlayerMsg index, "Seu texto é muiiito longo :| ", BrightRed
        Exit Sub
    End If
    
    ''''''''''
    For i = 1 To MAX_PLAYERS
        If Trim$(Mutado(i)) = GetPlayerIP(index) Then
            PlayerMsg index, " Teu ip ta mutado. Agora só poderá falar no chat no próximo reinicializamento do servidor(acontece as 6 e as 17 horas).", BrightRed
            Exit Sub
        End If
    Next
    ''''''''''''
    
    TempPlayer(index).MsgDelay = GetTickCount + 300
    Call AddLog("Map #" & GetPlayerMap(index) & ": " & GetPlayerName(index) & " says, '" & Msg & "'", PLAYER_LOG)
    Call SayMsg_Party(index, Msg, QBColor(Green))
    
    Set Buffer = Nothing
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandlePartyMsg", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub HandleVilaMsg(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    If TempPlayer(index).MsgDelay > 0 Then
        'HackingAttempt index, "Anti-Spam"
        Exit Sub
    End If
    
    Dim Msg As String
    Dim i As Long
    Dim Buffer As clsBuffer
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    Msg = Buffer.ReadString

    If LenB(Msg) / 2 > 170 Then
        PlayerMsg index, "Seu texto é muiiito longo :| ", BrightRed
        Exit Sub
    End If
    
    ''''''''''
    For i = 1 To MAX_PLAYERS
        If Trim$(Mutado(i)) = GetPlayerIP(index) Then
            PlayerMsg index, " Teu ip ta mutado. Agora só poderá falar no chat no próximo reinicializamento do servidor(acontece as 6 e as 17 horas).", BrightRed
            Exit Sub
        End If
    Next
    ''''''''''''
    
    TempPlayer(index).MsgDelay = GetTickCount + 300
    Call AddLog("Map #" & GetPlayerMap(index) & ": " & GetPlayerName(index) & " says, '" & Msg & "'", PLAYER_LOG)
    Call SayMsg_Vila(index, Msg, QBColor(BrightBlue))
    
    Set Buffer = Nothing
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleVilaMsg", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
    
End Sub

Sub HandleOrgLeft(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
Dim i As Byte
Dim X As Byte

If Player(index).Org < 1 Then
    PlayerMsg index, "Você não têm Organização", BrightRed
    Exit Sub
End If

If Player(index).OrgAccess > 1 Then
    PlayerMsg index, "Não da cara..", BrightRed
    Exit Sub
End If

If Player(index).InTorneio > 0 Then
    PlayerMsg index, "Não da pra sair da org enquanto estiver em torneio!!", White
    Exit Sub
End If

For i = 1 To MAX_PLAYER_SPELLS
    ' dont let them forget a spell which is in CD
    If TempPlayer(index).SpellCD(i) > GetTickCount Then
        PlayerMsg index, "Cannot forget a spell which is cooling down!", BrightRed
        Exit Sub
    End If
    
    ' dont let them forget a spell which is buffered
    If TempPlayer(index).spellBuffer.Spell = i Then
        PlayerMsg index, "Cannot forget a spell which you are casting!", BrightRed
        Exit Sub
    End If
    
    For X = 131 To 141
        If Player(index).Spell(i) = X Then
            Player(index).Spell(i) = 0
            SendPlayerSpells index
        End If
    Next
    
Next

sairOrgPrivada index

Player(index).Org = 0
Player(index).OrgAccess = 0
SendPlayerData index
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleOrgLeft", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleVIP(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim Nome As String
    Dim Dias As String
    Dim VIP As Byte
    Dim tipo As Byte
    Dim pINDEX As Long

    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    
    Nome = Buffer.ReadString
    VIP = Buffer.ReadByte
    Dias = Buffer.ReadLong
    tipo = Buffer.ReadByte
    
    Set Buffer = Nothing
    
    pINDEX = AcharPlayer(Nome)
    
    If pINDEX < 1 Or pINDEX > MAX_PLAYERS Then
        PlayerMsg index, "Player não ta online", BrightRed
        Exit Sub
    End If
    
    If GetPlayerAccess(index) < ADMIN_CREATOR Then
        PlayerMsg index, "Some ", BrightRed
        Exit Sub
    End If
    
    If tipo = 0 Then 'se for pra verificar o vip
        If Player(pINDEX).VipData.DiasVIP = vbNullString Or Player(pINDEX).VipData.DataVIP = vbNullString Then
            PlayerMsg index, Trim$(Nome) & " não possui vip.", White
        Else
            PlayerMsg index, Trim$(Nome) & "(lvl." & GetPlayerLevel(pINDEX) & ")", BrightGreen
            If Player(pINDEX).VipData.VIP = 1 Then
                PlayerMsg index, "Ele tem " & Player(pINDEX).VipData.DiasVIP & " dias LIGHT", BrightGreen
            ElseIf Player(pINDEX).VipData.VIP = 2 Then
                PlayerMsg index, "Ele tem " & Player(pINDEX).VipData.DiasVIP & " dias OHYEH", BrightGreen
            End If
        End If
    Else
        addVIP pINDEX, Dias, VIP, index
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleVIP", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub


Sub HandleCT(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim Nome As String
    Dim Dias As Long
    Dim pINDEX As Long
    Dim tipo As Byte
    
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    
    Nome = Buffer.ReadString
    Dias = Buffer.ReadLong
    tipo = Buffer.ReadByte
    
    Set Buffer = Nothing
    
    pINDEX = AcharPlayer(Nome)
    
    If pINDEX < 1 Or pINDEX > MAX_PLAYERS Then
        PlayerMsg index, "Player não ta online", BrightRed
        Exit Sub
    End If
    
    If GetPlayerAccess(index) < ADMIN_CREATOR Then
        PlayerMsg index, "Some", BrightRed
        Exit Sub
    End If
    
    If tipo = 0 Then 'verificação de ct
        If Player(pINDEX).CTdata.DiasCT = vbNullString Or Player(pINDEX).CTdata.DataCT = vbNullString Then
            PlayerMsg index, Trim$(Nome) & " não possui CT.", White
        Else
            PlayerMsg index, Trim$(Nome) & "(lvl." & GetPlayerLevel(pINDEX) & ")", BrightGreen
            PlayerMsg index, "Ele tem " & Player(pINDEX).CTdata.DiasCT & " dias CT", BrightGreen
        End If
    Else
        addCT pINDEX, Dias, index
    End If
    
    Exit Sub
ERRO:
    PlayerMsg index, "Deu algum problema CT. Data:" & Player(pINDEX).CTdata.DataCT, BrightRed
    Set Buffer = Nothing
    Exit Sub
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleCT", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Sub HandlePK(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
On Error GoTo errorhandler

If index < 1 Or index > MAX_PLAYERS Then Exit Sub

If GetPlayerAccess(index) = 2 Then 'gm
    Player(index).PKstate = NO
    PlayerMsg index, "GM Nambe,isso é só pros preyer rçrçrç", White
    Exit Sub
End If

If Torneio = TORNEIO_POKEMON Then
    If Player(index).InTorneio = TORNEIO_POKEMON Then
        If Player(index).PKstate > 0 Then Exit Sub
    End If
End If

Select Case Player(index).PKstate
    Case 0
        Player(index).PKstate = 1
    Case 1
        Player(index).PKstate = 2
    Case 2
        Player(index).PKstate = 3
    Case 3
        Player(index).PKstate = 0
End Select

If Torneio <> TORNEIO_POKEMON Then
    If Not GetPlayerAccess(index) = 2 Then 'GM
        If Player(index).InTorneio > 0 Then
            Player(index).PKstate = 3
            PlayerMsg index, "Você está em um torneio,caso queira sair de um torneio,vá em EXTRAS>Sair Torneio", Red
        End If
    End If
End If

SendPlayerData index
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandlePK", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleBAN(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim Nome As String
    Dim Dias As Long
    Dim pINDEX As Long

    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    
    Nome = Buffer.ReadString
    Dias = Buffer.ReadLong
    
    Set Buffer = Nothing
    
    pINDEX = AcharPlayer(Nome)
    
    If pINDEX < 1 Or pINDEX > MAX_PLAYERS Then
        PlayerMsg index, "Player não ta online", BrightRed
        Exit Sub
    End If
    
    If GetPlayerAccess(index) < ADMIN_MONITOR Then
        PlayerMsg index, "Some", BrightRed
        Exit Sub
    End If
    
    If GetPlayerAccess(pINDEX) >= 5 Then
        AlertMsg index, "Nawb"
        Exit Sub
    End If
    
    Player(pINDEX).Ban.Ban = YES
    Player(pINDEX).Ban.Data = DateAdd("d", Dias, Date)
    Player(pINDEX).Ban.Dias = Trim(DateDiff("d", Date, Player(pINDEX).Ban.Data))
    SavePlayer pINDEX
        
        PutVar App.Path & "\data\Banidos.txt", "BAN POR TEMPO", GetPlayerName(pINDEX), "Banido por:" & GetPlayerName(index) & ".Login:" & Player(pINDEX).Login & ".Dias Banido:" & Player(pINDEX).Ban.Dias
        PlayerMsg index, "Nome:" & GetPlayerName(pINDEX) & "(" & pINDEX & ")", BrightGreen
        PlayerMsg index, "Dias de BAN:" & DateDiff("d", Date, Player(pINDEX).Ban.Data), BrightGreen
        GlobalMsg GetPlayerName(pINDEX) & " foi banido por " & GetPlayerName(index) & " durante " & DateDiff("d", Date, Player(pINDEX).Ban.Data) & " dias!", White
        AlertMsg pINDEX, "Você foi banido por: " & DateDiff("d", Date, Player(pINDEX).Ban.Data) & " dias!"
   
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleBAN", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
    
End Sub

Sub HandleSenhaSecreta(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim Senha As String
    
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    
    Senha = Buffer.ReadString
    
    Set Buffer = Nothing

If Not Player(index).SenhaSecreta = vbNullString Then
    PlayerMsg index, "Você já têm uma Senha Secreta!", Red
    Exit Sub
End If

If Len(Senha) < 3 Or Len(Senha) > ACCOUNT_LENGTH Then
    PlayerMsg index, "Precisa ter pelo menos 3 dígitos!", Red
    Exit Sub
End If

Player(index).SenhaSecreta = Senha
PlayerMsg index, "Senha secreta feita com sucesso!Nunca se esqueça dela!!", White
PlayerMsg index, "SUA SENHA SECRETA É: " & Senha, White
SavePlayer index

' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleSenhaSecreta", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub


Sub HandleDesafio(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim Nome2 As String
    Dim Nome3 As String 'desafioanything
    Dim Nome4 As String
    Dim Campo As Byte
    Dim tipo As Byte
    Dim i As Byte
    
    Dim p2 As Long
    Dim p3 As Long
    Dim p4 As Long
    Dim teste As Long
    
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    
    teste = Buffer.ReadLong
            
    If teste <> CLIENT_REVISION + CLIENT_MAJOR + CLIENT_MINOR Then 'previni clients que não sejam o nip
        Set Buffer = Nothing
        CloseSocket index
        Exit Sub
    End If
    
    Nome2 = Buffer.ReadString
    Nome3 = Buffer.ReadString
    Nome4 = Buffer.ReadString
    
    Campo = Buffer.ReadByte
    tipo = Buffer.ReadByte
    
    Set Buffer = Nothing
    p2 = FindPlayer(Nome2)
    p3 = FindPlayer(Nome3)
    p4 = FindPlayer(Nome4)
    
    If Player(index).Invisivel = YES Or Player(index).InTorneio > 0 Or TempPlayer(index).InArena > 0 Then
        PlayerMsg index, "Não pode desafiar estando em torneio ou modo espectador ou estando ja em um desafio!", BrightRed
        Exit Sub
    End If
    
    If tipo = 0 Then '1x1
        If PodeDesafiar(p2) = NO Then
            PlayerMsg index, Nome2 & " não pode participar estando em torneio ou modo espectador ou estando ja em um desafio!", BrightRed
            Exit Sub
        End If
    End If
    
    If tipo = 1 Or tipo = 2 Then '1x2,2x1
        If PodeDesafiar(p2) = NO Then
            PlayerMsg index, Nome2 & " não pode participar estando em torneio ou modo espectador ou estando ja em um desafio!", BrightRed
            Exit Sub
        End If
        If PodeDesafiar(p3) = NO Then
            PlayerMsg index, Nome3 & " não pode participar estando em torneio ou modo espectador ou estando ja em um desafio!", BrightRed
            Exit Sub
        End If
    End If
    
    If tipo = 3 Then '2x2
        If PodeDesafiar(p2) = NO Then
            PlayerMsg index, Nome2 & " não pode participar estando em torneio ou modo espectador ou estando ja em um desafio!", BrightRed
            Exit Sub
        End If
        If PodeDesafiar(p3) = NO Then
            PlayerMsg index, Nome3 & " não pode participar estando em torneio ou modo espectador ou estando ja em um desafio!", BrightRed
            Exit Sub
        End If
        If PodeDesafiar(p4) = NO Then
            PlayerMsg index, Nome4 & " não pode participar estando em torneio ou modo espectador ou estando ja em um desafio!", BrightRed
            Exit Sub
        End If
    End If
    
    If Campo < 1 Or Campo > 9 Then
        PlayerMsg index, "Selecione apenas da arena 1 à 9", BrightRed
        Exit Sub
    End If
    
    If Arena(Campo).IsActive = YES Then
        PlayerMsg index, "Esta arena já está ocupada!", BrightRed
        Exit Sub
    End If
    
    Select Case tipo
        Case 0 '1x1
            TempPlayer(index).InArena = Campo
            TempPlayer(p2).InArena = Campo
            '#####
            Arena(Campo).p(1) = index
            Arena(Campo).p2(1) = p2
            '#####
            Arena(Campo).pResta = 1
            Arena(Campo).p2Resta = 1
            '#####
            TempPlayer(index).AceitouDesafio = YES
            TempPlayer(p2).AceitouDesafio = NO
            '#####
        Case 1 '1x2
            TempPlayer(index).InArena = Campo
            TempPlayer(p2).InArena = Campo
            TempPlayer(p3).InArena = Campo
            '#####
            Arena(Campo).p(1) = index
            Arena(Campo).p2(1) = p2
            Arena(Campo).p2(2) = p3
            '#####
            Arena(Campo).pResta = 1
            Arena(Campo).p2Resta = 2
            '#####
            TempPlayer(index).AceitouDesafio = YES
            TempPlayer(p2).AceitouDesafio = NO
            TempPlayer(p3).AceitouDesafio = NO
            '#####
        Case 2 '2x1
            TempPlayer(index).InArena = Campo
            TempPlayer(p2).InArena = Campo
            TempPlayer(p3).InArena = Campo
            '#####
            Arena(Campo).p(1) = index
            Arena(Campo).p(2) = p2
            Arena(Campo).p2(1) = p3
            '#####
            Arena(Campo).pResta = 2
            Arena(Campo).p2Resta = 1
            '#####
            TempPlayer(index).AceitouDesafio = YES
            TempPlayer(p2).AceitouDesafio = NO
            TempPlayer(p3).AceitouDesafio = NO
            TempPlayer(p4).AceitouDesafio = NO
            '#####
        Case 3 '2x2
            TempPlayer(index).InArena = Campo
            TempPlayer(p2).InArena = Campo
            TempPlayer(p3).InArena = Campo
            TempPlayer(p4).InArena = Campo
            '#####
            Arena(Campo).p(1) = index
            Arena(Campo).p(2) = p2
            Arena(Campo).p2(1) = p3
            Arena(Campo).p2(2) = p4
            '#####
            Arena(Campo).pResta = 2
            Arena(Campo).p2Resta = 2
            '#####
            TempPlayer(index).AceitouDesafio = YES
            TempPlayer(p2).AceitouDesafio = NO
            TempPlayer(p3).AceitouDesafio = NO
            TempPlayer(p4).AceitouDesafio = NO
            '#####
        Case Else
            Exit Sub
    End Select
    
    Arena(Campo).tipo = tipo
    Arena(Campo).IsActive = YES
    Arena(Campo).WaitTmr = GetTickCount + 60000 '60 segundos pra aceitarem
    PlayerMsg index, "Pedido enviado. Ele(s) tem 60 segundos para aceitar ou recusar.", White
    
    For i = 1 To 2
        If Arena(Campo).p(i) > 0 And Arena(Campo).p(i) <> index Then
            SendDesafioRequest Arena(Campo).p(i), 2, tipo, Campo
        End If
        If Arena(Campo).p2(i) > 0 And Arena(Campo).p2(i) <> index Then
            SendDesafioRequest Arena(Campo).p2(i), 2, tipo, Campo
        End If
    Next
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleDesafio", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleDesafioState(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    If IsPlaying(index) = False Then Exit Sub
    
    Dim Buffer As clsBuffer
    Dim state As Byte
    Dim Mapa As Long
    Dim p2 As Long
    Dim p3 As Long
    Dim p4 As Long
    Dim i As Long
    Dim teste As Long
    
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    
    teste = Buffer.ReadLong
            
    If teste <> CLIENT_REVISION + CLIENT_MAJOR + CLIENT_MINOR Then 'previni clients que não sejam o nip
        Set Buffer = Nothing
        CloseSocket index
        Exit Sub
    End If
    
    state = Buffer.ReadByte
    
    Set Buffer = Nothing
    
    Mapa = TempPlayer(index).InArena
    If Mapa < 1 Or Mapa > 9 Then
        PlayerMsg index, "A arena precisa ser de 1 à 9!", BrightRed
        Exit Sub
    End If
    
    If Arena(Mapa).IsActive = NO Then
        TempPlayer(index).InArena = NO
        PlayerMsg index, "Você não esta participando de um desafio nessa arena!", Red
        Exit Sub
    End If
    
    If TempPlayer(index).AceitouDesafio = YES Then
        PlayerMsg index, "Você já aceitou o desafio! Espere a decisão dos outros!", White
        Exit Sub
    End If
    
    Select Case state
        Case NO
        
            For i = 1 To 2
                If Arena(Mapa).p(i) > 0 Then
                    If IsPlaying(Arena(Mapa).p(i)) Then
                        SendExtras Arena(Mapa).p(i), 1
                        If Arena(Mapa).p(i) <> index Then PlayerMsg Arena(Mapa).p(i), GetPlayerName(index) & " recusou o desafio. Desafio cancelado.", Grey
                        TempPlayer(Arena(Mapa).p(i)).InArena = NO
                        TempPlayer(Arena(Mapa).p(i)).AceitouDesafio = NO
                    End If
                End If
                If Arena(Mapa).p2(i) > 0 Then
                    If IsPlaying(Arena(Mapa).p2(i)) Then
                        SendExtras Arena(Mapa).p2(i), 1
                        If Arena(Mapa).p2(i) <> index Then PlayerMsg Arena(Mapa).p2(i), GetPlayerName(index) & " recusou o desafio. Desafio cancelado.", Grey
                        TempPlayer(Arena(Mapa).p2(i)).InArena = NO
                        TempPlayer(Arena(Mapa).p2(i)).AceitouDesafio = NO
                    End If
                End If
            Next
            
            ZerarArena Mapa 'zera sapoha
            
        Case YES
            TempPlayer(index).AceitouDesafio = YES
            
            Select Case Arena(Mapa).tipo
                Case 0 '1x1
                    p2 = Arena(Mapa).p(1)
                    If p2 > 0 Then
                        If IsPlaying(p2) Then
                            TempPlayer(p2).AceitouDesafio = YES
                            '####
                            Player(index).PKstate = 3
                            Player(p2).PKstate = 3
                            '####
                            SetPlayerDir index, DIR_LEFT
                            SetPlayerDir p2, DIR_RIGHT
                            '####
                            TempPlayer(index).Contagem = 6
                            TempPlayer(p2).Contagem = 6
                            '####
                            PlayerWarp index, Arena(Mapa).Map, 29, 7
                            PlayerWarp p2, Arena(Mapa).Map, 1, 7
                            '####
                            PlayerMsg index, "Que comece a luta!!!", White
                            PlayerMsg p2, "Que comece a luta!!!", White
                            '###
                            Arena(Mapa).WaitTmr = NO
                        Else
                            PlayerMsg index, "Player ta offline..", BrightRed
                        End If
                    End If
                
                Case 1 '1x2
                    p2 = Arena(Mapa).p(1) 'desafiante
                    If Arena(Mapa).p2(2) = index Then
                        p3 = Arena(Mapa).p2(1) 'parceiro 1
                    Else
                        p3 = Arena(Mapa).p2(2) 'parceiro 2
                    End If
                    
                    If p2 > 0 And p3 > 0 Then
                        If IsPlaying(p2) And IsPlaying(p3) Then
                            If TempPlayer(p3).AceitouDesafio = YES Then
                                Arena(Mapa).WaitTmr = NO
                                '####
                                Player(index).PKstate = 3
                                Player(p2).PKstate = 3
                                Player(p3).PKstate = 3
                                '####
                                SetPlayerDir index, DIR_LEFT
                                SetPlayerDir p3, DIR_LEFT
                                'X
                                SetPlayerDir p2, DIR_RIGHT
                                '####
                                TempPlayer(index).Contagem = 6
                                TempPlayer(p2).Contagem = 6
                                TempPlayer(p3).Contagem = 6
                                '####
                                PlayerWarp index, Arena(Mapa).Map, 29, 5
                                PlayerWarp p3, Arena(Mapa).Map, 29, 8
                                PlayerWarp p2, Arena(Mapa).Map, 1, 7
                                '####
                                PlayerMsg index, "Que comece a luta!!!", White
                                PlayerMsg p3, "Que comece a luta!!!", White
                                PlayerMsg p2, "Que comece a luta!!!", White
                                '###
                                Arena(Mapa).WaitTmr = NO
                            Else
                                PlayerMsg p2, GetPlayerName(index) & " aceitou o desafio!", BrightCyan
                                'PlayerMsg p3, GetPlayerName(index) & " aceitou o desafio! Só falta você agora!!", BrightCyan
                                PlayerMsg index, GetPlayerName(p3) & " ainda não deu resposta. Espere a decisão dele!", White
                                PlayerMsg p2, GetPlayerName(p3) & " ainda não deu resposta. Espere a decisão dele!", White
                            End If
                        End If
                    End If
                    
                Case 2 '2x1
                    p2 = Arena(Mapa).p(1) 'desafiante
                    If Arena(Mapa).p(2) = index Then
                        p3 = Arena(Mapa).p2(1) 'inimigo
                    Else
                        p3 = Arena(Mapa).p(2) 'parceiro
                    End If
                    
                    If p2 > 0 And p3 > 0 Then
                        If IsPlaying(p2) And IsPlaying(p3) Then
                            If TempPlayer(p3).AceitouDesafio = YES Then
                                Arena(Mapa).WaitTmr = NO
                                '####
                                Player(index).PKstate = 3
                                Player(p2).PKstate = 3
                                Player(p3).PKstate = 3
                                '####
                                If Arena(Mapa).p2(1) = p3 Then 'se for o inimigo
                                    SetPlayerDir p3, DIR_LEFT 'inimigo
                                    SetPlayerDir index, DIR_RIGHT 'aliado
                                End If
                                If Arena(Mapa).p(2) = p3 Then 'se for aliado
                                    SetPlayerDir p3, DIR_RIGHT
                                    SetPlayerDir index, DIR_LEFT 'index inimigo
                                End If
                                SetPlayerDir p2, DIR_RIGHT
                                '####
                                TempPlayer(index).Contagem = 6
                                TempPlayer(p2).Contagem = 6
                                TempPlayer(p3).Contagem = 6
                                '####
                                If Arena(Mapa).p2(1) = p3 Then 'se for o inimigo
                                    PlayerWarp index, Arena(Mapa).Map, 1, 5 'aliado
                                    PlayerWarp p3, Arena(Mapa).Map, 29, 8 'inimigo
                                End If
                                If Arena(Mapa).p(2) = p3 Then 'se for aliado
                                    PlayerWarp index, Arena(Mapa).Map, 29, 5 'inimigo
                                    PlayerWarp p3, Arena(Mapa).Map, 1, 5 'aliado
                                End If
                                PlayerWarp p2, Arena(Mapa).Map, 1, 8
                                '####
                                PlayerMsg p3, "Que comece a luta!!!", White
                                PlayerMsg p2, "Que comece a luta!!!", White
                                PlayerMsg index, "Que comece a luta!!!", White
                                '###
                                Arena(Mapa).WaitTmr = NO
                            Else
                                PlayerMsg p2, GetPlayerName(index) & " aceitou o desafio!", BrightCyan
                                'PlayerMsg p3, GetPlayerName(index) & " aceitou o desafio! Só falta você agora!!", BrightCyan
                                PlayerMsg index, GetPlayerName(p3) & " ainda não deu resposta. Espere a decisão dele!", White
                                PlayerMsg p2, GetPlayerName(p3) & " ainda não deu resposta. Espere a decisão dele!", White
                            End If
                        End If
                    End If
                Case 3 '2x2
                    p2 = Arena(Mapa).p(1) 'desafiante
                    If Arena(Mapa).p(2) = index Then
                        p3 = Arena(Mapa).p2(1) 'inimigo
                        p4 = Arena(Mapa).p2(2) 'inimigo
                    Else
                        If Arena(Mapa).p2(1) = index Then
                            p4 = Arena(Mapa).p2(2)
                        Else
                            p4 = Arena(Mapa).p2(1)
                        End If
                        p3 = Arena(Mapa).p(2) 'parceiro
                    End If
                    
                    If p2 > 0 And p3 > 0 And p4 > 0 Then
                        If IsPlaying(p2) And IsPlaying(p3) And IsPlaying(p4) Then
                            If TempPlayer(p3).AceitouDesafio = YES And TempPlayer(p4).AceitouDesafio = YES Then
                                Arena(Mapa).WaitTmr = NO
                                '####
                                Player(index).PKstate = 3
                                Player(p2).PKstate = 3
                                Player(p3).PKstate = 3
                                Player(p4).PKstate = 3
                                '####
                                SetPlayerDir p2, DIR_RIGHT
                                If Arena(Mapa).p(2) = index Then
                                    SetPlayerDir index, DIR_RIGHT
                                    '#x#
                                    SetPlayerDir p3, DIR_LEFT
                                    SetPlayerDir p4, DIR_LEFT
                                Else
                                    SetPlayerDir index, DIR_LEFT
                                    SetPlayerDir p4, DIR_LEFT
                                    '#x#
                                    SetPlayerDir p3, DIR_RIGHT
                                End If
                                '####
                                TempPlayer(index).Contagem = 6
                                TempPlayer(p2).Contagem = 6
                                TempPlayer(p3).Contagem = 6
                                TempPlayer(p4).Contagem = 6
                                '####
                                PlayerWarp p2, Arena(Mapa).Map, 1, 8
                                If Arena(Mapa).p(2) = index Then
                                    PlayerWarp index, Arena(Mapa).Map, 1, 5 'aliado
                                    '#xxx#
                                    PlayerWarp p4, Arena(Mapa).Map, 29, 8 'inimigo
                                    PlayerWarp p3, Arena(Mapa).Map, 29, 5 'aliado
                                Else
                                    PlayerWarp index, Arena(Mapa).Map, 29, 8 'aliado
                                    PlayerWarp p4, Arena(Mapa).Map, 29, 5 'inimigo
                                    '#xxx#
                                    PlayerWarp p3, Arena(Mapa).Map, 1, 5 'aliado
                                End If
                                '####
                                PlayerMsg p4, "Que comece a luta!!!", White
                                PlayerMsg p3, "Que comece a luta!!!", White
                                PlayerMsg p2, "Que comece a luta!!!", White
                                PlayerMsg index, "Que comece a luta!!!", White
                                '###
                                Arena(Mapa).WaitTmr = NO
                            Else
                                If TempPlayer(p3).AceitouDesafio = NO Then
                                    PlayerMsg p2, GetPlayerName(index) & " aceitou o desafio!", BrightCyan
                                    'PlayerMsg p3, GetPlayerName(index) & " aceitou o desafio! Agora falta você!!", BrightCyan
                                    PlayerMsg index, GetPlayerName(p3) & " ainda não deu resposta. Espere a decisão dele!", White
                                    PlayerMsg p2, GetPlayerName(p3) & " ainda não deu resposta. Espere a decisão dele!", White
                                    PlayerMsg p4, GetPlayerName(p3) & " ainda não deu resposta. Espere a decisão dele!", White
                                    If TempPlayer(p4).AceitouDesafio = NO Then
                                        PlayerMsg index, GetPlayerName(p4) & " ainda não deu resposta. Espere a decisão dele!", White
                                        PlayerMsg p2, GetPlayerName(p4) & " ainda não deu resposta. Espere a decisão dele!", White
                                        PlayerMsg p3, GetPlayerName(p4) & " ainda não deu resposta. Espere a decisão dele!", White
                                        'PlayerMsg p4, GetPlayerName(index) & " aceitou o desafio! Agora falta você!!", BrightCyan
                                    Else
                                        PlayerMsg p4, GetPlayerName(index) & " aceitou o desafio!", BrightCyan
                                    End If
                                ElseIf TempPlayer(p4).AceitouDesafio = NO Then
                                    PlayerMsg p2, GetPlayerName(index) & " aceitou o desafio!", BrightCyan
                                    PlayerMsg p3, GetPlayerName(index) & " aceitou o desafio!", BrightCyan
                                    'PlayerMsg p4, GetPlayerName(index) & " aceitou o desafio! Agora falta você!!", BrightCyan
                                    PlayerMsg index, GetPlayerName(p4) & " ainda não deu resposta. Espere a decisão dele!", White
                                    PlayerMsg p2, GetPlayerName(p4) & " ainda não deu resposta. Espere a decisão dele!", White
                                    PlayerMsg p3, GetPlayerName(p4) & " ainda não deu resposta. Espere a decisão dele!", White
                                End If
                            End If
                        End If
                    End If
                Case Else
            End Select
        Case Else
    End Select
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleDesafioState", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub HandleProjecTileAttack(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
Dim curProjecTile As Long, i As Long, CurEquipment As Long

    ' prevent subscript
    If index > MAX_PLAYERS Or index < 1 Then Exit Sub
    
    ' get the players current equipment
    CurEquipment = GetPlayerEquipment(index, Weapon)
    
    ' check if they've got equipment
    If CurEquipment < 1 Or CurEquipment > MAX_ITEMS Then Exit Sub
    
    ' set the curprojectile
    For i = 1 To MAX_PLAYER_PROJECTILES
        If TempPlayer(index).ProjecTile(i).Pic = 0 Then
            ' just incase there is left over data
            ClearProjectile index, i
            ' set the curprojtile
            curProjecTile = i
            Exit For
        End If
    Next
    
    ' check for subscript
    If curProjecTile < 1 Then Exit Sub
    
    ' populate the data in the player rec
    With TempPlayer(index).ProjecTile(curProjecTile)
        .Damage = 1 'Item(CurEquipment).ProjecTile.Damage
        .Direction = GetPlayerDir(index)
        .Pic = 1 'Item(CurEquipment).ProjecTile.Pic
        .Range = 5 'Item(CurEquipment).ProjecTile.Range
        .Speed = 100 'Item(CurEquipment).ProjecTile.Speed
        .X = GetPlayerX(index)
        .Y = GetPlayerY(index)
    End With
                
    ' trololol, they have no more projectile space left
    If curProjecTile < 1 Or curProjecTile > MAX_PLAYER_PROJECTILES Then Exit Sub
    
    ' update the projectile on the map
    SendProjectileToMap index, curProjecTile
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleProjecTileAttack", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleSpec(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    If IsPlaying(index) = False Then Exit Sub
    If Player(index).InTorneio > 0 Then
        PlayerMsg index, "Você esta em um torneio.", Red
        Exit Sub
    End If
    
    If TempPlayer(index).InArena > 0 Or TempPlayer(index).AceitouDesafio > 0 Then
        PlayerMsg index, "Você está em um desafio!", Red
        Exit Sub
    End If
    
    If Player(index).Spec = YES Then
        Player(index).Invisivel = NO
        Player(index).Spec = NO
        PlayerWarp index, 99, 10, 6 'Atendimento
    Else
        If GetPlayerAccess(index) <= 1 And Map(GetPlayerMap(index)).Moral <> MAP_MORAL_SAFE Then
            If GetPlayerVital(index, Vitals.HP) < GetPlayerMaxVital(index, Vitals.HP) Then
                PlayerMsg index, "Você precisa estar com a vida cheia OU em zona segura.", White
                Exit Sub
            End If
        End If
        
        If Torneio = TORNEIO_CS And frmServer.chkTorneioStatus.Value = YES Then
            Player(index).Invisivel = YES 'Invisivel
            Player(index).Spec = YES
            PlayerWarp index, 59, 5, 11
        Else
            If Torneio = TORNEIO_CS And frmServer.chkTorneioStatus.Value = YES Then
                Player(index).Invisivel = YES 'Invisivel
                Player(index).Spec = YES
                PlayerWarp index, 59, 5, 11
            Else
                If Torneio = TORNEIO_GUERRA Then
                    Player(index).Invisivel = YES 'Invisivel
                    Player(index).Spec = YES
                    PlayerWarp index, 299, 7, 7
                Else
                    Player(index).Invisivel = YES 'Invisivel
                    Player(index).Spec = YES
                    PlayerWarp index, 100, 15, 12
                End If
            End If
        End If
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleSpec", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleRecusa(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim Invitador As String
    Dim Recusador As Long
    Dim RefuseNum As Byte
    Dim Mapa As Byte
    Dim i As Byte
    
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    
    RefuseNum = Buffer.ReadByte
    Invitador = FindPlayer(Buffer.ReadString)
    Recusador = Buffer.ReadLong
    
    Set Buffer = Nothing
    
    If IsPlaying(Invitador) = False Then Exit Sub
    
    Select Case RefuseNum
        Case 1 'Desafios arenathing desafioanything
            Mapa = TempPlayer(Invitador).InArena
            
            If Mapa > 0 And Mapa <= 9 Then
                For i = 1 To 2
                    If Arena(Mapa).p(i) > 0 Then
                        If IsPlaying(Arena(Mapa).p(i)) Then
                            SendExtras Arena(Mapa).p(i), 1
                            If Arena(Mapa).p(i) <> index Then PlayerMsg Arena(Mapa).p(i), GetPlayerName(index) & " recusou o desafio(automaticamente). Desafio cancelado.", Grey
                            TempPlayer(Arena(Mapa).p(i)).InArena = NO
                            TempPlayer(Arena(Mapa).p(i)).AceitouDesafio = NO
                        End If
                    End If
                    If Arena(Mapa).p2(i) > 0 Then
                        If IsPlaying(Arena(Mapa).p2(i)) Then
                            SendExtras Arena(Mapa).p2(i), 1
                            If Arena(Mapa).p2(i) <> index Then PlayerMsg Arena(Mapa).p2(i), GetPlayerName(index) & " recusou o desafio(automaticamente). Desafio cancelado.", Grey
                            TempPlayer(Arena(Mapa).p2(i)).InArena = NO
                            TempPlayer(Arena(Mapa).p2(i)).AceitouDesafio = NO
                        End If
                    End If
                Next
                
                ZerarArena Mapa
            End If
            
            PlayerMsg Invitador, "Seu desafio foi recusado(O jogador bloqueou convites pra desafio)..", BrightRed
        Case 2 'Chat
            If IsPlaying(Invitador) = True Then
                TempPlayer(Invitador).InChat = NO
            End If
            TempPlayer(Recusador).InChat = NO
            
            PlayerMsg Invitador, "Seu pedido de ChatPrivado foi recusado(O jogador bloqueou convites pra ChatPrivado)..", BrightRed
        Case Else
    End Select
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleRecusa", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub


Sub HandleChatPrivado(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim pINDEX As Long
    Dim ChatState As Byte
    Dim texto As String
    
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    
    ChatState = Buffer.ReadByte
    pINDEX = FindPlayer(Buffer.ReadString)
    texto = Buffer.ReadString
    
    Set Buffer = Nothing

    Select Case ChatState
        Case 1 'Convidar alguem pro chat
            If IsPlaying(pINDEX) = False Then
                PlayerMsg index, "O jogador está offline!", Red
                Exit Sub
            End If
            
            If TempPlayer(pINDEX).InChat > 0 Then
                PlayerMsg index, "O jogador já está conversando com alguém(Ou convidou/convidado)!", Red
                Exit Sub
            End If
            
            If TempPlayer(index).InChat > 0 Then
                PlayerMsg index, "Você já está conversando com alguém(Ou convidou/convidado)!", Red
                Exit Sub
            End If
            
            If Player(pINDEX).InTorneio > 0 Then
                PlayerMsg index, "Ele está em algum torneio!", Red
                Exit Sub
            End If
            
            TempPlayer(index).InChat = pINDEX
            TempPlayer(pINDEX).InChat = index
            
            SendChatRequest pINDEX, index
        Case 2 'Pedido de Chat Recusado
            If IsPlaying(TempPlayer(index).InChat) = True Then
                PlayerMsg TempPlayer(index).InChat, "Seu pedido de Chat foi recusado!", Red
                TempPlayer(TempPlayer(index).InChat).InChat = NO
            End If
            
            TempPlayer(index).InChat = NO
        Case 3 'Pedido de Chat aceito
            If IsPlaying(TempPlayer(index).InChat) = False Then
                PlayerMsg index, "O jogador está offline!", Red
                TempPlayer(index).InChat = NO
                Exit Sub
            End If
            
            SendChatPrivado index, 1, TempPlayer(index).InChat 'Abrindo janela do chat
            SendChatPrivado TempPlayer(index).InChat, 1, index 'Abrindo janela do chat
        Case 4 'Enviando e recebendo msg
            If IsPlaying(TempPlayer(index).InChat) = False Then
                PlayerMsg index, "O jogador está offline!", Red
                TempPlayer(index).InChat = NO
                Exit Sub
            End If
            
            SendChatPrivado index, 2, index, texto
            SendChatPrivado TempPlayer(index).InChat, 2, index, texto
        Case 5 'Chat fechado,algo assim
            If IsPlaying(TempPlayer(index).InChat) = True Then
                TempPlayer(TempPlayer(index).InChat).InChat = NO
                PlayerMsg TempPlayer(index).InChat, "O chat foi cancelado!", Red
            End If
            
            TempPlayer(index).InChat = NO
        Case Else
            PlayerMsg index, "Ocorreu um erro", BrightRed
    End Select
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleChatPrivado", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
            
End Sub


Sub HandleLuta(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim p1 As Long
    Dim p2 As Long
    Dim p3 As Long
    Dim i As Long
    
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    
    p1 = FindPlayer(Buffer.ReadString)
    p2 = Val(Buffer.ReadString)
    p3 = AcharPlayer(Buffer.ReadString)
    
    Set Buffer = Nothing
    
    If GetPlayerAccess(index) < ADMIN_MONITOR Then Exit Sub
    
    '''''''''''''''''
    If IsPlaying(p1) = False Then
        PlayerMsg index, "O jogador não ta online!Escolha denovo", Red
        Exit Sub
    End If
    
    If p2 = 0 Then
        For i = 1 To MAX_PLAYERS
            If Trim$(Mutado(i)) = GetPlayerIP(p1) Then
                PlayerMsg index, GetPlayerName(p1) & "O ip dele ja ta mutado ;)  .", BrightCyan
                Exit Sub
            End If
        Next
        
        For i = 1 To MAX_PLAYERS
            If Trim$(Mutado(i)) = vbNullString Then
                PlayerMsg p1, GetPlayerName(index) & " mutou seu ip. Agora só poderá falar no chat no próximo reinicializamento do servidor(acontece as 6 e as 17 horas).", BrightRed
                Mutado(i) = GetPlayerIP(p1)
                Exit Sub
            Else
                If i = MAX_PLAYERS Then
                    PlayerMsg index, "Acabo os slots, não tem como, são 200", BrightRed
                    Exit Sub
                End If
            End If
        Next
    End If
    
    If p2 = 1 Then 'desmutar
        For i = 1 To MAX_PLAYERS
            If Trim$(Mutado(i)) = GetPlayerIP(p1) Then
                PlayerMsg p1, GetPlayerName(index) & " desmutou seu ip. Agora você poderá falar.", White
                Mutado(i) = vbNullString
                Exit Sub
            Else
                If i = MAX_PLAYERS Then
                    PlayerMsg index, "Ele não ta mutado", BrightRed
                    Exit Sub
                End If
            End If
        Next
    End If
    
    If p2 = 2 Then 'mutar player individual
        
        For i = 1 To 10
            If TempPlayer(index).mutedPlayers(i) = LCase$(GetPlayerName(p1)) Then
                PlayerMsg index, "Esse jogador " & GetPlayerName(p1) & " já está mutado pra ti!", White
                Exit Sub
            End If
        Next
        
        For i = 1 To 10
            If TempPlayer(index).mutedPlayers(i) = vbNullString Then
                TempPlayer(index).mutedPlayers(i) = LCase$(GetPlayerName(p1))
                PlayerMsg index, "Enquanto estiver no jogo não verá mais mensagens de " & GetPlayerName(p1) & ". Se quiser reverter, terá que relogar.", White
                Exit Sub
            End If
        Next
        
        PlayerMsg index, "Parece que você já mutou 10 jogadores que é o limite.", BrightRed
        Exit Sub
    End If
    
    Exit Sub
    ''''''''''''
    
    If GetPlayerAccess(index) = ADMIN_MONITOR Then
        If Torneio = NO Then
            PlayerMsg index, "nenhum torneio esta ativado..", Red
            Exit Sub
        End If
    End If
    
    If Torneio = NO Then
        PlayerMsg index, "Não ta tendo nenhum torneio agora ;/", Red
        Exit Sub
    End If
    
    If IsPlaying(p1) = False Then
        PlayerMsg index, "Player 1 não ta online!Escolha denovo", Red
        Exit Sub
    End If
    
    If IsPlaying(p2) = False Then
        PlayerMsg index, "Player 2 não ta online!Escolha denovo", Red
        Exit Sub
    End If
    
    If p3 > 0 Then
        If IsPlaying(p3) = False Then
            PlayerMsg index, "Player 3 não ta online!Escolha denovo", Red
            Exit Sub
        End If
    End If
    
    For i = 1 To 3
        If GetPlayerMap(Luta.Player(i)) = 100 Then 'torneio
            PlayerMsg index, "Parece que já está tendo uma luta..(" & GetPlayerName(Luta.Player(i)) & ")", Red
            Exit Sub
        End If
    Next
    
    If Player(p1).InTorneio = NO Then
        PlayerMsg index, "Player 1 não ta em torneio,deve ter entrado de forma ilegal", BrightRed
        'Exit Sub
    End If
    
    If Player(p2).InTorneio = NO Then
        PlayerMsg index, "Player 2 não ta em torneio,deve ter entrado de forma ilegal", BrightRed
        'Exit Sub
    End If
    
    If p3 > 0 Then
        If Player(p3).InTorneio = NO Then
            PlayerMsg index, "Player 3 não ta em torneio,deve ter entrado de forma ilegal", BrightRed
            'Exit Sub
        End If
    End If
    
    ZerarLutas
    
    If p3 > 0 Then
        Luta.PlayerQnt = 3
        Luta.Player(3) = p3
        SetPlayerDir p3, DIR_DOWN
        PlayerWarp p3, 100, 15, 1
        TempPlayer(p3).Contagem = 6
        GlobalMsg GetPlayerName(p1) & "(" & GetClassName(GetPlayerClass(p1)) & "-Lvl." & GetPlayerLevel(p1) & ") X " & GetPlayerName(p2) & "(" & GetClassName(GetPlayerClass(p2)) & "-Lvl." & GetPlayerLevel(p2) & ") X " & GetPlayerName(p3) & "(" & GetClassName(GetPlayerClass(p3)) & "-Lvl." & GetPlayerLevel(p3) & ")", White
    Else
        Luta.PlayerQnt = 2
        Luta.Player(3) = NO
        GlobalMsg GetPlayerName(p1) & "(" & GetClassName(GetPlayerClass(p1)) & "-Lvl." & GetPlayerLevel(p1) & ") X " & GetPlayerName(p2) & "(" & GetClassName(GetPlayerClass(p2)) & "-Lvl." & GetPlayerLevel(p2) & ")", White
    End If
    
    Luta.Player(1) = p1
    Luta.Player(2) = p2
    'DIR
    SetPlayerDir p1, DIR_RIGHT
    SetPlayerDir p2, DIR_LEFT
    'Warp
    PlayerWarp p1, 100, 1, 12
    PlayerWarp p2, 100, 29, 12
    'Contagem
    TempPlayer(p1).Contagem = 6
    TempPlayer(p2).Contagem = 6
        
    GlobalMsg "By:" & GetPlayerName(index), Yellow
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleLuta", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
    
End Sub

Sub HandleSairTorneio(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
On Error GoTo errorhandler

Dim i As Long

If IsPlaying(index) = False Then Exit Sub

If Player(index).InTorneio = NO And Player(index).War = NO Then
    PlayerMsg index, "Você não está em um torneio..", Red
    Exit Sub
End If

If GetPlayerMap(index) = 100 Then
    PlayerMsg index, "Apenas deslogando.", Pink
    Exit Sub
End If

For i = 1 To MAX_LIMIT_TIP
    If Trim$(SemTip(i)) = GetPlayerIP(index) Then
        SemTip(i) = vbNullString
        Exit For
    End If
Next

If Player(index).War > 0 Then
    If GetPlayerMap(index) >= 298 And GetPlayerMap(index) <= 300 Then '
        War.PlayerCount(Player(index).War) = War.PlayerCount(Player(index).War) - 1
    End If
    
        Player(index).WarPoints = NO
        Player(index).War = NO
    
    If GetPlayerMap(index) = 299 Then
        AtualizarEvento
    End If
End If

TirarTorneioData index

For i = 1 To MAX_INV
    If GetPlayerInvItemNum(index, i) = 210 Then
        TakeItem index, 210, GetPlayerInvItemValue(index, i)
    End If
    
    If GetPlayerInvItemNum(index, i) = 211 Then
        TakeItem index, 211, GetPlayerInvItemValue(index, i)
    End If
Next
    
    Player(index).InTorneio = NO
    PlayerMsg index, "Você saiu do torneio com sucesso!", Green
    PlayerWarp index, 99, 10, 6 'Atendimento
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleSairTorneio", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleWar(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim WarChoice As Byte
    
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    
    WarChoice = Buffer.ReadByte
    
    Set Buffer = Nothing
    
    If Torneio <> TORNEIO_GUERRA Then
        PlayerMsg index, "Acabou o tempo para entrar na guerra.", Grey
        Exit Sub
    End If
    
    If frmServer.chkTorneioStatus.Value = NO Then Exit Sub
    If frmServer.lstTorneios.ListIndex = 0 Then Exit Sub
    
    If Player(index).War > 0 Then
        PlayerMsg index, "Você já participou ou está participando.", Red
        Exit Sub
    End If
    
    If WarChoice = 1 Then 'bem
        If War.PlayerCount(1) > 0 Then
            If War.PlayerCount(1) > War.PlayerCount(2) Then
                PlayerMsg index, "A aliança está muito cheia,espere uma vaga ou entre na Tsuki no Me.", White
                Exit Sub
            End If
        End If
    Else 'mal
        If War.PlayerCount(2) > 0 Then
            If War.PlayerCount(2) > War.PlayerCount(1) Then
                PlayerMsg index, "A Tsuki está muito cheia,espere uma vaga ou entre na Aliança Shinobi.", White
                Exit Sub
            End If
        End If
    End If
    
    Player(index).PKstate = 3
    War.PlayerCount(WarChoice) = War.PlayerCount(WarChoice) + 1
    Player(index).War = WarChoice
    Player(index).WarPoints = 0
    Player(index).InTorneio = TORNEIO_GUERRA
    ColocarTorneioData index
    
    If WarChoice = 1 Then 'bem
        PlayerWarp index, 298, 7, 5
    Else
        PlayerWarp index, 300, 7, 5
    End If
    
    SendPlayerData index
    PlayerMsg index, "Você entrou para a guerra,quanto mais derrotar do time inimigo,mais pontos você e seu time recebe!", White
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleWar", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleMudarNome(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim Nome As String
    Dim F As Long
    Dim n As Integer
    Dim i As Integer
    
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    
    Nome = Buffer.ReadString
    
    Set Buffer = Nothing
    
    If IsPlaying(index) = False Then Exit Sub
    
    If FindChar(Trim$(Nome)) Then
        PlayerMsg index, "Esse nick já está em uso. Escolha outro por favor!", BrightRed
        Exit Sub
    End If
    
    If InStr(Nome, " ") Then
        PlayerMsg index, "Não use espaços!!", Grey
        Exit Sub
    End If
    
    For i = 1 To Len(Nome)
        n = AscW(Mid$(Nome, i, 1))

        If Not nomeLegal(n) Then
            Call PlayerMsg(index, "Nick inválido, apenas letras,números,anderline, pontos e traços.", Grey)
            Exit Sub
        End If

    Next
    
    If CanTake(index, 254, 5000) = False Then
        PlayerMsg index, "Você precisa de 5k CASH pra mudar o NICK!", BrightRed
        Exit Sub
    Else
        TakeInvItem index, 254, 5000
    End If
    
    PlayerMsg index, "Tudo ocorreu bem!Seu novo nick é:" & Nome, BrightGreen
    
    If LenB(Trim$(GetPlayerName(index))) > 0 Then DeleteName GetPlayerName(index)
    
    If Player(index).Org >= 13 And Player(index).Org < 100 Then
        For i = 1 To MAX_ORG_MEMBERS
            If Trim$(Org(Player(index).Org).MembroLogin(i)) = GetPlayerLogin(index) Then
                Org(Player(index).Org).MembroNome(i) = Trim$(Nome)
                saveOrg Player(index).Org
                Exit For
            End If
        Next
    End If
    
    For i = 1 To 20
        If Trim$(TopLvl(i).Nome) = GetPlayerName(index) Then
            'muda o nick do top
            TopLvl(i).Nome = Trim$(Nome)
            SalvarTop
            Exit For
        End If
    Next
    
    For i = 1 To MAX_CLASS_TEMP
        If Trim$(TopChar(i).Nome) = GetPlayerName(index) Then
            'muda o nick do top
            TopChar(i).Nome = Trim$(Nome)
            SalvarTopChar
            Exit For
        End If
    Next
    
    For i = 1 To 10
        If Trim$(TopPvP(i).Nome) = GetPlayerName(index) Then
            'muda o nick do top
            TopPvP(i).Nome = Trim$(Nome)
            SalvarPVP
        End If
        If Trim$(TopPK(i).Nome) = GetPlayerName(index) Then
            'muda o nick do top
            TopPK(i).Nome = Trim$(Nome)
            SalvarKarma
        End If
        If Trim$(TopHero(i).Nome) = GetPlayerName(index) Then
            'muda o nick do top
            TopHero(i).Nome = Trim$(Nome)
            SalvarKarma
        End If
    Next
    
    Player(index).Name = Trim$(Nome)
    SendPlayerData index
    
    ' Append name to file
    F = FreeFile
    Open App.Path & "\data\accounts\charlist.txt" For Append As #F
        Print #F, Trim$(Nome)
    Close #F
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleMudarNome", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleExameEscrito(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim i As Byte
    
    Dim Buffer As clsBuffer
    Dim Passou As Byte
    
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    
    Passou = Buffer.ReadByte

    Set Buffer = Nothing
    
    If Passou = NO Then
        TempPlayer(index).ExameEscrito = NO
        Exit Sub
    End If
    
    If TempPlayer(index).ExameEscrito = NO Then
        PlayerMsg index, "nope ;]", BrightRed
        Exit Sub
    End If
    
    For i = 1 To 10
        If Player(index).QuestNum(i) >= 108 And Player(index).QuestNum(i) <= 110 Then
            PlayerMsg index, "Você já está com um teste de RANK ativado..", BrightRed
            Exit Sub
        End If
    Next

    Select Case Player(index).Rank
        Case RANK_GENIN
            If Not Player(index).Rank = RANK_GENIN Then
                PlayerMsg index, "Apenas Gennin's!", Red
                Exit Sub
            End If
            
            If Torneio = TORNEIO_CS And frmServer.chkTorneioStatus.Value = YES Then
                
                If GetPlayerLevel(index) >= 100 Then
                    StartQuest index, 4
                Else
                    PlayerMsg index, "Você precisa ser no mínimo level 100!", BrightRed
                End If
            Else
                PlayerMsg index, "No momento não está tendo Chunin Shiken.", BrightRed
            End If
        Case RANK_CHUNIN
            StartQuest index, 108, 209
        Case RANK_JOUNIN
            StartQuest index, 109, 209
        Case RANK_ANBU
            StartQuest index, 110, 209
        Case Else
            PlayerMsg index, "Não tem nada aqui", Pink
    End Select

    TempPlayer(index).ExameEscrito = NO
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleExameEscrito", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleZerarKarma(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
On Error GoTo errorhandler

If IsPlaying(index) = False Then Exit Sub
If index < 1 Or index > MAX_PLAYERS Then Exit Sub

Player(index).Karma = NO
SendPlayerData index

PlayerMsg index, "Seu karma foi zerado com sucesso!", BrightGreen

    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleZerarKarma", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub HandleAmigo(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim Nome As String
    Dim state As Byte
    Dim i As Byte
    
    Set Buffer = New clsBuffer
    Buffer.WriteBytes Data()
    
    state = Buffer.ReadByte
    Nome = Buffer.ReadString
    
    Set Buffer = Nothing
    
    Select Case state
        Case 1 'adicionar amigo
            For i = 1 To 50
                If Trim$(Player(index).Amigos(i)) = Trim$(Nome) Then
                    PlayerMsg index, "Você já adicionou essa pessoa.", BrightRed
                    Exit Sub
                End If
            Next
            
            For i = 1 To 50
                If Trim$(Player(index).Amigos(i)) = vbNullString Then
                    Player(index).Amigos(i) = Trim$(Nome)
                    SendPlayerNames index
                    PlayerMsg index, Nome & " adicionado com sucesso!", BrightGreen
                    Exit Sub
                End If
            Next
            
            PlayerMsg index, "Você atingiu o limite de amigos!", BrightRed
        
        Case 2 'remover amigo
            For i = 1 To 50
                If Trim$(Player(index).Amigos(i)) = Trim$(Nome) Then
                    Player(index).Amigos(i) = vbNullString
                    SendPlayerNames index
                    PlayerMsg index, Nome & " deletado com sucesso!", Yellow
                    Exit Sub
                End If
            Next
        Case Else
    End Select
       
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleAmigo", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub HandleKikarConta(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim Name As String
    Dim Password As String
    Dim i As Long
    Dim n As Long
    Dim teste As Long
    
        If Not IsLoggedIn(index) Then
            Set Buffer = New clsBuffer
            Buffer.WriteBytes Data()
            ' Get the data
            teste = Buffer.ReadLong
            
            If teste <> CLIENT_REVISION + CLIENT_MAJOR + CLIENT_MINOR Then 'previni clients que não sejam o nip
                Set Buffer = Nothing
                AlertMsg index, "Versão desatualizada!!"
                Exit Sub
            End If
            
            Name = Buffer.ReadString
            Password = Buffer.ReadString
            
            If teste <> CLIENT_REVISION + CLIENT_MAJOR + CLIENT_MINOR Then 'previni clients que não sejam o nip
                AlertMsg index, "Versão desatualizada!!"
                Exit Sub
            End If
            
            If isShuttingDown Then
                Call AlertMsg(index, "Server is either rebooting or being shutdown.")
                Exit Sub
            End If

            If Len(Trim$(Name)) < 3 Or Len(Trim$(Password)) < 3 Then
                Call AlertMsg(index, "Your name and password must be at least three characters in length")
                Exit Sub
            End If
            
            If InStr(Name, " ") Then
                AlertMsg index, "Não use espaços!"
                Exit Sub
            End If
            
            If LCase$(Left$(Name, 1)) = " " Or LCase$(Right(Name, 1)) = " " Then
                AlertMsg index, "Não use espaços!"
                Exit Sub
            End If
            
            If InStr(Name, " ") Then
                AlertMsg index, "Não use espaços!"
                Exit Sub
            End If
            
            ' Prevent hacking
            For i = 1 To Len(Name)
                n = AscW(Mid$(Name, i, 1))

                If Not isNameLegal(n) Then
                    Call AlertMsg(index, "Invalid name, only letters, numbers, spaces, and _ allowed in names.")
                    Exit Sub
                End If

            Next
            
            If Not AccountExist(Name) Then
                Call AlertMsg(index, "That account name does not exist.")
                Exit Sub
            End If

            If Not PasswordOK(Name, Password) Then
                Call AlertMsg(index, "Incorrect password.")
                Exit Sub
            End If

            If Not IsMultiAccounts(Name) Then
                Call AlertMsg(index, "Essa conta não está logada,pode logá-la agora.")
                Exit Sub
            End If
            
            For i = 1 To Player_HighIndex
                If GetPlayerLogin(i) = Trim$(Name) Then
                    AlertMsg i, "Você usou o Kick Forçado."
                    AlertMsg index, "Sua conta foi kikada,pode loga-la agora."
                    Exit Sub
                End If
            Next
            
            Set Buffer = Nothing
        End If
        
        ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleKikarConta", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub HandleCSecretPass(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim Name As String
    Dim Password As String
    Dim SenhaSecreta As String
    Dim NewPass As String
    Dim teste As Long
    
    If Not IsPlaying(index) Then
        If Not IsLoggedIn(index) Then
            Set Buffer = New clsBuffer
            Buffer.WriteBytes Data()
            ' Get the data
            teste = Buffer.ReadLong
            
            If teste <> CLIENT_REVISION + CLIENT_MAJOR + CLIENT_MINOR Then 'previni clients que não sejam o nip
                Set Buffer = Nothing
                AlertMsg index, "Versão desatualizada!!"
                Exit Sub
            End If
            
            Name = Buffer.ReadString
            SenhaSecreta = Buffer.ReadString
            NewPass = Buffer.ReadString
            
            If teste <> CLIENT_REVISION + CLIENT_MAJOR + CLIENT_MINOR Then 'previni clients que não sejam o nip
                AlertMsg index, "Versão desatualizada!!"
                Exit Sub
            End If
            
            If isShuttingDown Then
                Call AlertMsg(index, "O game está sendo desligado,tente novamente daqui alguns minutos.")
                Exit Sub
            End If

            If Len(Trim$(Name)) < 3 Or Len(Trim$(SenhaSecreta)) < 1 Or Len(Trim$(NewPass)) < 3 Then
                Call AlertMsg(index, "Seu nome e sua senha precisa ter pelo menos 3 caracteres")
                Exit Sub
            End If
            
            If Len(Trim$(NewPass)) > 12 Then
                AlertMsg index, "Sua nova senha precisa ter no máximo 12 caracteres"
                Exit Sub
            End If

            If Not AccountExist(Name) Then
                Call AlertMsg(index, "Essa conta não existe.")
                Exit Sub
            End If

            If IsMultiAccounts(Name) Then
                Call AlertMsg(index, "Essa conta ja esta online.")
                Exit Sub
            End If
            
            ' Load the player
            Call LoadPlayer(index, Name)
            
            If SecretPassOk(index, SenhaSecreta) = NO Then
                AlertMsg index, "Senha secreta errada!"
                Exit Sub
            Else
                Player(index).SenhaSecreta = Trim$(NewPass)
                SavePlayer index
            End If
            
            AlertMsg index, "Senha Secreta alterada com sucesso: " & Trim$(NewPass)
            
            Set Buffer = Nothing
        End If
    End If
        
        ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleCSecretPass", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Private Sub HandleGetPass(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
    On Error GoTo errorhandler
    
    Dim Buffer As clsBuffer
    Dim Name As String
    Dim Password As String
    Dim SenhaSecreta As String
    Dim teste As Long
    
    If Not IsPlaying(index) Then
        If Not IsLoggedIn(index) Then
            Set Buffer = New clsBuffer
            Buffer.WriteBytes Data()
            ' Get the data
            teste = Buffer.ReadLong
            
            If teste <> CLIENT_REVISION + CLIENT_MAJOR + CLIENT_MINOR Then 'previni clients que não sejam o nip
                Set Buffer = Nothing
                AlertMsg index, "Versão desatualizada!!"
                Exit Sub
            End If
            
            Name = Buffer.ReadString
            SenhaSecreta = Buffer.ReadString
            
            If teste <> CLIENT_REVISION + CLIENT_MAJOR + CLIENT_MINOR Then 'previni clients que não sejam o nip
                AlertMsg index, "Versão desatualizada!!"
                Exit Sub
            End If
            
            If isShuttingDown Then
                Call AlertMsg(index, "O game está sendo desligado,tente novamente daqui alguns minutos.")
                Exit Sub
            End If

            If Len(Trim$(Name)) < 3 Or Len(Trim$(SenhaSecreta)) < 1 Then
                Call AlertMsg(index, "Seu nome e sua senha precisa ter pelo menos 3 caracteres")
                Exit Sub
            End If

            If Not AccountExist(Name) Then
                Call AlertMsg(index, "Essa conta não existe.")
                Exit Sub
            End If

            If IsMultiAccounts(Name) Then
                Call AlertMsg(index, "Essa conta ja esta online.")
                Exit Sub
            End If
            
            ' Load the player
            Call LoadPlayer(index, Name)
            
            If SecretPassOk(index, SenhaSecreta) = NO Then
                AlertMsg index, "Senha secreta errada!"
                Exit Sub
            End If
            
            AlertMsg index, "Sua senha atual é: " & Trim$(Player(index).Password)
            
            Set Buffer = Nothing
        End If
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleGetPass", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Sub HandleBerserkerMode(ByVal index As Long, ByRef Data() As Byte, ByVal StartAddr As Long, ByVal ExtraVar As Long)
On Error GoTo errorhandler

Dim i As Long

If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If TempPlayer(index).berserkerMode = YES Then Exit Sub

If GetPlayerAccess(index) = 2 Then 'gm
    Player(index).PKstate = NO
    PlayerMsg index, "GM Nambe,isso é só pros preyer rçrçrç", White
    Exit Sub
End If

If GetPlayerLevel(index) < 300 Then
    PlayerMsg index, "Necessário ter pelo menos lvl 300+!", White
    Exit Sub
End If

For i = 1 To MAX_PLAYERS
    If PlayerBerserker(i) = vbNullString Then
        PlayerBerserker(i) = GetPlayerLogin(index)
        Exit For
    End If
Next

TempPlayer(index).berserkerMode = YES

PlayerMsg index, "BERSERKER MODE ATIVADO COM SUCESSO!", Yellow
PlayerMsg index, "Agora só será desativado no próximo reiniciamento do jogo! Boa sorte!!", Yellow

SendPlayerData index
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "HandleBerserkerMode", "modHandleData", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub
