Attribute VB_Name = "modGameLogic"
Option Explicit

Public Sub GameLoop()
Dim FrameTime As Long
Dim Tick As Long
Dim TickFPS As Long
Dim FPS As Long
Dim i As Long
Dim WalkTimer As Long
Dim tmr25 As Long
Dim tmr100 As Long
Dim tmr10000 As Long
Dim tmrRenderGraphics As Long
Dim tmr1000 As Long '1 segundo

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    ' *** Start GameLoop ***
    Do While InGame
        Tick = GetTickCount                            ' Set the inital tick
        ElapsedTime = Tick - FrameTime                 ' Set the time difference for time-based movement
        FrameTime = Tick                               ' Set the time second loop time to the first.
        
        If tmr1000 < Tick Then
            frmMain.tmrAntHack.Enabled = True
            
            AntiSpeed2 = AntiSpeed2 + 1
            
            If AntiSpeed1 + AntiSpeedDif + 2 < AntiSpeed2 Then
                AntiSpeed1 = NO
                AntiSpeed2 = NO
                logoutGame
                MsgBox "CHEAT!FUHAEUUHAE. REINICIA O PC FERA!"
            End If
            
            If enableChatTmr > 0 And enableChatTmr < Tick Then
                frmMain.txtMyChat.Enabled = True
                SetFocusOnChat
                enableChatTmr = 0 'zera
            End If
            
            If cheatTimer <> 1 Then
                verificarCheat NO 'se a verificação do timer não funcionar, aqui chama no gameloop
            End If
            
            If Ready2GO > 0 Then
                Ready2GO = 0
                frmMain.picContagem.Visible = False
                COUNT_FREEZE = NO
            End If
            
            If InGame = True Then
                If GetPlayerAccess(MyIndex) < ADMIN_MONITOR Then 'Player
                    If CanKickBoot = True Then
                        AFK = AFK + 1
                    End If
                    
                    If CanKickBoot = True Then
                        captchaTmr = captchaTmr + 1
                    End If
                End If
                
                If AFK >= 60 * 15 Then
                    logoutGame
                    AntiSpeed1 = NO
                    AntiSpeed2 = NO
                    MsgBox "Você foi kikado por estar muito tempo ausente!", vbOKOnly, "Naruto Inner PoWEr !!!"
                    AFK = NO
                End If
                
                If captchaTmr > 60 * 10 And captcha = vbNullString Then
                    captcha = Trim$(Rand(1000, 9999))
                    frmMain.lblCaptcha.Caption = "" & captcha
                    frmMain.txtCaptcha.text = "Clique aqui e insira o código mostrado acima."
                    frmMain.picCaptcha.Visible = True
                End If
                
                If captchaTmr > 60 * 13 Then
                    AntiSpeed1 = NO
                    AntiSpeed2 = NO
                    frmMain.picCaptcha.Visible = False
                    captcha = vbNullString
                    captchaTmr = NO
                    logoutGame
                    MsgBox "Você foi kikado por não responder a verificação humana!", vbOKOnly, "Naruto Inner PoWEr !!!"
                End If
            End If
            
            For i = 1 To MAX_PLAYER_SPELLS
                If SpellCDTime(i) > 0 Then
                    SpellCDTime(i) = SpellCDTime(i) - 1
                    BltPlayerSpells
                    BltHotbar
                End If
            Next
            
            If StunDuration > 0 Then
                StunDuration = StunDuration - 1000
                frmMain.picStun.Visible = True
            Else
                frmMain.picStun.Visible = False
            End If
            
            tmr1000 = GetTickCount + 1000
        End If
        
        ' * Check surface timers *
        ' Sprites
        If tmr10000 < Tick Then

            ' characters
            If NumCharacters > 0 Then
                For i = 1 To NumCharacters    'Check to unload surfaces
                    If CharacterTimer(i) > 0 Then 'Only update surfaces in use
                        If CharacterTimer(i) < Tick Then   'Unload the surface
                            Call ZeroMemory(ByVal VarPtr(DDSD_Character(i)), LenB(DDSD_Character(i)))
                            Set DDS_Character(i) = Nothing
                            CharacterTimer(i) = 0
                        End If
                    End If
                Next
            End If
            
            ' Paperdolls
            If NumPaperdolls > 0 Then
                For i = 1 To NumPaperdolls    'Check to unload surfaces
                    If PaperdollTimer(i) > 0 Then 'Only update surfaces in use
                        If PaperdollTimer(i) < Tick Then   'Unload the surface
                            Call ZeroMemory(ByVal VarPtr(DDSD_Paperdoll(i)), LenB(DDSD_Paperdoll(i)))
                            Set DDS_Paperdoll(i) = Nothing
                            PaperdollTimer(i) = 0
                        End If
                    End If
                Next
            End If

            ' animations
            If NumAnimations > 0 Then
                For i = 1 To NumAnimations    'Check to unload surfaces
                    If AnimationTimer(i) > 0 Then 'Only update surfaces in use
                        If AnimationTimer(i) < Tick Then   'Unload the surface
                            Call ZeroMemory(ByVal VarPtr(DDSD_Animation(i)), LenB(DDSD_Animation(i)))
                            Set DDS_Animation(i) = Nothing
                            AnimationTimer(i) = 0
                        End If
                    End If
                Next
            End If

            ' Items
            If NumItems > 0 Then
                For i = 1 To NumItems    'Check to unload surfaces
                    If ItemTimer(i) > 0 Then 'Only update surfaces in use
                        If ItemTimer(i) < Tick Then   'Unload the surface
                            Call ZeroMemory(ByVal VarPtr(DDSD_Item(i)), LenB(DDSD_Item(i)))
                            Set DDS_Item(i) = Nothing
                            ItemTimer(i) = 0
                        End If
                    End If
                Next
            End If

            ' Resources
            If NumResources > 0 Then
                For i = 1 To NumResources    'Check to unload surfaces
                    If ResourceTimer(i) > 0 Then 'Only update surfaces in use
                        If ResourceTimer(i) < Tick Then   'Unload the surface
                            Call ZeroMemory(ByVal VarPtr(DDSD_Resource(i)), LenB(DDSD_Resource(i)))
                            Set DDS_Resource(i) = Nothing
                            ResourceTimer(i) = 0
                        End If
                    End If
                Next
            End If
            
            ' spell icons
            If NumSpellIcons > 0 Then
                For i = 1 To NumSpellIcons    'Check to unload surfaces
                    If SpellIconTimer(i) > 0 Then 'Only update surfaces in use
                        If SpellIconTimer(i) < Tick Then   'Unload the surface
                            Call ZeroMemory(ByVal VarPtr(DDSD_SpellIcon(i)), LenB(DDSD_SpellIcon(i)))
                            Set DDS_SpellIcon(i) = Nothing
                            SpellIconTimer(i) = 0
                        End If
                    End If
                Next
            End If
            
            ' faces
            If NumFaces > 0 Then
                For i = 1 To NumFaces    'Check to unload surfaces
                    If FaceTimer(i) > 0 Then 'Only update surfaces in use
                        If FaceTimer(i) < Tick Then   'Unload the surface
                            Call ZeroMemory(ByVal VarPtr(DDSD_Face(i)), LenB(DDSD_Face(i)))
                            Set DDS_Face(i) = Nothing
                            FaceTimer(i) = 0
                        End If
                    End If
                Next
            End If
            
            ' check ping
            Call GetPing
            Call DrawPing
            tmr10000 = Tick + 10000
        End If
        
        ' animate the autotiles
        Dim tmr250 As Long
        If tmr250 < Tick Then
            If autoAnim < 3 Then
                autoAnim = autoAnim + 1
            Else
                autoAnim = 0
            End If
            
            If ChatDelay < Tick Then
                ChatDelay = 0
            End If
            
            If HotBarDelay < Tick Then
                HotBarDelay = 0
            End If
            
            tmr250 = GetTickCount + 250
        End If

        If tmr25 < Tick Then
            InGame = IsConnected
            Call CheckKeys ' Check to make sure they aren't trying to auto do anything

            If GetForegroundWindow() = frmMain.hWnd Then
                Call CheckInputKeys ' Check which keys were pressed
            End If
            
            ' check if we need to end the CD icon
            If NumSpellIcons > 0 Then
                For i = 1 To MAX_PLAYER_SPELLS
                    If PlayerSpells(i) > 0 Then
                        If SpellCD(i) > 0 Then
                            If SpellCD(i) + (Spell(PlayerSpells(i)).CDTime * 1000) < Tick Then
                                SpellCD(i) = 0
                                BltPlayerSpells
                                BltHotbar
                            End If
                        End If
                    End If
                Next
            End If
            
            ' check if we need to unlock the player's spell casting restriction
            If SpellBuffer > 0 Then
                If SpellBufferTimer + (Spell(PlayerSpells(SpellBuffer)).CastTime * 1000) < Tick Then
                    SpellBuffer = 0
                    SpellBufferTimer = 0
                End If
            End If

            If CanMoveNow Then
                If frmMain.chkAtk.value = YES Then
                    ControlDown = True
                End If
                
                Call CheckMovement ' Check if player is trying to move
                Call CheckAttack   ' Check to see if player is trying to attack
            End If

            ' Change map animation every 250 milliseconds
            If MapAnimTimer < Tick Then
                MapAnim = Not MapAnim
                MapAnimTimer = Tick + 250
            End If
            
            ' Update inv animation
            If NumItems > 0 Then
                If tmr100 < Tick Then
                    BltAnimatedInvItems
                    tmr100 = Tick + 100
                End If
            End If
            
            For i = 1 To MAX_BYTE
                CheckAnimInstance i
            Next
            
            Dim X, Y As Long
            For X = 0 To MAP.MaxX
                For Y = 0 To MAP.MaxY
                    CheckMapAnim X, Y 'animação
                Next
            Next
            
            tmr25 = Tick + 25
        End If

        

        ' Process input before rendering, otherwise input will be behind by 1 frame
        If WalkTimer < Tick Then

            For i = 1 To Player_HighIndex
                If IsPlaying(i) Then
                    Call ProcessMovement(i)
                End If
            Next i

            ' Process npc movements (actually move them)
            For i = 1 To Npc_HighIndex
                If MAP.Npc(i) > 0 Or MapNpc(i).X > 0 Or MapNpc(i).Y > 0 Then
                    Call ProcessNpcMovement(i)
                End If
            Next i

            WalkTimer = Tick + 30 ' edit this value to change WalkTimer
        End If

        ' *********************
        ' ** Render Graphics **
        ' *********************
        If tmrRenderGraphics < Tick Then
            Call Render_Graphics
            tmrRenderGraphics = Tick + 15
        End If
        
        
        DoEvents

        ' Lock fps
        If Not FPS_Lock Then
            Do While GetTickCount < Tick + 15
                DoEvents
                Sleep 1
            Loop
        End If
        
        ' Calculate fps
        If TickFPS < Tick Then
            GameFPS = FPS
            TickFPS = Tick + 1000
            FPS = 0
        Else
            FPS = FPS + 1
        End If

    Loop

    frmMain.Visible = False

    If isLogging Then
        isLogging = False
        frmMain.picScreen.Visible = False
        frmMenu.Visible = True
        GettingMap = True
        StopMidi
        PlayMidi Options.MenuMusic
    Else
        ' Shutdown the game
        frmLoad.Visible = True
        Call SetStatus("Destroying game data...")
        Call DestroyGame
    End If

    ' Error handler
    Exit Sub
