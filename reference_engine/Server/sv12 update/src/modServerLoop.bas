Attribute VB_Name = "modServerLoop"
Option Explicit

' halts thread of execution
Public Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)

Sub ServerLoop()
    Dim i As Long, X As Long
    Dim Tick As Long, TickCPS As Long, CPS As Long, FrameTime As Long
    Dim tmr25 As Long, tmr500 As Long, tmr1000 As Long
    Dim LastUpdateSavePlayers, LastUpdateMapSpawnItems As Long, LastUpdatePlayerVitals As Long

    ServerOnline = True

    Do While ServerOnline
        Tick = GetTickCount
        ElapsedTime = Tick - FrameTime
        FrameTime = Tick
        
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
                    
                    If TempPlayer(i).Henge > 0 Then
                        If Tick > TempPlayer(i).Henge Then
                            SendAnimation GetPlayerMap(i), 20, 0, 0, TARGET_TYPE_PLAYER, i
                            TempPlayer(i).Henge = 0
                            SetPlayerSprite i, TempPlayer(i).MySprite
                            SendPlayerData i
                        End If
                    End If
                    
                    For X = 1 To 4
                        If TempPlayer(i).Dojutsu(X) > 0 Then
                            If Tick > TempPlayer(i).Dojutsu(X) Then
                                TirarDojutsu i, X
                                PlayerMsg i, "O tempo de sua Técnica especial acabou..", DarkGrey
                            End If
                        End If
                    Next
                    
                    If TempPlayer(i).Reflect > 0 Then
                        If Tick > TempPlayer(i).Reflect Then
                            TempPlayer(i).Reflect = 0
                            PlayerMsg i, "Técnica Reflect acabou..", Green
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
                If frmServer.Socket(i).State > sckConnected Then
                    Call CloseSocket(i)
                End If
            Next
            UpdateMapLogic
            tmr500 = GetTickCount + 500
        End If

        If Tick > tmr1000 Then
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
                    If Npc(NpcNum).Behaviour = NPC_BEHAVIOUR_ATTACKONSIGHT Or Npc(NpcNum).Behaviour = NPC_BEHAVIOUR_GUARD Or Npc(NpcNum).Behaviour = NPC_BEHAVIOUR_BOSS Then
                    
                        ' make sure it's not stunned
                        If Not MapNpc(mapNum).Npc(X).StunDuration > 0 Then
    
                            For i = 1 To Player_HighIndex
                                If IsPlaying(i) Then
                                    If GetPlayerMap(i) = mapNum And MapNpc(mapNum).Npc(X).Target = 0 And GetPlayerAccess(i) <= ADMIN_MONITOR Then
                                        n = Npc(NpcNum).Range
                                        DistanceX = MapNpc(mapNum).Npc(X).X - GetPlayerX(i)
                                        DistanceY = MapNpc(mapNum).Npc(X).Y - GetPlayerY(i)
    
                                        ' Make sure we get a positive value
                                        If DistanceX < 0 Then DistanceX = DistanceX * -1
                                        If DistanceY < 0 Then DistanceY = DistanceY * -1
    
                                        ' Are they in range?  if so GET'M!
                                        If DistanceX <= n And DistanceY <= n Then
                                            If Npc(NpcNum).Behaviour = NPC_BEHAVIOUR_ATTACKONSIGHT Or GetPlayerPK(i) = YES Then
                                                If Not Npc(NpcNum).AttackSay = "                    " Then
                                                    Call PlayerMsg(i, Trim$(Npc(NpcNum).Name) & " says: " & Trim$(Npc(NpcNum).AttackSay), SayColor)
                                                End If
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
                                        Case 124 'Katsuyu
                                            If CanNpcAttackNpc(mapNum, X, MapNpc(mapNum).Npc(X).Target) = True Then
                                                Call NpcAttackNpc(mapNum, X, MapNpc(mapNum).Npc(X).Target, GetPlayerStat(MapNpc(mapNum).Npc(X).PetData.Owner, Stats.Willpower) * 3.5 + Npc(Map(mapNum).Npc(X)).Damage / 5)
                                            End If
                                        Case 125 'Manda
                                            If CanNpcAttackNpc(mapNum, X, MapNpc(mapNum).Npc(X).Target) = True Then
                                                Call NpcAttackNpc(mapNum, X, MapNpc(mapNum).Npc(X).Target, GetPlayerStat(MapNpc(mapNum).Npc(X).PetData.Owner, Stats.Intelligence) * 3.5 + Npc(Map(mapNum).Npc(X)).Damage / 5)
                                            End If
                                        Case Else
                                            If CanNpcAttackNpc(mapNum, X, MapNpc(mapNum).Npc(X).Target) = True Then
                                                Call NpcAttackNpc(mapNum, X, MapNpc(mapNum).Npc(X).Target, GetPlayerStat(MapNpc(mapNum).Npc(X).PetData.Owner, Stats.strength) * 3.5 + Npc(Map(mapNum).Npc(X)).Damage / 5)
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

        For i = 1 To Player_HighIndex

            If IsPlaying(i) Then
                Call SavePlayer(i)
                Call SaveBank(i)
                ZerarArenas
                Noticias i
            End If

            DoEvents
        Next

    End If

End Sub

Private Sub HandleShutdown()

    If Secs <= 0 Then Secs = 30
    If Secs Mod 5 = 0 Or Secs <= 5 Then
        Call GlobalMsg("Server Shutdown in " & Secs & " seconds.", BrightBlue)
        Call TextAdd("Automated Server Shutdown in " & Secs & " seconds.")
    End If

    Secs = Secs - 1

    If Secs <= 0 Then
        Call GlobalMsg("Server Shutdown.", BrightRed)
        Call DestroyServer
    End If

End Sub
