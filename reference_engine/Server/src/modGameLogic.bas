Attribute VB_Name = "modGameLogic"
Option Explicit

Function FindOpenPlayerSlot() As Long
    Dim i As Long
    FindOpenPlayerSlot = 0

    For i = 1 To MAX_PLAYERS

        If Not IsConnected(i) Then
            FindOpenPlayerSlot = i
            Exit Function
        End If

    Next

End Function

Function FindOpenMapItemSlot(ByVal mapNum As Long) As Long
    Dim i As Long
    FindOpenMapItemSlot = 0

    ' Check for subscript out of range
    If mapNum <= 0 Or mapNum > MAX_MAPS Then
        Exit Function
    End If

    For i = 1 To MAX_MAP_ITEMS

        If MapItem(mapNum, i).num = 0 Then
            FindOpenMapItemSlot = i
            Exit Function
        End If

    Next

End Function

Function TotalOnlinePlayers() As Long
    Dim i As Long
    TotalOnlinePlayers = 0

    For i = 1 To Player_HighIndex

        If IsPlaying(i) Then
            TotalOnlinePlayers = TotalOnlinePlayers + 1
        End If

    Next

End Function

Function FindPlayer(ByVal Name As String) As Long
    Dim i As Long

    For i = 1 To Player_HighIndex

        If IsPlaying(i) Then

            ' Make sure we dont try to check a name thats to small
            If Len(GetPlayerName(i)) >= Len(Trim$(Name)) Then
                If UCase$(Mid$(GetPlayerName(i), 1, Len(Trim$(Name)))) = UCase$(Trim$(Name)) Then
                'If GetPlayerName(i) = Name Then
                    FindPlayer = i
                    Exit Function
                End If
            End If
        End If

    Next

    FindPlayer = 0
End Function

Sub SpawnItem(ByVal itemNum As Long, ByVal ItemVal As Long, ByVal mapNum As Long, ByVal X As Long, ByVal Y As Long, Optional ByVal playerName As String = vbNullString)
    Dim i As Long

    ' Check for subscript out of range
    If itemNum < 1 Or itemNum > MAX_ITEMS Or mapNum <= 0 Or mapNum > MAX_MAPS Then
        Exit Sub
    End If

    ' Find open map item slot
    i = FindOpenMapItemSlot(mapNum)
    Call SpawnItemSlot(i, itemNum, ItemVal, mapNum, X, Y, playerName)
End Sub

Sub SpawnItemSlot(ByVal MapItemSlot As Long, ByVal itemNum As Long, ByVal ItemVal As Long, ByVal mapNum As Long, ByVal X As Long, ByVal Y As Long, Optional ByVal playerName As String = vbNullString, Optional ByVal canDespawn As Boolean = True)
    On Error Resume Next
    
    Dim packet As String
    Dim i As Long
    Dim Buffer As clsBuffer

    ' Check for subscript out of range
    If MapItemSlot <= 0 Or MapItemSlot > MAX_MAP_ITEMS Or itemNum < 0 Or itemNum > MAX_ITEMS Or mapNum <= 0 Or mapNum > MAX_MAPS Then
        Exit Sub
    End If

    i = MapItemSlot

    If i <> 0 Then
        If itemNum >= 0 And itemNum <= MAX_ITEMS Then
            MapItem(mapNum, i).playerName = playerName
            MapItem(mapNum, i).playerTimer = GetTickCount + ITEM_SPAWN_TIME
            MapItem(mapNum, i).canDespawn = canDespawn
            MapItem(mapNum, i).despawnTimer = GetTickCount + ITEM_DESPAWN_TIME
            MapItem(mapNum, i).num = itemNum
            MapItem(mapNum, i).Value = ItemVal
            MapItem(mapNum, i).X = X
            MapItem(mapNum, i).Y = Y
            ' send to map
            SendSpawnItemToMap mapNum, i
        End If
    End If

End Sub

Sub SpawnAllMapsItems()
    Dim i As Long

    For i = 1 To MAX_MAPS
        Call SpawnMapItems(i)
    Next

End Sub

Sub SpawnMapItems(ByVal mapNum As Long)
    Dim X As Long
    Dim Y As Long

    ' Check for subscript out of range
    If mapNum <= 0 Or mapNum > MAX_MAPS Then
        Exit Sub
    End If

    ' Spawn what we have
    For X = 0 To Map(mapNum).MaxX
        For Y = 0 To Map(mapNum).MaxY

            ' Check if the tile type is an item or a saved tile incase someone drops something
            If (Map(mapNum).Tile(X, Y).Type = TILE_TYPE_ITEM) Then

                ' Check to see if its a currency and if they set the value to 0 set it to 1 automatically
                If Map(mapNum).Tile(X, Y).Data1 > 0 And Map(mapNum).Tile(X, Y).Data1 <= MAX_ITEMS Then
                    If Item(Map(mapNum).Tile(X, Y).Data1).Type = ITEM_TYPE_CURRENCY And Map(mapNum).Tile(X, Y).Data2 <= 0 Then
                        Call SpawnItem(Map(mapNum).Tile(X, Y).Data1, 1, mapNum, X, Y)
                    Else
                        Call SpawnItem(Map(mapNum).Tile(X, Y).Data1, Map(mapNum).Tile(X, Y).Data2, mapNum, X, Y)
                    End If
                End If
            End If

        Next
    Next

End Sub

Function Random(ByVal Low As Long, ByVal High As Long) As Long
    Random = ((High - Low + 1) * Rnd) + Low
End Function

Public Sub SpawnNpc(ByVal mapNpcNum As Long, ByVal mapNum As Long, Optional ByVal SetX As Long, Optional ByVal SetY As Long)
    Dim Buffer As clsBuffer
    Dim NpcNum As Long
    Dim i As Long
    Dim X As Long
    Dim Y As Long
    Dim Spawned As Boolean

    ' Check for subscript out of range
    If mapNpcNum <= 0 Or mapNpcNum > MAX_MAP_NPCS Or mapNum <= 0 Or mapNum > MAX_MAPS Then Exit Sub
    NpcNum = Map(mapNum).Npc(mapNpcNum)

    If NpcNum > 0 Then
    
        MapNpc(mapNum).Npc(mapNpcNum).num = NpcNum
        MapNpc(mapNum).Npc(mapNpcNum).Target = 0
        MapNpc(mapNum).Npc(mapNpcNum).targetType = 0 ' clear
        
        MapNpc(mapNum).Npc(mapNpcNum).Vital(Vitals.HP) = GetNpcMaxVital(NpcNum, Vitals.HP)
        MapNpc(mapNum).Npc(mapNpcNum).Vital(Vitals.mp) = GetNpcMaxVital(NpcNum, Vitals.mp)
        
        MapNpc(mapNum).Npc(mapNpcNum).Dir = Int(Rnd * 4)
        
        'Check if theres a spawn tile for the specific npc
        For X = 0 To Map(mapNum).MaxX
            For Y = 0 To Map(mapNum).MaxY
                If Map(mapNum).Tile(X, Y).Type = TILE_TYPE_NPCSPAWN Then
                    If Map(mapNum).Tile(X, Y).Data1 = mapNpcNum Then
                        MapNpc(mapNum).Npc(mapNpcNum).X = X
                        MapNpc(mapNum).Npc(mapNpcNum).Y = Y
                        MapNpc(mapNum).Npc(mapNpcNum).Dir = Map(mapNum).Tile(X, Y).Data2
                        Spawned = True
                        Exit For
                    End If
                End If
            Next Y
        Next X
        
        If Not Spawned Then
    
            ' Well try 100 times to randomly place the sprite
            For i = 1 To 100
                
                If SetX = 0 And SetY = 0 Then
                    X = Random(0, Map(mapNum).MaxX)
                    Y = Random(0, Map(mapNum).MaxY)
                Else
                    X = SetX
                    Y = SetY
                End If
    
                If X > Map(mapNum).MaxX Then X = Map(mapNum).MaxX
                If Y > Map(mapNum).MaxY Then Y = Map(mapNum).MaxY
    
                ' Check if the tile is walkable
                If NpcTileIsOpen(mapNum, X, Y) Then
                    MapNpc(mapNum).Npc(mapNpcNum).X = X
                    MapNpc(mapNum).Npc(mapNpcNum).Y = Y
                    Spawned = True
                    Exit For
                End If
    
            Next
            
        End If

        ' Didn't spawn, so now we'll just try to find a free tile
        If Not Spawned Then

            For X = 0 To Map(mapNum).MaxX
                For Y = 0 To Map(mapNum).MaxY

                    If NpcTileIsOpen(mapNum, X, Y) Then
                        MapNpc(mapNum).Npc(mapNpcNum).X = X
                        MapNpc(mapNum).Npc(mapNpcNum).Y = Y
                        Spawned = True
                    End If

                Next
            Next

        End If

        ' If we suceeded in spawning then send it to everyone
        If Spawned Then
            Set Buffer = New clsBuffer
            Buffer.WriteLong SSpawnNpc
            Buffer.WriteLong mapNpcNum
            Buffer.WriteLong MapNpc(mapNum).Npc(mapNpcNum).num
            Buffer.WriteLong MapNpc(mapNum).Npc(mapNpcNum).X
            Buffer.WriteLong MapNpc(mapNum).Npc(mapNpcNum).Y
            Buffer.WriteLong MapNpc(mapNum).Npc(mapNpcNum).Dir
            Buffer.WriteByte MapNpc(mapNum).Npc(mapNpcNum).IsPet
            Buffer.WriteString MapNpc(mapNum).Npc(mapNpcNum).PetData.Name
            Buffer.WriteLong MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner
            SendDataToMap mapNum, Buffer.ToArray()
            Set Buffer = Nothing
            
            If NpcNum = 201 Then 'npc pinhata
                GlobalMsg "O npc pinhata NASCEU! Digite /evento para ir até o mapa dele.", Yellow
                GlobalMsg "Ajude a derrotar ele e você poderá ganhar algum prêmio, além de ainda, se der sorte, ativar 2x para todos!! :D", Yellow
            End If
        End If
        
        SendMapNpcVitals mapNum, mapNpcNum
    End If

End Sub

Public Function NpcTileIsOpen(ByVal mapNum As Long, ByVal X As Long, ByVal Y As Long) As Boolean
    On Error Resume Next
    
    Dim LoopI As Long
    NpcTileIsOpen = True

    If PlayersOnMap(mapNum) Then

        For LoopI = 1 To Player_HighIndex

            If GetPlayerMap(LoopI) = mapNum Then
                If GetPlayerX(LoopI) = X Then
                    If GetPlayerY(LoopI) = Y Then
                        NpcTileIsOpen = False
                        Exit Function
                    End If
                End If
            End If

        Next

    End If

    For LoopI = 1 To MAX_MAP_NPCS

        If MapNpc(mapNum).Npc(LoopI).num > 0 Then
            If MapNpc(mapNum).Npc(LoopI).X = X Then
                If MapNpc(mapNum).Npc(LoopI).Y = Y Then
                    NpcTileIsOpen = False
                    Exit Function
                End If
            End If
        End If

    Next

    If Map(mapNum).Tile(X, Y).Type <> TILE_TYPE_WALKABLE Then
        If Map(mapNum).Tile(X, Y).Type <> TILE_TYPE_NPCSPAWN Then
            If Map(mapNum).Tile(X, Y).Type <> TILE_TYPE_ITEM Then
                NpcTileIsOpen = False
            End If
        End If
    End If
End Function

Sub SpawnMapNpcs(ByVal mapNum As Long)
    Dim i As Long

    For i = 1 To MAX_MAP_NPCS
        Call SpawnNpc(i, mapNum)
    Next

End Sub

Sub SpawnAllMapNpcs()
    Dim i As Long

    For i = 1 To MAX_MAPS
        Call SpawnMapNpcs(i)
    Next

End Sub

Function CanNpcMove(ByVal mapNum As Long, ByVal mapNpcNum As Long, ByVal Dir As Byte) As Boolean
    Dim i As Long
    Dim n As Long
    Dim X As Long
    Dim Y As Long

    ' Check for subscript out of range
    If mapNum <= 0 Or mapNum > MAX_MAPS Or mapNpcNum <= 0 Or mapNpcNum > MAX_MAP_NPCS Or Dir < DIR_UP Or Dir > DIR_RIGHT Then
        Exit Function
    End If

    X = MapNpc(mapNum).Npc(mapNpcNum).X
    Y = MapNpc(mapNum).Npc(mapNpcNum).Y
    CanNpcMove = True

    Select Case Dir
        Case DIR_UP

            ' Check to make sure not outside of boundries
            If Y > 0 Then
                n = Map(mapNum).Tile(X, Y - 1).Type

                ' Check to make sure that the tile is walkable
                If n <> TILE_TYPE_WALKABLE And n <> TILE_TYPE_ITEM And n <> TILE_TYPE_NPCSPAWN And n <> TILE_TYPE_ONCLICK And n <> TILE_TYPE_SCRIPT Then
                    CanNpcMove = False
                    Exit Function
                End If

                ' Check to make sure that there is not a player in the way
                For i = 1 To Player_HighIndex
                    If IsPlaying(i) Then
                        If (GetPlayerMap(i) = mapNum) And (GetPlayerX(i) = MapNpc(mapNum).Npc(mapNpcNum).X) And (GetPlayerY(i) = MapNpc(mapNum).Npc(mapNpcNum).Y - 1) Then
                            CanNpcMove = False
                            Exit Function
                        End If
                    End If
                Next

                ' Check to make sure that there is not another npc in the way
                For i = 1 To MAX_MAP_NPCS
                    If (i <> mapNpcNum) And (MapNpc(mapNum).Npc(i).num > 0) And (MapNpc(mapNum).Npc(i).X = MapNpc(mapNum).Npc(mapNpcNum).X) And (MapNpc(mapNum).Npc(i).Y = MapNpc(mapNum).Npc(mapNpcNum).Y - 1) Then
                        CanNpcMove = False
                        Exit Function
                    End If
                Next
                
                ' Directional blocking
                If isDirBlocked(Map(mapNum).Tile(MapNpc(mapNum).Npc(mapNpcNum).X, MapNpc(mapNum).Npc(mapNpcNum).Y).DirBlock, DIR_UP + 1) Then
                    CanNpcMove = False
                    Exit Function
                End If
            Else
                CanNpcMove = False
            End If

        Case DIR_DOWN

            ' Check to make sure not outside of boundries
            If Y < Map(mapNum).MaxY Then
                n = Map(mapNum).Tile(X, Y + 1).Type

                ' Check to make sure that the tile is walkable
                If n <> TILE_TYPE_WALKABLE And n <> TILE_TYPE_ITEM And n <> TILE_TYPE_NPCSPAWN And n <> TILE_TYPE_ONCLICK And n <> TILE_TYPE_SCRIPT Then
                    CanNpcMove = False
                    Exit Function
                End If

                ' Check to make sure that there is not a player in the way
                For i = 1 To Player_HighIndex
                    If IsPlaying(i) Then
                        If (GetPlayerMap(i) = mapNum) And (GetPlayerX(i) = MapNpc(mapNum).Npc(mapNpcNum).X) And (GetPlayerY(i) = MapNpc(mapNum).Npc(mapNpcNum).Y + 1) Then
                            CanNpcMove = False
                            Exit Function
                        End If
                    End If
                Next

                ' Check to make sure that there is not another npc in the way
                For i = 1 To MAX_MAP_NPCS
                    If (i <> mapNpcNum) And (MapNpc(mapNum).Npc(i).num > 0) And (MapNpc(mapNum).Npc(i).X = MapNpc(mapNum).Npc(mapNpcNum).X) And (MapNpc(mapNum).Npc(i).Y = MapNpc(mapNum).Npc(mapNpcNum).Y + 1) Then
                        CanNpcMove = False
                        Exit Function
                    End If
                Next
                
                ' Directional blocking
                If isDirBlocked(Map(mapNum).Tile(MapNpc(mapNum).Npc(mapNpcNum).X, MapNpc(mapNum).Npc(mapNpcNum).Y).DirBlock, DIR_DOWN + 1) Then
                    CanNpcMove = False
                    Exit Function
                End If
            Else
                CanNpcMove = False
            End If

        Case DIR_LEFT

            ' Check to make sure not outside of boundries
            If X > 0 Then
                n = Map(mapNum).Tile(X - 1, Y).Type

                ' Check to make sure that the tile is walkable
                If n <> TILE_TYPE_WALKABLE And n <> TILE_TYPE_ITEM And n <> TILE_TYPE_NPCSPAWN And n <> TILE_TYPE_ONCLICK And n <> TILE_TYPE_SCRIPT Then
                    CanNpcMove = False
                    Exit Function
                End If

                ' Check to make sure that there is not a player in the way
                For i = 1 To Player_HighIndex
                    If IsPlaying(i) Then
                        If (GetPlayerMap(i) = mapNum) And (GetPlayerX(i) = MapNpc(mapNum).Npc(mapNpcNum).X - 1) And (GetPlayerY(i) = MapNpc(mapNum).Npc(mapNpcNum).Y) Then
                            CanNpcMove = False
                            Exit Function
                        End If
                    End If
                Next

                ' Check to make sure that there is not another npc in the way
                For i = 1 To MAX_MAP_NPCS
                    If (i <> mapNpcNum) And (MapNpc(mapNum).Npc(i).num > 0) And (MapNpc(mapNum).Npc(i).X = MapNpc(mapNum).Npc(mapNpcNum).X - 1) And (MapNpc(mapNum).Npc(i).Y = MapNpc(mapNum).Npc(mapNpcNum).Y) Then
                        CanNpcMove = False
                        Exit Function
                    End If
                Next
                
                ' Directional blocking
                If isDirBlocked(Map(mapNum).Tile(MapNpc(mapNum).Npc(mapNpcNum).X, MapNpc(mapNum).Npc(mapNpcNum).Y).DirBlock, DIR_LEFT + 1) Then
                    CanNpcMove = False
                    Exit Function
                End If
            Else
                CanNpcMove = False
            End If

        Case DIR_RIGHT

            ' Check to make sure not outside of boundries
            If X < Map(mapNum).MaxX Then
                n = Map(mapNum).Tile(X + 1, Y).Type

                ' Check to make sure that the tile is walkable
                If n <> TILE_TYPE_WALKABLE And n <> TILE_TYPE_ITEM And n <> TILE_TYPE_NPCSPAWN And n <> TILE_TYPE_ONCLICK And n <> TILE_TYPE_SCRIPT Then
                    CanNpcMove = False
                    Exit Function
                End If

                ' Check to make sure that there is not a player in the way
                For i = 1 To Player_HighIndex
                    If IsPlaying(i) Then
                        If (GetPlayerMap(i) = mapNum) And (GetPlayerX(i) = MapNpc(mapNum).Npc(mapNpcNum).X + 1) And (GetPlayerY(i) = MapNpc(mapNum).Npc(mapNpcNum).Y) Then
                            CanNpcMove = False
                            Exit Function
                        End If
                    End If
                Next

                ' Check to make sure that there is not another npc in the way
                For i = 1 To MAX_MAP_NPCS
                    If (i <> mapNpcNum) And (MapNpc(mapNum).Npc(i).num > 0) And (MapNpc(mapNum).Npc(i).X = MapNpc(mapNum).Npc(mapNpcNum).X + 1) And (MapNpc(mapNum).Npc(i).Y = MapNpc(mapNum).Npc(mapNpcNum).Y) Then
                        CanNpcMove = False
                        Exit Function
                    End If
                Next
                
                ' Directional blocking
                If isDirBlocked(Map(mapNum).Tile(MapNpc(mapNum).Npc(mapNpcNum).X, MapNpc(mapNum).Npc(mapNpcNum).Y).DirBlock, DIR_RIGHT + 1) Then
                    CanNpcMove = False
                    Exit Function
                End If
            Else
                CanNpcMove = False
            End If

    End Select

End Function

Sub NpcMove(ByVal mapNum As Long, ByVal mapNpcNum As Long, ByVal Dir As Long, ByVal movement As Long)
    Dim packet As String
    Dim Buffer As clsBuffer

    ' Check for subscript out of range
    If mapNum <= 0 Or mapNum > MAX_MAPS Or mapNpcNum <= 0 Or mapNpcNum > MAX_MAP_NPCS Or Dir < DIR_UP Or Dir > DIR_RIGHT Or movement < 1 Or movement > 2 Then
        Exit Sub
    End If

    MapNpc(mapNum).Npc(mapNpcNum).Dir = Dir

    Select Case Dir
        Case DIR_UP
            MapNpc(mapNum).Npc(mapNpcNum).Y = MapNpc(mapNum).Npc(mapNpcNum).Y - 1
            Set Buffer = New clsBuffer
            Buffer.WriteLong SNpcMove
            Buffer.WriteLong mapNpcNum
            Buffer.WriteLong MapNpc(mapNum).Npc(mapNpcNum).X
            Buffer.WriteLong MapNpc(mapNum).Npc(mapNpcNum).Y
            Buffer.WriteLong MapNpc(mapNum).Npc(mapNpcNum).Dir
            Buffer.WriteLong movement
            SendDataToMap mapNum, Buffer.ToArray()
            Set Buffer = Nothing
        Case DIR_DOWN
            MapNpc(mapNum).Npc(mapNpcNum).Y = MapNpc(mapNum).Npc(mapNpcNum).Y + 1
            Set Buffer = New clsBuffer
            Buffer.WriteLong SNpcMove
            Buffer.WriteLong mapNpcNum
            Buffer.WriteLong MapNpc(mapNum).Npc(mapNpcNum).X
            Buffer.WriteLong MapNpc(mapNum).Npc(mapNpcNum).Y
            Buffer.WriteLong MapNpc(mapNum).Npc(mapNpcNum).Dir
            Buffer.WriteLong movement
            SendDataToMap mapNum, Buffer.ToArray()
            Set Buffer = Nothing
        Case DIR_LEFT
            MapNpc(mapNum).Npc(mapNpcNum).X = MapNpc(mapNum).Npc(mapNpcNum).X - 1
            Set Buffer = New clsBuffer
            Buffer.WriteLong SNpcMove
            Buffer.WriteLong mapNpcNum
            Buffer.WriteLong MapNpc(mapNum).Npc(mapNpcNum).X
            Buffer.WriteLong MapNpc(mapNum).Npc(mapNpcNum).Y
            Buffer.WriteLong MapNpc(mapNum).Npc(mapNpcNum).Dir
            Buffer.WriteLong movement
            SendDataToMap mapNum, Buffer.ToArray()
            Set Buffer = Nothing
        Case DIR_RIGHT
            MapNpc(mapNum).Npc(mapNpcNum).X = MapNpc(mapNum).Npc(mapNpcNum).X + 1
            Set Buffer = New clsBuffer
            Buffer.WriteLong SNpcMove
            Buffer.WriteLong mapNpcNum
            Buffer.WriteLong MapNpc(mapNum).Npc(mapNpcNum).X
            Buffer.WriteLong MapNpc(mapNum).Npc(mapNpcNum).Y
            Buffer.WriteLong MapNpc(mapNum).Npc(mapNpcNum).Dir
            Buffer.WriteLong movement
            SendDataToMap mapNum, Buffer.ToArray()
            Set Buffer = Nothing
    End Select

End Sub

Sub NpcDir(ByVal mapNum As Long, ByVal mapNpcNum As Long, ByVal Dir As Long)
    Dim packet As String
    Dim Buffer As clsBuffer

    ' Check for subscript out of range
    If mapNum <= 0 Or mapNum > MAX_MAPS Or mapNpcNum <= 0 Or mapNpcNum > MAX_MAP_NPCS Or Dir < DIR_UP Or Dir > DIR_RIGHT Then
        Exit Sub
    End If

    MapNpc(mapNum).Npc(mapNpcNum).Dir = Dir
    Set Buffer = New clsBuffer
    Buffer.WriteLong SNpcDir
    Buffer.WriteLong mapNpcNum
    Buffer.WriteLong Dir
    SendDataToMap mapNum, Buffer.ToArray()
    Set Buffer = Nothing
End Sub

Function GetTotalMapPlayers(ByVal mapNum As Long) As Long
    Dim i As Long
    Dim n As Long
    n = 0

    For i = 1 To Player_HighIndex

        If IsPlaying(i) And GetPlayerMap(i) = mapNum Then
            n = n + 1
        End If

    Next

    GetTotalMapPlayers = n
End Function

Sub ClearTempTiles()
    Dim i As Long

    For i = 1 To MAX_MAPS
        ClearTempTile i
    Next

End Sub

Sub ClearTempTile(ByVal mapNum As Long)
    Dim Y As Long
    Dim X As Long
    TempTile(mapNum).DoorTimer = 0
    ReDim TempTile(mapNum).DoorOpen(0 To Map(mapNum).MaxX, 0 To Map(mapNum).MaxY)

    For X = 0 To Map(mapNum).MaxX
        For Y = 0 To Map(mapNum).MaxY
            TempTile(mapNum).DoorOpen(X, Y) = NO
        Next
    Next

End Sub

Public Sub CacheResources(ByVal mapNum As Long)
On Error Resume Next

    Dim X As Long, Y As Long, Resource_Count As Long
    Resource_Count = 0

    For X = 0 To Map(mapNum).MaxX
        For Y = 0 To Map(mapNum).MaxY

            If Map(mapNum).Tile(X, Y).Type = TILE_TYPE_RESOURCE Then
            
                Resource_Count = Resource_Count + 1
                ReDim Preserve ResourceCache(mapNum).ResourceData(0 To Resource_Count)
                ResourceCache(mapNum).ResourceData(Resource_Count).X = X
                ResourceCache(mapNum).ResourceData(Resource_Count).Y = Y
                If Map(mapNum).Tile(X, Y).Data1 > 0 Then
                    ResourceCache(mapNum).ResourceData(Resource_Count).cur_health = Resource(Map(mapNum).Tile(X, Y).Data1).health
                End If
            End If

        Next
    Next

    ResourceCache(mapNum).Resource_Count = Resource_Count
End Sub

Sub PlayerSwitchBankSlots(ByVal index As Long, ByVal oldSlot As Long, ByVal newSlot As Long)
Dim OldNum As Long
Dim OldValue As Long
Dim NewNum As Long
Dim NewValue As Long

    If oldSlot = 0 Or newSlot = 0 Then
        Exit Sub
    End If
    
    OldNum = GetPlayerBankItemNum(index, oldSlot)
    OldValue = GetPlayerBankItemValue(index, oldSlot)
    NewNum = GetPlayerBankItemNum(index, newSlot)
    NewValue = GetPlayerBankItemValue(index, newSlot)
    
    SetPlayerBankItemNum index, newSlot, OldNum
    SetPlayerBankItemValue index, newSlot, OldValue
    
    SetPlayerBankItemNum index, oldSlot, NewNum
    SetPlayerBankItemValue index, oldSlot, NewValue
        
    SendBank index
End Sub

Sub PlayerSwitchInvSlots(ByVal index As Long, ByVal oldSlot As Long, ByVal newSlot As Long)
    Dim OldNum As Long
    Dim OldValue As Long
    Dim NewNum As Long
    Dim NewValue As Long

    If oldSlot = 0 Or newSlot = 0 Then
        Exit Sub
    End If

    OldNum = GetPlayerInvItemNum(index, oldSlot)
    OldValue = GetPlayerInvItemValue(index, oldSlot)
    NewNum = GetPlayerInvItemNum(index, newSlot)
    NewValue = GetPlayerInvItemValue(index, newSlot)
    SetPlayerInvItemNum index, newSlot, OldNum
    SetPlayerInvItemValue index, newSlot, OldValue
    SetPlayerInvItemNum index, oldSlot, NewNum
    SetPlayerInvItemValue index, oldSlot, NewValue
    SendInventory index
End Sub

Sub PlayerSwitchSpellSlots(ByVal index As Long, ByVal oldSlot As Long, ByVal newSlot As Long)
    Dim OldNum As Long
    Dim NewNum As Long

    If oldSlot = 0 Or newSlot = 0 Then
        Exit Sub
    End If

    OldNum = GetPlayerSpell(index, oldSlot)
    NewNum = GetPlayerSpell(index, newSlot)
    SetPlayerSpell index, oldSlot, NewNum
    SetPlayerSpell index, newSlot, OldNum
    SendPlayerSpells index
End Sub

Sub PlayerUnequipItem(ByVal index As Long, ByVal EqSlot As Long, Optional ByVal PodePassar As Byte = 0)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub

If TempPlayer(index).EquipTmr > GetTickCount Then Exit Sub

If PodePassar <> 1 Then TempPlayer(index).EquipTmr = GetTickCount + 3000

    If EqSlot <= 0 Or EqSlot > Equipment.Equipment_Count - 1 Then Exit Sub ' exit out early if error'd
    If FindOpenInvSlot(index, GetPlayerEquipment(index, EqSlot)) > 0 Then
        GiveInvItem index, GetPlayerEquipment(index, EqSlot), 0
        PlayerMsg index, "Você desequipou " & CheckGrammar(Item(GetPlayerEquipment(index, EqSlot)).Name), Yellow
        ' send the sound
        SendPlayerSound index, GetPlayerX(index), GetPlayerY(index), SoundEntity.seItem, GetPlayerEquipment(index, EqSlot)
        ' remove equipment
        SetPlayerEquipment index, 0, EqSlot
        SendWornEquipment index
        SendMapEquipment index
        SendStats index
        ' send vitals
        Call SendVital(index, Vitals.HP)
        Call SendVital(index, Vitals.mp)
        ' send vitals to party if in one
        If TempPlayer(index).inParty > 0 Then SendPartyVitals TempPlayer(index).inParty, index
    Else
        PlayerMsg index, "Sua mochila está cheia", BrightRed
    End If

End Sub

Public Function CheckGrammar(ByVal Word As String, Optional ByVal Caps As Byte = 0) As String
Dim FirstLetter As String * 1
   
    FirstLetter = LCase$(Left$(Word, 1))
   
    If FirstLetter = "$" Then
      CheckGrammar = (Mid$(Word, 2, Len(Word) - 1))
      Exit Function
    End If
   
    If FirstLetter Like "*[aeiou]*" Then
        If Caps Then CheckGrammar = "Um(a) " & Word Else CheckGrammar = "um(a) " & Word
    Else
        If Caps Then CheckGrammar = "Um(a) " & Word Else CheckGrammar = "um(a) " & Word
    End If
End Function

Function isInRange(ByVal Range As Long, ByVal x1 As Long, ByVal y1 As Long, ByVal x2 As Long, ByVal y2 As Long) As Boolean
Dim nVal As Long
    isInRange = False
    nVal = Sqr((x1 - x2) ^ 2 + (y1 - y2) ^ 2)
    If nVal <= Range Then isInRange = True
End Function

Public Function isDirBlocked(ByRef blockvar As Byte, ByRef Dir As Byte) As Boolean
    If Not blockvar And (2 ^ Dir) Then
        isDirBlocked = False
    Else
        isDirBlocked = True
    End If
End Function

Public Function RAND(ByVal Low As Long, ByVal High As Long) As Long
    Randomize
    RAND = Int((High - Low + 1) * Rnd) + Low
End Function

' #####################
' ## Party functions ##
' #####################
Public Sub Party_PlayerLeave(ByVal index As Long)

If index < 1 Or index > MAX_PLAYERS Then Exit Sub

Dim partyNum As Long, i As Long

    partyNum = TempPlayer(index).inParty
    If partyNum > 0 Then
        ' find out how many members we have
        Party_CountMembers partyNum
        ' make sure there's more than 2 people
        If Party(partyNum).MemberCount > 2 Then
            ' check if leader
            If Party(partyNum).Leader = index Then
                ' set next person down as leader
                For i = 1 To MAX_PARTY_MEMBERS
                    If Party(partyNum).Member(i) > 0 And Party(partyNum).Member(i) <> index Then
                        Party(partyNum).Leader = Party(partyNum).Member(i)
                        PartyMsg partyNum, GetPlayerName(i) & " É agora o Líder do Grupo.", BrightBlue
                        Exit For
                    End If
                Next
                ' leave party
                PartyMsg partyNum, GetPlayerName(index) & " saiu do Grupo.", BrightRed
                ' remove from array
                For i = 1 To MAX_PARTY_MEMBERS
                    If Party(partyNum).Member(i) = index Then
                        Party(partyNum).Member(i) = 0
                        Exit For
                    End If
                Next
                ' recount party
                Party_CountMembers partyNum
                ' set update to all
                SendPartyUpdate partyNum
                ' send clear to player
                SendPartyUpdateTo index
            Else
                ' not the leader, just leave
                PartyMsg partyNum, GetPlayerName(index) & " Saiu do Grupo.", BrightRed
                ' remove from array
                For i = 1 To MAX_PARTY_MEMBERS
                    If Party(partyNum).Member(i) = index Then
                        Party(partyNum).Member(i) = 0
                        Exit For
                    End If
                Next
                ' recount party
                Party_CountMembers partyNum
                ' set update to all
                SendPartyUpdate partyNum
                ' send clear to player
                SendPartyUpdateTo index
            End If
        Else
            ' find out how many members we have
            Party_CountMembers partyNum
            ' only 2 people, disband
            PartyMsg partyNum, "Grupo finalizado.", BrightRed
            ' clear out everyone's party
            For i = 1 To MAX_PARTY_MEMBERS
                index = Party(partyNum).Member(i)
                ' player exist?
                If index > 0 Then
                    ' remove them
                    TempPlayer(index).inParty = 0
                    ' send clear to players
                    SendPartyUpdateTo index
                End If
            Next
            ' clear out the party itself
            ClearParty partyNum
        End If
        
        If index < 1 Or index > MAX_PLAYERS Then Exit Sub
        
        TempPlayer(index).inParty = 0
        SendPartyUpdateTo index
    End If
End Sub

Public Sub Party_Invite(ByVal index As Long, ByVal targetPlayer As Long)
Dim partyNum As Long, i As Long
    
    ' check if the person is a valid target
    If Not IsConnected(targetPlayer) Or Not IsPlaying(targetPlayer) Then Exit Sub
    
    If Player(index).Org > 0 Then
        PlayerMsg index, "Você está em uma Organização!", BrightRed
        Exit Sub
    End If
    
    If TempPlayer(index).partyInvite > 0 Then
        PlayerMsg index, "Você já convidou alguém para o grupo ou foi convidado para um!", BrightRed
        Exit Sub
    End If
    
    If Player(targetPlayer).Org > 0 Then
        PlayerMsg index, "Ele já está em uma organização!", BrightRed
        Exit Sub
    End If
    
    If GetPlayerAccess(index) > 1 Then
        PlayerMsg index, "Você não é player _|_", BrightRed
        Exit Sub
    End If
    
    If GetPlayerAccess(targetPlayer) > 1 Then
        PlayerMsg index, "Ele não pode entrar em Guilds!", BrightRed
        Exit Sub
    End If
    ' make sure they're not busy
    If TempPlayer(targetPlayer).partyInvite > 0 Or TempPlayer(targetPlayer).TradeRequest > 0 Then
        ' they've already got a request for trade/party
        PlayerMsg index, "Este jogador está ocupado.", BrightRed
        ' exit out early
        Exit Sub
    End If
    ' make syure they're not in a party
    If TempPlayer(targetPlayer).inParty > 0 Then
        ' they're already in a party
        PlayerMsg index, "Este jogador já está em um Grupo.", BrightRed
        'exit out early
        Exit Sub
    End If
    
    ' check if we're in a party
    If TempPlayer(index).inParty > 0 Then
        partyNum = TempPlayer(index).inParty
        ' make sure we're the leader
        If Party(partyNum).Leader = index Then
            ' got a blank slot?
            For i = 1 To MAX_PARTY_MEMBERS
                If Party(partyNum).Member(i) = 0 Then
                    ' send the invitation
                    SendPartyInvite targetPlayer, index
                    ' set the invite target
                    TempPlayer(targetPlayer).partyInvite = index
                    ' let them know
                    PlayerMsg index, "Convite enviado.", Pink
                    Exit Sub
                End If
            Next
            ' no room
            PlayerMsg index, "Grupo está cheio.", BrightRed
            Exit Sub
        Else
            ' not the leader
            PlayerMsg index, "Você não é o Líder do Grupo.", BrightRed
            Exit Sub
        End If
    Else
        ' not in a party - doesn't matter!
        SendPartyInvite targetPlayer, index
        ' set the invite target
        TempPlayer(targetPlayer).partyInvite = index
        ' let them know
        PlayerMsg index, "Convite enviado.", Pink
        Exit Sub
    End If
End Sub