errorhandler:
    HandleError "GameLoop", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub ProcessMovement(ByVal Index As Long)
Dim MovementSpeed As Long
Dim Correr, Andar As Byte

Select Case Player(Index).trans
    Case 1
        Correr = 10
        Andar = 6
    Case 2
        Correr = 14
        Andar = 8
    Case 3
        Correr = 18
        Andar = 12
    Case 4
        Correr = 24
        Andar = 14
    Case 5
        Correr = 28
        Andar = 16
        
        If GetPlayerClass(Index) = GAI Then
            Correr = 32
            Andar = 24
        End If
    Case 6
        Correr = 32
        Andar = 24
    Case Else
        Correr = RUN_SPEED
        Andar = WALK_SPEED
End Select


    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    ' Check if player is walking, and if so process moving them over
    Select Case Player(Index).Moving
        Case MOVING_WALKING: MovementSpeed = ((ElapsedTime / 1000) * (Correr * SIZE_X))
        Case MOVING_RUNNING: MovementSpeed = ((ElapsedTime / 1000) * (Andar * SIZE_X))
        Case Else: Exit Sub
    End Select
    
    Select Case GetPlayerDir(Index)
        Case DIR_UP
            Player(Index).YOffset = Player(Index).YOffset - MovementSpeed
            If Player(Index).YOffset < 0 Then Player(Index).YOffset = 0
        Case DIR_DOWN
            Player(Index).YOffset = Player(Index).YOffset + MovementSpeed
            If Player(Index).YOffset > 0 Then Player(Index).YOffset = 0
        Case DIR_LEFT
            Player(Index).XOffset = Player(Index).XOffset - MovementSpeed
            If Player(Index).XOffset < 0 Then Player(Index).XOffset = 0
        Case DIR_RIGHT
            Player(Index).XOffset = Player(Index).XOffset + MovementSpeed
            If Player(Index).XOffset > 0 Then Player(Index).XOffset = 0
    End Select

    ' Check if completed walking over to the next tile
    If Player(Index).Moving > 0 Then
        If GetPlayerDir(Index) = DIR_RIGHT Or GetPlayerDir(Index) = DIR_DOWN Then
            If (Player(Index).XOffset >= 0) And (Player(Index).YOffset >= 0) Then
                Player(Index).Moving = 0
                If Player(Index).Step = 1 Then
                    Player(Index).Step = 3
                Else
                    Player(Index).Step = 1
                End If
            End If
        Else
            If (Player(Index).XOffset <= 0) And (Player(Index).YOffset <= 0) Then
                Player(Index).Moving = 0
                If Player(Index).Step = 1 Then
                    Player(Index).Step = 3
                Else
                    Player(Index).Step = 1
                End If
            End If
        End If
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "ProcessMovement", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub ProcessNpcMovement(ByVal MapNpcNum As Long)

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler

    ' Check if NPC is walking, and if so process moving them over
    If MapNpc(MapNpcNum).Moving = MOVING_WALKING Then
        
        Select Case MapNpc(MapNpcNum).Dir
            Case DIR_UP
                MapNpc(MapNpcNum).YOffset = MapNpc(MapNpcNum).YOffset - ((ElapsedTime / 1000) * (WALK_SPEED * SIZE_X))
                If MapNpc(MapNpcNum).YOffset < 0 Then MapNpc(MapNpcNum).YOffset = 0
                
            Case DIR_DOWN
                MapNpc(MapNpcNum).YOffset = MapNpc(MapNpcNum).YOffset + ((ElapsedTime / 1000) * (WALK_SPEED * SIZE_X))
                If MapNpc(MapNpcNum).YOffset > 0 Then MapNpc(MapNpcNum).YOffset = 0
                
            Case DIR_LEFT
                MapNpc(MapNpcNum).XOffset = MapNpc(MapNpcNum).XOffset - ((ElapsedTime / 1000) * (WALK_SPEED * SIZE_X))
                If MapNpc(MapNpcNum).XOffset < 0 Then MapNpc(MapNpcNum).XOffset = 0
                
            Case DIR_RIGHT
                MapNpc(MapNpcNum).XOffset = MapNpc(MapNpcNum).XOffset + ((ElapsedTime / 1000) * (WALK_SPEED * SIZE_X))
                If MapNpc(MapNpcNum).XOffset > 0 Then MapNpc(MapNpcNum).XOffset = 0
                
        End Select
    
        ' Check if completed walking over to the next tile
        If MapNpc(MapNpcNum).Moving > 0 Then
            If MapNpc(MapNpcNum).Dir = DIR_RIGHT Or MapNpc(MapNpcNum).Dir = DIR_DOWN Then
                If (MapNpc(MapNpcNum).XOffset >= 0) And (MapNpc(MapNpcNum).YOffset >= 0) Then
                    MapNpc(MapNpcNum).Moving = 0
                    If MapNpc(MapNpcNum).Step = 1 Then
                        MapNpc(MapNpcNum).Step = 3
                    Else
                        MapNpc(MapNpcNum).Step = 1
                    End If
                End If
            Else
                If (MapNpc(MapNpcNum).XOffset <= 0) And (MapNpc(MapNpcNum).YOffset <= 0) Then
                    MapNpc(MapNpcNum).Moving = 0
                    If MapNpc(MapNpcNum).Step = 1 Then
                        MapNpc(MapNpcNum).Step = 3
                    Else
                        MapNpc(MapNpcNum).Step = 1
                    End If
                End If
            End If
        End If
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "ProcessNpcMovement", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub CheckMapGetItem()
Dim buffer As New clsBuffer
Dim i As Long
Dim ok As Byte
ok = NO

    For i = 1 To MAX_MAP_ITEMS
        With MapItem(i)
            If .num > 0 Then
                If GetPlayerX(MyIndex) = .X And GetPlayerY(MyIndex) = .Y Then
                    ok = YES
                    Exit For
                End If
            End If
        End With
    Next
    
    If ok = NO Then Exit Sub
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    Set buffer = New clsBuffer

    If GetTickCount > Player(MyIndex).MapGetTimer + 250 Then
        If Trim$(MyText) = vbNullString Then
            Player(MyIndex).MapGetTimer = GetTickCount
            buffer.WriteLong CMapGetItem
            SendData buffer.ToArray()
        End If
    End If

    Set buffer = Nothing
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "CheckMapGetItem", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Sub CheckAttack()
Dim buffer As clsBuffer
Dim attackspeed As Long
Dim X As Byte

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    If ControlDown Then
    
        If SpellBuffer > 0 Then Exit Sub ' currently casting a spell, can't attack
        If StunDuration > 0 Then Exit Sub ' stunned, can't attack

        ' speed from weapon
        If GetPlayerEquipment(MyIndex, Weapon) > 0 Then
            attackspeed = Item(GetPlayerEquipment(MyIndex, Weapon)).Speed
        Else
            attackspeed = 1000
        End If

        If Player(MyIndex).AttackTimer + attackspeed < GetTickCount Then
            If Player(MyIndex).Attacking = 0 Then

                With Player(MyIndex)
                    .Attacking = 1
                    .AttackTimer = GetTickCount
                End With

                Set buffer = New clsBuffer
                buffer.WriteLong CAttack
                SendData buffer.ToArray()
                Set buffer = Nothing
                
                X = Rand(1, 8)
    
                PlaySound "Ataque" & X & ".wav"
            End If
        End If
    End If

    ' Error handler
    Exit Sub
errorhandler:
    HandleError "CheckAttack", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Function IsTryingToMove() As Boolean
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    If DirUp Or DirDown Or DirLeft Or DirRight Then
        IsTryingToMove = True
    End If

    ' Error handler
    Exit Function
errorhandler:
    HandleError "IsTryingToMove", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Function
End Function

