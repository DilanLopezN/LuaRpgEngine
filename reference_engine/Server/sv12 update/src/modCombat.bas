Attribute VB_Name = "modCombat"
Option Explicit

' ################################
' ##      Basic Calculations    ##
' ################################

Function GetPlayerMaxVital(ByVal index As Long, ByVal Vital As Vitals) As Long
    If index > MAX_PLAYERS Then Exit Function
    Select Case Vital
        Case HP
            Select Case GetPlayerClass(index)
                Case 1, 3, 6, 7, 8, 9, 10, 13 ' Fisico
                    GetPlayerMaxVital = ((GetPlayerLevel(index) / 2) + (GetPlayerStat(index, Stats.Endurance) / 2)) * 25 + 150
                    If GetPlayerMaxVital < 1 Then GetPlayerMaxVital = 1
                Case 2, 4, 5, 11, 12, 14 ' Ninjutsu
                    GetPlayerMaxVital = ((GetPlayerLevel(index) / 2) + (GetPlayerStat(index, Stats.Endurance) / 2)) * 15 + 65
                    If GetPlayerMaxVital < 1 Then GetPlayerMaxVital = 1
                Case Else ' Anything else - Warrior by default
                    GetPlayerMaxVital = ((GetPlayerLevel(index) / 2) + (GetPlayerStat(index, Stats.Endurance) / 2)) * 25 + 150
                    If GetPlayerMaxVital < 1 Then GetPlayerMaxVital = 1
            End Select
        Case mp
            Select Case GetPlayerClass(index)
                Case 1, 3, 6, 7, 8, 9, 10, 13 ' Fisico
                    GetPlayerMaxVital = ((GetPlayerLevel(index) / 2) + (GetPlayerStat(index, Stats.Intelligence) / 2)) * 5 + 25
                    If GetPlayerMaxVital < 1 Then GetPlayerMaxVital = 1
                Case 2, 4, 5, 11, 12, 14 ' Ninjutsu
                    GetPlayerMaxVital = ((GetPlayerLevel(index) / 2) + (GetPlayerStat(index, Stats.Intelligence) / 2)) * 30 + 85
                    If GetPlayerMaxVital < 1 Then GetPlayerMaxVital = 1
                Case Else ' Anything else - Warrior by default
                    GetPlayerMaxVital = ((GetPlayerLevel(index) / 2) + (GetPlayerStat(index, Stats.Intelligence) / 2)) * 5 + 25
                    If GetPlayerMaxVital < 1 Then GetPlayerMaxVital = 1
            End Select
    End Select
    
    
    
   
End Function

Function GetPlayerVitalRegen(ByVal index As Long, ByVal Vital As Vitals) As Long
    Dim i As Long

    ' Prevent subscript out of range
    If IsPlaying(index) = False Or index <= 0 Or index > MAX_PLAYERS Then
        GetPlayerVitalRegen = 0
        Exit Function
    End If

    Select Case Vital
        Case HP
            i = (GetPlayerStat(index, Stats.Endurance) * 0.8) + 6
        Case mp
            i = (GetPlayerStat(index, Stats.Intelligence) / 4) + 12.5
    End Select

    If i < 2 Then i = 2
    GetPlayerVitalRegen = i
End Function

Function GetPlayerDamage(ByVal index As Long) As Long
    Dim weaponNum As Long
    
    GetPlayerDamage = 0

    ' Check for subscript out of range
    If IsPlaying(index) = False Or index <= 0 Or index > MAX_PLAYERS Then
        Exit Function
    End If
    If GetPlayerEquipment(index, Weapon) > 0 Then
        weaponNum = GetPlayerEquipment(index, Weapon)
        GetPlayerDamage = 0.085 * 5 * GetPlayerStat(index, strength) * Item(weaponNum).Data2 + (GetPlayerLevel(index) / 5)
    Else
        GetPlayerDamage = 0.085 * 5 * GetPlayerStat(index, strength) + (GetPlayerLevel(index) / 5)
    End If

End Function

Function GetNpcMaxVital(ByVal NpcNum As Long, ByVal Vital As Vitals) As Long
    Dim X As Long

    ' Prevent subscript out of range
    If NpcNum <= 0 Or NpcNum > MAX_NPCS Then
        GetNpcMaxVital = 0
        Exit Function
    End If

    Select Case Vital
        Case HP
            GetNpcMaxVital = Npc(NpcNum).HP
        Case mp
            GetNpcMaxVital = 30 + (Npc(NpcNum).Stat(Intelligence) * 10) + 2
    End Select

End Function

Function GetNpcVitalRegen(ByVal NpcNum As Long, ByVal Vital As Vitals) As Long
    Dim i As Long

    'Prevent subscript out of range
    If NpcNum <= 0 Or NpcNum > MAX_NPCS Then
        GetNpcVitalRegen = 0
        Exit Function
    End If

    Select Case Vital
        Case HP
            i = (Npc(NpcNum).Stat(Stats.Willpower) * 0.8) + 6
        Case mp
            i = (Npc(NpcNum).Stat(Stats.Willpower) / 4) + 12.5
    End Select
    
    GetNpcVitalRegen = i

End Function

Function GetNpcDamage(ByVal NpcNum As Long) As Long
    GetNpcDamage = 0.085 * 5 * Npc(NpcNum).Stat(Stats.strength) * Npc(NpcNum).Damage + (Npc(NpcNum).Level / 5)
End Function

' ###############################
' ##      Luck-based rates     ##
' ###############################

Public Function CanPlayerBlock(ByVal index As Long) As Boolean
Dim rate As Long
Dim rndNum As Long

    CanPlayerBlock = False

    rate = 0
    ' TODO : make it based on shield lulz
End Function

Public Function CanPlayerCrit(ByVal index As Long) As Boolean
Dim rate As Long
Dim rndNum As Long

    CanPlayerCrit = False

    rate = GetPlayerStat(index, Agility) / 100
    rndNum = RAND(1, 100)
    If rndNum <= rate Then
        CanPlayerCrit = True
    End If
End Function

Public Function CanPlayerDodge(ByVal index As Long) As Boolean
Dim rate As Long
Dim rndNum As Long

    CanPlayerDodge = False

    rate = GetPlayerStat(index, Agility) / 50
    rndNum = RAND(1, 100)
    If rndNum <= rate Then
        CanPlayerDodge = True
    End If
End Function

Public Function CanPlayerParry(ByVal index As Long) As Boolean
Dim rate As Long
Dim rndNum As Long

    CanPlayerParry = False

    rate = GetPlayerStat(index, strength) / 80
    rndNum = RAND(1, 100)
    If rndNum <= rate Then
        CanPlayerParry = True
    End If
End Function

Public Function CanNpcBlock(ByVal NpcNum As Long) As Boolean
Dim rate As Long
Dim rndNum As Long

    CanNpcBlock = False

    rate = 0
    ' TODO : make it based on shield lol
End Function

Public Function CanNpcCrit(ByVal NpcNum As Long) As Boolean
Dim rate As Long
Dim rndNum As Long

    CanNpcCrit = False

    rate = Npc(NpcNum).Stat(Stats.Agility) / 52.08
    rndNum = RAND(1, 100)
    If rndNum <= rate Then
        CanNpcCrit = True
    End If
End Function

Public Function CanNpcDodge(ByVal NpcNum As Long) As Boolean
Dim rate As Long
Dim rndNum As Long

    CanNpcDodge = False

    rate = Npc(NpcNum).Stat(Stats.Agility) / 83.3
    rndNum = RAND(1, 100)
    If rndNum <= rate Then
        CanNpcDodge = True
    End If
End Function

Public Function CanNpcParry(ByVal NpcNum As Long) As Boolean
Dim rate As Long
Dim rndNum As Long

    CanNpcParry = False

    rate = Npc(NpcNum).Stat(Stats.strength) * 0.25
    rndNum = RAND(1, 100)
    If rndNum <= rate Then
        CanNpcParry = True
    End If
End Function

' ###################################
' ##      Player Attacking NPC     ##
' ###################################

Public Sub TryPlayerAttackNpc(ByVal index As Long, ByVal mapNpcNum As Long)
Dim blockAmount As Long
Dim NpcNum As Long
Dim mapNum As Long
Dim Damage As Long

    Damage = 0

    ' Can we attack the npc?
    If CanPlayerAttackNpc(index, mapNpcNum) Then
    
        mapNum = GetPlayerMap(index)
        NpcNum = MapNpc(mapNum).Npc(mapNpcNum).num
    
        ' check if NPC can avoid the attack
        If CanNpcDodge(NpcNum) Then
            SendActionMsg mapNum, "Esquivou!", Magenta, 1, (MapNpc(mapNum).Npc(mapNpcNum).X * 32), (MapNpc(mapNum).Npc(mapNpcNum).Y * 32)
            Exit Sub
        End If
        If CanNpcParry(NpcNum) Then
            SendActionMsg mapNum, "Defendeu!", Green, 1, (MapNpc(mapNum).Npc(mapNpcNum).X * 32), (MapNpc(mapNum).Npc(mapNpcNum).Y * 32)
            Exit Sub
        End If

        ' Get the damage we can do
        Damage = GetPlayerDamage(index)
        
        ' if the npc blocks, take away the block amount
        blockAmount = CanNpcBlock(mapNpcNum)
        Damage = Damage - blockAmount
        
        ' take away armour
        Damage = Damage - RAND(1, (Npc(NpcNum).Stat(Stats.Agility) * 2))
        ' randomise from 1 to max hit
        Damage = RAND(1, Damage)
        
        ' * 1.5 if it's a crit!
        If CanPlayerCrit(index) Then
            Damage = Damage * 1.5
            SendActionMsg mapNum, "Crítico!", BrightCyan, 1, (GetPlayerX(index) * 32), (GetPlayerY(index) * 32)
        End If
            
        If Damage > 0 Then
            If Not TempPlayer(index).Target = mapNpcNum Then
               TempPlayer(index).Target = mapNpcNum
               TempPlayer(index).targetType = TARGET_TYPE_NPC
               SendTarget index
            End If
        
            Call PlayerAttackNpc(index, mapNpcNum, Damage)
            CheckHits index, mapNpcNum
        Else
            Call PlayerMsg(index, "Seu ataque é ridículo.", BrightRed)
        End If
    End If
End Sub

Public Function CanPlayerAttackNpc(ByVal Attacker As Long, ByVal mapNpcNum As Long, Optional ByVal IsSpell As Boolean = False) As Boolean
    Dim mapNum As Long
    Dim NpcNum As Long
    Dim NpcX As Long
    Dim NpcY As Long
    Dim attackspeed As Long

    ' Check for subscript out of range
    If IsPlaying(Attacker) = False Or mapNpcNum <= 0 Or mapNpcNum > MAX_MAP_NPCS Then
        Exit Function
    End If

    ' Check for subscript out of range
    If MapNpc(GetPlayerMap(Attacker)).Npc(mapNpcNum).num <= 0 Then
        Exit Function
    End If

    mapNum = GetPlayerMap(Attacker)
    NpcNum = MapNpc(mapNum).Npc(mapNpcNum).num
    
    ' Make sure the npc isn't already dead
    If MapNpc(mapNum).Npc(mapNpcNum).Vital(Vitals.HP) <= 0 Then
        Exit Function
    End If

    ' Make sure they are on the same map
    If IsPlaying(Attacker) Then
    
    If MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner = Attacker Then Exit Function
    
        ' exit out early
        If IsSpell Then
             If NpcNum > 0 Then
                If Npc(NpcNum).Behaviour <> NPC_BEHAVIOUR_FRIENDLY And Npc(NpcNum).Behaviour <> NPC_BEHAVIOUR_SHOPKEEPER Then
                    CanPlayerAttackNpc = True
                    Exit Function
                End If
            End If
        End If

        ' attack speed from weapon
        If GetPlayerEquipment(Attacker, Weapon) > 0 Then
            attackspeed = Item(GetPlayerEquipment(Attacker, Weapon)).Speed
        Else
            attackspeed = 1000
        End If

        If NpcNum > 0 And GetTickCount > TempPlayer(Attacker).AttackTimer + attackspeed Then
            ' Check if at same coordinates
            Select Case GetPlayerDir(Attacker)
                Case DIR_UP
                    NpcX = MapNpc(mapNum).Npc(mapNpcNum).X
                    NpcY = MapNpc(mapNum).Npc(mapNpcNum).Y + 1
                Case DIR_DOWN
                    NpcX = MapNpc(mapNum).Npc(mapNpcNum).X
                    NpcY = MapNpc(mapNum).Npc(mapNpcNum).Y - 1
                Case DIR_LEFT
                    NpcX = MapNpc(mapNum).Npc(mapNpcNum).X + 1
                    NpcY = MapNpc(mapNum).Npc(mapNpcNum).Y
                Case DIR_RIGHT
                    NpcX = MapNpc(mapNum).Npc(mapNpcNum).X - 1
                    NpcY = MapNpc(mapNum).Npc(mapNpcNum).Y
            End Select

            If NpcX = GetPlayerX(Attacker) Then
                If NpcY = GetPlayerY(Attacker) Then
                
                Dim i As Byte
                  For i = 1 To 10
                     If Player(Attacker).QuestNum(i) > 0 Then
                        If Quest(Player(Attacker).QuestNum(i)).Tipo = QUEST_TYPE_TALKTO Then
                           CheckQuestTalk Attacker, i, NpcNum
                        End If
                     End If
                  Next
                
                If Npc(MapNpc(mapNum).Npc(mapNpcNum).num).Script > 0 Then
                      ScriptedNpc Attacker, Npc(MapNpc(mapNum).Npc(mapNpcNum).num).Script, mapNpcNum
                  End If
                
                    If Npc(NpcNum).Behaviour <> NPC_BEHAVIOUR_FRIENDLY And Npc(NpcNum).Behaviour <> NPC_BEHAVIOUR_SHOPKEEPER Then
                        CanPlayerAttackNpc = True
                    Else
                        If Not Npc(NpcNum).AttackSay = "                    " Then
                            PlayerMsg Attacker, Trim$(Npc(NpcNum).Name) & ": " & Trim$(Npc(NpcNum).AttackSay), White
                        End If
                    End If
                End If
            End If
        End If
    End If

