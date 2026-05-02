Attribute VB_Name = "modServerLoop"
Option Explicit

' halts thread of execution
Public Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)

Sub ServerLoop()
    Dim i As Long, X As Long
    Dim Tick As Long, TickCPS As Long, CPS As Long, FrameTime As Long
    Dim tmr25 As Long, tmr500 As Long, tmr1000 As Long, tmr120000 As Long
    Dim LastUpdateSavePlayers, LastUpdateMapSpawnItems As Long, LastUpdatePlayerVitals As Long

    ServerOnline = True

    Do While ServerOnline
        Tick = GetTickCount
        ElapsedTime = Tick - FrameTime
        FrameTime = Tick
        
        If Tick > tmr120000 Then
            
            For i = 1 To MAX_PLAYERS
                AntiFK(i) = vbNullString
            Next
            
            tmr120000 = GetTickCount + 120000
        End If
        
        If Tick > tmr25 Then
            For i = 1 To Player_HighIndex
                If IsPlaying(i) Then
                    ' check if they've completed casting, and if so set the actual spell going
                    If TempPlayer(i).spellBuffer.Spell > 0 And Not TempPlayer(i).SpellDelay > 0 Then
                        
                            If GetTickCount > TempPlayer(i).spellBuffer.Timer + (Spell(Player(i).Spell(TempPlayer(i).spellBuffer.Spell)).CastTime * 1000) Then
                                CastSpell i, TempPlayer(i).spellBuffer.Spell, TempPlayer(i).spellBuffer.Target, TempPlayer(i).spellBuffer.tType
                                TempPlayer(i).spellBuffer.Spell = 0
                                TempPlayer(i).spellBuffer.Timer = 0
                                TempPlayer(i).spellBuffer.Target = 0
                                TempPlayer(i).spellBuffer.tType = 0
                                TempPlayer(i).SpellDelay = GetTickCount + 1000
                            End If
                    
                    End If
                    ' check if need to turn off stunned
                    If TempPlayer(i).StunDuration > 0 Then
                        If GetTickCount > TempPlayer(i).StunTimer + (TempPlayer(i).StunDuration) Then
                            TempPlayer(i).StunDuration = 0
                            TempPlayer(i).StunTimer = 0
                            SendStunned i
                        End If
                    End If
                    ' check regen timer
                    If TempPlayer(i).stopRegen Then
                        If TempPlayer(i).stopRegenTimer + 5000 < GetTickCount Then
                            TempPlayer(i).stopRegen = False
                            TempPlayer(i).stopRegenTimer = 0
                        End If
                    End If
                    ' HoT and DoT logic
                    For X = 1 To MAX_DOTS
                        HandleDoT_Player i, X
                        HandleHoT_Player i, X
                    Next
                    
                    'If Player(i).Trans > 0 Then
                        'If TempPlayer(i).Aura > 0 Then
                            'If Tick > TempPlayer(i).Aura Then
                                'SendAnimation GetPlayerMap(i), 2, 0, 0, TARGET_TYPE_PLAYER, i
                                'TempPlayer(i).Aura = 0
                            'End If
                        'Else
                            'TempPlayer(i).Aura = GetTickCount + 4000
                        'End If
                    'End If
                    
                    If TempPlayer(i).Kawarimi > 0 Then
                        If Tick > TempPlayer(i).Kawarimi Then
                            TempPlayer(i).Kawarimi = 0
                            PlayerMsg i, "O tempo do Kawarimi acabou..", Grey
                        End If
                    End If
                    
                    If TempPlayer(i).SharinganCopy > 0 Then
                        If Tick > TempPlayer(i).SharinganCopy Then
                            TempPlayer(i).SharinganCopy = 0
                            PlayerMsg i, "O tempo do Sharingan Copy acabou..", Grey
                        End If
                    End If
                    
                    If TempPlayer(i).Henge > 0 Then
                        If Tick > TempPlayer(i).Henge Then
                            SendAnimation GetPlayerMap(i), 20, 0, 0, TARGET_TYPE_PLAYER, i
                            TempPlayer(i).Henge = 0
                            SetPlayerSprite i, TempPlayer(i).MySprite
                            SendPlayerData i
                        End If
                    End If
                    
                    For X = 1 To 5
                        If TempPlayer(i).Dojutsu(X) > 0 Then
                            If Tick > TempPlayer(i).Dojutsu(X) Then
                                TirarDojutsu i, X
                                PlayerMsg i, "O tempo de sua Técnica especial acabou..", DarkGrey
                            End If
                        End If
                    Next
                    
                    If TempPlayer(i).NoDamage > 0 Then
                        If Tick > TempPlayer(i).NoDamage Then
                            TempPlayer(i).NoDamage = 0
                        End If
                    End If
                    
                    If TempPlayer(i).hitNpcUp > 0 Then
                        If Tick > TempPlayer(i).hitNpcUp Then
                            TempPlayer(i).hitNpcUp = 0
                        End If
                    End If
                    
                    If TempPlayer(i).playerAttackerOrVictim > 0 Then
                        If Tick > TempPlayer(i).playerAttackerOrVictim Then
                            TempPlayer(i).playerAttackerOrVictim = NO
                        End If
                    End If
                    
                    If TempPlayer(i).Reflect > 0 Then
                        If Tick > TempPlayer(i).Reflect Then
                            TempPlayer(i).Reflect = 0
                            Select Case GetPlayerClass(i)
                                Case SASUKE, MADARA, ITACHI
                                    PlayerMsg i, "Tempo do Susano'o acabou..", Green
                                    If Not GetPlayerSprite(i) = TempPlayer(i).MySprite Then
                                        SetPlayerSprite i, TempPlayer(i).MySprite
                                        SendPlayerData i
                                    End If
                                Case BEE, YUGITO
                                    PlayerMsg i, "Tempo do modo Bijuu acabou..", Green
                                    If Not GetPlayerSprite(i) = TempPlayer(i).MySprite Then
                                        SetPlayerSprite i, TempPlayer(i).MySprite
                                        SendPlayerData i
                                    End If
                                Case RAIKAGE
                                    PlayerMsg i, "Tempo do modo Yoroi acabou..", Green
                                    If Not GetPlayerSprite(i) = TempPlayer(i).MySprite Then
                                        SetPlayerSprite i, TempPlayer(i).MySprite
                                        SendPlayerData i
                                    End If
                                Case HIDAN
                                    PlayerMsg i, "Tempo do modo Ritual acabou..", Green
                                    If Not GetPlayerSprite(i) = TempPlayer(i).MySprite Then
                                        SetPlayerSprite i, TempPlayer(i).MySprite
                                        SendPlayerData i
                                    End If
                                Case DANZOU
                                    PlayerMsg i, "Tempo do Izanagi acabou..", Green
                                Case Else
                                    PlayerMsg i, "Técnica Reflect acabou..", Green
                            End Select
                        End If
                    End If
                    
                    If TempPlayer(i).ArrowTime > 0 Then
                        If Tick > TempPlayer(i).ArrowTime Then
                            TempPlayer(i).ArrowTime = 0
                        End If
                    End If
                    
                    If TempPlayer(i).MsgDelay > 0 Then
                        If Tick > TempPlayer(i).MsgDelay Then
                            TempPlayer(i).MsgDelay = 0
                        End If
                    End If
                    
                    If TempPlayer(i).SpellDelay > 0 Then
                        If Tick > TempPlayer(i).SpellDelay Then
                            TempPlayer(i).SpellDelay = 0
                        End If
                    End If
                    
                    If TempPlayer(i).ExpelDelay > 0 Then
                        If Tick > TempPlayer(i).ExpelDelay Then
                            TempPlayer(i).ExpelDelay = 0
                        End If
                    End If
                    
                End If
            Next
            frmServer.lblCPS.Caption = "CPS: " & Format$(GameCPS, "#,###,###,###")
            tmr25 = GetTickCount + 25
        End If

        ' Check for disconnections every half second
        If Tick > tmr500 Then
            For i = 1 To MAX_PLAYERS
                If frmServer.Socket(i).state > sckConnected Then
                    Call CloseSocket(i)
                End If
            Next
            UpdateMapLogic
            tmr500 = GetTickCount + 500
        End If

        If Tick > tmr1000 Then
            'For i = 1 To Player_HighIndex
                'If TempPlayer(i).firstLogin = False Then
                    'TempPlayer(i).firstLogin = True
                    'SendPlayerData i
                    'GlobalMsg "foi", White
                'End If
            'Next
            
            If SegundosParaAtualizarEvento > 0 Then
                SegundosParaAtualizarEvento = SegundosParaAtualizarEvento + 1
                
                If SegundosParaAtualizarEvento = 2 Then 'inicio
                    GlobalMsg "A próxima luta ou atualização do evento será em 10 segundos!", White
                ElseIf SegundosParaAtualizarEvento = 9 Then '3 segundos faltando
                    GlobalMsg "3!", White
                ElseIf SegundosParaAtualizarEvento = 10 Then '2 segundos faltando
                    GlobalMsg "2!", White
                ElseIf SegundosParaAtualizarEvento = 11 Then '1 segundo faltando
                    GlobalMsg "1!", White
                ElseIf SegundosParaAtualizarEvento = 12 Then 'começa
                    SegundosParaAtualizarEvento = 0 'zera de novo
                    AtualizarEvento
                End If
            End If
            
            If SegundosLuta > 0 Then
                SegundosLuta = SegundosLuta + 1
                If SegundosLuta = 180 Then '3 minutos
                    GlobalMsg "2 minutos para acabar a luta e desclassificar os lutadores!", BrightCyan
                ElseIf SegundosLuta = 240 Then '4 minutos
                    GlobalMsg "1 minuto para acabar a luta e desclassificar os lutadores!", BrightCyan
                ElseIf SegundosLuta = 270 Then '30 segundos
                    GlobalMsg "30 segundos para acabar a luta!", BrightRed
                ElseIf SegundosLuta = 285 Then '15 segundos
                    GlobalMsg "15 segundos para acabar a luta!", BrightRed
                ElseIf SegundosLuta = 290 Then '10 segundos
                    GlobalMsg "10!", BrightRed
                ElseIf SegundosLuta = 295 Then '5 segundos
                    GlobalMsg "5!", BrightRed
                ElseIf SegundosLuta = 297 Then '3 segundos
                    GlobalMsg "3!", BrightRed
                ElseIf SegundosLuta = 298 Then '2 segundos
                    GlobalMsg "2!", BrightRed
                ElseIf SegundosLuta = 299 Then '1 segundos
                    GlobalMsg "1!", BrightRed
                ElseIf SegundosLuta = 300 Then '5 minutos~finalizar luta
                    GlobalMsg "Luta finalizada e lutadores desclassificados pela demora!", White
                    For i = 1 To Luta.PlayerQnt
                        If IsPlaying(Luta.Player(i)) Then
                            TirarTorneioData Luta.Player(i)
                            PlayerMsg Luta.Player(i), "Você foi desclassificado pela demora na luta. Mais sorte na próxima!", White
                            Player(Luta.Player(i)).InTorneio = NO
                            Atendimento Luta.Player(i)
                        End If
                    Next
                    
                    AtualizarEvento
                End If
            End If
            
            For i = 1 To 9
                If Arena(i).WaitTmr > 0 Then
                    If Tick > Arena(i).WaitTmr Then
                        '##zera a arena por passar do tempo
                        ZerarArena i
                    End If 'desafioanything
                End If
            Next
            
            EventoAutomatico
            If frmServer.chkEventActive.Value = YES Then
                If Hour(Now) = frmServer.txtEventHour.Text Then
                    GlobalMsg "Evento de EXP acabou ;/ ", Magenta
                    frmServer.txtEventoEXP.Text = "1"
                    frmServer.txtEventHour.Text = "0"
                    frmServer.chkEventActive.Value = NO
                End If
            'Else
                'If Hour(Now) > 0 Then
                    'EventoExpAutomatico
                'End If
            End If
            
            For i = 1 To Player_HighIndex
                If IsPlaying(i) Then
                    If TempPlayer(i).TempoTroca > 1 Then
                        TempPlayer(i).TempoTroca = TempPlayer(i).TempoTroca - 1
                    ElseIf TempPlayer(i).TempoTroca = 1 Then
                        TempPlayer(i).TempoTroca = NO
                        PlayerMsg i, "Agora você pode aceitar a troca.Verifique se está tudo como combinado antes de aceitar.", White
                    End If
                    
                    If TempPlayer(i).Contagem > 0 Then
                        Select Case TempPlayer(i).Contagem
                            Case 6 'Starting
                                SendContagem i, 6
                                TempPlayer(i).Contagem = 5
                            Case 5 'Ready
                                SendContagem i, 5
                                TempPlayer(i).Contagem = 4
                            Case 4 '3
                                SendContagem i, 4
                                TempPlayer(i).Contagem = 3
                            Case 3 '2
                                SendContagem i, 3
                                TempPlayer(i).Contagem = 2
                            Case 2 '1
                                SendContagem i, 2
                                TempPlayer(i).Contagem = 1
                            Case 1 'GO
                                SendContagem i, 1
                                TempPlayer(i).Contagem = 0
                            Case Else
                                PlayerMsg i, "Algo deu errado..", Red
                        End Select
                    End If
                End If
            Next
            
            If isShuttingDown Then
                Call HandleShutdown
            End If
            tmr1000 = GetTickCount + 1000
        End If
        
        For i = 1 To Player_HighIndex
            If IsPlaying(i) Then
                For X = 1 To MAX_PLAYER_PROJECTILES
                    If TempPlayer(i).ProjecTile(X).Pic > 0 Then
                        ' handle the projec tile
                        HandleProjecTile i, X
                    End If
                Next
            End If
        Next

        ' Checks to update player vitals every 5 seconds - Can be tweaked
        If Tick > LastUpdatePlayerVitals Then
            UpdatePlayerVitals
            LastUpdatePlayerVitals = GetTickCount + 5000
        End If

        ' Checks to spawn map items every 5 minutes - Can be tweaked
        If Tick > LastUpdateMapSpawnItems Then
            UpdateMapSpawnItems
            LastUpdateMapSpawnItems = GetTickCount + 300000
        End If

        ' Checks to save players every 5 minutes - Can be tweaked
        If Tick > LastUpdateSavePlayers Then
            UpdateSavePlayers
            LastUpdateSavePlayers = GetTickCount + 300000
        End If

        If Not CPSUnlock Then Sleep 1
        DoEvents
        'deletar esse doevents se usar o outro
        
        ' Calculate CPS
        If TickCPS < Tick Then
            GameCPS = CPS
            TickCPS = Tick + 1000
            CPS = 0
        Else
            CPS = CPS + 1
        End If
    Loop