Function CanMove() As Boolean
Dim d As Long
    
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    CanMove = True

    ' Make sure they aren't trying to move when they are already moving
    If Player(MyIndex).Moving <> 0 Then
        CanMove = False
        Exit Function
    End If

    ' Make sure they haven't just casted a spell
    'If SpellBuffer > 0 Then
        'CanMove = False
        'Exit Function
   ' End If
    
    ' make sure they're not stunned
    If StunDuration > 0 Then
        CanMove = False
        Exit Function
    End If
    
    ' make sure they're not in a shop
    If InShop > 0 Then
        CanMove = False
        Exit Function
    End If
    
    ' not in bank
    If InBank Then
        'CanMove = False
        'Exit Function
        InBank = False
        frmMain.picCover.Visible = False
        frmMain.picBank.Visible = False
    End If

    d = GetPlayerDir(MyIndex)

    If DirUp Then
        Call SetPlayerDir(MyIndex, DIR_UP)

        ' Check to see if they are trying to go out of bounds
        If GetPlayerY(MyIndex) > 0 Then
            If CheckDirection(DIR_UP) Then
                CanMove = False

                ' Set the new direction if they weren't facing that direction
                If d <> DIR_UP Then
                    Call SendPlayerDir
                End If

                Exit Function
            End If

        Else

            ' Check if they can warp to a new map
            If MAP.Up > 0 Then
                Call MapEditorLeaveMap
                Call SendPlayerRequestNewMap
                GettingMap = True
                CanMoveNow = False
            End If

            CanMove = False
            Exit Function
        End If
    End If

    If DirDown Then
        Call SetPlayerDir(MyIndex, DIR_DOWN)

        ' Check to see if they are trying to go out of bounds
        If GetPlayerY(MyIndex) < MAP.MaxY Then
            If CheckDirection(DIR_DOWN) Then
                CanMove = False

                ' Set the new direction if they weren't facing that direction
                If d <> DIR_DOWN Then
                    Call SendPlayerDir
                End If

                Exit Function
            End If

        Else

            ' Check if they can warp to a new map
            If MAP.Down > 0 Then
                Call MapEditorLeaveMap
                Call SendPlayerRequestNewMap
                GettingMap = True
                CanMoveNow = False
            End If

            CanMove = False
            Exit Function
        End If
    End If

    If DirLeft Then
        Call SetPlayerDir(MyIndex, DIR_LEFT)

        ' Check to see if they are trying to go out of bounds
        If GetPlayerX(MyIndex) > 0 Then
            If CheckDirection(DIR_LEFT) Then
                CanMove = False

                ' Set the new direction if they weren't facing that direction
                If d <> DIR_LEFT Then
                    Call SendPlayerDir
                End If

                Exit Function
            End If

        Else

            ' Check if they can warp to a new map
            If MAP.Left > 0 Then
                Call MapEditorLeaveMap
                Call SendPlayerRequestNewMap
                GettingMap = True
                CanMoveNow = False
            End If

            CanMove = False
            Exit Function
        End If
    End If

    If DirRight Then
        Call SetPlayerDir(MyIndex, DIR_RIGHT)

        ' Check to see if they are trying to go out of bounds
        If GetPlayerX(MyIndex) < MAP.MaxX Then
            If CheckDirection(DIR_RIGHT) Then
                CanMove = False

                ' Set the new direction if they weren't facing that direction
                If d <> DIR_RIGHT Then
                    Call SendPlayerDir
                End If

                Exit Function
            End If

        Else

            ' Check if they can warp to a new map
            If MAP.Right > 0 Then
                Call MapEditorLeaveMap
                Call SendPlayerRequestNewMap
                GettingMap = True
                CanMoveNow = False
            End If

            CanMove = False
            Exit Function
        End If
    End If

    ' Error handler
    Exit Function
errorhandler:
    HandleError "CanMove", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Function
End Function

Function CheckDirection(ByVal Direction As Byte) As Boolean
Dim X As Long
Dim Y As Long
Dim i As Long
On Error Resume Next

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    CheckDirection = False
    
    ' check directional blocking
  If Player(MyIndex).Voando = NO Then
    If isDirBlocked(MAP.Tile(GetPlayerX(MyIndex), GetPlayerY(MyIndex)).DirBlock, Direction + 1) Then
        CheckDirection = True
        Exit Function
    End If
  End If

    Select Case Direction
        Case DIR_UP
            X = GetPlayerX(MyIndex)
            Y = GetPlayerY(MyIndex) - 1
        Case DIR_DOWN
            X = GetPlayerX(MyIndex)
            Y = GetPlayerY(MyIndex) + 1
        Case DIR_LEFT
            X = GetPlayerX(MyIndex) - 1
            Y = GetPlayerY(MyIndex)
        Case DIR_RIGHT
            X = GetPlayerX(MyIndex) + 1
            Y = GetPlayerY(MyIndex)
    End Select

'If Player(MyIndex).Voando = NO Then
    ' Check to see if the map tile is blocked or not
    If MAP.Tile(X, Y).Type = TILE_TYPE_BLOCKED Then
        CheckDirection = True
        Exit Function
    End If

'End If

If Player(MyIndex).Voando = NO Then
    ' Check to see if the map tile is tree or not
    If MAP.Tile(X, Y).Type = TILE_TYPE_RESOURCE Then
        CheckDirection = True
        Exit Function
    End If
End If

 'If Player(MyIndex).Voando = NO Then
    ' Check to see if the key door is open or not
    If MAP.Tile(X, Y).Type = TILE_TYPE_KEY Then

        ' This actually checks if its open or not
        If TempTile(X, Y).DoorOpen = NO Then
            CheckDirection = True
            Exit Function
        End If
    End If

'End If
    
    
If Player(MyIndex).Voando = NO And Player(MyIndex).Invisivel = NO Then
    ' Check to see if a player is already on that tile
    If Not MAP.Moral = MAP_MORAL_SAFE Then
        For i = 1 To Player_HighIndex
            If IsPlaying(i) And GetPlayerMap(i) = GetPlayerMap(MyIndex) Then
                If GetPlayerX(i) = X Then
                    If GetPlayerY(i) = Y Then
                        If Player(i).Voando = NO And Player(i).Invisivel = NO Then
                            CheckDirection = True
                            Exit Function
                        End If
                    End If
                End If
            End If
        Next i
    Else 'temos que pegar
        For i = 1 To Player_HighIndex
            If IsPlaying(i) And GetPlayerMap(i) = GetPlayerMap(MyIndex) Then
                If GetPlayerX(i) = X Then
                    If GetPlayerY(i) = Y Then
                        If Player(i).Access < 2 And Player(i).Invisivel = NO Then
                            If GetPlayerSprite(MyIndex) = 380 Then 'ash
                                EmoteMsg 126, i
                            End If
                        End If
                    End If
                End If
            End If
        Next i
    End If
End If

    
If Player(MyIndex).Voando = NO Then
    ' Check to see if a npc is already on that tile
    If Not MAP.Moral = MAP_MORAL_SAFE Then
        For i = 1 To Npc_HighIndex
            If MapNpc(i).num > 0 Then
                If MapNpc(i).X = X Then
                    If MapNpc(i).Y = Y Then
                        CheckDirection = True
                        Exit Function
                    End If
                End If
            End If
        Next
    End If
End If

    ' Error handler
    Exit Function
errorhandler:
    HandleError "checkDirection", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Function
End Function

Sub CheckMovement()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    If IsTryingToMove Then
        AFK = 0
        'AddText "Seu tempo de ausencia foi zerado", White
        
        If CanMove Then

            ' Check if player has the shift key down for running
            If ShiftDown Then
                Player(MyIndex).Moving = MOVING_WALKING
            Else
                Player(MyIndex).Moving = MOVING_RUNNING
                    If frmMain.chkRun.value = YES Then
                        Player(MyIndex).Moving = MOVING_WALKING
                    End If
            End If

            Select Case GetPlayerDir(MyIndex)
                Case DIR_UP
                    Call SendPlayerMove
                    Player(MyIndex).YOffset = PIC_Y
                    Call SetPlayerY(MyIndex, GetPlayerY(MyIndex) - 1)
                Case DIR_DOWN
                    Call SendPlayerMove
                    Player(MyIndex).YOffset = PIC_Y * -1
                    Call SetPlayerY(MyIndex, GetPlayerY(MyIndex) + 1)
                Case DIR_LEFT
                    Call SendPlayerMove
                    Player(MyIndex).XOffset = PIC_X
                    Call SetPlayerX(MyIndex, GetPlayerX(MyIndex) - 1)
                Case DIR_RIGHT
                    Call SendPlayerMove
                    Player(MyIndex).XOffset = PIC_X * -1
                    Call SetPlayerX(MyIndex, GetPlayerX(MyIndex) + 1)
            End Select

            If Player(MyIndex).XOffset = 0 Then
                If Player(MyIndex).YOffset = 0 Then
                    If MAP.Tile(GetPlayerX(MyIndex), GetPlayerY(MyIndex)).Type = TILE_TYPE_WARP Then
                        GettingMap = True
                    End If
                End If
            End If
        End If
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "CheckMovement", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Function isInBounds()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    If (CurX >= 0) Then
        If (CurX <= MAP.MaxX) Then
            If (CurY >= 0) Then
                If (CurY <= MAP.MaxY) Then
                    isInBounds = True
                End If
            End If
        End If
    End If

    ' Error handler
    Exit Function
errorhandler:
    HandleError "isInBounds", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Function
End Function

Public Sub UpdateDrawMapName()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    DrawMapNameX = Camera.Left + ((MAX_MAPX + 1) * PIC_X / 2) - getWidth(TexthDC, Trim$(MAP.name))
    DrawMapNameY = Camera.top + 1

    Select Case MAP.Moral
        Case MAP_MORAL_NONE
            DrawMapNameColor = QBColor(BrightRed)
        Case MAP_MORAL_SAFE
            DrawMapNameColor = QBColor(White)
        Case Else
            DrawMapNameColor = QBColor(White)
    End Select

    ' Error handler
    Exit Sub