End Function

Public Sub PlayerAttackNpc(ByVal Attacker As Long, ByVal mapNpcNum As Long, ByVal Damage As Long, Optional ByVal SpellNum As Long, Optional ByVal overTime As Boolean = False)
    On Error Resume Next
    Dim PetOwner As Long
    Dim Name As String
    Dim EXP As Long
    Dim n As Long
    Dim i As Long
    Dim STR As Long
    Dim DEF As Long
    Dim mapNum As Long
    Dim NpcNum As Long
    Dim Buffer As clsBuffer

    ' Check for subscript out of range
    If IsPlaying(Attacker) = False Or mapNpcNum <= 0 Or mapNpcNum > MAX_MAP_NPCS Or Damage < 0 Then
        Exit Sub
    End If

    mapNum = GetPlayerMap(Attacker)
    
    NpcNum = MapNpc(mapNum).Npc(mapNpcNum).num
    
    If NpcNum < 1 Or NpcNum > MAX_NPCS Then Exit Sub
    
    Name = Trim$(Npc(NpcNum).Name)
    
    ' Check for weapon
    n = 0

    If GetPlayerEquipment(Attacker, Weapon) > 0 Then
        n = GetPlayerEquipment(Attacker, Weapon)
    End If
    
    ' set the regen timer
    TempPlayer(Attacker).stopRegen = True
    TempPlayer(Attacker).stopRegenTimer = GetTickCount

    If Damage >= MapNpc(mapNum).Npc(mapNpcNum).Vital(Vitals.HP) Then
    
        SendActionMsg GetPlayerMap(Attacker), "-" & MapNpc(mapNum).Npc(mapNpcNum).Vital(Vitals.HP), BrightRed, 1, (MapNpc(mapNum).Npc(mapNpcNum).X * 32), (MapNpc(mapNum).Npc(mapNpcNum).Y * 32)
        SendBlood GetPlayerMap(Attacker), MapNpc(mapNum).Npc(mapNpcNum).X, MapNpc(mapNum).Npc(mapNpcNum).Y
        
        ' send the sound
        If SpellNum > 0 Then SendMapSound Attacker, MapNpc(mapNum).Npc(mapNpcNum).X, MapNpc(mapNum).Npc(mapNpcNum).Y, SoundEntity.seSpell, SpellNum
        
        ' send animation
        If n > 0 Then
            If Not overTime Then
                If SpellNum = 0 Then Call SendAnimation(mapNum, Item(GetPlayerEquipment(Attacker, Weapon)).Animation, MapNpc(mapNum).Npc(mapNpcNum).X, MapNpc(mapNum).Npc(mapNpcNum).Y)
            End If
        End If
        
        
        If MapNpc(mapNum).Npc(mapNpcNum).IsPet Then
            PetOwner = MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner
            If PetOwner > 0 Then
                PetDisband PetOwner, mapNum
            End If
        End If

        ' Calculate exp to give attacker
        EXP = Npc(NpcNum).EXP

        Dim DsH As Byte
        For DsH = 1 To Equipment.Equipment_Count - 1
            If GetPlayerEquipment(Attacker, DsH) > 0 Then
                If Item(GetPlayerEquipment(Attacker, DsH)).ExpExtra > 0 Then
                    EXP = EXP * Item(GetPlayerEquipment(Attacker, DsH)).ExpExtra / 100
                End If
            End If
        Next
        
        If Player(Attacker).VipData.VIP = 1 Then EXP = EXP * 1.5
        If Player(Attacker).VipData.VIP = 2 Then EXP = EXP * 2

        If Not frmServer.txtEventoEXP.Text = 0 Then
           EXP = EXP * frmServer.txtEventoEXP.Text * 4
        End If

        ' Make sure we dont get less then 0
        If EXP < 0 Then
            EXP = 1
        End If
    
    If Player(Attacker).Org > 0 Then
        TempPlayer(Attacker).GanhouEXP = YES
        GivePlayerEXP Attacker, EXP
    
        Dim j As Byte
        For j = 1 To Player_HighIndex
            If GetPlayerMap(Attacker) = GetPlayerMap(j) Then
                If Player(j).Org = Player(Attacker).Org Then
                    If Attacker <> j Then
                        TempPlayer(j).GanhouEXP = YES
                        GivePlayerEXP j, EXP / 2
                    End If
                End If
            End If
        Next
    Else
        ' in party?
        If TempPlayer(Attacker).inParty > 0 Then
            ' pass through party sharing function
            TempPlayer(Attacker).GanhouEXP = YES
            GivePlayerEXP Attacker, EXP / 2.5
            Party_ShareExp TempPlayer(Attacker).inParty, EXP, Attacker
        Else
            ' no party - keep exp for self
            TempPlayer(Attacker).GanhouEXP = YES
            GivePlayerEXP Attacker, EXP
        End If
    End If
        'Drop the goods if they get it
        'n = FindOpenInvSlot(Attacker, Npc(NpcNum).DropItem)
    
                        ' Open slot available?
        If Player(Attacker).VipData.VIP > 0 Then
            If (Int(Rnd * Npc(NpcNum).DropChance) + 1) = 1 Then
                'If n <> 0 Then
                    GiveItem Attacker, Npc(NpcNum).DropItem, Npc(NpcNum).DropItemValue
                'Else
                    'PlayerMsg Attacker, "Sem espaço na mochila", BrightRed
                'nd If
            End If
        Else
        
            n = Int(Rnd * Npc(NpcNum).DropChance) + 1
        
                If n = 1 Then
                    Call SpawnItem(Npc(NpcNum).DropItem, Npc(NpcNum).DropItemValue, mapNum, MapNpc(mapNum).Npc(mapNpcNum).X, MapNpc(mapNum).Npc(mapNpcNum).Y)
                End If
        End If

        For i = 1 To 10
           If Player(Attacker).QuestNum(i) > 0 Then
              If Quest(Player(Attacker).QuestNum(i)).Tipo = QUEST_TYPE_NPC Then
                 CheckQuestNPC Attacker, NpcNum, i
              End If
           End If
        Next

        ' Now set HP to 0 so we know to actually kill them in the server loop (this prevents subscript out of range)
        MapNpc(mapNum).Npc(mapNpcNum).num = 0
        MapNpc(mapNum).Npc(mapNpcNum).SpawnWait = GetTickCount
        MapNpc(mapNum).Npc(mapNpcNum).Vital(Vitals.HP) = 0
        
        ' clear DoTs and HoTs
        For i = 1 To MAX_DOTS
            With MapNpc(mapNum).Npc(mapNpcNum).DoT(i)
                .Spell = 0
                .Timer = 0
                .Caster = 0
                .StartTime = 0
                .Used = False
            End With
            
            With MapNpc(mapNum).Npc(mapNpcNum).HoT(i)
                .Spell = 0
                .Timer = 0
                .Caster = 0
                .StartTime = 0
                .Used = False
            End With
        Next
        
        ' send death to the map
        Set Buffer = New clsBuffer
        Buffer.WriteLong SNpcDead
        Buffer.WriteLong mapNpcNum
        SendDataToMap mapNum, Buffer.ToArray()
        Set Buffer = Nothing
        
        'Loop through entire map and purge NPC from targets
        For i = 1 To Player_HighIndex
            If IsPlaying(i) And IsConnected(i) Then
                If Player(i).Map = mapNum Then
                    If TempPlayer(i).targetType = TARGET_TYPE_NPC Then
                        If TempPlayer(i).Target = mapNpcNum Then
                            TempPlayer(i).Target = 0
                            TempPlayer(i).targetType = TARGET_TYPE_NONE
                            SendTarget i
                        End If
                    End If
                End If
            End If
        Next
    Else
        ' NPC not dead, just do the damage
        MapNpc(mapNum).Npc(mapNpcNum).Vital(Vitals.HP) = MapNpc(mapNum).Npc(mapNpcNum).Vital(Vitals.HP) - Damage

        ' Check for a weapon and say damage
        SendActionMsg mapNum, "-" & Damage, BrightRed, 1, (MapNpc(mapNum).Npc(mapNpcNum).X * 32), (MapNpc(mapNum).Npc(mapNpcNum).Y * 32)
        SendBlood GetPlayerMap(Attacker), MapNpc(mapNum).Npc(mapNpcNum).X, MapNpc(mapNum).Npc(mapNpcNum).Y
        
        ' send the sound
        If SpellNum > 0 Then
            SendMapSound Attacker, MapNpc(mapNum).Npc(mapNpcNum).X, MapNpc(mapNum).Npc(mapNpcNum).Y, SoundEntity.seSpell, SpellNum
        Else
            SendAnimation GetPlayerMap(Attacker), 28, 0, 0, TARGET_TYPE_NPC, mapNpcNum
        End If
        
        ' send animation
        If n > 0 Then
            If Not overTime Then
                If SpellNum = 0 Then Call SendAnimation(mapNum, Item(GetPlayerEquipment(Attacker, Weapon)).Animation, 0, 0, TARGET_TYPE_NPC, mapNpcNum)
            End If
        End If

        ' Set the NPC target to the player
        MapNpc(mapNum).Npc(mapNpcNum).targetType = 1 ' player
        MapNpc(mapNum).Npc(mapNpcNum).Target = Attacker

        ' Now check for guard ai and if so have all onmap guards come after'm
        If Npc(MapNpc(mapNum).Npc(mapNpcNum).num).Behaviour = NPC_BEHAVIOUR_GUARD Then
            For i = 1 To MAX_MAP_NPCS
                If MapNpc(mapNum).Npc(i).num = MapNpc(mapNum).Npc(mapNpcNum).num Then
                    MapNpc(mapNum).Npc(i).Target = Attacker
                    MapNpc(mapNum).Npc(i).targetType = 1 ' player
                End If
            Next
        End If
        
        If Npc(MapNpc(mapNum).Npc(mapNpcNum).num).Behaviour = NPC_BEHAVIOUR_BOSS Then
            For i = 1 To MAX_MAP_NPCS
                If MapNpc(mapNum).Npc(i).num > 0 Then
                    If Npc(MapNpc(mapNum).Npc(i).num).Behaviour = NPC_BEHAVIOUR_ATTACKONSIGHT Or Npc(MapNpc(mapNum).Npc(i).num).Behaviour = NPC_BEHAVIOUR_ATTACKWHENATTACKED Then
                        MapNpc(mapNum).Npc(i).Target = Attacker
                        MapNpc(mapNum).Npc(i).targetType = 1 ' player
                    End If
                End If
            Next
        End If
        ' set the regen timer
        MapNpc(mapNum).Npc(mapNpcNum).stopRegen = True
        MapNpc(mapNum).Npc(mapNpcNum).stopRegenTimer = GetTickCount
        
        ' if stunning spell, stun the npc
        If SpellNum > 0 Then
            If Spell(SpellNum).StunDuration > 0 Then StunNPC mapNpcNum, mapNum, SpellNum, Attacker
            ' DoT
            If Spell(SpellNum).Duration > 0 Then
                AddDoT_Npc mapNum, mapNpcNum, SpellNum, Attacker
            End If
        End If
        
        If GetPlayerEquipment(Attacker, Weapon) > 0 Then
            If Item(GetPlayerEquipment(Attacker, Weapon)).StunDuration > 0 Then
                MapNpc(mapNum).Npc(mapNpcNum).StunDuration = Item(GetPlayerEquipment(Attacker, Weapon)).StunDuration
                MapNpc(mapNum).Npc(mapNpcNum).StunTimer = GetTickCount
            End If
        End If
        
        SendMapNpcVitals mapNum, mapNpcNum
    End If

    If SpellNum = 0 Then
        ' Reset attack timer
        TempPlayer(Attacker).AttackTimer = GetTickCount
    End If
End Sub

' ###################################
' ##      NPC Attacking Player     ##
' ###################################

