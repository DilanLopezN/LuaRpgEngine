Attribute VB_Name = "modPlayer"
Option Explicit

Sub HandleUseChar(ByVal index As Long)
'If index < 1 Or index > MAX_PLAYERS Then Exit Sub
'If IsPlaying(index) = False Then Exit Sub

    If Not IsPlaying(index) Then
        Call JoinGame(index)
        Call AddLog(GetPlayerLogin(index) & "/" & GetPlayerName(index) & " começou a jogar " & Options.Game_Name & ".", PLAYER_LOG)
        Call TextAdd(GetPlayerLogin(index) & "/" & GetPlayerName(index) & " começou a jogar " & Options.Game_Name & ".")
        Call UpdateCaption
    End If
End Sub

Sub JoinGame(ByVal index As Long)
'If index < 1 Or index > MAX_PLAYERS Then Exit Sub
'If IsPlaying(index) = False Then Exit Sub

    Dim i, mapNum As Long
    
    ' Set the flag so we know the person is in the game
    TempPlayer(index).InGame = True
    'Update the log
    frmServer.lvwInfo.ListItems(index).SubItems(1) = GetPlayerIP(index)
    frmServer.lvwInfo.ListItems(index).SubItems(2) = GetPlayerLogin(index)
    frmServer.lvwInfo.ListItems(index).SubItems(3) = GetPlayerName(index)
    
    ' send the login ok
    SendLoginOk index
    
    TotalPlayersOnline = TotalPlayersOnline + 1
    
    ' Send some more little goodies, no need to explain these
    Call CheckEquippedItems(index)
    Call SendClasses(index)
    Call SendItems(index)
    Call SendAnimations(index)
    Call SendNpcs(index)
    Call SendShops(index)
    Call SendSpells(index)
    Call SendResources(index)
    Call SendInventory(index)
    Call SendWornEquipment(index)
    Call SendMapEquipment(index)
    Call SendPlayerSpells(index)
    Call SendHotbar(index)
    SendQuestPic index
    SendTopPic index
    SendKarmaPic index
    SendPvpPic index
    SendOrgPic index
    SendCharPic index
    
    ' send vitals, exp + stats
    For i = 1 To Vitals.Vital_Count - 1
        Call SendVital(index, i)
    Next
    SendEXP index
    Call SendStats(index)
    
    ' Warp the player to his saved location
    Call PlayerWarp(index, GetPlayerMap(index), GetPlayerX(index), GetPlayerY(index))
    
    If Player(index).PvP.V > 100000 Then
        Player(index).PvP.V = 0
        Player(index).PvP.D = 0
    End If
    
    If Player(index).Karma > 100000 Then
        Player(index).Karma = 0
    End If
    ' Send a global message that he/she joined
    If GetPlayerAccess(index) > 1 Then
        Select Case GetPlayerAccess(index)
            Case 2 'GM
                Call GlobalMsg(GetPlayerName(index) & " entrou no " & Options.Game_Name & "!", JoinLeftColor)
                GlobalMsg "GM na área!!", BrightGreen
            Case 3 'Mapper
                Call GlobalMsg(GetPlayerName(index) & " entrou no " & Options.Game_Name & "!", JoinLeftColor)
                GlobalMsg "Mapper na área!!", BrightGreen
            Case 4 'Desenvolvedor
                Call GlobalMsg(GetPlayerName(index) & " entrou no " & Options.Game_Name & "!", JoinLeftColor)
                GlobalMsg "Desenvolvedor na área!!", BrightGreen
            Case 5 'ADM
                Call GlobalMsg(GetPlayerName(index) & " entrou no " & Options.Game_Name & "!", JoinLeftColor)
                'GlobalMsg "ADM na área!!", BrightGreen
            Case Else
        End Select
    Else
        
        If Player(index).VipData.VIP > 0 Then
            Select Case Player(index).VipData.VIP
                Case 1 'Light
                    Call GlobalMsg(GetPlayerName(index) & "(VipLight-" & GetClassName(GetPlayerClass(index)) & ")" & " entrou no " & Options.Game_Name & "!", BrightCyan)
                Case 2 'OhYeh
                    Call GlobalMsg(GetPlayerName(index) & "(VipOhYeh-" & GetClassName(GetPlayerClass(index)) & ")" & " entrou no " & Options.Game_Name & "!", BrightCyan)
                Case Else
            End Select
        Else
            Call GlobalMsg(GetPlayerName(index) & "(" & GetClassName(GetPlayerClass(index)) & ")" & " entrou no " & Options.Game_Name & "!", Cyan)
        End If
    End If
    
    ' Send welcome messages
    Call SendWelcome(index)

    ' Send Resource cache
    For i = 0 To ResourceCache(GetPlayerMap(index)).Resource_Count
        SendResourceCacheTo index, i
    Next
    
    ' Send the flag so they know they can start doing stuff
    SendInGame index
    TempPlayer(index).MySprite = GetPlayerSprite(index)
    If GetPlayerAccess(index) = 0 Then SetPlayerAccess index, 1
    
    If Player(index).Rank = RANK_CHUNIN Then
        If Not HasSpell(index, 4) Then
            SetPlayerSpell index, FindOpenSpellSlot(index), 4
            PlayerMsg index, "Você aprendeu Kage Buyou!", BrightBlue
        End If
    End If
    
    If Player(index).Rank = RANK_DESERTOR Then
        Player(index).Vila = 0
    End If
    
    If Not Torneio = "cs" Then
        For i = 1 To MAX_INV
        
            If GetPlayerInvItemNum(index, i) = 219 Then
                TakeItem index, 219, 1
            End If

        Next
    End If
    
    If Not Torneio = "cs" Then
        Player(index).QuestCompleta(4) = 0
    End If
    
    mapNum = GetPlayerMap(index)
       
    If Player(index).Rank = RANK_JOUNIN Then
        If Player(index).Elemento(2) = 0 Then
            Select Case RAND(1, 5)
                Case 1 'Fogo
                    If Not Player(index).Elemento(1) = 1 Then
                        Player(index).Elemento(2) = 1
                        PlayerMsg index, "Agora você domina o elemento:Fogo", White
                    Else
                        Player(index).Elemento(2) = 2
                        PlayerMsg index, "Agora você domina o elemento:Vento", White
                    End If
                Case 2 'Vento
                    If Not Player(index).Elemento(1) = 2 Then
                        Player(index).Elemento(2) = 2
                        PlayerMsg index, "Agora você domina o elemento:Vento", White
                    Else
                        Player(index).Elemento(2) = 3
                        PlayerMsg index, "Agora você domina o elemento:Água", White
                    End If
                Case 3 'Agua
                    If Not Player(index).Elemento(1) = 3 Then
                        Player(index).Elemento(2) = 3
                        PlayerMsg index, "Agora você domina o elemento:Água", White
                    Else
                        Player(index).Elemento(2) = 4
                        PlayerMsg index, "Agora você domina o elemento:Terra", White
                    End If
                Case 4 'Terra
                    If Not Player(index).Elemento(1) = 4 Then
                        Player(index).Elemento(2) = 4
                        PlayerMsg index, "Agora você domina o elemento:Terra", White
                    Else
                        Player(index).Elemento(2) = 5
                        PlayerMsg index, "Agora você domina o elemento:Trovão", White
                    End If
                Case 5 'Trovão
                    If Not Player(index).Elemento(1) = 5 Then
                        Player(index).Elemento(2) = 5
                        PlayerMsg index, "Agora você domina o elemento:Trovão", White
                    Else
                        Player(index).Elemento(2) = 4
                        PlayerMsg index, "Agora você domina o elemento:Terra", White
                    End If
                Case Else
            End Select
            
            SavePlayer index
        End If
    End If
        
       'If Player(index).Karma = vbNullString Then Player(index).Karma = 0
        
        TransDown index
            
    OrgJutsu index
    'Checar Tempo
    CheckVIP index
    CheckCT index
    CheckAreaVIP index
    Noticias index
    
    For i = 1 To MAX_INV 'Tomar os itens por enquanto :D
        Dim NumItem As Byte
        NumItem = GetPlayerInvItemNum(index, i)
        
        If NumItem >= 200 And NumItem <= 216 Or NumItem >= 220 And NumItem <= 230 Then 'Chaves,etc..
            
            TakeInvItem index, NumItem, GetPlayerInvItemValue(index, i)
            
            If NumItem = 230 Then
                PlayerMsg index, "Aneis da akat tirados do game por enquanto..", BrightGreen
            End If
        End If
    Next
    
    
    
End Sub

Sub LeftGame(ByVal index As Long)
'If index < 1 Or index > MAX_PLAYERS Then Exit Sub
'If IsPlaying(index) = False Then Exit Sub

    Dim n As Long, i As Long
    Dim tradeTarget As Long
    
    
    If TempPlayer(index).InGame Then
        TempPlayer(index).InGame = False
        
        If TempPlayer(index).IsDesafio = YES Then
            ZerarDesafio TempPlayer(index).InDesafio, index, YES
        End If
        
        For i = 1 To 4
            If TempPlayer(index).Dojutsu(i) > 0 Then
                TirarDojutsu index, i
            End If
        Next
        
        'If Player(index).Trans > 0 Then
            TransDown index
        'End If
        
        If TempPlayer(index).Henge > 0 Then
            SetPlayerSprite index, TempPlayer(index).MySprite
        End If

        ' Check if player was the only player on the map and stop npc processing if so
        If GetTotalMapPlayers(GetPlayerMap(index)) < 1 Then
            PlayersOnMap(GetPlayerMap(index)) = NO
        End If
        
        ' cancel any trade they're in
        If TempPlayer(index).InTrade > 0 Then
            tradeTarget = TempPlayer(index).InTrade
            PlayerMsg tradeTarget, Trim$(GetPlayerName(index)) & " recusou seu pedido de troca.", BrightRed
            ' clear out trade
            For i = 1 To MAX_INV
                TempPlayer(tradeTarget).TradeOffer(i).num = 0
                TempPlayer(tradeTarget).TradeOffer(i).Value = 0
            Next
            TempPlayer(tradeTarget).InTrade = 0
            SendCloseTrade tradeTarget
        End If
        
        ' leave party.
        Party_PlayerLeave index

        ' save and clear data.
        Call SavePlayer(index)
        Call SaveBank(index)
        Call ClearBank(index)

        ' Send a global message that he/she left
        If GetPlayerAccess(index) <= ADMIN_MONITOR Then
            Call GlobalMsg(GetPlayerName(index) & " saiu do " & Options.Game_Name & "!", JoinLeftColor)
        Else
            Call GlobalMsg(GetPlayerName(index) & " saiu do " & Options.Game_Name & "!", White)
        End If

        Call TextAdd(GetPlayerName(index) & " foi desconectado do " & Options.Game_Name & ".")
        Call SendLeftGame(index)
        TotalPlayersOnline = TotalPlayersOnline - 1
    End If

    Call ClearPlayer(index)
End Sub

Function GetPlayerProtection(ByVal index As Long) As Long
If index < 1 Or index > MAX_PLAYERS Then Exit Function
If IsPlaying(index) = False Then Exit Function
    
    Dim Armor As Long
    Dim Helm As Long
    GetPlayerProtection = 0

    ' Check for subscript out of range
    If IsPlaying(index) = False Or index <= 0 Or index > Player_HighIndex Then
        Exit Function
    End If

    Armor = GetPlayerEquipment(index, Armor)
    Helm = GetPlayerEquipment(index, Helmet)
    GetPlayerProtection = (GetPlayerStat(index, Stats.Endurance) \ 5)

    If Armor > 0 Then
        GetPlayerProtection = GetPlayerProtection + Item(Armor).Data2
    End If

    If Helm > 0 Then
        GetPlayerProtection = GetPlayerProtection + Item(Helm).Data2
    End If

End Function

Function CanPlayerCriticalHit(ByVal index As Long) As Boolean
If index < 1 Or index > MAX_PLAYERS Then Exit Function
If IsPlaying(index) = False Then Exit Function

    Dim i As Long
    Dim n As Long

    If GetPlayerEquipment(index, Weapon) > 0 Then
        n = (Rnd) * 2

        If n = 1 Then
            i = (GetPlayerStat(index, Stats.strength) \ 2) + (GetPlayerLevel(index) \ 2)
            n = Int(Rnd * 100) + 1

            If n <= i Then
                CanPlayerCriticalHit = True
            End If
        End If
    End If

End Function

Function CanPlayerBlockHit(ByVal index As Long) As Boolean
If index < 1 Or index > MAX_PLAYERS Then Exit Function
If IsPlaying(index) = False Then Exit Function
    
    Dim i As Long
    Dim n As Long
    Dim ShieldSlot As Long
    ShieldSlot = GetPlayerEquipment(index, Shield)

    If ShieldSlot > 0 Then
        n = Int(Rnd * 2)

        If n = 1 Then
            i = (GetPlayerStat(index, Stats.Endurance) \ 2) + (GetPlayerLevel(index) \ 2)
            n = Int(Rnd * 100) + 1

            If n <= i Then
                CanPlayerBlockHit = True
            End If
        End If
    End If

End Function