Public Sub Party_InviteAccept(ByVal index As Long, ByVal targetPlayer As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If targetPlayer < 1 Or targetPlayer > MAX_PLAYERS Then Exit Sub

Dim partyNum As Long, i As Long

    ' check if already in a party
    If TempPlayer(index).inParty > 0 Then
        ' get the partynumber
        partyNum = TempPlayer(index).inParty
        ' got a blank slot?
        For i = 1 To MAX_PARTY_MEMBERS
            If Party(partyNum).Member(i) = 0 Then
                'add to the party
                Party(partyNum).Member(i) = targetPlayer
                ' recount party
                Party_CountMembers partyNum
                ' send update to all - including new player
                SendPartyUpdate partyNum
                SendPartyVitals partyNum, targetPlayer
                ' let everyone know they've joined
                PartyMsg partyNum, GetPlayerName(targetPlayer) & " entrou para o Grupo.", Pink
                ' add them in
                TempPlayer(targetPlayer).inParty = partyNum
                Exit Sub
            End If
        Next
        ' no empty slots - let them know
        PlayerMsg index, "Grupo está cheio.", BrightRed
        PlayerMsg targetPlayer, "Grupo está cheio.", BrightRed
        Exit Sub
    Else
        ' not in a party. Create one with the new person.
        For i = 1 To MAX_PARTYS
            ' find blank party
            If Not Party(i).Leader > 0 Then
                partyNum = i
                Exit For
            End If
        Next
        ' create the party
        Party(partyNum).MemberCount = 2
        Party(partyNum).Leader = index
        Party(partyNum).Member(1) = index
        Party(partyNum).Member(2) = targetPlayer
        SendPartyUpdate partyNum
        SendPartyVitals partyNum, index
        SendPartyVitals partyNum, targetPlayer
        ' let them know it's created
        PartyMsg partyNum, "Grupo criado.", BrightGreen
        PartyMsg partyNum, GetPlayerName(index) & " entrou para o Grupo.", Pink
        PartyMsg partyNum, GetPlayerName(targetPlayer) & " entrou para o Grupo.", Pink
        ' clear the invitation
        TempPlayer(targetPlayer).partyInvite = 0
        ' add them to the party
        TempPlayer(index).inParty = partyNum
        TempPlayer(targetPlayer).inParty = partyNum
        Exit Sub
    End If
End Sub

Public Sub Party_InviteDecline(ByVal index As Long, ByVal targetPlayer As Long)
    PlayerMsg index, GetPlayerName(targetPlayer) & " recusou seu convite.", BrightRed
    PlayerMsg targetPlayer, "Você recusou o Grupo.", BrightRed
    ' clear the invitation
    TempPlayer(targetPlayer).partyInvite = 0
End Sub

Public Sub Party_CountMembers(ByVal partyNum As Long)
Dim i As Long, highIndex As Long, X As Long
    ' find the high index
    For i = MAX_PARTY_MEMBERS To 1 Step -1
        If Party(partyNum).Member(i) > 0 Then
            highIndex = i
            Exit For
        End If
    Next
    ' count the members
    For i = 1 To MAX_PARTY_MEMBERS
        ' we've got a blank member
        If Party(partyNum).Member(i) = 0 Then
            ' is it lower than the high index?
            If i < highIndex Then
                ' move everyone down a slot
                For X = i To MAX_PARTY_MEMBERS - 1
                    Party(partyNum).Member(X) = Party(partyNum).Member(X + 1)
                    Party(partyNum).Member(X + 1) = 0
                Next
            Else
                ' not lower - highindex is count
                Party(partyNum).MemberCount = highIndex
                Exit Sub
            End If
        End If
        ' check if we've reached the max
        If i = MAX_PARTY_MEMBERS Then
            If highIndex = i Then
                Party(partyNum).MemberCount = MAX_PARTY_MEMBERS
                Exit Sub
            End If
        End If
    Next
    ' if we're here it means that we need to re-count again
    Party_CountMembers partyNum
End Sub

Public Sub Party_ShareExp(ByVal partyNum As Long, ByVal EXP As Long, ByVal index As Long)
On Error Resume Next
Dim expShare As Long, leftOver As Long, i As Long, tmpIndex As Long

    ' check if it's worth sharing
    If Not EXP >= Party(partyNum).MemberCount Then
        ' no party - keep exp for self
        TempPlayer(index).GanhouEXP = YES
        GivePlayerEXP index, EXP
        Exit Sub
    End If
    
    ' find out the equal share
    expShare = EXP \ Party(partyNum).MemberCount
    leftOver = EXP Mod Party(partyNum).MemberCount
    
    ' loop through and give everyone exp
    For i = 1 To MAX_PARTY_MEMBERS
        tmpIndex = Party(partyNum).Member(i)
        ' existing member?Kn
        If tmpIndex > 0 Then
            ' playing?
            If IsConnected(tmpIndex) And IsPlaying(tmpIndex) Then
                ' give them their share
                If GetPlayerMap(tmpIndex) = GetPlayerMap(index) Then
                    If Not tmpIndex = index Then
                        TempPlayer(tmpIndex).GanhouEXP = YES
                        GivePlayerEXP tmpIndex, expShare
                    End If
                End If
            End If
        End If
    Next
    
    ' give the remainder to a random member
    'tmpIndex = Party(partyNum).Member(RAND(1, Party(partyNum).MemberCount))
    ' give the exp
    'GivePlayerEXP tmpIndex, leftOver
End Sub

Public Sub GivePlayerEXP(ByVal index As Long, ByVal EXP As Long, Optional ByVal upAlone As Byte, Optional ByVal dontHitNpcUp As Byte)
    ' give the exp
    Dim expTotal As String
    
    If Not TempPlayer(index).GanhouEXP = YES Then Exit Sub
    If GetPlayerAccess(index) > 1 Then Exit Sub 'gm
    
    TempPlayer(index).GanhouEXP = NO
    
    If EXP < 1 Then Exit Sub
    
    expTotal = EXP
    expTotal = expTotal + GetPlayerExp(index)
    
    TempPlayer(index).SetExp = YES
    
    If expTotal > MAX_LONG Then
        SetPlayerExp index, MAX_LONG
    Else
        Call SetPlayerExp(index, GetPlayerExp(index) + EXP)
    End If
    
    SendEXP index
    
    If dontHitNpcUp = YES Then
        SendActionMsg GetPlayerMap(index), "+" & EXP & " EXP", Yellow, 1, (GetPlayerX(index) * 32), (GetPlayerY(index) * 32), index
    Else
        If upAlone = YES Then
            SendActionMsg GetPlayerMap(index), "+" & EXP & " EXP", Pink, 1, (GetPlayerX(index) * 32), (GetPlayerY(index) * 32), index
        Else
            SendActionMsg GetPlayerMap(index), "+" & EXP & " EXP", White, 1, (GetPlayerX(index) * 32), (GetPlayerY(index) * 32), index
        End If
    End If
    
    ' check if we've leveled
    CheckPlayerLevelUp index
    
End Sub

Sub CheckAttackNPC(ByVal index As Integer, ByVal Map As Integer, ByVal X As Byte, ByVal Y As Byte, ByVal Damage As Long, Optional ByVal SpellNum As Integer)
On Error Resume Next

Dim Count As Byte
Count = 1
Do While Count < MAX_MAP_NPCS

If MapNpc(GetPlayerMap(index)).Npc(Count).X = X And MapNpc(GetPlayerMap(index)).Npc(Count).Y = Y Then
    If CanPlayerAttackNpc(index, Count, True) Then
        Call PlayerAttackNpc(index, Count, Damage)
        
         If SpellNum > 0 Then
            If Spell(SpellNum).StunDuration > 0 Then StunNPC Count, GetPlayerMap(index), SpellNum, index
            If Spell(SpellNum).Duration > 0 Then AddDoT_Npc GetPlayerMap(index), Count, SpellNum, index
            If Spell(SpellNum).IsPush = YES Then PuxarNPC index, Count
            If Spell(SpellNum).SpellAnim > 0 Then SendAnimation GetPlayerMap(index), Spell(SpellNum).SpellAnim, 0, 0, TARGET_TYPE_NPC, Count
            ExpelirNpc index, Count, SpellNum
         End If
           If Not TempPlayer(index).Target = Count Then
              TempPlayer(index).Target = Count
              TempPlayer(index).targetType = TARGET_TYPE_NPC
              SendTarget index
           End If
    End If
    Exit Sub
End If
Count = Count + 1
Loop
    Call CheckAttackPlayer(index, Map, X, Y, Damage, SpellNum)
End Sub

Sub CheckAttackPlayer(ByVal index As Integer, ByVal Map As Integer, ByVal X As Byte, ByVal Y As Byte, ByVal Damage As Long, Optional ByVal SpellNum As Integer)
On Error Resume Next
Damage = Damage / 2.5
Dim Expelido As Byte

Dim Count As Byte
Count = 1
Do While Count <= Player_HighIndex
If Count <> index Then
    If IsPlaying(Count) Then
        If GetPlayerMap(Count) = Map And GetPlayerX(Count) = X And GetPlayerY(Count) = Y Then
            If CanPlayerAttackPlayer(index, Count, True) Then
                Call PlayerAttackPlayer(index, Count, Damage)
                If Spell(SpellNum).StunDuration > 0 Then StunPlayer Count, SpellNum, index
                If Spell(SpellNum).Duration > 0 Then AddDoT_Player Count, SpellNum, index
                If Spell(SpellNum).IsPush = YES Then PuxarPlayer index, Count
                If Spell(SpellNum).Expelir > 0 And Expelido = NO Then
                    ExpelirPlayer index, Count, SpellNum
                    Expelido = YES
                End If
                If Spell(SpellNum).SpellAnim > 0 Then SendAnimation GetPlayerMap(index), Spell(SpellNum).SpellAnim, 0, 0, TARGET_TYPE_PLAYER, Count
                If Not TempPlayer(index).Target = Count Then
                    TempPlayer(index).Target = Count
                    TempPlayer(index).targetType = TARGET_TYPE_PLAYER
                    SendTarget index
                End If
                
                'Se tiver ativado o sharingan Copy,envia o mesmo jutsu.
                If TempPlayer(Count).SharinganCopy > 0 Then
                    TempPlayer(Count).tmpSpell = SpellNum
                    CastSpell Count, 1, index, TARGET_TYPE_PLAYER, YES
                End If
            End If
        End If
    End If
End If
Count = Count + 1
Loop
End Sub

Public Sub ExpelirPlayer(ByVal attacker As Long, ByVal Vitima As Long, ByVal SpellNum As Long)
If SpellNum < 1 Or SpellNum > MAX_SPELLS Then Exit Sub
If Spell(SpellNum).Expelir < 1 Then Exit Sub
If Not IsPlaying(Vitima) Then Exit Sub
If Not GetPlayerMap(attacker) = GetPlayerMap(Vitima) Then Exit Sub
If TempPlayer(attacker).ExpelDelay > 0 Then Exit Sub

Dim i As Integer
Dim Dist As Byte

Select Case GetPlayerDir(attacker)

Case DIR_RIGHT
    Dist = GetPlayerX(Vitima) + Spell(SpellNum).Expelir
    If Dist > Map(GetPlayerMap(attacker)).MaxX Then Dist = Map(GetPlayerMap(attacker)).MaxX
    
    Player(Vitima).X = Dist
Case DIR_LEFT
    Dist = GetPlayerX(Vitima) - Spell(SpellNum).Expelir
    If Dist < 0 Then Dist = 0
    
    Player(Vitima).X = Dist
Case DIR_DOWN
    Dist = GetPlayerY(Vitima) + Spell(SpellNum).Expelir
    If Dist > Map(GetPlayerMap(attacker)).MaxY Then Dist = Map(GetPlayerMap(attacker)).MaxY
    
    Player(Vitima).Y = Dist
Case DIR_UP
    Dist = GetPlayerY(Vitima) - Spell(SpellNum).Expelir
    If Dist < 0 Then Dist = 0
    
    Player(Vitima).Y = GetPlayerY(Vitima) - Spell(SpellNum).Expelir

End Select

For i = 1 To Player_HighIndex
    If GetPlayerMap(i) = GetPlayerMap(Vitima) Then
        SendPlayerXYToMap i
    End If
Next

TempPlayer(attacker).ExpelDelay = GetTickCount + 1000
End Sub

Public Sub ExpelirNpc(ByVal attacker As Long, ByVal Vitima As Long, ByVal SpellNum As Long)
Dim i As Long
Dim MapX, mapY, Dist, distTotal, NpcX, NpcY As Byte


If attacker < 1 Or attacker > MAX_PLAYERS Then Exit Sub
If SpellNum < 1 Or SpellNum > MAX_SPELLS Then Exit Sub
If Spell(SpellNum).Expelir < 1 Then Exit Sub
If Vitima < 1 Or Vitima > MAX_NPCS Then Exit Sub
If TempPlayer(attacker).ExpelDelay > 0 Then Exit Sub

Dist = Spell(SpellNum).Expelir
MapX = Map(GetPlayerMap(attacker)).MaxX
mapY = Map(GetPlayerMap(attacker)).MaxY
NpcX = MapNpc(GetPlayerMap(attacker)).Npc(Vitima).X
NpcY = MapNpc(GetPlayerMap(attacker)).Npc(Vitima).Y

Select Case GetPlayerDir(attacker)
    Case DIR_RIGHT
     distTotal = NpcX + Dist
     If distTotal > MapX Then distTotal = MapX
      MapNpc(GetPlayerMap(attacker)).Npc(Vitima).X = distTotal
     
   Case DIR_LEFT
     distTotal = NpcX - Dist
     If distTotal < 1 Then distTotal = 0
      MapNpc(GetPlayerMap(attacker)).Npc(Vitima).X = distTotal
   
   Case DIR_DOWN
     distTotal = NpcY + Dist
     If distTotal > mapY Then distTotal = mapY
      MapNpc(GetPlayerMap(attacker)).Npc(Vitima).Y = distTotal
      
   Case DIR_UP
     distTotal = NpcY - Dist
     If distTotal < 1 Then distTotal = 0
      MapNpc(GetPlayerMap(attacker)).Npc(Vitima).Y = distTotal

End Select
SendMapNpcsToMap GetPlayerMap(attacker)
TempPlayer(attacker).ExpelDelay = GetTickCount + 1000


End Sub

Public Sub PuxarPlayer(ByVal index As Long, ByVal Vitima As Long)
On Error Resume Next
Dim X As Long
Dim Y As Long
Dim MapX As Long
Dim mapY As Long

If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If Vitima < 1 Or Vitima > MAX_PLAYERS Then Exit Sub
If GetPlayerMap(index) <> GetPlayerMap(Vitima) Then Exit Sub

MapX = Map(GetPlayerMap(index)).MaxX
mapY = Map(GetPlayerMap(index)).MaxY

Select Case GetPlayerDir(index)
    Case DIR_UP
        Player(Vitima).X = GetPlayerX(index)
        Y = GetPlayerY(index) - 1
        If Y < 1 Then Y = 1
        
        Player(Vitima).Y = Y
        
        Player(Vitima).Dir = DIR_DOWN
    Case DIR_DOWN
        Player(Vitima).X = GetPlayerX(index)
        Y = GetPlayerY(index) + 1
        If Y > mapY - 1 Then Y = mapY - 1
        
        Player(Vitima).Y = Y
        Player(Vitima).Dir = DIR_UP
    Case DIR_RIGHT
        X = GetPlayerX(index) + 1
        If X > MapX - 1 Then X = MapX - 1
        
        Player(Vitima).X = X
        Player(Vitima).Y = GetPlayerY(index)
        Player(Vitima).Dir = DIR_LEFT
    Case DIR_LEFT
        X = GetPlayerX(index) - 1
        If X < 1 Then X = 1
        
        Player(Vitima).X = X
        Player(Vitima).Y = GetPlayerY(index)
        Player(Vitima).Dir = DIR_RIGHT
End Select
       
   SendPlayerXYToMap Vitima
   
End Sub

Public Sub PuxarNPC(ByVal index As Long, ByVal mapNpcNum As Long)
Dim mapNum As Long
Dim Dist, MapX, mapY As Byte

If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If mapNpcNum < 1 Or mapNpcNum > MAX_MAP_NPCS Then Exit Sub

mapNum = GetPlayerMap(index)
MapX = Map(GetPlayerMap(index)).MaxX
mapY = Map(GetPlayerMap(index)).MaxY

Select Case GetPlayerDir(index)
    Case DIR_UP
        Dist = GetPlayerY(index) - 1
        If Dist < 1 Then Dist = 0
        MapNpc(mapNum).Npc(mapNpcNum).Y = Dist
        Dist = GetPlayerX(index)
        MapNpc(mapNum).Npc(mapNpcNum).X = Dist
        MapNpc(mapNum).Npc(mapNpcNum).Dir = DIR_DOWN
        
    Case DIR_DOWN
        Dist = GetPlayerY(index) + 1
        If Dist > mapY Then Dist = mapY
        MapNpc(mapNum).Npc(mapNpcNum).Y = Dist
        Dist = GetPlayerX(index)
        MapNpc(mapNum).Npc(mapNpcNum).X = Dist
        MapNpc(mapNum).Npc(mapNpcNum).Dir = DIR_UP
        
    Case DIR_RIGHT
        Dist = GetPlayerX(index) + 1
        If Dist > MapX Then Dist = MapX
        MapNpc(mapNum).Npc(mapNpcNum).X = Dist
        Dist = GetPlayerY(index)
        MapNpc(mapNum).Npc(mapNpcNum).Y = Dist
        MapNpc(mapNum).Npc(mapNpcNum).Dir = DIR_LEFT
        
    Case DIR_LEFT
        Dist = GetPlayerX(index) - 1
        If Dist < 1 Then Dist = 0
        MapNpc(mapNum).Npc(mapNpcNum).X = Dist
        Dist = GetPlayerY(index)
        MapNpc(mapNum).Npc(mapNpcNum).Y = Dist
        MapNpc(mapNum).Npc(mapNpcNum).Dir = DIR_RIGHT
End Select

SendMapNpcsToMap GetPlayerMap(index)
        
End Sub


Public Sub MagiaArea(ByVal index As Long, ByVal SpellNum As Long)
On Error Resume Next

If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If SpellNum < 1 Or SpellNum > MAX_SPELLS Then Exit Sub

Dim mapNum, Dano, Anim As Long
Dim X, Y As Long
Dim Dist As Byte

Dano = RAND(GetSpellBaseStat(index, SpellNum) - 10, GetSpellBaseStat(index, SpellNum))
Dist = Spell(SpellNum).Dist
Anim = Spell(SpellNum).RetaAnim(1)
mapNum = GetPlayerMap(index)
X = GetPlayerX(index)
Y = GetPlayerY(index)

SendJutsuAnim mapNum, 2, GetPlayerDir(index), SpellNum, X, Y

For Y = GetPlayerY(index) - Dist To GetPlayerY(index) + Dist
    For X = GetPlayerX(index) - Dist To GetPlayerX(index) + Dist
        If X >= 0 And X <= Map(mapNum).MaxX And Y >= 0 And Y <= Map(mapNum).MaxY Then
            CheckAttackNPC index, mapNum, X, Y, Dano, SpellNum
        End If
    Next
Next

End Sub


Public Sub MagiaReta(ByVal index As Long, ByVal SpellNum As Long)
On Error Resume Next

If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If SpellNum < 1 Or SpellNum > MAX_SPELLS Then Exit Sub

Dim Map, Forca, Dano, Anim As Long
Dim X, Y, i, larg, Dist, largura As Byte

Forca = RAND(GetSpellBaseStat(index, SpellNum) - 10, GetSpellBaseStat(index, SpellNum))
Dist = Spell(SpellNum).Dist
Map = GetPlayerMap(index)
X = GetPlayerX(index)
Y = GetPlayerY(index)
largura = Spell(SpellNum).Multipla

SendJutsuAnim Map, 1, GetPlayerDir(index), SpellNum, X, Y

For i = 1 To Dist
Select Case GetPlayerDir(index)
Case DIR_UP

Call CheckAttackNPC(index, Map, X, Y - i, Forca, SpellNum)

If largura > 0 Then
  For larg = 1 To largura
    
    Select Case i
    Case 1
       
    Case 2
        
    Case Else
        Call CheckAttackNPC(index, Map, X - larg, Y - i, Forca, SpellNum)
        Call CheckAttackNPC(index, Map, X + larg, Y - i, Forca, SpellNum)
    End Select
    
  Next
End If

Case DIR_DOWN

Call CheckAttackNPC(index, Map, X, Y + i, Forca, SpellNum)

If largura > 0 Then
  For larg = 1 To largura
  
    Select Case i
    Case 1
       
    Case 2
        
    Case Else
        Call CheckAttackNPC(index, Map, X - larg, Y + i, Forca, SpellNum)
        Call CheckAttackNPC(index, Map, X + larg, Y + i, Forca, SpellNum)
    End Select

  Next
End If

Case DIR_LEFT

Call CheckAttackNPC(index, Map, X - i, Y, Forca, SpellNum)

If largura > 0 Then
  For larg = 1 To largura
  
    Select Case i
    Case 1
       
    Case 2

    Case Else
        Call CheckAttackNPC(index, Map, X - i, Y + larg, Forca, SpellNum)
        Call CheckAttackNPC(index, Map, X - i, Y - larg, Forca, SpellNum)
    End Select
  
  Next
End If

Case DIR_RIGHT

Call CheckAttackNPC(index, Map, X + i, Y, Forca, SpellNum)

If largura > 0 Then
  For larg = 1 To largura
  
    Select Case i
        Case 1
       
        Case 2
            
        Case Else
            Call CheckAttackNPC(index, Map, X + i, Y + larg, Forca, SpellNum)
            Call CheckAttackNPC(index, Map, X + i, Y - larg, Forca, SpellNum)
        End Select
    
  Next
End If

End Select
Next

End Sub

Public Function GetSpellBaseStat(ByVal index As Long, ByVal SpellNum As Long) As Long
If SpellNum < 1 Or SpellNum > MAX_SPELLS Then Exit Function
If index < 1 Or index > MAX_PLAYERS Then Exit Function
Dim i As Long

If Spell(SpellNum).BaseStat = 0 Then
    GetSpellBaseStat = 1
    Exit Function
End If

   If SpellNum > 0 Then
       Select Case Spell(SpellNum).BaseStat
          Case 1
              GetSpellBaseStat = GetPlayerStat(index, Stats.strength) * 1.2 + GetPlayerLevel(index) / 6.2 + Spell(SpellNum).Vital
          Case 2
              GetSpellBaseStat = GetPlayerStat(index, Stats.Intelligence) * 1.2 + GetPlayerLevel(index) / 6.2 + Spell(SpellNum).Vital
          Case 3
              GetSpellBaseStat = GetPlayerStat(index, Stats.Agility) * 1.2 + GetPlayerLevel(index) / 6.2 + Spell(SpellNum).Vital
          Case 4
               GetSpellBaseStat = GetPlayerStat(index, Stats.Endurance) * 1.2 + GetPlayerLevel(index) / 6.2 + Spell(SpellNum).Vital
          Case 5
               GetSpellBaseStat = GetPlayerStat(index, Stats.Willpower) * 1.2 + GetPlayerLevel(index) / 6.2 + Spell(SpellNum).Vital
   
          End Select
    End If
    
    If SpellNum >= 7 And SpellNum <= 26 Then 'Elementais
        If GetClassStat(GetPlayerClass(index)) = Stats.strength Then
            GetSpellBaseStat = GetPlayerStat(index, Stats.strength) * 1.2 + GetPlayerLevel(index) / 6.2 + Spell(SpellNum).Vital
        Else
            GetSpellBaseStat = GetPlayerStat(index, Stats.Intelligence) * 1.2 + GetPlayerLevel(index) / 6.2 + Spell(SpellNum).Vital
        End If
    End If
    
    For i = 5 To 1 Step -1
        If TempPlayer(index).Dojutsu(i) > 0 Then
            GetSpellBaseStat = GetSpellBaseStat + (i * 5 / 100 * GetSpellBaseStat)
            Exit For
        End If
    Next
    
    If Player(index).Trans > 0 Then
        GetSpellBaseStat = GetSpellBaseStat + (Player(index).Trans * 5 / 100 * GetSpellBaseStat)
    End If
    
End Function

Sub CheckHits(ByVal index As Long, ByVal Vitima As Long)
If Vitima < 1 Then Exit Sub

Select Case TempPlayer(index).targetType
    Case TARGET_TYPE_NPC
            If TempPlayer(index).Hit(1) = Vitima Then
               TempPlayer(index).HitQnt(1) = TempPlayer(index).HitQnt(1) + 1
               SendActionMsg GetPlayerMap(index), TempPlayer(index).HitQnt(1) & " Hit's!", White, 1, (GetPlayerX(index) * 32 - 57), (GetPlayerY(index) * 32 - 35)
            Else
               TempPlayer(index).Hit(1) = Vitima
               TempPlayer(index).HitQnt(1) = 1
               SendActionMsg GetPlayerMap(index), "1 Hit!", White, 1, (GetPlayerX(index) * 32 - 61), (GetPlayerY(index) * 32 - 35)
            End If
            
    Case TARGET_TYPE_PLAYER
            If TempPlayer(index).Hit(2) = Vitima Then
               TempPlayer(index).HitQnt(2) = TempPlayer(index).HitQnt(2) + 1
               SendActionMsg GetPlayerMap(index), TempPlayer(index).HitQnt(2) & " Hit's!", White, 1, (GetPlayerX(index) * 32 - 57), (GetPlayerY(index) * 32 - 35)
            Else
               TempPlayer(index).Hit(2) = Vitima
               TempPlayer(index).HitQnt(2) = 1
               SendActionMsg GetPlayerMap(index), "1 Hit!", White, 1, (GetPlayerX(index) * 32 - 57), (GetPlayerY(index) * 32 - 35)
            End If
End Select

End Sub

Sub ClearHits(ByVal index As Long)
Dim i As Byte
For i = 1 To 2
  TempPlayer(index).Hit(i) = 0
  TempPlayer(index).HitQnt(i) = 0
Next

End Sub

Function CanStartQuest(ByVal index As Long, ByVal QuestNum As Long) As Boolean
Dim i As Long
Dim questSlot As Byte

If index < 1 Or index > MAX_PLAYERS Then Exit Function
If QuestNum < 1 Or QuestNum > MAX_QUESTS Then Exit Function

CanStartQuest = False

If CheckCanStartQuest(index, QuestNum) = NO Then
    Exit Function
End If

 For i = 1 To 10
   questSlot = Player(index).QuestNum(i)
   If questSlot > 0 Then
      If QuestNum = questSlot Then
         'PlayerMsg index, "Já está fazendo essa quest..", DarkGrey
         Exit Function
      End If
   End If
 Next
 
 If Quest(QuestNum).Repetivel = NO Then
     If Player(index).QuestCompleta(QuestNum) = YES Then
        'PlayerMsg index, "Ja fez essa quest", BrightRed
        Exit Function
     End If
 End If
 
 If Quest(QuestNum).ReqLevel > 0 Then
    If GetPlayerLevel(index) < Quest(QuestNum).ReqLevel Then
       PlayerMsg index, "Precisa ser no mínimo Level:" & Quest(QuestNum).ReqLevel, BrightRed
       Exit Function
    End If
 End If
 
 If Quest(QuestNum).ReqClasse > 0 Then
    If GetPlayerClass(index) <> Quest(QuestNum).ReqClasse Then
       PlayerMsg index, "Para fazer essa Missão,precisa ser:" & Class(Quest(QuestNum).ReqClasse).Name, BrightRed
       Exit Function
    End If
 End If
 
 If Quest(QuestNum).ReqParty > 0 Then
    If TempPlayer(index).inParty = 0 Then
       PlayerMsg index, "Você precisa de um grupo;" & Quest(QuestNum).ReqParty & " Membros", BrightRed
       Exit Function
    Else
       If Party(TempPlayer(index).inParty).MemberCount <> Quest(QuestNum).ReqParty Then
          PlayerMsg index, "Você precisa ter;" & Quest(QuestNum).ReqParty & " Membros no Grupo para começar.", BrightRed
          Exit Function
       End If
    End If
 End If

 If Quest(QuestNum).ReqVIP > 0 Then
    If Player(index).VipData.VIP < Quest(QuestNum).ReqVIP Then
       PlayerMsg index, "Precisa ser Doador para começar essa Missão.", BrightRed
       Exit Function
    End If
 End If
 
 If Quest(QuestNum).ReqVila > 0 Then
    If Player(index).Vila <> Quest(QuestNum).ReqVila Then
        PlayerMsg index, "Você não é da Vila necessária.", BrightRed
        Exit Function
    End If
End If

If Quest(QuestNum).ReqElemento > 0 Then
    For i = 1 To 5
        If Player(index).Elemento(i) <> Quest(QuestNum).ReqElemento Then
            PlayerMsg index, "Você não têm o Elemento necessário!", BrightRed
            Exit Function
        End If
    Next
End If
 
 If GetQuestFreeSlot(index) < 1 Then
   PlayerMsg index, "Você tem muitas missões ativas!", BrightRed
   Exit Function
 End If
 
 CanStartQuest = True
                    
          
End Function

Function GetQuestFreeSlot(ByVal index As Long) As Byte
Dim i As Byte
  
  For i = 1 To 10
     If Player(index).QuestNum(i) = 0 Then
        GetQuestFreeSlot = i
        Exit Function
     End If
  
  Next
  
End Function



Sub StartQuest(ByVal index As Long, ByVal QuestNum As Long, Optional ByVal NpcNum As Long)
Dim i As Long
Dim FreeSlot As Byte

If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If QuestNum < 1 Or QuestNum > MAX_QUESTS Then Exit Sub

FreeSlot = GetQuestFreeSlot(index)
If NpcNum > 0 Then
   For i = 1 To 10
       If Player(index).QuestInfo(i).QuestNpc(i) > 0 Then
          If Player(index).QuestInfo(i).QuestNpc(i) = NpcNum Then Exit Sub
       End If
          
   Next
End If

If CanStartQuest(index, QuestNum) = False Then Exit Sub

Player(index).QuestInfo(FreeSlot).QuestNpc(FreeSlot) = NpcNum
Player(index).QuestInfo(FreeSlot).Status = 2
UpdateQuestSlot index, QuestNum, FreeSlot

Player(index).QuestNum(FreeSlot) = QuestNum
PlayerMsg index, "Você iniciou a Missão ;" & Trim$(Quest(QuestNum).Name), BrightCyan
If Quest(QuestNum).StartScript > 0 Then ScriptStartQuest index, Quest(QuestNum).StartScript, QuestNum

'SendPlayerData index
SavePlayer index

If NpcNum > 0 Then
   SendPicFala index, Quest(QuestNum).Msg(1), NpcNum
End If

SendQuestPic index

End Sub

Sub UpdateQuestSlot(ByVal index As Long, ByVal QuestNum As Long, ByVal questSlot As Byte)
Dim i As Byte

If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If QuestNum < 1 Or QuestNum > MAX_QUESTS Then Exit Sub

 For i = 1 To 5
   Player(index).QuestInfo(questSlot).Item(i) = Quest(QuestNum).Item(i)
   Player(index).QuestInfo(questSlot).ItemQnt(i) = Quest(QuestNum).ItemQnt(i)
   Player(index).QuestInfo(questSlot).Npc(i) = Quest(QuestNum).Npc(i)
   Player(index).QuestInfo(questSlot).NpcQnt(i) = Quest(QuestNum).NpcQnt(i)
 Next
   Player(index).QuestInfo(questSlot).Name = Quest(QuestNum).Name
   Player(index).QuestInfo(questSlot).Msg(2) = Quest(QuestNum).Msg(2)
   Player(index).QuestInfo(questSlot).Desc = Quest(QuestNum).Desc
   Player(index).QuestInfo(questSlot).KillPlayerClass = Quest(QuestNum).KillPlayerClass
   Player(index).QuestInfo(questSlot).KillPlayerQnt = Quest(QuestNum).KillPlayerQnt
   Player(index).QuestInfo(questSlot).UsarSpell = Quest(QuestNum).UsarSpell
   Player(index).QuestInfo(questSlot).UsarSpellQnt = Quest(QuestNum).UsarSpellQnt

End Sub



Sub ClearQuestSlot(ByVal index As Long, ByVal questSlot As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If questSlot < 1 Or questSlot > 10 Then Exit Sub

Dim i As Byte, QuestNum As Long

QuestNum = Player(index).QuestNum(questSlot)
Player(index).QuestInfo(questSlot).Status = 0
Player(index).QuestInfo(questSlot).QuestNpc(questSlot) = 0

For i = 1 To 5
   Player(index).QuestInfo(questSlot).Item(i) = 0
   Player(index).QuestInfo(questSlot).ItemQnt(i) = 0
   Player(index).QuestInfo(questSlot).Npc(i) = 0
   Player(index).QuestInfo(questSlot).NpcQnt(i) = 0
 Next


Player(index).QuestNum(questSlot) = 0
SendQuestPic index
SavePlayer index

End Sub

Sub ClearQuestsCompletas(ByVal index As Long)
   Dim i As Long
   If index < 1 Or index > MAX_PLAYERS Then Exit Sub
   
   For i = 1 To MAX_QUESTS
       Player(index).QuestCompleta(i) = 0
   Next
End Sub

Sub QuestCompleta(ByVal index As Long, ByVal questSlot As Long)
Dim i, QuestID As Long

If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If questSlot < 1 Or questSlot > 10 Then Exit Sub

QuestID = Player(index).QuestNum(questSlot)

If Quest(QuestID).rClasse > 0 Then 'Classe
   SetPlayerClass index, Quest(QuestID).rClasse
   PlayerMsg index, "Você se transformou em " & Class(Quest(QuestID).rClasse).Name, White
End If

For i = 1 To 5 'Item
  If Quest(QuestID).rItem(i) > 0 Then
     GiveInvItem index, Quest(QuestID).rItem(i), Quest(QuestID).rItemQnt(i)
     PlayerMsg index, "Você acabou de ganhar " & Quest(QuestID).rItemQnt(i) & " " & Item(Quest(QuestID).rItem(i)).Name & "'s", White
  End If
Next

If Quest(QuestID).rSpell > 0 Then 'Spell
   If HasSpell(index, Quest(QuestID).rSpell) = False Then
        SetPlayerSpell index, FindOpenSpellSlot(index), Quest(QuestID).rSpell
        PlayerMsg index, "Aprendeu uma Técnica : " & Spell(Quest(QuestID).rSpell).Name, White
   End If
End If

If Quest(QuestID).rSprite > 0 Then 'Sprite
   SetPlayerSprite index, Quest(QuestID).rSprite
End If

If Quest(QuestID).rEXP > 0 Then 'EXP
    TempPlayer(index).GanhouEXP = YES
   GivePlayerEXP index, Quest(QuestID).rEXP
   PlayerMsg index, "Ganhou " & Quest(QuestID).rEXP & " de Experiência!", White
End If

If Quest(QuestID).rElemento > 0 Then
    For i = 1 To 5
    If Player(index).Elemento(i) = 0 Then
        Exit For
        Player(index).Elemento(i) = Quest(QuestID).rElemento
        PlayerMsg index, "Você está dominando um novo Elemento", BrightCyan
    Else
        PlayerMsg index, "Você já domina muitos Elementos!", BrightRed
    End If
    Next
End If

If Quest(QuestID).rEndScript > 0 Then ' Script quando acabar Quest
   ScriptEndQuest index, Quest(QuestID).rEndScript, QuestID
End If


Player(index).QuestCompleta(QuestID) = YES
Player(index).QuestInfo(questSlot).Status = 3
ClearQuestSlot index, questSlot
'SendPlayerData index

End Sub

Sub CheckQuestNPC(ByVal index As Long, ByVal NpcNum As Long, ByVal questSlot As Long)
Dim i, NpcQnt As Long
Dim QuestID As Long

If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If NpcNum < 1 Or NpcNum > MAX_NPCS Then Exit Sub
If questSlot < 1 Or questSlot > 10 Then Exit Sub

QuestID = Player(index).QuestNum(questSlot)
If Quest(QuestID).tipo <> QUEST_TYPE_NPC Then Exit Sub

For i = 1 To 5

    If Quest(QuestID).Npc(i) = NpcNum Then
    NpcQnt = Player(index).QuestInfo(questSlot).NpcQnt(i)
    
       If Player(index).QuestInfo(questSlot).NpcQnt(i) > 0 Then
          Player(index).QuestInfo(questSlot).NpcQnt(i) = Player(index).QuestInfo(questSlot).NpcQnt(i) - 1
       End If
       
       
        If Player(index).QuestInfo(questSlot).NpcQnt(i) > 0 Then
            If Quest(QuestID).Npc(i) > 0 Then
                PlayerMsg index, "Derrote :" & Npc(Player(index).QuestInfo(questSlot).Npc(i)).Name & "(" & Player(index).QuestInfo(questSlot).NpcQnt(i) & "/" & Quest(QuestID).NpcQnt(i) & ")", White
            End If
        End If
    End If
   

Next

If QuestID = 4 Then
    QuestCompleta index, questSlot
Else
    If Player(index).QuestInfo(questSlot).NpcQnt(1) = 0 And Player(index).QuestInfo(questSlot).NpcQnt(2) = 0 And Player(index).QuestInfo(questSlot).NpcQnt(3) = 0 And Player(index).QuestInfo(questSlot).NpcQnt(4) = 0 And Player(index).QuestInfo(questSlot).NpcQnt(5) = 0 Then
       Player(index).QuestInfo(questSlot).Status = 3
       
    If QuestID >= 108 And QuestID <= 110 Then
        QuestCompleta index, questSlot
        Exit Sub
    End If
        
        PlayerMsg index, "Missão: " & Quest(QuestID).Name & " completa!Fale com seu tutor para receber sua Recompensa.", DarkGrey
    End If
End If

End Sub

Sub CheckQuestItem(ByVal index As Long, ByVal itemNum As Long, ByVal questSlot As Byte)
Dim QuestID As Long

If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If itemNum < 1 Or itemNum > MAX_NPCS Then Exit Sub
If questSlot < 1 Or questSlot > 10 Then Exit Sub

QuestID = Player(index).QuestNum(questSlot)
If QuestID <= 1 Then Exit Sub

If Quest(QuestID).tipo <> QUEST_TYPE_ITEM Then Exit Sub
If Player(index).QuestInfo(questSlot).Status = 3 Then
    PlayerMsg index, "Missão: " & Quest(QuestID).Name & " completa!Fale com seu tutor para receber sua Recompensa ;D.", Yellow
    Exit Sub
End If
        
If CanTake(index, Quest(QuestID).Item(1), Quest(QuestID).ItemQnt(1)) Then
   Player(index).QuestInfo(questSlot).Status = 3
   TakeItem index, Quest(QuestID).Item(1), Quest(QuestID).ItemQnt(1)

    If QuestID >= 108 And QuestID <= 110 Then
        QuestCompleta index, questSlot
        Exit Sub
    End If
    
    PlayerMsg index, "Missão: " & Quest(QuestID).Name & " completa!Fale com seu tutor para receber sua Recompensa.", Yellow

End If


End Sub

Sub CheckQuestMAP(ByVal index As Long)
Dim QuestNum As Long
Dim i, questSlot As Byte

If index < 1 Or index > MAX_PLAYERS Then Exit Sub



For i = 1 To 10
    If Player(index).QuestNum(i) > 0 Then
       QuestNum = Player(index).QuestNum(i)
       If Quest(QuestNum).tipo = QUEST_TYPE_MAP Then
          If Quest(QuestNum).Map > 0 Then
             If GetPlayerMap(index) = Quest(QuestNum).Map Then
                PlayerMsg index, "Missão: " & Quest(QuestNum).Name & " completa!Fale com seu tutor para receber sua Recompensa.", Magenta
                Player(index).QuestInfo(i).Status = 3
             End If
          End If
       End If
    End If
Next

End Sub

Sub CheckQuestTalk(ByVal index As Long, ByVal questSlot As Byte, ByVal NpcNum As Long)
Dim i, QuestNum As Long
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If questSlot < 1 Or questSlot > 10 Then Exit Sub
If NpcNum < 1 Or NpcNum > MAX_NPCS Then Exit Sub
QuestNum = Player(index).QuestNum(questSlot)
    
If Quest(QuestNum).tipo <> QUEST_TYPE_TALKTO Then Exit Sub

   For i = 1 To 5
       If Player(index).QuestInfo(questSlot).Npc(i) > 0 Then
          If Player(index).QuestInfo(questSlot).Npc(i) = NpcNum Then
             If Player(index).QuestInfo(questSlot).NpcQnt(i) > 0 Then
              Player(index).QuestInfo(questSlot).NpcQnt(i) = Player(index).QuestInfo(questSlot).NpcQnt(i) - 1
             'Exit Sub
             End If
          End If
       End If
       
       
   Next


If Player(index).QuestInfo(questSlot).NpcQnt(1) = 0 And Player(index).QuestInfo(questSlot).NpcQnt(2) = 0 And Player(index).QuestInfo(questSlot).NpcQnt(3) = 0 And Player(index).QuestInfo(questSlot).NpcQnt(4) = 0 And Player(index).QuestInfo(questSlot).NpcQnt(5) = 0 Then
   Player(index).QuestInfo(questSlot).Status = 3
   PlayerMsg index, "Missão: " & Quest(QuestNum).Name & " completa!Fale com seu tutor para receber sua Recompensa.", BrightGreen
End If

End Sub

Sub CheckQuestLevel(ByVal index As Long)
Dim QuestNum As Long
Dim i, questSlot As Byte

    If index < 1 Or index > MAX_PLAYERS Then Exit Sub
    
    
    For i = 1 To 10
        If Player(index).QuestNum(i) > 0 Then
           QuestNum = Player(index).QuestNum(i)
           If Quest(QuestNum).tipo = QUEST_TYPE_LEVEL Then
              If GetPlayerLevel(index) >= Quest(QuestNum).NeedLevel Then
                 PlayerMsg index, "Missão: " & Quest(QuestNum).Name & " completa!Fale com seu tutor para receber sua Recompensa.", BrightCyan
                 Player(index).QuestInfo(i).Status = 3
              End If
           End If
        End If
    Next
    
End Sub

Public Sub CheckQuestUseSpell(ByVal index As Long, ByVal SpellNum As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If SpellNum < 1 Or SpellNum > MAX_SPELLS Then Exit Sub

Dim i As Byte, QuestNum As Long

For i = 1 To 10
    If Player(index).QuestNum(i) > 0 Then
        QuestNum = Player(index).QuestNum(i)
        If Quest(QuestNum).tipo = QUEST_TYPE_SPELL Then
            If Quest(QuestNum).UsarSpell > 0 Then
                If Quest(QuestNum).UsarSpell = SpellNum Then
                    If Player(index).QuestInfo(i).UsarSpellQnt > 1 Then
                        Player(index).QuestInfo(i).UsarSpellQnt = Player(index).QuestInfo(i).UsarSpellQnt - 1
                    
                    Else
                        Player(index).QuestInfo(i).Status = 3
                        Player(index).QuestInfo(i).UsarSpellQnt = 0
                        PlayerMsg index, "Missão: " & Quest(QuestNum).Name & " completa!Fale com seu tutor para receber sua Recompensa.", BrightBlue
                    End If
                
                    If Player(index).QuestInfo(i).UsarSpellQnt > 0 Then
                        PlayerMsg index, Spell(SpellNum).Name & ":" & Player(index).QuestInfo(i).UsarSpellQnt & "/" & Quest(QuestNum).UsarSpellQnt, White
                    End If
                End If
            End If
        End If
    End If
Next
End Sub



Sub CheckQuestKillPlayer(ByVal index As Long, ByVal Vitima As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If Vitima < 1 Or Vitima > MAX_PLAYERS Then Exit Sub
Dim i As Byte, QuestNum As Long

For i = 1 To 10
    If Player(index).QuestNum(i) > 0 Then
        QuestNum = Player(index).QuestNum(i)
        If Quest(QuestNum).tipo = QUEST_TYPE_KILLPLAYER Then
            If Quest(QuestNum).KillPlayerClass > 0 Then
                If GetPlayerClass(Vitima) <> Quest(QuestNum).KillPlayerClass Then Exit Sub
            End If
            
            If Player(index).QuestInfo(i).KillPlayerQnt < 2 Then
                Player(index).QuestInfo(i).Status = 3
                PlayerMsg index, "Missão: " & Quest(QuestNum).Name & " completa!Fale com seu tutor para receber sua Recompensa.", BrightBlue
            Else
                Player(index).QuestInfo(i).KillPlayerQnt = Player(index).QuestInfo(i).KillPlayerQnt - 1
            End If
            
            If Player(index).QuestInfo(i).KillPlayerQnt > 0 Then
                PlayerMsg index, Player(index).QuestInfo(i).KillPlayerQnt & "/" & Quest(QuestNum).KillPlayerQnt, White
            End If
        End If
    End If
Next
    
End Sub

Public Function Current_InvItemCount(ByVal index As Long, ByVal itemNum As Long) As Long
Dim i As Long
    If itemNum > 0 Then
        For i = 1 To MAX_INV
            If GetPlayerInvItemNum(index, i) = itemNum Then
                If Item(itemNum).Type = ITEM_TYPE_CURRENCY Then
                    Current_InvItemCount = Current_InvItemCount + GetPlayerInvItemValue(index, i)
                Else
                    Current_InvItemCount = Current_InvItemCount + 1
                End If
            End If
        Next
    End If
End Function

Function CanTake(ByVal index As Long, ByVal itemNum As Long, ByVal ItemValue As Long) As Boolean
Dim i As Long
  
  If itemNum > 0 Then
     If ItemValue > 0 Then
        If Current_InvItemCount(index, itemNum) >= ItemValue Then
           CanTake = True
           Exit Function
        End If
     End If
  End If
  

End Function

Sub TakeItem(ByVal index As Long, ByVal itemNum As Long, ByVal ItemValue As Long)
   Dim i As Long
   
   If itemNum < 1 Or itemNum > MAX_ITEMS Then Exit Sub
   If index < 1 Or index > MAX_PLAYERS Then Exit Sub
   
   'If CanTake(index, ItemNum, ItemValue) Then
      If Item(itemNum).Type = ITEM_TYPE_CURRENCY Then
         TakeInvItem index, itemNum, ItemValue
      Else
         For i = 1 To ItemValue
            TakeInvItem index, itemNum, i
         Next
      End If
    'End If
    
End Sub

Public Sub GiveItem(ByVal index As Long, ByVal itemNum As Long, ByVal ItemValue As Long)
If itemNum < 1 Or itemNum > MAX_ITEMS Then Exit Sub
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
Dim i As Long, Slot As Byte

Slot = FindOpenInvSlot(index, itemNum)
    If Slot = 0 Then
        PlayerMsg index, "Sem espaço na Mochila.", BrightRed
        Exit Sub
    End If

If Item(itemNum).Type = ITEM_TYPE_CURRENCY Then
    GiveInvItem index, itemNum, ItemValue, True
Else
    For i = 1 To ItemValue
        GiveInvItem index, itemNum, i
    Next
End If

End Sub

Public Sub TransUp(ByVal index As Long, ByVal TransNum As Byte, Optional ByVal VIP As Byte)
Dim i, Transformado As Byte
If index < 1 Or index > MAX_PLAYERS Then Exit Sub

If Player(index).Spec = YES Then
    PlayerMsg index, "Você está em modo Espectador,desative-o clicando de volta!", Red
    Exit Sub
End If

For i = 1 To 5
    If TempPlayer(index).Dojutsu(i) > 0 Then
        PlayerMsg index, "Uma técnica especial sua já esta ativada..", BrightRed
        Exit Sub
    End If
Next

If VIP > 0 Then
    If Player(index).VipData.VIP < VIP Then
        Select Case VIP
            Case 1
                PlayerMsg index, "Você precisa ser no mínimo;VIP Light!", BrightRed
            Case 2
                PlayerMsg index, "Você precisa ser no mínimo;VIP OhYeh!", BrightRed
        End Select
        
        Exit Sub
    End If
End If

If Player(index).Trans > 0 Then
    'PlayerMsg index, "Volte ao normal antes!", Red
    'Exit Sub
End If

Transformado = NO

Select Case TransNum
    Case 1
        If GetPlayerLevel(index) >= 30 Then
            Transformado = YES
            'For i = 1 To Stats.Stat_Count - 1
                'SetPlayerStat index, i, GetPlayerStat(index, i) + 30
            'Next
        
            Select Case GetPlayerClass(index)
                Case 1 'Naruto
                    SetPlayerSprite index, 3
                Case 2 'Sasuke
                    SetPlayerSprite index, 10
                    
                Case 6 'Chouji
                    SetPlayerSprite index, 18
                    Player(index).Voando = YES
                Case 7 'Rock Lee
                    SetPlayerSprite index, 24
                
                Case Else
            End Select
        Else
            PlayerMsg index, "Você não tem o level necessário(level 30)", BrightRed
        End If
    
    Case 2
        If GetPlayerLevel(index) >= 50 Then
        
            Transformado = YES
            
            'For i = 1 To Stats.Stat_Count - 1
                'SetPlayerStat index, i, GetPlayerStat(index, i) + 50
            'Next
        
            Select Case GetPlayerClass(index)
                Case 1 'Naruto
                    SetPlayerSprite index, 4
                Case 2 'Sasuke
                    SetPlayerSprite index, 11
                    Player(index).Voando = YES
                Case 3 'Sakura
                    SetPlayerSprite index, 30
                Case 4 'Ino
                    SetPlayerSprite index, 32
                Case 5 'Shikamaru
                    SetPlayerSprite index, 16
                Case 6 'Chouji
                    SetPlayerSprite index, 19
                Case 7 'Rock Lee
                    SetPlayerSprite index, 25
                Case 8 'Neji
                    SetPlayerSprite index, 38
                Case 9 'Tenten
                    SetPlayerSprite index, 34
                Case 10 'Inuzuka
                    SetPlayerSprite index, 36
                Case 11 'Aburame
                    SetPlayerSprite index, 28
                Case 12 'Gaara
                    SetPlayerSprite index, 21
                Case 13 'Kankurou
                    SetPlayerSprite index, 42
                Case 14 'Temari
                    SetPlayerSprite index, 46
                Case 15 'Hinata
                    SetPlayerSprite index, 40
                
                Case Else
            End Select
        Else
            PlayerMsg index, "Você não tem o level necessário(level 50)", BrightRed
        End If
        
    Case 3
        If GetPlayerLevel(index) >= 80 Then
        
            Transformado = YES
        
            'For i = 1 To Stats.Stat_Count - 1
                'SetPlayerStat index, i, GetPlayerStat(index, i) + 80
            'Next
        
            Select Case GetPlayerClass(index)
                Case 1 'Naruto
                    SetPlayerSprite index, 6
                Case 2 'Sasuke
                    SetPlayerSprite index, 12
                Case 3 'Sakura
                    SetPlayerSprite index, 30
                Case 4 'Ino
                    SetPlayerSprite index, 32
                Case 5 'Shikamaru
                    SetPlayerSprite index, 16
                Case 6 'Chouji
                    SetPlayerSprite index, 337
                Case 7 'Rock Lee
                    SetPlayerSprite index, 26
                Case 8 'Neji
                    SetPlayerSprite index, 38
                Case 9 'Tenten
                    SetPlayerSprite index, 34
                Case 10 'Inuzuka
                    SetPlayerSprite index, 36
                Case 11 'Aburame
                    SetPlayerSprite index, 28
                Case 12 'Gaara
                    SetPlayerSprite index, 22
                Case 13 'Kankurou
                    SetPlayerSprite index, 42
                Case 14 'Temari
                    SetPlayerSprite index, 46
                Case 15 'Hinata
                    SetPlayerSprite index, 40
                Case Else
            End Select
        Else
            PlayerMsg index, "Você não tem o level necessário(level 80)", BrightRed
        End If
    
    Case 4
        If GetPlayerLevel(index) >= 120 Then
        
            Transformado = YES
        
            'For i = 1 To Stats.Stat_Count - 1
                'SetPlayerStat index, i, GetPlayerStat(index, i) + 120
            'Next
        
            Select Case GetPlayerClass(index)
                Case 1 'Naruto
                    SetPlayerSprite index, 7
                Case 2 'Sasuke
                    SetPlayerSprite index, 13
                
                Case Else
            End Select
        Else
            PlayerMsg index, "Você não tem o level necessário(level 120)", BrightRed
        End If
        
    Case 5
        Dim wtf As Integer
        If GetPlayerClass(index) >= SAI Then 'Comprados/Torneios
            wtf = 30
        Else
            wtf = 150
        End If
        
        If GetPlayerLevel(index) >= wtf Then
        
            Transformado = YES
        
            'For i = 1 To Stats.Stat_Count - 1
                'SetPlayerStat index, i, GetPlayerStat(index, i) + 150
            'Next
        
            Select Case GetPlayerClass(index)
                Case 1 'Naruto
                    If RAND(1, 2) = 1 Then
                        SetPlayerSprite index, 364
                    Else
                        SetPlayerSprite index, 301
                    End If
                  
                Case 2 'Sasuke
                    SetPlayerSprite index, 14
                    Player(index).Voando = YES
                Case SAI
                    SetPlayerSprite index, 168
                Case YONDAIME
                    Select Case RAND(0, 3)
                        Case 1
                            SetPlayerSprite index, 137
                        Case 2
                            SetPlayerSprite index, 423
                        Case Else
                            SetPlayerSprite index, 461
                    End Select
                    
                Case KISAME
                    SetPlayerSprite index, 171
                Case DEIDARA
                    If RAND(1, 2) = 1 Then
                        SetPlayerSprite index, 172
                    Else
                        SetPlayerSprite index, 403
                    End If
                Case ITACHI
                    If RAND(1, 2) = 1 Then
                        SetPlayerSprite index, 173
                    Else
                        SetPlayerSprite index, 404
                    End If
                Case KIMIMARU
                    SetPlayerSprite index, RAND(93, 94)
                Case JIRAYA
                    If RAND(1, 2) = 1 Then
                        SetPlayerSprite index, 174
                    Else
                        SetPlayerSprite index, 299
                    End If
                Case TSUNADE
                    SetPlayerSprite index, 175
                Case KAKASHI
                    SetPlayerSprite index, 176
                Case PAIN
                    Select Case RAND(1, 3)
                        Case 1
                            SetPlayerSprite index, 177
                        Case 2
                            SetPlayerSprite index, 407
                        Case 3
                            SetPlayerSprite index, 408
                    Case Else
                    End Select
                    
                Case MADARA
                    SetPlayerSprite index, 179
                Case TOBI
                    If RAND(1, 2) = 1 Then
                        SetPlayerSprite index, 371
                    Else
                        SetPlayerSprite index, 133
                    End If
                Case OROCHIMARU
                    If RAND(1, 2) = 1 Then
                        SetPlayerSprite index, 181
                    Else
                        SetPlayerSprite index, 406
                    End If
                Case HAKU
                    SetPlayerSprite index, 309
                Case ZABUZA
                    SetPlayerSprite index, 310
                Case BEE
                    SetPlayerSprite index, 462
                Case HASHIRAMA
                    SetPlayerSprite index, 344
                Case YAMATO
                    SetPlayerSprite index, 351
                Case KONAN
                    SetPlayerSprite index, 369
                Case RAIKAGE
                    SetPlayerSprite index, 362
                Case DARUI
                    SetPlayerSprite index, 382
                Case HIDAN
                    SetPlayerSprite index, 390
                Case SASORI
                    SetPlayerSprite index, 397
                Case DANZOU
                    SetPlayerSprite index, 410
                Case YUGITO
                    SetPlayerSprite index, 416
                Case TOBIRAMA
                    SetPlayerSprite index, 426
                Case GAI
                    SetPlayerSprite index, 440
                Case MEI
                    SetPlayerSprite index, 449
                
                Case Else
            End Select
        Else
            PlayerMsg index, "Você não tem o level necessário", BrightRed
        End If
    
    Case 6
        If GetPlayerLevel(index) >= 180 Then
        
            Transformado = YES
        
            'For i = 1 To Stats.Stat_Count - 1
                'SetPlayerStat index, i, GetPlayerStat(index, i) + 180
            'Next
        
            Select Case GetPlayerClass(index)
                Case 1 'Naruto
                    SetPlayerSprite index, 458
                    
                Case Else
            End Select
        Else
            PlayerMsg index, "Você não tem o level necessário(level 180)", BrightRed
        End If
    
    Case Else
End Select
           
If Transformado = YES Then

If TempPlayer(index).SemRoupa = NO Then

Select Case GetPlayerClass(index)
    Case 1 'Naruto
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 183
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 184
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 185
            Case ORG_AKATSUKI
                SetPlayerSprite index, 156
            Case ORG_TAKA
                SetPlayerSprite index, 186
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 183
                End If
        End Select
    Case 2 'Sasuke
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 187
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 188
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 189
            Case ORG_AKATSUKI
                SetPlayerSprite index, 120
            Case ORG_TAKA
                SetPlayerSprite index, 190
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 187
                End If
        End Select
    Case 3 'Sakura
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 191
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 192
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 193
            Case ORG_AKATSUKI
                SetPlayerSprite index, 143
            Case ORG_TAKA
                SetPlayerSprite index, 194
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 191
                End If
        End Select
    Case 4 'Ino
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 195
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 196
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 197
            Case ORG_AKATSUKI
                SetPlayerSprite index, 144
            Case ORG_TAKA
                SetPlayerSprite index, 198
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 195
                End If
        End Select
    Case 5 'Shikamaru
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 199
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 200
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 201
            Case ORG_AKATSUKI
                SetPlayerSprite index, 152
            Case ORG_TAKA
                SetPlayerSprite index, 202
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 199
                End If
        End Select
    Case 6 'Chouji
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 203
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 204
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 205
            Case ORG_AKATSUKI
                SetPlayerSprite index, 141
            Case ORG_TAKA
                SetPlayerSprite index, 206
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 203
                End If
        End Select
    Case 7 'Lee
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 207
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 208
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 209
            Case ORG_AKATSUKI
                SetPlayerSprite index, 149
            Case ORG_TAKA
                SetPlayerSprite index, 210
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 207
                End If
        End Select
    Case 8 'Hyuuga
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 211
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 212
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 213
            Case ORG_AKATSUKI
                SetPlayerSprite index, 150
            Case ORG_TAKA
                SetPlayerSprite index, 214
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 211
                End If
        End Select
    Case 9 'Tenten
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 215
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 216
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 217
            Case ORG_AKATSUKI
                SetPlayerSprite index, 155
            Case ORG_TAKA
                SetPlayerSprite index, 218
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 215
                End If
        End Select
    Case 10 'Inuzuka
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 219
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 220
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 221
            Case ORG_AKATSUKI
                SetPlayerSprite index, 148
            Case ORG_TAKA
                SetPlayerSprite index, 222
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 219
                End If
        End Select
    Case 11 'Aburame
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 223
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 224
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 225
            Case ORG_AKATSUKI
                SetPlayerSprite index, 153
            Case ORG_TAKA
                SetPlayerSprite index, 226
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 223
                End If
        End Select
    Case 12 'Gaara
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 227
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 228
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 229
            Case ORG_AKATSUKI
                SetPlayerSprite index, 142
            Case ORG_TAKA
                SetPlayerSprite index, 230
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 227
                End If
        End Select
    Case 13 'Kankurou
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 231
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 232
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 233
            Case ORG_AKATSUKI
                SetPlayerSprite index, 147
            Case ORG_TAKA
                SetPlayerSprite index, 234
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 231
                End If
        End Select
    Case 14 'Temari
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 235
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 236
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 237
            Case ORG_AKATSUKI
                SetPlayerSprite index, 154
            Case ORG_TAKA
                SetPlayerSprite index, 238
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 235
                End If
        End Select
    Case 15 'Hinata
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 239
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 240
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 241
            Case ORG_AKATSUKI
                SetPlayerSprite index, 164
            Case ORG_TAKA
                SetPlayerSprite index, 242
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 239
                End If
        End Select
    Case SAI '
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 243
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 244
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 245
            Case ORG_AKATSUKI
                SetPlayerSprite index, 151
            Case ORG_TAKA
                SetPlayerSprite index, 246
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 243
                End If
        End Select
    Case YONDAIME '
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 247
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 248
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 249
            Case ORG_AKATSUKI
                SetPlayerSprite index, 250
            Case ORG_TAKA
                SetPlayerSprite index, 251
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 247
                End If
        End Select
    
    Case KISAME ' transdown
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 252
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 131
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 253
            Case ORG_AKATSUKI
                SetPlayerSprite index, 131
            Case ORG_TAKA
                SetPlayerSprite index, 254
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 252
                End If
        End Select
    Case DEIDARA ' transdown
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 255
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 256
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 257
            Case ORG_AKATSUKI
                SetPlayerSprite index, 102
            Case ORG_TAKA
                SetPlayerSprite index, 258
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 255
                End If
        End Select
    Case ITACHI ' transdown
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 259
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 260
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 261
            Case ORG_AKATSUKI
                SetPlayerSprite index, 130
            Case ORG_TAKA
                SetPlayerSprite index, 262
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 259
                End If
        End Select
    Case KIMIMARU ' transdown
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 263
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 264
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 265
            Case ORG_AKATSUKI
                SetPlayerSprite index, 145
            Case ORG_TAKA
                SetPlayerSprite index, 266
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 263
                End If
        End Select
    Case JIRAYA ' transdown
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 267
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 268
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 269
            Case ORG_AKATSUKI
                SetPlayerSprite index, 270
            Case ORG_TAKA
                SetPlayerSprite index, 271
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 267
                End If
        End Select
    Case TSUNADE ' transdown
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 272
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 273
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 274
            Case ORG_AKATSUKI
                SetPlayerSprite index, 275
            Case ORG_TAKA
                SetPlayerSprite index, 276
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 272
                End If
        End Select
    Case KAKASHI ' transdown
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 277
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 278
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 279
            Case ORG_AKATSUKI
                SetPlayerSprite index, 146
            Case ORG_TAKA
                SetPlayerSprite index, 280
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 277
                End If
        End Select
    Case PAIN ' transdown
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 281
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 282
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 283
            Case ORG_AKATSUKI
                SetPlayerSprite index, 124
            Case ORG_TAKA
                SetPlayerSprite index, 284
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 281
                End If
        End Select
    Case MADARA ' transdown
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 285
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 286
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 287
            Case ORG_AKATSUKI
                SetPlayerSprite index, 288
            Case ORG_TAKA
                SetPlayerSprite index, 289
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 285
                End If
        End Select
    Case OROCHIMARU ' transdown
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 294
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 295
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 296
            Case ORG_AKATSUKI
                SetPlayerSprite index, 297
            Case ORG_TAKA
                SetPlayerSprite index, 298
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 294
                End If
        End Select
    Case TOBI ' transdown
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 290
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 291
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 292
            Case ORG_AKATSUKI
                SetPlayerSprite index, 132
            Case ORG_TAKA
                SetPlayerSprite index, 293
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 290
                End If
        End Select
    Case HAKU
        SetPlayerSprite index, 309
        
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 327
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 328
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 329
            Case ORG_AKATSUKI
                SetPlayerSprite index, 326
            Case ORG_TAKA
                SetPlayerSprite index, 330
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 327
                End If
            End Select
    Case ZABUZA
        SetPlayerSprite index, 310
        
            Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 323
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 82
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 324
            Case ORG_AKATSUKI
                SetPlayerSprite index, 322
            Case ORG_TAKA
                SetPlayerSprite index, 325
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 323
                End If
            End Select
    Case BEE
        SetPlayerSprite index, 342
        
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 332
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 333
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 334
            Case ORG_AKATSUKI
                SetPlayerSprite index, 331
            Case ORG_TAKA
                SetPlayerSprite index, 335
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 332
                End If
        End Select
    
    Case HASHIRAMA
        SetPlayerSprite index, 344
        
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 346
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 347
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 348
            Case ORG_AKATSUKI
                SetPlayerSprite index, 345
            Case ORG_TAKA
                SetPlayerSprite index, 349
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 346
                End If
        End Select
        
    Case YAMATO
        SetPlayerSprite index, 351
        
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 353
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 354
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 355
            Case ORG_AKATSUKI
                SetPlayerSprite index, 352
            Case ORG_TAKA
                SetPlayerSprite index, 356
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 353
                End If
        End Select
    Case KONAN
        SetPlayerSprite index, 369
        
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 365
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 366
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 367
            Case ORG_AKATSUKI
                SetPlayerSprite index, 123
            Case ORG_TAKA
                SetPlayerSprite index, 368
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 365
                End If
        End Select
        
    Case RAIKAGE
        SetPlayerSprite index, 362
        
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 375
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 376
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 377
            Case ORG_AKATSUKI
                SetPlayerSprite index, 374
            Case ORG_TAKA
                SetPlayerSprite index, 378
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 375
                End If
        End Select
    
    Case DARUI
        SetPlayerSprite index, 382
        
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 386
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 385
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 384
            Case ORG_AKATSUKI
                SetPlayerSprite index, 387
            Case ORG_TAKA
                SetPlayerSprite index, 383
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 386
                End If
        End Select
        
    Case HIDAN
        SetPlayerSprite index, 390
        
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 392
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 393
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 394
            Case ORG_AKATSUKI
                SetPlayerSprite index, 389
            Case ORG_TAKA
                SetPlayerSprite index, 395
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 392
                End If
        End Select
        
    Case SASORI
        SetPlayerSprite index, 397
        
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 399
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 400
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 401
            Case ORG_AKATSUKI
                SetPlayerSprite index, 396
            Case ORG_TAKA
                SetPlayerSprite index, 402
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 399
                End If
        End Select
    
    Case DANZOU
        SetPlayerSprite index, 410
        
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 412
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 413
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 414
            Case ORG_AKATSUKI
                SetPlayerSprite index, 411
            Case ORG_TAKA
                SetPlayerSprite index, 415
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 412
                End If
        End Select
        
    Case YUGITO
        SetPlayerSprite index, 416
        
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 418
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 419
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 420
            Case ORG_AKATSUKI
                SetPlayerSprite index, 417
            Case ORG_TAKA
                SetPlayerSprite index, 421
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 418
                End If
        End Select
    
    Case TOBIRAMA
        SetPlayerSprite index, 426
        
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 428
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 429
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 430
            Case ORG_AKATSUKI
                SetPlayerSprite index, 427
            Case ORG_TAKA
                SetPlayerSprite index, 431
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 428
                End If
        End Select
    
    Case GAI
        SetPlayerSprite index, 440
        
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 442
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 445
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 443
            Case ORG_AKATSUKI
                SetPlayerSprite index, 441
            Case ORG_TAKA
                SetPlayerSprite index, 444
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 442
                End If
        End Select
    
    Case MEI
        SetPlayerSprite index, 449
        
        Select Case Player(index).Org
            Case ORG_ANBURAIZ
                SetPlayerSprite index, 451
            Case ORG_7ESPADACHINS
                SetPlayerSprite index, 452
            Case ORG_12GUARDIOES
                SetPlayerSprite index, 453
            Case ORG_AKATSUKI
                SetPlayerSprite index, 450
            Case ORG_TAKA
                SetPlayerSprite index, 454
            Case Else
                If Player(index).Rank = RANK_ANBU Then
                    SetPlayerSprite index, 451
                End If
        End Select
        
    Case Else
End Select

    'Sprite dos kages
    If Player(index).Rank = RANK_KAGE Then
            Select Case Player(index).Vila
                Case 0 'lider
                    If RAND(1, 2) = 1 Then
                        SetPlayerSprite index, 379
                    Else
                        SetPlayerSprite index, 405
                    End If
                Case 1 'konoha
                    SetPlayerSprite index, 163
                Case 2 'suna
                    SetPlayerSprite index, 162
                Case 3 'Mizu
                    SetPlayerSprite index, 159
                Case 4 'Iwa
                    SetPlayerSprite index, 161
                Case 5 'Kumo
                    SetPlayerSprite index, 160
                Case 6
                    SetPlayerSprite index, 446
                
                Case Else
            End Select
    End If

End If
    
    If GetPlayerClass(index) < SAI Then
        Player(index).Trans = TransNum
    Else
        Player(index).Trans = 4
    End If
    SendAnimation GetPlayerMap(index), 2, 0, 0, TARGET_TYPE_PLAYER, index
    SendPlayerData index
End If

End Sub

Public Sub TransDown(ByVal index As Long)
Dim u As Byte
Dim i As Byte

If index < 1 Or index > MAX_PLAYERS Then Exit Sub

If Player(index).Spec = YES Then
    PlayerMsg index, "Você está em modo Espectador,desative-o clicando de volta!", Red
    Exit Sub
End If

For i = 1 To 5
    If TempPlayer(index).Dojutsu(i) > 0 Then
        PlayerMsg index, "Uma técnica especial sua já esta ativada..", BrightRed
        Exit Sub
    End If
Next

Select Case GetPlayerClass(index)
    Case NARUTO
        SetPlayerSprite index, 1
    Case SASUKE
        SetPlayerSprite index, 9
    Case SAKURA
        SetPlayerSprite index, 29
    Case INO
        SetPlayerSprite index, 31
    Case SHIKAMARU
        SetPlayerSprite index, 15
    Case CHOUJI
        SetPlayerSprite index, 17
    Case LEE
        SetPlayerSprite index, 23
    Case NEJI
        SetPlayerSprite index, 37
    Case TENTEN
        SetPlayerSprite index, 33
    Case KIBA
        SetPlayerSprite index, 35
    Case SHINO
        SetPlayerSprite index, 27
    Case GAARA
        SetPlayerSprite index, 20
    Case KANKUROU
        SetPlayerSprite index, 41
    Case TEMARI
        SetPlayerSprite index, 45
    Case HINATA
        SetPlayerSprite index, 39
    Case SAI '
        SetPlayerSprite index, 43
    Case YONDAIME '
        SetPlayerSprite index, 169
    Case KISAME ' transdown
        SetPlayerSprite index, 131
    Case DEIDARA ' transdown
        SetPlayerSprite index, 102
    Case ITACHI ' transdown
        SetPlayerSprite index, 130
    Case KIMIMARU ' transdown
        SetPlayerSprite index, 92
    Case JIRAYA ' transdown
        SetPlayerSprite index, 134
    Case TSUNADE ' transdown
        SetPlayerSprite index, 136
    Case KAKASHI ' transdown
        SetPlayerSprite index, 84
    Case PAIN ' transdown
        SetPlayerSprite index, 124
    Case MADARA ' transdown
        SetPlayerSprite index, 178
    Case OROCHIMARU ' transdown
        SetPlayerSprite index, 98
    Case TOBI ' transdown
        SetPlayerSprite index, 132
    Case HAKU
        SetPlayerSprite index, 81
    Case ZABUZA
        SetPlayerSprite index, 82
    Case BEE
        SetPlayerSprite index, 138
    Case HASHIRAMA
        SetPlayerSprite index, 343
    Case YAMATO
        SetPlayerSprite index, 350
    Case KONAN
        SetPlayerSprite index, 123
    Case RAIKAGE
        SetPlayerSprite index, 373
    Case DARUI
        SetPlayerSprite index, 381
    Case HIDAN
        SetPlayerSprite index, 389
    Case SASORI
        SetPlayerSprite index, 396
    Case DANZOU
        SetPlayerSprite index, 409
    Case YUGITO
        SetPlayerSprite index, 308
    Case TOBIRAMA
        SetPlayerSprite index, 425
    Case GAI
        SetPlayerSprite index, 438
    Case MEI
        SetPlayerSprite index, 448
        
    Case Else
End Select

If TempPlayer(index).SemRoupa = NO Then
    'Sprite dos kages
    If Player(index).Rank = RANK_KAGE Then
            Select Case Player(index).Vila
                Case 0 'lider
                    If RAND(1, 2) = 1 Then
                        SetPlayerSprite index, 379
                    Else
                        SetPlayerSprite index, 405
                    End If
                Case 1 'konoha
                    SetPlayerSprite index, 163
                Case 2 'suna
                    SetPlayerSprite index, 162
                Case 3 'Mizu
                    SetPlayerSprite index, 159
                Case 4 'Iwa
                    SetPlayerSprite index, 161
                Case 5 'Kumo
                    SetPlayerSprite index, 160
                Case 6
                    SetPlayerSprite index, 446
                    
                Case Else
            End Select
    End If
End If

If GetPlayerClass(index) < SAI Then
    Player(index).Trans = 0
Else
    Player(index).Trans = 2
End If

Player(index).Voando = NO

SendPlayerData index

End Sub

Public Sub BlockPlayer(ByVal index As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub

Select Case GetPlayerDir(index)
    Case DIR_UP
        If Player(index).Y + 1 > Map(GetPlayerMap(index)).MaxY Then
            Player(index).Y = Map(GetPlayerMap(index)).MaxY
        Else
            Player(index).Y = Player(index).Y + 1
        End If
        
    Case DIR_DOWN
        If Player(index).Y - 1 < 1 Then
            Player(index).Y = 0
        Else
            Player(index).Y = Player(index).Y - 1
        End If
    Case DIR_LEFT
        If Player(index).X + 1 > Map(GetPlayerMap(index)).MaxX Then
            Player(index).X = Map(GetPlayerMap(index)).MaxX
        Else
            Player(index).X = Player(index).X + 1
        End If
        
    Case DIR_RIGHT
        If Player(index).X - 1 < 1 Then
            Player(index).X = 0
        Else
            Player(index).X = Player(index).X - 1
        End If
        
End Select

SendPlayerXY index

End Sub


Public Function CheckSeals(ByVal index As Long, ByVal SpellNum As Long) As Boolean
If index < 1 Or index > MAX_PLAYERS Then Exit Function
If SpellNum < 1 Or SpellNum > MAX_SPELLS Then Exit Function

If Spell(SpellNum).BaseStat = 1 Or Spell(SpellNum).BaseStat = 0 Then Exit Function

Dim L As Long

L = GetPlayerLevel(index)

If L >= 1 And L < 10 Then
    If RAND(1, 10) = 1 Then
        CheckSeals = True
        Exit Function
    End If

ElseIf L >= 10 And L < 20 Then
    If RAND(1, 8) = 1 Then
        CheckSeals = True
        Exit Function
    End If

ElseIf L >= 20 And L < 30 Then
    If RAND(1, 6) = 1 Then
        CheckSeals = True
        Exit Function
    End If
    
ElseIf L >= 30 And L < 40 Then
    If RAND(1, 4) = 1 Then
        CheckSeals = True
        Exit Function
    End If

ElseIf L >= 40 And L < 50 Then
    If RAND(1, 2) = 1 Then
        CheckSeals = True
        Exit Function
    End If

ElseIf L >= 50 Then
    CheckSeals = True
    Exit Function
End If

CheckSeals = False
PlayerMsg index, "Seu jutsu falhou..Tente de novo!", BrightRed

End Function

Public Sub TirarDojutsu(ByVal index As Long, ByVal DojutsuNum As Byte)
Dim i As Byte
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If DojutsuNum < 1 Then Exit Sub

Select Case GetPlayerClass(index)
    Case NARUTO, CHOUJI, KONAN, KISAME, SASORI, HIDAN, YUGITO
        If Not GetPlayerSprite(index) = TempPlayer(index).MySprite Then
            SetPlayerSprite index, TempPlayer(index).MySprite
            SendPlayerData index
        End If
    Case Else
End Select

TempPlayer(index).Dojutsu(DojutsuNum) = 0
                
End Sub

Sub CheckNPCAttackNpc(ByVal mapNpcNum As Byte, ByVal Map As Long, ByVal X As Byte, ByVal Y As Byte, ByVal Damage As Long, Optional ByVal SpellNum As Long)
On Error Resume Next

If Damage < 1 Then Exit Sub

Dim Count As Byte
Count = 1
Do While Count < MAX_MAP_NPCS
    If Count <> mapNpcNum Then
        If MapNpc(Map).Npc(Count).X = X And MapNpc(Map).Npc(Count).Y = Y Then
            If CanNpcAttackNpc(Map, mapNpcNum, Count, YES) Then
                Call NpcAttackNpc(Map, mapNpcNum, Count, Damage)
                 If SpellNum > 0 Then
                    If Spell(SpellNum).StunDuration > 0 Then
                        MapNpc(Map).Npc(Count).StunDuration = Spell(SpellNum).StunDuration
                        MapNpc(Map).Npc(Count).StunTimer = GetTickCount
                    End If
                    If Spell(SpellNum).IsPush = YES Then NpcPuxarNPC Map, mapNpcNum, Count
                    NpcExpelirNpc mapNpcNum, mapNpcNum, Count, SpellNum
                 End If
            'Exit Sub
            End If
        End If
    End If
Count = Count + 1
Loop
    Call CheckNPCAttackPlayer(mapNpcNum, Map, X, Y, Damage, SpellNum)
End Sub

Sub CheckNPCAttackPlayer(ByVal mapNpcNum As Byte, ByVal Map As Long, ByVal X As Byte, ByVal Y As Byte, ByVal Damage As Long, Optional ByVal SpellNum As Long)
On Error Resume Next

Dim Count As Byte
Count = 1
Do While Count <= Player_HighIndex
    If IsPlaying(Count) Then
        If GetPlayerMap(Count) = Map And GetPlayerX(Count) = X And GetPlayerY(Count) = Y Then
            If Not MapNpc(Map).Npc(mapNpcNum).PetData.Owner = Count Then
                If Player(Count).Invisivel = NO Then
                    Call NpcAttackPlayer(mapNpcNum, Count, Damage)
                    If SpellNum > 0 Then
                         If Spell(SpellNum).StunDuration > 0 Then
                              TempPlayer(Count).StunDuration = Spell(SpellNum).StunDuration
                              TempPlayer(Count).StunTimer = GetTickCount
                              SendStunned Count
                              PlayerMsg Count, "Você está paralizado.", BrightRed
                          End If
                         If Spell(SpellNum).IsPush = YES Then NpcPuxarPlayer mapNpcNum, Count
                         NpcExpelirPlayer mapNpcNum, Count, SpellNum
                    End If
                End If
            End If
        End If
    End If
Count = Count + 1
Loop
End Sub

Public Sub NpcExpelirPlayer(ByVal mapNpcNum As Byte, ByVal Vitima As Long, ByVal SpellNum As Long)
If mapNpcNum < 1 Or mapNpcNum > MAX_MAP_NPCS Then Exit Sub
If SpellNum < 1 Or SpellNum > MAX_SPELLS Then Exit Sub
If Spell(SpellNum).Expelir < 1 Then Exit Sub
If Not IsPlaying(Vitima) Then Exit Sub

Select Case MapNpc(GetPlayerMap(Vitima)).Npc(mapNpcNum).Dir

Case DIR_RIGHT
PlayerWarp Vitima, GetPlayerMap(Vitima), GetPlayerX(Vitima) + Spell(SpellNum).Expelir, GetPlayerY(Vitima)
Case DIR_LEFT
PlayerWarp Vitima, GetPlayerMap(Vitima), GetPlayerX(Vitima) - Spell(SpellNum).Expelir, GetPlayerY(Vitima)
Case DIR_DOWN
PlayerWarp Vitima, GetPlayerMap(Vitima), GetPlayerX(Vitima), GetPlayerY(Vitima) + Spell(SpellNum).Expelir
Case DIR_UP
PlayerWarp Vitima, GetPlayerMap(Vitima), GetPlayerX(Vitima), GetPlayerY(Vitima) - Spell(SpellNum).Expelir

End Select
End Sub

Public Sub NpcExpelirNpc(ByVal mapNum As Long, ByVal mapNpcNum As Byte, ByVal Vitima As Long, ByVal SpellNum As Long)
Dim i As Long
Dim MapX, mapY, Dist, distTotal, NpcX, NpcY As Byte
If mapNpcNum < 1 Or mapNpcNum > MAX_MAP_NPCS Then Exit Sub
If SpellNum < 1 Or SpellNum > MAX_SPELLS Then Exit Sub
If Spell(SpellNum).Expelir < 1 Then Exit Sub
If Vitima < 1 Or Vitima > MAX_NPCS Then Exit Sub

Dist = Spell(SpellNum).Expelir
MapX = Map(mapNum).MaxX
mapY = Map(mapNum).MaxY
NpcX = MapNpc(mapNum).Npc(Vitima).X
NpcY = MapNpc(mapNum).Npc(Vitima).Y

Select Case MapNpc(mapNum).Npc(mapNpcNum).Dir
    Case DIR_RIGHT
     distTotal = NpcX + Dist
     If distTotal > MapX Then distTotal = MapX
      MapNpc(mapNum).Npc(Vitima).X = distTotal
     
   Case DIR_LEFT
     distTotal = NpcX - Dist
     If distTotal < 1 Then distTotal = 0
      MapNpc(mapNum).Npc(Vitima).X = distTotal
   
   Case DIR_DOWN
     distTotal = NpcY + Dist
     If distTotal > mapY Then distTotal = mapY
      MapNpc(mapNum).Npc(Vitima).Y = distTotal
      
   Case DIR_UP
     distTotal = NpcY - Dist
     If distTotal < 1 Then distTotal = 0
      MapNpc(mapNum).Npc(Vitima).Y = distTotal

End Select
SendMapNpcsToMap mapNum



End Sub

Public Sub NpcPuxarPlayer(ByVal mapNpcNum As Long, ByVal Vitima As Long)
If mapNpcNum < 1 Or mapNpcNum > MAX_MAP_NPCS Then Exit Sub
If Vitima < 1 Or Vitima > MAX_PLAYERS Then Exit Sub
Dim Dist, MapX, mapY, NpcX, NpcY As Byte
Dim mapNum As Long

mapNum = GetPlayerMap(Vitima)
MapX = Map(mapNum).MaxX
mapY = Map(mapNum).MaxY
NpcX = MapNpc(mapNum).Npc(mapNpcNum).X
NpcY = MapNpc(mapNum).Npc(mapNpcNum).Y

Select Case MapNpc(mapNum).Npc(mapNpcNum).Dir
    Case DIR_UP
        Player(Vitima).X = NpcX
        Player(Vitima).Y = NpcY - 1
        Player(Vitima).Dir = DIR_DOWN
    Case DIR_DOWN
        Player(Vitima).X = NpcX
        Player(Vitima).Y = NpcY + 1
        Player(Vitima).Dir = DIR_UP
    Case DIR_RIGHT
        Player(Vitima).X = NpcX + 1
        Player(Vitima).Y = NpcY
        Player(Vitima).Dir = DIR_LEFT
    Case DIR_LEFT
        Player(Vitima).X = NpcX - 1
        Player(Vitima).Y = NpcY
        Player(Vitima).Dir = DIR_RIGHT
End Select
       
   SendPlayerData Vitima
   
End Sub

Public Sub NpcPuxarNPC(ByVal mapNum As Long, ByVal mapNpcNum As Byte, ByVal victim As Byte)

Dim Dist, MapX, mapY, NpcX, NpcY As Byte

If mapNum < 1 Or mapNum > MAX_MAPS Then Exit Sub
If mapNpcNum < 1 Or mapNpcNum > MAX_MAP_NPCS Then Exit Sub
If victim < 1 Or victim > MAX_MAP_NPCS Then Exit Sub

MapX = Map(mapNum).MaxX
mapY = Map(mapNum).MaxY
NpcX = MapNpc(mapNum).Npc(mapNpcNum).X
NpcY = MapNpc(mapNum).Npc(mapNpcNum).Y

Select Case MapNpc(mapNum).Npc(mapNpcNum).Dir
    Case DIR_UP
        Dist = NpcY - 1
        If Dist < 1 Then Dist = 0
        MapNpc(mapNum).Npc(victim).Y = Dist
        Dist = NpcX
        MapNpc(mapNum).Npc(victim).X = Dist
        MapNpc(mapNum).Npc(victim).Dir = DIR_DOWN
        
    Case DIR_DOWN
        Dist = NpcY + 1
        If Dist > mapY Then Dist = mapY
        MapNpc(mapNum).Npc(victim).Y = Dist
        Dist = NpcX
        MapNpc(mapNum).Npc(victim).X = Dist
        MapNpc(mapNum).Npc(victim).Dir = DIR_UP
        
    Case DIR_RIGHT
        Dist = NpcX + 1
        If Dist > MapX Then Dist = MapX
        MapNpc(mapNum).Npc(victim).X = Dist
        Dist = NpcY
        MapNpc(mapNum).Npc(victim).Y = Dist
        MapNpc(mapNum).Npc(victim).Dir = DIR_LEFT
        
    Case DIR_LEFT
        Dist = NpcX - 1
        If Dist < 1 Then Dist = 0
        MapNpc(mapNum).Npc(victim).X = Dist
        Dist = NpcY
        MapNpc(mapNum).Npc(victim).Y = Dist
        MapNpc(mapNum).Npc(victim).Dir = DIR_RIGHT
End Select

SendMapNpcsToMap mapNum
        
End Sub


Public Sub NpcMagiaArea(ByVal mapNum As Long, ByVal mapNpcNum As Byte, ByVal SpellNum As Long)

If mapNum < 1 Or mapNum > MAX_MAPS Then Exit Sub
If mapNpcNum < 1 Or mapNpcNum > MAX_MAP_NPCS Then Exit Sub
If SpellNum < 1 Or SpellNum > MAX_SPELLS Then Exit Sub

Dim Dano, Anim, NpcNum As Long
Dim X, Y, i, I2, Dist As Long
Dim NpcY, NpcX As Byte

Dist = Spell(SpellNum).Dist
Anim = Spell(SpellNum).RetaAnim(1)
NpcX = MapNpc(mapNum).Npc(mapNpcNum).X
NpcY = MapNpc(mapNum).Npc(mapNpcNum).Y
NpcNum = MapNpc(mapNum).Npc(mapNpcNum).num

If MapNpc(mapNum).Npc(mapNpcNum).IsPet Then
    If MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner > 0 Then
        Select Case NpcNum
            Case 120 'Frog tai
                Dano = RAND(1, GetPlayerStat(MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner, Stats.strength) * 1.8 + Npc(Map(mapNum).Npc(mapNpcNum)).Damage / 2)
            Case 121 'slug gen
                Dano = RAND(1, GetPlayerStat(MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner, Stats.Willpower) * 1.8 + Npc(Map(mapNum).Npc(mapNpcNum)).Damage / 2)
            Case 122 'Snake Nin
                Dano = RAND(1, GetPlayerStat(MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner, Stats.Intelligence) * 1.8 + Npc(Map(mapNum).Npc(mapNpcNum)).Damage / 2)
            Case 124, 195 'Katsuyu,salamander.
                Dano = RAND(1, GetPlayerStat(MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner, Stats.Willpower) * 3.5 + Npc(Map(mapNum).Npc(mapNpcNum)).Damage / 2)
            Case 125, 191, 192, 196 'Manda,Shukaku,Sanbi
                Dano = RAND(1, GetPlayerStat(MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner, Stats.Intelligence) * 3.5 + Npc(Map(mapNum).Npc(mapNpcNum)).Damage / 2)
            Case 123, 190, 193, 194 'Gamabunta tai, kyuubi, yonbi, hachibi
                Dano = RAND(1, GetPlayerStat(MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner, Stats.strength) * 3.5 + Npc(Map(mapNum).Npc(mapNpcNum)).Damage / 2)
            Case Else
                
        End Select
        
        Dano = RAND(1, Dano)
    Else
        Dano = RAND(1, GetNpcDamage(NpcNum))
    End If
Else
    Dano = RAND(1, GetNpcDamage(NpcNum))
End If

If CanNpcCrit(NpcNum) Then
    Dano = Dano * 1.5
    SendActionMsg mapNum, "Critical!", BrightCyan, 1, (MapNpc(mapNum).Npc(mapNpcNum).X * 32), (MapNpc(mapNum).Npc(mapNpcNum).Y * 32)
End If

SendJutsuAnim mapNum, 2, 0, SpellNum, NpcX, NpcY

For Y = NpcY - Dist To NpcY + Dist
    For X = NpcX - Dist To NpcX + Dist
        If X >= 0 And X <= Map(mapNum).MaxX And Y >= 0 And Y <= Map(mapNum).MaxY Then
            CheckNPCAttackNpc mapNpcNum, mapNum, X, Y, Dano, SpellNum
        End If
    Next
Next

End Sub

Public Sub NpcMagiaReta(ByVal mapNum As Long, ByVal mapNpcNum As Byte, ByVal SpellNum As Long)
If mapNum < 1 Or mapNum > MAX_MAPS Then Exit Sub
If mapNpcNum < 1 Or mapNpcNum > MAX_MAP_NPCS Then Exit Sub
If SpellNum < 1 Or SpellNum > MAX_SPELLS Then Exit Sub

Dim Forca, Dano, Anim, NpcNum As Long
Dim X, Y, i, larg, Dist, largura As Byte

Dist = Spell(SpellNum).Dist
X = MapNpc(mapNum).Npc(mapNpcNum).X
Y = MapNpc(mapNum).Npc(mapNpcNum).Y
NpcNum = MapNpc(mapNum).Npc(mapNpcNum).num

If MapNpc(mapNum).Npc(mapNpcNum).IsPet Then
    If MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner > 0 Then
        Select Case NpcNum
            Case 120 'Frog tai
                Forca = GetPlayerStat(MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner, Stats.strength) * 1.8 + Npc(Map(mapNum).Npc(mapNpcNum)).Damage / 2
            Case 121 'slug gen
                Forca = GetPlayerStat(MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner, Stats.Willpower) * 1.8 + Npc(Map(mapNum).Npc(mapNpcNum)).Damage / 2
            Case 122 'Snake Nin
                Forca = GetPlayerStat(MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner, Stats.Intelligence) * 1.8 + Npc(Map(mapNum).Npc(mapNpcNum)).Damage / 2
            Case 124, 195 'Katsuyu,salamander
                Forca = GetPlayerStat(MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner, Stats.Willpower) * 3.5 + Npc(Map(mapNum).Npc(mapNpcNum)).Damage / 2
            Case 125, 191, 192, 196 'Manda,Shukaku,Sanbi, manda
                Forca = GetPlayerStat(MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner, Stats.Intelligence) * 3.5 + Npc(Map(mapNum).Npc(mapNpcNum)).Damage / 2
            Case 123, 190, 193, 194 'Gamabunta tai, kyuubi, yonbi, hachibi
                Forca = GetPlayerStat(MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner, Stats.strength) * 3.5 + Npc(Map(mapNum).Npc(mapNpcNum)).Damage / 2
            Case Else
        End Select
        
        Forca = RAND(1, Forca)
    Else
        Forca = RAND(1, GetNpcDamage(NpcNum))
    End If
Else
    Forca = RAND(1, GetNpcDamage(NpcNum))
End If

If CanNpcCrit(NpcNum) Then
    Forca = Forca * 1.5
    SendActionMsg mapNum, "Critical!", BrightCyan, 1, (MapNpc(mapNum).Npc(mapNpcNum).X * 32), (MapNpc(mapNum).Npc(mapNpcNum).Y * 32)
End If
largura = Spell(SpellNum).Multipla
Anim = Spell(SpellNum).RetaAnim(1)

SendJutsuAnim mapNum, 1, MapNpc(mapNum).Npc(mapNpcNum).Dir, SpellNum, X, Y

For i = 1 To Dist
Select Case MapNpc(mapNum).Npc(mapNpcNum).Dir
Case DIR_UP

Call CheckNPCAttackNpc(mapNpcNum, mapNum, X, Y - i, Forca, SpellNum)

If largura > 0 Then
  For larg = 1 To largura
    
    Select Case i
    Case 1
       
    Case 2
        Call CheckNPCAttackNpc(mapNpcNum, mapNum, X - 1, Y - i, Forca, SpellNum)
        Call CheckNPCAttackNpc(mapNpcNum, mapNum, X + 1, Y - i, Forca, SpellNum)
    Case Else
        Call CheckNPCAttackNpc(mapNpcNum, mapNum, X - larg, Y - i, Forca, SpellNum)
        Call CheckNPCAttackNpc(mapNpcNum, mapNum, X + larg, Y - i, Forca, SpellNum)
    End Select
    
  Next
End If

Case DIR_DOWN

Call CheckNPCAttackNpc(mapNpcNum, mapNum, X, Y + i, Forca, SpellNum)

If largura > 0 Then
  For larg = 1 To largura
  
    Select Case i
    Case 1
       
    Case 2
        Call CheckNPCAttackNpc(mapNpcNum, mapNum, X - 1, Y + i, Forca, SpellNum)
        Call CheckNPCAttackNpc(mapNpcNum, mapNum, X + 1, Y + i, Forca, SpellNum)
    Case Else
        Call CheckNPCAttackNpc(mapNpcNum, mapNum, X - larg, Y + i, Forca, SpellNum)
        Call CheckNPCAttackNpc(mapNpcNum, mapNum, X + larg, Y + i, Forca, SpellNum)
    End Select

  Next
End If

Case DIR_LEFT

Call CheckNPCAttackNpc(mapNpcNum, mapNum, X - i, Y, Forca, SpellNum)

If largura > 0 Then
  For larg = 1 To largura
  
    Select Case i
    Case 1
       
    Case 2
        Call CheckNPCAttackNpc(mapNpcNum, mapNum, X - i, Y - 1, Forca, SpellNum)
        Call CheckNPCAttackNpc(mapNpcNum, mapNum, X - i, Y + 1, Forca, SpellNum)
    Case Else
        Call CheckNPCAttackNpc(mapNpcNum, mapNum, X - i, Y + larg, Forca, SpellNum)
        Call CheckNPCAttackNpc(mapNpcNum, mapNum, X - i, Y - larg, Forca, SpellNum)
    End Select
  
  Next
End If

Case DIR_RIGHT

Call CheckNPCAttackNpc(mapNpcNum, mapNum, X + i, Y, Forca, SpellNum)

If largura > 0 Then
  For larg = 1 To largura
  
    Select Case i
        Case 1
       
        Case 2
            Call CheckNPCAttackNpc(mapNpcNum, mapNum, X + i, Y - 1, Forca, SpellNum)
            Call CheckNPCAttackNpc(mapNpcNum, mapNum, X + i, Y + 1, Forca, SpellNum)
        Case Else
            Call CheckNPCAttackNpc(mapNpcNum, mapNum, X + i, Y + larg, Forca, SpellNum)
            Call CheckNPCAttackNpc(mapNpcNum, mapNum, X + i, Y - larg, Forca, SpellNum)
        End Select
    
  Next
End If

End Select
Next

End Sub

Public Sub NpcNormalMagic(ByVal mapNum As Long, ByVal mapNpcNum As Byte, ByVal SpellNum As Long)

Dim Alvo As Long
Dim Forca As Long
Dim NpcNum As Long

If mapNpcNum < 1 Or mapNpcNum > MAX_MAP_NPCS Then Exit Sub
If mapNum < 1 Or mapNum > MAX_MAPS Then Exit Sub
If SpellNum < 1 Or SpellNum > MAX_SPELLS Then Exit Sub

Alvo = MapNpc(mapNum).Npc(mapNpcNum).Target

If Alvo < 1 Then Exit Sub

NpcNum = MapNpc(mapNum).Npc(mapNpcNum).num

If NpcNum < 1 Or NpcNum > MAX_NPCS Then Exit Sub

If MapNpc(mapNum).Npc(mapNpcNum).IsPet Then
    If MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner > 0 Then
        Select Case NpcNum
            Case 120 'Frog tai
                Forca = GetPlayerStat(MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner, Stats.strength) * 1.8 + Npc(Map(mapNum).Npc(mapNpcNum)).Damage / 2
            Case 121 'slug gen
                Forca = GetPlayerStat(MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner, Stats.Willpower) * 1.8 + Npc(Map(mapNum).Npc(mapNpcNum)).Damage / 2
            Case 122 'Snake Nin
                Forca = GetPlayerStat(MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner, Stats.Intelligence) * 1.8 + Npc(Map(mapNum).Npc(mapNpcNum)).Damage / 2
            Case 124, 195 'Katsuyu,Salamander
                Forca = GetPlayerStat(MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner, Stats.Willpower) * 3.5 + Npc(Map(mapNum).Npc(mapNpcNum)).Damage / 2
            Case 125, 191, 192, 196 'Manda,Shukaku,Sanbi,manda
                Forca = GetPlayerStat(MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner, Stats.Intelligence) * 3.5 + Npc(Map(mapNum).Npc(mapNpcNum)).Damage / 2
            Case 123, 190, 193, 194 'Gamabunta tai, kyuubi, yonbi, hachibi
                Forca = GetPlayerStat(MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner, Stats.strength) * 3.5 + Npc(Map(mapNum).Npc(mapNpcNum)).Damage / 2
            Case Else
        End Select
        
        Forca = RAND(1, Forca)
    Else
        Forca = RAND(1, GetNpcDamage(NpcNum))
    End If
Else
    Forca = RAND(1, GetNpcDamage(NpcNum))
End If

If CanNpcCrit(NpcNum) Then
    Forca = Forca * 1.5
    SendActionMsg mapNum, "Critical!", BrightCyan, 1, (MapNpc(mapNum).Npc(mapNpcNum).X * 32), (MapNpc(mapNum).Npc(mapNpcNum).Y * 32)
End If

Select Case MapNpc(mapNum).Npc(mapNpcNum).targetType
    Case TARGET_TYPE_PLAYER
        If isInRange(Spell(SpellNum).Range, MapNpc(mapNum).Npc(mapNpcNum).X, MapNpc(mapNum).Npc(mapNpcNum).Y, GetPlayerX(Alvo), GetPlayerY(Alvo)) Then
            If Not MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner = Alvo Then
                NpcAttackPlayer mapNpcNum, Alvo, Forca
                SendAnimation mapNum, Spell(SpellNum).SpellAnim, 0, 0, TARGET_TYPE_PLAYER, Alvo
            End If
        End If
    Case TARGET_TYPE_NPC
        If isInRange(Spell(SpellNum).Range, MapNpc(mapNum).Npc(mapNpcNum).X, MapNpc(mapNum).Npc(mapNpcNum).Y, MapNpc(mapNum).Npc(Alvo).X, MapNpc(mapNum).Npc(Alvo).Y) Then
            If CanNpcAttackNpc(mapNum, mapNpcNum, Alvo, YES) Then
                NpcAttackNpc mapNum, mapNpcNum, Alvo, Forca
                SendAnimation mapNum, Spell(SpellNum).SpellAnim, 0, 0, TARGET_TYPE_NPC, Alvo
            End If
        End If
    Case Else
End Select

End Sub

Public Function EspecialJutsu(ByVal index As Long) As Long
If index < 1 Or index > MAX_PLAYERS Then Exit Function
Dim i As Byte

For i = 131 To 141
    If HasSpell(index, i) Then
        EspecialJutsu = i
        Exit Function
    End If
Next

End Function

Public Sub TirarJutsuEspecial(ByVal index As Long)
If IsPlaying(index) = False Then Exit Sub

Dim i As Byte
Dim n As Byte
Dim OK As Byte

If Player(index).Org = ORG_FREE Then
    If HasSpell(index, 130) = False Then
        SetPlayerSpell index, FindOpenSpellSlot(index), 130
        SendPlayerSpells index
    End If
End If

For n = 1 To MAX_PLAYER_SPELLS
    If Player(index).Spell(n) = 130 Then
        If Not Player(index).Org = ORG_FREE Then
            Player(index).Spell(n) = NO
            SendPlayerSpells index
            PlayerMsg index, "Um jutsu seu foi tirado por não ter o requerimento", Red
        End If
    End If
    
    For i = 131 To 132
        If Player(index).Spell(n) = i Then
            If Not Player(index).Org = ORG_HOSPITAL Then
                Player(index).Spell(n) = NO
                SendPlayerSpells index
                PlayerMsg index, "Um jutsu seu foi tirado por não ter o requerimento", Red
            End If
        End If
    Next
    
    If Player(index).Spell(n) = 134 Then
        Select Case Player(index).Org
            Case ORG_POLICIAKONOHA, ORG_ESQUADRAO, ORG_RENEGADOS
            Case Else
                Player(index).Spell(n) = NO
                SendPlayerSpells index
                PlayerMsg index, "Um jutsu seu foi tirado por não ter o requerimento", Red
        End Select
    End If
    
    For i = 136 To 141
        If Player(index).Spell(n) = i Then
            Select Case Player(index).Org
                Case ORG_TAKA, ORG_7ESPADACHINS, ORG_AKATSUKI, ORG_ANBURAIZ, ORG_12GUARDIOES
                Case Else
                    Player(index).Spell(n) = NO
                    SendPlayerSpells index
                    PlayerMsg index, "Um jutsu seu foi tirado por não ter o requerimento", Red
            End Select
        End If
    Next
    
    For i = 142 To 143
        If Player(index).Spell(n) = i Then
            If Not Player(index).Rank = RANK_KAGE Then
                Player(index).Spell(n) = NO
                SendPlayerSpells index
                PlayerMsg index, "Um jutsu seu foi tirado por não ter o requerimento", Red
            End If
        End If
    Next
    
    If Player(index).Spell(n) = 242 Then 'summon bijuu
        If Not Player(index).Rank = RANK_KAGE And Not GetPlayerClass(index) = TOBI Then
            Player(index).Spell(n) = NO
            SendPlayerSpells index
            PlayerMsg index, "Um jutsu seu foi tirado por não ter o requerimento", Red
        End If
    End If
Next


End Sub

Public Sub OrgJutsu(ByVal index As Long, ByVal Organization As Byte)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
Dim i As Byte
Dim n As Byte
Dim SpellOk As Byte

TirarJutsuEspecial index

If EspecialJutsu(index) > 0 Then Exit Sub

Select Case Organization
    Case ORG_TAKA, ORG_7ESPADACHINS, ORG_AKATSUKI, ORG_ANBURAIZ, ORG_12GUARDIOES
    
            If GetClassStat(GetPlayerClass(index)) = Stats.strength Then
                Select Case RAND(1, 3)
                    Case 1
                        SetPlayerSpell index, FindOpenSpellSlot(index), 137
                        PlayerMsg index, "Você aprendeu " & Spell(137).Name, BrightBlue
                    Case 2
                        SetPlayerSpell index, FindOpenSpellSlot(index), 140
                        PlayerMsg index, "Você aprendeu " & Spell(140).Name, BrightBlue
                    Case 3
                        SetPlayerSpell index, FindOpenSpellSlot(index), 141
                        PlayerMsg index, "Você aprendeu " & Spell(141).Name, BrightBlue
                End Select
            End If
            
            If GetClassStat(GetPlayerClass(index)) = Stats.Intelligence Then
                Select Case RAND(1, 3)
                    Case 1
                        SetPlayerSpell index, FindOpenSpellSlot(index), 136
                        PlayerMsg index, "Você aprendeu " & Spell(136).Name, BrightBlue
                    Case 2
                        SetPlayerSpell index, FindOpenSpellSlot(index), 138
                        PlayerMsg index, "Você aprendeu " & Spell(138).Name, BrightBlue
                    Case 3
                        SetPlayerSpell index, FindOpenSpellSlot(index), 139
                        PlayerMsg index, "Você aprendeu " & Spell(139).Name, BrightBlue
                End Select
            
            End If

    Case ORG_HOSPITAL
        
            SetPlayerSpell index, FindOpenSpellSlot(index), 131
            SetPlayerSpell index, FindOpenSpellSlot(index), 132
            PlayerMsg index, "Você aprendeu " & Spell(131).Name, BrightBlue
            PlayerMsg index, "Você aprendeu " & Spell(132).Name, BrightBlue
        
    Case ORG_POLICIAKONOHA, ORG_ESQUADRAO, ORG_RENEGADOS
        
            SetPlayerSpell index, FindOpenSpellSlot(index), 134
            PlayerMsg index, "Você aprendeu " & Spell(134).Name, BrightBlue
       
    Case Else
End Select
    
End Sub

Public Sub Noticias(ByVal index As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub

Dim i As Byte
Dim Folder As String

Folder = App.Path & "\Noticias.TXT"

    i = RAND(1, Noticias_MAX)
    PlayerMsg index, GetVar(Folder, "Noticias", Trim(i)), BrightGreen



End Sub

Public Function IsBlocked(ByVal index As Long, ByVal X As Long, ByVal Y As Long, ByVal Dir As Byte) As Byte
If IsPlaying(index) = False Then Exit Function
Dim mapNum As Long

mapNum = GetPlayerMap(index)
If mapNum < 1 Or mapNum > MAX_MAPS Then Exit Function

If X < 0 Or X > Map(mapNum).MaxX Then
    IsBlocked = YES
    Exit Function
End If

If Y < 0 Or Y > Map(mapNum).MaxY Then
    IsBlocked = YES
    Exit Function
End If

        If Map(mapNum).Tile(X, Y).Type = TILE_TYPE_BLOCKED Then
            IsBlocked = YES
            Exit Function
        End If

End Function

Public Sub setKarma(ByVal index As Integer, ByVal Vitima As Integer)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If Vitima < 1 Or Vitima > MAX_PLAYERS Then Exit Sub
If GetPlayerAccess(index) > 1 Then Exit Sub

If Player(index).PKstate = 3 Then
    PlayerMsg index, "Como você estava com o PK3 ativo, o Karma não foi alterado.", White
    PlayerMsg Vitima, GetPlayerName(index) & " estava com o PK3 ativo, o Karma não foi alterado.", White
    Exit Sub
End If

Dim MyRank As Byte
Dim PtsGanho As Byte

Select Case Player(Vitima).Karma
    Case -MAX_LONG To -4999
        PtsGanho = 50
    Case -5000 To -2999
        PtsGanho = 30
    Case -3000 To -999
        PtsGanho = 20
    Case -1000 To -499
        PtsGanho = 15
    Case -500 To -299
        PtsGanho = 10
    Case -300 To -99
        PtsGanho = 5
    Case -100 To -1
        PtsGanho = 1
    Case 0 To 100
        PtsGanho = 1
    Case 101 To 300
        PtsGanho = 5
    Case 301 To 500
        PtsGanho = 10
    Case 501 To 1000
        PtsGanho = 15
    Case 1001 To 3000
        PtsGanho = 20
    Case 3001 To 5000
        PtsGanho = 30
    Case 5001 To MAX_LONG
        PtsGanho = 50
    Case Else
End Select

'Aqui aumenta os pts do cara que matou
If Player(Vitima).Karma >= 0 Then
    Player(index).Karma = Player(index).Karma - PtsGanho
Else
    Player(index).Karma = Player(index).Karma + PtsGanho
End If

'Aqui tira os ptos to derrotado
If Player(Vitima).Karma > 0 Then
    If Player(Vitima).Karma - PtsGanho <= 0 Then
        Player(Vitima).Karma = 0
    Else
        Player(Vitima).Karma = Player(Vitima).Karma - PtsGanho
    End If
Else
    If Player(Vitima).Karma + PtsGanho >= 0 Then
        Player(Vitima).Karma = 0
    Else
        Player(Vitima).Karma = Player(Vitima).Karma + PtsGanho
    End If
End If

PlayerMsg index, "Meu Karma:" & Player(index).Karma, BrightGreen
PlayerMsg index, "Karma Inimigo:" & Player(Vitima).Karma, Green
SendPlayerData index
SendPlayerData Vitima

AtualizarKarma index

End Sub

Public Sub AtualizarKarma(ByVal index As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If GetPlayerAccess(index) > 1 Then Exit Sub
Dim MyRank As Byte 'Posição do Top
Dim Update As Byte
Dim i As Long

For i = 1 To 10
    If TopHero(i).Nome = GetPlayerName(index) Then
        MyRank = i
        Exit For
    End If
    
    If TopPK(i).Nome = GetPlayerName(index) Then
        MyRank = i
        Exit For
    End If
Next

If Player(index).Karma >= 0 Then 'TopHero
    'If Not TopHero(1).Nome = GetPlayerName(index) Then
        If MyRank > 1 And MyRank < 11 Then
            If Player(index).Karma > TopHero(MyRank - 1).Pts Then
                TopHero(MyRank).Nome = TopHero(MyRank - 1).Nome
                TopHero(MyRank).Pts = TopHero(MyRank - 1).Pts
                TopHero(MyRank - 1).Nome = GetPlayerName(index)
                TopHero(MyRank - 1).Pts = Player(index).Karma
                Update = YES
                GlobalMsg GetPlayerName(index) & " subiu para a " & MyRank - 1 & "° colocação como Herói com seus;" & Player(index).Karma & " Karma!", BrightCyan
                GlobalMsg TopHero(MyRank).Nome & " desceu para o " & MyRank & "° lugar no Top Hero!", BrightCyan
            Else
                TopHero(MyRank).Pts = Player(index).Karma
                Update = YES
            End If
        Else
            If MyRank = 1 Then '1° lugar,atualizar os pontos
                TopHero(1).Pts = Player(index).Karma
                Update = YES
            End If
        
            If MyRank = 0 Then 'Não ta nos tops
                If Player(index).Karma > TopHero(10).Pts Then
                    GlobalMsg TopHero(10).Nome & " saiu do Top Hero!", BrightCyan
                    TopHero(10).Nome = GetPlayerName(index)
                    TopHero(10).Pts = Player(index).Karma
                    Update = YES
                    GlobalMsg GetPlayerName(index) & " subiu para a 10° colocação como Herói com seus;" & Player(index).Karma & " Karma!", BrightCyan
                End If
            End If
        End If
    'End If
Else 'Top PK
    'If Not TopPK(1).Nome = GetPlayerName(index) Then
        If MyRank > 1 And MyRank < 11 Then
            If Player(index).Karma < TopPK(MyRank - 1).Pts Then
                TopPK(MyRank).Nome = TopPK(MyRank - 1).Nome
                TopPK(MyRank).Pts = TopPK(MyRank - 1).Pts
                TopPK(MyRank - 1).Nome = GetPlayerName(index)
                TopPK(MyRank - 1).Pts = Player(index).Karma
                Update = YES
                GlobalMsg GetPlayerName(index) & " subiu para a " & MyRank - 1 & "° colocação como Assassino com seus;" & Player(index).Karma & " Karma!", Cyan
                GlobalMsg TopPK(MyRank).Nome & " desceu para a " & MyRank & "° colocação no Top PK!", Cyan
            Else
                TopPK(MyRank).Pts = Player(index).Karma
                Update = YES
            End If
        Else
            If MyRank = 1 Then '1° lugar,atualizar os pontos
                TopPK(1).Pts = Player(index).Karma
                Update = YES
            End If
        
            If MyRank = 0 Then 'Não ta nos tops
                If Player(index).Karma < TopPK(10).Pts Then
                    GlobalMsg TopPK(10).Nome & " saiu do Top PK!", Cyan
                    TopPK(10).Nome = GetPlayerName(index)
                    TopPK(10).Pts = Player(index).Karma
                    Update = YES
                    GlobalMsg GetPlayerName(index) & " subiu para a 10° colocação como Assassino com seus;" & Player(index).Karma & " Karma!", Cyan
                End If
            End If
        End If
    'End If
End If
    
End Sub

Public Sub AtualizarPVP(ByVal index As Long, ByVal Ganhou As Byte)
'On Error Resume Next
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If Ganhou > 1 Then Exit Sub
If Ganhou < 0 Then Exit Sub
'desafioanything
If GetPlayerAccess(index) > 1 Then Exit Sub

Dim i As Long
Dim meuRank As Byte
Dim oldRank As Byte
Dim lastName1 As String
Dim lastV1 As Long
Dim lastD1 As Long
Dim lastName2 As String
Dim lastV2 As Long
Dim lastD2 As Long

If Ganhou = YES Then
    Player(index).PvP.V = Player(index).PvP.V + 1
Else
    Player(index).PvP.D = Player(index).PvP.D + 1
End If

For i = 1 To 10
    If GetPlayerName(index) = Trim$(TopPvP(i).Nome) Then
        oldRank = i
        Exit For
    End If
Next

If oldRank > 0 Then
    TopPvP(oldRank).V = Player(index).PvP.V
    TopPvP(oldRank).D = Player(index).PvP.D
End If

If oldRank = 1 Then Exit Sub

For i = 10 To 1 Step -1
    If Not GetPlayerName(index) = Trim$(TopPvP(i).Nome) Then
        If Player(index).PvP.V > TopPvP(i).V Then
            meuRank = i
        End If
    End If
Next

If meuRank < 1 Or meuRank > 10 Then Exit Sub
    
    If oldRank < 1 Then
        TopPvP(10).Nome = GetPlayerName(index)
        TopPvP(10).V = Player(index).PvP.V
        TopPvP(10).D = Player(index).PvP.D
    End If
    
    For i = 10 To 2 Step -1
        If TopPvP(i).V > TopPvP(i - 1).V Then
            If Trim$(TopPvP(i).Nome) <> Trim$(TopPvP(i - 1).Nome) Then
                lastName1 = Trim$(TopPvP(i - 1).Nome)
                lastV1 = TopPvP(i - 1).V
                lastD1 = TopPvP(i - 1).D
                lastName2 = Trim$(TopPvP(i).Nome)
                lastV2 = TopPvP(i).V
                lastD2 = TopPvP(i).D
                'mudando
                TopPvP(i).Nome = Trim$(lastName1)
                TopPvP(i).V = lastV1
                TopPvP(i).D = lastD1
                TopPvP(i - 1).Nome = Trim$(lastName2)
                TopPvP(i - 1).V = lastV2
                TopPvP(i - 1).D = lastD2
            End If
        End If
    Next

If meuRank = 1 Then
    GlobalMsg GetPlayerName(index) & " subiu para o 1° lugar no Top PVP(Desafios).", Cyan
Else
    If meuRank < oldRank Then
        PlayerMsg index, "Você subiu para o " & meuRank & "° lugar no Top PVP! Parabéns!!", White
    End If
End If

End Sub

Public Sub CarregarPVP()
'On Error Resume Next
Dim i As Byte

For i = 1 To 10
    TopPvP(i).Nome = GetVar(App.Path & "\Tops\PvP.txt", "PVP" & i, "Nome")
    TopPvP(i).V = GetVar(App.Path & "\Tops\PvP.txt", "PVP" & i, "V")
    TopPvP(i).D = GetVar(App.Path & "\Tops\PvP.txt", "PVP" & i, "D")
Next

End Sub

Public Sub SalvarPVP()
'On Error Resume Next
Dim i As Byte

For i = 1 To 10
    PutVar App.Path & "\Tops\PVP.txt", "PVP" & i, "Nome", TopPvP(i).Nome
    PutVar App.Path & "\Tops\PVP.txt", "PVP" & i, "V", TopPvP(i).V
    PutVar App.Path & "\Tops\PVP.txt", "PVP" & i, "D", TopPvP(i).D
Next

End Sub



Public Sub CarregarTopChar()
'On Error Resume Next
Dim i As Byte

For i = 1 To MAX_CLASS_TEMP
    TopChar(i).Nome = GetVar(App.Path & "\Tops\Char.txt", "CHAR" & i, "Nome")
    TopChar(i).Level = GetVar(App.Path & "\Tops\Char.txt", "CHAR" & i, "Level")
Next

End Sub

Public Sub SalvarTopChar()
'On Error Resume Next
Dim i As Byte

For i = 1 To MAX_CLASS_TEMP
    PutVar App.Path & "\Tops\Char.txt", "CHAR" & i, "Nome", TopChar(i).Nome
    PutVar App.Path & "\Tops\Char.txt", "CHAR" & i, "Level", TopChar(i).Level
Next

End Sub

Public Sub AtualizarTops()

SalvarTop

SalvarTopChar

SalvarKarma
        
SalvarPVP
        
End Sub

Public Sub AtualizarDesafio(ByVal arenaNum As Long, ByVal pINDEX As Long, Optional ByVal saiu As Byte = 0)
Dim i As Long
'desafioanything
If arenaNum < 1 Or arenaNum > 9 Then Exit Sub
If pINDEX < 1 Or pINDEX > MAX_PLAYERS Then Exit Sub


TempPlayer(pINDEX).AceitouDesafio = NO

For i = 1 To 2
    If Arena(arenaNum).p(i) > 0 Then
        If Arena(arenaNum).p(i) = pINDEX Then
            Arena(arenaNum).pResta = Arena(arenaNum).pResta - 1
        Else
            If saiu = YES Then
                PlayerMsg Arena(arenaNum).p(i), Trim$(Player(pINDEX).Name) & " deslogou do game..", DarkGrey
            End If
        End If
    End If
    
    If Arena(arenaNum).p2(i) > 0 Then
        If Arena(arenaNum).p2(i) = pINDEX Then
            Arena(arenaNum).p2Resta = Arena(arenaNum).p2Resta - 1
        Else
            If saiu = YES Then
                PlayerMsg Arena(arenaNum).p2(i), Trim$(Player(pINDEX).Name) & " deslogou do game..", DarkGrey
            End If
        End If
    End If
Next

If saiu = YES Then
    SetPlayerMap pINDEX, 99
    SetPlayerX pINDEX, 10
    SetPlayerY pINDEX, 6
    If Arena(arenaNum).WaitTmr > 0 Then
        ZerarArena arenaNum
        Exit Sub
    End If
Else
    PlayerWarp pINDEX, 99, 10, 6 'Atendimento
End If

If Arena(arenaNum).pResta < 1 Then
    For i = 1 To 2
        If Arena(arenaNum).p2(i) > 0 Then
            PlayerMsg Arena(arenaNum).p2(i), "Você ganhou!!", White
            If GetPlayerMap(Arena(arenaNum).p2(i)) = Arena(arenaNum).Map Then
                PlayerWarp Arena(arenaNum).p2(i), 99, 10, 6 'Atendimento
            End If
            
            If Arena(arenaNum).tipo = 0 And saiu = NO Then '1x1
                AtualizarPVP Arena(arenaNum).p2(1), YES
                AtualizarPVP pINDEX, NO
            End If
        End If
        
        If Arena(arenaNum).p(i) > 0 Then
            PlayerMsg Arena(arenaNum).p(i), "Você perdeu..", Grey
            If GetPlayerMap(Arena(arenaNum).p(i)) = Arena(arenaNum).Map Then
                PlayerWarp Arena(arenaNum).p(i), 99, 10, 6 'Atendimento
            End If
        End If
    Next
    
    ZerarArena arenaNum
    Exit Sub
End If
    
If Arena(arenaNum).p2Resta < 1 Then
    For i = 1 To 2
        If Arena(arenaNum).p(i) > 0 Then
            PlayerMsg Arena(arenaNum).p(i), "Você ganhou!!", White
            If GetPlayerMap(Arena(arenaNum).p(i)) = Arena(arenaNum).Map Then
                PlayerWarp Arena(arenaNum).p(i), 99, 10, 6 'Atendimento
            End If
            
            If Arena(arenaNum).tipo = 0 And saiu = NO Then '1x1
                AtualizarPVP Arena(arenaNum).p(1), YES
                AtualizarPVP pINDEX, NO
            End If
        End If
        
        If Arena(arenaNum).p2(i) > 0 Then
            PlayerMsg Arena(arenaNum).p2(i), "Você perdeu..", Grey
            If GetPlayerMap(Arena(arenaNum).p2(i)) = Arena(arenaNum).Map Then
                PlayerWarp Arena(arenaNum).p2(i), 99, 10, 6 'Atendimento
            End If
        End If
    Next
    
    ZerarArena arenaNum
    Exit Sub
End If

End Sub

Public Sub ZerarArena(ByVal arenaNum As Long)
Dim i As Long
If arenaNum < 1 Or arenaNum > 9 Then Exit Sub
            
Arena(arenaNum).IsActive = NO
Arena(arenaNum).p2Resta = NO
Arena(arenaNum).pResta = NO
Arena(arenaNum).p(1) = NO
Arena(arenaNum).p(2) = NO
Arena(arenaNum).p2(1) = NO
Arena(arenaNum).p2(2) = NO
Arena(arenaNum).tipo = NO

For i = 1 To Player_HighIndex
    If TempPlayer(i).InArena = arenaNum Then
        If IsPlaying(i) Then
            TempPlayer(i).InArena = NO
            TempPlayer(i).AceitouDesafio = NO
            If Arena(arenaNum).WaitTmr > 0 Then
                PlayerMsg i, "O tempo para aceitarem o desafio atingiu o limite ou algum desafiado deslogou.", White
            End If
            SendExtras i, 1
        End If
    End If
Next

Arena(arenaNum).WaitTmr = NO
        
End Sub

Public Sub HandleProjecTile(ByVal index As Long, ByVal PlayerProjectile As Long)
Dim X As Long, Y As Long, i As Long
Dim Anim, Especial, PassOver As Byte
Dim IsSpell As Long

    ' check for subscript out of range
    If index < 1 Or index > MAX_PLAYERS Or PlayerProjectile < 1 Or PlayerProjectile > MAX_PLAYER_PROJECTILES Then Exit Sub
        
    ' check to see if it's time to move the Projectile
    If GetTickCount > TempPlayer(index).ProjecTile(PlayerProjectile).TravelTime Then
        With TempPlayer(index).ProjecTile(PlayerProjectile)
            ' set next travel time and the current position and then set the actual direction based on RMXP arrow tiles.
            Select Case .Direction
                ' down
                Case DIR_DOWN
                    .Y = .Y + 1
                    ' check if they reached maxrange
                    If .Y = (GetPlayerY(index) + .Range) + 1 Then ClearProjectile index, PlayerProjectile: Exit Sub
                ' up
                Case DIR_UP
                    .Y = .Y - 1
                    ' check if they reached maxrange
                    If .Y = (GetPlayerY(index) - .Range) - 1 Then ClearProjectile index, PlayerProjectile: Exit Sub
                ' right
                Case DIR_RIGHT
                    .X = .X + 1
                    ' check if they reached max range
                    If .X = (GetPlayerX(index) + .Range) + 1 Then ClearProjectile index, PlayerProjectile: Exit Sub
                ' left
                Case DIR_LEFT
                    .X = .X - 1
                    ' check if they reached maxrange
                    If .X = (GetPlayerX(index) - .Range) - 1 Then ClearProjectile index, PlayerProjectile: Exit Sub
            End Select
            .TravelTime = GetTickCount + .Speed
        End With
    End If
    
    X = TempPlayer(index).ProjecTile(PlayerProjectile).X
    Y = TempPlayer(index).ProjecTile(PlayerProjectile).Y
    Anim = TempPlayer(index).ProjecTile(PlayerProjectile).Anim
    IsSpell = TempPlayer(index).ProjecTile(PlayerProjectile).IsSpell
    Especial = TempPlayer(index).ProjecTile(PlayerProjectile).Especial
    PassOver = TempPlayer(index).ProjecTile(PlayerProjectile).PassOver
    
    ' check if left map
    If X > Map(GetPlayerMap(index)).MaxX Or Y > Map(GetPlayerMap(index)).MaxY Or X < 0 Or Y < 0 Then
        ClearProjectile index, PlayerProjectile
        Exit Sub
    End If
    
    ' check if hit player
    For i = 1 To Player_HighIndex
        ' make sure they're actually playing
        If IsPlaying(i) Then
            ' check coordinates
            If X = Player(i).X And Y = GetPlayerY(i) Then
                ' make sure it's not the attacker
                If Not X = Player(index).X Or Not Y = GetPlayerY(index) Then
                    ' check if player can attack
                    If CanPlayerAttackPlayer(index, i, False, True) = True Then
                        ' attack the player and kill the project tile
                        PlayerAttackPlayer index, i, TempPlayer(index).ProjecTile(PlayerProjectile).Damage / 2.5
                        'If PassOver = NO Then
                            ClearProjectile index, PlayerProjectile
                        'End If
                        CheckHits index, i
                        
                        'Se tem o sharingan copy,o inimigo manda o mesmo jutsu
                        If IsSpell > 0 Then
                            If TempPlayer(i).SharinganCopy > 0 Then
                                TempPlayer(i).tmpSpell = IsSpell
                                CastSpell i, 1, index, TARGET_TYPE_PLAYER, YES
                            End If
                        End If
                        
                        If Especial = YES Then
                            Select Case GetPlayerClass(index)
                                Case ITACHI, MADARA
                                    SendAnimation GetPlayerMap(index), 81, 0, 0, TARGET_TYPE_PLAYER, index
                                Case Else 'yondaime e etc..
                                    SendAnimation GetPlayerMap(index), 70, 0, 0, TARGET_TYPE_PLAYER, index
                            End Select
                        
                            WarpBehind_Player index, i
                        End If
                        
                        If IsSpell > 0 Then
                            If Spell(IsSpell).StunDuration > 0 Then StunPlayer i, IsSpell, index
                            If Spell(IsSpell).Duration > 0 Then AddDoT_Player i, IsSpell, index
                            If Spell(IsSpell).SpellAnim > 0 Then SendAnimation GetPlayerMap(index), Spell(IsSpell).SpellAnim, 0, 0, TARGET_TYPE_PLAYER, i
                        End If
                        If Anim > 0 Then
                            SendAnimation GetPlayerMap(i), Anim, 0, 0, TARGET_TYPE_PLAYER, i
                        End If
                        
                        Exit Sub
                    Else
                        ClearProjectile index, PlayerProjectile
                        Exit Sub
                    End If
                End If
            End If
        End If
    Next
    
    ' check for npc hit
    For i = 1 To MAX_MAP_NPCS
        If X = MapNpc(GetPlayerMap(index)).Npc(i).X And Y = MapNpc(GetPlayerMap(index)).Npc(i).Y Then
            ' they're hit, remove it and deal that damage ;)
            If CanPlayerAttackNpc(index, i, True) Then
                PlayerAttackNpc index, i, TempPlayer(index).ProjecTile(PlayerProjectile).Damage
                CheckHits index, i
                'If PassOver = NO Then
                    ClearProjectile index, PlayerProjectile
                'End If
                
                If Especial = YES Then
                    Select Case GetPlayerClass(index)
                        Case ITACHI, MADARA
                            SendAnimation GetPlayerMap(index), 81, 0, 0, TARGET_TYPE_PLAYER, index
                        Case Else 'yondaime e etc..
                            SendAnimation GetPlayerMap(index), 70, 0, 0, TARGET_TYPE_PLAYER, index
                    End Select
                            
                    WarpBehind_Npc index, i
                End If
                        
                If IsSpell > 0 Then
                    If Spell(IsSpell).StunDuration > 0 Then StunNPC i, GetPlayerMap(index), IsSpell, index
                    If Spell(IsSpell).Duration > 0 Then AddDoT_Npc GetPlayerMap(index), i, IsSpell, index
                    If Spell(IsSpell).SpellAnim > 0 Then SendAnimation GetPlayerMap(index), Spell(IsSpell).SpellAnim, 0, 0, TARGET_TYPE_NPC, i
                End If
                If Anim > 0 Then
                    SendAnimation GetPlayerMap(index), Anim, 0, 0, TARGET_TYPE_NPC, i
                End If
                
                Exit Sub
            Else
                ClearProjectile index, PlayerProjectile
                Exit Sub
            End If
        End If
    Next
    
    ' hit a block
    If Map(GetPlayerMap(index)).Tile(X, Y).Type = TILE_TYPE_BLOCKED Then
        ' hit a block, clear it.
        ClearProjectile index, PlayerProjectile
        Exit Sub
    End If
    
End Sub

Public Sub SendArrow(ByVal index As Long, ByVal Pic As Integer, ByVal X As Byte, ByVal Y As Byte, ByVal Range As Byte, ByVal Dano As Long, ByVal Speed As Long, Optional ByVal Anim As Long, Optional ByVal IsSpell As Long, Optional ByVal Especial As Byte, Optional ByVal PassOver As Byte)
If IsPlaying(index) = False Then Exit Sub
Dim i As Byte, curProjecTile As Byte

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
    If curProjecTile < 1 Or curProjecTile > MAX_PLAYER_PROJECTILES Then Exit Sub
    
    ' populate the data in the player rec
    With TempPlayer(index).ProjecTile(curProjecTile)
        .Damage = Dano
        .Direction = GetPlayerDir(index)
        .Pic = Pic
        .Range = Range
        .Speed = Speed
        .X = X
        .Y = Y
        .Anim = Anim
        .IsSpell = IsSpell
        .Especial = Especial
        .PassOver = PassOver
    End With
    
    ' update the projectile on the map
    SendProjectileToMap index, curProjecTile
End Sub


Public Sub CarregarCharJutsus()

CharJutsus(NARUTO).JutsuNum(1) = 28
CharJutsus(NARUTO).JutsuNum(2) = 29
CharJutsus(NARUTO).JutsuNum(3) = 30
CharJutsus(NARUTO).JutsuNum(4) = 31
CharJutsus(NARUTO).JutsuNum(5) = 32
CharJutsus(NARUTO).JutsuNum(6) = 33
CharJutsus(NARUTO).JutsuNum(7) = 34
CharJutsus(NARUTO).JutsuNum(8) = 35
CharJutsus(NARUTO).JutsuNum(9) = 36

CharJutsus(SASUKE).JutsuNum(1) = 39
CharJutsus(SASUKE).JutsuNum(2) = 40
CharJutsus(SASUKE).JutsuNum(3) = 42
CharJutsus(SASUKE).JutsuNum(4) = 43
CharJutsus(SASUKE).JutsuNum(5) = 44
CharJutsus(SASUKE).JutsuNum(6) = 45
CharJutsus(SASUKE).JutsuNum(7) = 46
CharJutsus(SASUKE).JutsuNum(8) = 49
CharJutsus(SASUKE).JutsuNum(9) = 50

CharJutsus(SAKURA).JutsuNum(1) = 52
CharJutsus(SAKURA).JutsuNum(2) = 53
CharJutsus(SAKURA).JutsuNum(3) = 54
CharJutsus(SAKURA).JutsuNum(4) = 55
CharJutsus(SAKURA).JutsuNum(5) = 56

CharJutsus(INO).JutsuNum(1) = 58
CharJutsus(INO).JutsuNum(2) = 59
CharJutsus(INO).JutsuNum(3) = 60
CharJutsus(INO).JutsuNum(4) = 61

CharJutsus(SHIKAMARU).JutsuNum(1) = 63
CharJutsus(SHIKAMARU).JutsuNum(2) = 64
CharJutsus(SHIKAMARU).JutsuNum(3) = 65
CharJutsus(SHIKAMARU).JutsuNum(4) = 66
CharJutsus(SHIKAMARU).JutsuNum(5) = 67

CharJutsus(CHOUJI).JutsuNum(1) = 69
CharJutsus(CHOUJI).JutsuNum(2) = 70
CharJutsus(CHOUJI).JutsuNum(3) = 71
CharJutsus(CHOUJI).JutsuNum(4) = 72
CharJutsus(CHOUJI).JutsuNum(5) = 73
CharJutsus(CHOUJI).JutsuNum(6) = 74
CharJutsus(CHOUJI).JutsuNum(7) = 75

CharJutsus(LEE).JutsuNum(1) = 77
CharJutsus(LEE).JutsuNum(2) = 78
CharJutsus(LEE).JutsuNum(3) = 80
CharJutsus(LEE).JutsuNum(4) = 81
CharJutsus(LEE).JutsuNum(5) = 82
CharJutsus(LEE).JutsuNum(6) = 83

CharJutsus(NEJI).JutsuNum(1) = 85
CharJutsus(NEJI).JutsuNum(2) = 86
CharJutsus(NEJI).JutsuNum(3) = 87
CharJutsus(NEJI).JutsuNum(4) = 89
CharJutsus(NEJI).JutsuNum(5) = 90
CharJutsus(NEJI).JutsuNum(6) = 91

CharJutsus(HINATA).JutsuNum(1) = 85
CharJutsus(HINATA).JutsuNum(2) = 86
CharJutsus(HINATA).JutsuNum(3) = 87
CharJutsus(HINATA).JutsuNum(4) = 89
CharJutsus(HINATA).JutsuNum(5) = 90
CharJutsus(HINATA).JutsuNum(6) = 91

CharJutsus(TENTEN).JutsuNum(1) = 93
CharJutsus(TENTEN).JutsuNum(2) = 94
CharJutsus(TENTEN).JutsuNum(3) = 95
CharJutsus(TENTEN).JutsuNum(4) = 96
CharJutsus(TENTEN).JutsuNum(5) = 97

CharJutsus(KIBA).JutsuNum(1) = 99
CharJutsus(KIBA).JutsuNum(2) = 101
CharJutsus(KIBA).JutsuNum(3) = 103
CharJutsus(KIBA).JutsuNum(4) = 104
CharJutsus(KIBA).JutsuNum(5) = 105
CharJutsus(KIBA).JutsuNum(6) = 106

CharJutsus(SHINO).JutsuNum(1) = 108
CharJutsus(SHINO).JutsuNum(2) = 109
CharJutsus(SHINO).JutsuNum(3) = 110
CharJutsus(SHINO).JutsuNum(4) = 111
CharJutsus(SHINO).JutsuNum(5) = 112

CharJutsus(GAARA).JutsuNum(1) = 114
CharJutsus(GAARA).JutsuNum(2) = 115
CharJutsus(GAARA).JutsuNum(3) = 116
CharJutsus(GAARA).JutsuNum(4) = 117
CharJutsus(GAARA).JutsuNum(5) = 118
CharJutsus(GAARA).JutsuNum(6) = 119

CharJutsus(KANKUROU).JutsuNum(1) = 121
CharJutsus(KANKUROU).JutsuNum(2) = 122
CharJutsus(KANKUROU).JutsuNum(3) = 123
CharJutsus(KANKUROU).JutsuNum(4) = 124

CharJutsus(TEMARI).JutsuNum(1) = 126
CharJutsus(TEMARI).JutsuNum(2) = 127
CharJutsus(TEMARI).JutsuNum(3) = 128
CharJutsus(TEMARI).JutsuNum(4) = 129

CharJutsus(SAI).JutsuNum(1) = 145
CharJutsus(SAI).JutsuNum(2) = 146
CharJutsus(SAI).JutsuNum(3) = 147
CharJutsus(SAI).JutsuNum(4) = 148
CharJutsus(SAI).JutsuNum(5) = 149
CharJutsus(SAI).JutsuNum(6) = 150

CharJutsus(YONDAIME).JutsuNum(1) = 152
CharJutsus(YONDAIME).JutsuNum(2) = 153
CharJutsus(YONDAIME).JutsuNum(3) = 154
CharJutsus(YONDAIME).JutsuNum(4) = 155
CharJutsus(YONDAIME).JutsuNum(5) = 189
CharJutsus(YONDAIME).JutsuNum(6) = 156
CharJutsus(YONDAIME).JutsuNum(7) = 157
CharJutsus(YONDAIME).JutsuNum(8) = 158

CharJutsus(KISAME).JutsuNum(1) = 160
CharJutsus(KISAME).JutsuNum(2) = 161
CharJutsus(KISAME).JutsuNum(3) = 162
CharJutsus(KISAME).JutsuNum(4) = 163
CharJutsus(KISAME).JutsuNum(5) = 164

CharJutsus(DEIDARA).JutsuNum(1) = 166
CharJutsus(DEIDARA).JutsuNum(2) = 167
CharJutsus(DEIDARA).JutsuNum(3) = 168
CharJutsus(DEIDARA).JutsuNum(4) = 169
CharJutsus(DEIDARA).JutsuNum(5) = 170
CharJutsus(DEIDARA).JutsuNum(6) = 171

CharJutsus(ITACHI).JutsuNum(1) = 49
CharJutsus(ITACHI).JutsuNum(2) = 50
CharJutsus(ITACHI).JutsuNum(3) = 174
CharJutsus(ITACHI).JutsuNum(4) = 175
CharJutsus(ITACHI).JutsuNum(5) = 176
CharJutsus(ITACHI).JutsuNum(6) = 45
CharJutsus(ITACHI).JutsuNum(7) = 177
CharJutsus(ITACHI).JutsuNum(8) = 46
CharJutsus(ITACHI).JutsuNum(9) = 178

CharJutsus(KIMIMARU).JutsuNum(1) = 180
CharJutsus(KIMIMARU).JutsuNum(2) = 181
CharJutsus(KIMIMARU).JutsuNum(3) = 182
CharJutsus(KIMIMARU).JutsuNum(4) = 183
CharJutsus(KIMIMARU).JutsuNum(5) = 184
CharJutsus(KIMIMARU).JutsuNum(6) = 185

CharJutsus(JIRAYA).JutsuNum(1) = 187
CharJutsus(JIRAYA).JutsuNum(2) = 188
CharJutsus(JIRAYA).JutsuNum(3) = 189
CharJutsus(JIRAYA).JutsuNum(4) = 190
CharJutsus(JIRAYA).JutsuNum(5) = 191
CharJutsus(JIRAYA).JutsuNum(6) = 252

CharJutsus(TSUNADE).JutsuNum(1) = 54
CharJutsus(TSUNADE).JutsuNum(2) = 56
CharJutsus(TSUNADE).JutsuNum(3) = 193
CharJutsus(TSUNADE).JutsuNum(4) = 194
CharJutsus(TSUNADE).JutsuNum(5) = 195
CharJutsus(TSUNADE).JutsuNum(6) = 196
CharJutsus(TSUNADE).JutsuNum(7) = 251

CharJutsus(KAKASHI).JutsuNum(1) = 49
CharJutsus(KAKASHI).JutsuNum(2) = 198
CharJutsus(KAKASHI).JutsuNum(3) = 199
CharJutsus(KAKASHI).JutsuNum(4) = 200
CharJutsus(KAKASHI).JutsuNum(5) = 201
CharJutsus(KAKASHI).JutsuNum(6) = 202
CharJutsus(KAKASHI).JutsuNum(7) = 203

CharJutsus(PAIN).JutsuNum(1) = 205
CharJutsus(PAIN).JutsuNum(2) = 206
CharJutsus(PAIN).JutsuNum(3) = 207
CharJutsus(PAIN).JutsuNum(4) = 208
CharJutsus(PAIN).JutsuNum(5) = 209
CharJutsus(PAIN).JutsuNum(6) = 210
CharJutsus(PAIN).JutsuNum(7) = 240


CharJutsus(MADARA).JutsuNum(1) = 49
CharJutsus(MADARA).JutsuNum(2) = 50
CharJutsus(MADARA).JutsuNum(3) = 175
CharJutsus(MADARA).JutsuNum(4) = 212
CharJutsus(MADARA).JutsuNum(5) = 45
CharJutsus(MADARA).JutsuNum(6) = 213
CharJutsus(MADARA).JutsuNum(7) = 214
CharJutsus(MADARA).JutsuNum(8) = 46
CharJutsus(MADARA).JutsuNum(9) = 240


CharJutsus(OROCHIMARU).JutsuNum(1) = 216
CharJutsus(OROCHIMARU).JutsuNum(2) = 217
CharJutsus(OROCHIMARU).JutsuNum(3) = 218
CharJutsus(OROCHIMARU).JutsuNum(4) = 219
CharJutsus(OROCHIMARU).JutsuNum(5) = 220
CharJutsus(OROCHIMARU).JutsuNum(6) = 250

CharJutsus(TOBI).JutsuNum(1) = 49
CharJutsus(TOBI).JutsuNum(2) = 50
CharJutsus(TOBI).JutsuNum(3) = 223
CharJutsus(TOBI).JutsuNum(4) = 222
CharJutsus(TOBI).JutsuNum(5) = 206
CharJutsus(TOBI).JutsuNum(6) = 45
CharJutsus(TOBI).JutsuNum(7) = 208
CharJutsus(TOBI).JutsuNum(8) = 177
CharJutsus(TOBI).JutsuNum(9) = 240
CharJutsus(TOBI).JutsuNum(10) = 242

CharJutsus(HAKU).JutsuNum(1) = 161
CharJutsus(HAKU).JutsuNum(2) = 225
CharJutsus(HAKU).JutsuNum(3) = 226
CharJutsus(HAKU).JutsuNum(4) = 164
CharJutsus(HAKU).JutsuNum(5) = 227

CharJutsus(ZABUZA).JutsuNum(1) = 160
CharJutsus(ZABUZA).JutsuNum(2) = 161
CharJutsus(ZABUZA).JutsuNum(3) = 229
CharJutsus(ZABUZA).JutsuNum(4) = 164
CharJutsus(ZABUZA).JutsuNum(5) = 230

CharJutsus(BEE).JutsuNum(1) = 232
CharJutsus(BEE).JutsuNum(2) = 233
CharJutsus(BEE).JutsuNum(3) = 234
CharJutsus(BEE).JutsuNum(4) = 235
CharJutsus(BEE).JutsuNum(5) = 236
CharJutsus(BEE).JutsuNum(6) = 237
CharJutsus(BEE).JutsuNum(7) = 238

CharJutsus(HASHIRAMA).JutsuNum(1) = 52
CharJutsus(HASHIRAMA).JutsuNum(2) = 257
CharJutsus(HASHIRAMA).JutsuNum(3) = 258
CharJutsus(HASHIRAMA).JutsuNum(4) = 259
CharJutsus(HASHIRAMA).JutsuNum(5) = 260
CharJutsus(HASHIRAMA).JutsuNum(6) = 261
CharJutsus(HASHIRAMA).JutsuNum(7) = 262

CharJutsus(YAMATO).JutsuNum(1) = 52
CharJutsus(YAMATO).JutsuNum(2) = 257
CharJutsus(YAMATO).JutsuNum(3) = 258
CharJutsus(YAMATO).JutsuNum(4) = 259
CharJutsus(YAMATO).JutsuNum(5) = 260
CharJutsus(YAMATO).JutsuNum(6) = 261
CharJutsus(YAMATO).JutsuNum(7) = 262

CharJutsus(KONAN).JutsuNum(1) = 264
CharJutsus(KONAN).JutsuNum(2) = 265
CharJutsus(KONAN).JutsuNum(3) = 266
CharJutsus(KONAN).JutsuNum(4) = 267
CharJutsus(KONAN).JutsuNum(5) = 268
CharJutsus(KONAN).JutsuNum(6) = 269

CharJutsus(RAIKAGE).JutsuNum(1) = 271
CharJutsus(RAIKAGE).JutsuNum(2) = 236
CharJutsus(RAIKAGE).JutsuNum(3) = 272
CharJutsus(RAIKAGE).JutsuNum(4) = 273
CharJutsus(RAIKAGE).JutsuNum(5) = 274
CharJutsus(RAIKAGE).JutsuNum(6) = 275

CharJutsus(DARUI).JutsuNum(1) = 277
CharJutsus(DARUI).JutsuNum(2) = 278
CharJutsus(DARUI).JutsuNum(3) = 279
CharJutsus(DARUI).JutsuNum(4) = 280
CharJutsus(DARUI).JutsuNum(5) = 281
CharJutsus(DARUI).JutsuNum(6) = 282

CharJutsus(HIDAN).JutsuNum(1) = 284
CharJutsus(HIDAN).JutsuNum(2) = 285
CharJutsus(HIDAN).JutsuNum(3) = 286
CharJutsus(HIDAN).JutsuNum(4) = 287
CharJutsus(HIDAN).JutsuNum(5) = 288
CharJutsus(HIDAN).JutsuNum(6) = 289

CharJutsus(SASORI).JutsuNum(1) = 291
CharJutsus(SASORI).JutsuNum(2) = 292
CharJutsus(SASORI).JutsuNum(3) = 293
CharJutsus(SASORI).JutsuNum(4) = 294
CharJutsus(SASORI).JutsuNum(5) = 295
CharJutsus(SASORI).JutsuNum(6) = 296
CharJutsus(SASORI).JutsuNum(7) = 297

CharJutsus(DANZOU).JutsuNum(1) = 49
CharJutsus(DANZOU).JutsuNum(2) = 299
CharJutsus(DANZOU).JutsuNum(3) = 300
CharJutsus(DANZOU).JutsuNum(4) = 301
CharJutsus(DANZOU).JutsuNum(5) = 302
CharJutsus(DANZOU).JutsuNum(6) = 304
CharJutsus(DANZOU).JutsuNum(7) = 303

CharJutsus(YUGITO).JutsuNum(1) = 306
CharJutsus(YUGITO).JutsuNum(2) = 307
CharJutsus(YUGITO).JutsuNum(3) = 308
CharJutsus(YUGITO).JutsuNum(4) = 309
CharJutsus(YUGITO).JutsuNum(5) = 310
CharJutsus(YUGITO).JutsuNum(6) = 311
CharJutsus(YUGITO).JutsuNum(7) = 312

CharJutsus(TOBIRAMA).JutsuNum(1) = 152
CharJutsus(TOBIRAMA).JutsuNum(2) = 153
CharJutsus(TOBIRAMA).JutsuNum(3) = 154
CharJutsus(TOBIRAMA).JutsuNum(4) = 217
CharJutsus(TOBIRAMA).JutsuNum(5) = 314
CharJutsus(TOBIRAMA).JutsuNum(6) = 315
CharJutsus(TOBIRAMA).JutsuNum(7) = 316

CharJutsus(GAI).JutsuNum(1) = 318
CharJutsus(GAI).JutsuNum(2) = 319
CharJutsus(GAI).JutsuNum(3) = 320
CharJutsus(GAI).JutsuNum(4) = 321
CharJutsus(GAI).JutsuNum(5) = 322
CharJutsus(GAI).JutsuNum(6) = 323

CharJutsus(MEI).JutsuNum(1) = 325
CharJutsus(MEI).JutsuNum(2) = 326
CharJutsus(MEI).JutsuNum(3) = 327
CharJutsus(MEI).JutsuNum(4) = 328
CharJutsus(MEI).JutsuNum(5) = 329
CharJutsus(MEI).JutsuNum(6) = 330

End Sub

Public Function MapVip(ByVal mapNum As Long) As Byte

If mapNum < 1 Or mapNum > MAX_MAPS Then Exit Function
    
If mapNum >= 82 And mapNum <= 86 Or mapNum >= 154 And mapNum <= 156 Then
    MapVip = YES
End If

End Function

Public Function EmptyInvSlots(ByVal index As Long) As Byte
If IsPlaying(index) = False Then Exit Function

Dim qnt As Byte
Dim i As Byte

For i = 1 To MAX_INV
    If Player(index).Inv(i).num = 0 Then
        qnt = qnt + 1
    End If
Next

EmptyInvSlots = qnt

End Function

Public Function GetClassStat(ByVal ClassNum As Byte) As Byte
If ClassNum < 1 Or ClassNum > Max_Classes Then Exit Function

Select Case ClassNum
    Case NARUTO, SAKURA, CHOUJI, LEE, NEJI, TENTEN, KIBA, KANKUROU, HINATA, YONDAIME, KIMIMARU, JIRAYA, TSUNADE, BEE, RAIKAGE, HIDAN, SASORI, GAI, HASHIRAMA
        GetClassStat = Stats.strength
    Case SASUKE, SHIKAMARU, SHINO, GAARA, TEMARI, SAI, KISAME, DEIDARA, ITACHI, KAKASHI, PAIN, MADARA, TOBI, OROCHIMARU, INO, HAKU, ZABUZA, YAMATO, KONAN, DANZOU, YUGITO, TOBIRAMA, MEI
        GetClassStat = Stats.Intelligence
    Case Else
        GetClassStat = NO
End Select

End Function

Public Function GetElementName(ByVal Elemento As Byte) As String
If Elemento > 5 Then Exit Function

Select Case Elemento
    Case 1 'fogo
        GetElementName = "Katon(Fogo)"
    Case 2 'vento
        GetElementName = "Fuuton(Vento)"
    Case 3 'agua
        GetElementName = "Suiton(Água)"
    Case 4 'terra
        GetElementName = "Doton(Terra)"
    Case 5 'raio
        GetElementName = "Raiton(Trovão)"
    Case Else
        GetElementName = "Nenhum"
End Select

End Function

Public Function GetVilaName(ByVal VilaNum As Byte) As String
If VilaNum > 5 Then Exit Function

Select Case VilaNum
    Case 0 'chuva
        GetVilaName = "Vila da chuva"
    Case 1 'konoha
        GetVilaName = "Konoha"
    Case 2 'suna
        GetVilaName = "Suna"
    Case 3 'mizu
        GetVilaName = "Mizu"
    Case 4 'tsuchi
        GetVilaName = "Tsuchi"
    Case 5 'kumo
        GetVilaName = "Kumo"
    Case Else
        GetVilaName = "Nenhuma"
End Select

End Function

Public Function Lutando(ByVal index As Long) As Byte

If index < 1 Or index > MAX_PLAYERS Then Exit Function
If GetPlayerMap(index) < 1 Or GetPlayerMap(index) > MAX_MAPS Then Exit Function

If Player(index).Invisivel = YES Then
    Lutando = NO
    Exit Function
End If

If Player(index).Spec = YES Then
    Lutando = NO
    Exit Function
End If

If GetPlayerMap(index) = 96 Or GetPlayerMap(index) = 100 Then
    Lutando = YES
    Exit Function
End If

If GetPlayerMap(index) >= 250 And GetPlayerMap(index) <= 258 Then
    Lutando = YES
    Exit Function
End If

If GetPlayerMap(index) >= 297 And GetPlayerMap(index) <= 300 Then
    Lutando = YES
    Exit Function
End If

If GetPlayerMap(index) >= 229 And GetPlayerMap(index) <= 238 Then
    Lutando = YES
    Exit Function
End If

If GetPlayerMap(index) = 94 Then
    Lutando = YES
    Exit Function
End If

If Player(index).InTorneio > 0 Then
    Lutando = YES
    Exit Function
End If


End Function

Public Function AcharPlayer(ByVal Nome As String) As Long
If Nome = vbNullString Then Exit Function
Dim i As Long

For i = 1 To Player_HighIndex
    If GetPlayerName(i) = Trim(Nome) Then
        AcharPlayer = i
        Exit Function
    End If
Next

End Function

Public Function AcharLogin(ByVal logen As String) As Long
If logen = vbNullString Then Exit Function
Dim i As Long

For i = 1 To Player_HighIndex
    If GetPlayerLogin(i) = Trim(logen) Then
        AcharLogin = i
        Exit Function
    End If
Next

End Function

Public Sub ZerarLutas()
Dim i As Byte

For i = 1 To 3
    Luta.Player(i) = NO
Next

Luta.PlayerQnt = NO

End Sub

Public Sub SortearVila(ByVal index As Long)
If IsPlaying(index) = False Then Exit Sub

Dim ProxVila As Byte
Dim i As Byte

ProxVila = RAND(1, 5)

For i = 1 To 5
    If Player(index).Vila = ProxVila Then 'Ja tem esse elemento
        SortearVila index
        Exit Sub
    End If
Next

    Player(index).Vila = ProxVila
    SavePlayer index
    PlayerMsg index, "Você agora é da vila: " & GetVilaName(ProxVila), White

End Sub

Public Sub GiveElement(ByVal index As Long, ByVal Slot As Byte)
If IsPlaying(index) = False Then Exit Sub
If Slot < 1 Or Slot > 5 Then Exit Sub

Dim Ele As Byte
Dim i As Byte

Ele = RAND(1, 5)

For i = 1 To 5
    If Player(index).Elemento(i) = Ele Then 'Ja tem esse elemento
        GiveElement index, Slot
        Exit Sub
    End If
Next

    Player(index).Elemento(Slot) = Ele
    SavePlayer index
    PlayerMsg index, "Você aprendeu " & GetElementName(Ele), White

End Sub

Public Sub ClearElementJutsus(ByVal index As Long, ByVal Slot As Byte)
If IsPlaying(index) = False Then Exit Sub
If Slot < 1 Or Slot > 5 Then Exit Sub

Dim i, n As Byte

Select Case Player(index).Elemento(Slot)
    Case 1 'Katon
        For i = 1 To MAX_PLAYER_SPELLS
            For n = 7 To 10
                If Player(index).Spell(i) = n Then
                    Player(index).Spell(i) = 0
                End If
            Next
        Next
    Case 2 'Fuuton
        For i = 1 To MAX_PLAYER_SPELLS
            For n = 11 To 14
                If Player(index).Spell(i) = n Then
                    Player(index).Spell(i) = 0
                End If
            Next
        Next
    Case 3 'Suiton
        For i = 1 To MAX_PLAYER_SPELLS
            For n = 15 To 18
                If Player(index).Spell(i) = n Then
                    Player(index).Spell(i) = 0
                End If
            Next
        Next
    Case 4 'Doton
        For i = 1 To MAX_PLAYER_SPELLS
            For n = 23 To 26
                If Player(index).Spell(i) = n Then
                    Player(index).Spell(i) = 0
                End If
            Next
        Next
    Case 5 'Raiton
        For i = 1 To MAX_PLAYER_SPELLS
            For n = 19 To 22
                If Player(index).Spell(i) = n Then
                    Player(index).Spell(i) = 0
                End If
            Next
        Next
    Case Else
End Select

SendPlayerSpells index

End Sub

Public Sub LimparJutsus(ByVal index As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub

Dim i As Long

For i = 1 To MAX_PLAYER_SPELLS
    Select Case Player(index).Spell(i)
        Case 28 To 129
            Player(index).Spell(i) = NO
        Case 145 To 243
            Player(index).Spell(i) = NO
        Case 256 To MAX_SPELLS
            Player(index).Spell(i) = NO
        Case Else
    End Select
Next

End Sub

Public Sub SetarChar(ByVal index As Long, ByVal charNum As Byte, Optional ByVal itemNum As Long)
If IsPlaying(index) = False Then Exit Sub

Dim i As Long
    
    'If GetPlayerClass(index) = ITACHI Or GetPlayerClass(index) = PAIN Or GetPlayerClass(index) = MADARA Or GetPlayerClass(index) = HASHIRAMA Or GetPlayerClass(index) = RAIKAGE Or GetPlayerClass(index) = SASORI Then
    'se for especial
        'If HasItem(index, 221) = NO Then 'se não for supremo
            'If charNum <> ITACHI And charNum <> PAIN And charNum <> MADARA And charNum <> HASHIRAMA And charNum <> RAIKAGE And charNum <> SASORI Then
            'se o novo char não for especial
                'PlayerMsg index, "Char especial não pode usar um char que não seja especial se não perderia esse poder.", BrightRed
                'Exit Sub
            'End If
        'End If
    'End If
    
    If FindOpenSpellSlot(index) = NO Then
        PlayerMsg index, "Sua lista de jutsus está cheia. Precisa excluir algum", Red
        PlayerMsg index, "Para excluir jutsu,clique com o botão direito mas tenha certeza de que queira exclui-lo por que não há volta", Red
        Exit Sub
    End If
    
    If itemNum > 0 Then
        If HasItem(index, 221) = YES Then 'se for supremo
            PlayerMsg index, "Você é supremo, não precisa usar pergaminhos de personagens. É só digitar /+nome do char. Ex: /sakura", White
            Exit Sub
        End If
        
        If HasItem(index, 222) = YES Then 'se for especial
            PlayerMsg index, "Você é especial, não precisa usar pergaminhos de personagens básicos. É só digitar /+nome do char. Ex: /sakura", White
            Exit Sub
        End If
        
        If HasItem(index, itemNum) Then
            TakeInvItem index, itemNum, 1
            SendInventory index
        Else
            Exit Sub
        End If
    End If
    
    If Player(index).Class > 0 And Player(index).Class <= MAX_CLASS_TEMP Then
        If Trim$(TopChar(Player(index).Class).Nome) = GetPlayerName(index) Then 'se ele tiver no top char
            TopChar(Player(index).Class).Nome = "Nenhum" 'tira o nome dele daquele top char
            TopChar(Player(index).Class).Level = 1
        End If
    End If
    
    ResetarPontos index
    Player(index).Class = charNum
    PlayerMsg index, "Você se tornou o personagem: " & GetClassName(charNum), White
    'Limpando os jutsus que não sejam basicos ou de org..
            
    LimparJutsus index
    AtualizarJutsuEspecial index
    
    For i = 1 To MAX_PLAYER_SPELLS
        If CharJutsus(charNum).JutsuNum(i) > 0 Then
            If Not HasSpell(index, CharJutsus(charNum).JutsuNum(i)) Then
                SetPlayerSpell index, FindOpenSpellSlot(index), CharJutsus(charNum).JutsuNum(i)
                PlayerMsg index, "Você acabou de aprender:" & Spell(CharJutsus(charNum).JutsuNum(i)).Name, Blue
            End If
        End If
    Next
            
        SendPlayerSpells index
        SendPlayerData index
        TransDown index
End Sub


Public Sub SetarRank(ByVal n As Long, ByVal RankNum As Byte)
If n < 1 Or n > MAX_PLAYERS Then Exit Sub

Dim u As String

Player(n).Rank = RankNum
SendPlayerData n
SavePlayer n

Select Case RankNum
    Case RANK_ESTUDANTE
        u = "Estudante"
    Case RANK_GENIN
        u = "Genin"
    Case RANK_CHUNIN
        u = "Chunnin"
        If Not HasSpell(n, 4) Then
            SetPlayerSpell n, FindOpenSpellSlot(n), 4
            PlayerMsg n, "Você aprendeu Kage Buyou !", BrightBlue
        End If
    Case RANK_JOUNIN
        u = "Jounin"
        If Player(n).Elemento(2) = NO Then
            GiveElement n, 2
        Else
            PlayerMsg n, "Você já tem segundo elemento,logo,não ganhara um novo.", Red
        End If
        
    Case RANK_ANBU
        u = "ANBU"
        If Not HasSpell(n, 244) Then
            SetPlayerSpell n, FindOpenSpellSlot(n), 244
            PlayerMsg n, "Você aprendeu KAI !", BrightBlue
        End If
    Case RANK_SANNIN
        u = "Sannin"
        If Not HasSpell(n, 245) Then
            SetPlayerSpell n, FindOpenSpellSlot(n), 245
            PlayerMsg n, "Você aprendeu a Liberar Chakra!", BrightBlue
        End If
    Case RANK_KAGE
        AtualizarKage n
        u = "Kage"
        
        If Player(n).Elemento(3) = NO Then
            GiveElement n, 3
        Else
            PlayerMsg n, "Você já tem terceiro elemento,logo,não ganhara um novo.", Red
        End If
        
        If Not HasSpell(n, 242) Then
            SetPlayerSpell n, FindOpenSpellSlot(n), 242
            PlayerMsg n, "Você aprendeu " & Spell(242).Name, BrightBlue
        End If
            
        If GetClassStat(GetPlayerClass(n)) = Stats.strength Then
            If Not HasSpell(n, 142) Then
                SetPlayerSpell n, FindOpenSpellSlot(n), 142
                PlayerMsg n, "Você aprendeu " & Spell(142).Name, BrightBlue
            End If
        End If
            
        If GetClassStat(GetPlayerClass(n)) = Stats.Intelligence Then
            If Not HasSpell(n, 143) Then
                SetPlayerSpell n, FindOpenSpellSlot(n), 143
                PlayerMsg n, "Você aprendeu " & Spell(143).Name, BrightBlue
            End If
        End If
    Case RANK_DESERTOR
        Player(n).Rank = RANK_DESERTOR
        u = "Desertor :P "
    Case Else
        Exit Sub
End Select

PlayerWarp n, 99, 10, 6 'Atendimento

If frmServer.chkOmitir.Value = NO And RankNum <> RANK_KAGE Then
    GlobalMsg GetPlayerName(n) & " evoluiu no Caminho de um Ninja.Agora ele é " & u & "!", BrightCyan
    'GlobalMsg "By:" & GetPlayerName(index), Yellow
End If

End Sub

Public Sub ChecarKAGE(ByVal index As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
'If Not Player(index).Rank = RANK_KAGE Then Exit Sub

Dim i As Byte


If Player(index).Rank = RANK_KAGE Then
    i = Player(index).Vila
    
    If GetPlayerLogin(index) <> GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(i)) Then
        If i = 0 Or i = 6 Then
            Player(index).Rank = RANK_DESERTOR
        Else 'vila boa
            Player(index).Rank = RANK_SANNIN
        End If
        
        PlayerMsg index, "Você não é o atual Kage", BrightRed
        SendPlayerData index
    End If
End If

If GetPlayerLogin(index) = GetVar(App.Path & "\data\lendario.txt", "LENDARIO", "login") Then
    TempPlayer(index).Lendario = YES
Else
    TempPlayer(index).Lendario = NO
End If

End Sub

Public Sub AtualizarKage(ByVal index As Long)
If index < 1 Then Exit Sub

Dim i As Byte

i = Player(index).Vila

    If GetPlayerLogin(index) <> GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(i)) Then 'novo kage
        If frmServer.chkOmitir.Value = NO Then
            Select Case i
                Case 0 'lider
                    GlobalMsg GetPlayerName(index) & " é o novo Líder da Chuva!!", BrightCyan
                Case 1 'hokage
                    GlobalMsg GetPlayerName(index) & " é o novo HOKAGE!!", BrightCyan
                Case 2 'kazekage
                    GlobalMsg GetPlayerName(index) & " é o novo KAZEKAGE!!", BrightCyan
                Case 3 'mizukage
                    GlobalMsg GetPlayerName(index) & " é o novo MIZUKAGE!!", BrightCyan
                Case 4 'tsuchikage
                    GlobalMsg GetPlayerName(index) & " é o novo TSUCHIKAGE!!", BrightCyan
                Case 5 'raikage
                    GlobalMsg GetPlayerName(index) & " é o novo RAIKAGE!!", BrightCyan
                Case 6 'raikage
                    GlobalMsg GetPlayerName(index) & " é o novo Líder do Som!!", BrightCyan
                Case Else
            End Select
        End If
                
    Else 'menteve kage
        GiveInvItem index, 254, 3000, True
        PlayerMsg index, "Você ganhou 3K CASH e 7 dias VIP por manter o cargo.", White
        addVIP index, 7
        
            Select Case i
                Case 0 'lider
                    GlobalMsg GetPlayerName(index) & " manteve o Líder da Chuva!!", BrightCyan
                Case 1 'hokage
                    GlobalMsg GetPlayerName(index) & " manteve o HOKAGE!!", BrightCyan
                Case 2 'kazekage
                    GlobalMsg GetPlayerName(index) & " manteve o KAZEKAGE!!", BrightCyan
                Case 3 'mizukage
                    GlobalMsg GetPlayerName(index) & " manteve o MIZUKAGE!!", BrightCyan
                Case 4 'tsuchikage
                    GlobalMsg GetPlayerName(index) & " manteve o TSUCHIKAGE!!", BrightCyan
                Case 5 'raikage
                    GlobalMsg GetPlayerName(index) & " manteve o RAIKAGE!!", BrightCyan
                Case 6 'lider do som
                    GlobalMsg GetPlayerName(index) & " manteve o Líder do Som!!", BrightCyan
                Case Else
            End Select
        End If
    
    PutVar App.Path & "\data\kages.txt", "KAGES", Trim(i), GetPlayerLogin(index)
        
End Sub

Public Sub AtualizarLendario(ByVal index As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub

    If frmServer.chkOmitir.Value = NO Then
        If GetPlayerLogin(index) <> GetVar(App.Path & "\data\lendario.txt", "LENDARIO", "login") Then 'novo lendario
            GlobalMsg GetPlayerName(index) & " é o novo Lendário!!", BrightCyan
        Else 'menteve
            GlobalMsg GetPlayerName(index) & " manteve o rank de Lendário!!", BrightCyan
        End If
        
        addVIP index, 3
        addCT index, 3
        Atendimento index
        SalvarConta index
        PutVar App.Path & "\data\lendario.txt", "LENDARIO", "login", GetPlayerLogin(index)
    End If
    
End Sub

Public Sub SalvarConta(ByVal index As Long)
If IsPlaying(index) = False Then Exit Sub

    SavePlayer index
    PlayerMsg index, "Sua conta foi salva", Green
    
End Sub

Public Function PontosBugados(ByVal index As Long) As Byte
If index < 1 Then Exit Function

Dim i As Long
Dim pontosTotal As Long
Dim pontosAtuais As Long

If GetPlayerLevel(index) < 180 Then
    'PlayerMsg index, "Apenas lvl 180+", Red
    Exit Function
End If

For i = 1 To Stats.Stat_Count - 1
    pontosAtuais = GetPlayerRawStat(index, i) + pontosAtuais
Next

pontosAtuais = pontosAtuais + GetPlayerPOINTS(index) - 5

If Player(index).Resets > 0 Then '10+
    pontosTotal = pontosTotal + (GetPlayerLevel(index) * 10) + 630
Else '5+
    pontosTotal = pontosTotal + (GetPlayerLevel(index) * 5) + 615
End If
'610 pontos de brinde

If pontosAtuais <> pontosTotal Then
    PlayerMsg index, "Seus pontos estão errados. O certo é : " & pontosTotal, BrightRed
    PontosBugados = YES
End If

End Function


Public Sub ResetarPontos(ByVal index As Long)
If index < 1 Then Exit Sub

Dim pontosTotal As Long
Dim i As Byte

If GetPlayerLevel(index) < 180 Then
    'PlayerMsg index, "Apenas lvl 180+", Red
    Exit Sub
End If

If Player(index).Resets > 0 Then '10+
    pontosTotal = pontosTotal + (GetPlayerLevel(index) * 10) + 630
Else '5+
    pontosTotal = pontosTotal + (GetPlayerLevel(index) * 5) + 615
End If

For i = 1 To Stats.Stat_Count - 1
    SetPlayerStat index, i, 1
Next
    
    TempPlayer(index).SetPoints = YES
    SetPlayerPOINTS index, pontosTotal
    SendStats index
    SendPlayerData index
    PlayerMsg index, "Agora você têm : " & pontosTotal & " para distribuir.", White


End Sub

Public Sub Atendimento(ByVal index As Long)
If IsPlaying(index) = False Then Exit Sub

Player(index).InTorneio = NO
PlayerWarp index, 99, 10, 6
Player(index).Spec = NO
Player(index).Invisivel = NO

End Sub

Public Sub SorteOHYEH()
If Player_HighIndex < 1 Then Exit Sub

Dim i As Long
Dim charN As Long

i = RAND(1, Player_HighIndex)

If i < 1 Then Exit Sub

If IsPlaying(i) = False Then
    SorteOHYEH
    Exit Sub
End If

Select Case RAND(1, 5)
    Case 1, 2, 3, 4
        GiveInvItem i, 254, 10000, True
        GlobalMsg "SORTE OHYEH: " & GetPlayerName(i) & ". Ele ganhou 10K CASH!", Yellow
    Case Else '5
        charN = RAND(123, 160)
        If charN > 0 Then
            GiveInvItem i, charN, 1, True
            GlobalMsg "SORTE OHYEH: " & GetPlayerName(i) & ". Ele ganhou um " & Trim$(Item(charN).Name) & "!", Yellow
        End If
        
End Select

End Sub

Public Sub EventoUpdate(ByVal EVENTONUM As Byte, ByVal valor As Byte)
If EVENTONUM < 1 Then Exit Sub
If valor < 1 Then Exit Sub
If MinutoAviso = Minute(Now) Then Exit Sub

Dim i As Long
Dim itemSorteado As Long
Dim maiorIndex As Long
Dim maiorQuantia As Long

Select Case EVENTONUM
    Case TORNEIO_CS
        Select Case valor
            Case 1 'aviso 1 antes do cs 17:40
                MinutoAviso = 40
                GlobalMsg "20 minutos para o CS.Informações:clique em AJUDA>Chunin Shiken.", White
            Case 2 'aviso 2 antes do cs 17:50
                MinutoAviso = 50
                GlobalMsg "10 minutos para o CS.Informações:clique em AJUDA>Chunin Shiken.", White
            Case 3 'aviso 3 antes do cs 17:55
                MinutoAviso = 55
                GlobalMsg "5 minutos para o CS.Informações:clique em AJUDA>Chunin Shiken.", White
            Case 4 'começa CS 18hrs
                If Torneio <> TORNEIO_CS Then
                    Torneio = TORNEIO_CS
                    frmServer.lstTorneios.ListIndex = TORNEIO_CS
                    frmServer.chkTorneioStatus.Value = YES
                    GlobalMsg "Chunin Shiken ativo ! Para participar vá em 'Extras>Torneio'.", BrightCyan
                    GlobalMsg "Para saber mais sobre o CS,vá em 'Ajuda>Chunin Shiken'.", BrightCyan
                End If
            Case 5 'aviso 1 durante. 18:05
                MinutoAviso = 5
                GlobalMsg "5 minutos restando para a última fase do CS.", Yellow
            Case 6 'aviso 2 durante 18:07
                MinutoAviso = 7
                GlobalMsg "3 minutos restando para a última fase do CS.", Red
            Case 7 'aviso 3 durante 18:9
                MinutoAviso = 9
                GlobalMsg "Menos de 1 minuto restando para a última fase do CS.", BrightRed
            Case 8 ' começa as lutas 18:10
                MinutoAviso = 10
                frmServer.chkTorneioStatus = NO
                GlobalMsg "Parte da floresta da morte Finalizada. Podem começar as lutas.", BrightCyan
                For i = 1 To Player_HighIndex
                    If IsPlaying(i) Then
                        If Player(i).InTorneio > 0 Then
                            If GetPlayerMap(i) >= 57 And GetPlayerMap(i) <= 68 Then 'floresta
                                PlayerMsg i, "Você não conseguiu chegar no edifício chunin a tempo. Mais sorte na próxima.", Yellow
                                Player(i).InTorneio = NO
                                Atendimento i
                            End If
                        End If
                    End If
                Next
                
                AtualizarEvento
            Case Else
                
        End Select
    
    Case TORNEIO_SEMANAL
        Select Case valor
            Case 1 'aviso 1 antes do  17:40
                MinutoAviso = 40
                GlobalMsg "20 minutos para o Evento Semanal. Requer level 200+ e só 1 ip registrado pode participar.", White
            Case 2 'aviso 2 antes do  17:50
                MinutoAviso = 50
                GlobalMsg "10 minutos para o Evento Semanal. Requer level 200+ e só 1 ip registrado pode participar.", White
            Case 3 'aviso 3 antes do  17:55
                MinutoAviso = 55
                GlobalMsg "5 minutos para o Evento Semanal. Requer level 200+ e só 1 ip registrado pode participar.", White
            Case 4 'começa  18hrs
                If Torneio <> TORNEIO_SEMANAL Then
                    Torneio = TORNEIO_SEMANAL
                    frmServer.lstTorneios.ListIndex = TORNEIO_SEMANAL
                    frmServer.chkTorneioStatus.Value = YES
                    GlobalMsg "Evento Semanal ativo ! Para participar vá em 'Extras>Torneio'.", BrightCyan
                    GlobalMsg "Vai ser sorteado um item e quem possuir a maior quantidade ganhará. Caso seja o ganhador, vai ser tirado toda quantidade do item mas ganhará uma recompensa especial.", BrightCyan
                End If
            Case 5 'aviso 1 durante. 18:01
                MinutoAviso = 1
                GlobalMsg "2 minutos restando para o sorteio.", Yellow
            Case 6 'aviso 2 durante 18:02
                MinutoAviso = 2
                GlobalMsg "1 minuto restando para o sorteio.", Red
            Case 7 'começa 18:03
                MinutoAviso = 3
                
                maiorIndex = 0
                maiorQuantia = 0
                itemSorteado = RAND(48, 53)
                
                If itemSorteado < 1 Or itemSorteado > MAX_ITEMS Then
                    GlobalMsg "Item sorteado de número errado:" & itemSorteado, BrightRed
                    
                    Torneio = NO
                    frmServer.lstTorneios.ListIndex = NO
                    frmServer.chkTorneioStatus.Value = NO
                    ZerarLutas
                    ZerarTorneioData
                    SegundosLuta = NO
                    For i = 1 To MAX_LIMIT_TIP
                        SemTip(i) = vbNullString
                    Next
                    Exit Sub
                End If
                
                GlobalMsg "O item sorteado foi : " & Trim$(Item(itemSorteado).Name) & "!", Yellow
                
                For i = 1 To Player_HighIndex
                    If GetPlayerMap(i) = 95 Then 'se estiver no mapa do sorteio
                        If GetPlayerAccess(i) <= 1 Then
                            If HasItem(i, itemSorteado) > maiorQuantia Then
                                maiorQuantia = HasItem(i, itemSorteado)
                                maiorIndex = i
                            End If
                        End If
                    End If
                Next
                
                If IsPlaying(maiorIndex) Then
                    GlobalMsg GetPlayerName(maiorIndex) & " ganhou com a quantidade: " & maiorQuantia & "! Mais sorte na próxima para os que não ganharam.", Yellow
                    TakeInvItem maiorIndex, itemSorteado, HasItem(maiorIndex, itemSorteado)
                    addVIP maiorIndex, 7
                    addCT maiorIndex, 7
                    SalvarConta maiorIndex
                Else
                    GlobalMsg "Ninguém ganhou o evento!", White
                End If
                
                For i = 1 To Player_HighIndex
                    If GetPlayerMap(i) = 95 Then 'se estiver no mapa do sorteio
                        Player(i).InTorneio = NO
                        Atendimento i
                    End If
                Next
                
                Torneio = NO
                frmServer.lstTorneios.ListIndex = NO
                frmServer.chkTorneioStatus.Value = NO
                ZerarLutas
                ZerarTorneioData
                SegundosLuta = NO
                For i = 1 To MAX_LIMIT_TIP
                    SemTip(i) = vbNullString
                Next
                
            Case Else
                
        End Select
    
    Case TORNEIO_LENDARIO
        Select Case valor
            Case 1 'aviso 1 antes
                MinutoAviso = 10
                GlobalMsg "20 minutos para o evento Elite Shinobi! Apenas level 5k+ pode participar.", White
            Case 2 'aviso 2 antes
                MinutoAviso = 20
                GlobalMsg "10 minutos para o evento Elite Shinobi! Apenas level 5k+ pode participar.", White
            Case 3 'aviso 3 antes
                MinutoAviso = 25
                GlobalMsg "5 minutos para o evento Elite Shinobi! Apenas level 5k+ pode participar.", White
            Case 4 'TIP ativado
                MinutoAviso = 30
                GlobalMsg "Evento Elite Shinobi ativado!. Vá em extras>Torneio para participar.", BrightCyan
                Torneio = TORNEIO_LENDARIO
                frmServer.chkTorneioStatus.Value = YES
                frmServer.lstTorneios.ListIndex = TORNEIO_LENDARIO
            Case 5 'aviso 1 durante.
                MinutoAviso = 31
                GlobalMsg "2 minutos para começar o evento Elite Shinobi! Vá em extras>Torneio para participar!", White
            Case 6 'aviso 2 durante
                MinutoAviso = 32
                GlobalMsg "1 minuto para começar o evento Elite Shinobi! Vá em extras>Torneio para participar!", White
            Case 7 'começa as lutas
                MinutoAviso = 33
                frmServer.chkTorneioStatus.Value = NO
                GlobalMsg "Começando o evento dos lvl 5k! Se você não está participando,poderá ver(depois do boss ser derrotado) o mata mata da elite indo em 'Extras>Espectador'", Yellow
                
                If TorneioData.pTotal < 1 Then
                    GlobalMsg "Como não teve participantes o evento foi finalizado!", Green
                    
                    Torneio = NO
                    frmServer.lstTorneios.ListIndex = NO
                    frmServer.chkTorneioStatus.Value = NO
                    ZerarLutas
                    ZerarTorneioData
                    SegundosLuta = NO
                    For i = 1 To MAX_LIMIT_TIP
                        SemTip(i) = vbNullString
                    Next
                    
                    Exit Sub
                End If
                
                For i = 1 To Player_HighIndex
                    If IsPlaying(TorneioData.Participante(i)) = True Then
                        PlayerWarp TorneioData.Participante(i), 94, 1, 1 'teleporta pra otsutsuki BOSS
                    End If
                Next
                
            Case Else
                
        End Select
        
    Case TORNEIO_LUTA
        Select Case valor
            Case 1 'aviso 1 antes
                MinutoAviso = 10
                GlobalMsg "20 minutos para o Torneio Inner Power(TIP)!", White
            Case 2 'aviso 2 antes
                MinutoAviso = 20
                GlobalMsg "10 minutos para o Torneio Inner Power(TIP)!", White
            Case 3 'aviso 3 antes
                MinutoAviso = 25
                GlobalMsg "5 minutos para o Torneio Inner Power(TIP)!", White
            Case 4 'TIP ativado
                MinutoAviso = 30
                GlobalMsg "Torneio Inner Power(T.I.P.) ativado!. Vá em extras>Torneio para participar.", BrightCyan
                Torneio = TORNEIO_LUTA
                frmServer.chkTorneioStatus.Value = YES
                frmServer.lstTorneios.ListIndex = TORNEIO_LUTA
            Case 5 'aviso 1 durante.
                MinutoAviso = 31
                GlobalMsg "2 minutos para começar as lutas do TIP! Vá em extras>Torneio para participar!", White
            Case 6 'aviso 2 durante
                MinutoAviso = 32
                GlobalMsg "1 minuto para começar as lutas do TIP! Vá em extras>Torneio para participar!", White
            Case 7 'começa as lutas
                MinutoAviso = 33
                frmServer.chkTorneioStatus.Value = NO
                GlobalMsg "Começando o TIP! Se você não está participando,poderá ver as lutas indo em 'Extras>Espectador'", Yellow
                AtualizarEvento
            Case Else
                
        End Select
    
    Case TORNEIO_POKEMON
    'TEMOS QUE PEGAR
        Select Case valor
            Case 1 'aviso 1 antes
                MinutoAviso = 10
                GlobalMsg "20 minutos para o evento TEMOS QUE PEGAR! Os ultimos 5 poquemãos que sobrarem se tornam raros.", White
            Case 2 'aviso 2 antes
                MinutoAviso = 20
                GlobalMsg "10 minutos para o evento TEMOS QUE PEGAR! Os ultimos 5 poquemãos que sobrarem se tornam raros.", White
            Case 3 'aviso 3 antes
                MinutoAviso = 25
                GlobalMsg "5 minutos para o evento TEMOS QUE PEGAR! Os ultimos 5 poquemãos que sobrarem se tornam raros.", White
            Case 4 'temosqp ativado
                MinutoAviso = 30
                GlobalMsg "Evento TEMOS QUE PEGAR ativado!. Vá em extras>Torneio para participar.", BrightCyan
                Torneio = TORNEIO_POKEMON
                frmServer.chkTorneioStatus.Value = YES
                frmServer.lstTorneios.ListIndex = TORNEIO_POKEMON
            Case 5 'aviso 1 durante.
                MinutoAviso = 31
                GlobalMsg "2 minutos para começar o evento Temos que pegar! Vá em extras>Torneio para participar!", White
            Case 6 'aviso 2 durante
                MinutoAviso = 32
                GlobalMsg "1 minuto para começar o evento Temos que pegar! Vá em extras>Torneio para participar!", White
            Case 7 'começa
                MinutoAviso = 33
                frmServer.chkTorneioStatus.Value = NO
                GlobalMsg "Começando o evento!", Yellow
                AtualizarEvento
            Case Else
                
        End Select
        
    Case TORNEIO_GUERRA
        Select Case valor
            Case 1 'aviso 1 antes
                MinutoAviso = 10
                GlobalMsg "20 minutos para a Guerra Shinobi. Tsuki vs Aliança!!", White
            Case 2 'aviso 2 antes
                MinutoAviso = 20
                GlobalMsg "10 minutos para a Guerra Shinobi. Tsuki vs Aliança!!", White
            Case 3 'aviso 3 antes
                MinutoAviso = 25
                GlobalMsg "5 minutos para a Guerra Shinobi. Tsuki vs Aliança!!", White
            Case 4 'GUERRA  ativada
                MinutoAviso = 30
                GlobalMsg "GUERRA SHINBOI ativada!. Vá em extras>Torneio para participar.", BrightCyan
                Torneio = TORNEIO_GUERRA
                frmServer.chkTorneioStatus.Value = YES
                frmServer.lstTorneios.ListIndex = TORNEIO_GUERRA
            Case 5 'aviso 1 durante.
                MinutoAviso = 31
                GlobalMsg "2 minutos para começar a GUERRA! Vá em extras>Torneio para participar!", White
            Case 6 'aviso 2 durante
                MinutoAviso = 32
                GlobalMsg "1 minuto para começar a GUERRA! Vá em extras>Torneio para participar!", White
            Case 7 'começa as lutas
                MinutoAviso = 33
                frmServer.chkTorneioStatus.Value = NO
                
                For i = 1 To Player_HighIndex
                    If Player(i).War > 0 Then
                        TempPlayer(i).Contagem = 6
                        PlayerMsg i, "A GUERRA COMEÇOU,PREPARE-SE PARA A BATALHA!!", White
                        
                        If Player(i).War = 1 Then 'Bem
                            SetPlayerDir i, DIR_RIGHT
                            PlayerWarp i, 299, 2, RAND(2, 59)
                        Else 'maledito
                            SetPlayerDir i, DIR_LEFT
                            PlayerWarp i, 299, 29, RAND(2, 59)
                        End If
                    End If
                Next
                
                GlobalMsg "Começando Guerra Shinobi! Se você não está participando,poderá ver as lutas indo em 'Extras>Espectador'", Yellow
                AtualizarEvento
            Case Else
                
        End Select
    
    Case TORNEIO_DESAFIOS
        Select Case valor
            Case 1 'aviso 1 antes
                MinutoAviso = 10
                GlobalMsg "20 minutos para o Torneio dos Desafios!", White
            Case 2 'aviso 2 antes
                MinutoAviso = 20
                GlobalMsg "10 minutos para o Torneio dos Desafios!", White
            Case 3 'aviso 3 antes
                MinutoAviso = 25
                GlobalMsg "5 minutos para o Torneio dos Desafios!", White
            Case 4 'TIP ativado
                MinutoAviso = 30
                GlobalMsg "Torneio dos Desafios ativado!. Vá em extras>Torneio para participar.", BrightCyan
                Torneio = TORNEIO_DESAFIOS
                frmServer.chkTorneioStatus.Value = YES
                frmServer.lstTorneios.ListIndex = TORNEIO_DESAFIOS
                
                For i = 230 To 238
                    SpawnMapNpcs i
                Next
                
            Case 5 'aviso 1 durante.
                MinutoAviso = 31
                GlobalMsg "2 minutos para começar o Torneio dos Desafios! Vá em extras>Torneio para participar!", White
            Case 6 'aviso 2 durante
                MinutoAviso = 32
                GlobalMsg "1 minuto para começar o Torneio dos Desafios! Vá em extras>Torneio para participar!", White
            Case 7 'começa as lutas
                desafioNum = 0
                MinutoAviso = 33
                frmServer.chkTorneioStatus.Value = NO
                GlobalMsg "Começando o Torneio dos Desafios!", Yellow
                AtualizarEvento
            Case Else
                
        End Select
    
    Case Else
    
End Select
        
End Sub


Public Sub EventoAutomatico()
Dim i As Long
Dim mAtual As Byte 'minuto
Dim hAtual As Byte 'hora

mAtual = Minute(Now)
hAtual = Hour(Now)

If hAtual <> 1 And hAtual <> 6 And hAtual <> 10 And hAtual <> 13 And hAtual <> 17 And hAtual <> 18 And hAtual <> 19 Then Exit Sub
If mAtual <> 0 And mAtual <> 1 And mAtual <> 2 And mAtual <> 3 And mAtual <> 5 And mAtual <> 6 And mAtual <> 7 And mAtual <> 8 And mAtual <> 9 And mAtual <> 10 And mAtual <> 20 And mAtual <> 25 And mAtual <> 30 And mAtual <> 31 And mAtual <> 32 And mAtual <> 33 And mAtual <> 40 And mAtual <> 50 And mAtual <> 55 Then Exit Sub

If hAtual = 6 Or hAtual = 17 Then
    If mAtual < 1 Then
        If Second(Now) < 6 And frmServer.chkNoShutdown.Value = YES Then
            frmServer.chkNoShutdown.Value = NO
            isShuttingDown = True
            
            SaveAllPlayersOnline
        End If
    End If
End If

Select Case Weekday(Now)
    Case 1 'domingo
        Select Case hAtual
            Case 1  '1:30 #TIP#
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 10
                            EventoUpdate TORNEIO_LUTA, 1
                        Case 20
                            EventoUpdate TORNEIO_LUTA, 2
                        Case 25
                            EventoUpdate TORNEIO_LUTA, 3
                        Case 30
                            EventoUpdate TORNEIO_LUTA, 4
                        Case 31
                            EventoUpdate TORNEIO_LUTA, 5
                        Case 32
                            EventoUpdate TORNEIO_LUTA, 6
                        Case 33
                            EventoUpdate TORNEIO_LUTA, 7
                        Case Else
                    End Select
                End If
            
            Case 10  '10:30 #GUERRA#
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 10
                            EventoUpdate TORNEIO_GUERRA, 1
                        Case 20
                            EventoUpdate TORNEIO_GUERRA, 2
                        Case 25
                            EventoUpdate TORNEIO_GUERRA, 3
                        Case 30
                            EventoUpdate TORNEIO_GUERRA, 4
                        Case 31
                            EventoUpdate TORNEIO_GUERRA, 5
                        Case 32
                            EventoUpdate TORNEIO_GUERRA, 6
                        Case 33
                            EventoUpdate TORNEIO_GUERRA, 7
                        Case Else
                    End Select
                End If
                
            Case 13  '13:30 #POKEMON#
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 10
                            EventoUpdate TORNEIO_DESAFIOS, 1
                        Case 20
                            EventoUpdate TORNEIO_DESAFIOS, 2
                        Case 25
                            EventoUpdate TORNEIO_DESAFIOS, 3
                        Case 30
                            EventoUpdate TORNEIO_DESAFIOS, 4
                        Case 31
                            EventoUpdate TORNEIO_DESAFIOS, 5
                        Case 32
                            EventoUpdate TORNEIO_DESAFIOS, 6
                        Case 33
                            EventoUpdate TORNEIO_DESAFIOS, 7
                        Case Else
                    End Select
                End If
            
            Case 17  ' Semanal avisos
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 40
                            EventoUpdate TORNEIO_SEMANAL, 1
                        Case 50
                            EventoUpdate TORNEIO_SEMANAL, 2
                        Case 55
                            EventoUpdate TORNEIO_SEMANAL, 3
                        Case Else
                    End Select
                End If
                
            Case 18  'Semanal começando
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 0
                            If Torneio <> TORNEIO_SEMANAL Then
                                EventoUpdate TORNEIO_SEMANAL, 4
                                MinutoAviso = mAtual
                            End If
                        Case 1 '2 minutos para começar
                            EventoUpdate TORNEIO_SEMANAL, 5
                        Case 2 '1 minuto para começar
                            EventoUpdate TORNEIO_SEMANAL, 6
                        Case 3 'sorteou
                            EventoUpdate TORNEIO_SEMANAL, 7
                            
                        'EVENTO ELITE SHINOBI
                        Case 10
                            EventoUpdate TORNEIO_LENDARIO, 1
                        Case 20
                            EventoUpdate TORNEIO_LENDARIO, 2
                        Case 25
                            EventoUpdate TORNEIO_LENDARIO, 3
                        Case 30 'ativa
                            EventoUpdate TORNEIO_LENDARIO, 4
                        Case 31 'espera 2min
                            EventoUpdate TORNEIO_LENDARIO, 5
                        Case 32 'espera 1min
                            EventoUpdate TORNEIO_LENDARIO, 6
                        Case 33 'começa
                            EventoUpdate TORNEIO_LENDARIO, 7
                        Case Else
                    End Select
                End If
                
            Case 19  '19:30 #TIP#
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 10
                            EventoUpdate TORNEIO_LUTA, 1
                        Case 20
                            EventoUpdate TORNEIO_LUTA, 2
                        Case 25
                            EventoUpdate TORNEIO_LUTA, 3
                        Case 30
                            EventoUpdate TORNEIO_LUTA, 4
                        Case 31
                            EventoUpdate TORNEIO_LUTA, 5
                        Case 32
                            EventoUpdate TORNEIO_LUTA, 6
                        Case 33
                            EventoUpdate TORNEIO_LUTA, 7
                        Case Else
                    End Select
                End If
            
            Case Else 'outra hora do dia
        End Select
        
    Case 2 'segunda
        Select Case hAtual
            Case 1  '1:30 #GUERRA#
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 10
                            EventoUpdate TORNEIO_GUERRA, 1
                        Case 20
                            EventoUpdate TORNEIO_GUERRA, 2
                        Case 25
                            EventoUpdate TORNEIO_GUERRA, 3
                        Case 30
                            EventoUpdate TORNEIO_GUERRA, 4
                        Case 31
                            EventoUpdate TORNEIO_GUERRA, 5
                        Case 32
                            EventoUpdate TORNEIO_GUERRA, 6
                        Case 33
                            EventoUpdate TORNEIO_GUERRA, 7
                        Case Else
                    End Select
                End If
            
            Case 10  '10:30 #POKEMON#
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 10
                            EventoUpdate TORNEIO_LUTA, 1 'pokemon <<
                        Case 20
                            EventoUpdate TORNEIO_LUTA, 2
                        Case 25
                            EventoUpdate TORNEIO_LUTA, 3
                        Case 30
                            EventoUpdate TORNEIO_LUTA, 4
                        Case 31
                            EventoUpdate TORNEIO_LUTA, 5
                        Case 32
                            EventoUpdate TORNEIO_LUTA, 6
                        Case 33
                            EventoUpdate TORNEIO_LUTA, 7
                        Case Else
                    End Select
                End If
                
            Case 13  '13:30 #TIP#
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 10
                            EventoUpdate TORNEIO_LUTA, 1
                        Case 20
                            EventoUpdate TORNEIO_LUTA, 2
                        Case 25
                            EventoUpdate TORNEIO_LUTA, 3
                        Case 30
                            EventoUpdate TORNEIO_LUTA, 4
                        Case 31
                            EventoUpdate TORNEIO_LUTA, 5
                        Case 32
                            EventoUpdate TORNEIO_LUTA, 6
                        Case 33
                            EventoUpdate TORNEIO_LUTA, 7
                        Case Else
                    End Select
                End If
                
            Case 19  '19:30 #DESAFIOS#
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 10
                            EventoUpdate TORNEIO_DESAFIOS, 1
                        Case 20
                            EventoUpdate TORNEIO_DESAFIOS, 2
                        Case 25
                            EventoUpdate TORNEIO_DESAFIOS, 3
                        Case 30
                            EventoUpdate TORNEIO_DESAFIOS, 4
                        Case 31
                            EventoUpdate TORNEIO_DESAFIOS, 5
                        Case 32
                            EventoUpdate TORNEIO_DESAFIOS, 6
                        Case 33
                            EventoUpdate TORNEIO_DESAFIOS, 7
                        Case Else
                    End Select
                End If
            
            Case Else 'outra hora do dia
        End Select
        
    Case 3 'terça
        Select Case hAtual
            Case 1  '1:30 #DESAFIOS#
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 10
                            EventoUpdate TORNEIO_DESAFIOS, 1
                        Case 20
                            EventoUpdate TORNEIO_DESAFIOS, 2
                        Case 25
                            EventoUpdate TORNEIO_DESAFIOS, 3
                        Case 30
                            EventoUpdate TORNEIO_DESAFIOS, 4
                        Case 31
                            EventoUpdate TORNEIO_DESAFIOS, 5
                        Case 32
                            EventoUpdate TORNEIO_DESAFIOS, 6
                        Case 33
                            EventoUpdate TORNEIO_DESAFIOS, 7
                        Case Else
                    End Select
                End If
            
            Case 10  '10:30 #POKEMON#
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 10
                            EventoUpdate TORNEIO_LUTA, 1 '<<pokemon
                        Case 20
                            EventoUpdate TORNEIO_LUTA, 2
                        Case 25
                            EventoUpdate TORNEIO_LUTA, 3
                        Case 30
                            EventoUpdate TORNEIO_LUTA, 4
                        Case 31
                            EventoUpdate TORNEIO_LUTA, 5
                        Case 32
                            EventoUpdate TORNEIO_LUTA, 6
                        Case 33
                            EventoUpdate TORNEIO_LUTA, 7
                        Case Else
                    End Select
                End If
                
            Case 13  '13:30 #GUERRA#
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 10
                            EventoUpdate TORNEIO_GUERRA, 1
                        Case 20
                            EventoUpdate TORNEIO_GUERRA, 2
                        Case 25
                            EventoUpdate TORNEIO_GUERRA, 3
                        Case 30
                            EventoUpdate TORNEIO_GUERRA, 4
                        Case 31
                            EventoUpdate TORNEIO_GUERRA, 5
                        Case 32
                            EventoUpdate TORNEIO_GUERRA, 6
                        Case 33
                            EventoUpdate TORNEIO_GUERRA, 7
                        Case Else
                    End Select
                End If
                
            Case 19  '19:30 #TIP#
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 10
                            EventoUpdate TORNEIO_LUTA, 1
                        Case 20
                            EventoUpdate TORNEIO_LUTA, 2
                        Case 25
                            EventoUpdate TORNEIO_LUTA, 3
                        Case 30
                            EventoUpdate TORNEIO_LUTA, 4
                        Case 31
                            EventoUpdate TORNEIO_LUTA, 5
                        Case 32
                            EventoUpdate TORNEIO_LUTA, 6
                        Case 33
                            EventoUpdate TORNEIO_LUTA, 7
                        Case Else
                    End Select
                End If
            
            Case Else 'outra hora do dia
        End Select
    
    Case 4 'quarta
        Select Case hAtual
            Case 1  '1:30 #POKEMON#
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 10
                            EventoUpdate TORNEIO_LUTA, 1 '<<pokemon
                        Case 20
                            EventoUpdate TORNEIO_LUTA, 2
                        Case 25
                            EventoUpdate TORNEIO_LUTA, 3
                        Case 30
                            EventoUpdate TORNEIO_LUTA, 4
                        Case 31
                            EventoUpdate TORNEIO_LUTA, 5
                        Case 32
                            EventoUpdate TORNEIO_LUTA, 6
                        Case 33
                            EventoUpdate TORNEIO_LUTA, 7
                        Case Else
                    End Select
                End If
            
            Case 10  '10:30 #DESAFIOS#
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 10
                            EventoUpdate TORNEIO_DESAFIOS, 1
                        Case 20
                            EventoUpdate TORNEIO_DESAFIOS, 2
                        Case 25
                            EventoUpdate TORNEIO_DESAFIOS, 3
                        Case 30
                            EventoUpdate TORNEIO_DESAFIOS, 4
                        Case 31
                            EventoUpdate TORNEIO_DESAFIOS, 5
                        Case 32
                            EventoUpdate TORNEIO_DESAFIOS, 6
                        Case 33
                            EventoUpdate TORNEIO_DESAFIOS, 7
                        Case Else
                    End Select
                End If
                
            Case 13  '13:30 #POKEMON#
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 10
                            EventoUpdate TORNEIO_LUTA, 1 '<<pokemon
                        Case 20
                            EventoUpdate TORNEIO_LUTA, 2
                        Case 25
                            EventoUpdate TORNEIO_LUTA, 3
                        Case 30
                            EventoUpdate TORNEIO_LUTA, 4
                        Case 31
                            EventoUpdate TORNEIO_LUTA, 5
                        Case 32
                            EventoUpdate TORNEIO_LUTA, 6
                        Case 33
                            EventoUpdate TORNEIO_LUTA, 7
                        Case Else
                    End Select
                End If
            
            'Case 17  ' CS avisos
                'If MinutoAviso <> mAtual Then
                    'Select Case mAtual
                        'Case 40
                            'EventoUpdate TORNEIO_CS, 1
                        'Case 50
                            'EventoUpdate TORNEIO_CS, 2
                        'Case 55
                            'EventoUpdate TORNEIO_CS, 3
                        'Case Else
                    'End Select
                'End If
                
            'Case 18  'CS começando
                'If MinutoAviso <> mAtual Then
                    'Select Case mAtual
                        'Case 0
                            'If Torneio <> TORNEIO_CS Then
                                'EventoUpdate TORNEIO_CS, 4
                                'MinutoAviso = mAtual
                            'End If
                        'Case 5
                            'EventoUpdate TORNEIO_CS, 5
                        'Case 7
                            'EventoUpdate TORNEIO_CS, 6
                        'Case 9
                            'EventoUpdate TORNEIO_CS, 7
                        'Case 10
                            'EventoUpdate TORNEIO_CS, 8
                        'Case Else
                    'End Select
                'End If
                
            Case 19  '19:30 #GUERRA#
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 10
                            EventoUpdate TORNEIO_GUERRA, 1
                        Case 20
                            EventoUpdate TORNEIO_GUERRA, 2
                        Case 25
                            EventoUpdate TORNEIO_GUERRA, 3
                        Case 30
                            EventoUpdate TORNEIO_GUERRA, 4
                        Case 31
                            EventoUpdate TORNEIO_GUERRA, 5
                        Case 32
                            EventoUpdate TORNEIO_GUERRA, 6
                        Case 33
                            EventoUpdate TORNEIO_GUERRA, 7
                        Case Else
                    End Select
                End If
            
            Case Else 'outra hora do dia
        End Select
        
    Case 5 'quinta
        Select Case hAtual
            Case 1  '1:30 #DESAFIOS#
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 10
                            EventoUpdate TORNEIO_DESAFIOS, 1
                        Case 20
                            EventoUpdate TORNEIO_DESAFIOS, 2
                        Case 25
                            EventoUpdate TORNEIO_DESAFIOS, 3
                        Case 30
                            EventoUpdate TORNEIO_DESAFIOS, 4
                        Case 31
                            EventoUpdate TORNEIO_DESAFIOS, 5
                        Case 32
                            EventoUpdate TORNEIO_DESAFIOS, 6
                        Case 33
                            EventoUpdate TORNEIO_DESAFIOS, 7
                        Case Else
                    End Select
                End If
            
            Case 10  '10:30 #POKEMON#
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 10
                            EventoUpdate TORNEIO_LUTA, 1 '<<pokemon
                        Case 20
                            EventoUpdate TORNEIO_LUTA, 2
                        Case 25
                            EventoUpdate TORNEIO_LUTA, 3
                        Case 30
                            EventoUpdate TORNEIO_LUTA, 4
                        Case 31
                            EventoUpdate TORNEIO_LUTA, 5
                        Case 32
                            EventoUpdate TORNEIO_LUTA, 6
                        Case 33
                            EventoUpdate TORNEIO_LUTA, 7
                        Case Else
                    End Select
                End If
                
            Case 13  '13:30 #GUERRA#
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 10
                            EventoUpdate TORNEIO_GUERRA, 1
                        Case 20
                            EventoUpdate TORNEIO_GUERRA, 2
                        Case 25
                            EventoUpdate TORNEIO_GUERRA, 3
                        Case 30
                            EventoUpdate TORNEIO_GUERRA, 4
                        Case 31
                            EventoUpdate TORNEIO_GUERRA, 5
                        Case 32
                            EventoUpdate TORNEIO_GUERRA, 6
                        Case 33
                            EventoUpdate TORNEIO_GUERRA, 7
                        Case Else
                    End Select
                End If
                
            Case 19  '19:30 #TIP#
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 10
                            EventoUpdate TORNEIO_LUTA, 1
                        Case 20
                            EventoUpdate TORNEIO_LUTA, 2
                        Case 25
                            EventoUpdate TORNEIO_LUTA, 3
                        Case 30
                            EventoUpdate TORNEIO_LUTA, 4
                        Case 31
                            EventoUpdate TORNEIO_LUTA, 5
                        Case 32
                            EventoUpdate TORNEIO_LUTA, 6
                        Case 33
                            EventoUpdate TORNEIO_LUTA, 7
                        Case Else
                    End Select
                End If
            
            Case Else 'outra hora do dia
        End Select
    
    Case 6 'sexta
        Select Case hAtual
            Case 1  '1:30 #DESAFIOS#
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 10
                            EventoUpdate TORNEIO_DESAFIOS, 1
                        Case 20
                            EventoUpdate TORNEIO_DESAFIOS, 2
                        Case 25
                            EventoUpdate TORNEIO_DESAFIOS, 3
                        Case 30
                            EventoUpdate TORNEIO_DESAFIOS, 4
                        Case 31
                            EventoUpdate TORNEIO_DESAFIOS, 5
                        Case 32
                            EventoUpdate TORNEIO_DESAFIOS, 6
                        Case 33
                            EventoUpdate TORNEIO_DESAFIOS, 7
                        Case Else
                    End Select
                End If
            
            Case 10  '10:30 #TIP#
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 10
                            EventoUpdate TORNEIO_LUTA, 1
                        Case 20
                            EventoUpdate TORNEIO_LUTA, 2
                        Case 25
                            EventoUpdate TORNEIO_LUTA, 3
                        Case 30
                            EventoUpdate TORNEIO_LUTA, 4
                        Case 31
                            EventoUpdate TORNEIO_LUTA, 5
                        Case 32
                            EventoUpdate TORNEIO_LUTA, 6
                        Case 33
                            EventoUpdate TORNEIO_LUTA, 7
                        Case Else
                    End Select
                End If
                
            Case 13  '13:30 #GUERRA#
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 10
                            EventoUpdate TORNEIO_GUERRA, 1
                        Case 20
                            EventoUpdate TORNEIO_GUERRA, 2
                        Case 25
                            EventoUpdate TORNEIO_GUERRA, 3
                        Case 30
                            EventoUpdate TORNEIO_GUERRA, 4
                        Case 31
                            EventoUpdate TORNEIO_GUERRA, 5
                        Case 32
                            EventoUpdate TORNEIO_GUERRA, 6
                        Case 33
                            EventoUpdate TORNEIO_GUERRA, 7
                        Case Else
                    End Select
                End If
                
            Case 19  '19:30 #POKEMON#
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 10
                            EventoUpdate TORNEIO_LUTA, 1 '<<pokemon
                        Case 20
                            EventoUpdate TORNEIO_LUTA, 2
                        Case 25
                            EventoUpdate TORNEIO_LUTA, 3
                        Case 30
                            EventoUpdate TORNEIO_LUTA, 4
                        Case 31
                            EventoUpdate TORNEIO_LUTA, 5
                        Case 32
                            EventoUpdate TORNEIO_LUTA, 6
                        Case 33
                            EventoUpdate TORNEIO_LUTA, 7
                        Case Else
                    End Select
                End If
            
            Case Else 'outra hora do dia
        End Select
    
    Case 7 'sabado
        Select Case hAtual
            Case 1  '1:30 #GUERRA#
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 10
                            EventoUpdate TORNEIO_GUERRA, 1
                        Case 20
                            EventoUpdate TORNEIO_GUERRA, 2
                        Case 25
                            EventoUpdate TORNEIO_GUERRA, 3
                        Case 30
                            EventoUpdate TORNEIO_GUERRA, 4
                        Case 31
                            EventoUpdate TORNEIO_GUERRA, 5
                        Case 32
                            EventoUpdate TORNEIO_GUERRA, 6
                        Case 33
                            EventoUpdate TORNEIO_GUERRA, 7
                        Case Else
                    End Select
                End If
            
            Case 10  '10:30 #TIP#
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 10
                            EventoUpdate TORNEIO_LUTA, 1
                        Case 20
                            EventoUpdate TORNEIO_LUTA, 2
                        Case 25
                            EventoUpdate TORNEIO_LUTA, 3
                        Case 30
                            EventoUpdate TORNEIO_LUTA, 4
                        Case 31
                            EventoUpdate TORNEIO_LUTA, 5
                        Case 32
                            EventoUpdate TORNEIO_LUTA, 6
                        Case 33
                            EventoUpdate TORNEIO_LUTA, 7
                        Case Else
                    End Select
                End If
                
            Case 13  '13:30 #POKEMON#
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 10
                            EventoUpdate TORNEIO_LUTA, 1 '<<pokemon
                        Case 20
                            EventoUpdate TORNEIO_LUTA, 2
                        Case 25
                            EventoUpdate TORNEIO_LUTA, 3
                        Case 30
                            EventoUpdate TORNEIO_LUTA, 4
                        Case 31
                            EventoUpdate TORNEIO_LUTA, 5
                        Case 32
                            EventoUpdate TORNEIO_LUTA, 6
                        Case 33
                            EventoUpdate TORNEIO_LUTA, 7
                        Case Else
                    End Select
                End If
            
            Case 17  ' CS avisos
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 40
                            EventoUpdate TORNEIO_CS, 1
                        Case 50
                            EventoUpdate TORNEIO_CS, 2
                        Case 55
                            EventoUpdate TORNEIO_CS, 3
                        Case Else
                    End Select
                End If
                
            Case 18  'CS começando
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 0
                            If Torneio <> TORNEIO_CS Then
                                EventoUpdate TORNEIO_CS, 4
                                MinutoAviso = mAtual
                            End If
                        Case 5
                            EventoUpdate TORNEIO_CS, 5
                        Case 7
                            EventoUpdate TORNEIO_CS, 6
                        Case 9
                            EventoUpdate TORNEIO_CS, 7
                        Case 10
                            EventoUpdate TORNEIO_CS, 8
                        Case Else
                    End Select
                End If
                
            Case 19  '19:30 #GUERRA#
                If MinutoAviso <> mAtual Then
                    Select Case mAtual
                        Case 10
                            EventoUpdate TORNEIO_DESAFIOS, 1
                        Case 20
                            EventoUpdate TORNEIO_DESAFIOS, 2
                        Case 25
                            EventoUpdate TORNEIO_DESAFIOS, 3
                        Case 30
                            EventoUpdate TORNEIO_DESAFIOS, 4
                        Case 31
                            EventoUpdate TORNEIO_DESAFIOS, 5
                        Case 32
                            EventoUpdate TORNEIO_DESAFIOS, 6
                        Case 33
                            EventoUpdate TORNEIO_DESAFIOS, 7
                        Case Else
                    End Select
                End If
            
            Case Else 'outra hora do dia
        End Select
        
    Case Else 'outro dia da semana
End Select

End Sub

Public Sub EventoExpAutomatico()

    If frmServer.chkEventActive.Value = YES Then Exit Sub
    
    If Hour(Now) = 2 Then
        frmServer.txtEventoEXP.Text = "2"
        frmServer.txtEventHour.Text = "3"
        '###########
        GlobalMsg "Evento Ativo!! Agora você ganha " & frmServer.txtEventoEXP.Text & " vezes mais de EXP!Aproveite,OhYehGames.", BrightCyan
        GlobalMsg "Evento ativo até as :" & frmServer.txtEventHour & " horas", White
        frmServer.chkEventActive.Value = YES
        EventoExpCount = 1
    End If
    
    If Hour(Now) = 14 Then
        frmServer.txtEventoEXP.Text = "2"
        frmServer.txtEventHour.Text = "15"
        '###########
        GlobalMsg "Evento Ativo!! Agora você ganha " & frmServer.txtEventoEXP.Text & " vezes mais de EXP!Aproveite,OhYehGames.", BrightCyan
        GlobalMsg "Evento ativo até as :" & frmServer.txtEventHour & " horas", White
        frmServer.chkEventActive.Value = YES
        EventoExpCount = 2
    End If
    
    If Hour(Now) = 20 Then
        
        If Weekday(Now) = 1 Or Weekday(Now) = 6 Or Weekday(Now) = 7 Then 'final de semana
            frmServer.txtEventoEXP.Text = "3"
        Else
            frmServer.txtEventoEXP.Text = "2" 'dia normal
        End If
            
        frmServer.txtEventHour.Text = "22"
        '###########
        GlobalMsg "Evento Ativo!! Agora você ganha " & frmServer.txtEventoEXP.Text & " vezes mais de EXP!Aproveite,OhYehGames.", BrightCyan
        GlobalMsg "Evento ativo até as :" & frmServer.txtEventHour & " horas", White
        frmServer.chkEventActive.Value = YES
        EventoExpCount = 0
        
        If Weekday(Now) = 7 Or Weekday(Now) = 1 Then
            SorteOHYEH
        End If
    End If
    
End Sub

Public Sub WarpFrente(ByVal index As Long, ByVal Direcao As Byte, ByVal Dist As Long)
Dim i As Long
Dim novaDist As Long
Dim lastDist As Long
Dim Y As Long
Dim X As Long
Dim mapNum As Long

If IsPlaying(index) = False Then Exit Sub
If Dist < 1 Then Exit Sub

X = GetPlayerX(index)
Y = GetPlayerY(index)
mapNum = GetPlayerMap(index)

If Map(mapNum).Moral = MAP_MORAL_SAFE Then Exit Sub

Select Case Direcao
    Case DIR_DOWN
        For i = 1 To Dist
            If IsBlocked(index, X, Y + novaDist, DIR_DOWN) = NO Then
                novaDist = novaDist + 1
            Else
                novaDist = novaDist - 1
                Exit For
            End If
        Next
        
        If novaDist < 1 Then Exit Sub
        
        lastDist = Y + novaDist
        
        If lastDist > Map(mapNum).MaxY Then lastDist = Map(mapNum).MaxY
        
        SetPlayerY index, lastDist
        
        
    Case DIR_UP
        For i = 1 To Dist
            If IsBlocked(index, X, Y - novaDist, DIR_UP) = NO Then
                novaDist = novaDist + 1
            Else
                novaDist = novaDist - 1
                Exit For
            End If
        Next
        
        If novaDist < 1 Then Exit Sub
        
        lastDist = Y - novaDist
        
        If lastDist < 0 Then lastDist = 0
        
        SetPlayerY index, lastDist
        
    Case DIR_LEFT
        For i = 1 To Dist
            If IsBlocked(index, X - novaDist, Y, DIR_LEFT) = NO Then
                novaDist = novaDist + 1
            Else
                novaDist = novaDist - 1
                Exit For
            End If
        Next
        
        If novaDist < 1 Then Exit Sub
        
        lastDist = X - novaDist
        
        If lastDist < 0 Then lastDist = 0
        
        SetPlayerX index, lastDist
        
    Case DIR_RIGHT
        For i = 1 To Dist
            If IsBlocked(index, X + novaDist, Y, DIR_LEFT) = NO Then
                novaDist = novaDist + 1
            Else
                novaDist = novaDist - 1
                Exit For
            End If
        Next
        
        If novaDist < 1 Then Exit Sub
        
        lastDist = X + novaDist
        
        If lastDist > Map(mapNum).MaxX Then lastDist = Map(mapNum).MaxX
        
        SetPlayerX index, lastDist
        
    Case Else
End Select

SendPlayerXYToMap index

End Sub

Public Sub ZerarTorneioData()
Dim i As Long

For i = 1 To MAX_PLAYERS
    TorneioData.Participante(i) = NO
    TorneioData.pUsados(i) = NO
Next

TorneioData.pTotal = NO

End Sub

Public Sub TirarTorneioData(ByVal index As Long)
Dim i As Long

If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If GetPlayerAccess(index) >= ADMIN_MONITOR Then Exit Sub
    
For i = 1 To Player_HighIndex
    If TorneioData.Participante(i) = index Then
        TorneioData.Participante(i) = NO
        TorneioData.pUsados(i) = NO
        If TorneioData.pTotal > 0 Then
            TorneioData.pTotal = TorneioData.pTotal - 1
        Else
            TorneioData.pTotal = NO
        End If
        
        'VERIFICA SE O TORNEIO ACABO
        If Player(index).InTorneio = TORNEIO_DESAFIOS Then
            If GetPlayerMap(index) >= 230 And GetPlayerMap(index) <= 238 Then
                TempPlayer(index).npcsMortos = NO
                If frmServer.chkTorneioStatus.Value = NO Then 'se tiver desativado é pq ja começou
                    If TorneioData.pTotal <= 0 Then AtualizarEvento 'evita que passe pro proximo desafio
                End If
            End If
        End If
        
        Exit Sub
    End If
Next

End Sub

Public Sub ColocarTorneioData(ByVal index As Long)
Dim i As Long

If IsPlaying(index) = False Then Exit Sub
If GetPlayerAccess(index) >= ADMIN_MONITOR Then Exit Sub

For i = 1 To Player_HighIndex
    If TorneioData.Participante(i) = index Then
        PlayerMsg index, "Você já está listado!", BrightRed
        Exit Sub
    End If
Next

For i = 1 To Player_HighIndex
    If TorneioData.Participante(i) = NO Then
        TorneioData.Participante(i) = index
        TorneioData.pUsados(i) = NO
        TorneioData.pTotal = TorneioData.pTotal + 1
        Exit Sub
    End If
Next

End Sub

Public Sub SortearEchi()
Dim i As Long
Dim escolha As Long
If GetTotalMapPlayers(296) < 2 Then Exit Sub

escolha = RAND(1, Player_HighIndex)
If escolha < 1 Or escolha > Player_HighIndex Then Exit Sub

If IsPlaying(escolha) = False Or GetPlayerMap(escolha) <> 296 Or GetPlayerAccess(escolha) > 1 Then
    SortearEchi
    Exit Sub
End If

PlayerEchi = escolha
TempPlayer(PlayerEchi).Contagem = 6
SendAnimation 296, 20, GetPlayerX(PlayerEchi), GetPlayerY(PlayerEchi)
Player(PlayerEchi).PKstate = 2
SendPlayerData PlayerEchi

MapMsg 296, "ÉCHI SORTEADO:" & GetPlayerName(escolha) & "!", White
PlayerMsg escolha, "Quanto mais poquemãos você caçar,mais CASH irá receber :D", White

End Sub

Public Function JutsuEspecialErrado(ByVal index As Long, ByVal Order As Byte) As Byte
Dim i As Byte

JutsuEspecialErrado = NO

If Order < 1 Then Exit Function
If IsPlaying(index) = False Then Exit Function
If Player(index).Rank <> RANK_KAGE And Player(index).Org = NO Then Exit Function

Select Case Order
    Case 1 'ORG
        If Player(index).Org > 0 Then
            For i = 1 To MAX_PLAYER_SPELLS
                Select Case Player(index).Org
                    Case ORG_TAKA, ORG_7ESPADACHINS, ORG_AKATSUKI, ORG_ANBURAIZ, ORG_12GUARDIOES
                        If GetClassStat(GetPlayerClass(index)) = Stats.strength Then
                            If Player(index).Spell(i) = 136 Or Player(index).Spell(i) = 138 Or Player(index).Spell(i) = 139 Then
                                Player(index).Spell(i) = NO
                                JutsuEspecialErrado = YES
                                'Exit Function
                            End If
                        Else 'nin
                            If Player(index).Spell(i) = 137 Or Player(index).Spell(i) = 140 Or Player(index).Spell(i) = 141 Then
                                Player(index).Spell(i) = NO
                                JutsuEspecialErrado = YES
                                'Exit Function
                            End If
                        End If
                    Case Else
                End Select
            Next
        End If
    
    Case 2 'KAGE
        For i = 1 To MAX_PLAYER_SPELLS
            If Player(index).Rank = RANK_KAGE Then
                If GetClassStat(GetPlayerClass(index)) = Stats.strength Then
                    If Player(index).Spell(i) = 143 Then
                        Player(index).Spell(i) = NO
                        JutsuEspecialErrado = YES
                        'Exit Function
                    End If
                Else 'nin
                    If Player(index).Spell(i) = 142 Then
                        Player(index).Spell(i) = NO
                        JutsuEspecialErrado = YES
                        'Exit Function
                    End If
                End If
            End If
        Next
    End Select
    
End Function
Public Sub AtualizarJutsuEspecial(ByVal index As Long)

If IsPlaying(index) = False Then Exit Sub
If Player(index).Rank <> RANK_KAGE And Player(index).Org = NO Then Exit Sub

If JutsuEspecialErrado(index, 1) = YES Then 'org
    Select Case Player(index).Org
        Case ORG_TAKA, ORG_7ESPADACHINS, ORG_AKATSUKI, ORG_ANBURAIZ, ORG_12GUARDIOES
        
                If GetClassStat(GetPlayerClass(index)) = Stats.strength Then
                    Select Case RAND(1, 3)
                        Case 1
                            SetPlayerSpell index, FindOpenSpellSlot(index), 137
                            PlayerMsg index, "Você aprendeu " & Spell(137).Name, BrightBlue
                        Case 2
                            SetPlayerSpell index, FindOpenSpellSlot(index), 140
                            PlayerMsg index, "Você aprendeu " & Spell(140).Name, BrightBlue
                        Case 3
                            SetPlayerSpell index, FindOpenSpellSlot(index), 141
                            PlayerMsg index, "Você aprendeu " & Spell(141).Name, BrightBlue
                    End Select
                End If
                
                If GetClassStat(GetPlayerClass(index)) = Stats.Intelligence Then
                    Select Case RAND(1, 3)
                        Case 1
                            SetPlayerSpell index, FindOpenSpellSlot(index), 136
                            PlayerMsg index, "Você aprendeu " & Spell(136).Name, BrightBlue
                        Case 2
                            SetPlayerSpell index, FindOpenSpellSlot(index), 138
                            PlayerMsg index, "Você aprendeu " & Spell(138).Name, BrightBlue
                        Case 3
                            SetPlayerSpell index, FindOpenSpellSlot(index), 139
                            PlayerMsg index, "Você aprendeu " & Spell(139).Name, BrightBlue
                    End Select
                
                End If
           
        Case Else
    End Select
End If

If JutsuEspecialErrado(index, 2) = YES Then 'kage
    If Player(index).Rank = RANK_KAGE Then
        If GetClassStat(GetPlayerClass(index)) = Stats.strength Then 'tai
            SetPlayerSpell index, FindOpenSpellSlot(index), 142
            PlayerMsg index, "Você aprendeu " & Spell(142).Name, BrightBlue
        Else 'nin
            SetPlayerSpell index, FindOpenSpellSlot(index), 143
            PlayerMsg index, "Você aprendeu " & Spell(143).Name, BrightBlue
        End If
    End If
End If

End Sub

Public Sub AtualizarEvento()
Dim i As Long
Dim p1 As Long
Dim p2 As Long
Dim p3 As Long
Dim n As Long
Dim u As Long

If Torneio = NO Then Exit Sub

Select Case Torneio
    Case TORNEIO_GUERRA
        GlobalMsg TorneioData.pTotal & " players restando.", White
        
        If War.PlayerCount(1) > 0 And War.PlayerCount(2) > 0 Then Exit Sub 'ainda não há vencedor
        
        '##SE HOUVER GANHADOR,FINALIZA SAPOHA :D
        If War.Pts(1) > War.Pts(2) Then 'Bem ganho
            GlobalMsg "ALIANÇA SHINOBI GANHOU(" & War.Pts(1) & " pts)!!", White
            If War.Killer(1) > 0 Then
                GlobalMsg "Destaque(AliançaShinobi):" & GetPlayerName(War.Killer(1)) & "(" & Player(War.Killer(1)).WarPoints & " pts)", BrightCyan
                GiveInvItem War.Killer(1), 254, 3000
                PlayerMsg War.Killer(1), "Bonus por ser destaque: 3K CASH!", Yellow
            End If
            
            For i = 1 To Player_HighIndex
                If Player(i).War = 1 Then 'bem
                    If Player(i).WarPoints >= 3 Then
                        GiveInvItem i, 254, 1000, True
                        PlayerMsg i, "Você ganhou 1k CASH por sua bravura na guerra Shinobi!", White
                    Else
                        PlayerMsg i, "Você não fez muita diferença na batalha,que decepção..", Red
                    End If
                    
                    PlayerWarp i, 297, 7, 7
                End If
            Next
        Else 'Mal ganho
            GlobalMsg "TSUKI NO ME GANHOU(" & War.Pts(2) & " pts)!!", BrightRed
            If War.Killer(2) > 0 Then
                GlobalMsg "Destaque(TsukiNoMe):" & GetPlayerName(War.Killer(2)) & "(" & Player(War.Killer(2)).WarPoints & " pts)", BrightCyan
                GiveInvItem War.Killer(2), 254, 3000
                PlayerMsg War.Killer(2), "Bonus por ser destaque: 3K CASH!", Yellow
            End If
            
            For i = 1 To Player_HighIndex
                If Player(i).War = 2 Then 'mal
                    If Player(i).WarPoints >= 3 Then
                        GiveInvItem i, 254, 1000, True
                        PlayerMsg i, "Você ganhou 1k CASH por sua bravura na guerra Shinobi!", White
                    Else
                        PlayerMsg i, "Você não fez muita diferença na batalha,que decepção..", Red
                    End If
                    
                    PlayerWarp i, 297, 7, 7
                End If
            Next
        End If
        
        For i = 1 To Player_HighIndex
            If Player(i).WarPoints > 0 Then
                PlayerMsg i, "Você fechou a guerra com a seguinte pontuação:" & Player(i).WarPoints, White
            End If
            
            Player(i).WarPoints = NO
        Next
        
        War.Killer(1) = NO
        War.Killer(2) = NO
        War.Pts(1) = NO
        War.Pts(2) = NO
        War.PlayerCount(1) = NO
        War.PlayerCount(2) = NO
        
        Torneio = NO
        frmServer.lstTorneios.ListIndex = NO
        frmServer.chkTorneioStatus.Value = NO
        ZerarLutas
        ZerarTorneioData
        
    Case TORNEIO_POKEMON
        GlobalMsg TorneioData.pTotal & " players restando.", White
        
        If PlayerEchi = NO Then
            SortearEchi
        End If
        
        If TorneioData.pTotal <= 6 Then
            PlayerEchi = NO
        
            For i = 1 To Player_HighIndex
                If IsPlaying(i) Then
                    If GetPlayerMap(i) = 296 Then 'temos que pegar
                        If Player(i).PKstate = 1 Then 'poquemão
                            GiveInvItem i, 254, 1000, True '1k cash
                            PlayerMsg i, "Você ganhou " & 1000 & " CASH por ser um poquemão raro!", Yellow
                            Player(i).InTorneio = NO
                            Player(i).PKstate = NO
                            PlayerWarp i, 99, 10, 6 'Atendimento
                        ElseIf Player(i).PKstate = 2 Then 'echí
                            PlayerMsg i, "Ótima caçada oh mestre treinador.", White
                            Player(i).InTorneio = NO
                            Player(i).PKstate = NO
                            PlayerWarp i, 99, 10, 6 'Atendimento
                        End If
                    End If
                End If
            Next
            
            Torneio = NO
            frmServer.lstTorneios.ListIndex = NO
            frmServer.chkTorneioStatus.Value = NO
            ZerarLutas
            ZerarTorneioData
            GlobalMsg "Evento temos que pegar acabou!", Green
        End If
        
    Case TORNEIO_DESAFIOS
        
        If TorneioData.pTotal <= 0 Then
            GlobalMsg "Ninguém chegou até o final dos desafios :/", Pink
            
            For i = 1 To Player_HighIndex
                TempPlayer(i).npcsMortos = NO
                Player(i).InTorneio = NO
            Next
            
            desafioNum = 0
            Torneio = NO
            frmServer.lstTorneios.ListIndex = NO
            frmServer.chkTorneioStatus.Value = NO
            ZerarLutas
            ZerarTorneioData
            GlobalMsg "Evento dos Desafios acabou!", Green
            Exit Sub
        End If
        
        Select Case desafioNum
            Case 0
                n = 0
                
                GlobalMsg "Evento dos Desafios foi iniciado com " & TorneioData.pTotal & " participantes.", Yellow
                
                desafioNum = 1
                
                For i = 1 To Player_HighIndex
                    If TorneioData.Participante(i) > 0 Then
                        SetPlayerDir TorneioData.Participante(i), DIR_LEFT
                        PlayerWarp TorneioData.Participante(i), 230, 40, RAND(6, 9) 'vai pro 1° desafio
                    End If
                Next
                
            Case 1
                n = 0
                
                For i = 1 To MAX_MAP_NPCS
                    If MapNpc(230).Npc(i).Vital(Vitals.HP) > 0 Then
                        n = n + 1
                    End If
                Next
                
                If n = 0 Then
                    desafioNum = 2
                    
                    MapMsg 230, "Vocês passaram do 1° desafio! Indo agora para o próximo..", BrightGreen
                    
                    For i = 1 To Player_HighIndex
                        If IsPlaying(i) Then
                            If GetPlayerMap(i) = 230 Then
                                SetPlayerDir i, DIR_UP
                                PlayerWarp i, 231, RAND(0, 19), 30 'vai pro 2°
                            End If
                        End If
                    Next
                    
                    AtualizarEvento
                Else
                    MapMsg 230, "Resta(m) " & n & " npcs!", White
                End If
            
            Case 2
                n = 0
                
                For i = 1 To MAX_MAP_NPCS
                    If MapNpc(231).Npc(i).Vital(Vitals.HP) > 0 Then
                        n = n + 1
                    End If
                Next
                
                If n = 0 Then
                    desafioNum = 3
                    
                    MapMsg 231, "Vocês passaram do 2° desafio! Indo agora para o próximo..", BrightGreen
                    
                    For i = 1 To Player_HighIndex
                        If IsPlaying(i) Then
                            If GetPlayerMap(i) = 231 Then
                                SetPlayerDir i, DIR_UP
                                PlayerWarp i, 232, RAND(0, 19), 30 'vai pro 3°
                            End If
                        End If
                    Next
                    
                    AtualizarEvento
                Else
                    MapMsg 231, "Resta(m) " & n & " npcs!", White
                End If
            
            Case 3
                n = 0
                
                For i = 1 To MAX_MAP_NPCS
                    If MapNpc(232).Npc(i).Vital(Vitals.HP) > 0 Then
                        n = n + 1
                    End If
                Next
                
                If n = 0 Then
                    desafioNum = 4
                    
                    MapMsg 232, "Vocês passaram do 3° desafio! Indo agora para o próximo..", BrightGreen
                    
                    For i = 1 To Player_HighIndex
                        If IsPlaying(i) Then
                            If GetPlayerMap(i) = 232 Then
                                SetPlayerDir i, DIR_UP
                                PlayerWarp i, 233, RAND(0, 28), 30 'vai pro 4°
                            End If
                        End If
                    Next
                    
                    AtualizarEvento
                Else
                    MapMsg 232, "Resta(m) " & n & " npcs!", White
                End If
                
            Case 4
                n = 0
                
                For i = 1 To MAX_MAP_NPCS
                    If MapNpc(233).Npc(i).Vital(Vitals.HP) > 0 Then
                        n = n + 1
                    End If
                Next
                
                If n = 0 Then
                    desafioNum = 5
                    
                    MapMsg 233, "Vocês passaram do 4° desafio! Indo agora para o próximo..", BrightGreen
                    
                    For i = 1 To Player_HighIndex
                        If IsPlaying(i) Then
                            If GetPlayerMap(i) = 233 Then
                                SetPlayerDir i, DIR_UP
                                PlayerWarp i, 234, RAND(0, 15), 30 'vai pro 4°
                            End If
                        End If
                    Next
                    
                    AtualizarEvento
                Else
                    MapMsg 233, "Resta(m) " & n & " npcs!", White
                End If
            
            Case 5
                n = 0
                
                For i = 1 To MAX_MAP_NPCS
                    If MapNpc(234).Npc(i).Vital(Vitals.HP) > 0 Then
                        n = n + 1
                    End If
                Next
                
                If n = 0 Then
                    desafioNum = 6
                    
                    MapMsg 234, "Vocês passaram do 5° desafio! Indo agora para o Desafio Final!!!", BrightGreen
                    
                    For i = 1 To Player_HighIndex
                        If IsPlaying(i) Then
                            If GetPlayerMap(i) = 234 Then
                                Select Case RAND(1, 4)
                                    Case 1 'pains
                                        SetPlayerDir i, DIR_UP
                                        PlayerWarp i, 235, RAND(0, 30), 60
                                    Case 2 'juubi
                                        SetPlayerDir i, DIR_UP
                                        PlayerWarp i, 236, RAND(0, 25), 20
                                    Case 3 'yugito
                                        SetPlayerDir i, DIR_UP
                                        PlayerWarp i, 237, RAND(0, 40), 13
                                    Case 4 'tobi
                                        SetPlayerDir i, DIR_UP
                                        PlayerWarp i, 238, RAND(1, 24), 38
                                    Case Else
                                End Select
                            End If
                        End If
                    Next
                    
                    AtualizarEvento
                Else
                    MapMsg 234, "Resta(m) " & n & " npcs!", White
                End If
                
            Case 6 'final limpa os dados
                For i = 1 To MAX_LIMIT_TIP
                    SemTip(i) = vbNullString
                Next
                
                For i = 1 To Player_HighIndex
                    If IsPlaying(i) Then
                        If TempPlayer(i).npcsMortos >= 3 And Player(i).InTorneio = TORNEIO_DESAFIOS Then
                            Player(i).InTorneio = NO
                            GiveInvItem i, 254, 500, True ' cash
                            PlayerMsg i, "Você ganhou 500 CASH's por ter derrotado " & TempPlayer(i).npcsMortos & " npcs!", Yellow
                        Else
                            If Player(i).InTorneio = TORNEIO_DESAFIOS Then PlayerMsg i, "Você não obteve a quantidade minima de npcs derrotados para conseguir a recompensa. Você fez: " & TempPlayer(i).npcsMortos & " pontos!", BrightRed
                        End If
                    End If
                Next
                
                desafioNum = 0
                Torneio = NO
                frmServer.lstTorneios.ListIndex = NO
                frmServer.chkTorneioStatus.Value = NO
                ZerarLutas
                ZerarTorneioData
                GlobalMsg "Evento dos Desafios finalizado!", Green
            Case Else
                GlobalMsg "nada ainda", BrightRed
        End Select
                
    Case TORNEIO_KAGE_KONOHA, TORNEIO_KAGE_SUNA, TORNEIO_KAGE_KIRI, TORNEIO_KAGE_IWA, TORNEIO_KAGE_KUMO, TORNEIO_KAGE_CHUVA, TORNEIO_KAGE_SOM
        ZerarLutas
        
        n = 0
        
        If TorneioData.pTotal < 1 Then
            GlobalMsg "Não tem nenhum participante. Se tiver kage ONLINE(só ganha se estiver on) ele manteve", White
            n = encontrarKage()
            If IsPlaying(n) = True Then 'se ta on
                SetarRank n, RANK_KAGE
            End If
            Torneio = NO
            frmServer.lstTorneios.ListIndex = NO
            frmServer.chkTorneioStatus.Value = NO
            ZerarLutas
            ZerarTorneioData
            SegundosLuta = NO
            For i = 1 To MAX_LIMIT_TIP
                SemTip(i) = vbNullString
            Next
            Exit Sub
        End If
        
        For i = 1 To Player_HighIndex
            If TorneioData.Participante(i) > 0 Then
                If GetPlayerMap(TorneioData.Participante(i)) = 98 Then 'se tiver na sala de espera
                    n = n + 1
                End If
            End If
        Next
        
        Select Case n
            Case 0 'quando não tem mais participantes na sala de espera principal, chama a sala de espera2 ou o kage mantem
            
                n = 0
                
                For i = 1 To Player_HighIndex 'verifica a sala de espera 2
                    If TorneioData.Participante(i) > 0 Then
                        If GetPlayerMap(TorneioData.Participante(i)) = 95 Then 'se tiver na sala de 2
                            n = n + 1
                            PlayerWarp TorneioData.Participante(i), 98, 7, 7 'teleporta pra sala de espera principal
                        End If
                    End If
                Next
                
                If n > 0 Then
                    GlobalMsg "Proxima rodada começou..", Magenta
                    SegundosParaAtualizarEvento = 1 'ativa o contador
                    Exit Sub
                End If
                
                If n < 1 Then 'significa que não tinha ninguem na sala de espera 2
                    GlobalMsg "Não tinha ninguem na sala de espera 2..Se tiver kage ONLINE(só ganha se estiver on) ele manteve.", White
                    u = encontrarKage()
                    
                    If IsPlaying(u) = True Then
                        If Player(u).Rank = RANK_DESERTOR Then
                            If Torneio = TORNEIO_KAGE_CHUVA Then Player(u).Vila = 0
                            If Torneio = TORNEIO_KAGE_SOM Then Player(u).Vila = 6
                        End If
                        SetarRank u, RANK_KAGE
                    End If
                    
                    Torneio = NO
                    frmServer.lstTorneios.ListIndex = NO
                    frmServer.chkTorneioStatus.Value = NO
                    ZerarLutas
                    ZerarTorneioData
                    SegundosLuta = NO
                    For i = 1 To MAX_LIMIT_TIP
                        SemTip(i) = vbNullString
                    Next
                    Exit Sub
                End If
                
            Case 1 'se tiver desafiante ou acontece a luta final se o kage tiver on ou ele é o novo kage ou puxa a sala de espera 2
                p1 = 0
                p2 = 0
                
                p1 = encontrarKage()
                
                n = 0
                
                For i = 1 To Player_HighIndex
                    If TorneioData.Participante(i) > 0 Then
                        If GetPlayerMap(TorneioData.Participante(i)) = 98 Then
                            p2 = TorneioData.Participante(i)
                        End If
                    End If
                Next
                
                If kageLutou = YES Then
                    GlobalMsg GetPlayerName(p2) & " é o novo KAGE!", Yellow
                    
                    If IsPlaying(p2) Then
                        If Player(p2).Rank = RANK_DESERTOR Then
                            If Torneio = TORNEIO_KAGE_CHUVA Then Player(p2).Vila = 0
                            If Torneio = TORNEIO_KAGE_SOM Then Player(p2).Vila = 6
                        End If
                    End If
                    
                    SetarRank p2, RANK_KAGE
                    
                    Torneio = NO
                    frmServer.lstTorneios.ListIndex = NO
                    frmServer.chkTorneioStatus.Value = NO
                    ZerarLutas
                    ZerarTorneioData
                    SegundosLuta = NO
                    For i = 1 To MAX_LIMIT_TIP
                        SemTip(i) = vbNullString
                    Next
                    
                    Exit Sub
                End If
                
                For i = 1 To Player_HighIndex 'verifica a sala de espera 2
                    If TorneioData.Participante(i) > 0 Then
                        If GetPlayerMap(TorneioData.Participante(i)) = 95 Then 'se tiver na sala de 2
                            n = n + 1
                            PlayerWarp TorneioData.Participante(i), 98, 7, 7 'teleporta pra sala de espera principal
                        End If
                    End If
                Next
                
                If p2 > 0 Then
                    If n > 0 Then 'se tiver sala de espera 2 é pq ele não conseguiu uma luta
                        GlobalMsg "Não existe luta para o " & GetPlayerName(p2) & ", seu oponente saiu.", White
                        SegundosParaAtualizarEvento = 1 'ativa o contador
                        Exit Sub
                    End If
                End If
                
                If p1 > 0 Then
                    If p2 > 0 Then 'se os 2 tiverem on, eles lutam
                        GlobalMsg "LUTA FINAL! ATUAL KAGE VS DESAFIANTE!", Yellow
                        Luta.PlayerQnt = 2
                        Luta.Player(3) = NO
                        
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
                        'anunciamento
                        GlobalMsg GetPlayerName(p1) & "(" & GetClassName(GetPlayerClass(p1)) & "-Lvl." & GetPlayerLevel(p1) & ") X " & GetPlayerName(p2) & "(" & GetClassName(GetPlayerClass(p2)) & "-Lvl." & GetPlayerLevel(p2) & ")", White
                
                        SegundosLuta = 1 'começa a contagem
                        kageLutou = YES 'marca que ele ja lutou
                    Else
                        GlobalMsg "Tem kage mas não tem participante. Ele manteve(estranho).", BrightRed
                        u = encontrarKage()
                        
                        If IsPlaying(u) = True Then
                            SetarRank u, RANK_KAGE
                        End If
                        
                        Torneio = NO
                        frmServer.lstTorneios.ListIndex = NO
                        frmServer.chkTorneioStatus.Value = NO
                        ZerarLutas
                        ZerarTorneioData
                        SegundosLuta = NO
                        For i = 1 To MAX_LIMIT_TIP
                            SemTip(i) = vbNullString
                        Next
                        Exit Sub
                    End If
                Else
                    GlobalMsg "O kage não ta online.", White
                    If p2 > 0 Then
                        GlobalMsg "Se o kage ta offline," & GetPlayerName(p2) & " é o novo kage!", White
                        
                        If IsPlaying(p2) Then
                            If Player(p2).Rank = RANK_DESERTOR Then
                                If Torneio = TORNEIO_KAGE_CHUVA Then Player(p2).Vila = 0
                                If Torneio = TORNEIO_KAGE_SOM Then Player(p2).Vila = 6
                            End If
                        End If
                        
                        SetarRank p2, RANK_KAGE
                        
                        Torneio = NO
                        frmServer.lstTorneios.ListIndex = NO
                        frmServer.chkTorneioStatus.Value = NO
                        ZerarLutas
                        ZerarTorneioData
                        SegundosLuta = NO
                        For i = 1 To MAX_LIMIT_TIP
                            SemTip(i) = vbNullString
                        Next
                        Exit Sub
                    Else
                        GlobalMsg "Não tem kage e não tem participante!", White
                        
                        Torneio = NO
                        frmServer.lstTorneios.ListIndex = NO
                        frmServer.chkTorneioStatus.Value = NO
                        ZerarLutas
                        ZerarTorneioData
                        SegundosLuta = NO
                        For i = 1 To MAX_LIMIT_TIP
                            SemTip(i) = vbNullString
                        Next
                        Exit Sub
                    End If
                End If
        
            Case 3  'manda os 3
                p1 = 0
                p2 = 0
                p3 = 0
                
                For i = 1 To Player_HighIndex
                    If TorneioData.Participante(i) > 0 And p1 = 0 Then
                        If GetPlayerMap(TorneioData.Participante(i)) = 98 Then p1 = TorneioData.Participante(i)
                    End If
                    
                    If TorneioData.Participante(i) > 0 And TorneioData.Participante(i) <> p1 And p2 = 0 Then
                        If GetPlayerMap(TorneioData.Participante(i)) = 98 Then p2 = TorneioData.Participante(i)
                    End If
                    
                    If TorneioData.Participante(i) > 0 And TorneioData.Participante(i) <> p1 And TorneioData.Participante(i) <> p2 And p3 = 0 Then
                        If GetPlayerMap(TorneioData.Participante(i)) = 98 Then p3 = TorneioData.Participante(i)
                    End If
                Next
                
                If p1 < 1 Then
                    GlobalMsg "O jogador 1 não consta.", BrightRed
                    Exit Sub
                End If
                
                If p2 < 1 Then
                    GlobalMsg "O jogador 2 não consta.", BrightRed
                    Exit Sub
                End If
                
                If p3 < 1 Then
                    GlobalMsg "O jogador 3 não consta.", BrightRed
                    Exit Sub
                End If
                
                Luta.PlayerQnt = 3
                Luta.Player(1) = p1
                Luta.Player(2) = p2
                Luta.Player(3) = p3
                'DIR
                SetPlayerDir p1, DIR_RIGHT
                SetPlayerDir p2, DIR_LEFT
                SetPlayerDir p3, DIR_DOWN
                'Warp
                PlayerWarp p1, 100, 1, 12
                PlayerWarp p2, 100, 29, 12
                PlayerWarp p3, 100, 15, 1
                'Contagem
                TempPlayer(p1).Contagem = 6
                TempPlayer(p2).Contagem = 6
                TempPlayer(p3).Contagem = 6
                'anunciamento
                GlobalMsg GetPlayerName(p1) & "(" & GetClassName(GetPlayerClass(p1)) & "-Lvl." & GetPlayerLevel(p1) & ") X " & GetPlayerName(p2) & "(" & GetClassName(GetPlayerClass(p2)) & "-Lvl." & GetPlayerLevel(p2) & ") X " & GetPlayerName(p3) & "(" & GetClassName(GetPlayerClass(p3)) & "-Lvl." & GetPlayerLevel(p3) & ")", White
                
                SegundosLuta = 1 'começa a contagem
                
            Case Else 'luta normal
                
                p1 = 0
                p2 = 0
                
                For i = 1 To Player_HighIndex
                    If TorneioData.Participante(i) > 0 Then
                        If TorneioData.Participante(i) <> p1 Then
                            If p1 = 0 Then 'ninguem
                                If GetPlayerMap(TorneioData.Participante(i)) = 98 Then p1 = TorneioData.Participante(i)
                            Else
                                If GetPlayerLevel(TorneioData.Participante(i)) <= GetPlayerLevel(p1) Then
                                    If GetPlayerMap(TorneioData.Participante(i)) = 98 Then p1 = TorneioData.Participante(i)
                                End If
                            End If
                        End If
                    End If
                Next
                
                For i = 1 To Player_HighIndex
                    If TorneioData.Participante(i) > 0 Then
                        If TorneioData.Participante(i) <> p1 And TorneioData.Participante(i) <> p2 Then
                            If p2 = 0 Then 'ninguem
                                If GetPlayerMap(TorneioData.Participante(i)) = 98 Then p2 = TorneioData.Participante(i)
                            Else
                                If GetPlayerLevel(TorneioData.Participante(i)) >= GetPlayerLevel(p1) And GetPlayerLevel(TorneioData.Participante(i)) <= GetPlayerLevel(p2) Then
                                    If GetPlayerMap(TorneioData.Participante(i)) = 98 Then p2 = TorneioData.Participante(i)
                                End If
                            End If
                        End If
                    End If
                Next
                
                If p1 < 1 Then
                    GlobalMsg "O jogador 1 não consta.", BrightRed
                    Exit Sub
                End If
                
                If p2 < 1 Then
                    GlobalMsg "O jogador 2 não consta.", BrightRed
                    Exit Sub
                End If
                
                Luta.PlayerQnt = 2
                Luta.Player(3) = NO
                
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
                'anunciamento
                GlobalMsg GetPlayerName(p1) & "(" & GetClassName(GetPlayerClass(p1)) & "-Lvl." & GetPlayerLevel(p1) & ") X " & GetPlayerName(p2) & "(" & GetClassName(GetPlayerClass(p2)) & "-Lvl." & GetPlayerLevel(p2) & ")", White
        
                SegundosLuta = 1 'começa a contagem
        End Select
    
    Case TORNEIO_LUTA, TORNEIO_CS
        ZerarLutas
        
        Select Case TorneioData.pTotal
            Case 0
                Torneio = NO
                frmServer.lstTorneios.ListIndex = NO
                frmServer.chkTorneioStatus.Value = NO
                ZerarLutas
                ZerarTorneioData
                GlobalMsg "Torneio foi finalizado. Parabéns a todos.", Green
                SegundosLuta = NO
                For i = 1 To MAX_LIMIT_TIP
                    SemTip(i) = vbNullString
                Next
            Case 1
                For i = 1 To MAX_LIMIT_TIP
                    SemTip(i) = vbNullString
                Next
                
                For i = 1 To Player_HighIndex
                    If TorneioData.Participante(i) > 0 Then
                        PlayerMsg TorneioData.Participante(i), "Não há luta para você.", Red
                        GlobalMsg "Torneio acabou." & GetPlayerName(TorneioData.Participante(i)) & " ganhou por não haver oponentes.", Pink
                        GiveInvItem TorneioData.Participante(i), 254, 300, True
                        PlayerMsg TorneioData.Participante(i), "300 CASH!", Yellow
                        Torneio = NO
                        Player(TorneioData.Participante(i)).InTorneio = NO
                        frmServer.lstTorneios.ListIndex = NO
                        frmServer.chkTorneioStatus.Value = NO
                        SegundosLuta = NO
                        Atendimento TorneioData.Participante(i)
                        ZerarTorneioData
                        ZerarLutas
                        Exit Sub
                    End If
                Next
        
            Case 3  'manda os 3
                For i = 1 To Player_HighIndex
                    If TorneioData.Participante(i) > 0 And p1 = 0 Then
                        p1 = TorneioData.Participante(i)
                    End If
                    
                    If TorneioData.Participante(i) > 0 And TorneioData.Participante(i) <> p1 And p2 = 0 Then
                        p2 = TorneioData.Participante(i)
                    End If
                    
                    If TorneioData.Participante(i) > 0 And TorneioData.Participante(i) <> p1 And TorneioData.Participante(i) <> p2 And p3 = 0 Then
                        p3 = TorneioData.Participante(i)
                    End If
                Next
                
                Luta.PlayerQnt = 3
                Luta.Player(1) = p1
                Luta.Player(2) = p2
                Luta.Player(3) = p3
                'DIR
                SetPlayerDir p1, DIR_RIGHT
                SetPlayerDir p2, DIR_LEFT
                SetPlayerDir p3, DIR_DOWN
                'Warp
                PlayerWarp p1, 100, 1, 12
                PlayerWarp p2, 100, 29, 12
                PlayerWarp p3, 100, 15, 1
                'Contagem
                TempPlayer(p1).Contagem = 6
                TempPlayer(p2).Contagem = 6
                TempPlayer(p3).Contagem = 6
                'anunciamento
                GlobalMsg GetPlayerName(p1) & "(" & GetClassName(GetPlayerClass(p1)) & "-Lvl." & GetPlayerLevel(p1) & ") X " & GetPlayerName(p2) & "(" & GetClassName(GetPlayerClass(p2)) & "-Lvl." & GetPlayerLevel(p2) & ") X " & GetPlayerName(p3) & "(" & GetClassName(GetPlayerClass(p3)) & "-Lvl." & GetPlayerLevel(p3) & ")", White
                
                SegundosLuta = 1 'começa a contagem
                
            Case Else 'luta normal
                
                For i = 1 To Player_HighIndex
                    If TorneioData.Participante(i) > 0 Then
                        If TorneioData.Participante(i) <> p1 Then
                            If p1 = 0 Then 'ninguem
                                p1 = TorneioData.Participante(i)
                            Else
                                If GetPlayerLevel(TorneioData.Participante(i)) <= GetPlayerLevel(p1) Then
                                    p1 = TorneioData.Participante(i)
                                End If
                            End If
                        End If
                    End If
                Next
                
                For i = 1 To Player_HighIndex
                    If TorneioData.Participante(i) > 0 Then
                        If TorneioData.Participante(i) <> p1 And TorneioData.Participante(i) <> p2 Then
                            If p2 = 0 Then 'ninguem
                                p2 = TorneioData.Participante(i)
                            Else
                                If GetPlayerLevel(TorneioData.Participante(i)) >= GetPlayerLevel(p1) And GetPlayerLevel(TorneioData.Participante(i)) <= GetPlayerLevel(p2) Then
                                    p2 = TorneioData.Participante(i)
                                End If
                            End If
                        End If
                    End If
                Next
                   
                Luta.PlayerQnt = 2
                Luta.Player(3) = NO
                
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
                'anunciamento
                GlobalMsg GetPlayerName(p1) & "(" & GetClassName(GetPlayerClass(p1)) & "-Lvl." & GetPlayerLevel(p1) & ") X " & GetPlayerName(p2) & "(" & GetClassName(GetPlayerClass(p2)) & "-Lvl." & GetPlayerLevel(p2) & ")", White
        
                SegundosLuta = 1 'começa a contagem
        End Select
        
    Case Else 'outros torneios

End Select

End Sub


Public Function ParceiroDesafio(ByVal p1 As Long, ByVal p2 As Long) As Byte
ParceiroDesafio = NO
Dim i As Byte 'desafioanything
Dim meuTime As Byte
Dim arenaNum As Byte

If p1 < 1 Or p1 > Player_HighIndex Then Exit Function
If p2 < 1 Or p2 > Player_HighIndex Then Exit Function
If TempPlayer(p1).InArena <> TempPlayer(p2).InArena Then Exit Function

arenaNum = TempPlayer(p1).InArena
If arenaNum < 1 Or arenaNum > 9 Then Exit Function

meuTime = 0

For i = 1 To 2
    If Arena(arenaNum).p(i) = p1 Or Arena(arenaNum).p(i) = p2 Then
        meuTime = meuTime + 1
        If meuTime = 2 Then
            ParceiroDesafio = YES
            Exit Function
        End If
    End If
Next

meuTime = 0

For i = 1 To 2
    If Arena(arenaNum).p2(i) = p1 Or Arena(arenaNum).p2(i) = p2 Then
        meuTime = meuTime + 1
        If meuTime = 2 Then
            ParceiroDesafio = YES
            Exit Function
        End If
    End If
Next

End Function

Public Function PodeDesafiar(ByVal index As Long) As Byte
    
    PodeDesafiar = NO
    
    If index < 1 Then Exit Function
    
    If IsPlaying(index) = False Then Exit Function
    
    If Player(index).Invisivel = YES Then Exit Function
    
    If Player(index).InTorneio > 0 Then Exit Function
    
    If TempPlayer(index).InArena > 0 Then Exit Function
    
    If GetPlayerAccess(index) > 1 Then Exit Function
    
    If GetPlayerLevel(index) < 100 Then Exit Function
    
    PodeDesafiar = YES
    
End Function

Public Sub criarOrg(ByVal index As Long, ByVal orgNum As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If IsPlaying(index) = False Then Exit Sub
If orgNum < 13 Or orgNum > 100 Then Exit Sub
If Org(orgNum).orgCarregada = YES Then Exit Sub

Org(orgNum).orgCarregada = YES
Org(orgNum).MembrosTotal = 1
Org(orgNum).MembroLogin(1) = GetPlayerLogin(index)
Org(orgNum).MembroNome(1) = GetPlayerName(index)
Org(orgNum).MembroAcesso(1) = 3

Player(index).Org = orgNum
Player(index).OrgAccess = 3

saveOrg orgNum

End Sub
Public Sub saveOrg(ByVal orgNum As Long)
If orgNum < 13 Or orgNum > 100 Then Exit Sub

Dim filename As String
Dim F As Long

filename = App.Path & "\data\orgs\" & orgNum & ".dat"
    
    F = FreeFile
    Open filename For Binary As #F
        Put #F, , Org(orgNum)
    Close #F

End Sub

Public Sub LoadOrg(ByVal index As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If Player(index).Org < 13 Or Player(index).Org > 100 Then Exit Sub

Dim orgNum As Byte
Dim filename As String
Dim F As Long

orgNum = Player(index).Org

If Org(orgNum).orgCarregada = 0 Then
    filename = App.Path & "\data\orgs\" & orgNum & ".dat"
    
    If FileExist(filename, True) = False Then
        GlobalMsg "org não existe", White
        Exit Sub
    End If
    
    F = FreeFile
    Open filename For Binary As #F
        Get #F, , Org(orgNum)
    Close #F
    
    Org(orgNum).orgCarregada = 1
End If
    
End Sub

Public Sub checarOrg(ByVal index As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If Player(index).Org < 13 Or Player(index).Org > 100 Then Exit Sub

Dim orgNum As Byte
Dim i As Byte

orgNum = Player(index).Org

If Org(orgNum).orgCarregada = NO Then LoadOrg index

membrosOnlineOrg index

For i = 1 To MAX_ORG_MEMBERS
    If Trim$(Org(orgNum).MembroLogin(i)) = GetPlayerLogin(index) Then Exit Sub
Next

PlayerMsg index, "Você foi tirado da org enquanto estava offline.", White
Player(index).Org = NO
Player(index).OrgAccess = NO
SendPlayerData index

End Sub

Public Sub tirarMembrosOffline(ByVal index As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If Player(index).Org < 13 Or Player(index).Org > 100 Then Exit Sub

If Player(index).OrgAccess < 2 Then
    PlayerMsg index, "Você não tem acesso pra isso", White
    Exit Sub
End If

Dim orgNum As Byte
Dim i As Byte
Dim OK As Byte

orgNum = Player(index).Org

If Org(orgNum).orgCarregada = NO Then LoadOrg index

For i = 2 To MAX_ORG_MEMBERS
    If Org(orgNum).MembroAcesso(i) > 0 Then
        If AcharLogin(Trim$(Org(orgNum).MembroLogin(i))) = NO Then
            PlayerMsg index, Trim$(Org(orgNum).MembroNome(i)) & " foi tirado da org.", White
            Org(orgNum).MembroAcesso(i) = NO
            Org(orgNum).MembroLogin(i) = vbNullString
            Org(orgNum).MembroNome(i) = vbNullString
            Org(orgNum).MembrosTotal = Org(orgNum).MembrosTotal - 1
            OK = YES
        End If
    End If
Next
        
If OK = YES Then saveOrg orgNum

End Sub

Public Sub setarOrgMembro(ByVal index As Long, ByVal pINDEX As Long)
    PlayerMsg index, "Item desativado", Pink
    Exit Sub
    
    
Dim orgNum As Byte
Dim i As Byte

If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If pINDEX < 1 Or pINDEX > MAX_PLAYERS Then Exit Sub
If Player(index).Org < 13 Or Player(index).Org > 100 Then Exit Sub
If index = pINDEX Then Exit Sub

If Player(index).OrgAccess < 2 Then
    PlayerMsg index, "Você não tem acesso pra isso", White
    Exit Sub
End If

If Player(pINDEX).Org > 0 Then
    PlayerMsg index, "Ele ja esta em uma org.", White
    Exit Sub
End If

orgNum = Player(index).Org

If Org(orgNum).orgCarregada = NO Then
    LoadOrg index
End If

If Org(orgNum).MembrosTotal >= 15 Then
    PlayerMsg index, "Já atingiu o limite de 15 jogadores na org.", White
    Exit Sub
End If

For i = 1 To MAX_ORG_MEMBERS
    If Trim$(Org(orgNum).MembroAcesso(i)) = NO Then
        Org(orgNum).MembroLogin(i) = GetPlayerLogin(pINDEX)
        Org(orgNum).MembroNome(i) = GetPlayerName(pINDEX)
        Org(orgNum).MembroAcesso(i) = 1
        Org(orgNum).MembrosTotal = Org(orgNum).MembrosTotal + 1
        Exit For
    End If
Next

PlayerMsg index, "Agora a org possui: " & Org(orgNum).MembrosTotal & " membros! Limite=15", White

Player(pINDEX).Org = orgNum
Player(pINDEX).OrgAccess = 1 'membro
OrgJutsu pINDEX, orgNum
SendPlayerData pINDEX
saveOrg orgNum

Select Case Player(index).Org
    Case 13 'esquadrao
        PlayerMsg pINDEX, "Você entrou na esquadrão.", Magenta
    Case Else
End Select

End Sub

Public Sub tirarOrgMembro(ByVal index As Long, ByVal pINDEX As Long)

If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If pINDEX < 1 Or pINDEX > MAX_PLAYERS Then Exit Sub
If Player(index).Org < 13 Or Player(index).Org > 100 Then Exit Sub
If index = pINDEX Then Exit Sub

If Player(index).OrgAccess < 2 Then
    PlayerMsg index, "Você não tem acesso pra isso", White
    Exit Sub
End If

If Player(index).OrgAccess <= Player(pINDEX).OrgAccess Then
    PlayerMsg index, "Você não tem acesso pra isso", White
    Exit Sub
End If

If Player(index).Org <> Player(pINDEX).Org Then
    PlayerMsg index, "Vocês precisam ser da mesma org.", White
    Exit Sub
End If

Dim i As Byte
Dim orgNum As Byte

orgNum = Player(index).Org

For i = 1 To MAX_ORG_MEMBERS
    If Trim$(Org(orgNum).MembroLogin(i)) = GetPlayerLogin(pINDEX) Then
        Org(orgNum).MembroLogin(i) = vbNullString
        Org(orgNum).MembroNome(i) = vbNullString
        Org(orgNum).MembroAcesso(i) = NO
        Org(orgNum).MembrosTotal = Org(orgNum).MembrosTotal - 1
        saveOrg orgNum
        Exit For
    End If
Next

Player(pINDEX).Org = NO
Player(pINDEX).OrgAccess = NO
SendPlayerData pINDEX

End Sub

Public Sub setarOrgAcesso(ByVal index As Long, ByVal pINDEX As Long, ByVal AcessoNum As Byte)

If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If pINDEX < 1 Or pINDEX > MAX_PLAYERS Then Exit Sub
If Player(index).Org < 13 Or Player(index).Org > 100 Then Exit Sub
If index = pINDEX Then Exit Sub

If Player(index).OrgAccess < 2 Then
    PlayerMsg index, "Você não tem acesso pra isso", White
    Exit Sub
End If

If Player(index).Org <> Player(pINDEX).Org Then
    PlayerMsg index, "Vocês precisam ser da mesma org.", White
    Exit Sub
End If

If AcessoNum < 1 Then AcessoNum = 1
If AcessoNum > 2 Then AcessoNum = 2

If AcessoNum = 1 Then
    PlayerMsg index, "Agora ele é um membro normal..", White
ElseIf AcessoNum = 2 Then
    PlayerMsg index, "Agora ele é um sub-lider. Ele conseguirá agora colocar e tirar pessoas da org.", White
    PlayerMsg pINDEX, "Agora você é um sub-lider. Você conseguirá agora colocar e tirar pessoas da org.", White
End If

Dim i As Byte
Dim orgNum As Byte

orgNum = Player(index).Org

For i = 1 To MAX_ORG_MEMBERS
    If Trim$(Org(orgNum).MembroLogin(i)) = GetPlayerLogin(pINDEX) Then
        Org(orgNum).MembroAcesso(i) = AcessoNum
        saveOrg orgNum
        Exit For
    End If
Next

Player(pINDEX).OrgAccess = AcessoNum

End Sub

Public Sub membrosOnlineOrg(ByVal index As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If Player(index).Org < 13 Or Player(index).Org > 100 Then Exit Sub

Dim i As Byte
Dim texto As String
texto = Trim(Org(Player(index).Org).MembrosTotal) & " membros na org: "

For i = 1 To MAX_ORG_MEMBERS
    If Org(Player(index).Org).MembroAcesso(i) > 0 Then
        If i > 1 Then texto = texto & ", "
        texto = texto & Trim$(Org(Player(index).Org).MembroNome(i))
    End If
Next

texto = texto & "."

PlayerMsg index, texto, White

End Sub

Public Sub sairOrgPrivada(ByVal index As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If Player(index).Org < 13 Or Player(index).Org > 100 Then Exit Sub

Dim i As Byte
Dim orgNum As Long

orgNum = Player(index).Org

For i = 1 To MAX_ORG_MEMBERS
    If GetPlayerLogin(index) = Trim$(Org(orgNum).MembroLogin(i)) Then
        Org(orgNum).MembroLogin(i) = vbNullString
        Org(orgNum).MembroNome(i) = vbNullString
        Org(orgNum).MembroAcesso(i) = NO
        Org(orgNum).MembrosTotal = Org(orgNum).MembrosTotal - 1
    End If
Next

End Sub

Public Sub RecuperarAposLuta(ByVal index As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If IsPlaying(index) = False Then Exit Sub

Dim i As Byte

For i = 1 To 5
    If TempPlayer(index).Dojutsu(i) > 0 Then
        TempPlayer(index).Dojutsu(i) = 1
    End If
Next

If TempPlayer(index).Reflect > 0 Then TempPlayer(index).Reflect = 1

SetPlayerVital index, Vitals.HP, GetPlayerMaxVital(index, Vitals.HP)
SetPlayerVital index, Vitals.mp, GetPlayerMaxVital(index, Vitals.mp)

SendVital index, Vitals.HP
SendVital index, Vitals.mp

End Sub

Public Function encontrarKage() As Long
    
    Select Case Torneio
        Case TORNEIO_KAGE_CHUVA
            encontrarKage = AcharLogin(GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(0)))
                    
        Case TORNEIO_KAGE_KONOHA
            encontrarKage = AcharLogin(GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(1)))
            
        Case TORNEIO_KAGE_SUNA
            encontrarKage = AcharLogin(GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(2)))
            
        Case TORNEIO_KAGE_KIRI
            encontrarKage = AcharLogin(GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(3)))
            
        Case TORNEIO_KAGE_IWA
            encontrarKage = AcharLogin(GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(4)))
            
        Case TORNEIO_KAGE_KUMO
            encontrarKage = AcharLogin(GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(5)))
        
        Case TORNEIO_KAGE_SOM
            encontrarKage = AcharLogin(GetVar(App.Path & "\data\kages.txt", "KAGES", Trim(6)))
            
        Case Else
            encontrarKage = 0
    End Select
    
End Function

Public Sub charSupremo(ByVal index As Long, ByVal charNum As Long)
    If index < 1 Or index > MAX_PLAYERS Then Exit Sub
    If charNum < NARUTO Or charNum > MAX_CLASS_TEMP Then Exit Sub
    
    If HasItem(index, 221) = NO Then
        If charNum < SAI Then
            If HasItem(index, 222) = False Then
                PlayerMsg index, "Você não possui o item CHAR SUPREMO ou CHAR ESPECIAL para usar os chars básicos.", White
                Exit Sub
            End If
        Else
            PlayerMsg index, "Você não possui o item CHAR SUPREMO.", White
            Exit Sub
        End If
    End If
    
    If GetPlayerClass(index) = charNum Then
        PlayerMsg index, "Você já esta com esse personagem!", BrightRed
        Exit Sub
    End If
    
    Dim i As Byte

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

    SetarChar index, charNum

End Sub

Public Sub addVIP(ByVal pINDEX As Long, ByVal Dias As Long, Optional ByVal VIP As Byte, Optional ByVal admIndex As Long)
    
    If IsPlaying(pINDEX) = False Then Exit Sub
    If Dias > MAX_LONG Then Exit Sub
    If VIP > 2 Then Exit Sub
    If admIndex > MAX_PLAYERS Then Exit Sub
    
    If Trim$(Player(pINDEX).VipData.DataVIP) = vbNullString Then
        Player(pINDEX).VipData.DataVIP = Date 'se não tiver vip, deixa gravado o dia de hoje pra não bugar a calculação
    End If
    
    If VIP < 1 Then 'quer dizer que foi evento
        If Player(pINDEX).VipData.VIP < 1 Then Player(pINDEX).VipData.VIP = 1 'se não tiver vip, seta light
        GlobalMsg GetPlayerName(pINDEX) & " ganhou " & Dias & " dias VIP pelo evento.", BrightCyan
    Else
        Player(pINDEX).VipData.VIP = VIP
        PlayerMsg pINDEX, "Obrigado por ajudar a família NIP!Aproveite bem seu tempo como VIP :}", BrightCyan
    End If
    
    Player(pINDEX).VipData.DataVIP = DateAdd("d", Dias, Player(pINDEX).VipData.DataVIP)
    Player(pINDEX).VipData.DiasVIP = Trim(DateDiff("d", Date, Player(pINDEX).VipData.DataVIP))
    
    If Player(pINDEX).VipData.VIP = 1 Then 'light
        PlayerMsg pINDEX, "Agora você têm: " & DateDiff("d", Date, Player(pINDEX).VipData.DataVIP) & " dias LIGHT!", BrightCyan
    ElseIf Player(pINDEX).VipData.VIP = 2 Then 'ohyeh
        PlayerMsg pINDEX, "Agora você têm: " & DateDiff("d", Date, Player(pINDEX).VipData.DataVIP) & " dias OHYEH!", BrightCyan
    End If
    
    SendPlayerData pINDEX
    SavePlayer pINDEX
    
    If admIndex > 0 Then
        PlayerMsg admIndex, "Nome:" & GetPlayerName(pINDEX) & "(" & GetPlayerLevel(pINDEX) & ")", BrightGreen
        PlayerMsg admIndex, "Dias:" & DateDiff("d", Date, Player(pINDEX).VipData.DataVIP), BrightGreen
        PlayerMsg admIndex, "VIP:" & VIP, BrightGreen
    End If
    
End Sub

Public Sub addCT(ByVal pINDEX As Long, ByVal Dias As Long, Optional ByVal admIndex As Long)
    
    If IsPlaying(pINDEX) = False Then Exit Sub
    If Dias > MAX_LONG Then Exit Sub
    If admIndex > MAX_PLAYERS Then Exit Sub
    
    If Trim$(Player(pINDEX).CTdata.DataCT) = vbNullString Then
        Player(pINDEX).CTdata.DataCT = Date 'se não tiver ct, deixa gravado o dia de hoje pra não bugar a calculação
    End If
    
    If admIndex < 1 Then 'quer dizer que foi evento
        GlobalMsg GetPlayerName(pINDEX) & " ganhou " & Dias & " dias CT pelo evento.", BrightCyan
    Else
        PlayerMsg pINDEX, "Obrigado por ajudar a família NIP!Aproveite bem seu tempo com CT :}", BrightCyan
    End If
    
    Player(pINDEX).CTdata.CT = YES
    Player(pINDEX).CTdata.DataCT = DateAdd("d", Dias, Player(pINDEX).CTdata.DataCT)
    Player(pINDEX).CTdata.DiasCT = Trim(DateDiff("d", Date, Player(pINDEX).CTdata.DataCT))
    
    PlayerMsg pINDEX, "Agora você têm: " & DateDiff("d", Date, Player(pINDEX).CTdata.DataCT) & " dias CT!", BrightCyan
    
    SendPlayerData pINDEX
    SavePlayer pINDEX
    
    If admIndex > 0 Then
        PlayerMsg admIndex, "Nome:" & GetPlayerName(pINDEX) & "(" & GetPlayerLevel(pINDEX) & ")", BrightGreen
        PlayerMsg admIndex, "Dias:" & DateDiff("d", Date, Player(pINDEX).CTdata.DataCT), BrightGreen
        PlayerMsg admIndex, "CT", BrightGreen
    End If
    
End Sub

Public Sub mandarLutaKs(ByVal index As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If GetPlayerAccess(index) < 2 Then Exit Sub
Dim i As Long

    If Torneio <> TORNEIO_KAGE_KONOHA And Torneio <> TORNEIO_KAGE_SUNA And Torneio <> TORNEIO_KAGE_KIRI And Torneio <> TORNEIO_KAGE_IWA And Torneio <> TORNEIO_KAGE_KUMO And Torneio <> TORNEIO_KAGE_CHUVA And Torneio <> TORNEIO_KAGE_SOM Then
        PlayerMsg index, "Não ta tendo um KS..", White
        Exit Sub
    End If
    
    If frmServer.chkTorneioStatus.Value = YES Then
        PlayerMsg index, "O torneio ainda ta ativado! Espera ser desativado.", White
        Exit Sub
    End If
    
    For i = 1 To Player_HighIndex
        If TorneioData.Participante(i) > 0 Then
            If GetPlayerMap(TorneioData.Participante(i)) = 100 Then
                PlayerMsg index, GetPlayerName(TorneioData.Participante(i)) & " ainda ta lutando na arena!", White
                Exit Sub
            End If
        End If
    Next
    
    SegundosParaAtualizarEvento = 1 'ativa o contador
    'AtualizarEvento
End Sub

Public Sub VerificarJutsus(ByVal index As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub

Dim needUp As Boolean
needUp = False

If GetPlayerClass(index) = TOBI Or Player(index).Rank = RANK_KAGE Then
    If HasSpell(index, 242) = False Then
        PlayerMsg index, "Você aprendeu Summon Bijuu!", Blue
        SetPlayerSpell index, FindOpenSpellSlot(index), 242
        needUp = True
    End If
End If

If GetPlayerClass(index) = TOBI Then
    If Not HasSpell(index, 240) Then
        SetPlayerSpell index, FindOpenSpellSlot(index), 240
        PlayerMsg index, "Você aprendeu RINNEGAN!", Blue
        needUp = True
    End If
End If

If Player(index).Resets > 0 Then
    If Not HasSpell(index, 4) Then
        SetPlayerSpell index, FindOpenSpellSlot(index), 4
        PlayerMsg index, "Você aprendeu KAGE BUYOU!", Blue
        needUp = True
    End If
End If

If Player(index).Org > 0 Then
    OrgJutsu index, Player(index).Org
End If

If needUp = True Then
    SendPlayerSpells index
End If

PlayerMsg index, "Jutsus verificados! Se você não ganhou nada quer dizer que está tudo em ordem.", White

End Sub

Public Sub KarmaTradeAccept(ByVal index As Long)
If index < 1 Or index > Player_HighIndex Then Exit Sub

If TempPlayer(index).KarmaTradeIndex < 1 Then Exit Sub

If TempPlayer(index).KarmaTradeOwner <> 0 Then
    PlayerMsg index, "Espere ele decidir se aceita ou não!", White
    Exit Sub
End If

Dim karmaIndex As Long
Dim myKarma As Long
Dim inviterKarma As Long
Dim karmaAmmount As Long

karmaIndex = TempPlayer(index).KarmaTradeIndex

If karmaIndex < 1 Or karmaIndex > Player_HighIndex Then
    TempPlayer(index).KarmaTradeIndex = 0
    TempPlayer(index).KarmaTradeQnt = 0
    PlayerMsg index, "O jogador está offline.", White
    Exit Sub
End If

If TempPlayer(karmaIndex).KarmaTradeIndex <> index Then
    TempPlayer(index).KarmaTradeIndex = 0
    TempPlayer(index).KarmaTradeQnt = 0
    PlayerMsg index, "Ele não está negociando com você.", White
    Exit Sub
End If

If HasItem(karmaIndex, 254) < 3000 Then
    TempPlayer(index).KarmaTradeIndex = 0
    TempPlayer(index).KarmaTradeQnt = 0
    TempPlayer(karmaIndex).KarmaTradeIndex = 0
    TempPlayer(karmaIndex).KarmaTradeQnt = 0
    TempPlayer(karmaIndex).KarmaTradeOwner = 0
    PlayerMsg karmaIndex, "Você não possui a quantidade de cash necessário!", BrightRed
    PlayerMsg index, "Ele não possui a quantidade de cash necessário.", BrightRed
    Exit Sub
End If
    
myKarma = Player(index).Karma
inviterKarma = Player(karmaIndex).Karma
karmaAmmount = TempPlayer(index).KarmaTradeQnt

If karmaAmmount > 0 Then
    If inviterKarma < karmaAmmount Then
        TempPlayer(index).KarmaTradeIndex = 0
        TempPlayer(index).KarmaTradeQnt = 0
        TempPlayer(karmaIndex).KarmaTradeIndex = 0
        TempPlayer(karmaIndex).KarmaTradeQnt = 0
        TempPlayer(karmaIndex).KarmaTradeOwner = 0
        PlayerMsg karmaIndex, "Você não possui a quantidade de karma necessária!", BrightRed
        PlayerMsg index, "Ele não possui a quantidade de karma necessária.", BrightRed
        Exit Sub
    End If
End If

If karmaAmmount <= 0 Then
    If inviterKarma > karmaAmmount Then
        TempPlayer(index).KarmaTradeIndex = 0
        TempPlayer(index).KarmaTradeQnt = 0
        TempPlayer(karmaIndex).KarmaTradeIndex = 0
        TempPlayer(karmaIndex).KarmaTradeQnt = 0
        TempPlayer(karmaIndex).KarmaTradeOwner = 0
        PlayerMsg karmaIndex, "Você não possui a quantidade de karma necessária!", BrightRed
        PlayerMsg index, "Ele não possui a quantidade de karma necessária.", BrightRed
        Exit Sub
    End If
End If
    
    TakeInvItem karmaIndex, 254, 3000
    
    PlayerMsg karmaIndex, "Deu tudo certo!", BrightGreen
    PlayerMsg index, "Deu tudo certo. Seu karma antigo era:" & myKarma & ".", Yellow
    
    Player(karmaIndex).Karma = Player(karmaIndex).Karma + (karmaAmmount * -1)
    Player(index).Karma = Player(index).Karma + karmaAmmount
    PlayerMsg index, "Seu karma atual é:" & Player(index).Karma & ".", Yellow
    SendPlayerData index
    SendPlayerData karmaIndex
    SalvarConta index
    SalvarConta karmaIndex
    
    TempPlayer(index).KarmaTradeIndex = 0
    TempPlayer(index).KarmaTradeQnt = 0
    TempPlayer(karmaIndex).KarmaTradeOwner = 0
    TempPlayer(karmaIndex).KarmaTradeIndex = 0
    TempPlayer(karmaIndex).KarmaTradeQnt = 0
End Sub

Public Sub KarmaTradeRefused(ByVal index As Long)
If index < 1 Or index > Player_HighIndex Then Exit Sub
If TempPlayer(index).KarmaTradeIndex < 1 Then Exit Sub

If TempPlayer(index).KarmaTradeOwner <> 0 Then
    PlayerMsg index, "Espere a pessoa decidir se aceita sua oferta de karma!", White
    Exit Sub
End If

Dim karmaIndex As Long
karmaIndex = TempPlayer(index).KarmaTradeIndex

PlayerMsg index, "Você recusou a oferta com sucesso!", White

    TempPlayer(index).KarmaTradeIndex = 0
    TempPlayer(index).KarmaTradeQnt = 0
    TempPlayer(index).KarmaTradeOwner = 0
    
If karmaIndex > 0 And karmaIndex <= Player_HighIndex Then
    If TempPlayer(karmaIndex).KarmaTradeIndex = index Then
        TempPlayer(karmaIndex).KarmaTradeOwner = 0
        TempPlayer(karmaIndex).KarmaTradeIndex = 0
        TempPlayer(karmaIndex).KarmaTradeQnt = 0
        PlayerMsg karmaIndex, "O jogador " & GetPlayerName(index) & " recusou sua oferta de karma.", BrightRed
    End If
End If

End Sub

Public Sub KarmaTradeInvite(ByVal index As Long, ByVal qnt As Long)
If index < 1 Or index > Player_HighIndex Then Exit Sub

If qnt < 0 Then
    If qnt > -10 Then
        PlayerMsg index, "A quantidade mínima de karma para transferência é -10 ou 10!", BrightCyan
        Exit Sub
    End If
    
    If Player(index).Karma > qnt Then
        PlayerMsg index, "Quantidade de karma insuficiente!", BrightCyan
        Exit Sub
    End If
End If

If qnt > 0 Then
    If qnt < 10 Then
        PlayerMsg index, "A quantidade mínima de karma para transferência é -10 ou 10!", BrightCyan
        Exit Sub
    End If
    
    If Player(index).Karma < qnt Then
        PlayerMsg index, "Quantidade de karma insuficiente!", BrightCyan
        Exit Sub
    End If
End If

If TempPlayer(index).KarmaTradeIndex <> 0 Then
    PlayerMsg index, "Você já está em uma transferência de karma! Caso não esteja e mesmo assim não consegue, deslogue.", White
    Exit Sub
End If

Dim karmaIndex As Long
karmaIndex = TempPlayer(index).Target

If index = karmaIndex Then
    PlayerMsg index, "Tu é bixão memo heim", White
    Exit Sub
End If

If karmaIndex < 1 Or karmaIndex > Player_HighIndex Or TempPlayer(index).targetType <> TARGET_TYPE_PLAYER Then
    PlayerMsg index, "Selecione um jogador para fazer o convite!", White
    Exit Sub
End If

If Player(index).InTorneio > 0 Or Player(karmaIndex).InTorneio > 0 Then
    PlayerMsg index, "Alguém está em algum torneio.", BrightRed
    Exit Sub
End If

If TempPlayer(karmaIndex).KarmaTradeIndex > 0 Then
    PlayerMsg index, "Ele já está em uma transferência de karma!", White
    Exit Sub
End If

TempPlayer(index).KarmaTradeIndex = karmaIndex
TempPlayer(index).KarmaTradeQnt = qnt
TempPlayer(index).KarmaTradeOwner = 1

TempPlayer(karmaIndex).KarmaTradeIndex = index
TempPlayer(karmaIndex).KarmaTradeQnt = qnt

PlayerMsg index, "Seu pedido de transferência de " & qnt & " karmas foi enviado ao " & GetPlayerName(karmaIndex) & "! Espere a resposta dele agora.", White
PlayerMsg karmaIndex, GetPlayerName(index) & " enviou " & qnt & " karmas para você. Para aceitar, digite no mapa /aceitarkarma. Para recusar, digite no mapa /recusarkarma.", Yellow

End Sub