Public Sub TryNpcAttackPlayer(ByVal mapNpcNum As Long, ByVal index As Long)
Dim mapNum As Long, NpcNum As Long, blockAmount As Long, Damage As Long

    ' Can the npc attack the player?
    If CanNpcAttackPlayer(mapNpcNum, index) Then
        mapNum = GetPlayerMap(index)
        NpcNum = MapNpc(mapNum).Npc(mapNpcNum).num
    
        ' check if PLAYER can avoid the attack
        If CanPlayerDodge(index) Then
            SendActionMsg mapNum, "Esquivou!", Magenta, 1, (Player(index).X * 32), (Player(index).Y * 32)
            Exit Sub
        End If
        If CanPlayerParry(index) Then
            SendActionMsg mapNum, "Defendeu!", Green, 1, (Player(index).X * 32), (Player(index).Y * 32)
            Exit Sub
        End If

        ' Get the damage we can do
        Damage = GetNpcDamage(NpcNum)
        
        ' if the player blocks, take away the block amount
        blockAmount = CanPlayerBlock(index)
        Damage = Damage - blockAmount
        
        ' take away armour
        Damage = Damage - RAND(1, (GetPlayerStat(index, Agility) / 30))
        
        ' randomise for up to 10% lower than max hit
        Damage = RAND(1, Damage)
        
        ' * 1.5 if crit hit
        If CanNpcCrit(index) Then
            Damage = Damage * 1.5
            SendActionMsg mapNum, "Crítico!", BrightCyan, 1, (MapNpc(mapNum).Npc(mapNpcNum).X * 32), (MapNpc(mapNum).Npc(mapNpcNum).Y * 32)
        End If

        If Damage > 0 Then
            If Npc(MapNpc(mapNum).Npc(mapNpcNum).num).AttackScript > 0 Then
                    NpcAttack index, Npc(MapNpc(mapNum).Npc(mapNpcNum).num).AttackScript, mapNpcNum
            End If
        
            Call NpcAttackPlayer(mapNpcNum, index, Damage)
            
        End If
    End If
End Sub

Function CanNpcAttackPlayer(ByVal mapNpcNum As Long, ByVal index As Long) As Boolean
    Dim mapNum As Long
    Dim NpcNum As Long
    
    ' Check for subscript out of range
    If mapNpcNum <= 0 Or mapNpcNum > MAX_MAP_NPCS Or Not IsPlaying(index) Then
        Exit Function
    End If

    ' Check for subscript out of range
    If MapNpc(GetPlayerMap(index)).Npc(mapNpcNum).num <= 0 Then
        Exit Function
    End If

    mapNum = GetPlayerMap(index)
    NpcNum = MapNpc(mapNum).Npc(mapNpcNum).num
    
    'check if the NPC attacking us is actually our pet.
'We don't want a rebellion on our hands now do we?
        
    If MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner = index Then Exit Function

    If MapNpc(mapNum).Npc(mapNpcNum).StunDuration > 0 Then Exit Function
    
    ' Make sure the npc isn't already dead
    If MapNpc(mapNum).Npc(mapNpcNum).Vital(Vitals.HP) <= 0 Then
        Exit Function
    End If
    
    If Map(mapNum).Moral = MAP_MORAL_SAFE Then
         If MapNpc(mapNum).Npc(mapNpcNum).IsPet Then
            Exit Function
        End If
    End If
    
    If Npc(NpcNum).Level > 100 Then
        If GetPlayerLevel(index) < 100 Then
            Exit Function
        End If
    End If

    ' Make sure npcs dont attack more then once a second
    If GetTickCount < MapNpc(mapNum).Npc(mapNpcNum).AttackTimer + 1000 Then
        Exit Function
    End If

    ' Make sure we dont attack the player if they are switching maps
    If TempPlayer(index).GettingMap = YES Then
        Exit Function
    End If

    MapNpc(mapNum).Npc(mapNpcNum).AttackTimer = GetTickCount

    ' Make sure they are on the same map
    If IsPlaying(index) Then
        If NpcNum > 0 Then

            ' Check if at same coordinates
            If (GetPlayerY(index) + 1 = MapNpc(mapNum).Npc(mapNpcNum).Y) And (GetPlayerX(index) = MapNpc(mapNum).Npc(mapNpcNum).X) Then
                CanNpcAttackPlayer = True
            Else
                If (GetPlayerY(index) - 1 = MapNpc(mapNum).Npc(mapNpcNum).Y) And (GetPlayerX(index) = MapNpc(mapNum).Npc(mapNpcNum).X) Then
                    CanNpcAttackPlayer = True
                Else
                    If (GetPlayerY(index) = MapNpc(mapNum).Npc(mapNpcNum).Y) And (GetPlayerX(index) + 1 = MapNpc(mapNum).Npc(mapNpcNum).X) Then
                        CanNpcAttackPlayer = True
                    Else
                        If (GetPlayerY(index) = MapNpc(mapNum).Npc(mapNpcNum).Y) And (GetPlayerX(index) - 1 = MapNpc(mapNum).Npc(mapNpcNum).X) Then
                            CanNpcAttackPlayer = True
                        End If
                    End If
                End If
            End If
        End If
    End If
End Function

Sub NpcAttackPlayer(ByVal mapNpcNum As Long, ByVal Victim As Long, ByVal Damage As Long)
    Dim Name As String
    Dim EXP As Long
    Dim mapNum As Long
    Dim i As Long
    Dim Buffer As clsBuffer

    ' Check for subscript out of range
    If mapNpcNum <= 0 Or mapNpcNum > MAX_MAP_NPCS Or IsPlaying(Victim) = False Then
        Exit Sub
    End If

    ' Check for subscript out of range
    If MapNpc(GetPlayerMap(Victim)).Npc(mapNpcNum).num <= 0 Then
        Exit Sub
    End If

    If TempPlayer(Victim).Kawarimi > 0 Then
       SendAnimation GetPlayerMap(Victim), 1, GetPlayerX(Victim), GetPlayerY(Victim)
       WarpBehind_Npc Victim, mapNpcNum
       Exit Sub
    End If
     
    mapNum = GetPlayerMap(Victim)
    Name = Trim$(Npc(MapNpc(mapNum).Npc(mapNpcNum).num).Name)
    
    ' Send this packet so they can see the npc attacking
    Set Buffer = New clsBuffer
    Buffer.WriteLong SNpcAttack
    Buffer.WriteLong mapNpcNum
    SendDataToMap mapNum, Buffer.ToArray()
    Set Buffer = Nothing
    
    If TempPlayer(Victim).Reflect > 0 Then
        Select Case GetPlayerClass(Victim)
            Case SASUKE
                Select Case GetPlayerLevel(Victim)
                    Case 0 To 500
                        Damage = Damage / 1.2
                    Case 501 To 749
                        Damage = Damage / 1.4
                    Case 750 To MAX_INTEGER
                        Damage = Damage / 1.6
                    Case Else
                End Select
                    
            Case INO
                Damage = Damage / 1.5
            Case Else
        End Select
    End If
    
    If Damage <= 0 Then
        Exit Sub
    End If
    
    ' set the regen timer
    MapNpc(mapNum).Npc(mapNpcNum).stopRegen = True
    MapNpc(mapNum).Npc(mapNpcNum).stopRegenTimer = GetTickCount

    If Damage >= GetPlayerVital(Victim, Vitals.HP) Then
        ' Say damage
        SendActionMsg GetPlayerMap(Victim), "-" & GetPlayerVital(Victim, Vitals.HP), BrightRed, 1, (GetPlayerX(Victim) * 32), (GetPlayerY(Victim) * 32)
        
        ' send the sound
        SendMapSound Victim, GetPlayerX(Victim), GetPlayerY(Victim), SoundEntity.seNpc, MapNpc(mapNum).Npc(mapNpcNum).num
        
        ' kill player
        KillPlayer Victim
        
        ' Player is dead
        Call GlobalMsg(GetPlayerName(Victim) & " foi derrotado por " & Name, BrightRed)

        ' Set NPC target to 0
        MapNpc(mapNum).Npc(mapNpcNum).Target = 0
        MapNpc(mapNum).Npc(mapNpcNum).targetType = 0
    Else
        ' Player not dead, just do the damage
        Call SetPlayerVital(Victim, Vitals.HP, GetPlayerVital(Victim, Vitals.HP) - Damage)
        Call SendVital(Victim, Vitals.HP)
        Call SendAnimation(mapNum, Npc(MapNpc(GetPlayerMap(Victim)).Npc(mapNpcNum).num).Animation, 0, 0, TARGET_TYPE_PLAYER, Victim)
        
        ' send vitals to party if in one
        If TempPlayer(Victim).inParty > 0 Then SendPartyVitals TempPlayer(Victim).inParty, Victim
        
        ' send the sound
        SendMapSound Victim, GetPlayerX(Victim), GetPlayerY(Victim), SoundEntity.seNpc, MapNpc(mapNum).Npc(mapNpcNum).num
        
        ' Say damage
        SendActionMsg GetPlayerMap(Victim), "-" & Damage, BrightRed, 1, (GetPlayerX(Victim) * 32), (GetPlayerY(Victim) * 32)
        SendBlood GetPlayerMap(Victim), GetPlayerX(Victim), GetPlayerY(Victim)
        
        ' set the regen timer
        TempPlayer(Victim).stopRegen = True
        TempPlayer(Victim).stopRegenTimer = GetTickCount
    End If

End Sub

' ###################################
' ##    Player Attacking Player    ##
' ###################################

Public Sub TryPlayerAttackPlayer(ByVal Attacker As Long, ByVal Victim As Long)
Dim blockAmount As Long
Dim NpcNum As Long
Dim mapNum As Long
Dim Damage As Long

    Damage = 0

    ' Can we attack the npc?
    If CanPlayerAttackPlayer(Attacker, Victim) Then
    
        mapNum = GetPlayerMap(Attacker)
    
        ' check if NPC can avoid the attack
        If CanPlayerDodge(Victim) Then
            SendActionMsg mapNum, "Esquivou!", Magenta, 1, (GetPlayerX(Victim) * 32), (GetPlayerY(Victim) * 32)
            Exit Sub
        End If
        If CanPlayerParry(Victim) Then
            SendActionMsg mapNum, "Defendeu!", Green, 1, (GetPlayerX(Victim) * 32), (GetPlayerY(Victim) * 32)
            Exit Sub
        End If

        ' Get the damage we can do
        Damage = GetPlayerDamage(Attacker)
        
        ' if the npc blocks, take away the block amount
        blockAmount = CanPlayerBlock(Victim)
        Damage = Damage - blockAmount
        
        ' take away armour
        Damage = Damage - RAND(1, (GetPlayerStat(Victim, Agility) * 2))
        
        ' randomise for up to 10% lower than max hit
        Damage = RAND(1, Damage)
        
        ' * 1.5 if can crit
        If CanPlayerCrit(Attacker) Then
            Damage = Damage * 1.5
            SendActionMsg mapNum, "Crítico!", BrightCyan, 1, (GetPlayerX(Attacker) * 32), (GetPlayerY(Attacker) * 32)
        End If

        If Damage > 0 Then
            If Not TempPlayer(Attacker).Target = Victim Then
                TempPlayer(Attacker).Target = Victim
                TempPlayer(Attacker).targetType = TARGET_TYPE_PLAYER
                SendTarget Attacker
             End If
          
            Call PlayerAttackPlayer(Attacker, Victim, Damage)
            CheckHits Attacker, Victim
            
        Else
            Call PlayerMsg(Attacker, "Seu ataque é ridículo!", BrightRed)
        End If
    End If
End Sub