errorhandler:
    HandleError "UpdateDrawMapName", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Sub UseItem()
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    ' Check for subscript out of range
    If InventoryItemSelected < 1 Or InventoryItemSelected > MAX_INV Then
        Exit Sub
    End If

    Call SendUseItem(InventoryItemSelected)
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "UseItem", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Sub ForgetSpell(ByVal spellslot As Long)
Dim buffer As clsBuffer

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    ' Check for subscript out of range
    If spellslot < 1 Or spellslot > MAX_PLAYER_SPELLS Then
        Exit Sub
    End If
    
    ' dont let them forget a spell which is in CD
    If SpellCD(spellslot) > 0 Then
        AddText "Cannot forget a spell which is cooling down!", BrightRed
        Exit Sub
    End If
    
    ' dont let them forget a spell which is buffered
    If SpellBuffer = spellslot Then
        AddText "Cannot forget a spell which you are casting!", BrightRed
        Exit Sub
    End If
    
    If PlayerSpells(spellslot) > 0 Then
        Set buffer = New clsBuffer
        buffer.WriteLong CForgetSpell
        buffer.WriteLong spellslot
        SendData buffer.ToArray()
        Set buffer = Nothing
    Else
        AddText "No spell here.", BrightRed
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "ForgetSpell", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Sub CastSpell(ByVal spellslot As Long)
Dim buffer As clsBuffer

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    ' Check for subscript out of range
    If spellslot < 1 Or spellslot > MAX_PLAYER_SPELLS Then
        Exit Sub
    End If
    
    If SpellCD(spellslot) > 0 Or SpellBuffer > 0 Then
        'AddText "O jutsu ainda não está pronto para uso!", BrightRed
        Exit Sub
    End If
    
    If PlayerSpells(spellslot) = 0 Then Exit Sub

    ' Check if player has enough MP
    If GetPlayerVital(MyIndex, Vitals.MP) < Spell(PlayerSpells(spellslot)).MPCost Then
        Call AddText("Sem chakra suficiente para usar " & Trim$(Spell(PlayerSpells(spellslot)).name) & ".", BrightRed)
        Exit Sub
    End If

    If PlayerSpells(spellslot) > 0 Then
        If GetTickCount > Player(MyIndex).AttackTimer + 1000 Then
            'If Player(MyIndex).Moving = 0 Then
                Set buffer = New clsBuffer
                buffer.WriteLong CCast
                buffer.WriteLong spellslot
                SendData buffer.ToArray()
                Set buffer = Nothing
                SpellBuffer = spellslot
                SpellBufferTimer = GetTickCount
            'Else
                'Call AddText("Cannot cast while walking!", BrightRed)
            'End If
        End If
    Else
        Call AddText("No spell here.", BrightRed)
    End If

    ' Error handler
    Exit Sub
errorhandler:
    HandleError "CastSpell", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub ClearTempTile()
Dim X As Long
Dim Y As Long

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    ReDim TempTile(0 To MAP.MaxX, 0 To MAP.MaxY)

    For X = 0 To MAP.MaxX
        For Y = 0 To MAP.MaxY
            TempTile(X, Y).DoorOpen = NO
        Next
    Next

    ' Error handler
    Exit Sub
errorhandler:
    HandleError "ClearTempTile", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Sub DevMsg(ByVal text As String, ByVal color As Byte)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    If InGame Then
        If GetPlayerAccess(MyIndex) > ADMIN_DEVELOPER Then
            Call AddText(text, color)
        End If
    End If

    Debug.Print text
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "DevMsg", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Function TwipsToPixels(ByVal twip_val As Long, ByVal XorY As Byte) As Long
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    If XorY = 0 Then
        TwipsToPixels = twip_val / Screen.TwipsPerPixelX
    ElseIf XorY = 1 Then
        TwipsToPixels = twip_val / Screen.TwipsPerPixelY
    End If
    
    ' Error handler
    Exit Function
errorhandler:
    HandleError "TwipsToPixels", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Function
End Function

Public Function PixelsToTwips(ByVal pixel_val As Long, ByVal XorY As Byte) As Long
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    If XorY = 0 Then
        PixelsToTwips = pixel_val * Screen.TwipsPerPixelX
    ElseIf XorY = 1 Then
        PixelsToTwips = pixel_val * Screen.TwipsPerPixelY
    End If
    
    ' Error handler
    Exit Function
errorhandler:
    HandleError "PixelsToTwips", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Function
End Function

Public Function ConvertCurrency(ByVal Amount As Long) As String
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    If Int(Amount) < 10000 Then
        ConvertCurrency = Amount
    ElseIf Int(Amount) < 999999 Then
        ConvertCurrency = Int(Amount / 1000) & "k"
    ElseIf Int(Amount) < 999999999 Then
        ConvertCurrency = Int(Amount / 1000000) & "m"
    Else
        ConvertCurrency = Int(Amount / 1000000000) & "b"
    End If
    
    ' Error handler
    Exit Function
errorhandler:
    HandleError "ConvertCurrency", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Function
End Function

Sub DrawPing()
Dim PingToDraw As String

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    PingToDraw = Ping

    Select Case Ping
        Case -1
            PingToDraw = "Syncing"
        Case 0 To 5
            PingToDraw = "Local"
    End Select

    frmMain.lblPing.Caption = PingToDraw
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "DrawPing", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Sub UpdateSpellWindow(ByVal spellnum As Long, ByVal X As Long, ByVal Y As Long)
Dim i As Long
    
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    ' check for off-screen
    If Y + frmMain.picSpellDesc.height > frmMain.ScaleHeight Then
        Y = frmMain.ScaleHeight - frmMain.picSpellDesc.height
    End If
    
    With frmMain
        .picSpellDesc.top = Y
        .picSpellDesc.Left = X
        .picSpellDesc.Visible = True
        
        If LastSpellDesc = spellnum Then Exit Sub
        
        .lblSpellName.Caption = Trim$(Spell(spellnum).name)
        .lblSpellDesc.Caption = Trim$(Spell(spellnum).Desc)
        BltSpellDesc spellnum
    End With
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "UpdteSpellWindow", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Sub UpdateDescWindow(ByVal itemnum As Long, ByVal X As Long, ByVal Y As Long)
Dim i As Long
Dim FirstLetter As String * 1
Dim name As String
    
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    FirstLetter = LCase$(Left$(Trim$(Item(itemnum).name), 1))
   
    If FirstLetter = "$" Then
        name = (Mid$(Trim$(Item(itemnum).name), 2, Len(Trim$(Item(itemnum).name)) - 1))
    Else
        name = Trim$(Item(itemnum).name)
    End If
    
    ' check for off-screen
    If Y + frmMain.picItemDesc.height > frmMain.ScaleHeight Then
        Y = frmMain.ScaleHeight - frmMain.picItemDesc.height
    End If
    
    ' set z-order
    frmMain.picItemDesc.ZOrder (0)

    With frmMain
        .picItemDesc.top = Y
        .picItemDesc.Left = X
        .picItemDesc.Visible = True

        If LastItemDesc = itemnum Then Exit Sub ' exit out after setting x + y so we don't reset values

        ' set the name
        Select Case Item(itemnum).Rarity
            Case 0 ' white
                .lblItemName.ForeColor = RGB(255, 255, 255)
            Case 1 ' green
                .lblItemName.ForeColor = RGB(117, 198, 92)
            Case 2 ' blue
                .lblItemName.ForeColor = RGB(103, 140, 224)
            Case 3 ' maroon
                .lblItemName.ForeColor = RGB(205, 34, 0)
            Case 4 ' purple
                .lblItemName.ForeColor = RGB(193, 104, 204)
            Case 5 ' orange
                .lblItemName.ForeColor = RGB(217, 150, 64)
        End Select
        
        ' set captions
        .lblItemName.Caption = name
        .lblItemDesc.Caption = Trim$(Item(itemnum).Desc)
        
        ' render the item
        BltItemDesc itemnum
    End With

    ' Error handler
    Exit Sub
errorhandler:
    HandleError "UpdateDescWindow", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Sub CacheResources()
