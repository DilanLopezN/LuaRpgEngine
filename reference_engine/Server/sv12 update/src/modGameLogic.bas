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

Sub SpawnItem(ByVal ItemNum As Long, ByVal ItemVal As Long, ByVal mapNum As Long, ByVal X As Long, ByVal Y As Long, Optional ByVal playerName As String = vbNullString)
    Dim i As Long

    ' Check for subscript out of range
    If ItemNum < 1 Or ItemNum > MAX_ITEMS Or mapNum <= 0 Or mapNum > MAX_MAPS Then
        Exit Sub
    End If

    ' Find open map item slot
    i = FindOpenMapItemSlot(mapNum)
    Call SpawnItemSlot(i, ItemNum, ItemVal, mapNum, X, Y, playerName)
End Sub

Sub SpawnItemSlot(ByVal MapItemSlot As Long, ByVal ItemNum As Long, ByVal ItemVal As Long, ByVal mapNum As Long, ByVal X As Long, ByVal Y As Long, Optional ByVal playerName As String = vbNullString, Optional ByVal canDespawn As Boolean = True)
    Dim packet As String
    Dim i As Long
    Dim Buffer As clsBuffer

    ' Check for subscript out of range
    If MapItemSlot <= 0 Or MapItemSlot > MAX_MAP_ITEMS Or ItemNum < 0 Or ItemNum > MAX_ITEMS Or mapNum <= 0 Or mapNum > MAX_MAPS Then
        Exit Sub
    End If

    i = MapItemSlot

    If i <> 0 Then
        If ItemNum >= 0 And ItemNum <= MAX_ITEMS Then
            MapItem(mapNum, i).playerName = playerName
            MapItem(mapNum, i).playerTimer = GetTickCount + ITEM_SPAWN_TIME
            MapItem(mapNum, i).canDespawn = canDespawn
            MapItem(mapNum, i).despawnTimer = GetTickCount + ITEM_DESPAWN_TIME
            MapItem(mapNum, i).num = ItemNum
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
                If Item(Map(mapNum).Tile(X, Y).Data1).Type = ITEM_TYPE_CURRENCY And Map(mapNum).Tile(X, Y).Data2 <= 0 Then
                    Call SpawnItem(Map(mapNum).Tile(X, Y).Data1, 1, mapNum, X, Y)
                Else
                    Call SpawnItem(Map(mapNum).Tile(X, Y).Data1, Map(mapNum).Tile(X, Y).Data2, mapNum, X, Y)
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
                ResourceCache(mapNum).ResourceData(Resource_Count).cur_health = Resource(Map(mapNum).Tile(X, Y).Data1).health
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

Sub PlayerUnequipItem(ByVal index As Long, ByVal EqSlot As Long)

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

Public Sub GivePlayerEXP(ByVal index As Long, ByVal EXP As Long)
    ' give the exp

    If Not TempPlayer(index).GanhouEXP = YES Then Exit Sub
    TempPlayer(index).GanhouEXP = NO
    
    If EXP < 1 Then Exit Sub
    
    TempPlayer(index).SetExp = YES
    Call SetPlayerExp(index, GetPlayerExp(index) + EXP)
    SendEXP index
    SendActionMsg GetPlayerMap(index), "+" & EXP & " EXP", White, 1, (GetPlayerX(index) * 32), (GetPlayerY(index) * 32)
    
    ' check if we've leveled
    CheckPlayerLevelUp index
End Sub

Sub CheckAttackNPC(ByVal index As Integer, ByVal Map As Integer, ByVal X As Byte, ByVal Y As Byte, ByVal Damage As Long, Optional ByVal SpellNum As Integer)
On Error Resume Next

Dim Count As Byte
Count = 1
Do While Count < 30

If MapNpc(GetPlayerMap(index)).Npc(Count).X = X And MapNpc(GetPlayerMap(index)).Npc(Count).Y = Y Then
    If CanPlayerAttackNpc(index, Count, True) Then
        Call PlayerAttackNpc(index, Count, Damage)
        
         If SpellNum > 0 Then
            If Spell(SpellNum).StunDuration > 0 Then StunNPC Count, GetPlayerMap(index), SpellNum, index
            If Spell(SpellNum).Duration > 0 Then AddDoT_Npc GetPlayerMap(index), Count, SpellNum, index
            If Spell(SpellNum).IsPush = YES Then PuxarNPC index, Count
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
                If GetPlayerClass(index) = 11 Then 'Aburame
                    If GetPlayerVital(Count, Vitals.mp) > 10 Then
                        SetPlayerVital Count, Vitals.mp, GetPlayerVital(Count, Vitals.mp) - 10
                        SendVital Count, Vitals.mp
                    End If
                End If
                    If Not TempPlayer(index).Target = Count Then
                      TempPlayer(index).Target = Count
                      TempPlayer(index).targetType = TARGET_TYPE_PLAYER
                     SendTarget index
                    End If
            End If
        End If
    End If
End If
Count = Count + 1
Loop
End Sub

Public Sub ExpelirPlayer(ByVal Attacker As Long, ByVal Vitima As Long, ByVal SpellNum As Long)
If SpellNum < 1 Or SpellNum > MAX_SPELLS Then Exit Sub
If Spell(SpellNum).Expelir < 1 Then Exit Sub
If Not IsPlaying(Vitima) Then Exit Sub
If Not GetPlayerMap(Attacker) = GetPlayerMap(Vitima) Then Exit Sub
If TempPlayer(Attacker).ExpelDelay > 0 Then Exit Sub
Dim i As Integer

Select Case GetPlayerDir(Attacker)

Case DIR_RIGHT
    Player(Vitima).X = GetPlayerX(Vitima) + Spell(SpellNum).Expelir
Case DIR_LEFT
    Player(Vitima).X = GetPlayerX(Vitima) - Spell(SpellNum).Expelir
Case DIR_DOWN
    Player(Vitima).Y = GetPlayerY(Vitima) + Spell(SpellNum).Expelir
Case DIR_UP
    Player(Vitima).Y = GetPlayerY(Vitima) - Spell(SpellNum).Expelir

End Select

For i = 1 To Player_HighIndex
    If GetPlayerMap(i) = GetPlayerMap(Vitima) Then
        SendPlayerXYToMap i
    End If
Next

TempPlayer(Attacker).ExpelDelay = GetTickCount + 1000
End Sub

Public Sub ExpelirNpc(ByVal Attacker As Long, ByVal Vitima As Long, ByVal SpellNum As Long)
Dim i As Long
Dim MapX, mapY, Dist, distTotal, NpcX, NpcY As Byte