Function CanPlayerAttackPlayer(ByVal Attacker As Long, ByVal Victim As Long, Optional ByVal IsSpell As Boolean = False, Optional ByVal IsProjectile As Boolean = False) As Boolean
If Attacker < 1 Or Attacker > MAX_PLAYERS Then Exit Function
If Victim < 1 Or Victim > MAX_PLAYERS Then Exit Function

    If Not IsSpell And Not IsProjectile Then
        ' Check attack timer
        If GetPlayerEquipment(Attacker, Weapon) > 0 Then
            If GetTickCount < TempPlayer(Attacker).AttackTimer + Item(GetPlayerEquipment(Attacker, Weapon)).Speed Then Exit Function
        Else
            If GetTickCount < TempPlayer(Attacker).AttackTimer + 1000 Then Exit Function
        End If
    End If

    ' Check for subscript out of range
    If Not IsPlaying(Victim) Then Exit Function

    ' Make sure they are on the same map
    If Not GetPlayerMap(Attacker) = GetPlayerMap(Victim) Then Exit Function

    ' Make sure we dont attack the player if they are switching maps
    If TempPlayer(Victim).GettingMap = YES Then Exit Function
    
    
    If Not IsSpell And Not IsProjectile Then
        ' Check if at same coordinates
        Select Case GetPlayerDir(Attacker)
            Case DIR_UP
    
                If Not ((GetPlayerY(Victim) + 1 = GetPlayerY(Attacker)) And (GetPlayerX(Victim) = GetPlayerX(Attacker))) Then Exit Function
            Case DIR_DOWN
    
                If Not ((GetPlayerY(Victim) - 1 = GetPlayerY(Attacker)) And (GetPlayerX(Victim) = GetPlayerX(Attacker))) Then Exit Function
            Case DIR_LEFT
    
                If Not ((GetPlayerY(Victim) = GetPlayerY(Attacker)) And (GetPlayerX(Victim) + 1 = GetPlayerX(Attacker))) Then Exit Function
            Case DIR_RIGHT
    
                If Not ((GetPlayerY(Victim) = GetPlayerY(Attacker)) And (GetPlayerX(Victim) - 1 = GetPlayerX(Attacker))) Then Exit Function
            Case Else
                Exit Function
        End Select
    End If
    
    If Player(Attacker).PKstate = 0 Then
        PlayerMsg Attacker, "Ligue o PK se quizer atacar um Player(Aperte INSERT)", BrightRed
        Exit Function
    End If
    
    If GetPlayerIP(Attacker) = GetPlayerIP(Victim) And Not GetPlayerAccess(Attacker) = ADMIN_CREATOR Then
        'PlayerMsg Attacker, "Não pode atacar você mesmo,safado ;] ", BrightRed
        Exit Function
    End If
    
    If Torneio = vbNullString Then
        If GetPlayerLevel(Victim) <= 300 Then
            If GetPlayerLevel(Victim) + 200 < GetPlayerLevel(Attacker) Then
                PlayerMsg Attacker, "Ele não têm muita chance com você..", BrightRed
                Exit Function
            End If
        End If
        
        If GetPlayerLevel(Attacker) <= 300 Then
            If GetPlayerLevel(Attacker) + 200 < GetPlayerLevel(Victim) Then
                PlayerMsg Attacker, "Pense 2 vezes :D..", BrightRed
                Exit Function
            End If
        End If
    End If

    If TempPlayer(Attacker).inParty > 0 Then
        If TempPlayer(Attacker).inParty = TempPlayer(Victim).inParty And Not Torneio = "Torneio" Then
            If Not Player(Attacker).PKstate = 2 Then
                'PlayerMsg Attacker, "Vocês são do mesmo Grupo!(Ligue PK2)", BrightRed
                Exit Function
            End If
        End If
    End If
    
    If Player(Attacker).Org > 0 Then
        If Player(Attacker).Org = Player(Victim).Org And Not Torneio = "Torneio" Then
            If Not Player(Attacker).PKstate = 2 Then
                'PlayerMsg Attacker, "Vocês são da Mesma organização!", BrightRed
                Exit Function
            End If
        End If
    End If
    
    ' Check if map is attackable
    If Not Map(GetPlayerMap(Attacker)).Moral = MAP_MORAL_NONE Then
        If Not Torneio = "Invasão" Then
            Call PlayerMsg(Attacker, "Está é uma zona segura!", BrightRed)
            Exit Function
        Else
            If Player(Attacker).Vila = Player(Victim).Vila Then
                PlayerMsg Attacker, "Vocês são da mesma vila!", BrightRed
                Exit Function
            End If
        End If
    End If

    ' Make sure they have more then 0 hp
    If GetPlayerVital(Victim, Vitals.HP) <= 0 Then Exit Function

    ' Check to make sure that they dont have access
    If GetPlayerAccess(Attacker) > 1 And Not GetPlayerAccess(Attacker) = ADMIN_CREATOR Then
        Call PlayerMsg(Attacker, "ADM's não podem atacar", BrightBlue)
        Exit Function
    End If

    ' Check to make sure the victim isn't an admin
    If GetPlayerAccess(Victim) > 1 And Not GetPlayerAccess(Attacker) = ADMIN_CREATOR Then
        Call PlayerMsg(Attacker, "Não pode atacar ADM!", BrightRed)
        Exit Function
    End If

    ' Make sure attacker is high enough level
    If GetPlayerLevel(Attacker) < 100 Then
        Call PlayerMsg(Attacker, "Você é level menor que 100,não pode atacar ninguém ainda!", BrightRed)
        Exit Function
    End If

    ' Make sure victim is high enough level
    If GetPlayerLevel(Victim) < 100 Then
        Call PlayerMsg(Attacker, GetPlayerName(Victim) & " é level menor que 100, você não pode atacá-lo ainda!", BrightRed)
        Exit Function
    End If
    
    If TempPlayer(Victim).Kawarimi > 0 Then
       SendAnimation GetPlayerMap(Victim), 1, GetPlayerX(Victim), GetPlayerY(Victim)
       WarpBehind_Player Victim, Attacker
       Exit Function
    End If

    CanPlayerAttackPlayer = True
End Function

Sub PlayerAttackPlayer(ByVal Attacker As Long, ByVal Victim As Long, ByVal Damage As Long, Optional ByVal SpellNum As Long = 0)
    Dim EXP As Long
    Dim n As Long
    Dim i As Long
    Dim Buffer As clsBuffer

    ' Check for subscript out of range
    If IsPlaying(Attacker) = False Or IsPlaying(Victim) = False Or Damage < 0 Then
        Exit Sub
    End If

    ' Check for weapon
    n = 0

    If GetPlayerEquipment(Attacker, Weapon) > 0 Then
        n = GetPlayerEquipment(Attacker, Weapon)
        Select Case GetPlayerEquipment(Attacker, Weapon)
            Case 18
                If GetPlayerVital(Victim, Vitals.mp) > 20 Then
                    SetPlayerVital Victim, Vitals.mp, GetPlayerVital(Victim, Vitals.mp) - 20
                    SendVital Victim, Vitals.mp
                End If
            Case Else
        End Select
    End If
    
    ' set the regen timer
    TempPlayer(Attacker).stopRegen = True
    TempPlayer(Attacker).stopRegenTimer = GetTickCount

    Damage = Damage - GetPlayerProtection(Victim)
    
    If TempPlayer(Victim).Reflect > 0 Then
        Select Case GetPlayerClass(Victim)
            Case SASUKE
                Select Case GetPlayerLevel(Victim)
                    Case 0 To 500
                        Damage = Damage / 1.2
                    Case 501 To 749
                        Damage = Damage / 1.4
                    Case 750 To MAX_INTEGER
                        Damage = Damage / 1.6
                    Case Else
                End Select
                    
            Case INO
                Damage = Damage / 1.5
            Case Else
        End Select
    End If
    
    If Damage >= GetPlayerVital(Victim, Vitals.HP) Then
        
        SendActionMsg GetPlayerMap(Victim), "-" & GetPlayerVital(Victim, Vitals.HP), BrightRed, 1, (GetPlayerX(Victim) * 32), (GetPlayerY(Victim) * 32)
        
        ' send the sound
        If SpellNum > 0 Then SendMapSound Victim, GetPlayerX(Victim), GetPlayerY(Victim), SoundEntity.seSpell, SpellNum
        
        ' Player is dead
        Call GlobalMsg(GetPlayerName(Victim) & " foi derrotado por " & GetPlayerName(Attacker), BrightRed)
        ' Calculate exp to give attacker
        EXP = (GetPlayerExp(Victim) / 200)
        
        Dim DsH As Byte
        For DsH = 1 To Equipment.Equipment_Count - 1
            If GetPlayerEquipment(Attacker, DsH) > 0 Then
                If Item(GetPlayerEquipment(Attacker, DsH)).ExpExtra > 0 Then
                    EXP = EXP * Item(GetPlayerEquipment(Attacker, DsH)).ExpExtra / 100
                End If
            End If
        Next
        
        If Player(Attacker).VipData.VIP = 1 Then EXP = EXP * 1.5
        If Player(Attacker).VipData.VIP = 2 Then EXP = EXP * 2
        
        If Not frmServer.txtEventoEXP.Text = 0 Then
           EXP = EXP * frmServer.txtEventoEXP.Text * 4
        End If
        
        ' Make sure we dont get less then 0
        If EXP < 0 Then
            EXP = 0
        End If
        
        EXP = 0

        If EXP = 0 Then
            Call PlayerMsg(Victim, "Você não perdeu EXP.", BrightRed)
            Call PlayerMsg(Attacker, "Você não recebeu EXP.", BrightBlue)
        Else
            If HasItem(Victim, 68) Then
                TakeInvItem Victim, 68, 1
                PlayerMsg Victim, "Amuleto da sorte foi ativado!", BrightRed
            Else
                TempPlayer(Victim).SetExp = YES
                Call SetPlayerExp(Victim, GetPlayerExp(Victim) - EXP)
                SendEXP Victim
                Call PlayerMsg(Victim, "Você perdeu " & EXP & " de EXP.", BrightRed)
            
            ' check if we're in a party
                If TempPlayer(Attacker).inParty > 0 Then
                ' pass through party exp share function
                    'GivePlayerEXP Attacker, EXP / 2.5
                    'Party_ShareExp TempPlayer(Attacker).inParty, EXP, Attacker
                Else
                ' not in party, get exp for self
                    'GivePlayerEXP Attacker, EXP
                End If
            End If
        End If
        
        ' purge target info of anyone who targetted dead guy
        For i = 1 To Player_HighIndex
            If IsPlaying(i) And IsConnected(i) Then
                If Player(i).Map = GetPlayerMap(Attacker) Then
                    If TempPlayer(i).Target = TARGET_TYPE_PLAYER Then
                        If TempPlayer(i).Target = Victim Then
                            TempPlayer(i).Target = 0
                            TempPlayer(i).targetType = TARGET_TYPE_NONE
                            SendTarget i
                        End If
                    End If
                End If
            End If
        Next

        'If GetPlayerPK(Victim) = NO Then
            'If GetPlayerPK(Attacker) = NO Then
                'Call SetPlayerPK(Attacker, YES)
                'Call SendPlayerData(Attacker)
                'Call GlobalMsg(GetPlayerName(Attacker) & " foi nomeado à Assassino!!!", BrightRed)
            'End If

        'Else
            'Call GlobalMsg(GetPlayerName(Victim) & " pagou o preço por matar!!!", BrightRed)
        'End If
        
        setKarma Attacker, Victim
        OnDeath Victim
        CheckQuestKillPlayer Attacker, Victim
        
    Else
        ' Player not dead, just do the damage
        Call SetPlayerVital(Victim, Vitals.HP, GetPlayerVital(Victim, Vitals.HP) - Damage)
        Call SendVital(Victim, Vitals.HP)
        
        ' send vitals to party if in one
        If TempPlayer(Victim).inParty > 0 Then SendPartyVitals TempPlayer(Victim).inParty, Victim
        
        ' send the sound
        If SpellNum > 0 Then SendMapSound Victim, GetPlayerX(Victim), GetPlayerY(Victim), SoundEntity.seSpell, SpellNum
        
        SendActionMsg GetPlayerMap(Victim), "-" & Damage, BrightRed, 1, (GetPlayerX(Victim) * 32), (GetPlayerY(Victim) * 32)
        SendBlood GetPlayerMap(Victim), GetPlayerX(Victim), GetPlayerY(Victim)
        
        ' set the regen timer
        TempPlayer(Victim).stopRegen = True
        TempPlayer(Victim).stopRegenTimer = GetTickCount
        
        'if a stunning spell, stun the player
        If SpellNum > 0 Then
            If Spell(SpellNum).StunDuration > 0 Then StunPlayer Victim, SpellNum, Attacker
            ' DoT
            If Spell(SpellNum).Duration > 0 Then
                AddDoT_Player Victim, SpellNum, Attacker
            End If
        Else
            SendAnimation GetPlayerMap(Victim), 28, 0, 0, TARGET_TYPE_PLAYER, Victim
        End If
        
        If GetPlayerEquipment(Attacker, Weapon) > 0 Then
           If Item(GetPlayerEquipment(Attacker, Weapon)).StunDuration > 0 Then
                TempPlayer(Victim).StunDuration = Item(GetPlayerEquipment(Attacker, Weapon)).StunDuration
                TempPlayer(Victim).StunTimer = GetTickCount
                SendStunned Victim
                ' tell him he's stunned
                PlayerMsg Victim, "Você está paralizado.", BrightRed
            End If
        End If
    End If

    ' Reset attack timer
    TempPlayer(Attacker).AttackTimer = GetTickCount
End Sub

' ############
' ## Spells ##
' ############