Dim X As Long, Y As Long, Resource_Count As Long

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    Resource_Count = 0

    For X = 0 To MAP.MaxX
        For Y = 0 To MAP.MaxY
            If MAP.Tile(X, Y).Type = TILE_TYPE_RESOURCE Then
                Resource_Count = Resource_Count + 1
                ReDim Preserve MapResource(0 To Resource_Count)
                MapResource(Resource_Count).X = X
                MapResource(Resource_Count).Y = Y
            End If
        Next
    Next

    Resource_Index = Resource_Count
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "CacheResources", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Sub CreateActionMsg(ByVal message As String, ByVal color As Integer, ByVal MsgType As Byte, ByVal X As Long, ByVal Y As Long)
Dim i As Long

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    ActionMsgIndex = ActionMsgIndex + 1
    If ActionMsgIndex >= MAX_BYTE Then ActionMsgIndex = 1

    With ActionMsg(ActionMsgIndex)
        .message = message
        .color = color
        .Type = MsgType
        .Created = GetTickCount
        .Scroll = 1
        .X = X
        .Y = Y
    End With

    If ActionMsg(ActionMsgIndex).Type = ACTIONMSG_SCROLL Then
        ActionMsg(ActionMsgIndex).Y = ActionMsg(ActionMsgIndex).Y + Rand(-2, 6)
        ActionMsg(ActionMsgIndex).X = ActionMsg(ActionMsgIndex).X + Rand(-8, 8)
    End If
    
    ' find the new high index
    For i = MAX_BYTE To 1 Step -1
        If ActionMsg(i).Created > 0 Then
            Action_HighIndex = i + 1
            Exit For
        End If
    Next
    ' make sure we don't overflow
    If Action_HighIndex > MAX_BYTE Then Action_HighIndex = MAX_BYTE
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "CreateActionMsg", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Sub ClearActionMsg(ByVal Index As Byte)
Dim i As Long

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    ActionMsg(Index).message = vbNullString
    ActionMsg(Index).Created = 0
    ActionMsg(Index).Type = 0
    ActionMsg(Index).color = 0
    ActionMsg(Index).Scroll = 0
    ActionMsg(Index).X = 0
    ActionMsg(Index).Y = 0
    
    ' find the new high index
    For i = MAX_BYTE To 1 Step -1
        If ActionMsg(i).Created > 0 Then
            Action_HighIndex = i + 1
            Exit For
        End If
    Next
    ' make sure we don't overflow
    If Action_HighIndex > MAX_BYTE Then Action_HighIndex = MAX_BYTE
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "ClearActionMsg", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Sub CheckAnimInstance(ByVal Index As Long)
Dim loopTime As Long
Dim layer As Long
Dim FrameCount As Long
Dim LockIndex As Long

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    ' if doesn't exist then exit sub
    If AnimInstance(Index).Animation <= 0 Then Exit Sub
    If AnimInstance(Index).Animation >= MAX_ANIMATIONS Then Exit Sub
    
    For layer = 0 To 1
        If AnimInstance(Index).Used(layer) Then
            loopTime = Animation(AnimInstance(Index).Animation).loopTime(layer)
            FrameCount = Animation(AnimInstance(Index).Animation).Frames(layer)
            
            ' if zero'd then set so we don't have extra loop and/or frame
            If AnimInstance(Index).FrameIndex(layer) = 0 Then AnimInstance(Index).FrameIndex(layer) = 1
            If AnimInstance(Index).LoopIndex(layer) = 0 Then AnimInstance(Index).LoopIndex(layer) = 1
            
            ' check if frame timer is set, and needs to have a frame change
            If AnimInstance(Index).Timer(layer) + loopTime <= GetTickCount Then
                ' check if out of range
                If AnimInstance(Index).FrameIndex(layer) >= FrameCount Then
                    AnimInstance(Index).LoopIndex(layer) = AnimInstance(Index).LoopIndex(layer) + 1
                    If AnimInstance(Index).LoopIndex(layer) > Animation(AnimInstance(Index).Animation).LoopCount(layer) Then
                        AnimInstance(Index).Used(layer) = False
                    Else
                        AnimInstance(Index).FrameIndex(layer) = 1
                    End If
                Else
                    AnimInstance(Index).FrameIndex(layer) = AnimInstance(Index).FrameIndex(layer) + 1
                End If
                AnimInstance(Index).Timer(layer) = GetTickCount
            End If
        End If
    Next
    
    ' if neither layer is used, clear
    If AnimInstance(Index).Used(0) = False And AnimInstance(Index).Used(1) = False Then ClearAnimInstance (Index)
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "checkAnimInstance", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Sub OpenShop(ByVal shopnum As Long)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    InShop = shopnum
    ShopAction = 0
    frmMain.picCover.Visible = True
    frmMain.picShop.Visible = True
    BltShop
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "OpenShop", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Function GetBankItemNum(ByVal bankslot As Long) As Long
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    If bankslot = 0 Then
        GetBankItemNum = 0
        Exit Function
    End If
    
    If bankslot > MAX_BANK Then
        GetBankItemNum = 0
        Exit Function
    End If
    
    GetBankItemNum = Bank.Item(bankslot).num
    
    ' Error handler
    Exit Function
errorhandler:
    HandleError "GetBankItemNum", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Function
End Function

Public Sub SetBankItemNum(ByVal bankslot As Long, ByVal itemnum As Long)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    Bank.Item(bankslot).num = itemnum
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "SetBankItemNum", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Function GetBankItemValue(ByVal bankslot As Long) As Long
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    GetBankItemValue = Bank.Item(bankslot).value
    
    ' Error handler
    Exit Function
errorhandler:
    HandleError "GetBankItemValue", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Function
End Function

Public Sub SetBankItemValue(ByVal bankslot As Long, ByVal ItemValue As Long)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    Bank.Item(bankslot).value = ItemValue
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "SetBankItemValue", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

' BitWise Operators for directional blocking
Public Sub setDirBlock(ByRef blockvar As Byte, ByRef Dir As Byte, ByVal block As Boolean)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    If block Then
        blockvar = blockvar Or (2 ^ Dir)
    Else
        blockvar = blockvar And Not (2 ^ Dir)
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "setDirBlock", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Function isDirBlocked(ByRef blockvar As Byte, ByRef Dir As Byte) As Boolean
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    If Not blockvar And (2 ^ Dir) Then
        isDirBlocked = False
    Else
        isDirBlocked = True
    End If
    
    ' Error handler
    Exit Function
errorhandler:
    HandleError "isDirBlocked", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Function
End Function

Public Function IsHotbarSlot(ByVal X As Single, ByVal Y As Single) As Long
Dim top As Long, Left As Long
Dim i As Long

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    IsHotbarSlot = 0

    For i = 1 To MAX_HOTBAR
        top = HotbarTop
        Left = HotbarLeft + ((HotbarOffsetX + 32) * (((i - 1) Mod MAX_HOTBAR)))
        If X >= Left And X <= Left + PIC_X Then
            If Y >= top And Y <= top + PIC_Y Then
                IsHotbarSlot = i
                Exit Function
            End If
        End If
    Next
    
    ' Error handler
    Exit Function
errorhandler:
    HandleError "IsHotbarSlot", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Function
End Function

Public Sub PlayMapSound(ByVal X As Long, ByVal Y As Long, ByVal entityType As Long, ByVal entityNum As Long)
Dim soundName As String

    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    If entityNum <= 0 Then Exit Sub
    
    ' find the sound
    Select Case entityType
        ' animations
        Case SoundEntity.seAnimation
            If entityNum > MAX_ANIMATIONS Then Exit Sub
            soundName = Trim$(Animation(entityNum).Sound)
            
        ' items
        Case SoundEntity.seItem
            If entityNum > MAX_ITEMS Then Exit Sub
            soundName = Trim$(Item(entityNum).Sound)
        ' npcs
        Case SoundEntity.seNpc
            If entityNum > MAX_NPCS Then Exit Sub
            soundName = Trim$(Npc(entityNum).Sound)
        ' resources
        Case SoundEntity.seResource
            If entityNum > MAX_RESOURCES Then Exit Sub
            soundName = Trim$(Resource(entityNum).Sound)
        ' spells
        Case SoundEntity.seSpell
            If entityNum > MAX_SPELLS Then Exit Sub
            soundName = Trim$(Spell(entityNum).Sound)
        ' other
        Case Else
            Exit Sub
    End Select
    
    ' exit out if it's not set
    If Trim$(soundName) = "None." Then Exit Sub

    ' play the sound
    PlaySound soundName
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "PlayMapSound", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Sub Dialogue(ByVal diTitle As String, ByVal diText As String, ByVal diIndex As Long, Optional ByVal isYesNo As Boolean = False, Optional ByVal Data1 As Long = 0)
    ' If debug mode, handle error then exit out
    If Options.Debug = 1 Then On Error GoTo errorhandler
    
    ' exit out if we've already got a dialogue open
    If dialogueIndex > 0 Then Exit Sub
    
    ' set global dialogue index
    dialogueIndex = diIndex
    
    ' set the global dialogue data
    dialogueData1 = Data1

    ' set the captions
    frmMain.lblDialogue_Title.Caption = diTitle
    frmMain.lblDialogue_Text.Caption = diText
    
    ' show/hide buttons
    If Not isYesNo Then
        frmMain.lblDialogue_Button(1).Visible = True ' Okay button
        frmMain.lblDialogue_Button(2).Visible = False ' Yes button
        frmMain.lblDialogue_Button(3).Visible = False ' No button
    Else
        frmMain.lblDialogue_Button(1).Visible = False ' Okay button
        frmMain.lblDialogue_Button(2).Visible = True ' Yes button
        frmMain.lblDialogue_Button(3).Visible = True ' No button
    End If
    
    ' show the dialogue box
    frmMain.picDialogue.Visible = True
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "Dialogue", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Sub dialogueHandler(ByVal Index As Long)
If Options.Debug = 1 Then On Error GoTo errorhandler

    ' find out which button
    If Index = 1 Then ' okay button
        ' dialogue index
        Select Case dialogueIndex
        
        End Select
    ElseIf Index = 2 Then ' yes button
        ' dialogue index
        Select Case dialogueIndex
            Case DIALOGUE_TYPE_TRADE
                SendAcceptTradeRequest
            Case DIALOGUE_TYPE_FORGET
                ForgetSpell dialogueData1
            Case DIALOGUE_TYPE_PARTY
                SendAcceptParty
            Case DIALOGUE_TYPE_DESAFIO
                SendDesafioState YES
            Case DIALOGUE_TYPE_CHAT
                SendChat CHAT_ACEITO, ChatPlayer, vbNullString
            
        End Select
    ElseIf Index = 3 Then ' no button
        ' dialogue index
        Select Case dialogueIndex
            Case DIALOGUE_TYPE_TRADE
                SendDeclineTradeRequest
            Case DIALOGUE_TYPE_PARTY
                SendDeclineParty
            Case DIALOGUE_TYPE_DESAFIO
                SendDesafioState NO
            Case DIALOGUE_TYPE_CHAT
                SendChat CHAT_RECUSADO, ChatPlayer, vbNullString
        End Select
    End If
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "Sub dialoguEhandleR", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Sub CheckMapAnim(ByVal X As Long, ByVal Y As Long) 'animação
If Options.Debug = 1 Then On Error GoTo errorhandler

    Dim AnimNum As Long
    Dim layer As Long
    Dim loopTime As Long
    Dim FrameCount As Long
    On Error Resume Next
    
    AnimNum = MAP.Tile(X, Y).Animation.Animation
    
    ' if it doesn't exist then exit sub
    If AnimNum = 0 Or AnimNum > MAX_ANIMATIONS Then Exit Sub
    
    For layer = 0 To 1
        loopTime = Animation(AnimNum).loopTime(layer)
        FrameCount = Animation(AnimNum).Frames(layer)
        
        ' make sure we don't have an extra frame
        If MAP.Tile(X, Y).Animation.FrameIndex(layer) = 0 Then MAP.Tile(X, Y).Animation.FrameIndex(layer) = 1
        
        If MAP.Tile(X, Y).Animation.Timer(layer) + loopTime <= GetTickCount Then
            ' out of range?
            If MAP.Tile(X, Y).Animation.FrameIndex(layer) >= FrameCount Then
                MAP.Tile(X, Y).Animation.FrameIndex(layer) = 1
            Else
                MAP.Tile(X, Y).Animation.FrameIndex(layer) = MAP.Tile(X, Y).Animation.FrameIndex(layer) + 1
            End If
            MAP.Tile(X, Y).Animation.Timer(layer) = GetTickCount
        End If
    Next
    
    ' Error handler
    Exit Sub