Sub PlayerWarp(ByVal index As Long, ByVal mapNum As Long, ByVal X As Long, ByVal Y As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If IsPlaying(index) = False Then Exit Sub
If mapNum <= 0 Or mapNum > MAX_MAPS Then Exit Sub
    
    Dim shopNum As Long
    Dim OldMap As Long
    Dim i As Long
    Dim Buffer As clsBuffer

    ' Check for subscript out of range
    If IsPlaying(index) = False Or mapNum <= 0 Or mapNum > MAX_MAPS Then
        Exit Sub
    End If
    
    If TempPlayer(index).IsDesafio = YES Then
        PlayerMsg index, "Não pode se teleportar enquanto está no meio de um duelo!", BrightRed
        Exit Sub
    End If

    ' Check if you are out of bounds
    If X > Map(mapNum).MaxX Then X = Map(mapNum).MaxX
    If Y > Map(mapNum).MaxY Then Y = Map(mapNum).MaxY
    If X < 0 Then X = 0
    If Y < 0 Then Y = 0
    
    ' if same map then just send their co-ordinates
    If mapNum = GetPlayerMap(index) Then
        SendPlayerXYToMap index
    End If
    
    ' clear target
    TempPlayer(index).Target = 0
    TempPlayer(index).targetType = TARGET_TYPE_NONE
    SendTarget index

    ' Save old map to send erase player data to
    OldMap = GetPlayerMap(index)

    If OldMap <> mapNum Then
        Call SendLeaveMap(index, OldMap)
    End If

    Call SetPlayerMap(index, mapNum)
    Call SetPlayerX(index, X)
    Call SetPlayerY(index, Y)
    
     If (OldMap <> mapNum) And TempPlayer(index).TempPetSlot > 0 Then
        'switch maps
       PetDisband index, OldMap
       SendPetBox index, "", 0
        'SpawnPet index, MapNum, Player(index).Pet.SpriteNum
        'PetFollowOwner index
    End If
    
    ' send player's equipment to new map
    SendMapEquipment index
    
    ' send equipment of all people on new map
    If GetTotalMapPlayers(mapNum) > 0 Then
        For i = 1 To Player_HighIndex
            If IsPlaying(i) Then
                If GetPlayerMap(i) = mapNum Then
                    SendMapEquipmentTo i, index
                End If
            End If
        Next
    End If

    ' Now we check if there were any players left on the map the player just left, and if not stop processing npcs
    If GetTotalMapPlayers(OldMap) = 0 Then
        PlayersOnMap(OldMap) = NO

        ' Regenerate all NPCs' health
        For i = 1 To MAX_MAP_NPCS

            If MapNpc(OldMap).Npc(i).num > 0 Then
                MapNpc(OldMap).Npc(i).Vital(Vitals.HP) = GetNpcMaxVital(MapNpc(OldMap).Npc(i).num, Vitals.HP)
            End If

        Next

    End If
    
    SendEXP index
    CheckQuestMAP index

    ' Sets it so we know to process npcs on the map
    PlayersOnMap(mapNum) = YES
    TempPlayer(index).GettingMap = YES
    
    Set Buffer = New clsBuffer
    Buffer.WriteLong SCheckForMap
    Buffer.WriteLong mapNum
    Buffer.WriteLong Map(mapNum).Revision
    SendDataTo index, Buffer.ToArray()
    Set Buffer = Nothing
    
    If mapNum = 56 And TempPlayer(index).InTorneio = YES Then
        PlayerMsg index, "Você está em um Torneio,passada pra fora proíbida!", BrightRed
        PlayerWarp index, OldMap, 50, GetPlayerY(index)
        Exit Sub
    End If
    
    If OldMap = 56 And mapNum = 57 And Not Player(index).Rank = RANK_GENIN Then
        If GetPlayerAccess(index) < ADMIN_MONITOR Then
            PlayerMsg index, "Área restrita apenas para Gennins!", BrightRed
            PlayerWarp index, OldMap, 5, GetPlayerY(index)
            Exit Sub
        End If
    End If
    
End Sub

Sub PlayerMove(ByVal index As Long, ByVal Dir As Long, ByVal movement As Long, Optional ByVal sendToSelf As Boolean = False)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If IsPlaying(index) = False Then Exit Sub
On Error Resume Next

    Dim Buffer As clsBuffer, mapNum As Long
    Dim X As Long, Y As Long
    Dim Moved As Byte, MovedSoFar As Boolean
    Dim NewMapX As Byte, NewMapY As Byte
    Dim TileType As Long, VitalType As Long, Colour As Long, amount As Long

    ' Check for subscript out of range
    If IsPlaying(index) = False Or Dir < DIR_UP Or Dir > DIR_RIGHT Or movement < 1 Or movement > 2 Then
        Exit Sub
    End If
    
    If TempPlayer(index).AndandoAgua = YES Then
        If GetPlayerVital(index, Vitals.mp) > 10 Then
            SetPlayerVital index, Vitals.mp, GetPlayerVital(index, Vitals.mp) - 10
            SendVital index, Vitals.mp
        Else
            TempPlayer(index).AndandoAgua = NO
            PlayerMsg index, "Jutsu desativado por você não ter Chakra.", Cyan
            Exit Sub
        End If
    End If

    Call SetPlayerDir(index, Dir)
    Moved = NO
    mapNum = GetPlayerMap(index)
    
    Select Case Dir
        Case DIR_UP

            ' Check to make sure not outside of boundries
            If GetPlayerY(index) > 0 Then

                ' Check to make sure that the tile is walkable
                If Not isDirBlocked(Map(GetPlayerMap(index)).Tile(GetPlayerX(index), GetPlayerY(index)).DirBlock, DIR_UP + 1) Then
                    If Map(GetPlayerMap(index)).Tile(GetPlayerX(index), GetPlayerY(index) - 1).Type <> TILE_TYPE_BLOCKED Then
                        If Map(GetPlayerMap(index)).Tile(GetPlayerX(index), GetPlayerY(index) - 1).Type <> TILE_TYPE_RESOURCE Then
    
                            ' Check to see if the tile is a key and if it is check if its opened
                            If Map(GetPlayerMap(index)).Tile(GetPlayerX(index), GetPlayerY(index) - 1).Type <> TILE_TYPE_KEY Or (Map(GetPlayerMap(index)).Tile(GetPlayerX(index), GetPlayerY(index) - 1).Type = TILE_TYPE_KEY And TempTile(GetPlayerMap(index)).DoorOpen(GetPlayerX(index), GetPlayerY(index) - 1) = YES) Then
                                Call SetPlayerY(index, GetPlayerY(index) - 1)
                                SendPlayerMove index, movement, sendToSelf
                                Moved = YES
                            End If
                        End If
                    End If
                End If

            Else

                ' Check to see if we can move them to the another map
                If Map(GetPlayerMap(index)).Up > 0 Then
                    NewMapY = Map(Map(GetPlayerMap(index)).Up).MaxY
                    Moved = YES
                    Call PlayerWarp(index, Map(GetPlayerMap(index)).Up, GetPlayerX(index), NewMapY)
                    'Moved = YES
                    ' clear their target
                    TempPlayer(index).Target = 0
                    TempPlayer(index).targetType = TARGET_TYPE_NONE
                    SendTarget index
                End If
            End If

        Case DIR_DOWN

            ' Check to make sure not outside of boundries
            If GetPlayerY(index) < Map(mapNum).MaxY Then

                ' Check to make sure that the tile is walkable
                If Not isDirBlocked(Map(GetPlayerMap(index)).Tile(GetPlayerX(index), GetPlayerY(index)).DirBlock, DIR_DOWN + 1) Then
                    If Map(GetPlayerMap(index)).Tile(GetPlayerX(index), GetPlayerY(index) + 1).Type <> TILE_TYPE_BLOCKED Then
                        If Map(GetPlayerMap(index)).Tile(GetPlayerX(index), GetPlayerY(index) + 1).Type <> TILE_TYPE_RESOURCE Then
    
                            ' Check to see if the tile is a key and if it is check if its opened
                            If Map(GetPlayerMap(index)).Tile(GetPlayerX(index), GetPlayerY(index) + 1).Type <> TILE_TYPE_KEY Or (Map(GetPlayerMap(index)).Tile(GetPlayerX(index), GetPlayerY(index) + 1).Type = TILE_TYPE_KEY And TempTile(GetPlayerMap(index)).DoorOpen(GetPlayerX(index), GetPlayerY(index) + 1) = YES) Then
                                Call SetPlayerY(index, GetPlayerY(index) + 1)
                                SendPlayerMove index, movement, sendToSelf
                                Moved = YES
                            End If
                        End If
                    End If
                End If

            Else

                ' Check to see if we can move them to the another map
                If Map(GetPlayerMap(index)).Down > 0 Then
                    Moved = YES
                    Call PlayerWarp(index, Map(GetPlayerMap(index)).Down, GetPlayerX(index), 0)
                    'Moved = YES
                    ' clear their target
                    TempPlayer(index).Target = 0
                    TempPlayer(index).targetType = TARGET_TYPE_NONE
                    SendTarget index
                End If
            End If

        Case DIR_LEFT

            ' Check to make sure not outside of boundries
            If GetPlayerX(index) > 0 Then

                ' Check to make sure that the tile is walkable
                If Not isDirBlocked(Map(GetPlayerMap(index)).Tile(GetPlayerX(index), GetPlayerY(index)).DirBlock, DIR_LEFT + 1) Then
                    If Map(GetPlayerMap(index)).Tile(GetPlayerX(index) - 1, GetPlayerY(index)).Type <> TILE_TYPE_BLOCKED Then
                        If Map(GetPlayerMap(index)).Tile(GetPlayerX(index) - 1, GetPlayerY(index)).Type <> TILE_TYPE_RESOURCE Then
    
                            ' Check to see if the tile is a key and if it is check if its opened
                            If Map(GetPlayerMap(index)).Tile(GetPlayerX(index) - 1, GetPlayerY(index)).Type <> TILE_TYPE_KEY Or (Map(GetPlayerMap(index)).Tile(GetPlayerX(index) - 1, GetPlayerY(index)).Type = TILE_TYPE_KEY And TempTile(GetPlayerMap(index)).DoorOpen(GetPlayerX(index) - 1, GetPlayerY(index)) = YES) Then
                                Call SetPlayerX(index, GetPlayerX(index) - 1)
                                SendPlayerMove index, movement, sendToSelf
                                Moved = YES
                            End If
                        End If
                    End If
                End If

            Else

                ' Check to see if we can move them to the another map
                If Map(GetPlayerMap(index)).Left > 0 Then
                    NewMapX = Map(Map(GetPlayerMap(index)).Left).MaxX
                    Moved = YES
                    Call PlayerWarp(index, Map(GetPlayerMap(index)).Left, NewMapX, GetPlayerY(index))
                    'Moved = YES
                    ' clear their target
                    TempPlayer(index).Target = 0
                    TempPlayer(index).targetType = TARGET_TYPE_NONE
                    SendTarget index
                End If
            End If

        Case DIR_RIGHT

            ' Check to make sure not outside of boundries
            If GetPlayerX(index) < Map(mapNum).MaxX Then

                ' Check to make sure that the tile is walkable
                If Not isDirBlocked(Map(GetPlayerMap(index)).Tile(GetPlayerX(index), GetPlayerY(index)).DirBlock, DIR_RIGHT + 1) Then
                    If Map(GetPlayerMap(index)).Tile(GetPlayerX(index) + 1, GetPlayerY(index)).Type <> TILE_TYPE_BLOCKED Then
                        If Map(GetPlayerMap(index)).Tile(GetPlayerX(index) + 1, GetPlayerY(index)).Type <> TILE_TYPE_RESOURCE Then
    
                            ' Check to see if the tile is a key and if it is check if its opened
                            If Map(GetPlayerMap(index)).Tile(GetPlayerX(index) + 1, GetPlayerY(index)).Type <> TILE_TYPE_KEY Or (Map(GetPlayerMap(index)).Tile(GetPlayerX(index) + 1, GetPlayerY(index)).Type = TILE_TYPE_KEY And TempTile(GetPlayerMap(index)).DoorOpen(GetPlayerX(index) + 1, GetPlayerY(index)) = YES) Then
                                Call SetPlayerX(index, GetPlayerX(index) + 1)
                                SendPlayerMove index, movement, sendToSelf
                                Moved = YES
                            End If
                        End If
                    End If
                End If
            Else
                ' Check to see if we can move them to the another map
                If Map(GetPlayerMap(index)).Right > 0 Then
                    Moved = YES
                    Call PlayerWarp(index, Map(GetPlayerMap(index)).Right, 0, GetPlayerY(index))
                    ' clear their target
                    TempPlayer(index).Target = 0
                    TempPlayer(index).targetType = TARGET_TYPE_NONE
                    SendTarget index
                End If
            End If
    End Select
    
    With Map(GetPlayerMap(index)).Tile(GetPlayerX(index), GetPlayerY(index))
        ' Check to see if the tile is a warp tile, and if so warp them
        If .Type = TILE_TYPE_WARP Then
            mapNum = .Data1
            X = .Data2
            Y = .Data3
            Call PlayerWarp(index, mapNum, X, Y)
            Moved = YES
        End If
    
        ' Check to see if the tile is a door tile, and if so warp them
        If .Type = TILE_TYPE_DOOR Then
            mapNum = .Data1
            X = .Data2
            Y = .Data3
            ' send the animation to the map
            SendDoorAnimation GetPlayerMap(index), GetPlayerX(index), GetPlayerY(index)
            Call PlayerWarp(index, mapNum, X, Y)
            Moved = YES
        End If
    
        If .Type = TILE_TYPE_SCRIPT Then
            ScriptedTile index, .Data1
            Moved = YES
         End If
    
        ' Check for key trigger open
        If .Type = TILE_TYPE_KEYOPEN Then
            X = .Data1
            Y = .Data2
    
            If Map(GetPlayerMap(index)).Tile(X, Y).Type = TILE_TYPE_KEY And TempTile(GetPlayerMap(index)).DoorOpen(X, Y) = NO Then
                TempTile(GetPlayerMap(index)).DoorOpen(X, Y) = YES
                TempTile(GetPlayerMap(index)).DoorTimer = GetTickCount
                SendMapKey index, X, Y, 1
                Call MapMsg(GetPlayerMap(index), "Uma porta foi aberta.", White)
            End If
        End If
        
        ' Check for a shop, and if so open it
        If .Type = TILE_TYPE_SHOP Then
            X = .Data1
            If X > 0 Then ' shop exists?
                If Len(Trim$(Shop(X).Name)) > 0 Then ' name exists?
                    SendOpenShop index, X
                    TempPlayer(index).InShop = X ' stops movement and the like
                End If
            End If
        End If
        
        ' Check to see if the tile is a bank, and if so send bank
        If .Type = TILE_TYPE_BANK Then
            SendBank index
            TempPlayer(index).InBank = True
            Moved = YES
        End If
        
        ' Check if it's a heal tile
        If .Type = TILE_TYPE_HEAL Then
            VitalType = .Data1
            amount = .Data2
            If Not GetPlayerVital(index, VitalType) = GetPlayerMaxVital(index, VitalType) Then
                If VitalType = Vitals.HP Then
                    Colour = BrightGreen
                Else
                    Colour = BrightBlue
                End If
                SendActionMsg GetPlayerMap(index), "+" & amount, Colour, ACTIONMSG_SCROLL, GetPlayerX(index) * 32, GetPlayerY(index) * 32, 1
                SetPlayerVital index, VitalType, GetPlayerVital(index, VitalType) + amount
                PlayerMsg index, "Você se sente revigorado!", BrightGreen
                Call SendVital(index, VitalType)
                ' send vitals to party if in one
                If TempPlayer(index).inParty > 0 Then SendPartyVitals TempPlayer(index).inParty, index
            End If
            Moved = YES
        End If
        
        ' Check if it's a trap tile
        If .Type = TILE_TYPE_TRAP Then
            amount = .Data1
            SendActionMsg GetPlayerMap(index), "-" & amount, BrightRed, ACTIONMSG_SCROLL, GetPlayerX(index) * 32, GetPlayerY(index) * 32, 1
            If GetPlayerVital(index, HP) - amount <= 0 Then
                KillPlayer index
                PlayerMsg index, "Você foi pego por uma armadilha!", BrightRed
            Else
                SetPlayerVital index, HP, GetPlayerVital(index, HP) - amount
                PlayerMsg index, "Você caiu em uma armadilha!", BrightRed
                Call SendVital(index, HP)
                ' send vitals to party if in one
                If TempPlayer(index).inParty > 0 Then SendPartyVitals TempPlayer(index).inParty, index
            End If
            Moved = YES
        End If
        
        ' Slide
        If .Type = TILE_TYPE_SLIDE Then
            ForcePlayerMove index, MOVING_WALKING, GetPlayerDir(index)
            Moved = YES
        End If
    End With

    ' They tried to hack
    If Moved = NO Then
        PlayerWarp index, GetPlayerMap(index), GetPlayerX(index), GetPlayerY(index)
    End If

End Sub

Sub ForcePlayerMove(ByVal index As Long, ByVal movement As Long, ByVal Direction As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If IsPlaying(index) = False Then Exit Sub
    
    If Direction < DIR_UP Or Direction > DIR_RIGHT Then Exit Sub
    If movement < 1 Or movement > 2 Then Exit Sub
    
    Select Case Direction
        Case DIR_UP
            If GetPlayerY(index) = 0 Then Exit Sub
        Case DIR_LEFT
            If GetPlayerX(index) = 0 Then Exit Sub
        Case DIR_DOWN
            If GetPlayerY(index) = Map(GetPlayerMap(index)).MaxY Then Exit Sub
        Case DIR_RIGHT
            If GetPlayerX(index) = Map(GetPlayerMap(index)).MaxX Then Exit Sub
    End Select
    
    PlayerMove index, Direction, movement, True
End Sub

Sub CheckEquippedItems(ByVal index As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If IsPlaying(index) = False Then Exit Sub
    
    Dim Slot As Long
    Dim ItemNum As Long
    Dim i As Long

    ' We want to check incase an admin takes away an object but they had it equipped
    For i = 1 To Equipment.Equipment_Count - 1
        ItemNum = GetPlayerEquipment(index, i)

        If ItemNum > 0 Then

            Select Case i
                Case Equipment.Weapon

                    If Item(ItemNum).Type <> ITEM_TYPE_WEAPON Then SetPlayerEquipment index, 0, i
                Case Equipment.Armor

                    If Item(ItemNum).Type <> ITEM_TYPE_ARMOR Then SetPlayerEquipment index, 0, i
                Case Equipment.Helmet

                    If Item(ItemNum).Type <> ITEM_TYPE_HELMET Then SetPlayerEquipment index, 0, i
                Case Equipment.Shield

                    If Item(ItemNum).Type <> ITEM_TYPE_SHIELD Then SetPlayerEquipment index, 0, i
            End Select

        Else
            SetPlayerEquipment index, 0, i
        End If

    Next

End Sub

Function FindOpenInvSlot(ByVal index As Long, ByVal ItemNum As Long) As Long
If index < 1 Or index > MAX_PLAYERS Then Exit Function
If IsPlaying(index) = False Then Exit Function
    
    Dim i As Long

    ' Check for subscript out of range
    If IsPlaying(index) = False Or ItemNum <= 0 Or ItemNum > MAX_ITEMS Then
        Exit Function
    End If

    If Item(ItemNum).Type = ITEM_TYPE_CURRENCY Then

        ' If currency then check to see if they already have an instance of the item and add it to that
        For i = 1 To MAX_INV

            If GetPlayerInvItemNum(index, i) = ItemNum Then
                FindOpenInvSlot = i
                Exit Function
            End If

        Next

    End If

    For i = 1 To MAX_INV

        ' Try to find an open free slot
        If GetPlayerInvItemNum(index, i) = 0 Then
            FindOpenInvSlot = i
            Exit Function
        End If

    Next

End Function

Function FindOpenBankSlot(ByVal index As Long, ByVal ItemNum As Long) As Long
If index < 1 Or index > MAX_PLAYERS Then Exit Function
If IsPlaying(index) = False Then Exit Function
    
    Dim i As Long

    If Not IsPlaying(index) Then Exit Function
    If ItemNum <= 0 Or ItemNum > MAX_ITEMS Then Exit Function

        For i = 1 To MAX_BANK
            If GetPlayerBankItemNum(index, i) = ItemNum Then
                FindOpenBankSlot = i
                Exit Function
            End If
        Next i

    For i = 1 To MAX_BANK
        If GetPlayerBankItemNum(index, i) = 0 Then
            FindOpenBankSlot = i
            Exit Function
        End If
    Next i

End Function

Function HasItem(ByVal index As Long, ByVal ItemNum As Long) As Long
If index < 1 Or index > MAX_PLAYERS Then Exit Function
If IsPlaying(index) = False Then Exit Function

    Dim i As Long

    ' Check for subscript out of range
    If IsPlaying(index) = False Or ItemNum <= 0 Or ItemNum > MAX_ITEMS Then
        Exit Function
    End If

    For i = 1 To MAX_INV

        ' Check to see if the player has the item
        If GetPlayerInvItemNum(index, i) = ItemNum Then
            If Item(ItemNum).Type = ITEM_TYPE_CURRENCY Then
                HasItem = GetPlayerInvItemValue(index, i)
            Else
                HasItem = 1
            End If

            Exit Function
        End If

    Next

End Function

Function TakeInvItem(ByVal index As Long, ByVal ItemNum As Long, ByVal ItemVal As Long) As Boolean
If index < 1 Or index > MAX_PLAYERS Then Exit Function
If IsPlaying(index) = False Then Exit Function
    
    Dim i As Long
    Dim n As Long
    'On Error Resume Next
    TakeInvItem = False

    ' Check for subscript out of range
    If IsPlaying(index) = False Or ItemNum <= 0 Or ItemNum > MAX_ITEMS Then
        Exit Function
    End If

    For i = 1 To MAX_INV

        ' Check to see if the player has the item
        If GetPlayerInvItemNum(index, i) = ItemNum Then
            If Item(ItemNum).Type = ITEM_TYPE_CURRENCY Then

                ' Is what we are trying to take away more then what they have?  If so just set it to zero
                If ItemVal >= GetPlayerInvItemValue(index, i) Then
                    TakeInvItem = True
                Else
                    Call SetPlayerInvItemValue(index, i, GetPlayerInvItemValue(index, i) - ItemVal)
                    Call SendInventoryUpdate(index, i)
                End If
            Else
                TakeInvItem = True
            End If

            If TakeInvItem Then
                Call SetPlayerInvItemNum(index, i, 0)
                Call SetPlayerInvItemValue(index, i, 0)
                ' Send the inventory update
                Call SendInventoryUpdate(index, i)
                Exit Function
            End If
        End If

    Next

End Function

Function TakeInvSlot(ByVal index As Long, ByVal invSlot As Long, ByVal ItemVal As Long) As Boolean
If index < 1 Or index > MAX_PLAYERS Then Exit Function
If IsPlaying(index) = False Then Exit Function
    
    Dim i As Long
    Dim n As Long
    Dim ItemNum
    
    TakeInvSlot = False

    ' Check for subscript out of range
    If IsPlaying(index) = False Or invSlot <= 0 Or invSlot > MAX_ITEMS Then
        Exit Function
    End If
    
    ItemNum = GetPlayerInvItemNum(index, invSlot)

    If Item(ItemNum).Type = ITEM_TYPE_CURRENCY Then

        ' Is what we are trying to take away more then what they have?  If so just set it to zero
        If ItemVal >= GetPlayerInvItemValue(index, invSlot) Then
            TakeInvSlot = True
        Else
            Call SetPlayerInvItemValue(index, invSlot, GetPlayerInvItemValue(index, invSlot) - ItemVal)
        End If
    Else
        TakeInvSlot = True
    End If

    If TakeInvSlot Then
        Call SetPlayerInvItemNum(index, invSlot, 0)
        Call SetPlayerInvItemValue(index, invSlot, 0)
        Exit Function
    End If

End Function

Function GiveInvItem(ByVal index As Long, ByVal ItemNum As Long, ByVal ItemVal As Long, Optional ByVal sendUpdate As Boolean = True) As Boolean
If index < 1 Or index > MAX_PLAYERS Then Exit Function
If IsPlaying(index) = False Then Exit Function
    
    Dim i As Long

    ' Check for subscript out of range
    If IsPlaying(index) = False Or ItemNum <= 0 Or ItemNum > MAX_ITEMS Then
        GiveInvItem = False
        Exit Function
    End If

    i = FindOpenInvSlot(index, ItemNum)

    ' Check to see if inventory is full
    If i <> 0 Then
        Call SetPlayerInvItemNum(index, i, ItemNum)
        Call SetPlayerInvItemValue(index, i, GetPlayerInvItemValue(index, i) + ItemVal)
        If sendUpdate Then Call SendInventoryUpdate(index, i)
        GiveInvItem = True
    Else
        Call PlayerMsg(index, "Sua mochila está cheia", BrightRed)
        GiveInvItem = False
    End If

End Function

Function HasSpell(ByVal index As Long, ByVal SpellNum As Long) As Boolean
If index < 1 Or index > MAX_PLAYERS Then Exit Function
If IsPlaying(index) = False Then Exit Function
If SpellNum < 1 Or SpellNum > MAX_SPELLS Then Exit Function

    
    Dim i As Long

    For i = 1 To MAX_PLAYER_SPELLS

        If GetPlayerSpell(index, i) = SpellNum Then
            HasSpell = True
            Exit Function
        End If

    Next

End Function

Function FindOpenSpellSlot(ByVal index As Long) As Long
If index < 1 Or index > MAX_PLAYERS Then Exit Function
If IsPlaying(index) = False Then Exit Function

    Dim i As Long

    For i = 1 To MAX_PLAYER_SPELLS

        If GetPlayerSpell(index, i) = 0 Then
            FindOpenSpellSlot = i
            Exit Function
        End If

    Next

End Function

Sub PlayerMapGetItem(ByVal index As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If IsPlaying(index) = False Then Exit Sub

    Dim i As Long
    Dim n As Long
    Dim mapNum As Long
    Dim Msg As String
'On Error Resume Next
    If Not IsPlaying(index) Then Exit Sub
    mapNum = GetPlayerMap(index)

    For i = 1 To MAX_MAP_ITEMS
        ' See if theres even an item here
        If (MapItem(mapNum, i).num > 0) And (MapItem(mapNum, i).num <= MAX_ITEMS) Then
            ' our drop?
            If CanPlayerPickupItem(index, i) Then
                ' Check if item is at the same location as the player
                If (MapItem(mapNum, i).X = GetPlayerX(index)) Then
                    If (MapItem(mapNum, i).Y = GetPlayerY(index)) Then
                        ' Find open slot
                        n = FindOpenInvSlot(index, MapItem(mapNum, i).num)
    
                        ' Open slot available?
                        If n <> 0 Then
                            ' Set item in players inventor
                            Call SetPlayerInvItemNum(index, n, MapItem(mapNum, i).num)
    
                            If Item(GetPlayerInvItemNum(index, n)).Type = ITEM_TYPE_CURRENCY Then
                                Call SetPlayerInvItemValue(index, n, GetPlayerInvItemValue(index, n) + MapItem(mapNum, i).Value)
                                Msg = MapItem(mapNum, i).Value & " " & Trim$(Item(GetPlayerInvItemNum(index, n)).Name)
                            Else
                                Call SetPlayerInvItemValue(index, n, 0)
                                Msg = Trim$(Item(GetPlayerInvItemNum(index, n)).Name)
                            End If
    
                            Dim questSlot As Byte
                            For questSlot = 1 To 10
                                If Player(index).QuestNum(questSlot) > 0 Then
                                   If Quest(Player(index).QuestNum(questSlot)).Tipo = QUEST_TYPE_ITEM Then
                                      CheckQuestItem index, MapItem(mapNum, i).num, questSlot
                                   End If
                                End If
                            Next
    
                            ' Erase item from the map
                            ClearMapItem i, mapNum
                            
                            Call SendInventoryUpdate(index, n)
                            Call SpawnItemSlot(i, 0, 0, GetPlayerMap(index), 0, 0)
                            SendActionMsg GetPlayerMap(index), Msg, White, 1, (GetPlayerX(index) * 32), (GetPlayerY(index) * 32)
                            Exit For
                        Else
                            Call PlayerMsg(index, "Sua Mochila está cheia!", BrightRed)
                            Exit For
                        End If
                    End If
                End If
            End If
        End If
    Next
End Sub

Function CanPlayerPickupItem(ByVal index As Long, ByVal mapItemNum As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Function
If IsPlaying(index) = False Then Exit Function

Dim mapNum As Long
'On Error Resume Next
    mapNum = GetPlayerMap(index)
    
    ' no lock or locked to player?
    If MapItem(mapNum, mapItemNum).playerName = vbNullString Or MapItem(mapNum, mapItemNum).playerName = Trim$(GetPlayerName(index)) Then
        CanPlayerPickupItem = True
        Exit Function
    End If
    
    CanPlayerPickupItem = False
End Function

Sub PlayerMapDropItem(ByVal index As Long, ByVal invNum As Long, ByVal amount As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If IsPlaying(index) = False Then Exit Sub
Dim ItemNum As Long
    Dim i As Long
'On Error Resume Next
    ' Check for subscript out of range
    If IsPlaying(index) = False Or invNum <= 0 Or invNum > MAX_INV Then
        Exit Sub
    End If
    
    ' check the player isn't doing something
    If TempPlayer(index).InBank Or TempPlayer(index).InShop Or TempPlayer(index).InTrade > 0 Then Exit Sub

ItemNum = GetPlayerInvItemNum(index, invNum)
    If ItemNum >= 200 And ItemNum <= 230 Then
        If Not GetPlayerAccess(index) = ADMIN_CREATOR Then
            PlayerMsg index, "Não pôde dropar o item!", BrightRed
            Exit Sub
        End If
    End If
    
    If (GetPlayerInvItemNum(index, invNum) > 0) Then
        If (GetPlayerInvItemNum(index, invNum) <= MAX_ITEMS) Then
            i = FindOpenMapItemSlot(GetPlayerMap(index))

            If i <> 0 Then
                MapItem(GetPlayerMap(index), i).num = GetPlayerInvItemNum(index, invNum)
                MapItem(GetPlayerMap(index), i).X = GetPlayerX(index)
                MapItem(GetPlayerMap(index), i).Y = GetPlayerY(index)
                MapItem(GetPlayerMap(index), i).playerName = Trim$(GetPlayerName(index))
                MapItem(GetPlayerMap(index), i).playerTimer = GetTickCount + ITEM_SPAWN_TIME
                MapItem(GetPlayerMap(index), i).canDespawn = True
                MapItem(GetPlayerMap(index), i).despawnTimer = GetTickCount + ITEM_DESPAWN_TIME

                If Item(GetPlayerInvItemNum(index, invNum)).Type = ITEM_TYPE_CURRENCY Then
                
                If GetPlayerInvItemNum(index, invNum) >= 21 And GetPlayerInvItemNum(index, invNum) <= 44 Then
                    PlayerMsg index, "Não pode dropar jutsus elementais", BrightCyan
                    Exit Sub
                End If
                
                    ' Check if its more then they have and if so drop it all
                    If amount >= GetPlayerInvItemValue(index, invNum) Then
                        MapItem(GetPlayerMap(index), i).Value = GetPlayerInvItemValue(index, invNum)
                        Call MapMsg(GetPlayerMap(index), GetPlayerName(index) & " largou " & GetPlayerInvItemValue(index, invNum) & " " & Trim$(Item(GetPlayerInvItemNum(index, invNum)).Name) & ".", Yellow)
                        Call SetPlayerInvItemNum(index, invNum, 0)
                        Call SetPlayerInvItemValue(index, invNum, 0)
                    Else
                        MapItem(GetPlayerMap(index), i).Value = amount
                        Call MapMsg(GetPlayerMap(index), GetPlayerName(index) & " largou " & amount & " " & Trim$(Item(GetPlayerInvItemNum(index, invNum)).Name) & ".", Yellow)
                        Call SetPlayerInvItemValue(index, invNum, GetPlayerInvItemValue(index, invNum) - amount)
                    End If

                Else
                    ' Its not a currency object so this is easy
                    MapItem(GetPlayerMap(index), i).Value = 0
                    ' send message
                    Call MapMsg(GetPlayerMap(index), GetPlayerName(index) & " largou " & CheckGrammar(Trim$(Item(GetPlayerInvItemNum(index, invNum)).Name)) & ".", Yellow)
                    Call SetPlayerInvItemNum(index, invNum, 0)
                    Call SetPlayerInvItemValue(index, invNum, 0)
                End If

                ' Send inventory update
                Call SendInventoryUpdate(index, invNum)
                ' Spawn the item before we set the num or we'll get a different free map item slot
                Call SpawnItemSlot(i, MapItem(GetPlayerMap(index), i).num, amount, GetPlayerMap(index), GetPlayerX(index), GetPlayerY(index), Trim$(GetPlayerName(index)), MapItem(GetPlayerMap(index), i).canDespawn)
            Else
                Call PlayerMsg(index, "Já há muitos itens no chão..", BrightRed)
            End If
        End If
    End If

End Sub

Sub CheckPlayerLevelUp(ByVal index As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If IsPlaying(index) = False Then Exit Sub
SendTopPic index
    Dim i As Long
    Dim expRollover As Long
    Dim level_count As Long
    'On Error Resume Next
    level_count = 0
    
    Do While GetPlayerExp(index) >= GetPlayerNextLevel(index)
        expRollover = GetPlayerExp(index) - GetPlayerNextLevel(index)
        
        ' can level up?
        TempPlayer(index).SetLevel = YES
        If Not SetPlayerLevel(index, GetPlayerLevel(index) + 1) Then
            Exit Sub
        End If
        
        TempPlayer(index).SetPoints = YES
        If GetPlayerLevel(index) >= 1000 Then
            Call SetPlayerPOINTS(index, GetPlayerPOINTS(index) + 10)
        Else
            Call SetPlayerPOINTS(index, GetPlayerPOINTS(index) + 5)
        End If
        TempPlayer(index).SetExp = YES
        Call SetPlayerExp(index, expRollover)
        level_count = level_count + 1
    Loop
    
    If level_count > 0 Then
        'If level_count = 1 Then
            'singular
            'GlobalMsg GetPlayerName(index) & " has gained " & level_count & " level!", Brown
        'Else
            'plural
            'GlobalMsg GetPlayerName(index) & " has gained " & level_count & " levels!", Brown
        'End If
        
        CheckQuestLevel index
        CheckLevelSkill index
        
        AtualizarTop index
        
        SetPlayerVital index, Vitals.HP, GetPlayerMaxVital(index, Vitals.HP)
        SetPlayerVital index, Vitals.mp, GetPlayerMaxVital(index, Vitals.mp)
        SendVital index, Vitals.HP
        SendVital index, Vitals.mp
        
        If GetPlayerLevel(index) = 30 Then
            TempPlayer(index).SetPoints = YES
            SetPlayerPOINTS index, GetPlayerPOINTS(index) + 30
            PlayerMsg index, "Você evoluiu !Ganhou 30 Pontos.", BrightCyan
            PlayerMsg index, "Agora você pode usar Transformação nível 1.", White
        End If
        
        If GetPlayerLevel(index) = 50 Then
            TempPlayer(index).SetPoints = YES
            SetPlayerPOINTS index, GetPlayerPOINTS(index) + 50
            PlayerMsg index, "Você evoluiu !Ganhou 50 Pontos.", BrightCyan
            PlayerMsg index, "Agora você pode usar Transformação nível 2.", White
        End If
        
        If GetPlayerLevel(index) = 80 Then
            TempPlayer(index).SetPoints = YES
            SetPlayerPOINTS index, GetPlayerPOINTS(index) + 80
            PlayerMsg index, "Você evoluiu !Ganhou 80 Pontos.", BrightCyan
            PlayerMsg index, "Agora você pode usar Transformação nível 3.", White
        End If
        
        If GetPlayerLevel(index) = 120 Then
            TempPlayer(index).SetPoints = YES
            SetPlayerPOINTS index, GetPlayerPOINTS(index) + 120
            PlayerMsg index, "Você evoluiu !Ganhou 120 Pontos.", BrightCyan
            If GetPlayerClass(index) = 1 Or GetPlayerClass(index) = 2 Then
                PlayerMsg index, "Agora você pode usar Transformação nível 4.", White
            End If
        End If
        
        If GetPlayerLevel(index) = 150 Then
            TempPlayer(index).SetPoints = YES
            SetPlayerPOINTS index, GetPlayerPOINTS(index) + 150
            PlayerMsg index, "Você evoluiu !Ganhou 150 Pontos.", BrightCyan
            If GetPlayerClass(index) = 1 Or GetPlayerClass(index) = 2 Then
                If Player(index).VipData.VIP > 0 Then
                    PlayerMsg index, "Agora você pode usar Transformação nível 5.", White
                End If
            End If
        End If
        
        If GetPlayerLevel(index) = 180 Then
            TempPlayer(index).SetPoints = YES
            SetPlayerPOINTS index, GetPlayerPOINTS(index) + 180
            PlayerMsg index, "Você evoluiu !Ganhou 180 Pontos.", BrightCyan
            If GetPlayerClass(index) = 1 Then
                If Player(index).VipData.VIP > 0 Then
                    PlayerMsg index, "Agora você pode usar Transformação nível 6.", White
                End If
            End If
        End If
        
        SendEXP index
        SendPlayerData index
    End If
End Sub

' //////////////////////
' // PLAYER FUNCTIONS //
' //////////////////////
Function GetPlayerLogin(ByVal index As Long) As String
'If index < 1 Or index > MAX_PLAYERS Then Exit Function

    GetPlayerLogin = Trim$(Player(index).Login)
End Function

Sub SetPlayerLogin(ByVal index As Long, ByVal Login As String)
'If index < 1 Or index > MAX_PLAYERS Then Exit Sub

    Player(index).Login = Login
End Sub

Function GetPlayerPassword(ByVal index As Long) As String
'If index < 1 Or index > MAX_PLAYERS Then Exit Function
    GetPlayerPassword = Trim$(Player(index).Password)
End Function

Sub SetPlayerPassword(ByVal index As Long, ByVal Password As String)
'If index < 1 Or index > MAX_PLAYERS Then Exit Sub
    Player(index).Password = Password
End Sub

Function GetPlayerName(ByVal index As Long) As String
If index < 1 Or index > MAX_PLAYERS Then Exit Function
    If index > MAX_PLAYERS Then Exit Function
    GetPlayerName = Trim$(Player(index).Name)
End Function

Sub SetPlayerName(ByVal index As Long, ByVal Name As String)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub

    Player(index).Name = Name
End Sub

Function GetPlayerClass(ByVal index As Long) As Long
If index < 1 Or index > MAX_PLAYERS Then Exit Function

    GetPlayerClass = Player(index).Class
End Function

Sub SetPlayerClass(ByVal index As Long, ByVal ClassNum As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub

    Player(index).Class = ClassNum
End Sub

Function GetPlayerSprite(ByVal index As Long) As Long
If index < 1 Or index > MAX_PLAYERS Then Exit Function

    If index > MAX_PLAYERS Then Exit Function
    GetPlayerSprite = Player(index).Sprite
End Function

Sub SetPlayerSprite(ByVal index As Long, ByVal Sprite As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub

    Player(index).Sprite = Sprite
End Sub

Function GetPlayerLevel(ByVal index As Long) As Long
If index < 1 Or index > MAX_PLAYERS Then Exit Function

    If index > MAX_PLAYERS Then Exit Function
    GetPlayerLevel = Player(index).Level
End Function

Function SetPlayerLevel(ByVal index As Long, ByVal Level As Long) As Boolean
If index < 1 Or index > MAX_PLAYERS Then Exit Function
If Not TempPlayer(index).SetLevel = YES Then Exit Function
    TempPlayer(index).SetLevel = NO
    SetPlayerLevel = False
    If Level > MAX_LEVELS Then Exit Function
    Player(index).Level = Level
    SetPlayerLevel = True
End Function

Function GetPlayerNextLevel(ByVal index As Long) As Long
On Error Resume Next
If index < 1 Or index > MAX_PLAYERS Then Exit Function

    GetPlayerNextLevel = (1 / 3) * ((GetPlayerLevel(index) + 1) ^ 3 - (2 * (GetPlayerLevel(index) / 3) ^ 2) + 17 * (GetPlayerLevel(index) / 6) - 12)
    If GetPlayerNextLevel < 1 Then GetPlayerNextLevel = 1

End Function

Function GetPlayerExp(ByVal index As Long) As Long
If index < 1 Or index > MAX_PLAYERS Then Exit Function

    GetPlayerExp = Player(index).EXP
End Function

Sub SetPlayerExp(ByVal index As Long, ByVal EXP As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If Not TempPlayer(index).SetExp = YES Then Exit Sub

    TempPlayer(index).SetExp = NO
    Player(index).EXP = EXP
End Sub

Function GetPlayerAccess(ByVal index As Long) As Long
If index < 1 Or index > MAX_PLAYERS Then Exit Function

    If index > MAX_PLAYERS Then Exit Function
    GetPlayerAccess = Player(index).Access
End Function

Sub SetPlayerAccess(ByVal index As Long, ByVal Access As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub

    Player(index).Access = Access
End Sub

Function GetPlayerPK(ByVal index As Long) As Long
If index < 1 Or index > MAX_PLAYERS Then Exit Function

    If index > MAX_PLAYERS Then Exit Function
    GetPlayerPK = Player(index).PK
End Function

Sub SetPlayerPK(ByVal index As Long, ByVal PK As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub

    Player(index).PK = PK
End Sub

Function GetPlayerVital(ByVal index As Long, ByVal Vital As Vitals) As Long
If index < 1 Or index > MAX_PLAYERS Then Exit Function

    If index > MAX_PLAYERS Then Exit Function
    GetPlayerVital = Player(index).Vital(Vital)
End Function

Sub SetPlayerVital(ByVal index As Long, ByVal Vital As Vitals, ByVal Value As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub

    Player(index).Vital(Vital) = Value

    If GetPlayerVital(index, Vital) > GetPlayerMaxVital(index, Vital) Then
        Player(index).Vital(Vital) = GetPlayerMaxVital(index, Vital)
    End If

    If GetPlayerVital(index, Vital) < 0 Then
        Player(index).Vital(Vital) = 0
    End If

End Sub

Public Function GetPlayerStat(ByVal index As Long, ByVal Stat As Stats) As Long
If index < 1 Or index > MAX_PLAYERS Then Exit Function
    Dim X As Long, i As Long
    If index > MAX_PLAYERS Then Exit Function
    
    X = Player(index).Stat(Stat)
    
    For i = 1 To Equipment.Equipment_Count - 1
        If Player(index).Equipment(i) > 0 Then
            If Item(Player(index).Equipment(i)).Add_Stat(Stat) > 0 Then
                X = X + Item(Player(index).Equipment(i)).Add_Stat(Stat)
            End If
        End If
    Next
    
    GetPlayerStat = X
End Function

Public Function GetPlayerRawStat(ByVal index As Long, ByVal Stat As Stats) As Long
If index < 1 Or index > MAX_PLAYERS Then Exit Function

    If index > MAX_PLAYERS Then Exit Function
    
    GetPlayerRawStat = Player(index).Stat(Stat)
End Function

Public Sub SetPlayerStat(ByVal index As Long, ByVal Stat As Stats, ByVal Value As Long)
    If index < 1 Or index > MAX_PLAYERS Then Exit Sub
    
    Player(index).Stat(Stat) = Value
End Sub

Function GetPlayerPOINTS(ByVal index As Long) As Long
If index < 1 Or index > MAX_PLAYERS Then Exit Function

    If index > MAX_PLAYERS Then Exit Function
    GetPlayerPOINTS = Player(index).POINTS
End Function

Sub SetPlayerPOINTS(ByVal index As Long, ByVal POINTS As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If Not TempPlayer(index).SetPoints = YES Then Exit Sub
    TempPlayer(index).SetPoints = NO
    If POINTS <= 0 Then POINTS = 0
    Player(index).POINTS = POINTS
End Sub

Function GetPlayerMap(ByVal index As Long) As Long
If index < 1 Or index > MAX_PLAYERS Then Exit Function

    If index > MAX_PLAYERS Then Exit Function
    GetPlayerMap = Player(index).Map
End Function

Sub SetPlayerMap(ByVal index As Long, ByVal mapNum As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub

    If mapNum > 0 And mapNum <= MAX_MAPS Then
        Player(index).Map = mapNum
    End If

End Sub

Function GetPlayerX(ByVal index As Long) As Long
If index < 1 Or index > MAX_PLAYERS Then Exit Function

    If index > MAX_PLAYERS Then Exit Function
    GetPlayerX = Player(index).X
End Function

Sub SetPlayerX(ByVal index As Long, ByVal X As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub

    Player(index).X = X
End Sub

Function GetPlayerY(ByVal index As Long) As Long
If index < 1 Or index > MAX_PLAYERS Then Exit Function

    If index > MAX_PLAYERS Then Exit Function
    GetPlayerY = Player(index).Y
End Function

Sub SetPlayerY(ByVal index As Long, ByVal Y As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub

    Player(index).Y = Y
End Sub

Function GetPlayerDir(ByVal index As Long) As Long
If index < 1 Or index > MAX_PLAYERS Then Exit Function

    If index > MAX_PLAYERS Then Exit Function
    GetPlayerDir = Player(index).Dir
End Function

Sub SetPlayerDir(ByVal index As Long, ByVal Dir As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub

    Player(index).Dir = Dir
End Sub

Function GetPlayerIP(ByVal index As Long) As String
If index < 1 Or index > MAX_PLAYERS Then Exit Function

    If index > MAX_PLAYERS Then Exit Function
    GetPlayerIP = frmServer.Socket(index).RemoteHostIP
End Function

Function GetPlayerInvItemNum(ByVal index As Long, ByVal invSlot As Long) As Long
On Error Resume Next
If index < 1 Or index > MAX_PLAYERS Then Exit Function

    If index > MAX_PLAYERS Then Exit Function
    If invSlot = 0 Then Exit Function
    
    GetPlayerInvItemNum = Player(index).Inv(invSlot).num
End Function

Sub SetPlayerInvItemNum(ByVal index As Long, ByVal invSlot As Long, ByVal ItemNum As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub

    Player(index).Inv(invSlot).num = ItemNum
End Sub

Function GetPlayerInvItemValue(ByVal index As Long, ByVal invSlot As Long) As Long
On Error Resume Next
If index < 1 Or index > MAX_PLAYERS Then Exit Function

    If index > MAX_PLAYERS Then Exit Function
    GetPlayerInvItemValue = Player(index).Inv(invSlot).Value
End Function

Sub SetPlayerInvItemValue(ByVal index As Long, ByVal invSlot As Long, ByVal ItemValue As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub

    Player(index).Inv(invSlot).Value = ItemValue
End Sub

Function GetPlayerSpell(ByVal index As Long, ByVal spellslot As Long) As Long
If index < 1 Or index > MAX_PLAYERS Then Exit Function

    If index > MAX_PLAYERS Then Exit Function
    GetPlayerSpell = Player(index).Spell(spellslot)
End Function

Sub SetPlayerSpell(ByVal index As Long, ByVal spellslot As Long, ByVal SpellNum As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub

    Player(index).Spell(spellslot) = SpellNum
End Sub

Function GetPlayerEquipment(ByVal index As Long, ByVal EquipmentSlot As Equipment) As Long
If index < 1 Or index > MAX_PLAYERS Then Exit Function

    If index > MAX_PLAYERS Then Exit Function
    If EquipmentSlot = 0 Then Exit Function
    GetPlayerEquipment = Player(index).Equipment(EquipmentSlot)
End Function

Sub SetPlayerEquipment(ByVal index As Long, ByVal invNum As Long, ByVal EquipmentSlot As Equipment)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub

    Player(index).Equipment(EquipmentSlot) = invNum
End Sub

' ToDo
Sub OnDeath(ByVal index As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If IsPlaying(index) = False Then Exit Sub
    'On Error Resume Next
    Dim Desafiando As Byte
    Dim i As Long
    
    If TempPlayer(index).IsDesafio = YES Then
        ZerarDesafio TempPlayer(index).InDesafio, index
        Desafiando = YES
    End If
    
    If Torneio = "cs" Then
    If TempPlayer(index).InTorneio = YES Then
        For i = 1 To MAX_INV
            If GetPlayerInvItemNum(index, i) = 219 Then
                TakeItem index, 219, 1
            End If
        
        Next
        
        PlayerMsg index, "Você foi desqualificado do Chunin Shiken.", DarkGrey
        SpawnItem 219, 1, GetPlayerMap(index), GetPlayerX(index), GetPlayerY(index)
    End If
 End If
 
    TempPlayer(index).InTorneio = NO
    
For i = 1 To 10
    If Player(index).QuestNum(i) > 0 Then
        If Player(index).QuestNum(i) = 47 Or Player(index).QuestNum(i) = 48 Or Player(index).QuestNum(i) = 49 Then
            Exit For
            ClearQuestSlot index, i
            PlayerMsg index, "Seu teste pra Org foi cancelado.. Perdedor!", BrightRed
        End If
    End If
Next
    ' Set HP to nothing
    Call SetPlayerVital(index, Vitals.HP, 0)

    If Player(index).VIP < 1 Then
        If RAND(1, 3) = 1 Then
            ' Drop all worn items
            For i = 1 To Equipment.Equipment_Count - 1
                If GetPlayerEquipment(index, i) > 0 Then
                    PlayerMapDropItem index, GetPlayerEquipment(index, i), 0
                End If
            Next
        End If
    End If

    ' Warp player away
    Call SetPlayerDir(index, DIR_DOWN)
    
    If Desafiando = NO Then 'se tivesse desafiado,ele voltaria pro atendimento
        With Map(GetPlayerMap(index))
            ' to the bootmap if it is set
            If .BootMap > 0 Then
                PlayerWarp index, .BootMap, .BootX, .BootY
            Else
                Call PlayerWarp(index, START_MAP(1), START_X(1), START_Y(1))
            End If
        End With
    End If
    
    ' clear all DoTs and HoTs
    For i = 1 To MAX_DOTS
        With TempPlayer(index).DoT(i)
            .Used = False
            .Spell = 0
            .Timer = 0
            .Caster = 0
            .StartTime = 0
        End With
        
        With TempPlayer(index).HoT(i)
            .Used = False
            .Spell = 0
            .Timer = 0
            .Caster = 0
            .StartTime = 0
        End With
    Next
    
    ' Clear spell casting
    TempPlayer(index).spellBuffer.Spell = 0
    TempPlayer(index).spellBuffer.Timer = 0
    TempPlayer(index).spellBuffer.Target = 0
    TempPlayer(index).spellBuffer.tType = 0
    Call SendClearSpellBuffer(index)
    
    ' Restore vitals
    Call SetPlayerVital(index, Vitals.HP, GetPlayerMaxVital(index, Vitals.HP))
    Call SetPlayerVital(index, Vitals.mp, GetPlayerMaxVital(index, Vitals.mp))
    Call SendVital(index, Vitals.HP)
    Call SendVital(index, Vitals.mp)
    ' send vitals to party if in one
    If TempPlayer(index).inParty > 0 Then SendPartyVitals TempPlayer(index).inParty, index

    ' If the player the attacker killed was a pk then take it away
    If GetPlayerPK(index) = YES Then
        Call SetPlayerPK(index, NO)
        Call SendPlayerData(index)
    End If

End Sub

Sub CheckResource(ByVal index As Long, ByVal X As Long, ByVal Y As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
    On Error Resume Next
    Dim Resource_num As Long
    Dim Resource_index As Long
    Dim rX As Long, rY As Long
    Dim i As Long
    Dim Damage As Long
    Dim questSlot As Byte
    Dim EXP As Long
    
    If Map(GetPlayerMap(index)).Tile(X, Y).Type = TILE_TYPE_RESOURCE Then
        Resource_num = 0
        Resource_index = Map(GetPlayerMap(index)).Tile(X, Y).Data1

        ' Get the cache number
        For i = 0 To ResourceCache(GetPlayerMap(index)).Resource_Count

            If ResourceCache(GetPlayerMap(index)).ResourceData(i).X = X Then
                If ResourceCache(GetPlayerMap(index)).ResourceData(i).Y = Y Then
                    Resource_num = i
                End If
            End If

        Next

        If Resource_num > 0 Then
            If Resource_index > 0 Then
            If Resource(Resource_index).ToolRequired > 0 Then
            If Not GetPlayerEquipment(index, Weapon) > 0 Then
                PlayerMsg index, "Você precisa de uma ferramenta.", BrightRed
                Exit Sub
            Else
                If Not Item(GetPlayerEquipment(index, Weapon)).Data3 = Resource(Resource_index).ToolRequired Then
                    PlayerMsg index, "Você tem a ferramenta errada.", BrightRed
                    Exit Sub
                Else
                    Damage = Item(GetPlayerEquipment(index, Weapon)).Data2
                End If
            End If
            Else
                Damage = 1
            End If
            End If
            
                    ' inv space?
                    If Resource(Resource_index).ItemReward > 0 Then
                        If FindOpenInvSlot(index, Resource(Resource_index).ItemReward) = 0 Then
                            PlayerMsg index, "Você não têm espaço na Mochila", BrightRed
                            Exit Sub
                        End If
                    End If

                    ' check if already cut down
                    If ResourceCache(GetPlayerMap(index)).ResourceData(Resource_num).ResourceState = 0 Then
                    
                        rX = ResourceCache(GetPlayerMap(index)).ResourceData(Resource_num).X
                        rY = ResourceCache(GetPlayerMap(index)).ResourceData(Resource_num).Y
                        
                        
                    
                        ' check if damage is more than health
                        If Damage > 0 Then
                            ' cut it down!
                            If ResourceCache(GetPlayerMap(index)).ResourceData(Resource_num).cur_health - Damage <= 0 Then
                                SendActionMsg GetPlayerMap(index), "-" & ResourceCache(GetPlayerMap(index)).ResourceData(Resource_num).cur_health, BrightRed, 1, (rX * 32), (rY * 32)
                                ResourceCache(GetPlayerMap(index)).ResourceData(Resource_num).ResourceState = 1 ' Cut
                                ResourceCache(GetPlayerMap(index)).ResourceData(Resource_num).ResourceTimer = GetTickCount
                                SendResourceCacheToMap GetPlayerMap(index), Resource_num
                                ' send message if it exists
                                If Len(Trim$(Resource(Resource_index).SuccessMessage)) > 0 Then
                                    SendActionMsg GetPlayerMap(index), Trim$(Resource(Resource_index).SuccessMessage), BrightGreen, 1, (GetPlayerX(index) * 32), (GetPlayerY(index) * 32)
                                End If
                                ' carry on
                                GiveInvItem index, Resource(Resource_index).ItemReward, 1
                                SendAnimation GetPlayerMap(index), Resource(Resource_index).Animation, rX, rY
                                Select Case Resource_index
                                    Case 2
                                        If Player(index).Rank = RANK_ESTUDANTE Then
                                    
                                            For questSlot = 1 To 10
                                                If Player(index).QuestNum(questSlot) = 1 Then
                                                        TempPlayer(index).LogTrain = TempPlayer(index).LogTrain + 1
                                                        
                                                        If TempPlayer(index).LogTrain >= 20 Then
                                                            Player(index).QuestInfo(Player(index).QuestNum(questSlot)).Status = 3
                                                            PlayerMsg index, "Você está se sentindo muito mais forte!", BrightGreen
                                                            PlayerMsg index, "Volte e fale com o Iruka denovo!", White
                                                        End If
                                                    
                                                End If
                                            Next
                                        Else
                                            If GetPlayerLevel(index) >= 100 Then
                                                EXP = 2000
                                                
                                                If Not frmServer.txtEventoEXP.Text = 0 Then
                                                    EXP = EXP * frmServer.txtEventoEXP.Text
                                                End If
                                                TempPlayer(index).GanhouEXP = YES
                                                GivePlayerEXP index, EXP
                                                
                                            Else
                                                PlayerMsg index, "Apenas level 100 pra cima!", BrightRed
                        
                                            End If
                                        End If
                                    
                                    Case 4 'Casa/Base
                                        EXP = 10000
                                                                                    
                                        If Not frmServer.txtEventoEXP.Text = 0 Then
                                            EXP = EXP * frmServer.txtEventoEXP.Text
                                        End If
                                                
                                        TempPlayer(index).GanhouEXP = YES
                                        GivePlayerEXP index, EXP
                                    Case 5 'Base
                                        EXP = 15000

                                        If Not frmServer.txtEventoEXP.Text = 0 Then
                                            EXP = EXP * frmServer.txtEventoEXP.Text
                                        End If
                                        TempPlayer(index).GanhouEXP = YES
                                        GivePlayerEXP index, EXP
                                    
                                    Case Else
                                End Select
                            Else
                                ' just do the damage
                                ResourceCache(GetPlayerMap(index)).ResourceData(Resource_num).cur_health = ResourceCache(GetPlayerMap(index)).ResourceData(Resource_num).cur_health - Damage
                                SendActionMsg GetPlayerMap(index), "-" & Damage, BrightRed, 1, (rX * 32), (rY * 32)
                                SendAnimation GetPlayerMap(index), Resource(Resource_index).Animation, rX, rY
                            End If
                            ' send the sound
                            SendMapSound index, rX, rY, SoundEntity.seResource, Resource_index
                        Else
                            ' too weak
                            SendActionMsg GetPlayerMap(index), "Errou!", BrightRed, 1, (rX * 32), (rY * 32)
                        End If
                    Else
                        ' send message if it exists
                        If Len(Trim$(Resource(Resource_index).EmptyMessage)) > 0 Then
                            SendActionMsg GetPlayerMap(index), Trim$(Resource(Resource_index).EmptyMessage), BrightRed, 1, (GetPlayerX(index) * 32), (GetPlayerY(index) * 32)
                        End If
                    End If

                
        End If
    End If
End Sub

Function GetPlayerBankItemNum(ByVal index As Long, ByVal BankSlot As Long) As Long
If index < 1 Or index > MAX_PLAYERS Then Exit Function

    GetPlayerBankItemNum = Bank(index).Item(BankSlot).num
End Function

Sub SetPlayerBankItemNum(ByVal index As Long, ByVal BankSlot As Long, ByVal ItemNum As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub

    Bank(index).Item(BankSlot).num = ItemNum
End Sub

Function GetPlayerBankItemValue(ByVal index As Long, ByVal BankSlot As Long) As Long
If index < 1 Or index > MAX_PLAYERS Then Exit Function

    GetPlayerBankItemValue = Bank(index).Item(BankSlot).Value
End Function

Sub SetPlayerBankItemValue(ByVal index As Long, ByVal BankSlot As Long, ByVal ItemValue As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub

    Bank(index).Item(BankSlot).Value = ItemValue
End Sub

Sub GiveBankItem(ByVal index As Long, ByVal invSlot As Long, ByVal amount As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
Dim ItemNum As Long
Dim BankSlot
'On Error Resume Next
    If invSlot < 0 Or invSlot > MAX_INV Then
        Exit Sub
    End If
    
    If amount < 0 Or amount > GetPlayerInvItemValue(index, invSlot) Then
        Exit Sub
    End If
    
    If GetPlayerInvItemNum(index, invSlot) >= 200 And GetPlayerInvItemNum(index, invSlot) <= 230 Then
        PlayerMsg index, "Não pôde depositar o item!", BrightRed
        Exit Sub
    End If
    
    BankSlot = FindOpenBankSlot(index, GetPlayerInvItemNum(index, invSlot))
        
    If BankSlot > 0 Then
        If Item(GetPlayerInvItemNum(index, invSlot)).Type = ITEM_TYPE_CURRENCY Then
            If GetPlayerBankItemNum(index, BankSlot) = GetPlayerInvItemNum(index, invSlot) Then
                Call SetPlayerBankItemValue(index, BankSlot, GetPlayerBankItemValue(index, BankSlot) + amount)
                Call TakeInvItem(index, GetPlayerInvItemNum(index, invSlot), amount)
            Else
                Call SetPlayerBankItemNum(index, BankSlot, GetPlayerInvItemNum(index, invSlot))
                Call SetPlayerBankItemValue(index, BankSlot, amount)
                Call TakeInvItem(index, GetPlayerInvItemNum(index, invSlot), amount)
            End If
        Else
            If GetPlayerBankItemNum(index, BankSlot) = GetPlayerInvItemNum(index, invSlot) Then
                Call SetPlayerBankItemValue(index, BankSlot, GetPlayerBankItemValue(index, BankSlot) + 1)
                Call TakeInvItem(index, GetPlayerInvItemNum(index, invSlot), 0)
            Else
                Call SetPlayerBankItemNum(index, BankSlot, GetPlayerInvItemNum(index, invSlot))
                Call SetPlayerBankItemValue(index, BankSlot, 1)
                Call TakeInvItem(index, GetPlayerInvItemNum(index, invSlot), 0)
            End If
        End If
    End If
    
    SaveBank index
    SavePlayer index
    SendBank index

End Sub

Sub TakeBankItem(ByVal index As Long, ByVal BankSlot As Long, ByVal amount As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub

Dim invSlot
'On Error Resume Next
    If BankSlot < 0 Or BankSlot > MAX_BANK Then
        Exit Sub
    End If
    
    If amount < 0 Or amount > GetPlayerBankItemValue(index, BankSlot) Then
        Exit Sub
    End If
    
    invSlot = FindOpenInvSlot(index, GetPlayerBankItemNum(index, BankSlot))
        
    If invSlot > 0 Then
        If Item(GetPlayerBankItemNum(index, BankSlot)).Type = ITEM_TYPE_CURRENCY Then
            Call GiveInvItem(index, GetPlayerBankItemNum(index, BankSlot), amount)
            Call SetPlayerBankItemValue(index, BankSlot, GetPlayerBankItemValue(index, BankSlot) - amount)
            If GetPlayerBankItemValue(index, BankSlot) <= 0 Then
                Call SetPlayerBankItemNum(index, BankSlot, 0)
                Call SetPlayerBankItemValue(index, BankSlot, 0)
            End If
        Else
            If GetPlayerBankItemValue(index, BankSlot) > 1 Then
                Call GiveInvItem(index, GetPlayerBankItemNum(index, BankSlot), 0)
                Call SetPlayerBankItemValue(index, BankSlot, GetPlayerBankItemValue(index, BankSlot) - 1)
            Else
                Call GiveInvItem(index, GetPlayerBankItemNum(index, BankSlot), 0)
                Call SetPlayerBankItemNum(index, BankSlot, 0)
                Call SetPlayerBankItemValue(index, BankSlot, 0)
            End If
        End If
    End If
    
    SaveBank index
    SavePlayer index
    SendBank index

End Sub

Public Sub KillPlayer(ByVal index As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub

'On Error Resume Next
Dim EXP, mapNum As Long, i As Byte
mapNum = GetPlayerMap(index)

    ' Calculate exp to give attacker
    EXP = GetPlayerExp(index) \ 3
If HasItem(index, 68) Then
    TakeItem index, 68, 1
    PlayerMsg index, "Amuleto Da Sorte foi ativado.", Green
Else
    ' Make sure we dont get less then 0
    If EXP < 0 Then EXP = 0
    If EXP = 0 Then
        Call PlayerMsg(index, "Você não perdeu EXP.", BrightRed)
    Else
        TempPlayer(index).SetExp = YES
        Call SetPlayerExp(index, GetPlayerExp(index) - EXP)
        SendEXP index
        Call PlayerMsg(index, "Você perdeu " & EXP & " de EXP!", BrightRed)
    End If
End If
    
    Call OnDeath(index)
End Sub

Public Sub UseItem(ByVal index As Long, ByVal invNum As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub

Dim n As Long, i As Long, tempItem As Long, X As Long, Y As Long, ItemNum As Long
'On Error Resume Next
    ' Prevent hacking
    If invNum < 1 Or invNum > MAX_ITEMS Then
        Exit Sub
    End If

    If (GetPlayerInvItemNum(index, invNum) > 0) And (GetPlayerInvItemNum(index, invNum) <= MAX_ITEMS) Then
        n = Item(GetPlayerInvItemNum(index, invNum)).Data2
        ItemNum = GetPlayerInvItemNum(index, invNum)
        
        ' Find out what kind of item it is
        Select Case Item(ItemNum).Type
            Case ITEM_TYPE_ARMOR
            
                ' stat requirements
                For i = 1 To Stats.Stat_Count - 1
                    If GetPlayerRawStat(index, i) < Item(ItemNum).Stat_Req(i) Then
                        PlayerMsg index, "Você não têm os Stats requeridos pra usar este item", BrightRed
                        Exit Sub
                    End If
                Next
                
                ' level requirement
                If GetPlayerLevel(index) < Item(ItemNum).LevelReq Then
                    PlayerMsg index, "Você não têm os Levels requeridos pra usar este item", BrightRed
                    Exit Sub
                End If
                
                ' class requirement
                If Item(ItemNum).ClassReq > 0 Then
                    If Not GetPlayerClass(index) = Item(ItemNum).ClassReq Then
                        PlayerMsg index, "Você não têm o Personagem requerido pra usar este item", BrightRed
                        Exit Sub
                    End If
                End If
                
                ' access requirement
                If Not GetPlayerAccess(index) >= Item(ItemNum).AccessReq Then
                    PlayerMsg index, "Você não têm o Acesso requerido pra usar este item.", BrightRed
                    Exit Sub
                End If

                If GetPlayerEquipment(index, Armor) > 0 Then
                    tempItem = GetPlayerEquipment(index, Armor)
                End If

                SetPlayerEquipment index, ItemNum, Armor
                PlayerMsg index, "Você equipou " & CheckGrammar(Item(ItemNum).Name), BrightGreen
                TakeInvItem index, ItemNum, 0

                If tempItem > 0 Then
                    GiveInvItem index, tempItem, 0 ' give back the stored item
                    tempItem = 0
                End If

                Call SendWornEquipment(index)
                Call SendMapEquipment(index)
                
                ' send vitals
                Call SendVital(index, Vitals.HP)
                Call SendVital(index, Vitals.mp)
                ' send vitals to party if in one
                If TempPlayer(index).inParty > 0 Then SendPartyVitals TempPlayer(index).inParty, index
                
                ' send the sound
                SendPlayerSound index, GetPlayerX(index), GetPlayerY(index), SoundEntity.seItem, ItemNum
            Case ITEM_TYPE_WEAPON
            
                ' stat requirements
                For i = 1 To Stats.Stat_Count - 1
                    If GetPlayerRawStat(index, i) < Item(ItemNum).Stat_Req(i) Then
                        PlayerMsg index, "Você não têm os Stats requeridos pra usar este item", BrightRed
                        Exit Sub
                    End If
                Next
                
                ' level requirement
                If GetPlayerLevel(index) < Item(ItemNum).LevelReq Then
                    PlayerMsg index, "Você não têm os Levels requeridos pra usar este item", BrightRed
                    Exit Sub
                End If
                
                ' class requirement
                If Item(ItemNum).ClassReq > 0 Then
                    If Not GetPlayerClass(index) = Item(ItemNum).ClassReq Then
                        PlayerMsg index, "Você não têm o Personagem requerido pra usar este item", BrightRed
                        Exit Sub
                    End If
                End If
                
                ' access requirement
                If Not GetPlayerAccess(index) >= Item(ItemNum).AccessReq Then
                    PlayerMsg index, "Você não têm o Acesso requerido pra usar este item.", BrightRed
                    Exit Sub
                End If

                If GetPlayerEquipment(index, Weapon) > 0 Then
                    tempItem = GetPlayerEquipment(index, Weapon)
                End If

                SetPlayerEquipment index, ItemNum, Weapon
                PlayerMsg index, "Você equipou " & CheckGrammar(Item(ItemNum).Name), BrightGreen
                TakeInvItem index, ItemNum, 1

                If tempItem > 0 Then
                    GiveInvItem index, tempItem, 0 ' give back the stored item
                    tempItem = 0
                End If

                Call SendWornEquipment(index)
                Call SendMapEquipment(index)
                
                ' send vitals
                Call SendVital(index, Vitals.HP)
                Call SendVital(index, Vitals.mp)
                ' send vitals to party if in one
                If TempPlayer(index).inParty > 0 Then SendPartyVitals TempPlayer(index).inParty, index
                
                ' send the sound
                SendPlayerSound index, GetPlayerX(index), GetPlayerY(index), SoundEntity.seItem, ItemNum
            Case ITEM_TYPE_HELMET
            
                ' stat requirements
                For i = 1 To Stats.Stat_Count - 1
                    If GetPlayerRawStat(index, i) < Item(ItemNum).Stat_Req(i) Then
                        PlayerMsg index, "Você não têm os Stats requeridos pra usar este item", BrightRed
                        Exit Sub
                    End If
                Next
                
                ' level requirement
                If GetPlayerLevel(index) < Item(ItemNum).LevelReq Then
                    PlayerMsg index, "Você não têm os Levels requeridos pra usar este item", BrightRed
                    Exit Sub
                End If
                
                ' class requirement
                If Item(ItemNum).ClassReq > 0 Then
                    If Not GetPlayerClass(index) = Item(ItemNum).ClassReq Then
                        PlayerMsg index, "Você não têm o Personagem requerido pra usar este item", BrightRed
                        Exit Sub
                    End If
                End If
                
                ' access requirement
                If Not GetPlayerAccess(index) >= Item(ItemNum).AccessReq Then
                    PlayerMsg index, "Você não têm o Acesso requerido pra usar este item.", BrightRed
                    Exit Sub
                End If

                If GetPlayerEquipment(index, Helmet) > 0 Then
                    tempItem = GetPlayerEquipment(index, Helmet)
                End If

                SetPlayerEquipment index, ItemNum, Helmet
                PlayerMsg index, "Você equipou " & CheckGrammar(Item(ItemNum).Name), BrightGreen
                TakeInvItem index, ItemNum, 1

                If tempItem > 0 Then
                    GiveInvItem index, tempItem, 0 ' give back the stored item
                    tempItem = 0
                End If

                Call SendWornEquipment(index)
                Call SendMapEquipment(index)
                
                ' send vitals
                Call SendVital(index, Vitals.HP)
                Call SendVital(index, Vitals.mp)
                ' send vitals to party if in one
                If TempPlayer(index).inParty > 0 Then SendPartyVitals TempPlayer(index).inParty, index
                
                ' send the sound
                SendPlayerSound index, GetPlayerX(index), GetPlayerY(index), SoundEntity.seItem, ItemNum
            Case ITEM_TYPE_SHIELD
            
                ' stat requirements
                For i = 1 To Stats.Stat_Count - 1
                    If GetPlayerRawStat(index, i) < Item(ItemNum).Stat_Req(i) Then
                        PlayerMsg index, "Você não têm os Stats requeridos pra usar este item", BrightRed
                        Exit Sub
                    End If
                Next
                
                ' level requirement
                If GetPlayerLevel(index) < Item(ItemNum).LevelReq Then
                    PlayerMsg index, "Você não têm os Levels requeridos pra usar este item", BrightRed
                    Exit Sub
                End If
                
                ' class requirement
                If Item(ItemNum).ClassReq > 0 Then
                    If Not GetPlayerClass(index) = Item(ItemNum).ClassReq Then
                        PlayerMsg index, "Você não têm o Personagem requerido pra usar este item", BrightRed
                        Exit Sub
                    End If
                End If
                
                ' access requirement
                If Not GetPlayerAccess(index) >= Item(ItemNum).AccessReq Then
                    PlayerMsg index, "Você não têm o Acesso requerido pra usar este item.", BrightRed
                    Exit Sub
                End If

                If GetPlayerEquipment(index, Shield) > 0 Then
                    tempItem = GetPlayerEquipment(index, Shield)
                End If

                SetPlayerEquipment index, ItemNum, Shield
                PlayerMsg index, "Você equipou " & CheckGrammar(Item(ItemNum).Name), BrightGreen
                TakeInvItem index, ItemNum, 1

                If tempItem > 0 Then
                    GiveInvItem index, tempItem, 0 ' give back the stored item
                    tempItem = 0
                End If
                
                ' send vitals
                Call SendVital(index, Vitals.HP)
                Call SendVital(index, Vitals.mp)
                ' send vitals to party if in one
                If TempPlayer(index).inParty > 0 Then SendPartyVitals TempPlayer(index).inParty, index

                Call SendWornEquipment(index)
                Call SendMapEquipment(index)
                
                ' send the sound
                SendPlayerSound index, GetPlayerX(index), GetPlayerY(index), SoundEntity.seItem, ItemNum
            ' consumable
            Case ITEM_TYPE_CONSUME
                ' stat requirements
                For i = 1 To Stats.Stat_Count - 1
                    If GetPlayerRawStat(index, i) < Item(ItemNum).Stat_Req(i) Then
                        PlayerMsg index, "Você não têm os Stats requeridos pra usar este item", BrightRed
                        Exit Sub
                    End If
                Next
                
                ' level requirement
                If GetPlayerLevel(index) < Item(ItemNum).LevelReq Then
                    PlayerMsg index, "Você não têm os Levels requeridos pra usar este item", BrightRed
                    Exit Sub
                End If
                
                ' class requirement
                If Item(ItemNum).ClassReq > 0 Then
                    If Not GetPlayerClass(index) = Item(ItemNum).ClassReq Then
                        PlayerMsg index, "Você não têm o Personagem requerido pra usar este item", BrightRed
                        Exit Sub
                    End If
                End If
                
                ' access requirement
                If Not GetPlayerAccess(index) >= Item(ItemNum).AccessReq Then
                    PlayerMsg index, "Você não têm o Acesso requerido pra usar este item.", BrightRed
                    Exit Sub
                End If
                
                ' add hp
                If Item(ItemNum).AddHP > 0 Then
                    Player(index).Vital(Vitals.HP) = Player(index).Vital(Vitals.HP) + Item(ItemNum).AddHP
                    SendActionMsg GetPlayerMap(index), "+" & Item(ItemNum).AddHP, BrightGreen, ACTIONMSG_SCROLL, GetPlayerX(index) * 32, GetPlayerY(index) * 32
                    SendVital index, HP
                    ' send vitals to party if in one
                    If TempPlayer(index).inParty > 0 Then SendPartyVitals TempPlayer(index).inParty, index
                End If
                ' add mp
                If Item(ItemNum).AddMP > 0 Then
                    Player(index).Vital(Vitals.mp) = Player(index).Vital(Vitals.mp) + Item(ItemNum).AddMP
                    SendActionMsg GetPlayerMap(index), "+" & Item(ItemNum).AddMP, BrightBlue, ACTIONMSG_SCROLL, GetPlayerX(index) * 32, GetPlayerY(index) * 32
                    SendVital index, mp
                    ' send vitals to party if in one
                    If TempPlayer(index).inParty > 0 Then SendPartyVitals TempPlayer(index).inParty, index
                End If
                ' add exp
                If Item(ItemNum).AddEXP > 0 Then
                    TempPlayer(index).SetExp = YES
                    SetPlayerExp index, GetPlayerExp(index) + Item(ItemNum).AddEXP
                    CheckPlayerLevelUp index
                    SendActionMsg GetPlayerMap(index), "+" & Item(ItemNum).AddEXP & " EXP", White, ACTIONMSG_SCROLL, GetPlayerX(index) * 32, GetPlayerY(index) * 32
                    SendEXP index
                End If
                Call SendAnimation(GetPlayerMap(index), Item(ItemNum).Animation, 0, 0, TARGET_TYPE_PLAYER, index)
                Call TakeInvItem(index, Player(index).Inv(invNum).num, 0)
                
                ' send the sound
                SendPlayerSound index, GetPlayerX(index), GetPlayerY(index), SoundEntity.seItem, ItemNum
            Case ITEM_TYPE_KEY
                ' stat requirements
                For i = 1 To Stats.Stat_Count - 1
                    If GetPlayerRawStat(index, i) < Item(ItemNum).Stat_Req(i) Then
                        PlayerMsg index, "Você não têm os Stats requeridos pra usar este item", BrightRed
                        Exit Sub
                    End If
                Next
                
                ' level requirement
                If GetPlayerLevel(index) < Item(ItemNum).LevelReq Then
                    PlayerMsg index, "Você não têm os Levels requeridos pra usar este item", BrightRed
                    Exit Sub
                End If
                
                ' class requirement
                If Item(ItemNum).ClassReq > 0 Then
                    If Not GetPlayerClass(index) = Item(ItemNum).ClassReq Then
                        PlayerMsg index, "Você não têm o Personagem requerido pra usar este item", BrightRed
                        Exit Sub
                    End If
                End If
                
                ' access requirement
                If Not GetPlayerAccess(index) >= Item(ItemNum).AccessReq Then
                    PlayerMsg index, "Você não têm o Acesso requerido pra usar este item.", BrightRed
                    Exit Sub
                End If

                Select Case GetPlayerDir(index)
                    Case DIR_UP

                        If GetPlayerY(index) > 0 Then
                            X = GetPlayerX(index)
                            Y = GetPlayerY(index) - 1
                        Else
                            Exit Sub
                        End If

                    Case DIR_DOWN

                        If GetPlayerY(index) < Map(GetPlayerMap(index)).MaxY Then
                            X = GetPlayerX(index)
                            Y = GetPlayerY(index) + 1
                        Else
                            Exit Sub
                        End If

                    Case DIR_LEFT

                        If GetPlayerX(index) > 0 Then
                            X = GetPlayerX(index) - 1
                            Y = GetPlayerY(index)
                        Else
                            Exit Sub
                        End If

                    Case DIR_RIGHT

                        If GetPlayerX(index) < Map(GetPlayerMap(index)).MaxX Then
                            X = GetPlayerX(index) + 1
                            Y = GetPlayerY(index)
                        Else
                            Exit Sub
                        End If

                End Select

                ' Check if a key exists
                If Map(GetPlayerMap(index)).Tile(X, Y).Type = TILE_TYPE_KEY Then

                    ' Check if the key they are using matches the map key
                    If ItemNum = Map(GetPlayerMap(index)).Tile(X, Y).Data1 Then
                        TempTile(GetPlayerMap(index)).DoorOpen(X, Y) = YES
                        TempTile(GetPlayerMap(index)).DoorTimer = GetTickCount
                        SendMapKey index, X, Y, 1
                        Call MapMsg(GetPlayerMap(index), "A porta se abre..", White)
                        
                        Call SendAnimation(GetPlayerMap(index), Item(ItemNum).Animation, X, Y)

                        ' Check if we are supposed to take away the item
                        If Map(GetPlayerMap(index)).Tile(X, Y).Data2 = 1 Then
                            Call TakeInvItem(index, ItemNum, 0)
                            Call PlayerMsg(index, "A chave foi destruída na fechadura!", Yellow)
                        End If
                    End If
                End If
                
                ' send the sound
                SendPlayerSound index, GetPlayerX(index), GetPlayerY(index), SoundEntity.seItem, ItemNum
            Case ITEM_TYPE_SPELL

            
            
                ' stat requirements
                For i = 1 To Stats.Stat_Count - 1
                    If GetPlayerRawStat(index, i) < Item(ItemNum).Stat_Req(i) Then
                        PlayerMsg index, "Você não têm os Stats requeridos pra usar este item", BrightRed
                        Exit Sub
                    End If
                Next
                
                ' level requirement
                If GetPlayerLevel(index) < Item(ItemNum).LevelReq Then
                    PlayerMsg index, "Você não têm os Levels requeridos pra usar este item", BrightRed
                    Exit Sub
                End If
                
                ' class requirement
                If Item(ItemNum).ClassReq > 0 Then
                    If Not GetPlayerClass(index) = Item(ItemNum).ClassReq Then
                        PlayerMsg index, "Você não têm o Personagem requerido pra usar este item", BrightRed
                        Exit Sub
                    End If
                End If
                
                ' access requirement
                If Not GetPlayerAccess(index) >= Item(ItemNum).AccessReq Then
                    PlayerMsg index, "Você não têm o Acesso requerido pra usar este item.", BrightRed
                    Exit Sub
                End If
                
                ' Get the spell num
                n = Item(ItemNum).Data1

                If n > 0 Then

                    ' Make sure they are the right class
                    If Spell(n).ClassReq = GetPlayerClass(index) Or Spell(n).ClassReq = 0 Then
                        ' Make sure they are the right level
                        i = Spell(n).LevelReq

                        If i <= GetPlayerLevel(index) Then
                            i = FindOpenSpellSlot(index)

                            ' Make sure they have an open spell slot
                            If i > 0 Then

                                ' Make sure they dont already have the spell
                                If Not HasSpell(index, n) Then
                                    Call SetPlayerSpell(index, i, n)
                                    Call SendAnimation(GetPlayerMap(index), Item(ItemNum).Animation, 0, 0, TARGET_TYPE_PLAYER, index)
                                    Call TakeInvItem(index, ItemNum, 0)
                                    Call PlayerMsg(index, "Você aprendeu o Jutsu: " & Trim$(Spell(n).Name) & ".", BrightGreen)
                                Else
                                    Call PlayerMsg(index, "Você já sabe usar este jutsu..", BrightRed)
                                End If

                            Else
                                Call PlayerMsg(index, "Você já sabe muitos Jutsus!", BrightRed)
                            End If

                        Else
                            Call PlayerMsg(index, "Você precisa ser Level: " & i & " para aprender este Jutsu..", BrightRed)
                        End If

                    Else
                        Call PlayerMsg(index, "Este Jutsu só pode ser aprendido por " & CheckGrammar(GetClassName(Spell(n).ClassReq)) & ".", BrightRed)
                    End If
                End If
                
                ' send the sound
                SendPlayerSound index, GetPlayerX(index), GetPlayerY(index), SoundEntity.seItem, ItemNum
        Case ITEM_TYPE_SCRIPT
            ' stat requirements
                For i = 1 To Stats.Stat_Count - 1
                    If GetPlayerRawStat(index, i) < Item(ItemNum).Stat_Req(i) Then
                        PlayerMsg index, "Você não têm os Stats requeridos pra usar este item", BrightRed
                        Exit Sub
                    End If
                Next
                
                ' level requirement
                If GetPlayerLevel(index) < Item(ItemNum).LevelReq Then
                    PlayerMsg index, "Você não têm os Levels requeridos pra usar este item", BrightRed
                    Exit Sub
                End If
                
                ' class requirement
                If Item(ItemNum).ClassReq > 0 Then
                    If Not GetPlayerClass(index) = Item(ItemNum).ClassReq Then
                        PlayerMsg index, "Você não têm o Personagem requerido pra usar este item", BrightRed
                        Exit Sub
                    End If
                End If
                
                ' access requirement
                If Not GetPlayerAccess(index) >= Item(ItemNum).AccessReq Then
                    PlayerMsg index, "Você não têm o Acesso requerido pra usar este item.", BrightRed
                    Exit Sub
                End If
            
            ScriptedItem index, Item(ItemNum).Script, ItemNum
            SendPlayerSound index, GetPlayerX(index), GetPlayerY(index), SoundEntity.seItem, ItemNum
        
        
        End Select
    End If
End Sub

Public Sub WarpBehind_Player(ByVal index As Long, ByVal Alvo As Long)
'On Error Resume Next
 If index < 1 Or index > MAX_PLAYERS Then Exit Sub
 If Alvo < 1 Or Alvo > MAX_PLAYERS Then Exit Sub
 
 Dim AlvoX, AlvoY, Dist, MapX, mapY As Byte
 
MapX = Map(GetPlayerMap(index)).MaxX
mapY = Map(GetPlayerMap(index)).MaxY
AlvoX = GetPlayerX(Alvo)
AlvoY = GetPlayerY(Alvo)

    Select Case GetPlayerDir(Alvo)
        Case DIR_UP
               Dist = AlvoY + 1
               If Dist > MapX Then Dist = MapX
               SetPlayerY index, Dist
               SetPlayerX index, AlvoX
               SetPlayerDir index, DIR_UP
           Case DIR_DOWN
                Dist = AlvoY - 1
                If Dist < 1 Then Dist = 0
                SetPlayerY index, Dist
                SetPlayerX index, AlvoX
                SetPlayerDir index, DIR_DOWN
           Case DIR_RIGHT
                Dist = AlvoX - 1
                If Dist < 1 Then Dist = 0
                SetPlayerX index, Dist
                SetPlayerY index, AlvoY
                SetPlayerDir index, DIR_RIGHT
           Case DIR_LEFT
                Dist = AlvoX + 1
                If Dist > MapX Then Dist = MapX
                SetPlayerX index, Dist
                SetPlayerY index, AlvoY
                SetPlayerDir index, DIR_LEFT
    End Select
    
SendPlayerXYToMap index
If TempPlayer(index).Kawarimi > 0 Then TempPlayer(index).Kawarimi = 0
 
End Sub

Public Sub WarpBehind_Npc(ByVal index As Long, ByVal Alvo As Long)
'On Error Resume Next
Dim NpcX, NpcY, Dist, MapX, mapY As Byte

If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If Alvo < 1 Or Alvo > MAX_MAP_NPCS Then Exit Sub
MapX = Map(GetPlayerMap(index)).MaxX
mapY = Map(GetPlayerMap(index)).MaxY
 NpcX = MapNpc(GetPlayerMap(index)).Npc(Alvo).X
NpcY = MapNpc(GetPlayerMap(index)).Npc(Alvo).Y

    Select Case MapNpc(GetPlayerMap(index)).Npc(Alvo).Dir
           Case DIR_UP
               Dist = NpcY + 1
               If Dist > MapX Then Dist = MapX
               SetPlayerY index, Dist
               SetPlayerX index, NpcX
               SetPlayerDir index, DIR_UP
           Case DIR_DOWN
                Dist = NpcY - 1
                If Dist < 1 Then Dist = 0
                SetPlayerY index, Dist
                SetPlayerX index, NpcX
                SetPlayerDir index, DIR_DOWN
           Case DIR_RIGHT
                Dist = NpcX - 1
                If Dist < 1 Then Dist = 0
                SetPlayerX index, Dist
                SetPlayerY index, NpcY
                SetPlayerDir index, DIR_RIGHT
           Case DIR_LEFT
                Dist = NpcX + 1
                If Dist > MapX Then Dist = MapX
                SetPlayerX index, Dist
                SetPlayerY index, NpcY
                SetPlayerDir index, DIR_LEFT
    End Select
    
    SendPlayerXYToMap index
    If TempPlayer(index).Kawarimi > 0 Then TempPlayer(index).Kawarimi = 0
           
End Sub

Sub NpcWarpBehind(ByVal NpcID As Byte, ByVal index As Long)
'On Error Resume Next
Dim MapX, mapY, Dist, distTotal, NpcX, NpcY As Byte


If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If NpcID < 1 Or NpcID > MAX_MAP_NPCS Then Exit Sub


MapX = Map(GetPlayerMap(index)).MaxX
mapY = Map(GetPlayerMap(index)).MaxY
NpcX = MapNpc(GetPlayerMap(index)).Npc(NpcID).X
NpcY = MapNpc(GetPlayerMap(index)).Npc(NpcID).Y

  Select Case GetPlayerDir(index)
       Case DIR_UP
           Dist = GetPlayerY(index) + 1
           If Dist > mapY Then Dist = mapY
           MapNpc(GetPlayerMap(index)).Npc(NpcID).Y = Dist
           MapNpc(GetPlayerMap(index)).Npc(NpcID).X = GetPlayerX(index)
           MapNpc(GetPlayerMap(index)).Npc(NpcID).Dir = DIR_UP
        Case DIR_DOWN
           Dist = GetPlayerY(index) - 1
           If Dist < 1 Then Dist = 0
           MapNpc(GetPlayerMap(index)).Npc(NpcID).Y = Dist
           MapNpc(GetPlayerMap(index)).Npc(NpcID).X = GetPlayerX(index)
           MapNpc(GetPlayerMap(index)).Npc(NpcID).Dir = DIR_DOWN
        Case DIR_RIGHT
           Dist = GetPlayerX(index) - 1
           If Dist < 1 Then Dist = 0
           MapNpc(GetPlayerMap(index)).Npc(NpcID).X = Dist
           MapNpc(GetPlayerMap(index)).Npc(NpcID).Y = GetPlayerY(index)
           MapNpc(GetPlayerMap(index)).Npc(NpcID).Dir = DIR_RIGHT
        Case DIR_LEFT
           Dist = GetPlayerX(index) + 1
           If Dist > MapX Then Dist = MapX
           MapNpc(GetPlayerMap(index)).Npc(NpcID).X = Dist
           MapNpc(GetPlayerMap(index)).Npc(NpcID).Y = GetPlayerY(index)
           MapNpc(GetPlayerMap(index)).Npc(NpcID).Dir = DIR_LEFT
  End Select
  
  SendMapNpcsToMap GetPlayerMap(index)
           
End Sub

Sub EscapeNoJutsu(ByVal index As Long, ByVal Dist As Byte)
'On Error Resume Next
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
    
    Select Case GetPlayerDir(index)
    
       Case DIR_UP
           PlayerWarp index, GetPlayerMap(index), GetPlayerX(index), GetPlayerY(index) + Dist
       Case DIR_DOWN
            PlayerWarp index, GetPlayerMap(index), GetPlayerX(index), GetPlayerY(index) - Dist
       Case DIR_RIGHT
             PlayerWarp index, GetPlayerMap(index), GetPlayerX(index) - Dist, GetPlayerY(index)
       Case DIR_LEFT
              PlayerWarp index, GetPlayerMap(index), GetPlayerX(index) + Dist, GetPlayerY(index)
    End Select
    
    If TempPlayer(index).Kawarimi > 0 Then TempPlayer(index).Kawarimi = 0
End Sub

Public Sub CheckLevelSkill(ByVal index As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
On Error Resume Next
Select Case GetPlayerClass(index)

    Case 1 'Uzumaki
        If GetPlayerLevel(index) >= 10 Then
            If Not HasSpell(index, 28) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 28
                PlayerMsg index, "Você acabou de aprender " & Spell(28).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 30 Then
            If Not HasSpell(index, 29) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 29
                PlayerMsg index, "Você acabou de aprender " & Spell(29).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 50 Then
            If Not HasSpell(index, 30) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 30
                PlayerMsg index, "Você acabou de aprender " & Spell(30).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 70 Then
            If Not HasSpell(index, 31) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 31
                PlayerMsg index, "Você acabou de aprender " & Spell(31).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 100 Then
            If Not HasSpell(index, 32) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 32
                PlayerMsg index, "Você acabou de aprender " & Spell(32).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 120 Then
            If Not HasSpell(index, 33) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 33
                PlayerMsg index, "Você acabou de aprender " & Spell(33).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 150 Then
            If Not HasSpell(index, 36) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 36
                PlayerMsg index, "Você acabou de aprender " & Spell(36).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 180 Then
            If Not HasSpell(index, 34) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 34
                PlayerMsg index, "Você acabou de aprender " & Spell(34).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 220 Then
            If Not HasSpell(index, 35) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 35
                PlayerMsg index, "Você acabou de aprender " & Spell(35).Name, BrightBlue
            End If
        End If
    
    Case 2 'Uchila
        If GetPlayerLevel(index) >= 10 Then
            If Not HasSpell(index, 38) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 38
                PlayerMsg index, "Você acabou de aprender " & Spell(38).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 30 Then
            If Not HasSpell(index, 39) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 39
                PlayerMsg index, "Você acabou de aprender " & Spell(39).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 50 Then
            If Not HasSpell(index, 49) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 49
                PlayerMsg index, "Você acabou de aprender " & Spell(49).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 70 Then
            If Not HasSpell(index, 40) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 40
                PlayerMsg index, "Você acabou de aprender " & Spell(40).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 100 Then
            If Not HasSpell(index, 41) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 41
                PlayerMsg index, "Você acabou de aprender " & Spell(41).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 120 Then
            If Not HasSpell(index, 42) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 42
                PlayerMsg index, "Você acabou de aprender " & Spell(42).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 150 Then
            If Not HasSpell(index, 43) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 43
                PlayerMsg index, "Você acabou de aprender " & Spell(43).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 180 Then
            If Not HasSpell(index, 50) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 50
                PlayerMsg index, "Você acabou de aprender " & Spell(50).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 220 Then
            If Not HasSpell(index, 44) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 44
                PlayerMsg index, "Você acabou de aprender " & Spell(44).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 250 Then
            If Not HasSpell(index, 45) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 45
                PlayerMsg index, "Você acabou de aprender " & Spell(45).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 280 Then
            If Not HasSpell(index, 46) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 46
                PlayerMsg index, "Você acabou de aprender " & Spell(46).Name, BrightBlue
            End If
        End If
        
    Case 3 'Haruno
        If GetPlayerLevel(index) >= 10 Then
            If Not HasSpell(index, 52) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 52
                PlayerMsg index, "Você acabou de aprender " & Spell(52).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 30 Then
            If Not HasSpell(index, 53) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 53
                PlayerMsg index, "Você acabou de aprender " & Spell(53).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 50 Then
            If Not HasSpell(index, 54) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 54
                PlayerMsg index, "Você acabou de aprender " & Spell(54).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 70 Then
            If Not HasSpell(index, 55) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 55
                PlayerMsg index, "Você acabou de aprender " & Spell(55).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 100 Then
            If Not HasSpell(index, 56) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 56
                PlayerMsg index, "Você acabou de aprender " & Spell(56).Name, BrightBlue
            End If
        End If
        
    Case 4 'Ino
        If GetPlayerLevel(index) >= 10 Then
            If Not HasSpell(index, 58) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 58
                PlayerMsg index, "Você acabou de aprender " & Spell(58).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 30 Then
            If Not HasSpell(index, 59) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 59
                PlayerMsg index, "Você acabou de aprender " & Spell(59).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 50 Then
            If Not HasSpell(index, 60) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 60
                PlayerMsg index, "Você acabou de aprender " & Spell(60).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 70 Then
            If Not HasSpell(index, 61) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 61
                PlayerMsg index, "Você acabou de aprender " & Spell(61).Name, BrightBlue
            End If
        End If
        
    Case 5 'Nara
        If GetPlayerLevel(index) >= 10 Then
            If Not HasSpell(index, 63) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 63
                PlayerMsg index, "Você acabou de aprender " & Spell(63).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 30 Then
            If Not HasSpell(index, 64) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 64
                PlayerMsg index, "Você acabou de aprender " & Spell(64).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 50 Then
            If Not HasSpell(index, 65) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 65
                PlayerMsg index, "Você acabou de aprender " & Spell(65).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 70 Then
            If Not HasSpell(index, 66) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 66
                PlayerMsg index, "Você acabou de aprender " & Spell(66).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 100 Then
            If Not HasSpell(index, 67) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 67
                PlayerMsg index, "Você acabou de aprender " & Spell(67).Name, BrightBlue
            End If
        End If
        
    Case 6 'Chouji
        If GetPlayerLevel(index) >= 10 Then
            If Not HasSpell(index, 69) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 69
                PlayerMsg index, "Você acabou de aprender " & Spell(69).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 30 Then
            If Not HasSpell(index, 70) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 70
                PlayerMsg index, "Você acabou de aprender " & Spell(70).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 50 Then
            If Not HasSpell(index, 71) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 71
                PlayerMsg index, "Você acabou de aprender " & Spell(71).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 70 Then
            If Not HasSpell(index, 72) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 72
                PlayerMsg index, "Você acabou de aprender " & Spell(72).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 100 Then
            If Not HasSpell(index, 73) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 73
                PlayerMsg index, "Você acabou de aprender " & Spell(73).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 120 Then
            If Not HasSpell(index, 74) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 74
                PlayerMsg index, "Você acabou de aprender " & Spell(74).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 150 Then
            If Not HasSpell(index, 75) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 75
                PlayerMsg index, "Você acabou de aprender " & Spell(75).Name, BrightBlue
            End If
        End If
    
    Case 7 ' Lee
        If GetPlayerLevel(index) >= 10 Then
            If Not HasSpell(index, 77) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 77
                PlayerMsg index, "Você acabou de aprender " & Spell(77).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 30 Then
            If Not HasSpell(index, 78) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 78
                PlayerMsg index, "Você acabou de aprender " & Spell(78).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 50 Then
            If Not HasSpell(index, 79) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 79
                PlayerMsg index, "Você acabou de aprender " & Spell(79).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 70 Then
            If Not HasSpell(index, 80) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 80
                PlayerMsg index, "Você acabou de aprender " & Spell(80).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 100 Then
            If Not HasSpell(index, 81) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 81
                PlayerMsg index, "Você acabou de aprender " & Spell(81).Name, BrightBlue
            End If
        End If
        
        If GetPlayerLevel(index) >= 120 Then
            If Not HasSpell(index, 82) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 82
                PlayerMsg index, "Você acabou de aprender " & Spell(82).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 150 Then
            If Not HasSpell(index, 83) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 83
                PlayerMsg index, "Você acabou de aprender " & Spell(83).Name, BrightBlue
            End If
        End If
        
    Case 8, 15 'Hyuuga-Neji Hinata
        If GetPlayerLevel(index) >= 10 Then
            If Not HasSpell(index, 85) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 85
                PlayerMsg index, "Você acabou de aprender " & Spell(85).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 30 Then
            If Not HasSpell(index, 86) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 86
                PlayerMsg index, "Você acabou de aprender " & Spell(86).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 50 Then
            If Not HasSpell(index, 87) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 87
                PlayerMsg index, "Você acabou de aprender " & Spell(87).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 70 Then
            If Not HasSpell(index, 88) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 88
                PlayerMsg index, "Você acabou de aprender " & Spell(88).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 100 Then
            If Not HasSpell(index, 89) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 89
                PlayerMsg index, "Você acabou de aprender " & Spell(89).Name, BrightBlue
            End If
        End If
        
        If GetPlayerLevel(index) >= 120 Then
            If Not HasSpell(index, 90) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 90
                PlayerMsg index, "Você acabou de aprender " & Spell(90).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 150 Then
            If Not HasSpell(index, 91) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 91
                PlayerMsg index, "Você acabou de aprender " & Spell(91).Name, BrightBlue
            End If
        End If
    Case 9 'Tenten
        If GetPlayerLevel(index) >= 10 Then
            If Not HasSpell(index, 93) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 93
                PlayerMsg index, "Você acabou de aprender " & Spell(93).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 30 Then
            If Not HasSpell(index, 94) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 94
                PlayerMsg index, "Você acabou de aprender " & Spell(94).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 50 Then
            If Not HasSpell(index, 95) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 95
                PlayerMsg index, "Você acabou de aprender " & Spell(95).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 70 Then
            If Not HasSpell(index, 96) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 96
                PlayerMsg index, "Você acabou de aprender " & Spell(96).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 100 Then
            If Not HasSpell(index, 97) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 97
                PlayerMsg index, "Você acabou de aprender " & Spell(97).Name, BrightBlue
            End If
        End If
        
    Case 10 'Inuzuka
        If GetPlayerLevel(index) >= 10 Then
            If Not HasSpell(index, 99) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 99
                PlayerMsg index, "Você acabou de aprender " & Spell(99).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 30 Then
            If Not HasSpell(index, 100) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 100
                PlayerMsg index, "Você acabou de aprender " & Spell(100).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 50 Then
            If Not HasSpell(index, 101) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 101
                PlayerMsg index, "Você acabou de aprender " & Spell(101).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 70 Then
            If Not HasSpell(index, 102) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 102
                PlayerMsg index, "Você acabou de aprender " & Spell(102).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 100 Then
            If Not HasSpell(index, 103) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 103
                PlayerMsg index, "Você acabou de aprender " & Spell(103).Name, BrightBlue
            End If
        End If
        
        If GetPlayerLevel(index) >= 120 Then
            If Not HasSpell(index, 104) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 104
                PlayerMsg index, "Você acabou de aprender " & Spell(104).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 150 Then
            If Not HasSpell(index, 105) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 105
                PlayerMsg index, "Você acabou de aprender " & Spell(105).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 180 Then
            If Not HasSpell(index, 106) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 106
                PlayerMsg index, "Você acabou de aprender " & Spell(106).Name, BrightBlue
            End If
        End If
        
    Case 11 'Aburame
       
        If GetPlayerLevel(index) >= 10 Then
            If Not HasSpell(index, 108) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 108
                PlayerMsg index, "Você acabou de aprender " & Spell(108).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 30 Then
            If Not HasSpell(index, 109) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 109
                PlayerMsg index, "Você acabou de aprender " & Spell(109).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 50 Then
            If Not HasSpell(index, 110) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 110
                PlayerMsg index, "Você acabou de aprender " & Spell(110).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 70 Then
            If Not HasSpell(index, 111) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 111
                PlayerMsg index, "Você acabou de aprender " & Spell(111).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 100 Then
            If Not HasSpell(index, 112) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 112
                PlayerMsg index, "Você acabou de aprender " & Spell(112).Name, BrightBlue
            End If
        
        End If
    
    Case 12 'Sabaku
        If GetPlayerLevel(index) >= 10 Then
            If Not HasSpell(index, 114) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 114
                PlayerMsg index, "Você acabou de aprender " & Spell(114).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 30 Then
            If Not HasSpell(index, 115) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 115
                PlayerMsg index, "Você acabou de aprender " & Spell(115).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 50 Then
            If Not HasSpell(index, 116) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 116
                PlayerMsg index, "Você acabou de aprender " & Spell(116).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 70 Then
            If Not HasSpell(index, 117) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 117
                PlayerMsg index, "Você acabou de aprender " & Spell(117).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 100 Then
            If Not HasSpell(index, 118) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 118
                PlayerMsg index, "Você acabou de aprender " & Spell(118).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 120 Then
            If Not HasSpell(index, 119) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 119
                PlayerMsg index, "Você acabou de aprender " & Spell(119).Name, BrightBlue
            End If
        
        End If
        
    Case 13 'Kankurou
        If GetPlayerLevel(index) >= 10 Then
            If Not HasSpell(index, 121) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 121
                PlayerMsg index, "Você acabou de aprender " & Spell(121).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 30 Then
            If Not HasSpell(index, 122) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 122
                PlayerMsg index, "Você acabou de aprender " & Spell(122).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 50 Then
            If Not HasSpell(index, 123) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 123
                PlayerMsg index, "Você acabou de aprender " & Spell(123).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 70 Then
            If Not HasSpell(index, 124) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 124
                PlayerMsg index, "Você acabou de aprender " & Spell(124).Name, BrightBlue
            End If
        End If
        
    Case 14 'Temari
        
        If GetPlayerLevel(index) >= 10 Then
            If Not HasSpell(index, 126) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 126
                PlayerMsg index, "Você acabou de aprender " & Spell(126).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 30 Then
            If Not HasSpell(index, 127) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 127
                PlayerMsg index, "Você acabou de aprender " & Spell(127).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 50 Then
            If Not HasSpell(index, 128) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 128
                PlayerMsg index, "Você acabou de aprender " & Spell(128).Name, BrightBlue
            End If
        End If
        If GetPlayerLevel(index) >= 70 Then
            If Not HasSpell(index, 129) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), 129
                PlayerMsg index, "Você acabou de aprender " & Spell(129).Name, BrightBlue
            End If
        
        End If
    
    Case Else
End Select

End Sub


Public Sub AtualizarTop(ByVal index As Long)
'On Error Resume Next
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If GetPlayerAccess(index) > 1 Then Exit Sub

Dim i As Byte
Dim n As Byte

For n = 1 To 20
    If TopLvl(n).Nome = GetPlayerName(index) Then
        i = n
        Exit For
    End If
Next

    If i > 1 And i < 21 Then
        If TopLvl(i - 1).Nivel < GetPlayerLevel(index) Then
            TopLvl(i).Nivel = TopLvl(i - 1).Nivel
            TopLvl(i).Nome = TopLvl(i - 1).Nome
            TopLvl(i - 1).Nivel = GetPlayerLevel(index)
            TopLvl(i - 1).Nome = GetPlayerName(index)
            GlobalMsg GetPlayerName(index) & " subiu para o " & i - 1 & "° lugar no Top Ninja!(digite /top)", BrightCyan
            SalvarTop
        Else
            TopLvl(i).Nivel = GetPlayerLevel(index)
            TopLvl(i).Nome = GetPlayerName(index)
            SalvarTop
        End If
    Else
        If Not GetPlayerName(index) = TopLvl(1).Nome Then
            If GetPlayerLevel(index) > TopLvl(20).Nivel Then
                TopLvl(20).Nome = GetPlayerName(index)
                TopLvl(20).Nivel = GetPlayerLevel(index)
                GlobalMsg GetPlayerName(index) & " subiu para o 20° lugar no Top Ninja!(digite /top)", BrightCyan
                SalvarTop
            End If
        End If
        
        If i = 1 Then
            TopLvl(1).Nome = GetPlayerName(index)
            TopLvl(1).Nivel = GetPlayerLevel(index)
            SalvarTop
        End If
    End If
    
CarregarTop

For i = 1 To Player_HighIndex
    SendTopPic i
Next

AtualizarTopChar index

End Sub

Public Sub AtualizarTopChar(ByVal index As Long)
'On Error Resume Next
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If GetPlayerAccess(index) > 1 Then Exit Sub

Dim i As Byte
Dim n As Byte

For i = 1 To Max_Classes
    If GetPlayerClass(index) = i Then
        If Not TopChar(i).Nome = GetPlayerName(index) Then
            If GetPlayerLevel(index) > TopChar(i).Level Then
                TopChar(i).Nome = GetPlayerName(index)
                TopChar(i).Level = GetPlayerLevel(index)
                GlobalMsg GetPlayerName(index) & " é o player mais forte com o Personagem: " & Class(i).Name, BrightCyan
                SalvarTopChar
            End If
        Else
            TopChar(i).Level = GetPlayerLevel(index)
            SalvarTopChar
        End If
    Exit For
    End If
Next
                
End Sub

Public Sub CarregarTop()
'On Error Resume Next
Dim i As Byte

For i = 1 To 20
    TopLvl(i).Nome = GetVar(App.Path & "\Tops\top.txt", "TOP" & i, "Nome")
    TopLvl(i).Nivel = GetVar(App.Path & "\Tops\top.txt", "TOP" & i, "Level")
Next

End Sub

Public Sub SalvarTop()
'On Error Resume Next
Dim i As Byte

For i = 1 To 20
    PutVar App.Path & "\Tops\top.txt", "TOP" & i, "Nome", TopLvl(i).Nome
    PutVar App.Path & "\Tops\top.txt", "TOP" & i, "Level", Trim(TopLvl(i).Nivel)
Next

End Sub

Public Sub CarregarKarma()
'On Error Resume Next
Dim i As Byte

For i = 1 To 10
    TopHero(i).Nome = GetVar(App.Path & "\Tops\HERO.txt", "HERO" & i, "Nome")
    TopHero(i).Pts = GetVar(App.Path & "\Tops\HERO.txt", "HERO" & i, "PTS")
    
    TopPK(i).Nome = GetVar(App.Path & "\Tops\PK.txt", "PK" & i, "Nome")
    TopPK(i).Pts = GetVar(App.Path & "\Tops\PK.txt", "PK" & i, "PTS")
Next

End Sub

Public Sub SalvarKarma()
'On Error Resume Next
Dim i As Byte

For i = 1 To 10
    PutVar App.Path & "\Tops\HERO.txt", "HERO" & i, "Nome", TopHero(i).Nome
    PutVar App.Path & "\Tops\HERO.txt", "HERO" & i, "PTS", Trim(TopHero(i).Pts)
    
    PutVar App.Path & "\Tops\PK.txt", "PK" & i, "Nome", TopPK(i).Nome
    PutVar App.Path & "\Tops\PK.txt", "PK" & i, "PTS", Trim(TopPK(i).Pts)
Next

End Sub

Public Sub Torneios(ByVal index As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
'If Torneio = "cs" Then Exit Sub

Dim Ok As Byte
Select Case Torneio
    Case vbNullString
        PlayerMsg index, "Não está tendo nenhum evento!", BrightRed
    
    Case "cs"
        If Player(index).Rank = RANK_DESERTOR And Not GetPlayerAccess(index) > 1 Then
            PlayerMsg index, "Desertores não podem participar desse Torneio!", BrightRed
            Exit Sub
        End If
    
        If Player(index).Rank = RANK_GENIN Or GetPlayerAccess(index) > 1 Then
            If GetPlayerLevel(index) >= 100 Then
                PlayerWarp index, 57, 17, 6
            Else
                PlayerMsg index, "Precisa ser pelo menos level 100!", BrightRed
            End If
        Else
            PlayerMsg index, "Precisa ser Genin!", BrightRed
        End If
        
    Case "js"
        If Player(index).Rank = RANK_DESERTOR And Not GetPlayerAccess(index) > 1 Then
            PlayerMsg index, "Desertores não podem participar desse Torneio!", BrightRed
            Exit Sub
        End If
        
        If Player(index).Rank = RANK_CHUNIN Then
            PlayerMsg index, "Espere o GM começar..Boa sorte!", White
            Ok = YES
        Else
            PlayerMsg index, "Precisa ser Chunin!", BrightRed
        End If
    
    Case "as" 'Anbu Shiken
        If Player(index).Rank = RANK_DESERTOR And Not GetPlayerAccess(index) > 1 Then
            PlayerMsg index, "Desertores não podem participar desse Torneio!", BrightRed
            Exit Sub
        End If
    
        If Player(index).Rank = RANK_JOUNIN Then
            PlayerMsg index, "Espere o GM começar..Boa sorte!", White
            Ok = YES
        Else
            PlayerMsg index, "Precisa ser Jounin!", BrightRed
        End If
        
    Case "ss" 'Sannin Shiken
        If Player(index).Rank = RANK_DESERTOR And Not GetPlayerAccess(index) > 1 Then
            PlayerMsg index, "Desertores não podem participar desse Torneio!", BrightRed
            Exit Sub
        End If
    
        
            If Player(index).Rank = RANK_ANBU Then
                PlayerMsg index, "Espere o GM começar..Boa sorte!", White
                Ok = YES
            Else
                PlayerMsg index, "Precisa ser ANBU!", BrightRed
            End If
    
    Case "KageKonoha"
        If Player(index).Vila = 1 Then 'Konoha
            If Player(index).Rank = RANK_SANNIN Then
                PlayerMsg index, "Espere o GM começar..Boa sorte!", White
                Ok = YES
            Else
                PlayerMsg index, "Precisa ser no mínimo Sannin!", BrightRed
            End If
        Else
            PlayerMsg index, "Precisa ser de Konoha!", BrightRed
        End If
        
    Case "KageSuna"
        If Player(index).Vila = 2 Then 'Suna
            If Player(index).Rank = RANK_SANNIN Then
                PlayerMsg index, "Espere o GM começar..Boa sorte!", White
                Ok = YES
            Else
                PlayerMsg index, "Precisa ser no mínimo Sannin!", BrightRed
            End If
        Else
            PlayerMsg index, "Precisa ser de Suna!", BrightRed
        End If
        
    Case "KageKiri"
        If Player(index).Vila = 3 Then 'Kiri
            If Player(index).Rank = RANK_SANNIN Then
                PlayerMsg index, "Espere o GM começar..Boa sorte!", White
                Ok = YES
            Else
                PlayerMsg index, "Precisa ser no mínimo Sannin!", BrightRed
            End If
        Else
            PlayerMsg index, "Precisa ser de Kiri!", BrightRed
        End If
    
    Case "KageIwa"
        If Player(index).Vila = 4 Then 'Iwa
            If Player(index).Rank = RANK_SANNIN Then
                PlayerMsg index, "Espere o GM começar..Boa sorte!", White
                Ok = YES
            Else
                PlayerMsg index, "Precisa ser no mínimo Sannin!", BrightRed
            End If
        Else
            PlayerMsg index, "Precisa ser de Iwa!", BrightRed
        End If
        
    Case "KageKumo"
        If Player(index).Vila = 5 Then 'Kumo
            If Player(index).Rank = RANK_SANNIN Then
                PlayerMsg index, "Espere o GM começar..Boa sorte!", White
                Ok = YES
            Else
                PlayerMsg index, "Precisa ser no mínimo Sannin!", BrightRed
            End If
        Else
            PlayerMsg index, "Precisa ser de Kumo!", BrightRed
        End If
    
    Case "KageChuva"
        If Player(index).Vila = 0 Then 'Chuva
            If GetPlayerLevel(index) > 700 Then
                PlayerMsg index, "Espere o GM começar..Boa sorte!", White
                Ok = YES
            Else
                PlayerMsg index, "Precisa ter no mínimo level 700!", BrightRed
            End If
        Else
            PlayerMsg index, "Precisa ser desertor!", BrightRed
        End If
    
    Case "Torneio"
        If GetPlayerLevel(index) < 100 Then
            PlayerMsg index, "Apenas lvl 100+", BrightRed
            Exit Sub
        End If
        
        PlayerWarp index, 100, 7, 7
        Ok = YES
        
    Case Else
        PlayerMsg index, "Contate o adm..Ocorreu um erro no comando /torneio!", Cyan
End Select

If GetPlayerAccess(index) > 1 Then
    Ok = YES
End If

If Ok = YES Then
    TempPlayer(index).InTorneio = YES
    PlayerWarp index, 98, 10, 8
End If
End Sub

Public Sub CheckAreaVIP(ByVal index As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
Dim mapNum As Integer

mapNum = GetPlayerMap(index)
If mapNum < 1 Or mapNum > MAX_MAPS Then Exit Sub

Select Case mapNum
    Case 83, 84, 85, 86, 154, 155, 156
        If Player(index).VipData.VIP < 1 Then
            PlayerWarp index, 99, 10, 6 'Atendimento
            PlayerMsg index, "Área VIP só para membros VIP!", BrightRed
        End If
    Case Else
    
End Select

End Sub

Public Sub CheckBAN(ByVal index As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If Not Player(index).Ban.Ban = YES Then Exit Sub
If GetPlayerAccess(index) > 1 Then Exit Sub 'ADM não cai nessa '-'

If Player(index).Ban.Data = vbNullString Then
    AlertMsg index, "Vocês está BANIDO!"
    ClearPlayer index
    Exit Sub
End If

Player(index).Ban.Dias = Trim(DateDiff("d", Date, Player(index).Ban.Data))

If Player(index).Ban.Dias < 1 Then
    Player(index).Ban.Ban = NO
    Player(index).Ban.Data = vbNullString
    Player(index).Ban.Dias = vbNullString
    PlayerMsg index, "Seu tempo como Banido expirou!Pense 2x antes de fazer algo errado!", BrightRed
    SendPlayerData index
    SavePlayer index
    Exit Sub
End If

AlertMsg index, "Você ainda está banido por :" & Player(index).Ban.Dias & " dias!"
ClearPlayer index

End Sub

Public Sub CheckVIP(ByVal index As Long)

If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If Player(index).VipData.VIP < 1 Then Exit Sub
If Player(index).VipData.DiasVIP = vbNullString Then Exit Sub
If Player(index).VipData.DataVIP = vbNullString Then Exit Sub

On Error GoTo ERRO
Player(index).VipData.DiasVIP = Trim(DateDiff("d", Date, Player(index).VipData.DataVIP))

If Player(index).VipData.DiasVIP < 1 Then
    Player(index).VipData.VIP = NO
    Player(index).VipData.DataVIP = vbNullString
    Player(index).VipData.DiasVIP = vbNullString
    PlayerMsg index, "Seu VIP expirou! Muito obrigado por ajudar a família NIP!", BrightRed
    SendPlayerData index
    SavePlayer index
    Exit Sub
End If

'PlayerMsg index, "Você ainda têm: " & Player(index).VipData.DiasVIP & " dia(s) de VIP!", BrightGreen

ERRO:
'Acho que é por causa da data ter passado o limite de dias..
If Not Len(Player(index).VipData.DataVIP) = 10 Then
    PutVar App.Path & "\VipBugado.txt", GetPlayerLogin(index), "Data", Player(index).VipData.DataVIP
End If
Exit Sub

End Sub

Public Sub CheckCT(ByVal index As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If Player(index).CTdata.CT < 1 Then Exit Sub
If Player(index).CTdata.DiasCT = vbNullString Then Exit Sub
If Player(index).CTdata.DataCT = vbNullString Then Exit Sub

Player(index).CTdata.DiasCT = Trim(DateDiff("d", Date, Player(index).CTdata.DataCT))

If Player(index).CTdata.DiasCT < 1 Then
    Player(index).CTdata.CT = NO
    Player(index).CTdata.DataCT = vbNullString
    Player(index).CTdata.DiasCT = vbNullString
    PlayerMsg index, "Seu passe para o CT expirou! Muito obrigado por ajudar a família NIP!", BrightRed
    SavePlayer index
    Exit Sub
End If

'PlayerMsg index, "Você ainda têm: " & Player(index).CTdata.DiasCT & " dia(s) de treino no CT!", BrightGreen

End Sub