Public Sub BufferSpell(ByVal index As Long, ByVal spellslot As Long)
    Dim SpellNum As Long
    Dim MPCost As Long
    Dim LevelReq As Long
    Dim mapNum As Long
    Dim SpellCastType As Long
    Dim ClassReq As Long
    Dim AccessReq As Long
    Dim Range As Long
    Dim HasBuffered As Boolean
    
    Dim targetType As Byte
    Dim Target As Long
    
    ' Prevent subscript out of range
    If spellslot <= 0 Or spellslot > MAX_PLAYER_SPELLS Then Exit Sub
    
    SpellNum = GetPlayerSpell(index, spellslot)
    mapNum = GetPlayerMap(index)
    
    If SpellNum <= 0 Or SpellNum > MAX_SPELLS Then Exit Sub
    
    ' Make sure player has the spell
    If Not HasSpell(index, SpellNum) Then Exit Sub
    
    ' see if cooldown has finished
    'If TempPlayer(index).SpellCD(spellslot) > GetTickCount Then
        'PlayerMsg index, "Spell hasn't cooled down yet!", BrightRed
        'Exit Sub
    'End If

    MPCost = Spell(SpellNum).MPCost

    ' Check if they have enough MP
    If GetPlayerVital(index, Vitals.mp) < MPCost Then
        Call PlayerMsg(index, "Sem chakra o suficiente!", BrightRed)
        Exit Sub
    End If
    
    LevelReq = Spell(SpellNum).LevelReq

    ' Make sure they are the right level
    If LevelReq > GetPlayerLevel(index) Then
        Call PlayerMsg(index, "Você precisa ser Level " & LevelReq & " para usar este Jutsu.", BrightRed)
        Exit Sub
    End If
    
    AccessReq = Spell(SpellNum).AccessReq
    
    ' make sure they have the right access
    If AccessReq > GetPlayerAccess(index) Then
        Call PlayerMsg(index, "Apenas ADM.", BrightRed)
        Exit Sub
    End If
    
    ClassReq = Spell(SpellNum).ClassReq
    
    ' make sure the classreq > 0
    If ClassReq > 0 Then ' 0 = no req
        If ClassReq <> GetPlayerClass(index) Then
            Call PlayerMsg(index, "Apenas " & CheckGrammar(Trim$(Class(ClassReq).Name)) & " pode usar este Jutsu.", BrightRed)
            Exit Sub
        End If
    End If
    
    If Spell(SpellNum).ReqTrans > 0 Then
        If Spell(SpellNum).ReqTrans > Player(index).Trans Then
            PlayerMsg index, "Você precisa estar transformado pelo menos no Nível :" & Spell(SpellNum).ReqTrans, BrightRed
            Exit Sub
        End If
    End If
    
    If Spell(SpellNum).ReqDojutsu > 0 Then
    Dim i As Byte
    Dim MyDojutsu As Byte
        For i = Spell(SpellNum).ReqDojutsu To 5
            If TempPlayer(index).Dojutsu(i) > 0 Then
                MyDojutsu = i
                Exit For
            End If
        Next
        
        If Not MyDojutsu >= Spell(SpellNum).ReqDojutsu Then
            PlayerMsg index, "Você precisa ativar seu Dojutsu em um Nível superior..", BrightRed
            Exit Sub
        End If
    End If
    
    ' find out what kind of spell it is! self cast, target or AOE
    If Spell(SpellNum).Range > 0 Then
        ' ranged attack, single target or aoe?
        If Not Spell(SpellNum).IsAoE Then
            SpellCastType = 2 ' targetted
        Else
            SpellCastType = 3 ' targetted aoe
        End If
    Else
        If Not Spell(SpellNum).IsAoE Then
            SpellCastType = 0 ' self-cast
        Else
            SpellCastType = 1 ' self-cast AoE
        End If
    End If
    
    targetType = TempPlayer(index).targetType
    Target = TempPlayer(index).Target
    Range = Spell(SpellNum).Range
    HasBuffered = False
    
    Select Case SpellCastType
        Case 0, 1 ' self-cast & self-cast AOE
            HasBuffered = True
        Case 2, 3 ' targeted & targeted AOE
            ' check if have target
            If Not Target > 0 Then
                PlayerMsg index, "Você não têm um Alvo.", BrightRed
            End If
            If targetType = TARGET_TYPE_PLAYER Then
                ' if have target, check in range
                If Not isInRange(Range, GetPlayerX(index), GetPlayerY(index), GetPlayerX(Target), GetPlayerY(Target)) Then
                    PlayerMsg index, "Alvo não está no alcance.", BrightRed
                Else
                    ' go through spell types
                    If Spell(SpellNum).Type <> SPELL_TYPE_DAMAGEHP And Spell(SpellNum).Type <> SPELL_TYPE_DAMAGEMP Then
                        HasBuffered = True
                    Else
                        If CanPlayerAttackPlayer(index, Target, True) Then
                            HasBuffered = True
                        End If
                    End If
                End If
            ElseIf targetType = TARGET_TYPE_NPC Then
                ' if have target, check in range
                If Not isInRange(Range, GetPlayerX(index), GetPlayerY(index), MapNpc(mapNum).Npc(Target).X, MapNpc(mapNum).Npc(Target).Y) Then
                    PlayerMsg index, "Alvo não está no Alcance.", BrightRed
                    HasBuffered = False
                Else
                    ' go through spell types
                    If Spell(SpellNum).Type <> SPELL_TYPE_DAMAGEHP And Spell(SpellNum).Type <> SPELL_TYPE_DAMAGEMP Then
                        HasBuffered = True
                    Else
                        If CanPlayerAttackNpc(index, Target, True) Then
                            HasBuffered = True
                        End If
                    End If
                End If
            End If
    End Select
    
    If HasBuffered Then
        SendAnimation mapNum, Spell(SpellNum).CastAnim, 0, 0, TARGET_TYPE_PLAYER, index
        If Spell(SpellNum).CastTime > 0 Then
            SendActionMsg mapNum, "Preparando..", BrightRed, ACTIONMSG_SCROLL, GetPlayerX(index) * 32, GetPlayerY(index) * 32 - 80
        End If
        TempPlayer(index).spellBuffer.Spell = spellslot
        TempPlayer(index).spellBuffer.Timer = GetTickCount
        TempPlayer(index).spellBuffer.Target = TempPlayer(index).Target
        TempPlayer(index).spellBuffer.tType = TempPlayer(index).targetType
        Exit Sub
    Else
        SendClearSpellBuffer index
    End If
End Sub

Public Sub CastSpell(ByVal index As Long, ByVal spellslot As Long, ByVal Target As Long, ByVal targetType As Byte)
    Dim SpellNum As Long
    Dim MPCost As Long
    Dim LevelReq As Long
    Dim mapNum As Long
    Dim Vital As Long
    Dim DidCast As Boolean
    Dim ClassReq As Long
    Dim AccessReq As Long
    Dim i As Long
    Dim AoE As Long
    Dim Range As Long
    Dim VitalType As Byte
    Dim increment As Boolean
    Dim X As Long, Y As Long
    
    Dim Buffer As clsBuffer
    Dim SpellCastType As Long
    
    DidCast = False

    ' Prevent subscript out of range
    If spellslot <= 0 Or spellslot > MAX_PLAYER_SPELLS Then Exit Sub

    SpellNum = GetPlayerSpell(index, spellslot)
    mapNum = GetPlayerMap(index)

    ' Make sure player has the spell
    If Not HasSpell(index, SpellNum) Then Exit Sub

    MPCost = Spell(SpellNum).MPCost
    
    'If MAP(mapNum).Moral = MAP_MORAL_SAFE Then
        'PlayerMsg index, "Não pode usar jutsu em Zona segura!", BrightRed
        'Exit Sub
   ' End If
    
    ' Check if they have enough MP
    If GetPlayerVital(index, Vitals.mp) < MPCost Then
        Call PlayerMsg(index, "Sem chakra o suficiente!", BrightRed)
        Exit Sub
    End If
    
    LevelReq = Spell(SpellNum).LevelReq

    ' Make sure they are the right level
    If LevelReq > GetPlayerLevel(index) Then
        Call PlayerMsg(index, "Você precisa ser Level " & LevelReq & " para usar este Jutsu.", BrightRed)
        Exit Sub
    End If
    
    AccessReq = Spell(SpellNum).AccessReq
    
    ' make sure they have the right access
    If AccessReq > GetPlayerAccess(index) Then
        Call PlayerMsg(index, "Apenas ADM", BrightRed)
        Exit Sub
    End If
    
    ClassReq = Spell(SpellNum).ClassReq
    
    ' make sure the classreq > 0
    If ClassReq > 0 Then ' 0 = no req
        If ClassReq <> GetPlayerClass(index) Then
            Call PlayerMsg(index, "Apenas " & CheckGrammar(Trim$(Class(ClassReq).Name)) & " pode usar este Jutsu.", BrightRed)
            Exit Sub
        End If
    End If
    
    If Spell(SpellNum).ReqTrans > 0 Then
        If Spell(SpellNum).ReqTrans > Player(index).Trans Then
            PlayerMsg index, "Você precisa estar transformado pelo menos no Nível :" & Spell(SpellNum).ReqTrans, BrightRed
            Exit Sub
        End If
    End If
    
    If Spell(SpellNum).ReqDojutsu > 0 Then
    Dim MyDojutsu As Byte
        For i = Spell(SpellNum).ReqDojutsu To 5
            If TempPlayer(index).Dojutsu(i) > 0 Then
                MyDojutsu = i
                Exit For
            End If
        Next
        
        If Not MyDojutsu >= Spell(SpellNum).ReqDojutsu Then
            PlayerMsg index, "Você precisa ativar seu Dojutsu em um Nível superior..", BrightRed
            Exit Sub
        End If
    End If
    
    ' find out what kind of spell it is! self cast, target or AOE
    If Spell(SpellNum).Range > 0 Then
        ' ranged attack, single target or aoe?
        If Not Spell(SpellNum).IsAoE Then
            SpellCastType = 2 ' targetted
        Else
            SpellCastType = 3 ' targetted aoe
        End If
    Else
        If Not Spell(SpellNum).IsAoE Then
            SpellCastType = 0 ' self-cast
        Else
            SpellCastType = 1 ' self-cast AoE
        End If
    End If
    
    ' set the vital
    Vital = RAND(GetSpellBaseStat(index, SpellNum) - 10, GetSpellBaseStat(index, SpellNum))
    AoE = Spell(SpellNum).AoE
    Range = Spell(SpellNum).Range
    
    'CheckSeals index, SpellNum
    CheckQuestUseSpell index, SpellNum
    
    Select Case SpellCastType
    
    
    
        Case 0 ' self-cast target
            Select Case Spell(SpellNum).Type
                Case SPELL_TYPE_HEALHP
                    SpellPlayer_Effect Vitals.HP, True, index, Vital, SpellNum
                    DidCast = True
                Case SPELL_TYPE_HEALMP
                    SpellPlayer_Effect Vitals.mp, True, index, Vital, SpellNum
                    DidCast = True
                Case SPELL_TYPE_WARP
                    SendAnimation mapNum, Spell(SpellNum).SpellAnim, 0, 0, TARGET_TYPE_PLAYER, index
                    PlayerWarp index, Spell(SpellNum).Map, Spell(SpellNum).X, Spell(SpellNum).Y
                    SendAnimation GetPlayerMap(index), Spell(SpellNum).SpellAnim, 0, 0, TARGET_TYPE_PLAYER, index
                    DidCast = True
                Case SPELL_TYPE_RETA
                    SendAnimation GetPlayerMap(index), Spell(SpellNum).SpellAnim, 0, 0, TARGET_TYPE_PLAYER, index
                    MagiaReta index, SpellNum
                    DidCast = True
                Case SPELL_TYPE_AREA
                    SendAnimation GetPlayerMap(index), Spell(SpellNum).SpellAnim, 0, 0, TARGET_TYPE_PLAYER, index
                    MagiaArea index, SpellNum
                    DidCast = True
                Case SPELL_TYPE_SCRIPT
                   ScriptedSpell index, Spell(SpellNum).Script, SpellNum
                   DidCast = True
                Case SPELL_TYPE_PET
                    SpawnPet index, mapNum, Spell(SpellNum).PetNum
                    SendAnimation GetPlayerMap(index), Spell(SpellNum).SpellAnim, 0, 0, TARGET_TYPE_PLAYER, index
                    DidCast = True
            End Select
        Case 1, 3 ' self-cast AOE & targetted AOE
            If SpellCastType = 1 Then
                X = GetPlayerX(index)
                Y = GetPlayerY(index)
            ElseIf SpellCastType = 3 Then
                If targetType = 0 Then Exit Sub
                If Target = 0 Then Exit Sub
                
                If targetType = TARGET_TYPE_PLAYER Then
                    X = GetPlayerX(Target)
                    Y = GetPlayerY(Target)
                Else
                    X = MapNpc(mapNum).Npc(Target).X
                    Y = MapNpc(mapNum).Npc(Target).Y
                End If
                
                If Not isInRange(Range, GetPlayerX(index), GetPlayerY(index), X, Y) Then
                    PlayerMsg index, "Alvo não está no Alcance.", BrightRed
                    SendClearSpellBuffer index
                End If
            End If
            Select Case Spell(SpellNum).Type
                Case SPELL_TYPE_DAMAGEHP
                    DidCast = True
                    For i = 1 To Player_HighIndex
                        If IsPlaying(i) Then
                            If i <> index Then
                                If GetPlayerMap(i) = GetPlayerMap(index) Then
                                    If isInRange(AoE, X, Y, GetPlayerX(i), GetPlayerY(i)) Then
                                        If CanPlayerAttackPlayer(index, i, True) Then
                                            SendAnimation mapNum, Spell(SpellNum).SpellAnim, 0, 0, TARGET_TYPE_PLAYER, i
                                            PlayerAttackPlayer index, i, Vital / 2, SpellNum
                                            If Not TempPlayer(index).Target = i Then
                                                TempPlayer(index).Target = i
                                                TempPlayer(index).targetType = TARGET_TYPE_PLAYER
                                                SendTarget index
                                            End If
                                        End If
                                    End If
                                End If
                            End If
                        End If
                    Next
                    For i = 1 To MAX_MAP_NPCS
                        If MapNpc(mapNum).Npc(i).num > 0 Then
                            If MapNpc(mapNum).Npc(i).Vital(HP) > 0 Then
                                If isInRange(AoE, X, Y, MapNpc(mapNum).Npc(i).X, MapNpc(mapNum).Npc(i).Y) Then
                                    If CanPlayerAttackNpc(index, i, True) Then
                                        SendAnimation mapNum, Spell(SpellNum).SpellAnim, 0, 0, TARGET_TYPE_NPC, i
                                        PlayerAttackNpc index, i, Vital, SpellNum
                                        If Not TempPlayer(index).Target = i Then
                                            TempPlayer(index).Target = i
                                            TempPlayer(index).targetType = TARGET_TYPE_NPC
                                            SendTarget index
                                        End If
                                    End If
                                End If
                            End If
                        End If
                    Next
                Case SPELL_TYPE_HEALHP, SPELL_TYPE_HEALMP, SPELL_TYPE_DAMAGEMP
                    If Spell(SpellNum).Type = SPELL_TYPE_HEALHP Then
                        VitalType = Vitals.HP
                        increment = True
                    ElseIf Spell(SpellNum).Type = SPELL_TYPE_HEALMP Then
                        VitalType = Vitals.mp
                        increment = True
                    ElseIf Spell(SpellNum).Type = SPELL_TYPE_DAMAGEMP Then
                        VitalType = Vitals.mp
                        increment = False
                    End If
                    
                    DidCast = True
                    For i = 1 To Player_HighIndex
                        If IsPlaying(i) Then
                            If GetPlayerMap(i) = GetPlayerMap(index) Then
                                If isInRange(AoE, X, Y, GetPlayerX(i), GetPlayerY(i)) Then
                                    SpellPlayer_Effect VitalType, increment, i, Vital, SpellNum
                                End If
                            End If
                        End If
                    Next
                    For i = 1 To MAX_MAP_NPCS
                        If MapNpc(mapNum).Npc(i).num > 0 Then
                            If MapNpc(mapNum).Npc(i).Vital(HP) > 0 Then
                                If isInRange(AoE, X, Y, MapNpc(mapNum).Npc(i).X, MapNpc(mapNum).Npc(i).Y) Then
                                    SpellNpc_Effect VitalType, increment, i, Vital, SpellNum, mapNum
                                End If
                            End If
                        End If
                    Next
            End Select
        Case 2 ' targetted
            If targetType = 0 Then Exit Sub
            If Target = 0 Then Exit Sub
            
            If targetType = TARGET_TYPE_PLAYER Then
                X = GetPlayerX(Target)
                Y = GetPlayerY(Target)
            Else
                X = MapNpc(mapNum).Npc(Target).X
                Y = MapNpc(mapNum).Npc(Target).Y
            End If
                
            If Not isInRange(Range, GetPlayerX(index), GetPlayerY(index), X, Y) Then
                PlayerMsg index, "Alvo não está no alcance.", BrightRed
                SendClearSpellBuffer index
                Exit Sub
            End If
            
            Select Case Spell(SpellNum).Type
                Case SPELL_TYPE_DAMAGEHP
                    If targetType = TARGET_TYPE_PLAYER Then
                        If CanPlayerAttackPlayer(index, Target, True) Then
                            If Vital > 0 Then
                                SendAnimation mapNum, Spell(SpellNum).SpellAnim, 0, 0, TARGET_TYPE_PLAYER, Target
                                PlayerAttackPlayer index, Target, Vital, SpellNum
                                DidCast = True
                            End If
                        End If
                    Else
                        If CanPlayerAttackNpc(index, Target, True) Then
                            If Vital > 0 Then
                                SendAnimation mapNum, Spell(SpellNum).SpellAnim, 0, 0, TARGET_TYPE_NPC, Target
                                PlayerAttackNpc index, Target, Vital, SpellNum
                                DidCast = True
                            End If
                        End If
                    End If
                    
                Case SPELL_TYPE_DAMAGEMP, SPELL_TYPE_HEALMP, SPELL_TYPE_HEALHP
                    If Spell(SpellNum).Type = SPELL_TYPE_DAMAGEMP Then
                        VitalType = Vitals.mp
                        increment = False
                    ElseIf Spell(SpellNum).Type = SPELL_TYPE_HEALMP Then
                        VitalType = Vitals.mp
                        increment = True
                    ElseIf Spell(SpellNum).Type = SPELL_TYPE_HEALHP Then
                        VitalType = Vitals.HP
                        increment = True
                    End If
                    
                    If targetType = TARGET_TYPE_PLAYER Then
                        If Spell(SpellNum).Type = SPELL_TYPE_DAMAGEMP Then
                            If CanPlayerAttackPlayer(index, Target, True) Then
                                SpellPlayer_Effect VitalType, increment, Target, Vital, SpellNum
                            End If
                        Else
                            SpellPlayer_Effect VitalType, increment, Target, Vital, SpellNum
                        End If
                    Else
                        If Spell(SpellNum).Type = SPELL_TYPE_DAMAGEMP Then
                            If CanPlayerAttackNpc(index, Target, True) Then
                                SpellNpc_Effect VitalType, increment, Target, Vital, SpellNum, mapNum
                            End If
                        Else
                            SpellNpc_Effect VitalType, increment, Target, Vital, SpellNum, mapNum
                        End If
                    End If
            End Select
    End Select
    
    If DidCast Then
        Call SetPlayerVital(index, Vitals.mp, GetPlayerVital(index, Vitals.mp) - MPCost)
        Call SendVital(index, Vitals.mp)
        ' send vitals to party if in one
        If TempPlayer(index).inParty > 0 Then SendPartyVitals TempPlayer(index).inParty, index
        
        TempPlayer(index).SpellCD(spellslot) = GetTickCount + (Spell(SpellNum).CDTime * 1000)
        Call SendCooldown(index, spellslot)
        If Spell(SpellNum).CDTime > 0 Then
            'PlayerMsg index, Spell(SpellNum).CDTime, White
            SendCDTime index, spellslot, Spell(SpellNum).CDTime
        End If
        SendVital index, Vitals.HP
        If TempPlayer(index).inParty > 0 Then SendPartyVitals TempPlayer(index).inParty, index
        SendActionMsg mapNum, Trim$(Spell(SpellNum).Name) & "!", BrightRed, ACTIONMSG_SCROLL, GetPlayerX(index) * 32, GetPlayerY(index) * 32 - 80
    End If