errorhandler:
    HandleError "Sub ChekMapAnim", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Sub UpdateTransPic()
If Options.Debug = 1 Then On Error GoTo errorhandler

Dim tenso As String

If MyIndex < 1 Or MyIndex > MAX_PLAYERS Then Exit Sub

frmMain.picTrans0.ToolTipText = "Voltar ao Normal"

Select Case GetPlayerClass(MyIndex)
    Case 1
        tenso = "naruto"
    Case 2
        tenso = "sasuke"
    Case 3
        tenso = "sakura"
    Case 4
        tenso = "ino"
    Case 5
        tenso = "shikamaru"
    Case 6
        tenso = "chouji"
    Case 7
        tenso = "lee"
    Case 8
        tenso = "neji"
    Case 9
        tenso = "tenten"
    Case 10
        tenso = "kiba"
    Case 11
        tenso = "shino"
    Case 12
        tenso = "gaara"
    Case 13
        tenso = "kankurou"
    Case 14
        tenso = "temari"
    Case 15
        tenso = "hinata"
    Case SAI
        tenso = "sai"
    Case YONDAIME
        tenso = "yondaime"
    Case KISAME
        tenso = "kisame"
    Case DEIDARA
        tenso = "deidara"
    Case ITACHI
        tenso = "itachi"
    Case KIMIMARU
        tenso = "kimimaru"
    Case JIRAYA
        tenso = "JIRAYA"
    Case TSUNADE
        tenso = "tsunade"
    Case KAKASHI
        tenso = "kakashi"
    Case PAIN
        tenso = "pain"
    Case MADARA
        tenso = "madara"
    Case TOBI
        tenso = "tobi"
    Case OROCHIMARU
        tenso = "orochimaru"
    Case HAKU
        tenso = "haku"
    Case ZABUZA
        tenso = "zabuza"
    Case BEE
        tenso = "bee"
    Case HASHIRAMA
        tenso = "hashirama"
    Case YAMATO
        tenso = "yamato"
    Case KONAN
        tenso = "konan"
    Case RAIKAGE
        tenso = "raikage"
    Case DARUI
        tenso = "darui"
    Case HIDAN
        tenso = "hidan"
    Case SASORI
        tenso = "sasori"
    Case DANZOU
        tenso = "danzou"
    Case YUGITO
        tenso = "yugito"
    Case TOBIRAMA
        tenso = "tobirama"
    Case GAI
        tenso = "gai"
    Case MEI
        tenso = "mei"
        
    Case Else
      frmMain.picTrans0.Visible = False
      frmMain.picTrans1.Visible = False
      frmMain.picTrans2.Visible = False
      frmMain.picTrans3.Visible = False
      frmMain.picTrans4.Visible = False
      frmMain.picTrans5.Visible = False
      frmMain.picTrans6.Visible = False
      Exit Sub
    End Select
    