If Attacker < 1 Or Attacker > MAX_PLAYERS Then Exit Sub
If SpellNum < 1 Or SpellNum > MAX_SPELLS Then Exit Sub
If Spell(SpellNum).Expelir < 1 Then Exit Sub
If Vitima < 1 Or Vitima > MAX_NPCS Then Exit Sub
If TempPlayer(Attacker).ExpelDelay > 0 Then Exit Sub

Dist = Spell(SpellNum).Expelir
MapX = Map(GetPlayerMap(Attacker)).MaxX
mapY = Map(GetPlayerMap(Attacker)).MaxY
NpcX = MapNpc(GetPlayerMap(Attacker)).Npc(Vitima).X
NpcY = MapNpc(GetPlayerMap(Attacker)).Npc(Vitima).Y

Select Case GetPlayerDir(Attacker)
    Case DIR_RIGHT
     distTotal = NpcX + Dist
     If distTotal > MapX Then distTotal = MapX
      MapNpc(GetPlayerMap(Attacker)).Npc(Vitima).X = distTotal
     
   Case DIR_LEFT
     distTotal = NpcX - Dist
     If distTotal < 1 Then distTotal = 0
      MapNpc(GetPlayerMap(Attacker)).Npc(Vitima).X = distTotal
   
   Case DIR_DOWN
     distTotal = NpcY + Dist
     If distTotal > mapY Then distTotal = mapY
      MapNpc(GetPlayerMap(Attacker)).Npc(Vitima).Y = distTotal
      
   Case DIR_UP
     distTotal = NpcY - Dist
     If distTotal < 1 Then distTotal = 0
      MapNpc(GetPlayerMap(Attacker)).Npc(Vitima).Y = distTotal

End Select
SendMapNpcsToMap GetPlayerMap(Attacker)
TempPlayer(Attacker).ExpelDelay = GetTickCount + 1000


End Sub