End Sub

Public Sub SpellPlayer_Effect(ByVal Vital As Byte, ByVal increment As Boolean, ByVal index As Long, ByVal Damage As Long, ByVal SpellNum As Long)
Dim sSymbol As String * 1
Dim Colour As Long

    If Damage > 0 Then
        If increment Then
            sSymbol = "+"
            If Vital = Vitals.HP Then Colour = BrightGreen
            If Vital = Vitals.mp Then Colour = BrightBlue
        Else
            sSymbol = "-"
            Colour = Blue
        End If
    
        SendAnimation GetPlayerMap(index), Spell(SpellNum).SpellAnim, 0, 0, TARGET_TYPE_PLAYER, index
        SendActionMsg GetPlayerMap(index), sSymbol & Damage, Colour, ACTIONMSG_SCROLL, GetPlayerX(index) * 32, GetPlayerY(index) * 32
        
        ' send the sound
        SendMapSound index, GetPlayerX(index), GetPlayerY(index), SoundEntity.seSpell, SpellNum
        
        If increment Then
            SetPlayerVital index, Vital, GetPlayerVital(index, Vital) + Damage
            If Spell(SpellNum).Duration > 0 Then
                AddHoT_Player index, SpellNum
            End If
        ElseIf Not increment Then
            SetPlayerVital index, Vital, GetPlayerVital(index, Vital) - Damage
        End If
    End If
End Sub

Public Sub SpellNpc_Effect(ByVal Vital As Byte, ByVal increment As Boolean, ByVal index As Long, ByVal Damage As Long, ByVal SpellNum As Long, ByVal mapNum As Long)
Dim sSymbol As String * 1
Dim Colour As Long

    If Damage > 0 Then
        If increment Then
            sSymbol = "+"
            If Vital = Vitals.HP Then Colour = BrightGreen
            If Vital = Vitals.mp Then Colour = BrightBlue
        Else
            sSymbol = "-"
            Colour = Blue
        End If
    
        SendAnimation mapNum, Spell(SpellNum).SpellAnim, 0, 0, TARGET_TYPE_NPC, index
        SendActionMsg mapNum, sSymbol & Damage, Colour, ACTIONMSG_SCROLL, MapNpc(mapNum).Npc(index).X * 32, MapNpc(mapNum).Npc(index).Y * 32
        
        ' send the sound
        SendMapSound index, MapNpc(mapNum).Npc(index).X, MapNpc(mapNum).Npc(index).Y, SoundEntity.seSpell, SpellNum
        
        If increment Then
            MapNpc(mapNum).Npc(index).Vital(Vital) = MapNpc(mapNum).Npc(index).Vital(Vital) + Damage
            If Spell(SpellNum).Duration > 0 Then
                AddHoT_Npc mapNum, index, SpellNum
            End If
        ElseIf Not increment Then
            MapNpc(mapNum).Npc(index).Vital(Vital) = MapNpc(mapNum).Npc(index).Vital(Vital) - Damage
        End If
    End If
End Sub

Public Sub AddDoT_Player(ByVal index As Long, ByVal SpellNum As Long, ByVal Caster As Long)
Dim i As Long

    For i = 1 To MAX_DOTS
        With TempPlayer(index).DoT(i)
            If .Spell = SpellNum Then
                .Timer = GetTickCount
                .Caster = Caster
                .StartTime = GetTickCount
                Exit Sub
            End If
            
            If .Used = False Then
                .Spell = SpellNum
                .Timer = GetTickCount
                .Caster = Caster
                .Used = True
                .StartTime = GetTickCount
                Exit Sub
            End If
        End With
    Next
End Sub

Public Sub AddHoT_Player(ByVal index As Long, ByVal SpellNum As Long)
Dim i As Long

    For i = 1 To MAX_DOTS
        With TempPlayer(index).HoT(i)
            If .Spell = SpellNum Then
                .Timer = GetTickCount
                .StartTime = GetTickCount
                Exit Sub
            End If
            
            If .Used = False Then
                .Spell = SpellNum
                .Timer = GetTickCount
                .Used = True
                .StartTime = GetTickCount
                Exit Sub
            End If
        End With
    Next
End Sub

Public Sub AddDoT_Npc(ByVal mapNum As Long, ByVal index As Long, ByVal SpellNum As Long, ByVal Caster As Long)
Dim i As Long

    For i = 1 To MAX_DOTS
        With MapNpc(mapNum).Npc(index).DoT(i)
            If .Spell = SpellNum Then
                .Timer = GetTickCount
                .Caster = Caster
                .StartTime = GetTickCount
                Exit Sub
            End If
            
            If .Used = False Then
                .Spell = SpellNum
                .Timer = GetTickCount
                .Caster = Caster
                .Used = True
                .StartTime = GetTickCount
                Exit Sub
            End If
        End With
    Next
End Sub

Public Sub AddHoT_Npc(ByVal mapNum As Long, ByVal index As Long, ByVal SpellNum As Long)
Dim i As Long

    For i = 1 To MAX_DOTS
        With MapNpc(mapNum).Npc(index).HoT(i)
            If .Spell = SpellNum Then
                .Timer = GetTickCount
                .StartTime = GetTickCount
                Exit Sub
            End If
            
            If .Used = False Then
                .Spell = SpellNum
                .Timer = GetTickCount
                .Used = True
                .StartTime = GetTickCount
                Exit Sub
            End If
        End With
    Next
End Sub

Public Sub HandleDoT_Player(ByVal index As Long, ByVal dotNum As Long)
    With TempPlayer(index).DoT(dotNum)
        If .Used And .Spell > 0 Then
            ' time to tick?
            If GetTickCount > .Timer + (Spell(.Spell).Interval * 1000) Then
                If CanPlayerAttackPlayer(.Caster, index, True) Then
                    PlayerAttackPlayer .Caster, index, RAND(1, GetSpellBaseStat(.Caster, .Spell))
                End If
                .Timer = GetTickCount
                ' check if DoT is still active - if player died it'll have been purged
                If .Used And .Spell > 0 Then
                    ' destroy DoT if finished
                    If GetTickCount - .StartTime >= (Spell(.Spell).Duration * 1000) Then
                        .Used = False
                        .Spell = 0
                        .Timer = 0
                        .Caster = 0
                        .StartTime = 0
                    End If
                End If
            End If
        End If
    End With