If FileExist(App.Path & "\data files\graphics\trans\" & tenso & "\0.jpg", True) Then
    frmMain.picTrans0.Picture = LoadPicture(App.Path & "\data files\graphics\trans\" & tenso & "\0.jpg")
    frmMain.picTrans0.Visible = True
Else: frmMain.picTrans0.Visible = False
End If

If FileExist(App.Path & "\data files\graphics\trans\" & tenso & "\1.jpg", True) Then
    frmMain.picTrans1.Picture = LoadPicture(App.Path & "\data files\graphics\trans\" & tenso & "\1.jpg")
    frmMain.picTrans1.Visible = True
Else: frmMain.picTrans1.Visible = False
End If

If FileExist(App.Path & "\data files\graphics\trans\" & tenso & "\2.jpg", True) Then
    frmMain.picTrans2.Picture = LoadPicture(App.Path & "\data files\graphics\trans\" & tenso & "\2.jpg")
    frmMain.picTrans2.Visible = True
Else: frmMain.picTrans2.Visible = False
End If

If FileExist(App.Path & "\data files\graphics\trans\" & tenso & "\3.jpg", True) Then
    frmMain.picTrans3.Picture = LoadPicture(App.Path & "\data files\graphics\trans\" & tenso & "\3.jpg")
    frmMain.picTrans3.Visible = True
Else: frmMain.picTrans3.Visible = False
End If

If FileExist(App.Path & "\data files\graphics\trans\" & tenso & "\4.jpg", True) Then
    frmMain.picTrans4.Picture = LoadPicture(App.Path & "\data files\graphics\trans\" & tenso & "\4.jpg")
    frmMain.picTrans4.Visible = True
Else: frmMain.picTrans4.Visible = False
End If

If FileExist(App.Path & "\data files\graphics\trans\" & tenso & "\5.jpg", True) Then
    frmMain.picTrans5.Picture = LoadPicture(App.Path & "\data files\graphics\trans\" & tenso & "\5.jpg")
    frmMain.picTrans5.Visible = True
Else: frmMain.picTrans5.Visible = False
End If

If FileExist(App.Path & "\data files\graphics\trans\" & tenso & "\6.jpg", True) Then
    frmMain.picTrans6.Picture = LoadPicture(App.Path & "\data files\graphics\trans\" & tenso & "\6.jpg")
    frmMain.picTrans6.Visible = True
Else: frmMain.picTrans6.Visible = False
End If

' Error handler
    Exit Sub
errorhandler:
    HandleError "Sub UpdateTransPIc", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
      
End Sub



Public Sub UpdatePositions()
If Options.Debug = 1 Then On Error GoTo errorhandler

'TOP LVL
frmMain.picTopLevel.top = 24
frmMain.picTopLevel.Left = 96
frmMain.picTopLevel.height = 441
frmMain.picTopLevel.width = 449
'TOP KARMA
frmMain.picKarma.top = 24
frmMain.picKarma.Left = 40
frmMain.picKarma.height = 433
frmMain.picKarma.width = 577
'TOP PVP
frmMain.picPVP.top = 56
frmMain.picPVP.Left = 120
frmMain.picPVP.height = 385
frmMain.picPVP.width = 385

'TOP CHAR
frmMain.picTopChar.top = 24
frmMain.picTopChar.Left = 120
frmMain.picTopChar.height = 409
frmMain.picTopChar.width = 393

' Error handler
    Exit Sub
errorhandler:
    HandleError "Sub UpdatePositions", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Sub
End Sub

Public Function AreaVIP() As Byte
If Options.Debug = 1 Then On Error GoTo errorhandler

Dim Mapa As Long

For Mapa = 82 To 86
    If GetPlayerMap(MyIndex) = Mapa Then
        AreaVIP = YES
    End If
Next

For Mapa = 154 To 156
    If GetPlayerMap(MyIndex) = Mapa Then
        AreaVIP = YES
    End If
Next

For Mapa = 221 To 223
    If GetPlayerMap(MyIndex) = Mapa Then
        AreaVIP = YES
    End If
Next

' Error handler
    Exit Function
errorhandler:
    HandleError "Function AreaVIP", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Function

End Function

Public Function CanKickBoot() As Boolean
If Options.Debug = 1 Then On Error GoTo errorhandler

Dim MapNum As Long
MapNum = GetPlayerMap(MyIndex)

If MapNum < 1 Or MapNum > MAX_MAPS Then Exit Function

If MapNum >= 260 And MapNum <= 279 Then 'area vip ohyeh
    CanKickBoot = True
    Exit Function
End If

If MapNum >= 54 And MapNum <= 56 Then 'caminho cs
    CanKickBoot = True
    Exit Function
End If

If MapNum >= 82 And MapNum <= 86 Then 'area vip
    CanKickBoot = True
    Exit Function
End If

If MapNum >= 154 And MapNum <= 156 Then 'area vip
    CanKickBoot = True
    Exit Function
End If

If MapNum >= 221 And MapNum <= 222 Then 'area vip
    CanKickBoot = True
    Exit Function
End If

If MapNum >= 73 And MapNum <= 77 Then 'local akat
    CanKickBoot = True
    Exit Function
End If

If MapNum = 103 Then 'fn3
    CanKickBoot = True
    Exit Function
End If

CanKickBoot = False

' Error handler
    Exit Function
errorhandler:
    HandleError "Function CanKickBoot", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Function
End Function

Public Function CanKick() As Boolean
If Options.Debug = 1 Then On Error GoTo errorhandler

Dim MapNum As Long
MapNum = GetPlayerMap(MyIndex)

If MapNum < 1 Or MapNum > MAX_MAPS Then Exit Function

If MapNum = 71 Or MapNum = 298 Or MapNum = 299 Or MapNum = 300 Or MapNum = 296 Or MapNum = 295 Or MapNum = 294 Then   'Logs
    CanKick = False
    Exit Function
End If

If MapNum = 98 Or MapNum = 94 Or MapNum = 95 Or MapNum = 100 Then   'Torneios
    CanKick = False
    Exit Function
End If

If TotalPerguntas > 0 Then
    CanKick = False
    Exit Function
End If

CanKick = True

' Error handler
    Exit Function
errorhandler:
    HandleError "Function CanKick", "modGameLogic", Err.Number, Err.Description, Err.Source, Err.HelpContext
    Err.Clear
    Exit Function
    
End Function

Public Sub CarregarExame()

ExameEscrito(1).Pergunta = "Naruto Inner Power é feito por qual equipe?"
ExameEscrito(1).Resposta(1) = "Miraba Dreams"
ExameEscrito(1).Resposta(2) = "OhYehGAMES"
ExameEscrito(1).Resposta(3) = "Shunin Ninjas"
ExameEscrito(1).Resposta(4) = "Goku Lovers"
ExameEscrito(1).RespostaCerta = "OhYehGAMES"

ExameEscrito(2).Pergunta = "Qual a primeira evolução na vida de um shinobi?"
ExameEscrito(2).Resposta(1) = "Gennin"
ExameEscrito(2).Resposta(2) = "ANBU"
ExameEscrito(2).Resposta(3) = "Chunnin Ninjas"
ExameEscrito(2).Resposta(4) = "Kage"
ExameEscrito(2).RespostaCerta = "Gennin"

ExameEscrito(3).Pergunta = "Como se chama o kage da vila da folha?"
ExameEscrito(3).Resposta(1) = "Raikage"
ExameEscrito(3).Resposta(2) = "Hokage"
ExameEscrito(3).Resposta(3) = "Tsuchikage"
ExameEscrito(3).Resposta(4) = "Mizukage"
ExameEscrito(3).RespostaCerta = "Hokage"

ExameEscrito(4).Pergunta = "Tsuchikage é o kage de qual vila?"
ExameEscrito(4).Resposta(1) = "Konoha"
ExameEscrito(4).Resposta(2) = "Kiri"
ExameEscrito(4).Resposta(3) = "Suna"
ExameEscrito(4).Resposta(4) = "Iwa"
ExameEscrito(4).RespostaCerta = "Iwa"

ExameEscrito(5).Pergunta = "Qual função do jutsu Mizu no Kinobori?"
ExameEscrito(5).Resposta(1) = "Recuperar vida"
ExameEscrito(5).Resposta(2) = "Correr mais rápido"
ExameEscrito(5).Resposta(3) = "Andar na água"
ExameEscrito(5).Resposta(4) = "Cantar melhor"
ExameEscrito(5).RespostaCerta = "Andar na água"

ExameEscrito(6).Pergunta = "Em que lugar ocorreu a luta épica entre naruto e sasuke na fase clássica?"
ExameEscrito(6).Resposta(1) = "Vale sem fim"
ExameEscrito(6).Resposta(2) = "Vale do medo"
ExameEscrito(6).Resposta(3) = "Vale do fim"
ExameEscrito(6).Resposta(4) = "Vale da morte"
ExameEscrito(6).RespostaCerta = "Vale do fim"

ExameEscrito(7).Pergunta = "Qual nome do autor do anime/mangá Naruto?"
ExameEscrito(7).Resposta(1) = "Mayashi Kishimoto"
ExameEscrito(7).Resposta(2) = "Masashi Kishimoto"
ExameEscrito(7).Resposta(3) = "Masashi Kishemoto"
ExameEscrito(7).Resposta(4) = "Ronaldinho"
ExameEscrito(7).RespostaCerta = "Masashi Kishimoto"

ExameEscrito(8).Pergunta = "Quem foi o sensei de Shikamaru?"
ExameEscrito(8).Resposta(1) = "Kakashi"
ExameEscrito(8).Resposta(2) = "Jiraya"
ExameEscrito(8).Resposta(3) = "Asuma"
ExameEscrito(8).Resposta(4) = "Orochimaru"
ExameEscrito(8).RespostaCerta = "Asuma"

ExameEscrito(9).Pergunta = "Quem matou Asuma"
ExameEscrito(9).Resposta(1) = "Hidan"
ExameEscrito(9).Resposta(2) = "Hiruko"
ExameEscrito(9).Resposta(3) = "Kakuzu"
ExameEscrito(9).Resposta(4) = "Sasori"
ExameEscrito(9).RespostaCerta = "Hidan"

ExameEscrito(10).Pergunta = "Quem era o parceiro de Hidan?"
ExameEscrito(10).Resposta(1) = "Hiruko"
ExameEscrito(10).Resposta(2) = "Kakuzo"
ExameEscrito(10).Resposta(3) = "Kisame"
ExameEscrito(10).Resposta(4) = "Orochimaru"
ExameEscrito(10).RespostaCerta = "Kakuzo"

ExameEscrito(11).Pergunta = "Por traz de tudo,quem comanda a Akatsuki?"
ExameEscrito(11).Resposta(1) = "Pain"
ExameEscrito(11).Resposta(2) = "Konan"
ExameEscrito(11).Resposta(3) = "Itachi"
ExameEscrito(11).Resposta(4) = "Tobi"
ExameEscrito(11).RespostaCerta = "Tobi"

ExameEscrito(12).Pergunta = "Os 12 Guardiões foram criados para protegerem quem?"
ExameEscrito(12).Resposta(1) = "Mizukage"
ExameEscrito(12).Resposta(2) = "Naruto"
ExameEscrito(12).Resposta(3) = "Senhor feudal do fogo"
ExameEscrito(12).Resposta(4) = "Hokage"
ExameEscrito(12).RespostaCerta = "Senhor feudal do fogo"

ExameEscrito(13).Pergunta = "Como se chama o bijuu das 10 caldas?"
ExameEscrito(13).Resposta(1) = "Juubi"
ExameEscrito(13).Resposta(2) = "Bijuu"
ExameEscrito(13).Resposta(3) = "Ichibaku"
ExameEscrito(13).Resposta(4) = "Hachibi"
ExameEscrito(13).RespostaCerta = "Juubi"

ExameEscrito(14).Pergunta = "Oque é Sanbi?"
ExameEscrito(14).Resposta(1) = "Um jutsu"
ExameEscrito(14).Resposta(2) = "Um estilo de luta"
ExameEscrito(14).Resposta(3) = "Um bijuu"
ExameEscrito(14).Resposta(4) = "Um acessório ninja"
ExameEscrito(14).RespostaCerta = "Um bijuu"

ExameEscrito(15).Pergunta = "Yonbi é o bijuu de quantas caldas?"
ExameEscrito(15).Resposta(1) = "4"
ExameEscrito(15).Resposta(2) = "7"
ExameEscrito(15).Resposta(3) = "3"
ExameEscrito(15).Resposta(4) = "5"
ExameEscrito(15).RespostaCerta = "4"

ExameEscrito(16).Pergunta = "Qual é o Jinchuuriki do bijuu de 5 caldas?"
ExameEscrito(16).Resposta(1) = "Naruto"
ExameEscrito(16).Resposta(2) = "Utakata"
ExameEscrito(16).Resposta(3) = "Saiken"
ExameEscrito(16).Resposta(4) = "Han"
ExameEscrito(16).RespostaCerta = "Han"

ExameEscrito(17).Pergunta = "Qual shinobi ensinou naruto a controlar a Kyuubi?"
ExameEscrito(17).Resposta(1) = "Kakashi"
ExameEscrito(17).Resposta(2) = "Jiraya"
ExameEscrito(17).Resposta(3) = "Tsunade"
ExameEscrito(17).Resposta(4) = "Killer-Bee"
ExameEscrito(17).RespostaCerta = "Killer-Bee"

ExameEscrito(18).Pergunta = "Qual o maior cargo que um shinobi pode chegar?"
ExameEscrito(18).Resposta(1) = "Gennin"
ExameEscrito(18).Resposta(2) = "Jounin"
ExameEscrito(18).Resposta(3) = "Kage"
ExameEscrito(18).Resposta(4) = "ANBU"
ExameEscrito(18).RespostaCerta = "Kage"

ExameEscrito(19).Pergunta = "Como é possivel saber se um shinobi é ANBU?"
ExameEscrito(19).Resposta(1) = "Pela sua roupa"
ExameEscrito(19).Resposta(2) = "Pela sua bandana"
ExameEscrito(19).Resposta(3) = "Pela sua máscara"
ExameEscrito(19).Resposta(4) = "Pelo seu cabelo"
ExameEscrito(19).RespostaCerta = "Pela sua máscara"

ExameEscrito(20).Pergunta = "Quem é a paixão de Hinata?"
ExameEscrito(20).Resposta(1) = "Kankurou"
ExameEscrito(20).Resposta(2) = "Kiba"
ExameEscrito(20).Resposta(3) = "Sasuke"
ExameEscrito(20).Resposta(4) = "Naruto"
ExameEscrito(20).RespostaCerta = "Naruto"

ExameEscrito(21).Pergunta = "Qual o shinobi conhecido como sobrancelhudo?"
ExameEscrito(21).Resposta(1) = "RockLee"
ExameEscrito(21).Resposta(2) = "Naruto"
ExameEscrito(21).Resposta(3) = "Sakura"
ExameEscrito(21).Resposta(4) = "Não sei dizer"
ExameEscrito(21).RespostaCerta = "RockLee"

ExameEscrito(22).Pergunta = "Quem derrotou Sasori?"
ExameEscrito(22).Resposta(1) = "Gaara e Kankurou"
ExameEscrito(22).Resposta(2) = "Jiraya"
ExameEscrito(22).Resposta(3) = "Juugo e Suigetsu"
ExameEscrito(22).Resposta(4) = "Sakura e Chyio-Baa"
ExameEscrito(22).RespostaCerta = "Sakura e Chyio-Baa"

ExameEscrito(23).Pergunta = "Qual o membro mais forte do quinteto do som?"
ExameEscrito(23).Resposta(1) = "Kindoumaru"
ExameEscrito(23).Resposta(2) = "Sakon"
ExameEscrito(23).Resposta(3) = "Ukon"
ExameEscrito(23).Resposta(4) = "Kimimaro"
ExameEscrito(23).RespostaCerta = "Kimimaro"

ExameEscrito(24).Pergunta = "Qual apelido do Pai de Kakashi?"
ExameEscrito(24).Resposta(1) = "Camelo branco"
ExameEscrito(24).Resposta(2) = "Canino Maldito"
ExameEscrito(24).Resposta(3) = "Canino branco"
ExameEscrito(24).Resposta(4) = "algo haver com rosa"
ExameEscrito(24).RespostaCerta = "Canino branco"

ExameEscrito(25).Pergunta = "Qual nome do pai de Kakashi?"
ExameEscrito(25).Resposta(1) = "Hatake Uchiha"
ExameEscrito(25).Resposta(2) = "Hatake Shinsui"
ExameEscrito(25).Resposta(3) = "Hatake Kakashi Sr."
ExameEscrito(25).Resposta(4) = "Hatake Sakumo"
ExameEscrito(25).RespostaCerta = "Hatake Sakumo"

ExameEscrito(26).Pergunta = "Oque significa Suiton/Katon/Doton ?"
ExameEscrito(26).Resposta(1) = "Trovão/Terra/Raio"
ExameEscrito(26).Resposta(2) = "Fogo/Água/Trevas"
ExameEscrito(26).Resposta(3) = "Água/Fogo/Terra"
ExameEscrito(26).Resposta(4) = "Terra/Lama/Tiririca"
ExameEscrito(26).RespostaCerta = "Água/Fogo/Terra"

ExameEscrito(27).Pergunta = "Defina Taijutsu"
ExameEscrito(27).Resposta(1) = "Combate corpo-a-corpo"
ExameEscrito(27).Resposta(2) = "Luta a distância"
ExameEscrito(27).Resposta(3) = "Confundir a mente inimiga"
ExameEscrito(27).Resposta(4) = "Uma variação de ramen"
ExameEscrito(27).RespostaCerta = "Combate corpo-a-corpo"

ExameEscrito(28).Pergunta = "Defina Genjutsu"
ExameEscrito(28).Resposta(1) = "Combate corpo-a-corpo"
ExameEscrito(28).Resposta(2) = "Luta a distância"
ExameEscrito(28).Resposta(3) = "Confundir a mente inimiga"
ExameEscrito(28).Resposta(4) = "Uma variação de ramen"
ExameEscrito(28).RespostaCerta = "Confundir a mente inimiga"

ExameEscrito(29).Pergunta = "Defina Ninjutsu"
ExameEscrito(29).Resposta(1) = "Combate corpo-a-corpo"
ExameEscrito(29).Resposta(2) = "Luta a distância"
ExameEscrito(29).Resposta(3) = "Confundir a mente inimiga"
ExameEscrito(29).Resposta(4) = "Uma variação de ramen"
ExameEscrito(29).RespostaCerta = "Luta a distância"

ExameEscrito(30).Pergunta = "Qual nome do jutsu que pain devastou konoha?"
ExameEscrito(30).Resposta(1) = "Chibaku Tensei"
ExameEscrito(30).Resposta(2) = "Shibaku Tensei"
ExameEscrito(30).Resposta(3) = "China Tensei"
ExameEscrito(30).Resposta(4) = "Shinra Tensei"
ExameEscrito(30).RespostaCerta = "Shinra Tensei"
End Sub

Public Sub SortearPergunta()
Dim question As Byte
Dim i As Byte
Dim oka As Byte

For i = 1 To 30
    If ExameEscrito(i).Usado = NO Then
        oka = YES
        Exit For
    End If
Next

If oka = NO Then Exit Sub

question = Rand(1, 30)

If ExameEscrito(question).Usado = YES Then
    SortearPergunta
    Exit Sub
End If

frmMain.txtExame.text = Trim$(ExameEscrito(question).Pergunta)

frmMain.lstExame.List(0) = Trim$(ExameEscrito(question).Resposta(1))
frmMain.lstExame.List(1) = Trim$(ExameEscrito(question).Resposta(2))
frmMain.lstExame.List(2) = Trim$(ExameEscrito(question).Resposta(3))
frmMain.lstExame.List(3) = Trim$(ExameEscrito(question).Resposta(4))


ExameEscrito(question).Usado = YES
PerguntaIndex = question
PerguntasCount = PerguntasCount + 1

frmMain.picExame.Visible = True

End Sub

Public Sub AddAnim(ByVal AnimNum As Long, ByVal X As Long, ByVal Y As Long, Optional ByVal LockType As Byte, Optional ByVal LockIndex As Long)
If AnimNum < 1 Or AnimNum > MAX_ANIMATIONS Then Exit Sub

AnimationIndex = AnimationIndex + 1
If AnimationIndex >= MAX_BYTE Then AnimationIndex = 1

With AnimInstance(AnimationIndex)
    .Animation = AnimNum
    .X = X
    .Y = Y
    .LockType = LockType
    .LockIndex = LockIndex
    .Used(0) = True
    .Used(1) = True
End With
                        
End Sub

Public Function jaTemDesafio(ByVal Nome As String) As Byte
Dim i As Byte
jaTemDesafio = NO
If Trim$(Nome) = GetPlayerName(MyIndex) Then Exit Function
If Trim$(Nome) = vbNullString Then Exit Function

For i = 1 To 3
    If NomesDesafio(i) = Trim$(Nome) Then
        jaTemDesafio = YES
        Exit Function
    End If
Next

End Function

Public Function pegarDesafioIndex() As Byte
Dim i As Byte

For i = 1 To 3
    If NomesDesafio(i) = vbNullString Then
        pegarDesafioIndex = i
        Exit Function
    End If
Next

End Function

Public Sub atualizarArena()
Dim i As Long

Arena(1).Nome = "Floresta"
Arena(2).Nome = "Vale do Fim"
Arena(3).Nome = "Campo de Treino"
Arena(4).Nome = "Deserto"
Arena(5).Nome = "Arena Livre"
Arena(6).Nome = "Floresta da Morte"
Arena(7).Nome = "Arena Livre 2"
Arena(8).Nome = "Esconderijo Akatsuki"
Arena(9).Nome = "Esconderijo Orochimaru"

EmoteMsg 129

End Sub

Public Sub verificarCheat(ByVal num As Byte)

Dim hWPE As Long
Dim ok As Byte
    
    ok = NO
    
    cheatTimer = num
    
    '#############
    'WPE PRO- WINSOCK PACKET editor
    '#############
        hWPE = GetModuleHandle("WpeSpy.dll")
        If hWPE Then
            ok = YES
            FreeLibrary hWPE
        End If
    
    '#############
    'REDOX PACKET EDITOR-RPE
    '#############
        hWPE = GetModuleHandle("rPE.dll")
        If hWPE Then
            ok = YES
            FreeLibrary hWPE
        End If
        
        hWPE = GetModuleHandle("rPE_ex.dll")
        If hWPE Then
            ok = YES
            FreeLibrary hWPE
        End If
    
    '############
    'T-SEARCH
    '############
        hWPE = GetModuleHandle("TSearchDll.dll")
        If hWPE Then
            ok = YES
            FreeLibrary hWPE
        End If
        
        hWPE = GetModuleHandle("THotkeys.dll")
        If hWPE Then
            ok = YES
            FreeLibrary hWPE
        End If
        
        hWPE = GetModuleHandle("TSpeech.dll")
        If hWPE Then
            ok = YES
            FreeLibrary hWPE
        End If
    '############
    'ARTMONEY
    '############
        hWPE = GetModuleHandle("am743.dll")
        If hWPE Then
            ok = YES
            FreeLibrary hWPE
        End If
        
        hWPE = GetModuleHandle("am74364.dll")
        If hWPE Then
            ok = YES
            FreeLibrary hWPE
        End If
    '##############
    'SPEEDERXP
    '##############
        hWPE = GetModuleHandle("inproc.dll")
        If hWPE Then
            ok = YES
            FreeLibrary hWPE
        End If
    
    '##############
    'CHEAT ENGINE- SPEEDHACK - Não deu pra bloquear tudo, nenhuma outra dll deu certo
    '##############
        hWPE = GetModuleHandle("speedhack-i386.dll")
        If hWPE Then
            ok = YES
            FreeLibrary hWPE
        End If
        
        hWPE = GetModuleHandle("speedhack-x86_64.dll")
        If hWPE Then
            ok = YES
            FreeLibrary hWPE
        End If
    '##############
    '##############
    '##############
    
If ok = YES Then
    logoutGame
    MsgBox "Cheat detectado!", vbCritical
End If

End Sub

Public Sub enviarDropItem(ByVal InvNum As Long)
    AntiSpeed1 = NO
    AntiSpeed2 = NO
    If Item(GetPlayerInvItemNum(MyIndex, InvNum)).Type = ITEM_TYPE_CURRENCY Then
        If GetPlayerInvItemValue(MyIndex, InvNum) > 0 Then
            CurrencyMenu = 1 ' drop
            frmMain.lblCurrency.Caption = "How many do you want to drop?"
            tmpCurrencyItem = InvNum
            frmMain.txtCurrency.text = vbNullString
            frmMain.picCurrency.Visible = True
            frmMain.txtCurrency.SetFocus
        End If
    Else
        Call SendDropItem(InvNum, 0)
    End If
End Sub