Public Sub PuxarPlayer(ByVal index As Long, ByVal Vitima As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If Vitima < 1 Or Vitima > MAX_PLAYERS Then Exit Sub

Select Case GetPlayerDir(index)
    Case DIR_UP
        Player(Vitima).X = GetPlayerX(index)
        Player(Vitima).Y = GetPlayerY(index) - 1
        Player(Vitima).Dir = DIR_DOWN
    Case DIR_DOWN
        Player(Vitima).X = GetPlayerX(index)
        Player(Vitima).Y = GetPlayerY(index) + 1
        Player(Vitima).Dir = DIR_UP
    Case DIR_RIGHT
        Player(Vitima).X = GetPlayerX(index) + 1
        Player(Vitima).Y = GetPlayerY(index)
        Player(Vitima).Dir = DIR_LEFT
    Case DIR_LEFT
        Player(Vitima).X = GetPlayerX(index) - 1
        Player(Vitima).Y = GetPlayerY(index)
        Player(Vitima).Dir = DIR_RIGHT
End Select
       
   SendPlayerData index
   SendPlayerData Vitima
   
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

For Y = GetPlayerY(index) - Dist To GetPlayerY(index) + Dist
    For X = GetPlayerX(index) - Dist To GetPlayerX(index) + Dist
        If X >= 0 And X <= Map(mapNum).MaxX And Y >= 0 And Y <= Map(mapNum).MaxY Then
            SendAnimation mapNum, Anim, X, Y
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
Anim = Spell(SpellNum).RetaAnim(1)

For i = 1 To Dist
Select Case GetPlayerDir(index)
Case DIR_UP

SendAnimation GetPlayerMap(index), Anim, X, Y - i
Call CheckAttackNPC(index, Map, X, Y - i, Forca, SpellNum)

If largura > 0 Then
  For larg = 1 To largura
    
    Select Case i
    Case 1
       
    Case 2
        SendAnimation GetPlayerMap(index), Anim, X - 1, Y - i
        SendAnimation GetPlayerMap(index), Anim, X + 1, Y - i
        Call CheckAttackNPC(index, Map, X - 1, Y - i, Forca, SpellNum)
        Call CheckAttackNPC(index, Map, X + 1, Y - i, Forca, SpellNum)
    Case Else
        SendAnimation GetPlayerMap(index), Anim, X - larg, Y - i
        SendAnimation GetPlayerMap(index), Anim, X + larg, Y - i
        Call CheckAttackNPC(index, Map, X - larg, Y - i, Forca, SpellNum)
        Call CheckAttackNPC(index, Map, X + larg, Y - i, Forca, SpellNum)
    End Select
    
  Next
End If

Case DIR_DOWN
If Spell(SpellNum).MultiAnim = YES Then
    Anim = Spell(SpellNum).RetaAnim(2)
End If

SendAnimation GetPlayerMap(index), Anim, X, Y + i
Call CheckAttackNPC(index, Map, X, Y + i, Forca, SpellNum)

If largura > 0 Then
  For larg = 1 To largura
  
    Select Case i
    Case 1
       
    Case 2
        SendAnimation GetPlayerMap(index), Anim, X - 1, Y + i
        SendAnimation GetPlayerMap(index), Anim, X + 1, Y + i
        Call CheckAttackNPC(index, Map, X - 1, Y + i, Forca, SpellNum)
        Call CheckAttackNPC(index, Map, X + 1, Y + i, Forca, SpellNum)
    Case Else
        SendAnimation GetPlayerMap(index), Anim, X - larg, Y + i
        SendAnimation GetPlayerMap(index), Anim, X + larg, Y + i
        Call CheckAttackNPC(index, Map, X - larg, Y + i, Forca, SpellNum)
        Call CheckAttackNPC(index, Map, X + larg, Y + i, Forca, SpellNum)
    End Select

  Next
End If

Case DIR_LEFT
If Spell(SpellNum).MultiAnim = YES Then
    Anim = Spell(SpellNum).RetaAnim(3)
End If

SendAnimation GetPlayerMap(index), Anim, X - i, Y
Call CheckAttackNPC(index, Map, X - i, Y, Forca, SpellNum)

If largura > 0 Then
  For larg = 1 To largura
  
    Select Case i
    Case 1
       
    Case 2
        SendAnimation GetPlayerMap(index), Anim, X - i, Y - 1
        SendAnimation GetPlayerMap(index), Anim, X - i, Y + 1
        Call CheckAttackNPC(index, Map, X - i, Y - 1, Forca, SpellNum)
        Call CheckAttackNPC(index, Map, X - i, Y + 1, Forca, SpellNum)
    Case Else
        SendAnimation GetPlayerMap(index), Anim, X - i, Y + larg
        SendAnimation GetPlayerMap(index), Anim, X - i, Y - larg
        Call CheckAttackNPC(index, Map, X - i, Y + larg, Forca, SpellNum)
        Call CheckAttackNPC(index, Map, X - i, Y - larg, Forca, SpellNum)
    End Select
  
  Next
End If

Case DIR_RIGHT
If Spell(SpellNum).MultiAnim = YES Then
    Anim = Spell(SpellNum).RetaAnim(4)
End If

SendAnimation GetPlayerMap(index), Anim, X + i, Y
Call CheckAttackNPC(index, Map, X + i, Y, Forca, SpellNum)

If largura > 0 Then
  For larg = 1 To largura
  
    Select Case i
        Case 1
       
        Case 2
            SendAnimation GetPlayerMap(index), Anim, X + i, Y - 1
            SendAnimation GetPlayerMap(index), Anim, X + i, Y + 1
            Call CheckAttackNPC(index, Map, X + i, Y - 1, Forca, SpellNum)
            Call CheckAttackNPC(index, Map, X + i, Y + 1, Forca, SpellNum)
        Case Else
            SendAnimation GetPlayerMap(index), Anim, X + i, Y + larg
            SendAnimation GetPlayerMap(index), Anim, X + i, Y - larg
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
Dim i As Byte

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
    
    For i = 1 To 4
        If TempPlayer(index).Dojutsu(i) > 0 Then
            GetSpellBaseStat = GetSpellBaseStat + (1 * 10 / 100 * GetSpellBaseStat)
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
PlayerMsg index, "Você iniciou a Missão ;" & Quest(QuestNum).Name, BrightCyan
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
Dim QuestID As Byte

If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If NpcNum < 1 Or NpcNum > MAX_NPCS Then Exit Sub
If questSlot < 1 Or questSlot > 10 Then Exit Sub

QuestID = Player(index).QuestNum(questSlot)
If Quest(QuestID).Tipo <> QUEST_TYPE_NPC Then Exit Sub

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
       PlayerMsg index, "Missão: " & Quest(QuestID).Name & " completa!Fale com seu tutor para receber sua Recompensa.", DarkGrey
       Player(index).QuestInfo(questSlot).Status = 3
    End If
End If
End Sub

Sub CheckQuestItem(ByVal index As Long, ByVal ItemNum As Long, ByVal questSlot As Byte)
Dim i As Byte
Dim QuestID As Byte

If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If ItemNum < 1 Or ItemNum > MAX_NPCS Then Exit Sub
If questSlot < 1 Or questSlot > 10 Then Exit Sub

QuestID = Player(index).QuestNum(questSlot)
If QuestID <= 1 Then Exit Sub

If Quest(QuestID).Tipo <> QUEST_TYPE_ITEM Then Exit Sub


If CanTake(index, Quest(QuestID).Item(1), Quest(QuestID).ItemQnt(1)) And CanTake(index, Quest(QuestID).Item(2), Quest(QuestID).ItemQnt(2)) And CanTake(index, Quest(QuestID).Item(3), Quest(QuestID).ItemQnt(3)) And CanTake(index, Quest(QuestID).Item(4), Quest(QuestID).ItemQnt(4)) And CanTake(index, Quest(QuestID).Item(5), Quest(QuestID).ItemQnt(5)) Then
   Player(index).QuestInfo(questSlot).Status = 3
   PlayerMsg index, "Missão: " & Quest(QuestID).Name & " completa!Fale com seu tutor para receber sua Recompensa.", Yellow
   For i = 1 To 5
      TakeItem index, Quest(QuestID).Item(i), Quest(QuestID).ItemQnt(i)
   Next
End If


End Sub

Sub CheckQuestMAP(ByVal index As Long)
Dim QuestNum As Long
Dim i, questSlot As Byte

If index < 1 Or index > MAX_PLAYERS Then Exit Sub



For i = 1 To 10
    If Player(index).QuestNum(i) > 0 Then
       QuestNum = Player(index).QuestNum(i)
       If Quest(QuestNum).Tipo = QUEST_TYPE_MAP Then
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
    
If Quest(QuestNum).Tipo <> QUEST_TYPE_TALKTO Then Exit Sub

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
           If Quest(QuestNum).Tipo = QUEST_TYPE_LEVEL Then
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
        If Quest(QuestNum).Tipo = QUEST_TYPE_SPELL Then
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
        If Quest(QuestNum).Tipo = QUEST_TYPE_KILLPLAYER Then
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

Public Function Current_InvItemCount(ByVal index As Long, ByVal ItemNum As Long) As Long
Dim i As Long
    If ItemNum > 0 Then
        For i = 1 To MAX_INV
            If GetPlayerInvItemNum(index, i) = ItemNum Then
                If Item(ItemNum).Type = ITEM_TYPE_CURRENCY Then
                    Current_InvItemCount = Current_InvItemCount + GetPlayerInvItemValue(index, i)
                Else
                    Current_InvItemCount = Current_InvItemCount + 1
                End If
            End If
        Next
    End If
End Function

Function CanTake(ByVal index As Long, ByVal ItemNum As Long, ByVal ItemValue As Long) As Boolean
Dim i As Long
  
  If ItemNum > 0 Then
     If ItemValue > 0 Then
        If Current_InvItemCount(index, ItemNum) >= ItemValue Then
           CanTake = True
           Exit Function
        End If
     End If
  End If
  

End Function

Sub TakeItem(ByVal index As Long, ByVal ItemNum As Long, ByVal ItemValue As Long)
   Dim i As Long
   
   If ItemNum < 1 Or ItemNum > MAX_ITEMS Then Exit Sub
   If index < 1 Or index > MAX_PLAYERS Then Exit Sub
   
   'If CanTake(index, ItemNum, ItemValue) Then
      If Item(ItemNum).Type = ITEM_TYPE_CURRENCY Then
         TakeInvItem index, ItemNum, ItemValue
      Else
         For i = 1 To ItemValue
            TakeInvItem index, ItemNum, i
         Next
      End If
    'End If
    
End Sub

Public Sub GiveItem(ByVal index As Long, ByVal ItemNum As Long, ByVal ItemValue As Long)
If ItemNum < 1 Or ItemNum > MAX_ITEMS Then Exit Sub
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
Dim i As Long, Slot As Byte

Slot = FindOpenInvSlot(index, ItemNum)
    If Slot = 0 Then
        PlayerMsg index, "Sem espaço na Mochila.", BrightRed
        Exit Sub
    End If

If Item(ItemNum).Type = ITEM_TYPE_CURRENCY Then
    GiveInvItem index, ItemNum, ItemValue, True
Else
    For i = 1 To ItemValue
        GiveInvItem index, ItemNum, i
    Next
End If

End Sub

Public Sub TransUp(ByVal index As Long, ByVal TransNum As Byte, Optional ByVal VIP As Byte)
Dim i, Transformado As Byte
If index < 1 Or index > MAX_PLAYERS Then Exit Sub

For i = 1 To 4
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
    PlayerMsg index, "Volte ao normal antes!", Red
    Exit Sub
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
                    SetPlayerSprite index, 2
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
            PlayerMsg index, "Você não tem o level necessário", BrightRed
        End If
    
    Case 2
        If GetPlayerLevel(index) >= 50 Then
        
            Transformado = YES
            
            'For i = 1 To Stats.Stat_Count - 1
                'SetPlayerStat index, i, GetPlayerStat(index, i) + 50
            'Next
        
            Select Case GetPlayerClass(index)
                Case 1 'Naruto
                    SetPlayerSprite index, 3
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
            PlayerMsg index, "Você não tem o level necessário", BrightRed
        End If
        
    Case 3
        If GetPlayerLevel(index) >= 80 Then
        
            Transformado = YES
        
            'For i = 1 To Stats.Stat_Count - 1
                'SetPlayerStat index, i, GetPlayerStat(index, i) + 80
            'Next
        
            Select Case GetPlayerClass(index)
                Case 1 'Naruto
                    SetPlayerSprite index, 4
                Case 2 'Sasuke
                    SetPlayerSprite index, 12
                Case 3 'Sakura
                    SetPlayerSprite index, 30
                Case 4 'Ino
                    SetPlayerSprite index, 32
                Case 5 'Shikamaru
                    SetPlayerSprite index, 16
                Case 6 'Chouji
                    SetPlayerSprite index, 19
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
            PlayerMsg index, "Você não tem o level necessário", BrightRed
        End If
    
    Case 4
        If GetPlayerLevel(index) >= 120 Then
        
            Transformado = YES
        
            'For i = 1 To Stats.Stat_Count - 1
                'SetPlayerStat index, i, GetPlayerStat(index, i) + 120
            'Next
        
            Select Case GetPlayerClass(index)
                Case 1 'Naruto
                    SetPlayerSprite index, 5
                Case 2 'Sasuke
                    SetPlayerSprite index, 13
                
                Case Else
            End Select
        Else
            PlayerMsg index, "Você não tem o level necessário", BrightRed
        End If
        
    Case 5
        If GetPlayerLevel(index) >= 150 Then
        
            Transformado = YES
        
            'For i = 1 To Stats.Stat_Count - 1
                'SetPlayerStat index, i, GetPlayerStat(index, i) + 150
            'Next
        
            Select Case GetPlayerClass(index)
                Case 1 'Naruto
                    SetPlayerSprite index, 6
                Case 2 'Sasuke
                    SetPlayerSprite index, 14
                    Player(index).Voando = YES
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
                    SetPlayerSprite index, 7
                    
                Case Else
            End Select
        Else
            PlayerMsg index, "Você não tem o level necessário", BrightRed
        End If
    
    Case Else
End Select
           
If Transformado = YES Then
    Select Case Player(index).Org
        Case ORG_AKATSUKI
            Select Case GetPlayerClass(index)
                Case 1 'Naruto
                    SetPlayerSprite index, 156
                Case 2 'Sasuke
                    SetPlayerSprite index, 120
                Case 3 'Sakura
                    SetPlayerSprite index, 143
                Case 4 'Ino
                    SetPlayerSprite index, 144
                Case 5 'Shikamaru
                    SetPlayerSprite index, 152
                Case 6 'Chouji
                    SetPlayerSprite index, 141
                Case 7 'Lee
                    SetPlayerSprite index, 149
                Case 8 'Hyuuga
                    SetPlayerSprite index, 150
                Case 9 'Tenten
                    SetPlayerSprite index, 155
                Case 10 'Kiba
                    SetPlayerSprite index, 148
                Case 11 'Aburame
                    SetPlayerSprite index, 153
                Case 12 'Gaara
                    SetPlayerSprite index, 142
                Case 13 'Kankurou
                    SetPlayerSprite index, 147
                Case 14 'Temari
                    SetPlayerSprite index, 154
                Case 15 'Hinata
                    SetPlayerSprite index, 164
                Case Else
            End Select
        Case Else
    End Select
    
    'Sprite dos kages
    If Player(index).Rank = RANK_KAGE Then
            Select Case Player(index).Vila
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
                Case Else
            End Select
    End If
    
    Player(index).Trans = TransNum
    SendAnimation GetPlayerMap(index), 2, 0, 0, TARGET_TYPE_PLAYER, index
    SendPlayerData index
End If

End Sub

Public Sub TransDown(ByVal index As Long)
Dim u As Byte
Dim i As Byte

If index < 1 Or index > MAX_PLAYERS Then Exit Sub

For i = 1 To 4
    If TempPlayer(index).Dojutsu(i) > 0 Then
        PlayerMsg index, "Uma técnica especial sua já esta ativada..", BrightRed
        Exit Sub
    End If
Next

Select Case GetPlayerClass(index)
    Case 1 'Naruto
        SetPlayerSprite index, 1
                
        Select Case Player(index).Org
            Case ORG_AKATSUKI
                SetPlayerSprite index, 156
            Case Else
        End Select
    Case 2 'Sasuke
        SetPlayerSprite index, 9
        
        Select Case Player(index).Org
            Case ORG_AKATSUKI
                SetPlayerSprite index, 120
            Case Else
        End Select
    Case 3 'Sakura
        SetPlayerSprite index, 29
        
        Select Case Player(index).Org
            Case ORG_AKATSUKI
                SetPlayerSprite index, 143
            Case Else
        End Select
    Case 4 'Ino
        SetPlayerSprite index, 31
        
        Select Case Player(index).Org
            Case ORG_AKATSUKI
                SetPlayerSprite index, 144
            Case Else
        End Select
    Case 5 'Shikamaru
        SetPlayerSprite index, 15
        
        Select Case Player(index).Org
            Case ORG_AKATSUKI
                SetPlayerSprite index, 152
            Case Else
        End Select
    Case 6 'Chouji
        SetPlayerSprite index, 17
        
        Select Case Player(index).Org
            Case ORG_AKATSUKI
                SetPlayerSprite index, 141
            Case Else
        End Select
    Case 7 'Lee
        SetPlayerSprite index, 23
        
        Select Case Player(index).Org
            Case ORG_AKATSUKI
                SetPlayerSprite index, 149
            Case Else
        End Select
    Case 8 'Hyuuga
        SetPlayerSprite index, 37
        
        Select Case Player(index).Org
            Case ORG_AKATSUKI
                SetPlayerSprite index, 150
            Case Else
        End Select
    Case 9 'Tenten
        SetPlayerSprite index, 33
        
        Select Case Player(index).Org
            Case ORG_AKATSUKI
                SetPlayerSprite index, 155
            Case Else
        End Select
    Case 10 'Inuzuka
        SetPlayerSprite index, 35
        
        Select Case Player(index).Org
            Case ORG_AKATSUKI
                SetPlayerSprite index, 148
            Case Else
        End Select
    Case 11 'Aburame
        SetPlayerSprite index, 27
        
        Select Case Player(index).Org
            Case ORG_AKATSUKI
                SetPlayerSprite index, 153
            Case Else
        End Select
    Case 12 'Gaara
        SetPlayerSprite index, 20
        
        Select Case Player(index).Org
            Case ORG_AKATSUKI
                SetPlayerSprite index, 142
            Case Else
        End Select
    Case 13 'Kankurou
        SetPlayerSprite index, 41
        
        Select Case Player(index).Org
            Case ORG_AKATSUKI
                SetPlayerSprite index, 147
            Case Else
        End Select
    Case 14 'Temari
        SetPlayerSprite index, 45
        
        Select Case Player(index).Org
            Case ORG_AKATSUKI
                SetPlayerSprite index, 154
            Case Else
        End Select
    Case 15 'Hinata
        SetPlayerSprite index, 39
        
        Select Case Player(index).Org
            Case ORG_AKATSUKI
                SetPlayerSprite index, 164
            Case Else
        End Select
    Case Else
End Select
    
    'Sprite dos kages
    If Player(index).Rank = RANK_KAGE Then
            Select Case Player(index).Vila
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
                Case Else
            End Select
    End If

Player(index).Trans = 0
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

If Not GetPlayerSprite(index) = TempPlayer(index).MySprite Then
    SetPlayerSprite index, TempPlayer(index).MySprite
    SendPlayerData index
End If
TempPlayer(index).Dojutsu(DojutsuNum) = 0
                
End Sub

Sub CheckNPCAttackNpc(ByVal mapNpcNum As Byte, ByVal Map As Long, ByVal X As Byte, ByVal Y As Byte, ByVal Damage As Long, Optional ByVal SpellNum As Long)
On Error Resume Next

Dim Count As Byte
Count = 1
Do While Count < 30
If MapNpc(Map).Npc(Count).X = X And MapNpc(Map).Npc(Count).Y = Y Then
        Call NpcAttackNpc(Map, mapNpcNum, Count, Damage)
         If SpellNum > 0 Then
            If Spell(SpellNum).StunDuration > 0 Then
                MapNpc(Map).Npc(Count).StunDuration = Spell(SpellNum).StunDuration
                MapNpc(Map).Npc(Count).StunTimer = GetTickCount
            End If
            If Spell(SpellNum).IsPush = YES Then NpcPuxarNPC Map, mapNpcNum, Count
            NpcExpelirNpc mapNpcNum, mapNpcNum, Count, SpellNum
         End If
    Exit Sub
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

Public Sub NpcPuxarNPC(ByVal mapNum As Long, ByVal mapNpcNum As Byte, ByVal Victim As Byte)

Dim Dist, MapX, mapY, NpcX, NpcY As Byte

If mapNum < 1 Or mapNum > MAX_MAPS Then Exit Sub
If mapNpcNum < 1 Or mapNpcNum > MAX_MAP_NPCS Then Exit Sub
If Victim < 1 Or Victim > MAX_MAP_NPCS Then Exit Sub

MapX = Map(mapNum).MaxX
mapY = Map(mapNum).MaxY
NpcX = MapNpc(mapNum).Npc(mapNpcNum).X
NpcY = MapNpc(mapNum).Npc(mapNpcNum).Y

Select Case MapNpc(mapNum).Npc(mapNpcNum).Dir
    Case DIR_UP
        Dist = NpcY - 1
        If Dist < 1 Then Dist = 0
        MapNpc(mapNum).Npc(Victim).Y = Dist
        Dist = NpcX
        MapNpc(mapNum).Npc(Victim).X = Dist
        MapNpc(mapNum).Npc(Victim).Dir = DIR_DOWN
        
    Case DIR_DOWN
        Dist = NpcY + 1
        If Dist > mapY Then Dist = mapY
        MapNpc(mapNum).Npc(Victim).Y = Dist
        Dist = NpcX
        MapNpc(mapNum).Npc(Victim).X = Dist
        MapNpc(mapNum).Npc(Victim).Dir = DIR_UP
        
    Case DIR_RIGHT
        Dist = NpcX + 1
        If Dist > MapX Then Dist = MapX
        MapNpc(mapNum).Npc(Victim).X = Dist
        Dist = NpcY
        MapNpc(mapNum).Npc(Victim).Y = Dist
        MapNpc(mapNum).Npc(Victim).Dir = DIR_LEFT
        
    Case DIR_LEFT
        Dist = NpcX - 1
        If Dist < 1 Then Dist = 0
        MapNpc(mapNum).Npc(Victim).X = Dist
        Dist = NpcY
        MapNpc(mapNum).Npc(Victim).Y = Dist
        MapNpc(mapNum).Npc(Victim).Dir = DIR_RIGHT
End Select

SendMapNpcsToMap mapNum
        
End Sub


Public Sub NpcMagiaArea(ByVal mapNum As Long, ByVal mapNpcNum As Byte, ByVal SpellNum As Long)

If mapNum < 1 Or mapNum > MAX_MAPS Then Exit Sub
If mapNpcNum < 1 Or mapNpcNum > MAX_MAP_NPCS Then Exit Sub
If SpellNum < 1 Or SpellNum > MAX_SPELLS Then Exit Sub

Dim Dano, Anim, NpcNum As Long
Dim X, Y, i, I2, Dist As Byte

Dist = Spell(SpellNum).Dist
Anim = Spell(SpellNum).RetaAnim(1)
X = MapNpc(mapNum).Npc(mapNpcNum).X
Y = MapNpc(mapNum).Npc(mapNpcNum).Y
NpcNum = MapNpc(mapNum).Npc(mapNpcNum).num

If MapNpc(mapNum).Npc(mapNpcNum).IsPet Then
    If MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner > 0 Then
        Select Case NpcNum
            Case 124 'Katsuyu
                Dano = RAND(1, GetPlayerStat(MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner, Stats.Willpower) * 3.5 + Npc(Map(mapNum).Npc(mapNpcNum)).Damage / 2)
            Case 125 'Manda
                Dano = RAND(1, GetPlayerStat(MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner, Stats.Intelligence) * 3.5 + Npc(Map(mapNum).Npc(mapNpcNum)).Damage / 2)
            Case Else
                Dano = RAND(1, GetPlayerStat(MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner, Stats.strength) * 3.5 + Npc(Map(mapNum).Npc(mapNpcNum)).Damage / 2)
        End Select
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


For i = 1 To Dist
    For I2 = 1 To Dist
        SendAnimation mapNum, Anim, X, Y - i
        CheckNPCAttackNpc mapNpcNum, mapNum, X, Y - i, Dano, SpellNum
        SendAnimation mapNum, Anim, X - I2, Y - i
        CheckNPCAttackNpc mapNpcNum, mapNum, X - I2, Y - i, Dano, SpellNum
        SendAnimation mapNum, Anim, X + I2, Y - i
        CheckNPCAttackNpc mapNpcNum, mapNum, X + I2, Y - 1, Dano, SpellNum

        SendAnimation mapNum, Anim, X, Y + i
        CheckNPCAttackNpc mapNpcNum, mapNum, X, Y + i, Dano, SpellNum
        SendAnimation mapNum, Anim, X - I2, Y + i
        CheckNPCAttackNpc mapNpcNum, mapNum, X - I2, Y + i, Dano, SpellNum
        SendAnimation mapNum, Anim, X + I2, Y + i
        CheckNPCAttackNpc mapNpcNum, mapNum, X + I2, Y + i, Dano, SpellNum
    
        SendAnimation mapNum, Anim, X - i, Y
        CheckNPCAttackNpc mapNpcNum, mapNum, X - i, Y, Dano, SpellNum

        SendAnimation mapNum, Anim, X + i, Y
        CheckNPCAttackNpc mapNpcNum, mapNum, X + i, Y, Dano, SpellNum
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
            Case 124 'Katsuyu
                Forca = GetPlayerStat(MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner, Stats.Willpower) * 3.5 + Npc(Map(mapNum).Npc(mapNpcNum)).Damage / 2
            Case 125 'Manda
                Forca = GetPlayerStat(MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner, Stats.Intelligence) * 3.5 + Npc(Map(mapNum).Npc(mapNpcNum)).Damage / 2
            Case Else
                Forca = GetPlayerStat(MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner, Stats.strength) * 3.5 + Npc(Map(mapNum).Npc(mapNpcNum)).Damage / 2
        End Select
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

For i = 1 To Dist
Select Case MapNpc(mapNum).Npc(mapNpcNum).Dir
Case DIR_UP

SendAnimation mapNum, Anim, X, Y - i
Call CheckNPCAttackNpc(mapNpcNum, mapNum, X, Y - i, Forca, SpellNum)

If largura > 0 Then
  For larg = 1 To largura
    
    Select Case i
    Case 1
       
    Case 2
        SendAnimation mapNum, Anim, X - 1, Y - i
        SendAnimation mapNum, Anim, X + 1, Y - i
        Call CheckNPCAttackNpc(mapNpcNum, mapNum, X - 1, Y - i, Forca, SpellNum)
        Call CheckNPCAttackNpc(mapNpcNum, mapNum, X + 1, Y - i, Forca, SpellNum)
    Case Else
        SendAnimation mapNum, Anim, X - larg, Y - i
        SendAnimation mapNum, Anim, X + larg, Y - i
        Call CheckNPCAttackNpc(mapNpcNum, mapNum, X - larg, Y - i, Forca, SpellNum)
        Call CheckNPCAttackNpc(mapNpcNum, mapNum, X + larg, Y - i, Forca, SpellNum)
    End Select
    
  Next
End If

Case DIR_DOWN
If Spell(SpellNum).MultiAnim = YES Then
    Anim = Spell(SpellNum).RetaAnim(2)
End If

SendAnimation mapNum, Anim, X, Y + i
Call CheckNPCAttackNpc(mapNpcNum, mapNum, X, Y + i, Forca, SpellNum)

If largura > 0 Then
  For larg = 1 To largura
  
    Select Case i
    Case 1
       
    Case 2
        SendAnimation mapNum, Anim, X - 1, Y + i
        SendAnimation mapNum, Anim, X + 1, Y + i
        Call CheckNPCAttackNpc(mapNpcNum, mapNum, X - 1, Y + i, Forca, SpellNum)
        Call CheckNPCAttackNpc(mapNpcNum, mapNum, X + 1, Y + i, Forca, SpellNum)
    Case Else
        SendAnimation mapNum, Anim, X - larg, Y + i
        SendAnimation mapNum, Anim, X + larg, Y + i
        Call CheckNPCAttackNpc(mapNpcNum, mapNum, X - larg, Y + i, Forca, SpellNum)
        Call CheckNPCAttackNpc(mapNpcNum, mapNum, X + larg, Y + i, Forca, SpellNum)
    End Select

  Next
End If

Case DIR_LEFT
If Spell(SpellNum).MultiAnim = YES Then
    Anim = Spell(SpellNum).RetaAnim(3)
End If

SendAnimation mapNum, Anim, X - i, Y
Call CheckNPCAttackNpc(mapNpcNum, mapNum, X - i, Y, Forca, SpellNum)

If largura > 0 Then
  For larg = 1 To largura
  
    Select Case i
    Case 1
       
    Case 2
        SendAnimation mapNum, Anim, X - i, Y - 1
        SendAnimation mapNum, Anim, X - i, Y + 1
        Call CheckNPCAttackNpc(mapNpcNum, mapNum, X - i, Y - 1, Forca, SpellNum)
        Call CheckNPCAttackNpc(mapNpcNum, mapNum, X - i, Y + 1, Forca, SpellNum)
    Case Else
        SendAnimation mapNum, Anim, X - i, Y + larg
        SendAnimation mapNum, Anim, X - i, Y - larg
        Call CheckNPCAttackNpc(mapNpcNum, mapNum, X - i, Y + larg, Forca, SpellNum)
        Call CheckNPCAttackNpc(mapNpcNum, mapNum, X - i, Y - larg, Forca, SpellNum)
    End Select
  
  Next
End If

Case DIR_RIGHT
If Spell(SpellNum).MultiAnim = YES Then
    Anim = Spell(SpellNum).RetaAnim(4)
End If

SendAnimation mapNum, Anim, X + i, Y
Call CheckNPCAttackNpc(mapNpcNum, mapNum, X + i, Y, Forca, SpellNum)

If largura > 0 Then
  For larg = 1 To largura
  
    Select Case i
        Case 1
       
        Case 2
            SendAnimation mapNum, Anim, X + i, Y - 1
            SendAnimation mapNum, Anim, X + i, Y + 1
            Call CheckNPCAttackNpc(mapNpcNum, mapNum, X + i, Y - 1, Forca, SpellNum)
            Call CheckNPCAttackNpc(mapNpcNum, mapNum, X + i, Y + 1, Forca, SpellNum)
        Case Else
            SendAnimation mapNum, Anim, X + i, Y + larg
            SendAnimation mapNum, Anim, X + i, Y - larg
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
If mapNpcNum < 1 Or mapNpcNum > MAX_MAP_NPCS Then Exit Sub
If mapNum < 1 Or mapNum > MAX_MAPS Then Exit Sub
If SpellNum < 1 Or SpellNum > MAX_SPELLS Then Exit Sub

Alvo = MapNpc(mapNum).Npc(mapNpcNum).Target

If Alvo < 1 Then Exit Sub
Select Case MapNpc(mapNum).Npc(mapNpcNum).targetType
    Case TARGET_TYPE_PLAYER
        If isInRange(Spell(SpellNum).Range, MapNpc(mapNum).Npc(mapNpcNum).X, MapNpc(mapNum).Npc(mapNpcNum).Y, GetPlayerX(Alvo), GetPlayerY(Alvo)) Then
            If Not MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner = Alvo Then
                NpcAttackPlayer mapNpcNum, Alvo, GetNpcDamage(MapNpc(mapNum).Npc(mapNpcNum).num)
                SendAnimation mapNum, Spell(SpellNum).SpellAnim, 0, 0, TARGET_TYPE_PLAYER, Alvo
            End If
        End If
    Case TARGET_TYPE_NPC
        If isInRange(Spell(SpellNum).Range, MapNpc(mapNum).Npc(mapNpcNum).X, MapNpc(mapNum).Npc(mapNpcNum).Y, MapNpc(mapNum).Npc(Alvo).X, MapNpc(mapNum).Npc(Alvo).Y) Then
            'If CanNpcAttackNpc(mapNum, MapNpcNum, Alvo) Then
                NpcAttackNpc mapNum, mapNpcNum, Alvo, GetNpcDamage(MapNpc(mapNum).Npc(mapNpcNum).num)
                SendAnimation mapNum, Spell(SpellNum).SpellAnim, 0, 0, TARGET_TYPE_NPC, Alvo
            'End If
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

Public Sub OrgJutsu(ByVal index As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
Dim i As Byte

If EspecialJutsu(index) > 0 Then Exit Sub
If Player(index).Org < 1 Then Exit Sub

Select Case Player(index).Org
    Case ORG_TAKA, ORG_7ESPADACHINS, ORG_AKATSUKI, ORG_ANBURAIZ, ORG_12GUARDIOES
        Select Case GetPlayerClass(index)
            Case 1, 3, 6, 7, 8, 9, 10, 13, 15, 17, 21, 22, 23 'Taijutsu
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
            Case 2, 4, 5, 11, 12, 14, 16, 18, 19, 20, 24, 25 'Ninjutsu
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
            
            Case Else
        End Select
    Case ORG_HOSPITAL
        SetPlayerSpell index, FindOpenSpellSlot(index), 131
        SetPlayerSpell index, FindOpenSpellSlot(index), 132
        PlayerMsg index, "Você aprendeu " & Spell(131).Name, BrightBlue
        PlayerMsg index, "Você aprendeu " & Spell(132).Name, BrightBlue
        
    Case ORG_POLICIAKONOHA
        SetPlayerSpell index, FindOpenSpellSlot(index), 134
        PlayerMsg index, "Você aprendeu " & Spell(134).Name, BrightBlue
    Case Else
        If Player(index).Rank = RANK_KAGE Then
            Select Case GetPlayerClass(index)
                Case 1, 3, 6, 7, 8, 9, 10, 13, 15, 17, 21, 22, 23 'Taijutsu
                    SetPlayerSpell index, FindOpenSpellSlot(index), 142
                    PlayerMsg index, "Você aprendeu " & Spell(142).Name, BrightBlue
                Case 2, 4, 5, 11, 12, 14, 16, 18, 19, 20, 24, 25 'Ninjutsu
                    SetPlayerSpell index, FindOpenSpellSlot(index), 143
                    PlayerMsg index, "Você aprendeu " & Spell(143).Name, BrightBlue
                Case Else
            End Select
        End If

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

Public Function IsBlocked(ByVal index As Long, ByVal X As Byte, ByVal Y As Byte, ByVal Dir As Byte) As Byte
If index < 1 Or index > MAX_PLAYERS Then Exit Function
If X < 1 Or X > MAX_BYTE Then Exit Function
If Y < 1 Or Y > MAX_BYTE Then Exit Function

IsBlocked = YES

If Not isDirBlocked(Map(GetPlayerMap(index)).Tile(X, Y).DirBlock, Dir) Then
    If Map(GetPlayerMap(index)).Tile(X, Y).Type <> TILE_TYPE_BLOCKED Then
        If Map(GetPlayerMap(index)).Tile(X, Y).Type <> TILE_TYPE_RESOURCE Then
            If Map(GetPlayerMap(index)).Tile(X, Y).Type <> TILE_TYPE_KEY Or (Map(GetPlayerMap(index)).Tile(X, Y).Type = TILE_TYPE_KEY And TempTile(GetPlayerMap(index)).DoorOpen(X, Y) = YES) Then
                IsBlocked = NO
            End If
        End If
    End If
End If

End Function

Public Sub setKarma(ByVal index As Integer, ByVal Vitima As Integer)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If Vitima < 1 Or Vitima > MAX_PLAYERS Then Exit Sub

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
             
If Update = YES Then
    For i = 1 To Player_HighIndex
        SendKarmaPic i
    Next
    
    SalvarKarma
End If
        
    
End Sub

Public Sub AtualizarPVP(ByVal index As Long, ByVal Vitima As Long)
'On Error Resume Next
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If Vitima < 1 Or Vitima > MAX_PLAYERS Then Exit Sub

If GetPlayerAccess(index) > 1 Then Exit Sub

'Vencedor ganhou 1 vitoria
Player(index).PvP.V = Player(index).PvP.V + 1
'Vitima ganhou 1 derrota
Player(Vitima).PvP.D = Player(Vitima).PvP.D + 1

Dim i As Byte
Dim MyRank As Byte

For i = 1 To 10
    If TopPvP(i).Nome = GetPlayerName(index) Then
        MyRank = i
        Exit For
    End If
Next

    If MyRank > 1 And MyRank < 11 Then
        If TopPvP(MyRank - 1).V < Player(index).PvP.V Then
            TopPvP(MyRank).D = TopPvP(MyRank - 1).D
            TopPvP(MyRank).V = TopPvP(MyRank - 1).V
            TopPvP(MyRank).Nome = TopPvP(MyRank - 1).Nome
            TopPvP(MyRank - 1).D = Player(index).PvP.D
            TopPvP(MyRank - 1).V = Player(index).PvP.V
            TopPvP(MyRank - 1).Nome = GetPlayerName(index)
            GlobalMsg GetPlayerName(index) & " subiu para o " & MyRank - 1 & "° lugar no Top Player.X.Player!(digite /top)", BrightCyan
            SalvarPVP
        Else
            TopPvP(MyRank).D = Player(index).PvP.D
            TopPvP(MyRank).V = Player(index).PvP.V
            TopPvP(MyRank).Nome = GetPlayerName(index)
            SalvarPVP
        End If
    Else
        If Not GetPlayerName(index) = TopPvP(1).Nome Then
            TopPvP(10).D = Player(index).PvP.D
            TopPvP(10).V = Player(index).PvP.V
            TopPvP(10).Nome = GetPlayerName(index)
            GlobalMsg GetPlayerName(index) & " subiu para o 10° lugar no Top Player.X.Player!(digite /top)", BrightCyan
            SalvarPVP
        End If
        
        If MyRank = 1 Then
            TopPvP(1).D = Player(index).PvP.D
            TopPvP(1).V = Player(index).PvP.V
            TopPvP(1).Nome = GetPlayerName(index)
            SalvarPVP
        End If
    End If

CarregarPVP

For i = 1 To Player_HighIndex
    SendPvpPic i
Next

'PlayerMsg index, Player(index).PvP.V & "v", White
'PlayerMsg index, Player(index).PvP.D & "d", White
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

Public Sub CarregarTopORG()
'On Error Resume Next
Dim i As Byte

For i = 1 To 9
    TopOrg(i).Nome = GetVar(App.Path & "\Tops\Org.txt", "ORG" & i, "Nome")
    TopOrg(i).Pts = GetVar(App.Path & "\Tops\Org.txt", "ORG" & i, "Pts")
Next

End Sub

Public Sub SalvarTopORG()
'On Error Resume Next
Dim i As Byte

For i = 1 To 9
    PutVar App.Path & "\Tops\Org.txt", "ORG" & i, "Nome", TopOrg(i).Nome
    PutVar App.Path & "\Tops\Org.txt", "ORG" & i, "Pts", TopOrg(i).Pts
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
Dim i As Long
Dim n As Byte

For n = 1 To 20
    For i = 1 To Player_HighIndex
        If TopLvl(n).Nome = GetPlayerName(i) Then
            TopLvl(n).Nivel = Player(i).Level
            SalvarTop
        End If
    Next
Next

For n = 1 To MAX_CLASS_TEMP
    For i = 1 To Player_HighIndex
        If TopChar(n).Nome = GetPlayerName(i) Then
            TopChar(n).Level = GetPlayerLevel(i)
            SalvarTopChar
        End If
    Next
Next

    CarregarTopORG


For n = 1 To 10
    For i = 1 To Player_HighIndex
        If TopHero(n).Nome = GetPlayerName(i) Then
            TopHero(n).Pts = Player(i).Karma
            SalvarKarma
        End If
        
        If TopPK(n).Nome = GetPlayerName(i) Then
            TopPK(n).Pts = Player(i).Karma
            SalvarKarma
        End If
        
        If TopPvP(n).Nome = GetPlayerName(i) Then
            TopPvP(n).V = Player(i).PvP.V
            TopPvP(n).D = Player(i).PvP.D
            SalvarPVP
        End If
        
        SendTopPic i
        SendKarmaPic i
        SendPvpPic i
        SendOrgPic i
        SendCharPic i
    Next
Next
        
End Sub

Public Sub ZerarArenas()
Dim ArenaNum As Byte

For ArenaNum = 1 To 5
    If PlayersOnMap(Arena(ArenaNum).Map) = NO Then
        Arena(ArenaNum).IsActive = NO
        Arena(ArenaNum).Player(1) = NO
        Arena(ArenaNum).Player(2) = NO
    End If
Next
        
End Sub

Public Sub ZerarDesafio(ByVal Atk As Long, ByVal Vitima As Long, Optional ByVal LeftGame As Byte)
If IsPlaying(Atk) = False Then Exit Sub

If LeftGame = NO Then
    If IsPlaying(Vitima) = False Then Exit Sub
Else
    PlayerMsg Atk, "Parece que seu parceiro de combate desistiu..", Green
End If

Dim ArenaNum As Byte

ArenaNum = TempPlayer(Atk).InArena

'zerando players
TempPlayer(Atk).InDesafio = NO
TempPlayer(Atk).InArena = NO
TempPlayer(Atk).IsDesafio = NO
TempPlayer(Vitima).InDesafio = NO
TempPlayer(Vitima).InArena = NO
TempPlayer(Vitima).IsDesafio = NO

'zerando Arena
Arena(ArenaNum).IsActive = NO
Arena(ArenaNum).Player(1) = NO
Arena(ArenaNum).Player(2) = NO

PlayerWarp Atk, 99, 10, 6 'Atendimento
If LeftGame = NO Then
    PlayerWarp Vitima, 99, 10, 6 'Atendimento
Else 'Se o player não tiver online,precisa mandar ele pro atendimento manualmente pq o playerwarp só pega se o cara tiver Online
    SetPlayerMap Vitima, 99
    SetPlayerX Vitima, 10
    SetPlayerY Vitima, 6
End If

If LeftGame = NO Then 'Só vai contar caso o cara não tenha saido do game
    AtualizarPVP Atk, Vitima
End If

End Sub

Public Sub HandleProjecTile(ByVal index As Long, ByVal PlayerProjectile As Long)
Dim X As Long, Y As Long, i As Long
Dim Anim As Byte
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
                        PlayerAttackPlayer index, i, TempPlayer(index).ProjecTile(PlayerProjectile).Damage
                        ClearProjectile index, PlayerProjectile
                        CheckHits index, i
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
                ClearProjectile index, PlayerProjectile
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

Public Sub SendArrow(ByVal index As Long, ByVal Pic As Integer, ByVal Range As Byte, ByVal Dano As Long, ByVal Speed As Long, Optional ByVal Anim As Long)
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
        .X = GetPlayerX(index)
        .Y = GetPlayerY(index)
        .Anim = Anim
    End With
    
    ' update the projectile on the map
    SendProjectileToMap index, curProjecTile
End Sub