End Sub

Public Sub HandleHoT_Player(ByVal index As Long, ByVal hotNum As Long)
    With TempPlayer(index).HoT(hotNum)
        If .Used And .Spell > 0 Then
            ' time to tick?
            If GetTickCount > .Timer + (Spell(.Spell).Interval * 1000) Then
                SendActionMsg Player(index).Map, "+" & Spell(.Spell).Vital, BrightGreen, ACTIONMSG_SCROLL, Player(index).X * 32, Player(index).Y * 32
                Player(index).Vital(Vitals.HP) = Player(index).Vital(Vitals.HP) + Spell(.Spell).Vital
                .Timer = GetTickCount
                ' check if DoT is still active - if player died it'll have been purged
                If .Used And .Spell > 0 Then
                    ' destroy hoT if finished
                    If GetTickCount - .StartTime >= (Spell(.Spell).Duration * 1000) Then
                        .Used = False
                        .Spell = 0
                        .Timer = 0
                        .Caster = 0
                        .StartTime = 0
                    End If
                End If
            End If
        End If
    End With
End Sub

Public Sub HandleDoT_Npc(ByVal mapNum As Long, ByVal index As Long, ByVal dotNum As Long)
    With MapNpc(mapNum).Npc(index).DoT(dotNum)
        If .Used And .Spell > 0 Then
            ' time to tick?
            If GetTickCount > .Timer + (Spell(.Spell).Interval * 1000) Then
                If CanPlayerAttackNpc(.Caster, index, True) Then
                    PlayerAttackNpc .Caster, index, RAND(1, GetSpellBaseStat(.Caster, .Spell)), , True
                End If
                .Timer = GetTickCount
                ' check if DoT is still active - if NPC died it'll have been purged
                If .Used And .Spell > 0 Then
                    ' destroy DoT if finished
                    If GetTickCount - .StartTime >= (Spell(.Spell).Duration * 1000) Then
                        .Used = False
                        .Spell = 0
                        .Timer = 0
                        .Caster = 0
                        .StartTime = 0
                    End If
                End If
            End If
        End If
    End With
End Sub

Public Sub HandleHoT_Npc(ByVal mapNum As Long, ByVal index As Long, ByVal hotNum As Long)
    With MapNpc(mapNum).Npc(index).HoT(hotNum)
        If .Used And .Spell > 0 Then
            ' time to tick?
            If GetTickCount > .Timer + (Spell(.Spell).Interval * 1000) Then
                SendActionMsg mapNum, "+" & Spell(.Spell).Vital, BrightGreen, ACTIONMSG_SCROLL, MapNpc(mapNum).Npc(index).X * 32, MapNpc(mapNum).Npc(index).Y * 32
                MapNpc(mapNum).Npc(index).Vital(Vitals.HP) = MapNpc(mapNum).Npc(index).Vital(Vitals.HP) + Spell(.Spell).Vital
                .Timer = GetTickCount
                ' check if DoT is still active - if NPC died it'll have been purged
                If .Used And .Spell > 0 Then
                    ' destroy hoT if finished
                    If GetTickCount - .StartTime >= (Spell(.Spell).Duration * 1000) Then
                        .Used = False
                        .Spell = 0
                        .Timer = 0
                        .Caster = 0
                        .StartTime = 0
                    End If
                End If
            End If
        End If
    End With
End Sub

Public Sub StunPlayer(ByVal index As Integer, ByVal SpellNum As Integer, ByVal Attacker As Integer)
Dim Gen As Long
Dim GenAtk As Long
Dim Duration As Long

Gen = GetPlayerStat(index, Stats.Willpower) * 10
GenAtk = GetPlayerStat(Attacker, Stats.Willpower) * 10

    ' check if it's a stunning spell
    If Spell(SpellNum).StunDuration > 0 Then
        Duration = Spell(SpellNum).StunDuration * 300
        Duration = Duration + GenAtk - Gen
        
        ' set the values on index
        TempPlayer(index).StunDuration = Duration
        TempPlayer(index).StunTimer = GetTickCount
        ' send it to the index
        SendStunned index

        ' tell him he's stunned
        If Duration > 500 Then
            PlayerMsg index, "Você foi paralizado por " & Duration / 1000 & " segundos!", BrightRed
        End If
    End If
End Sub

Public Sub StunNPC(ByVal index As Long, ByVal mapNum As Long, ByVal SpellNum As Long, ByVal Attacker As Long)
Dim Gen As Long
Gen = GetPlayerStat(Attacker, Stats.Willpower) * 5

    ' check if it's a stunning spell
    If Spell(SpellNum).StunDuration > 0 Then
        ' set the values on index
        MapNpc(mapNum).Npc(index).StunDuration = Gen + (Spell(SpellNum).StunDuration * 300)
        MapNpc(mapNum).Npc(index).StunTimer = GetTickCount
    End If
End Sub

'makes the pet follow its owner
Sub PetFollowOwner(ByVal index As Long)
    If TempPlayer(index).TempPetSlot < 1 Then Exit Sub
    
    MapNpc(GetPlayerMap(index)).Npc(TempPlayer(index).TempPetSlot).targetType = 1
    MapNpc(GetPlayerMap(index)).Npc(TempPlayer(index).TempPetSlot).Target = index
End Sub

'makes the pet wander around the map
Sub PetWander(ByVal index As Long)
    If TempPlayer(index).TempPetSlot < 1 Then Exit Sub

    MapNpc(GetPlayerMap(index)).Npc(TempPlayer(index).TempPetSlot).targetType = TARGET_TYPE_NONE
    MapNpc(GetPlayerMap(index)).Npc(TempPlayer(index).TempPetSlot).Target = 0
End Sub

'Clear the npc from the map
Sub PetDisband(ByVal index As Long, ByVal mapNum As Long)
    If TempPlayer(index).TempPetSlot < 1 Then Exit Sub
    
    Call ClearSingleMapNpc(TempPlayer(index).TempPetSlot, mapNum)
    Map(GetPlayerMap(index)).Npc(TempPlayer(index).TempPetSlot) = 0
    TempPlayer(index).TempPetSlot = 0
End Sub

Sub SpawnPet(ByVal index As Long, ByVal mapNum As Long, ByVal NpcNum As Long)
    Dim PlayerMap As Long
    Dim i As Integer
    Dim PetSlot As Byte
    
    'Prevent multiple pets for the same owner
    If TempPlayer(index).TempPetSlot > 0 Then Exit Sub
    
    PlayerMap = GetPlayerMap(index)
    PetSlot = 0
    
    If PlayerMap = 57 Or PlayerMap = 69 Or PlayerMap = 70 Then
        PlayerMsg index, "Você não pode usar no lugar onde está!", BrightRed
        Exit Sub
    End If
    
    If Map(GetPlayerMap(index)).Moral = MAP_MORAL_SAFE Then
        PlayerMsg index, "Não pode invocar em Zona Segura!", BrightRed
        Exit Sub
    End If
    
    For i = 1 To MAX_MAP_NPCS
        If Map(PlayerMap).Npc(i) = 0 Then
            PetSlot = i
            Exit For
        End If
    Next
    
    If PetSlot = 0 Then
        Call PlayerMsg(index, "O mapa está muito cheio!", Red)
        Exit Sub
    End If

    'create the pet for the map
    Map(PlayerMap).Npc(PetSlot) = NpcNum
    MapNpc(PlayerMap).Npc(PetSlot).num = NpcNum
    'set its Pet Data
    MapNpc(PlayerMap).Npc(PetSlot).IsPet = YES
    MapNpc(PlayerMap).Npc(PetSlot).PetData.Name = GetPlayerName(index) & "'s " & Npc(NpcNum).Name
    MapNpc(PlayerMap).Npc(PetSlot).PetData.Owner = index
    
    'If Pet doesn't exist with player, link it to the player
    If Player(index).Pet.SpriteNum <> NpcNum Then
        Player(index).Pet.SpriteNum = NpcNum
        Player(index).Pet.Name = GetPlayerName(index) & "'s " & Npc(NpcNum).Name
    End If
    
    TempPlayer(index).TempPetSlot = PetSlot
       
    'cache the map for sending
    Call MapCache_Create(PlayerMap)
    
    'send the update
    For i = 1 To Player_HighIndex
        If IsPlaying(i) Then
            If GetPlayerMap(i) = GetPlayerMap(index) Then
                SendMap i, PlayerMap
            End If
        End If
    Next

    Select Case GetPlayerDir(index)
        Case DIR_UP
            Call SpawnNpc(PetSlot, PlayerMap, GetPlayerX(index), GetPlayerY(index) - 1)
        Case DIR_DOWN
            Call SpawnNpc(PetSlot, PlayerMap, GetPlayerX(index), GetPlayerY(index) + 1)
        Case DIR_LEFT
            Call SpawnNpc(PetSlot, PlayerMap, GetPlayerX(index) + 1, GetPlayerY(index))
        Case DIR_RIGHT
            Call SpawnNpc(PetSlot, PlayerMap, GetPlayerX(index), GetPlayerY(index) - 1)
    End Select
    
    're-warp the players on the map
    For i = 1 To Player_HighIndex
        If IsPlaying(i) Then
            If GetPlayerMap(i) = GetPlayerMap(index) Then
                Call PlayerWarp(i, GetPlayerMap(i), GetPlayerX(i), GetPlayerY(i))
            End If
            
        End If
    Next
    
    SendPetBox index, Player(index).Pet.Name, Npc(Player(index).Pet.SpriteNum).Sprite
    PlayerWarp index, GetPlayerMap(index), GetPlayerX(index), GetPlayerY(index)
    PetFollowOwner index
End Sub

Function CanNpcAttackNpc(ByVal mapNum As Long, ByVal Attacker As Long, ByVal Victim As Long) As Boolean
    Dim aNpcNum As Long
    Dim vNpcNum As Long
    Dim VictimX As Long
    Dim VictimY As Long
    Dim AttackerX As Long
    Dim AttackerY As Long
    
    CanNpcAttackNpc = False

    ' Check for subscript out of range
    If Attacker <= 0 Or Attacker > MAX_MAP_NPCS Then
        Exit Function
    End If
    
    If Victim <= 0 Or Victim > MAX_MAP_NPCS Then
        Exit Function
    End If

    ' Check for subscript out of range
    If MapNpc(mapNum).Npc(Attacker).num <= 0 Then
        Exit Function
    End If
    
    ' Check for subscript out of range
    If MapNpc(mapNum).Npc(Victim).num <= 0 Then
        Exit Function
    End If

    aNpcNum = MapNpc(mapNum).Npc(Attacker).num
    vNpcNum = MapNpc(mapNum).Npc(Victim).num
    
    If aNpcNum <= 0 Then Exit Function
    If vNpcNum <= 0 Then Exit Function

    ' Make sure the npcs arent already dead
    If MapNpc(mapNum).Npc(Attacker).Vital(Vitals.HP) <= 0 Then
        Exit Function
    End If
    
    ' Make sure the npc isn't already dead
    If MapNpc(mapNum).Npc(Victim).Vital(Vitals.HP) <= 0 Then
        Exit Function
    End If

    ' Make sure npcs dont attack more then once a second
    If GetTickCount < MapNpc(mapNum).Npc(Attacker).AttackTimer + 1000 Then
        Exit Function
    End If
    
    If Npc(MapNpc(mapNum).Npc(Victim).num).Behaviour = NPC_BEHAVIOUR_BOSS Then
        Exit Function
    End If
    
    MapNpc(mapNum).Npc(Attacker).AttackTimer = GetTickCount
    
    AttackerX = MapNpc(mapNum).Npc(Attacker).X
    AttackerY = MapNpc(mapNum).Npc(Attacker).Y
    VictimX = MapNpc(mapNum).Npc(Victim).X
    VictimY = MapNpc(mapNum).Npc(Victim).Y

    ' Check if at same coordinates
    If (VictimY + 1 = AttackerY) And (VictimX = AttackerX) Then
        CanNpcAttackNpc = True
    Else

        If (VictimY - 1 = AttackerY) And (VictimX = AttackerX) Then
            CanNpcAttackNpc = True
        Else

            If (VictimY = AttackerY) And (VictimX + 1 = AttackerX) Then
                CanNpcAttackNpc = True
            Else

                If (VictimY = AttackerY) And (VictimX - 1 = AttackerX) Then
                    CanNpcAttackNpc = True
                End If
            End If
        End If
    End If

End Function