End Sub

Private Sub UpdateMapSpawnItems()
    Dim X As Long
    Dim Y As Long

    ' ///////////////////////////////////////////
    ' // This is used for respawning map items //
    ' ///////////////////////////////////////////
    For Y = 1 To MAX_MAPS

        ' Make sure no one is on the map when it respawns
        If Not PlayersOnMap(Y) Then

            ' Clear out unnecessary junk
            For X = 1 To MAX_MAP_ITEMS
                Call ClearMapItem(X, Y)
            Next

            ' Spawn the items
            Call SpawnMapItems(Y)
            Call SendMapItemsToAll(Y)
        End If

        DoEvents
    Next

End Sub

Private Sub UpdateMapLogic()
    On Error Resume Next
    
    Dim i As Long, X As Long, mapNum As Long, n As Long, x1 As Long, y1 As Long
    Dim TickCount As Long, Damage As Long, DistanceX As Long, DistanceY As Long, NpcNum As Long
    Dim Target As Long, targetType As Byte, DidWalk As Boolean, Buffer As clsBuffer, Resource_index As Long
    Dim TargetX As Long, TargetY As Long, target_verify As Boolean

    For mapNum = 1 To MAX_MAPS
        ' items appearing to everyone
        For i = 1 To MAX_MAP_ITEMS
            If MapItem(mapNum, i).num > 0 Then
                If MapItem(mapNum, i).playerName <> vbNullString Then
                    ' make item public?
                    If MapItem(mapNum, i).playerTimer < GetTickCount Then
                        ' make it public
                        MapItem(mapNum, i).playerName = vbNullString
                        MapItem(mapNum, i).playerTimer = 0
                        ' send updates to everyone
                        SendMapItemsToAll mapNum
                    End If
                    ' despawn item?
                    If MapItem(mapNum, i).canDespawn Then
                        If MapItem(mapNum, i).despawnTimer < GetTickCount Then
                            ' despawn it
                            ClearMapItem i, mapNum
                            ' send updates to everyone
                            SendMapItemsToAll mapNum
                        End If
                    End If
                End If
            End If
        Next
        
        '  Close the doors
        If TickCount > TempTile(mapNum).DoorTimer + 5000 Then
            For x1 = 0 To Map(mapNum).MaxX
                For y1 = 0 To Map(mapNum).MaxY
                    If Map(mapNum).Tile(x1, y1).Type = TILE_TYPE_KEY And TempTile(mapNum).DoorOpen(x1, y1) = YES Then
                        TempTile(mapNum).DoorOpen(x1, y1) = NO
                        SendMapKeyToMap mapNum, x1, y1, 0
                    End If
                Next
            Next
        End If
        
        ' check for DoTs + hots
        For i = 1 To MAX_MAP_NPCS
            If MapNpc(mapNum).Npc(i).num > 0 Then
                For X = 1 To MAX_DOTS
                    HandleDoT_Npc mapNum, i, X
                    HandleHoT_Npc mapNum, i, X
                Next
            End If
        Next

        ' Respawning Resources
        If ResourceCache(mapNum).Resource_Count > 0 Then
            For i = 0 To ResourceCache(mapNum).Resource_Count
                Resource_index = Map(mapNum).Tile(ResourceCache(mapNum).ResourceData(i).X, ResourceCache(mapNum).ResourceData(i).Y).Data1

                If Resource_index > 0 Then
                    If ResourceCache(mapNum).ResourceData(i).ResourceState = 1 Or ResourceCache(mapNum).ResourceData(i).cur_health < 1 Then  ' dead or fucked up
                        If ResourceCache(mapNum).ResourceData(i).ResourceTimer + (Resource(Resource_index).RespawnTime * 1000) < GetTickCount Then
                            ResourceCache(mapNum).ResourceData(i).ResourceTimer = GetTickCount
                            ResourceCache(mapNum).ResourceData(i).ResourceState = 0 ' normal
                            ' re-set health to resource root
                            ResourceCache(mapNum).ResourceData(i).cur_health = Resource(Resource_index).health
                            SendResourceCacheToMap mapNum, i
                        End If
                    End If
                End If
            Next
        End If

        If PlayersOnMap(mapNum) = YES Then
            TickCount = GetTickCount
            
            For X = 1 To MAX_MAP_NPCS
                NpcNum = MapNpc(mapNum).Npc(X).num

                ' /////////////////////////////////////////
                ' // This is used for ATTACKING ON SIGHT //
                ' /////////////////////////////////////////
                ' Make sure theres a npc with the map
                If Map(mapNum).Npc(X) > 0 And MapNpc(mapNum).Npc(X).num > 0 Then

                    ' If the npc is a attack on sight, search for a player on the map
                    If Npc(NpcNum).Behaviour = NPC_BEHAVIOUR_ATTACKONSIGHT Or Npc(NpcNum).Behaviour = NPC_BEHAVIOUR_GUARD Or Npc(NpcNum).Behaviour = NPC_BEHAVIOUR_BOSS Or Npc(NpcNum).Behaviour = NPC_BEHAVIOUR_SUBORDINADO Then
                    
                        ' make sure it's not stunned
                        If Not MapNpc(mapNum).Npc(X).StunDuration > 0 Then
    
                            For i = 1 To Player_HighIndex
                                If IsPlaying(i) Then
                                    If GetPlayerMap(i) = mapNum And MapNpc(mapNum).Npc(X).Target = 0 And GetPlayerAccess(i) < ADMIN_MONITOR And Player(i).Invisivel = NO Then
                                        n = Npc(NpcNum).Range
                                        DistanceX = MapNpc(mapNum).Npc(X).X - GetPlayerX(i)
                                        DistanceY = MapNpc(mapNum).Npc(X).Y - GetPlayerY(i)
    
                                        ' Make sure we get a positive value
                                        If DistanceX < 0 Then DistanceX = DistanceX * -1
                                        If DistanceY < 0 Then DistanceY = DistanceY * -1
    
                                        ' Are they in range?  if so GET'M!
                                        If DistanceX <= n And DistanceY <= n Then
                                            If Npc(NpcNum).Behaviour = NPC_BEHAVIOUR_SUBORDINADO Or Npc(NpcNum).Behaviour = NPC_BEHAVIOUR_BOSS Or Npc(NpcNum).Behaviour = NPC_BEHAVIOUR_ATTACKONSIGHT Or GetPlayerPK(i) = YES Then
                                                'If Not Npc(NpcNum).AttackSay = "                    " Then
                                                    'Call PlayerMsg(i, Trim$(Npc(NpcNum).Name) & " says: " & Trim$(Npc(NpcNum).AttackSay), SayColor)
                                                'End If
                                                MapNpc(mapNum).Npc(X).targetType = 1 ' player
                                                MapNpc(mapNum).Npc(X).Target = i
                                            End If
                                        End If
                                    End If
                                End If
                            Next
                        End If
                    End If
                End If
                
                target_verify = False

                ' /////////////////////////////////////////////
                ' // This is used for NPC walking/targetting //
                ' /////////////////////////////////////////////
                ' Make sure theres a npc with the map
                If Map(mapNum).Npc(X) > 0 And MapNpc(mapNum).Npc(X).num > 0 Then
                    If MapNpc(mapNum).Npc(X).StunDuration > 0 Then
                        ' check if we can unstun them
                        If GetTickCount > MapNpc(mapNum).Npc(X).StunTimer + (MapNpc(mapNum).Npc(X).StunDuration) Then
                            MapNpc(mapNum).Npc(X).StunDuration = 0
                            MapNpc(mapNum).Npc(X).StunTimer = 0
                        End If
                    Else
                            
                        Target = MapNpc(mapNum).Npc(X).Target
                        targetType = MapNpc(mapNum).Npc(X).targetType
    
                        ' Check to see if its time for the npc to walk
                        If Npc(NpcNum).Behaviour <> NPC_BEHAVIOUR_SHOPKEEPER Then
                        
                            If targetType = 1 Then ' player
    
                                ' Check to see if we are following a player or not
                                If Target > 0 Then
        
                                    ' Check if the player is even playing, if so follow'm
                                    If IsPlaying(Target) And GetPlayerMap(Target) = mapNum Then
                                        DidWalk = False
                                        target_verify = True
                                        TargetY = GetPlayerY(Target)
                                        TargetX = GetPlayerX(Target)
                                    Else
                                        MapNpc(mapNum).Npc(X).targetType = 0 ' clear
                                        MapNpc(mapNum).Npc(X).Target = 0
                                    End If
                                End If
                            
                            ElseIf targetType = 2 Then 'npc
                                
                                If Target > 0 Then
                                    
                                    If MapNpc(mapNum).Npc(Target).num > 0 Then
                                        DidWalk = False
                                        target_verify = True
                                        TargetY = MapNpc(mapNum).Npc(Target).Y
                                        TargetX = MapNpc(mapNum).Npc(Target).X
                                    Else
                                        MapNpc(mapNum).Npc(X).targetType = 0 ' clear
                                        MapNpc(mapNum).Npc(X).Target = 0
                                    End If
                                End If
                            End If
                            
                            If target_verify Then
                                
                                i = Int(Rnd * 5)
    
                                ' Lets move the npc
                                Select Case i
                                    Case 0
    
                                        ' Up
                                        If MapNpc(mapNum).Npc(X).Y > TargetY And Not DidWalk Then
                                            If CanNpcMove(mapNum, X, DIR_UP) Then
                                                Call NpcMove(mapNum, X, DIR_UP, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If
    
                                        ' Down
                                        If MapNpc(mapNum).Npc(X).Y < TargetY And Not DidWalk Then
                                            If CanNpcMove(mapNum, X, DIR_DOWN) Then
                                                Call NpcMove(mapNum, X, DIR_DOWN, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If
    
                                        ' Left
                                        If MapNpc(mapNum).Npc(X).X > TargetX And Not DidWalk Then
                                            If CanNpcMove(mapNum, X, DIR_LEFT) Then
                                                Call NpcMove(mapNum, X, DIR_LEFT, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If
    
                                        ' Right
                                        If MapNpc(mapNum).Npc(X).X < TargetX And Not DidWalk Then
                                            If CanNpcMove(mapNum, X, DIR_RIGHT) Then
                                                Call NpcMove(mapNum, X, DIR_RIGHT, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If
    
                                    Case 1
    
                                        ' Right
                                        If MapNpc(mapNum).Npc(X).X < TargetX And Not DidWalk Then
                                            If CanNpcMove(mapNum, X, DIR_RIGHT) Then
                                                Call NpcMove(mapNum, X, DIR_RIGHT, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If
    
                                        ' Left
                                        If MapNpc(mapNum).Npc(X).X > TargetX And Not DidWalk Then
                                            If CanNpcMove(mapNum, X, DIR_LEFT) Then
                                                Call NpcMove(mapNum, X, DIR_LEFT, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If
    
                                        ' Down
                                        If MapNpc(mapNum).Npc(X).Y < TargetY And Not DidWalk Then
                                            If CanNpcMove(mapNum, X, DIR_DOWN) Then
                                                Call NpcMove(mapNum, X, DIR_DOWN, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If
    
                                        ' Up
                                        If MapNpc(mapNum).Npc(X).Y > TargetY And Not DidWalk Then
                                            If CanNpcMove(mapNum, X, DIR_UP) Then
                                                Call NpcMove(mapNum, X, DIR_UP, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If
    
                                    Case 2
    
                                        ' Down
                                        If MapNpc(mapNum).Npc(X).Y < TargetY And Not DidWalk Then
                                            If CanNpcMove(mapNum, X, DIR_DOWN) Then
                                                Call NpcMove(mapNum, X, DIR_DOWN, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If
    
                                        ' Up
                                        If MapNpc(mapNum).Npc(X).Y > TargetY And Not DidWalk Then
                                            If CanNpcMove(mapNum, X, DIR_UP) Then
                                                Call NpcMove(mapNum, X, DIR_UP, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If
    
                                        ' Right
                                        If MapNpc(mapNum).Npc(X).X < TargetX And Not DidWalk Then
                                            If CanNpcMove(mapNum, X, DIR_RIGHT) Then
                                                Call NpcMove(mapNum, X, DIR_RIGHT, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If
    
                                        ' Left
                                        If MapNpc(mapNum).Npc(X).X > TargetX And Not DidWalk Then
                                            If CanNpcMove(mapNum, X, DIR_LEFT) Then
                                                Call NpcMove(mapNum, X, DIR_LEFT, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If
    
                                    Case 3
    
                                        ' Left
                                        If MapNpc(mapNum).Npc(X).X > TargetX And Not DidWalk Then
                                            If CanNpcMove(mapNum, X, DIR_LEFT) Then
                                                Call NpcMove(mapNum, X, DIR_LEFT, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If
    
                                        ' Right
                                        If MapNpc(mapNum).Npc(X).X < TargetX And Not DidWalk Then
                                            If CanNpcMove(mapNum, X, DIR_RIGHT) Then
                                                Call NpcMove(mapNum, X, DIR_RIGHT, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If
    
                                        ' Up
                                        If MapNpc(mapNum).Npc(X).Y > TargetY And Not DidWalk Then
                                            If CanNpcMove(mapNum, X, DIR_UP) Then
                                                Call NpcMove(mapNum, X, DIR_UP, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If
    
                                        ' Down
                                        If MapNpc(mapNum).Npc(X).Y < TargetY And Not DidWalk Then
                                            If CanNpcMove(mapNum, X, DIR_DOWN) Then
                                                Call NpcMove(mapNum, X, DIR_DOWN, MOVING_WALKING)
                                                DidWalk = True
                                            End If
                                        End If
    
                                End Select
    
                                ' Check if we can't move and if Target is behind something and if we can just switch dirs
                                If Not DidWalk Then
                                    If MapNpc(mapNum).Npc(X).X - 1 = TargetX And MapNpc(mapNum).Npc(X).Y = TargetY Then
                                        If MapNpc(mapNum).Npc(X).Dir <> DIR_LEFT Then
                                            Call NpcDir(mapNum, X, DIR_LEFT)
                                        End If
    
                                        DidWalk = True
                                    End If
    
                                    If MapNpc(mapNum).Npc(X).X + 1 = TargetX And MapNpc(mapNum).Npc(X).Y = TargetY Then
                                        If MapNpc(mapNum).Npc(X).Dir <> DIR_RIGHT Then
                                            Call NpcDir(mapNum, X, DIR_RIGHT)
                                        End If
    
                                        DidWalk = True
                                    End If
    
                                    If MapNpc(mapNum).Npc(X).X = TargetX And MapNpc(mapNum).Npc(X).Y - 1 = TargetY Then
                                        If MapNpc(mapNum).Npc(X).Dir <> DIR_UP Then
                                            Call NpcDir(mapNum, X, DIR_UP)
                                        End If
    
                                        DidWalk = True
                                    End If
    
                                    If MapNpc(mapNum).Npc(X).X = TargetX And MapNpc(mapNum).Npc(X).Y + 1 = TargetY Then
                                        If MapNpc(mapNum).Npc(X).Dir <> DIR_DOWN Then
                                            Call NpcDir(mapNum, X, DIR_DOWN)
                                        End If
    
                                        DidWalk = True
                                    End If
    
                                    ' We could not move so Target must be behind something, walk randomly.
                                    If Not DidWalk Then
                                        i = Int(Rnd * 2)
    
                                        If i = 1 Then
                                            i = Int(Rnd * 4)
    
                                            If CanNpcMove(mapNum, X, i) Then
                                                Call NpcMove(mapNum, X, i, MOVING_WALKING)
                                            End If
                                        End If
                                    End If
                                End If
    
                            Else
                                i = Int(Rnd * 4)
    
                                If i = 1 Then
                                    i = Int(Rnd * 4)
    
                                    If CanNpcMove(mapNum, X, i) Then
                                        Call NpcMove(mapNum, X, i, MOVING_WALKING)
                                    End If
                                End If
                            End If
                        End If
                    End If
                End If

                ' /////////////////////////////////////////////
                ' // This is used for npcs to attack targets //
                ' /////////////////////////////////////////////
                ' Make sure theres a npc with the map
                If Map(mapNum).Npc(X) > 0 And MapNpc(mapNum).Npc(X).num > 0 Then
                    Target = MapNpc(mapNum).Npc(X).Target
                    targetType = MapNpc(mapNum).Npc(X).targetType

                    ' Check if the npc can attack the targeted player player
                    If Target > 0 Then
                    
                        If targetType = 1 Then ' player

                            ' Is the target playing and on the same map?
                            If IsPlaying(Target) And GetPlayerMap(Target) = mapNum Then
                                TryNpcAttackPlayer X, Target
                                
                                If TempPlayer(Target).TempPetSlot > 0 Then
                                    If X <> TempPlayer(Target).TempPetSlot Then
                                        MapNpc(mapNum).Npc(TempPlayer(Target).TempPetSlot).targetType = TARGET_TYPE_NPC
                                        MapNpc(mapNum).Npc(TempPlayer(Target).TempPetSlot).Target = X
                                    End If
                                End If
                                
                                If MapNpc(mapNum).Npc(X).num > 0 Then
                                If Npc(MapNpc(mapNum).Npc(X).num).OnSighScript > 0 Then
                                    NpcOnSigh Target, Npc(MapNpc(mapNum).Npc(X).num).OnSighScript, X
                                End If
                                End If
                                
                                If MapNpc(mapNum).Npc(X).num > 0 Then
                                If Npc(MapNpc(mapNum).Npc(X).num).SpellAnim > 0 Then
                                    If GetTickCount > MapNpc(mapNum).Npc(X).NpcSpell Then
                                        If Not MapNpc(mapNum).Npc(X).PetData.Owner = Target Then
                                            If Not MapNpc(mapNum).Npc(X).StunDuration > 0 Then
                                                NpcSpell mapNum, X, Npc(MapNpc(mapNum).Npc(X).num).SpellAnim, Target
                                                MapNpc(mapNum).Npc(X).NpcSpell = GetTickCount + Npc(MapNpc(mapNum).Npc(X).num).SpellCD * 1000
                                            End If
                                        End If
                                       
                                    End If
                                End If
                                End If
                                
                            Else
                                ' Player left map or game, set target to 0
                                MapNpc(mapNum).Npc(X).Target = 0
                                MapNpc(mapNum).Npc(X).targetType = 0 ' clear
                            End If
                        ElseIf targetType = 2 Then
                            ' lol no npc combat :( DATS WAT YOU THINK
                            
                            If Npc(MapNpc(mapNum).Npc(X).num).SpellAnim > 0 Then
                                        If GetTickCount > MapNpc(mapNum).Npc(X).NpcSpell Then
                                            If Not MapNpc(mapNum).Npc(X).StunDuration > 0 Then
                                                    NpcSpell mapNum, X, Npc(MapNpc(mapNum).Npc(X).num).SpellAnim, MapNpc(mapNum).Npc(X).Target
                                                    MapNpc(mapNum).Npc(X).NpcSpell = GetTickCount + Npc(MapNpc(mapNum).Npc(X).num).SpellCD * 1000
                                            End If
                                        End If
                            End If
                            
                            If MapNpc(mapNum).Npc(X).IsPet Then
                                If MapNpc(mapNum).Npc(X).PetData.Owner > 0 Then
                                    Select Case MapNpc(mapNum).Npc(X).num
                                        Case 120 'frog
                                            If CanNpcAttackNpc(mapNum, X, MapNpc(mapNum).Npc(X).Target) = True Then
                                                Call NpcAttackNpc(mapNum, X, MapNpc(mapNum).Npc(X).Target, GetPlayerStat(MapNpc(mapNum).Npc(X).PetData.Owner, Stats.strength) * 2 + Npc(Map(mapNum).Npc(X)).Damage / 5)
                                            End If
                                        Case 121 'Slug
                                            If CanNpcAttackNpc(mapNum, X, MapNpc(mapNum).Npc(X).Target) = True Then
                                                Call NpcAttackNpc(mapNum, X, MapNpc(mapNum).Npc(X).Target, GetPlayerStat(MapNpc(mapNum).Npc(X).PetData.Owner, Stats.Willpower) * 2 + Npc(Map(mapNum).Npc(X)).Damage / 5)
                                            End If
                                        Case 122 'snakE
                                            If CanNpcAttackNpc(mapNum, X, MapNpc(mapNum).Npc(X).Target) = True Then
                                                Call NpcAttackNpc(mapNum, X, MapNpc(mapNum).Npc(X).Target, GetPlayerStat(MapNpc(mapNum).Npc(X).PetData.Owner, Stats.Intelligence) * 2 + Npc(Map(mapNum).Npc(X)).Damage / 5)
                                            End If
                                        Case 124, 195 'Katsuyu,salamander.
                                            If CanNpcAttackNpc(mapNum, X, MapNpc(mapNum).Npc(X).Target) = True Then
                                                Call NpcAttackNpc(mapNum, X, MapNpc(mapNum).Npc(X).Target, GetPlayerStat(MapNpc(mapNum).Npc(X).PetData.Owner, Stats.Willpower) * 3.5 + Npc(Map(mapNum).Npc(X)).Damage / 5)
                                            End If
                                        Case 125, 191, 192, 196 'Manda,Shukaku,Sanbi
                                            If CanNpcAttackNpc(mapNum, X, MapNpc(mapNum).Npc(X).Target) = True Then
                                                Call NpcAttackNpc(mapNum, X, MapNpc(mapNum).Npc(X).Target, GetPlayerStat(MapNpc(mapNum).Npc(X).PetData.Owner, Stats.Intelligence) * 3.5 + Npc(Map(mapNum).Npc(X)).Damage / 5)
                                            End If
                                        Case 123, 190, 193, 194 'Gamabunta tai, kyuubi, yonbi, hachibi
                                            If CanNpcAttackNpc(mapNum, X, MapNpc(mapNum).Npc(X).Target) = True Then
                                                Call NpcAttackNpc(mapNum, X, MapNpc(mapNum).Npc(X).Target, GetPlayerStat(MapNpc(mapNum).Npc(X).PetData.Owner, Stats.strength) * 3.5 + Npc(Map(mapNum).Npc(X)).Damage / 5)
                                            End If
                                        Case Else
                                            If CanNpcAttackNpc(mapNum, X, MapNpc(mapNum).Npc(X).Target) = True Then
                                                If GetPlayerClass(MapNpc(mapNum).Npc(X).PetData.Owner) = KANKUROU Then
                                                    Call NpcAttackNpc(mapNum, X, MapNpc(mapNum).Npc(X).Target, RAND(1, GetPlayerStat(MapNpc(mapNum).Npc(X).PetData.Owner, Stats.strength) * 3.5 + Npc(Map(mapNum).Npc(X)).Damage / 5))
                                                Else
                                                    Call NpcAttackNpc(mapNum, X, MapNpc(mapNum).Npc(X).Target, GetPlayerStat(MapNpc(mapNum).Npc(X).PetData.Owner, Stats.strength) + Npc(Map(mapNum).Npc(X)).Damage / 5)
                                                End If
                                            End If
                                    End Select
                                Else
                                    If CanNpcAttackNpc(mapNum, X, MapNpc(mapNum).Npc(X).Target) = True Then
                                        Call NpcAttackNpc(mapNum, X, MapNpc(mapNum).Npc(X).Target, Npc(Map(mapNum).Npc(X)).Damage)
                                    End If
                                End If
                            Else
                            
                                If CanNpcAttackNpc(mapNum, X, MapNpc(mapNum).Npc(X).Target) = True Then
                                    Call NpcAttackNpc(mapNum, X, MapNpc(mapNum).Npc(X).Target, Npc(Map(mapNum).Npc(X)).Damage)
                                End If
                            End If
                        Else
                        
                        End If
                    End If
                End If

                ' ////////////////////////////////////////////
                ' // This is used for regenerating NPC's HP //
                ' ////////////////////////////////////////////
                ' Check to see if we want to regen some of the npc's hp
                If Not MapNpc(mapNum).Npc(X).stopRegen Then
                    If MapNpc(mapNum).Npc(X).num > 0 And TickCount > GiveNPCHPTimer + 10000 Then
                        If MapNpc(mapNum).Npc(X).Vital(Vitals.HP) > 0 Then
                            MapNpc(mapNum).Npc(X).Vital(Vitals.HP) = MapNpc(mapNum).Npc(X).Vital(Vitals.HP) + GetNpcVitalRegen(NpcNum, Vitals.HP)
    
                            ' Check if they have more then they should and if so just set it to max
                            If MapNpc(mapNum).Npc(X).Vital(Vitals.HP) > GetNpcMaxVital(NpcNum, Vitals.HP) Then
                                MapNpc(mapNum).Npc(X).Vital(Vitals.HP) = GetNpcMaxVital(NpcNum, Vitals.HP)
                            End If
                        End If
                    End If
                End If

                ' ////////////////////////////////////////////////////////
                ' // This is used for checking if an NPC is dead or not //
                ' ////////////////////////////////////////////////////////
                ' Check if the npc is dead or not
                'If MapNpc(y, x).Num > 0 Then
                '    If MapNpc(y, x).HP <= 0 And Npc(MapNpc(y, x).Num).STR > 0 And Npc(MapNpc(y, x).Num).DEF > 0 Then
                '        MapNpc(y, x).Num = 0
                '        MapNpc(y, x).SpawnWait = TickCount
                '   End If
                'End If
                
                ' //////////////////////////////////////
                ' // This is used for spawning an NPC //
                ' //////////////////////////////////////
                ' Check if we are supposed to spawn an npc or not
                If MapNpc(mapNum).Npc(X).num = 0 And Map(mapNum).Npc(X) > 0 Then
                    If TickCount > MapNpc(mapNum).Npc(X).SpawnWait + (Npc(Map(mapNum).Npc(X)).SpawnSecs * 1000) Then
                        Call SpawnNpc(X, mapNum)
                    End If
                End If

            Next

        End If

        DoEvents
    Next

    ' Make sure we reset the timer for npc hp regeneration
    If GetTickCount > GiveNPCHPTimer + 10000 Then
        GiveNPCHPTimer = GetTickCount
    End If

    ' Make sure we reset the timer for door closing
    If GetTickCount > KeyTimer + 15000 Then
        KeyTimer = GetTickCount
    End If

End Sub

Private Sub UpdatePlayerVitals()
Dim i As Long
    For i = 1 To Player_HighIndex
        If IsPlaying(i) Then
            If Not TempPlayer(i).stopRegen Then
                If GetPlayerVital(i, Vitals.HP) <> GetPlayerMaxVital(i, Vitals.HP) Then
                    Call SetPlayerVital(i, Vitals.HP, GetPlayerVital(i, Vitals.HP) + GetPlayerVitalRegen(i, Vitals.HP))
                    Call SendVital(i, Vitals.HP)
                    ' send vitals to party if in one
                    If TempPlayer(i).inParty > 0 Then SendPartyVitals TempPlayer(i).inParty, i
                End If
    
                If GetPlayerVital(i, Vitals.mp) <> GetPlayerMaxVital(i, Vitals.mp) Then
                    Call SetPlayerVital(i, Vitals.mp, GetPlayerVital(i, Vitals.mp) + GetPlayerVitalRegen(i, Vitals.mp))
                    Call SendVital(i, Vitals.mp)
                    ' send vitals to party if in one
                    If TempPlayer(i).inParty > 0 Then SendPartyVitals TempPlayer(i).inParty, i
                End If
            End If
        End If
    Next
End Sub

Private Sub UpdateSavePlayers()
    Dim i As Long

    If TotalOnlinePlayers > 0 Then
        Call TextAdd("Saving all online players...")
        AtualizarTops
        
        For i = 1 To Player_HighIndex

            If IsPlaying(i) Then
                Call SavePlayer(i)
                Call SaveBank(i)
                Noticias i
            End If

            DoEvents
        Next

    End If

End Sub

Private Sub HandleShutdown()

    If Secs <= 0 Then Secs = 10
    If Secs Mod 5 = 0 Or Secs <= 5 Then
        Call GlobalMsg("O game vai ser desligado em " & Secs & " segundos.Isso limpa o game em geral.", BrightBlue)
        Call TextAdd("Automated Server Shutdown in " & Secs & " seconds.")
    End If

    Secs = Secs - 1

    If Secs <= 0 Then
        Call GlobalMsg("Server Shutdown.", BrightRed)
        Call desligarServ
    End If

End Sub