Sub NpcAttackNpc(ByVal mapNum As Long, ByVal Attacker As Long, ByVal Victim As Long, ByVal Damage As Long)
    Dim i As Long
    Dim Buffer As clsBuffer
    Dim aNpcNum As Long
    Dim vNpcNum As Long
    Dim n As Long
    Dim PetOwner As Long
    Dim EXP As Long
    
    If Attacker <= 0 Or Attacker > MAX_MAP_NPCS Then Exit Sub
    If Victim <= 0 Or Victim > MAX_MAP_NPCS Then Exit Sub
    
    If Damage <= 0 Then Exit Sub
    
    aNpcNum = MapNpc(mapNum).Npc(Attacker).num
    vNpcNum = MapNpc(mapNum).Npc(Victim).num
    
    If aNpcNum <= 0 Then Exit Sub
    If vNpcNum <= 0 Then Exit Sub
    
    'set the victim's target to the pet attacking it
    MapNpc(mapNum).Npc(Victim).targetType = 2 'Npc
    MapNpc(mapNum).Npc(Victim).Target = Attacker
    
    ' Send this packet so they can see the person attacking
    Set Buffer = New clsBuffer
    Buffer.WriteLong SNpcAttack
    Buffer.WriteLong Attacker
    SendDataToMap mapNum, Buffer.ToArray()
    Set Buffer = Nothing

    If Damage >= MapNpc(mapNum).Npc(Victim).Vital(Vitals.HP) Then
        SendActionMsg mapNum, "-" & Damage, BrightRed, 1, (MapNpc(mapNum).Npc(Victim).X * 32), (MapNpc(mapNum).Npc(Victim).Y * 32)
        SendBlood mapNum, MapNpc(mapNum).Npc(Victim).X, MapNpc(mapNum).Npc(Victim).Y
        
        ' npc is dead.
        'Call GlobalMsg(CheckGrammar(Trim$(Npc(vNpcNum).Name), 1) & " has been killed by " & CheckGrammar(Trim$(Npc(aNpcNum).Name)) & "!", BrightRed)

        ' Set NPC target to 0
        MapNpc(mapNum).Npc(Attacker).Target = 0
        MapNpc(mapNum).Npc(Attacker).targetType = 0
        'reset the targetter for the player
        
        If MapNpc(mapNum).Npc(Attacker).IsPet = YES Then
            TempPlayer(MapNpc(mapNum).Npc(Attacker).PetData.Owner).Target = 0
            TempPlayer(MapNpc(mapNum).Npc(Attacker).PetData.Owner).targetType = TARGET_TYPE_NONE
            
            PetOwner = MapNpc(mapNum).Npc(Attacker).PetData.Owner
            EXP = Npc(MapNpc(mapNum).Npc(Victim).num).EXP
            Dim DsH As Byte
            For DsH = 1 To Equipment.Equipment_Count - 1
                If GetPlayerEquipment(PetOwner, DsH) > 0 Then
                    If Item(GetPlayerEquipment(PetOwner, DsH)).ExpExtra > 0 Then
                        EXP = EXP * Item(GetPlayerEquipment(PetOwner, DsH)).ExpExtra / 100
                    End If
                End If
            Next
            
            If Player(PetOwner).VipData.VIP = 1 Then EXP = EXP * 1.5
            If Player(PetOwner).VipData.VIP = 2 Then EXP = EXP * 2
            
            If Not frmServer.txtEventoEXP.Text = 0 Then
                EXP = EXP * frmServer.txtEventoEXP.Text * 4
            End If
            
            SendTarget PetOwner
            
            'Give the player the pet owner some experience from the kill
            TempPlayer(PetOwner).GanhouEXP = YES
            GivePlayerEXP PetOwner, EXP
            If Player(PetOwner).Org > 0 Then
                For i = 1 To Player_HighIndex
                    If Player(i).Org = Player(PetOwner).Org Then
                        If Not i = PetOwner Then
                            If GetPlayerMap(i) = GetPlayerMap(PetOwner) Then
                                TempPlayer(i).GanhouEXP = YES
                                GivePlayerEXP i, EXP / 2
                            End If
                        End If
                    End If
                Next
            Else
                If TempPlayer(PetOwner).inParty > 0 Then
                    Party_ShareExp TempPlayer(PetOwner).inParty, EXP, PetOwner
                End If
            End If
                      
        ElseIf MapNpc(mapNum).Npc(Victim).IsPet = YES Then
            'Get the pet owners' index
            PetOwner = MapNpc(mapNum).Npc(Victim).PetData.Owner
            'Set the NPC's target on the owner now
            MapNpc(mapNum).Npc(Attacker).targetType = 1 'player
            MapNpc(mapNum).Npc(Attacker).Target = PetOwner
            'Disband the pet
            PetDisband PetOwner, GetPlayerMap(PetOwner)
        End If
               
        ' Drop the goods if they get it
        'For n = 1 To MAX_NPC_DROPS
        'If Npc(vNpcNum).DropItem <> 0 Then
            'If Rnd <= Npc(vNpcNum).DropChance Then
                'Call SpawnItem(Npc(vNpcNum).DropItem, Npc(vNpcNum).DropItemValue, mapNum, MapNpc(mapNum).Npc(Victim).X, MapNpc(mapNum).Npc(Victim).Y)
            'End If
        'End If
        'Next
        
        
        ' Reset victim's stuff so it dies in loop
        MapNpc(mapNum).Npc(Victim).num = 0
        MapNpc(mapNum).Npc(Victim).SpawnWait = GetTickCount
        MapNpc(mapNum).Npc(Victim).Vital(Vitals.HP) = 0
               
        ' send npc death packet to map
        Set Buffer = New clsBuffer
        Buffer.WriteLong SNpcDead
        Buffer.WriteLong Victim
        SendDataToMap mapNum, Buffer.ToArray()
        Set Buffer = Nothing
        
        If PetOwner > 0 Then
            PetFollowOwner PetOwner
        End If
    Else
        ' npc not dead, just do the damage
        MapNpc(mapNum).Npc(Victim).Vital(Vitals.HP) = MapNpc(mapNum).Npc(Victim).Vital(Vitals.HP) - Damage
       
        ' Say damage
        SendActionMsg mapNum, "-" & Damage, BrightRed, 1, (MapNpc(mapNum).Npc(Victim).X * 32), (MapNpc(mapNum).Npc(Victim).Y * 32)
        SendBlood mapNum, MapNpc(mapNum).Npc(Victim).X, MapNpc(mapNum).Npc(Victim).Y
    End If
    
    'Send both Npc's Vitals to the client
    SendMapNpcVitals mapNum, Attacker
    SendMapNpcVitals mapNum, Victim

End Sub

Public Sub NpcSpell(ByVal mapNum As Long, ByVal mapNpcNum As Long, ByVal SpellNum As Long, ByVal Target As Long)
If mapNum < 1 Or mapNum > MAX_MAPS Then Exit Sub
If mapNpcNum < 1 Or mapNpcNum > MAX_MAP_NPCS Then Exit Sub
If SpellNum < 1 Or SpellNum > MAX_SPELLS Then Exit Sub
Dim NpcNum As Long

NpcNum = MapNpc(mapNum).Npc(mapNpcNum).num
Select Case NpcNum
    Case 41 'Haku
        Select Case RAND(1, 2)
            Case 1
                NpcMagiaArea mapNum, mapNpcNum, 15 'Kirigakure
                SendActionMsg mapNum, Spell(15).Name, BrightBlue, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case 2
                NpcMagiaReta mapNum, mapNpcNum, 16 'Suiryuudan
                SendActionMsg mapNum, Spell(16).Name, BrightBlue, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case Else
        End Select
        
    Case 42 'Zabuza
        Select Case RAND(1, 4)
            Case 1
                NpcMagiaArea mapNum, mapNpcNum, 15 'Kirigakure
                SendActionMsg mapNum, Spell(15).Name, BrightBlue, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case 2
                NpcMagiaReta mapNum, mapNpcNum, 16 'Suiryuudan
                SendActionMsg mapNum, Spell(16).Name, BrightBlue, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case 3
                NpcMagiaArea mapNum, mapNpcNum, 17 'Suijinheki
                SendActionMsg mapNum, Spell(17).Name, BrightBlue, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case 4
                NpcMagiaReta mapNum, mapNpcNum, 18 'Suishouha
                SendActionMsg mapNum, Spell(18).Name, BrightBlue, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case Else
        End Select
        
    Case 60, 61, 64, 65 'Jiroubou/Tayuya
        Select Case RAND(1, 2)
            Case 1
                NpcMagiaReta mapNum, mapNpcNum, 23
                SendActionMsg mapNum, Spell(23).Name, BrightBlue, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case 2
                NpcMagiaReta mapNum, mapNpcNum, 25
                SendActionMsg mapNum, Spell(25).Name, BrightBlue, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case Else
        End Select
        
    Case 62, 63 'Kindoumaru
        Select Case RAND(1, 2)
            Case 1
                NpcMagiaReta mapNum, mapNpcNum, 11
                SendActionMsg mapNum, Spell(11).Name, BrightBlue, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case 2
                NpcMagiaReta mapNum, mapNpcNum, 13
                SendActionMsg mapNum, Spell(13).Name, BrightBlue, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case Else
        End Select
        
    Case 66, 67 'Sakon
        Select Case RAND(1, 2)
            Case 1
                NpcMagiaReta mapNum, mapNpcNum, 20
                SendActionMsg mapNum, Spell(20).Name, BrightBlue, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case 2
                NpcMagiaReta mapNum, mapNpcNum, 21
                SendActionMsg mapNum, Spell(21).Name, BrightBlue, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case Else
        End Select
    
    Case 72 'Orochimaru
        Select Case RAND(1, 4)
            Case 1
                NpcMagiaReta mapNum, mapNpcNum, 10
                SendActionMsg mapNum, Spell(10).Name, BrightBlue, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case 2
                NpcMagiaArea mapNum, mapNpcNum, 14
                SendActionMsg mapNum, Spell(14).Name, BrightBlue, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case 3
                NpcMagiaArea mapNum, mapNpcNum, 18
                SendActionMsg mapNum, Spell(18).Name, BrightBlue, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case 4
                NpcMagiaArea mapNum, mapNpcNum, 22
                SendActionMsg mapNum, Spell(22).Name, BrightBlue, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case Else
        End Select
    
    Case 79, 251 'Sasori
        Select Case RAND(1, 6)
            Case 1 'Goukakyu
                NpcMagiaReta mapNum, mapNpcNum, 7
                SendActionMsg mapNum, Spell(7).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case 2 'Ryuuka
                NpcMagiaReta mapNum, mapNpcNum, 8
                SendActionMsg mapNum, Spell(8).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case 3 'Housenka
                NpcMagiaReta mapNum, mapNpcNum, 9
                SendActionMsg mapNum, Spell(9).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case 4 'KaryuuEndan
                NpcMagiaReta mapNum, mapNpcNum, 10
                SendActionMsg mapNum, Spell(10).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case 5 'Venonosa
                NpcNormalMagic mapNum, mapNpcNum, 254
                SendActionMsg mapNum, Spell(254).Name, Green, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case 6 'Shuriken
                NpcNormalMagic mapNum, mapNpcNum, 255
                SendActionMsg mapNum, Spell(255).Name, Grey, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case Else
        End Select
    
    Case 253 'Karasu
        Select Case RAND(1, 2)
            Case 1 'Venonosa
                NpcNormalMagic mapNum, mapNpcNum, 254
                SendActionMsg mapNum, Spell(254).Name, Green, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case 2 'Shuriken
                NpcNormalMagic mapNum, mapNpcNum, 255
                SendActionMsg mapNum, Spell(255).Name, Grey, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case Else
        End Select
        
    Case 254 'Sanshouou
        Select Case RAND(1, 3)
            Case 1 'Goukakyu
                NpcMagiaReta mapNum, mapNpcNum, 7
                SendActionMsg mapNum, Spell(7).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case 2 'Ryuuka
                NpcMagiaReta mapNum, mapNpcNum, 8
                SendActionMsg mapNum, Spell(8).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case 3 'Housenka
                NpcMagiaReta mapNum, mapNpcNum, 9
                SendActionMsg mapNum, Spell(9).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case Else
        End Select
        
    Case 74, 75, 97 'Hida,Hiruko
        NpcMagiaReta mapNum, mapNpcNum, 96
    
    Case 76 'Deidara
        NpcNormalMagic mapNum, mapNpcNum, 95
    
    Case 78 'Kakuzo
        Select Case RAND(1, 5)
            Case 1
                NpcMagiaReta mapNum, mapNpcNum, 10
            Case 2
                NpcMagiaReta mapNum, mapNpcNum, 11
            Case 3
                NpcMagiaReta mapNum, mapNpcNum, 20
            Case 4
                NpcMagiaReta mapNum, mapNpcNum, 25
            Case 5
                NpcMagiaArea mapNum, mapNpcNum, 18
            Case Else
        End Select
    
    Case 123 'Gamabunta
        Select Case RAND(1, 2)
            Case 1
                NpcMagiaReta mapNum, mapNpcNum, 16
            Case 2
                NpcMagiaArea mapNum, mapNpcNum, 18
            Case Else
        End Select
    Case 124 'KaTsuyu
        NpcMagiaReta mapNum, mapNpcNum, 254
    
Case Else

End Select

End Sub

