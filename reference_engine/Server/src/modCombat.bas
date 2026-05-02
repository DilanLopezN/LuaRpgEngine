Attribute VB_Name = "modCombat"
Option Explicit

' ################################
' ##      Basic Calculations    ##
' ################################

Function GetPlayerMaxVital(ByVal index As Long, ByVal Vital As Vitals) As Long
    If index > MAX_PLAYERS Then Exit Function
    Select Case Vital
        Case HP
            If GetClassStat(GetPlayerClass(index)) = Stats.strength Then 'TAI
                GetPlayerMaxVital = ((GetPlayerLevel(index) / 2) + (GetPlayerStat(index, Stats.Endurance) / 2)) * 25 + 150
                If GetPlayerMaxVital < 1 Then GetPlayerMaxVital = 1
            Else 'Ninjutsu
                GetPlayerMaxVital = ((GetPlayerLevel(index) / 2) + (GetPlayerStat(index, Stats.Endurance) / 2)) * 20 + 65
                If GetPlayerMaxVital < 1 Then GetPlayerMaxVital = 1
            End If
        Case mp
            If GetClassStat(GetPlayerClass(index)) = Stats.strength Then 'TAI
                GetPlayerMaxVital = ((GetPlayerLevel(index) / 2) + (GetPlayerStat(index, Stats.Intelligence) / 2)) * 5 + 25
                If GetPlayerMaxVital < 1 Then GetPlayerMaxVital = 1
            Else 'NIN
                GetPlayerMaxVital = ((GetPlayerLevel(index) / 2) + (GetPlayerStat(index, Stats.Intelligence) / 2)) * 30 + 85
                If GetPlayerMaxVital < 1 Then GetPlayerMaxVital = 1
            End If
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

Function GetPlayerDamage(ByVal index As Long, Optional ByVal isNin As Boolean) As Long
    Dim weaponNum As Long
    
    GetPlayerDamage = 0

    ' Check for subscript out of range
    If IsPlaying(index) = False Or index <= 0 Or index > MAX_PLAYERS Then
        Exit Function
    End If
    
    If isNin Then
        If GetPlayerEquipment(index, Weapon) > 0 Then
            weaponNum = GetPlayerEquipment(index, Weapon)
            GetPlayerDamage = 0.085 * 5 * GetPlayerStat(index, Stats.Intelligence) * Item(weaponNum).Data2 + (GetPlayerLevel(index) / 5)
        Else
            GetPlayerDamage = 0.085 * 5 * GetPlayerStat(index, Stats.Intelligence) + (GetPlayerLevel(index) / 5)
        End If
    Else
        If GetPlayerEquipment(index, Weapon) > 0 Then
            weaponNum = GetPlayerEquipment(index, Weapon)
            GetPlayerDamage = 0.085 * 5 * GetPlayerStat(index, strength) * Item(weaponNum).Data2 + (GetPlayerLevel(index) / 5)
        Else
            GetPlayerDamage = 0.085 * 5 * GetPlayerStat(index, strength) + (GetPlayerLevel(index) / 5)
        End If
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

If GetPlayerAccess(index) >= ADMIN_MONITOR And Not GetPlayerAccess(index) = ADMIN_CREATOR Then
    'PlayerMsg index, "GM's não atacam", White
    Exit Sub
End If

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
        If GetPlayerEquipment(index, Equipment.Weapon) = 108 Then 'lendaria nin
            Damage = GetPlayerDamage(index, True)
        Else
            Damage = GetPlayerDamage(index, False)
        End If
        
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

Public Function CanPlayerAttackNpc(ByVal attacker As Long, ByVal mapNpcNum As Long, Optional ByVal IsSpell As Boolean = False) As Boolean
    Dim mapNum As Long
    Dim NpcNum As Long
    Dim NpcX As Long
    Dim NpcY As Long
    Dim attackspeed As Long

    ' Check for subscript out of range
    If IsPlaying(attacker) = False Or mapNpcNum <= 0 Or mapNpcNum > MAX_MAP_NPCS Then
        Exit Function
    End If

    ' Check for subscript out of range
    If MapNpc(GetPlayerMap(attacker)).Npc(mapNpcNum).num <= 0 Then
        Exit Function
    End If
    
    If GetPlayerAccess(attacker) >= ADMIN_MONITOR And Not GetPlayerAccess(attacker) = ADMIN_CREATOR Then
        PlayerMsg attacker, "GM's não atacam", White
        Exit Function
    End If

    mapNum = GetPlayerMap(attacker)
    NpcNum = MapNpc(mapNum).Npc(mapNpcNum).num
    
    ' Make sure the npc isn't already dead
    If MapNpc(mapNum).Npc(mapNpcNum).Vital(Vitals.HP) <= 0 Then
        Exit Function
    End If

    ' Make sure they are on the same map
    If IsPlaying(attacker) Then
    
    If MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner = attacker Then Exit Function
    
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
        If GetPlayerEquipment(attacker, Weapon) > 0 Then
            attackspeed = Item(GetPlayerEquipment(attacker, Weapon)).Speed
        Else
            attackspeed = 1000
        End If

        If NpcNum > 0 And GetTickCount > TempPlayer(attacker).AttackTimer + attackspeed Then
            ' Check if at same coordinates
            Select Case GetPlayerDir(attacker)
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

            If NpcX = GetPlayerX(attacker) Then
                If NpcY = GetPlayerY(attacker) Then
                
                Dim i As Byte
                  For i = 1 To 10
                     If Player(attacker).QuestNum(i) > 0 Then
                        If Quest(Player(attacker).QuestNum(i)).tipo = QUEST_TYPE_TALKTO Then
                           CheckQuestTalk attacker, i, NpcNum
                        End If
                     End If
                  Next
                
                If Npc(MapNpc(mapNum).Npc(mapNpcNum).num).Script > 0 Then
                      ScriptedNpc attacker, Npc(MapNpc(mapNum).Npc(mapNpcNum).num).Script, mapNpcNum
                  End If
                
                    If Npc(NpcNum).Behaviour <> NPC_BEHAVIOUR_FRIENDLY And Npc(NpcNum).Behaviour <> NPC_BEHAVIOUR_SHOPKEEPER Then
                        CanPlayerAttackNpc = True
                    Else
                        'If Not Npc(NpcNum).AttackSay = "                    " Then
                            'PlayerMsg Attacker, Trim$(Npc(NpcNum).Name) & ": " & Trim$(Npc(NpcNum).AttackSay), White
                        'End If
                    End If
                End If
            End If
        End If
    End If

End Function

Public Sub PlayerAttackNpc(ByVal attacker As Long, ByVal mapNpcNum As Long, ByVal Damage As Long, Optional ByVal SpellNum As Long, Optional ByVal overTime As Boolean = False)
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
    Dim j As Byte
    Dim upAlone As Byte
    Dim hitNpcUpTmp As Byte
    
    ' Check for subscript out of range
    If IsPlaying(attacker) = False Or mapNpcNum <= 0 Or mapNpcNum > MAX_MAP_NPCS Or Damage < 0 Then
        Exit Sub
    End If

    mapNum = GetPlayerMap(attacker)
    
    NpcNum = MapNpc(mapNum).Npc(mapNpcNum).num
    
    If NpcNum < 1 Or NpcNum > MAX_NPCS Then Exit Sub
    
    Name = Trim$(Npc(NpcNum).Name)
    
    ' Check for weapon
    n = 0

    If GetPlayerEquipment(attacker, Weapon) > 0 Then
        n = GetPlayerEquipment(attacker, Weapon)
    End If
    
    ' set the regen timer
    TempPlayer(attacker).stopRegen = True
    TempPlayer(attacker).stopRegenTimer = GetTickCount
    
    If NpcNum = 201 Then 'npc pinhata
        Damage = 1
        TempPlayer(attacker).hitNpcPinhata = YES
    End If
    
    If Damage >= MapNpc(mapNum).Npc(mapNpcNum).Vital(Vitals.HP) Then
        
        SendActionMsg GetPlayerMap(attacker), "-" & MapNpc(mapNum).Npc(mapNpcNum).Vital(Vitals.HP), BrightRed, 1, (MapNpc(mapNum).Npc(mapNpcNum).X * 32), (MapNpc(mapNum).Npc(mapNpcNum).Y * 32)
        SendBlood GetPlayerMap(attacker), MapNpc(mapNum).Npc(mapNpcNum).X, MapNpc(mapNum).Npc(mapNpcNum).Y
        
        ' send the sound
        If SpellNum > 0 Then SendMapSound attacker, MapNpc(mapNum).Npc(mapNpcNum).X, MapNpc(mapNum).Npc(mapNpcNum).Y, SoundEntity.seSpell, SpellNum
        
        ' send animation
        If n > 0 Then
            If Not overTime Then
                If SpellNum = 0 Then Call SendAnimation(mapNum, Item(GetPlayerEquipment(attacker, Weapon)).Animation, MapNpc(mapNum).Npc(mapNpcNum).X, MapNpc(mapNum).Npc(mapNpcNum).Y)
            End If
        End If
        
        
        If MapNpc(mapNum).Npc(mapNpcNum).IsPet Then
            PetOwner = MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner
            If PetOwner > 0 Then
                
                Select Case GetPlayerClass(PetOwner)
                    Case ITACHI, DEIDARA
                        SendAnimation mapNum, 73, MapNpc(mapNum).Npc(mapNpcNum).X, MapNpc(mapNum).Npc(mapNpcNum).Y
                        NpcAttackPlayer mapNpcNum, attacker, GetNpcDamage(NpcNum)
                    Case KAKASHI
                        SendAnimation mapNum, 18, MapNpc(mapNum).Npc(mapNpcNum).X, MapNpc(mapNum).Npc(mapNpcNum).Y
                        NpcAttackPlayer mapNpcNum, attacker, GetNpcDamage(NpcNum)
                    Case Else
                End Select
                    
                PetDisband PetOwner, mapNum
            End If
        End If

        ' Calculate exp to give attacker
        EXP = Npc(NpcNum).EXP
        
        TempPlayer(attacker).hitNpcUp = GetTickCount + 30000
        hitNpcUpTmp = YES
        
        If IsUpAlone(attacker) = True Then
            EXP = EXP * 2
            upAlone = YES
        Else
            upAlone = NO
        End If
        
        If Player(attacker).Resets < 1 Then
            EXP = EXP * 100
        Else
            If GetPlayerLevel(attacker) <= 500 Then
                EXP = EXP * 10
            End If
        End If
        
        Dim DsH As Byte
        For DsH = 1 To Equipment.Equipment_Count - 1
            If GetPlayerEquipment(attacker, DsH) > 0 Then
                If Item(GetPlayerEquipment(attacker, DsH)).ExpExtra > 0 Then
                    EXP = EXP * Item(GetPlayerEquipment(attacker, DsH)).ExpExtra / 100
                End If
            End If
        Next
        
        If Player(attacker).VipData.VIP = 1 Then EXP = EXP * 1.5
        If Player(attacker).VipData.VIP = 2 Then EXP = EXP * 2

        If Not frmServer.txtEventoEXP.Text = 0 Then
           EXP = EXP * frmServer.txtEventoEXP.Text
        End If

        ' Make sure we dont get less then 0
        If EXP < 0 Then
            EXP = 1
        End If
        
        Dim randNum As Long
        
        If NpcNum = 201 Then 'evento pinhata
            TempPlayer(attacker).SetExp = YES
            SetPlayerExp attacker, GetPlayerNextLevel(attacker)
            CheckPlayerLevelUp attacker
            
            randNum = RAND(0, 10)
            
            Select Case randNum
                Case 10
                    addVIP attacker, 2
                Case 7 To 9
                    addCT attacker, 2
                Case Else
                    randNum = RAND(0, GetPlayerLevel(attacker) * 2)
                    If randNum > 2000 Then randNum = 2000
                    
                    GiveInvItem attacker, 254, randNum, True
                    PlayerMsg attacker, "Você ganhou " & randNum & " de CASH!", Yellow
            End Select
            
            For j = 1 To Player_HighIndex
                If GetPlayerMap(attacker) = GetPlayerMap(j) Then
                    If TempPlayer(j).hitNpcPinhata = YES Then
                        If attacker <> j Then
                            randNum = RAND(1, 3)
                            
                            Select Case randNum
                                Case 1
                                    TempPlayer(j).SetExp = YES
                                    SetPlayerExp j, GetPlayerNextLevel(j)
                                    CheckPlayerLevelUp j
                                    PlayerMsg j, "Você upou 1 lvl!", Yellow
                                Case 2
                                    randNum = RAND(0, GetPlayerLevel(j))
                                    If randNum > 2000 Then randNum = 2000
                                    
                                    GiveInvItem j, 254, randNum, True
                                    PlayerMsg j, "Você ganhou " & randNum & " de CASH!", Yellow
                                Case Else
                                    PlayerMsg j, "Vish.. Hoje tu deu azar e não chegou nada pra ti. Não desanima porque esse evento ocorre várias vezes ao dia. Fique atento.", Pink
                            End Select
                        End If
                    Else
                        PlayerMsg j, "Po cara, tu não ajudou em nada.. Da próxima vez entra na vibe do evento.", BrightRed
                    End If
                End If
            Next
            
            If RAND(1, 2) = 2 And Hour(Now) < 23 And frmServer.chkEventActive.Value = NO Then
                frmServer.txtEventoEXP.Text = "2"
                frmServer.txtEventHour.Text = Trim(Hour(Now) + 1)
                '###########
                GlobalMsg "Evento 2x EXP ativo até as :" & frmServer.txtEventHour & " horas", BrightCyan
                frmServer.chkEventActive.Value = YES
            End If
        End If
        
    If Player(attacker).Map <> 297 Then
        If Player(attacker).Org > 0 Then
            TempPlayer(attacker).GanhouEXP = YES
            GivePlayerEXP attacker, EXP, upAlone
    
            For j = 1 To Player_HighIndex
                If GetPlayerMap(attacker) = GetPlayerMap(j) Then
                    If Player(j).Org = Player(attacker).Org Then
                        If attacker <> j Then
                            EXP = Npc(NpcNum).EXP
                            
                            If Player(j).VipData.VIP = 1 Then EXP = EXP * 1.5
                            If Player(j).VipData.VIP = 2 Then EXP = EXP * 2
                    
                            If Not frmServer.txtEventoEXP.Text = 0 Then
                               EXP = EXP * frmServer.txtEventoEXP.Text
                            End If
                            
                            TempPlayer(j).GanhouEXP = YES
                            If TempPlayer(j).hitNpcUp > 0 Then
                                GivePlayerEXP j, EXP / 2, NO, NO
                            Else
                                GivePlayerEXP j, EXP / 6, NO, YES
                            End If
                        End If
                    End If
                End If
            Next
        Else
        ' in party?
            If TempPlayer(attacker).inParty > 0 Then
                ' pass through party sharing function
                TempPlayer(attacker).GanhouEXP = YES
                GivePlayerEXP attacker, EXP, upAlone
                
                For j = 1 To Player_HighIndex
                    If GetPlayerMap(attacker) = GetPlayerMap(j) Then
                        If TempPlayer(j).inParty = TempPlayer(attacker).inParty Then
                            If attacker <> j Then
                                EXP = Npc(NpcNum).EXP
                            
                                If Player(j).VipData.VIP = 1 Then EXP = EXP * 1.5
                                If Player(j).VipData.VIP = 2 Then EXP = EXP * 2
                        
                                If Not frmServer.txtEventoEXP.Text = 0 Then
                                   EXP = EXP * frmServer.txtEventoEXP.Text
                                End If
                                
                                TempPlayer(j).GanhouEXP = YES
                                
                                If TempPlayer(j).hitNpcUp > 0 Then
                                    GivePlayerEXP j, EXP / 2, NO, NO
                                Else
                                    GivePlayerEXP j, EXP / 6, NO, YES
                                End If
                            End If
                        End If
                    End If
                Next
                
                'Party_ShareExp TempPlayer(Attacker).inParty, EXP, Attacker
            Else
                ' no party - keep exp for self
                TempPlayer(attacker).GanhouEXP = YES
                GivePlayerEXP attacker, EXP, upAlone
            End If
        End If
    Else 'Esta na guerra
        TempPlayer(attacker).GanhouEXP = YES
        GivePlayerEXP attacker, EXP
            
        For i = 1 To Player_HighIndex
            If GetPlayerMap(i) = 297 Then
                If attacker <> i Then
                    TempPlayer(i).GanhouEXP = YES
                    GivePlayerEXP i, EXP / 2
                End If
            End If
        Next
    End If
            'Drop the goods if they get it
            'n = FindOpenInvSlot(Attacker, Npc(NpcNum).DropItem)
    
                        ' Open slot available?
        If Player(attacker).VipData.VIP > 0 Then
            If (Int(Rnd * Npc(NpcNum).DropChance) + 1) = 1 Then
                'If n <> 0 Then
                        GiveItem attacker, Npc(NpcNum).DropItem, Npc(NpcNum).DropItemValue
                'Else
                    'PlayerMsg Attacker, "Sem espaço na mochila", BrightRed
                'nd If
            End If
        Else
        
            n = Int(Rnd * Npc(NpcNum).DropChance) + 1
        
                If n = 1 Then
                    Call SpawnItem(Npc(NpcNum).DropItem, Npc(NpcNum).DropItemValue, mapNum, MapNpc(mapNum).Npc(mapNpcNum).X, MapNpc(mapNum).Npc(mapNpcNum).Y)
                End If
            'End If
        End If

        If Npc(NpcNum).Behaviour = NPC_BEHAVIOUR_BOSS Then
            GlobalMsg GetPlayerName(attacker) & " derrotou: " & Trim$(Npc(NpcNum).Name), White
            If mapNum >= 235 And mapNum <= 238 Or mapNum = 297 Then
                For n = 1 To Player_HighIndex
                    If GetPlayerMap(n) = mapNum Then
                        Atendimento n
                    End If
                Next
            End If
        End If
        
        If NpcNum = 115 Then 'otsutsuki
            If Torneio = TORNEIO_LENDARIO Then
                If TorneioData.pTotal > 1 Then 'quer dizer que vai ter luta por ter mais de 1
                    For i = 1 To Player_HighIndex
                        If TorneioData.Participante(i) > 0 Then
                            PlayerWarp TorneioData.Participante(i), 100, RAND(2, 29), RAND(2, 24)
                            TempPlayer(TorneioData.Participante(i)).Contagem = 6
                            RecuperarAposLuta TorneioData.Participante(i)
                        End If
                    Next
                    MapMsg 100, "Quem ganhar será o novo LENDÁRIO!", Yellow
                Else
                    If TorneioData.pTotal = 1 Then
                        For i = 1 To Player_HighIndex
                            If IsPlaying(TorneioData.Participante(i)) = True Then
                                AtualizarLendario TorneioData.Participante(i)
                                GlobalMsg "Evento finalizado!", Green
                                Torneio = NO
                                frmServer.lstTorneios.ListIndex = NO
                                frmServer.chkTorneioStatus.Value = NO
                                ZerarLutas
                                ZerarTorneioData
                                SegundosLuta = NO
                                Exit For
                            End If
                        Next
                    Else '0= ninguem
                        GlobalMsg "Ninguem no torneio. Finalizado.", Green
                        Torneio = NO
                        frmServer.lstTorneios.ListIndex = NO
                        frmServer.chkTorneioStatus.Value = NO
                        ZerarLutas
                        ZerarTorneioData
                        SegundosLuta = NO
                    End If
                End If
            End If
        End If
        
        For i = 1 To 10
           If Player(attacker).QuestNum(i) > 0 Then
              If Quest(Player(attacker).QuestNum(i)).tipo = QUEST_TYPE_NPC Then
                 CheckQuestNPC attacker, NpcNum, i
              End If
           End If
        Next

        ' Now set HP to 0 so we know to actually kill them in the server loop (this prevents subscript out of range)
        MapNpc(mapNum).Npc(mapNpcNum).num = 0
        MapNpc(mapNum).Npc(mapNpcNum).SpawnWait = GetTickCount
        MapNpc(mapNum).Npc(mapNpcNum).Vital(Vitals.HP) = 0
        
        'TORNEIO_DESAFIOS
        If GetPlayerMap(attacker) >= 230 And GetPlayerMap(attacker) <= 234 Then 'ta no desafio
            TempPlayer(attacker).npcsMortos = TempPlayer(attacker).npcsMortos + 1
            AtualizarEvento
        End If
        
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
        SendBlood GetPlayerMap(attacker), MapNpc(mapNum).Npc(mapNpcNum).X, MapNpc(mapNum).Npc(mapNpcNum).Y
        
        ' send the sound
        If SpellNum > 0 Then
            SendMapSound attacker, MapNpc(mapNum).Npc(mapNpcNum).X, MapNpc(mapNum).Npc(mapNpcNum).Y, SoundEntity.seSpell, SpellNum
        Else
            SendAnimation GetPlayerMap(attacker), 28, 0, 0, TARGET_TYPE_NPC, mapNpcNum
        End If
        
        ' send animation
        If n > 0 Then
            If Not overTime Then
                If SpellNum = 0 Then Call SendAnimation(mapNum, Item(GetPlayerEquipment(attacker, Weapon)).Animation, 0, 0, TARGET_TYPE_NPC, mapNpcNum)
            End If
        End If

        ' Set the NPC target to the player
        MapNpc(mapNum).Npc(mapNpcNum).targetType = 1 ' player
        MapNpc(mapNum).Npc(mapNpcNum).Target = attacker

        ' Now check for guard ai and if so have all onmap guards come after'm
        If Npc(MapNpc(mapNum).Npc(mapNpcNum).num).Behaviour = NPC_BEHAVIOUR_GUARD Then
            For i = 1 To MAX_MAP_NPCS
                If MapNpc(mapNum).Npc(i).num = MapNpc(mapNum).Npc(mapNpcNum).num Then
                    MapNpc(mapNum).Npc(i).Target = attacker
                    MapNpc(mapNum).Npc(i).targetType = 1 ' player
                End If
            Next
        End If
        
        If Npc(MapNpc(mapNum).Npc(mapNpcNum).num).Behaviour = NPC_BEHAVIOUR_BOSS Then
            For i = 1 To MAX_MAP_NPCS
                If MapNpc(mapNum).Npc(i).num > 0 Then
                    If Npc(MapNpc(mapNum).Npc(i).num).Behaviour = NPC_BEHAVIOUR_ATTACKONSIGHT Or Npc(MapNpc(mapNum).Npc(i).num).Behaviour = NPC_BEHAVIOUR_SUBORDINADO Then
                        MapNpc(mapNum).Npc(i).Target = attacker
                        MapNpc(mapNum).Npc(i).targetType = TARGET_TYPE_PLAYER ' player
                    End If
                End If
            Next
        End If
        ' set the regen timer
        MapNpc(mapNum).Npc(mapNpcNum).stopRegen = True
        MapNpc(mapNum).Npc(mapNpcNum).stopRegenTimer = GetTickCount
        
        ' if stunning spell, stun the npc
        If SpellNum > 0 Then
            If Spell(SpellNum).StunDuration > 0 Then StunNPC mapNpcNum, mapNum, SpellNum, attacker
            ' DoT
            If Spell(SpellNum).Duration > 0 Then
                AddDoT_Npc mapNum, mapNpcNum, SpellNum, attacker
            End If
        End If
        
        If GetPlayerEquipment(attacker, Weapon) > 0 Then
            If Item(GetPlayerEquipment(attacker, Weapon)).StunDuration > 0 Then
                MapNpc(mapNum).Npc(mapNpcNum).StunDuration = Item(GetPlayerEquipment(attacker, Weapon)).StunDuration
                MapNpc(mapNum).Npc(mapNpcNum).StunTimer = GetTickCount
            End If
        End If
        
        SendMapNpcVitals mapNum, mapNpcNum
    End If

    If SpellNum = 0 Then
        ' Reset attack timer
        TempPlayer(attacker).AttackTimer = GetTickCount
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
    
    If GetPlayerAccess(index) > 1 Then Exit Function 'gm
    If Player(index).Spec = YES Then Exit Function
    If Player(index).Invisivel = YES Then Exit Function
    
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

Sub NpcAttackPlayer(ByVal mapNpcNum As Long, ByVal victim As Long, ByVal Damage As Long)
    Dim Name As String
    Dim EXP As Long
    Dim mapNum As Long
    Dim i As Long
    Dim Buffer As clsBuffer

    ' Check for subscript out of range
    If mapNpcNum <= 0 Or mapNpcNum > MAX_MAP_NPCS Or IsPlaying(victim) = False Then
        Exit Sub
    End If

    ' Check for subscript out of range
    If MapNpc(GetPlayerMap(victim)).Npc(mapNpcNum).num <= 0 Then
        Exit Sub
    End If
    
    If TempPlayer(victim).NoDamage > 0 Then Exit Sub
    
    If TempPlayer(victim).Kawarimi > 0 Then
        Select Case GetPlayerClass(victim)
            Case MADARA, ITACHI
                SendAnimation GetPlayerMap(victim), 81, GetPlayerX(victim), GetPlayerY(victim), TARGET_TYPE_PLAYER, victim
            Case YONDAIME
                SendAnimation GetPlayerMap(victim), 70, GetPlayerX(victim), GetPlayerY(victim), TARGET_TYPE_PLAYER, victim
            Case Else
                SendAnimation GetPlayerMap(victim), 1, GetPlayerX(victim), GetPlayerY(victim)
        End Select
        
        TempPlayer(victim).NoDamage = GetTickCount + 800
        TempPlayer(victim).Kawarimi = 0
        WarpBehind_Npc victim, mapNpcNum
       Exit Sub
    End If
     
    mapNum = GetPlayerMap(victim)
    Name = Trim$(Npc(MapNpc(mapNum).Npc(mapNpcNum).num).Name)
    
    ' Send this packet so they can see the npc attacking
    Set Buffer = New clsBuffer
    Buffer.WriteLong SNpcAttack
    Buffer.WriteLong mapNpcNum
    SendDataToMap mapNum, Buffer.ToArray()
    Set Buffer = Nothing
    
    If GetPlayerClass(victim) = GAARA Then
        Damage = Damage / 1.3
        SendAnimation mapNum, 59, 0, 0, TARGET_TYPE_PLAYER, victim
    End If
    
    If GetPlayerClass(victim) = KIMIMARU Then
        Damage = Damage / 1.3
    End If
    
    If TempPlayer(victim).Reflect > 0 Then
        Select Case GetPlayerClass(victim)
            
            Case SASUKE
                Select Case GetPlayerLevel(victim)
                    Case 0 To 500
                        Damage = Damage / 1.1
                    Case 501 To 749
                        Damage = Damage / 1.3
                    Case 750 To MAX_INTEGER
                        Damage = Damage / 1.4
                    Case Else
                End Select
            Case ITACHI, MADARA, BEE, RAIKAGE, YUGITO
                Damage = Damage / 1.5
            Case PAIN, DANZOU
                Damage = 0
            Case HIDAN
                Damage = 0
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

    If Damage >= GetPlayerVital(victim, Vitals.HP) Then
        ' Say damage
        SendActionMsg GetPlayerMap(victim), "-" & GetPlayerVital(victim, Vitals.HP), BrightRed, 1, (GetPlayerX(victim) * 32), (GetPlayerY(victim) * 32)
        
        ' send the sound
        SendMapSound victim, GetPlayerX(victim), GetPlayerY(victim), SoundEntity.seNpc, MapNpc(mapNum).Npc(mapNpcNum).num
        
        ' kill player
        KillPlayer victim
        
        ' Player is dead
        If Not MapNpc(mapNum).Npc(mapNpcNum).IsPet = YES Then
            If Lutando(victim) = NO Then
                Call GlobalMsg(GetPlayerName(victim) & " foi derrotado por " & Name, BrightRed)
            Else
                MapMsg GetPlayerMap(victim), GetPlayerName(victim) & " foi derrotado por " & Name, Grey
            End If
        Else
            If MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner > 0 Then
                If IsPlaying(MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner) Then
                    GlobalMsg GetPlayerName(victim) & " foi derrotado por " & GetPlayerName(MapNpc(mapNum).Npc(mapNpcNum).PetData.Owner), BrightRed
                End If
            End If
        End If
        
        ' Set NPC target to 0
        MapNpc(mapNum).Npc(mapNpcNum).Target = 0
        MapNpc(mapNum).Npc(mapNpcNum).targetType = 0
    Else
        ' Player not dead, just do the damage
        Call SetPlayerVital(victim, Vitals.HP, GetPlayerVital(victim, Vitals.HP) - Damage)
        Call SendVital(victim, Vitals.HP)
        Call SendAnimation(mapNum, Npc(MapNpc(GetPlayerMap(victim)).Npc(mapNpcNum).num).Animation, 0, 0, TARGET_TYPE_PLAYER, victim)
        
        ' send vitals to party if in one
        If TempPlayer(victim).inParty > 0 Then SendPartyVitals TempPlayer(victim).inParty, victim
        
        ' send the sound
        SendMapSound victim, GetPlayerX(victim), GetPlayerY(victim), SoundEntity.seNpc, MapNpc(mapNum).Npc(mapNpcNum).num
        
        ' Say damage
        SendActionMsg GetPlayerMap(victim), "-" & Damage, BrightRed, 1, (GetPlayerX(victim) * 32), (GetPlayerY(victim) * 32)
        SendBlood GetPlayerMap(victim), GetPlayerX(victim), GetPlayerY(victim)
        
        ' set the regen timer
        TempPlayer(victim).stopRegen = True
        TempPlayer(victim).stopRegenTimer = GetTickCount
    End If

End Sub

' ###################################
' ##    Player Attacking Player    ##
' ###################################

Public Sub TryPlayerAttackPlayer(ByVal attacker As Long, ByVal victim As Long)
Dim blockAmount As Long
Dim NpcNum As Long
Dim mapNum As Long
Dim Damage As Long
Dim weaponNum As Long
Dim tmpChakra As Long

    Damage = 0

    ' Can we attack the npc?
    If CanPlayerAttackPlayer(attacker, victim) Then
    
        mapNum = GetPlayerMap(attacker)
    
        ' check if NPC can avoid the attack
        If CanPlayerDodge(victim) Then
            SendActionMsg mapNum, "Esquivou!", Magenta, 1, (GetPlayerX(victim) * 32), (GetPlayerY(victim) * 32)
            Exit Sub
        End If
        If CanPlayerParry(victim) Then
            SendActionMsg mapNum, "Defendeu!", Green, 1, (GetPlayerX(victim) * 32), (GetPlayerY(victim) * 32)
            Exit Sub
        End If
        
        weaponNum = GetPlayerEquipment(attacker, Equipment.Weapon)
        
        ' Get the damage we can do
        If weaponNum = 108 Then 'lendaria nin
            Damage = GetPlayerDamage(attacker, True)
            Damage = Damage / 5
        Else
            Damage = GetPlayerDamage(attacker, False)
            If weaponNum = 107 Then
                Damage = Damage / 5
            End If
        End If
        
        ' if the npc blocks, take away the block amount
        blockAmount = CanPlayerBlock(victim)
        Damage = Damage - blockAmount
        
        ' take away armour
        Damage = Damage - RAND(1, (GetPlayerStat(victim, Agility) * 2))
        
        ' randomise for up to 10% lower than max hit
        Damage = RAND(1, Damage)
        
        ' * 1.5 if can crit
        If CanPlayerCrit(attacker) Then
            Damage = Damage * 1.5
            SendActionMsg mapNum, "Crítico!", BrightCyan, 1, (GetPlayerX(attacker) * 32), (GetPlayerY(attacker) * 32)
        End If

        If Damage > 0 Then
            If Not TempPlayer(attacker).Target = victim Then
                TempPlayer(attacker).Target = victim
                TempPlayer(attacker).targetType = TARGET_TYPE_PLAYER
                SendTarget attacker
             End If
            
            ' Check for weapon
            If GetPlayerEquipment(attacker, Weapon) > 0 Then
                tmpChakra = (GetPlayerMaxVital(victim, Vitals.mp) / 100) * 5
                
                Select Case weaponNum
                    Case 18
                        If GetPlayerVital(victim, Vitals.mp) > tmpChakra Then
                            SetPlayerVital victim, Vitals.mp, GetPlayerVital(victim, Vitals.mp) - tmpChakra
                            SendVital victim, Vitals.mp
                            SetPlayerVital attacker, Vitals.mp, GetPlayerVital(attacker, Vitals.mp) + tmpChakra
                            SendVital attacker, Vitals.mp
                        End If
                    Case Else
                End Select
            End If
            
            Call PlayerAttackPlayer(attacker, victim, Damage)
            CheckHits attacker, victim
            
        Else
            Call PlayerMsg(attacker, "Seu ataque é ridículo!", BrightRed)
        End If
    End If
End Sub

Function CanPlayerAttackPlayer(ByVal attacker As Long, ByVal victim As Long, Optional ByVal IsSpell As Boolean = False, Optional ByVal IsProjectile As Boolean = False) As Boolean
If attacker < 1 Or attacker > MAX_PLAYERS Then Exit Function
If victim < 1 Or victim > MAX_PLAYERS Then Exit Function
If victim = attacker Then Exit Function

    If Not IsSpell And Not IsProjectile Then
        ' Check attack timer
        If GetPlayerEquipment(attacker, Weapon) > 0 Then
            If GetTickCount < TempPlayer(attacker).AttackTimer + Item(GetPlayerEquipment(attacker, Weapon)).Speed Then Exit Function
        Else
            If GetTickCount < TempPlayer(attacker).AttackTimer + 1000 Then Exit Function
        End If
    End If

    ' Check for subscript out of range
    If Not IsPlaying(victim) Then Exit Function

    ' Make sure they are on the same map
    If Not GetPlayerMap(attacker) = GetPlayerMap(victim) Then Exit Function

    ' Make sure we dont attack the player if they are switching maps
    If TempPlayer(victim).GettingMap = YES Then Exit Function
    
    If Player(attacker).Invisivel = YES Then Exit Function
    If Player(attacker).Spec = YES Then Exit Function
    If Player(victim).Spec = YES Then Exit Function
    If Player(victim).Invisivel = YES Then Exit Function
    If Trim$(TempPlayer(attacker).KilledName) = GetPlayerName(victim) Then
        If TempPlayer(attacker).KilledCount >= 3 Then
            PlayerMsg attacker, "Você já derrotou muitas vezes este player!", Grey
            Exit Function
        End If
    End If
    
    If Not IsSpell And Not IsProjectile Then
        ' Check if at same coordinates
        Select Case GetPlayerDir(attacker)
            Case DIR_UP
    
                If Not ((GetPlayerY(victim) + 1 = GetPlayerY(attacker)) And (GetPlayerX(victim) = GetPlayerX(attacker))) Then Exit Function
            Case DIR_DOWN
    
                If Not ((GetPlayerY(victim) - 1 = GetPlayerY(attacker)) And (GetPlayerX(victim) = GetPlayerX(attacker))) Then Exit Function
            Case DIR_LEFT
    
                If Not ((GetPlayerY(victim) = GetPlayerY(attacker)) And (GetPlayerX(victim) + 1 = GetPlayerX(attacker))) Then Exit Function
            Case DIR_RIGHT
    
                If Not ((GetPlayerY(victim) = GetPlayerY(attacker)) And (GetPlayerX(victim) - 1 = GetPlayerX(attacker))) Then Exit Function
            Case Else
                Exit Function
        End Select
    End If
    
    If Player(attacker).PKstate = 0 Then
        PlayerMsg attacker, "Ligue o PK se quiser atacar um Player(Aperte INSERT)", BrightRed
        Exit Function
    End If
    
    If GetPlayerIP(attacker) = GetPlayerIP(victim) And Not GetPlayerAccess(attacker) = ADMIN_CREATOR Then
        If frmServer.chkIpKill.Value = NO Then
            'PlayerMsg Attacker, "Não pode atacar você mesmo,safado ;] ", BrightRed
            Exit Function
        End If
    End If
    
    '####desafioanything
    If TempPlayer(attacker).InArena > 0 Then
        If ParceiroDesafio(attacker, victim) = YES Then Exit Function
    End If
    
    If TempPlayer(attacker).berserkerMode = YES And TempPlayer(victim).berserkerMode = YES Then
        If CanBerserkerAttack(GetPlayerMap(attacker)) = False Then Exit Function
    Else
        If Lutando(attacker) = NO And Lutando(victim) = NO Then 'Soh vai ter essa regra se nao tiver nenhum torneio ativo
            If GetPlayerLevel(victim) <= 700 Then
                If GetPlayerLevel(victim) + 200 < GetPlayerLevel(attacker) Then
                    'PlayerMsg Attacker, "Ele não têm muita chance com você..", BrightRed
                    Exit Function
                End If
            End If
            
            If GetPlayerLevel(attacker) <= 700 Then
                If GetPlayerLevel(attacker) + 200 < GetPlayerLevel(victim) Then
                    'PlayerMsg Attacker, "Pense 2 vezes :D..", BrightRed
                    Exit Function
                End If
            End If
        
            If frmServer.chkFogoAmigo.Value = NO Then
                If TempPlayer(attacker).inParty > 0 Then
                    If TempPlayer(attacker).inParty = TempPlayer(victim).inParty Then
                        If Not Player(attacker).PKstate >= 2 Then
                            Exit Function
                        End If
                    End If
                End If
        
                If Player(attacker).Org > 0 Then
                    If Player(attacker).Org = Player(victim).Org Then
                        If Not Player(attacker).PKstate >= 2 Then
                            'PlayerMsg Attacker, "Vocês são da Mesma organização!", BrightRed
                            Exit Function
                        End If
                    End If
                End If
            End If
        End If
        
        ' Check if map is attackable
        If Not Map(GetPlayerMap(attacker)).Moral = MAP_MORAL_NONE Then
            Exit Function
        End If
    End If

    ' Make sure they have more then 0 hp
    If GetPlayerVital(victim, Vitals.HP) <= 0 Then Exit Function

    ' Check to make sure that they dont have access
    If GetPlayerAccess(attacker) > 1 And Not GetPlayerAccess(attacker) = ADMIN_CREATOR Then
        If GetPlayerAccess(victim) = 1 Or GetPlayerAccess(victim) > GetPlayerAccess(attacker) Then 'player
            Call PlayerMsg(attacker, "ADM's não podem atacar", BrightBlue)
            Exit Function
        End If
    End If

    ' Check to make sure the victim isn't an admin
    If GetPlayerAccess(attacker) < GetPlayerAccess(victim) Then
        Call PlayerMsg(attacker, "Não pode atacar ADM!", BrightRed)
        Exit Function
    End If

    ' Make sure attacker is high enough level
    If GetPlayerLevel(attacker) < 100 Then
        Call PlayerMsg(attacker, "Você é level menor que 100,não pode atacar ninguém ainda!", BrightRed)
        Exit Function
    End If

    ' Make sure victim is high enough level
    If GetPlayerLevel(victim) < 100 Then
        Call PlayerMsg(attacker, GetPlayerName(victim) & " é level menor que 100, você não pode atacá-lo ainda!", BrightRed)
        Exit Function
    End If
    
    If Player(attacker).War > 0 And Player(victim).War > 0 Then
        If Player(attacker).War = Player(victim).War Then
            Exit Function
        End If
    End If
        
    If TempPlayer(victim).Kawarimi > 0 Then
       Select Case GetPlayerClass(victim)
            Case MADARA, ITACHI
                SendAnimation GetPlayerMap(victim), 81, GetPlayerX(victim), GetPlayerY(victim)
            Case YONDAIME
                SendAnimation GetPlayerMap(victim), 70, GetPlayerX(victim), GetPlayerY(victim)
            Case Else
                SendAnimation GetPlayerMap(victim), 1, GetPlayerX(victim), GetPlayerY(victim)
        End Select
        
        TempPlayer(victim).NoDamage = GetTickCount + 800
        TempPlayer(victim).Kawarimi = 0
        WarpBehind_Player victim, attacker
       Exit Function
    End If

    CanPlayerAttackPlayer = True
End Function

Sub PlayerAttackPlayer(ByVal attacker As Long, ByVal victim As Long, ByVal Damage As Long, Optional ByVal SpellNum As Long = 0)
    Dim EXP As Long
    Dim n As Long
    Dim i As Long
    Dim Buffer As clsBuffer
    Dim tmpChakra As Long
    
    ' Check for subscript out of range
    If IsPlaying(attacker) = False Or IsPlaying(victim) = False Or Damage < 0 Then
        Exit Sub
    End If
    
    If TempPlayer(victim).NoDamage > 0 Then Exit Sub
    
    ' set the regen timer
    TempPlayer(attacker).stopRegen = True
    TempPlayer(attacker).stopRegenTimer = GetTickCount

    Damage = Damage - GetPlayerProtection(victim)
    
    If GetPlayerClass(victim) = GAARA Then
        Damage = Damage / 1.3
        SendAnimation GetPlayerMap(victim), 59, 0, 0, TARGET_TYPE_PLAYER, victim
    End If
    
    If GetPlayerClass(victim) = KIMIMARU Then
        Damage = Damage / 1.3
    End If
    
    If TempPlayer(victim).Reflect > 0 Then
        Select Case GetPlayerClass(victim)
            
            Case SASUKE
                Select Case GetPlayerLevel(victim)
                    Case 0 To 500
                        Damage = Damage / 1.1
                    Case 501 To 749
                        Damage = Damage / 1.1
                    Case 750 To MAX_INTEGER
                        Damage = Damage / 1.1
                    Case Else
                End Select
            Case ITACHI, MADARA, BEE, RAIKAGE, YUGITO
                Damage = Damage / 1.2
            Case PAIN, DANZOU
                Damage = 0
            Case HIDAN
                If GetPlayerClass(attacker) <> HIDAN Then
                    PlayerAttackPlayer victim, attacker, Damage, 1
                End If
                
                Damage = 0
            Case INO
                Damage = Damage / 1.5
            Case Else
        End Select
    End If
    
    If GetPlayerMap(attacker) = 299 And GetPlayerMap(victim) = 299 Then
        Damage = Damage / 3
    End If
    
    If Damage >= GetPlayerVital(victim, Vitals.HP) Then
        
        SendActionMsg GetPlayerMap(victim), "-" & GetPlayerVital(victim, Vitals.HP), BrightRed, 1, (GetPlayerX(victim) * 32), (GetPlayerY(victim) * 32)
        
        ' send the sound
        If SpellNum > 0 Then SendMapSound victim, GetPlayerX(victim), GetPlayerY(victim), SoundEntity.seSpell, SpellNum
        
        ' Player is dead
        
        If Player(attacker).InTorneio > 0 And Player(victim).InTorneio > 0 Then
            If Player(attacker).War > 0 And Player(victim).War > 0 Then
                Player(attacker).WarPoints = Player(attacker).WarPoints + 1
                War.Pts(Player(attacker).War) = War.Pts(Player(attacker).War) + 1
                If War.Killer(Player(attacker).War) > 0 Then
                    If Player(attacker).WarPoints > Player(War.Killer(Player(attacker).War)).WarPoints Then
                        War.Killer(Player(attacker).War) = attacker
                    End If
                Else
                    War.Killer(Player(attacker).War) = attacker
                End If
            End If
        End If
        
        If TempPlayer(victim).StunDuration > 0 Then
            TempPlayer(victim).StunDuration = NO
            TempPlayer(victim).StunTimer = NO
            SendStunned victim
            PlayerMsg victim, "Você foi liberado da paralização.", Blue
        End If
    
        If Lutando(attacker) = NO Then 'Conta
            If Trim$(TempPlayer(attacker).KilledName) = GetPlayerName(victim) Then
                TempPlayer(attacker).KilledCount = TempPlayer(attacker).KilledCount + 1
            Else
                TempPlayer(attacker).KilledCount = 1
                TempPlayer(attacker).KilledName = GetPlayerName(victim)
            End If
            
            Call GlobalMsg(GetPlayerName(victim) & " foi derrotado por " & GetPlayerName(attacker), BrightRed)
            CheckQuestKillPlayer attacker, victim
            
            If IsVictimOverKilled(victim) = False Then
                setKarma attacker, victim
            End If
        Else
            MapMsg GetPlayerMap(attacker), GetPlayerName(victim) & " foi derrotado por " & GetPlayerName(attacker), Grey
        End If
        
        ' purge target info of anyone who targetted dead guy
        For i = 1 To Player_HighIndex
            If IsPlaying(i) And IsConnected(i) Then
                If Player(i).Map = GetPlayerMap(attacker) Then
                    If TempPlayer(i).Target = TARGET_TYPE_PLAYER Then
                        If TempPlayer(i).Target = victim Then
                            TempPlayer(i).Target = 0
                            TempPlayer(i).targetType = TARGET_TYPE_NONE
                            SendTarget i
                        End If
                    End If
                End If
            End If
        Next
        
        OnDeath victim
    Else
        ' Player not dead, just do the damage
        Call SetPlayerVital(victim, Vitals.HP, GetPlayerVital(victim, Vitals.HP) - Damage)
        Call SendVital(victim, Vitals.HP)
        
        ' send vitals to party if in one
        If TempPlayer(victim).inParty > 0 Then SendPartyVitals TempPlayer(victim).inParty, victim
        
        ' send the sound
        If SpellNum > 0 Then SendMapSound victim, GetPlayerX(victim), GetPlayerY(victim), SoundEntity.seSpell, SpellNum
        
        SendActionMsg GetPlayerMap(victim), "-" & Damage, BrightRed, 1, (GetPlayerX(victim) * 32), (GetPlayerY(victim) * 32)
        SendBlood GetPlayerMap(victim), GetPlayerX(victim), GetPlayerY(victim)
        
        ' set the regen timer
        TempPlayer(victim).stopRegen = True
        TempPlayer(victim).stopRegenTimer = GetTickCount
        
        'if a stunning spell, stun the player
        If SpellNum > 0 Then
            If Spell(SpellNum).StunDuration > 0 Then StunPlayer victim, SpellNum, attacker
            ' DoT
            If Spell(SpellNum).Duration > 0 Then
                AddDoT_Player victim, SpellNum, attacker
            End If
        Else
            SendAnimation GetPlayerMap(victim), 28, 0, 0, TARGET_TYPE_PLAYER, victim
        End If
        
        If GetPlayerEquipment(attacker, Weapon) > 0 Then
           If Item(GetPlayerEquipment(attacker, Weapon)).StunDuration > 0 Then
                TempPlayer(victim).StunDuration = Item(GetPlayerEquipment(attacker, Weapon)).StunDuration
                TempPlayer(victim).StunTimer = GetTickCount
                SendStunned victim
                ' tell him he's stunned
                PlayerMsg victim, "Você está paralizado.", BrightRed
            End If
        End If
    End If
    
    TempPlayer(victim).playerAttackerOrVictim = GetTickCount + 10000
    TempPlayer(attacker).playerAttackerOrVictim = GetTickCount + 10000
    ' Reset attack timer
    TempPlayer(attacker).AttackTimer = GetTickCount
End Sub

' ############
' ## Spells ##
' ############

Public Sub BufferSpell(ByVal index As Long, ByVal spellslot As Long)
    If Player(index).Spec = YES Then
        PlayerMsg index, "Você está em modo Espectador. Desative usando-o denovo!", Red
        Exit Sub
    End If
    
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
    If TempPlayer(index).SpellCD(spellslot) > GetTickCount Then
        'PlayerMsg index, "Spell hasn't cooled down yet!", BrightRed
        Exit Sub
    End If
    
    If GetPlayerMap(index) = 293 Then 'npc pinhata
        PlayerMsg index, "Só chute aqui!", BrightRed
        Exit Sub
    End If
    
    MPCost = Spell(SpellNum).MPCost
    If GetPlayerMap(index) >= 260 And GetPlayerMap(index) <= 279 Then
        MPCost = 0
    End If
    
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

Public Sub CastSpell(ByVal index As Long, ByVal spellslot As Long, ByVal Target As Long, ByVal targetType As Byte, Optional ByVal SharinganCopy As Byte)
    If Player(index).Spec = YES Then
        PlayerMsg index, "Você está em modo Espectador. Desative usando-o denovo!", Red
        Exit Sub
    End If
    
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
    If SharinganCopy = NO Then
        If spellslot <= 0 Or spellslot > MAX_PLAYER_SPELLS Then Exit Sub
    End If
    
    If SharinganCopy = NO Then
        SpellNum = GetPlayerSpell(index, spellslot)
    Else
        If TempPlayer(index).tmpSpell < 1 Or TempPlayer(index).tmpSpell > MAX_SPELLS Then Exit Sub
        
        SpellNum = TempPlayer(index).tmpSpell
    End If
    
    'limpando o jutsu sharingan copy
    TempPlayer(index).tmpSpell = NO
    
    mapNum = GetPlayerMap(index)
    
    If SharinganCopy = NO Then
        ' Make sure player has the spell
        If Not HasSpell(index, SpellNum) Then Exit Sub
    End If

    If GetPlayerMap(index) = 293 Then 'npc pinhata
        PlayerMsg index, "Só chute aqui!", BrightRed
        Exit Sub
    End If
    
    MPCost = Spell(SpellNum).MPCost
    If GetPlayerMap(index) >= 260 And GetPlayerMap(index) <= 279 Then
        MPCost = 0
    End If
    
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
    
    If SharinganCopy = NO Then
    
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
                    SendMapSound index, GetPlayerX(index), GetPlayerY(index), SoundEntity.seSpell, SpellNum
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
                                            If SharinganCopy = NO Then
                                                SendAnimation mapNum, Spell(SpellNum).SpellAnim, 0, 0, TARGET_TYPE_PLAYER, i
                                                PlayerAttackPlayer index, i, Vital / 2, SpellNum
                                                If Not TempPlayer(index).Target = i Then
                                                    TempPlayer(index).Target = i
                                                    TempPlayer(index).targetType = TARGET_TYPE_PLAYER
                                                    SendTarget index
                                                End If
                                            Else
                                                TempPlayer(TempPlayer(index).Target).tmpSpell = SpellNum
                                                CastSpell TempPlayer(index).Target, 1, index, TARGET_TYPE_PLAYER, YES
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
                            If SharinganCopy = NO Then
                                If Vital > 0 Then
                                    SendAnimation mapNum, Spell(SpellNum).SpellAnim, 0, 0, TARGET_TYPE_PLAYER, Target
                                    PlayerAttackPlayer index, Target, Vital / 2, SpellNum
                                    DidCast = True
                                End If
                            Else
                                TempPlayer(TempPlayer(index).Target).tmpSpell = SpellNum
                                CastSpell TempPlayer(index).Target, 1, index, TARGET_TYPE_PLAYER, YES
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
                    If GetSpellBaseStat(.Caster, .Spell) / 2.5 > 1 Then
                        PlayerAttackPlayer .Caster, index, RAND(1, GetSpellBaseStat(.Caster, .Spell) / 2.5)
                    End If
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
                    If GetSpellBaseStat(.Caster, .Spell) / 2.5 > 1 Then
                        PlayerAttackNpc .Caster, index, RAND(1, GetSpellBaseStat(.Caster, .Spell) / 2.5), , True
                    End If
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

Public Sub StunPlayer(ByVal index As Integer, ByVal SpellNum As Integer, ByVal attacker As Integer)

If TempPlayer(index).StunDuration > 0 Then Exit Sub

Dim Gen As Long
Dim GenAtk As Long
Dim Duration As Long

Gen = GetPlayerStat(index, Stats.Willpower) * 5
GenAtk = GetPlayerStat(attacker, Stats.Willpower) * 5

    ' check if it's a stunning spell
    If Spell(SpellNum).StunDuration > 0 Then
        Duration = Spell(SpellNum).StunDuration * 1000
        'Duration = Duration + GenAtk - Gen
        
        If Duration > 3000 Then
            Duration = 3000
        End If
        
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

Public Sub StunNPC(ByVal index As Long, ByVal mapNum As Long, ByVal SpellNum As Long, ByVal attacker As Long)
Dim Duracao As Long

If MapNpc(mapNum).Npc(index).StunDuration > 0 Then Exit Sub

Dim Gen As Long
Gen = GetPlayerStat(attacker, Stats.Willpower) * 2
Duracao = Spell(SpellNum).StunDuration * 1000

If Duracao > 10000 Then
    Duracao = 10000
End If

    ' check if it's a stunning spell
    If Spell(SpellNum).StunDuration > 0 Then
        ' set the values on index
        MapNpc(mapNum).Npc(index).StunDuration = Duracao
        MapNpc(mapNum).Npc(index).StunTimer = GetTickCount
    End If
End Sub

'makes the pet follow its owner
Sub PetFollowOwner(ByVal index As Long)
    If index < 1 Or index > MAX_PLAYERS Then Exit Sub
    If TempPlayer(index).TempPetSlot < 1 Or TempPlayer(index).TempPetSlot > MAX_MAP_NPCS Then Exit Sub
    
    MapNpc(GetPlayerMap(index)).Npc(TempPlayer(index).TempPetSlot).targetType = 1
    MapNpc(GetPlayerMap(index)).Npc(TempPlayer(index).TempPetSlot).Target = index
End Sub

'makes the pet wander around the map
Sub PetWander(ByVal index As Long)
    If index < 1 Or index > MAX_PLAYERS Then Exit Sub
    If TempPlayer(index).TempPetSlot < 1 Or TempPlayer(index).TempPetSlot > MAX_MAP_NPCS Then Exit Sub
    
    MapNpc(GetPlayerMap(index)).Npc(TempPlayer(index).TempPetSlot).targetType = TARGET_TYPE_NONE
    MapNpc(GetPlayerMap(index)).Npc(TempPlayer(index).TempPetSlot).Target = 0
End Sub

'Clear the npc from the map
Sub PetDisband(ByVal index As Long, ByVal mapNum As Long)
Dim i As Long
    
    If index < 1 Or index > MAX_PLAYERS Then Exit Sub
    If TempPlayer(index).TempPetSlot < 1 Or TempPlayer(index).TempPetSlot > MAX_MAP_NPCS Then Exit Sub
    If mapNum < 1 Or mapNum > MAX_MAPS Then Exit Sub
    
    Call ClearSingleMapNpc(TempPlayer(index).TempPetSlot, mapNum)
    Map(mapNum).Npc(TempPlayer(index).TempPetSlot) = 0
    TempPlayer(index).TempPetSlot = 0
    
    Call SendMapNpcsToMap(mapNum)
    
End Sub

Sub SpawnPet(ByVal index As Long, ByVal mapNum As Long, ByVal NpcNum As Long)
    Dim PlayerMap As Long
    Dim i As Integer
    Dim PetSlot As Byte
    
    If index < 1 Or index > MAX_PLAYERS Then Exit Sub
    'Prevent multiple pets for the same owner
    If TempPlayer(index).TempPetSlot > 0 Then Exit Sub
    
    PlayerMap = GetPlayerMap(index)
    PetSlot = 0
    
    If Map(GetPlayerMap(index)).Moral = MAP_MORAL_SAFE Then
        PlayerMsg index, "Não pode invocar em Zona Segura!", BrightRed
        Exit Sub
    End If
    
    If GetPlayerMap(index) = 299 Then
        PlayerMsg index, "Ops,não da pra usar aqui", BrightRed
        Exit Sub
    End If
    
    If GetPlayerMap(index) = 100 Then
        PlayerMsg index, "Ops,não da pra usar aqui", BrightRed
        Exit Sub
    End If
    
    For i = 1 To MAX_MAP_NPCS
        If MapNpc(PlayerMap).Npc(i).SpawnWait = 0 And MapNpc(PlayerMap).Npc(i).num = 0 Then
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
    'For i = 1 To Player_HighIndex
        'If IsPlaying(i) Then
            'If GetPlayerMap(i) = GetPlayerMap(index) Then
                'SendMap i, PlayerMap
            'End If
        'End If
    'Next

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
    
    SendMapNpcsToMap PlayerMap
    'SendPlayerXY index
    
    
    For i = 1 To Player_HighIndex
        If GetPlayerMap(i) = PlayerMap Then
            SendExtras i, 2 'atualiza o npc_highindex
        End If
    Next
    
    If Player(index).Pet.SpriteNum > 0 And index > 0 Then
        SendPetBox index, Player(index).Pet.Name, Npc(Player(index).Pet.SpriteNum).Sprite
    End If
    
    'PlayerWarp index, GetPlayerMap(index), GetPlayerX(index), GetPlayerY(index)
    PetFollowOwner index
End Sub

Function CanNpcAttackNpc(ByVal mapNum As Long, ByVal attacker As Long, ByVal victim As Long, Optional ByVal IsSpell As Byte) As Boolean
    Dim aNpcNum As Long
    Dim vNpcNum As Long
    Dim VictimX As Long
    Dim VictimY As Long
    Dim AttackerX As Long
    Dim AttackerY As Long
    
    CanNpcAttackNpc = False

    ' Check for subscript out of range
    If attacker <= 0 Or attacker > MAX_MAP_NPCS Then
        Exit Function
    End If
    
    If victim <= 0 Or victim > MAX_MAP_NPCS Then
        Exit Function
    End If

    ' Check for subscript out of range
    If MapNpc(mapNum).Npc(attacker).num <= 0 Then
        Exit Function
    End If
    
    ' Check for subscript out of range
    If MapNpc(mapNum).Npc(victim).num <= 0 Then
        Exit Function
    End If

    aNpcNum = MapNpc(mapNum).Npc(attacker).num
    vNpcNum = MapNpc(mapNum).Npc(victim).num
    
    If aNpcNum <= 0 Then Exit Function
    If vNpcNum <= 0 Then Exit Function

    ' Make sure the npcs arent already dead
    If MapNpc(mapNum).Npc(attacker).Vital(Vitals.HP) <= 0 Then
        Exit Function
    End If
    
    ' Make sure the npc isn't already dead
    If MapNpc(mapNum).Npc(victim).Vital(Vitals.HP) <= 0 Then
        Exit Function
    End If

    ' Make sure npcs dont attack more then once a second
    If GetTickCount < MapNpc(mapNum).Npc(attacker).AttackTimer + 1000 Then
        Exit Function
    End If
    
    If MapNpc(mapNum).Npc(attacker).IsPet = NO And MapNpc(mapNum).Npc(victim).IsPet = NO Then
        Exit Function
    End If
    
    MapNpc(mapNum).Npc(attacker).AttackTimer = GetTickCount
    
    AttackerX = MapNpc(mapNum).Npc(attacker).X
    AttackerY = MapNpc(mapNum).Npc(attacker).Y
    VictimX = MapNpc(mapNum).Npc(victim).X
    VictimY = MapNpc(mapNum).Npc(victim).Y
    
    If IsSpell = NO Then
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
    
    Else 'Spell
        CanNpcAttackNpc = True
    End If

End Function

Sub NpcAttackNpc(ByVal mapNum As Long, ByVal attacker As Long, ByVal victim As Long, ByVal Damage As Long)
    Dim i As Long
    Dim Buffer As clsBuffer
    Dim aNpcNum As Long
    Dim vNpcNum As Long
    Dim n As Long
    Dim PetOwner As Long
    Dim EXP As Long
    
    If attacker <= 0 Or attacker > MAX_MAP_NPCS Then Exit Sub
    If victim <= 0 Or victim > MAX_MAP_NPCS Then Exit Sub
    
    If Damage <= 0 Then Exit Sub
    
    aNpcNum = MapNpc(mapNum).Npc(attacker).num
    vNpcNum = MapNpc(mapNum).Npc(victim).num
    
    If aNpcNum <= 0 Then Exit Sub
    If vNpcNum <= 0 Then Exit Sub
    
    If MapNpc(mapNum).Npc(victim).IsPet = YES Then
        If MapNpc(mapNum).Npc(attacker).IsPet = NO Then
            If MapNpc(mapNum).Npc(victim).PetData.Owner > 0 Then
                MapNpc(mapNum).Npc(attacker).targetType = TARGET_TYPE_PLAYER
                MapNpc(mapNum).Npc(attacker).Target = MapNpc(mapNum).Npc(victim).PetData.Owner
                NpcWarpBehind attacker, MapNpc(mapNum).Npc(victim).PetData.Owner
                Exit Sub
            End If
        End If
    End If
            
    'set the victim's target to the pet attacking it
    MapNpc(mapNum).Npc(victim).targetType = 2 'Npc
    MapNpc(mapNum).Npc(victim).Target = attacker
    
    ' Send this packet so they can see the person attacking
    Set Buffer = New clsBuffer
    Buffer.WriteLong SNpcAttack
    Buffer.WriteLong attacker
    SendDataToMap mapNum, Buffer.ToArray()
    Set Buffer = Nothing

    If Damage >= MapNpc(mapNum).Npc(victim).Vital(Vitals.HP) Then
        SendActionMsg mapNum, "-" & Damage, BrightRed, 1, (MapNpc(mapNum).Npc(victim).X * 32), (MapNpc(mapNum).Npc(victim).Y * 32)
        SendBlood mapNum, MapNpc(mapNum).Npc(victim).X, MapNpc(mapNum).Npc(victim).Y
        
        ' npc is dead.
        'Call GlobalMsg(CheckGrammar(Trim$(Npc(vNpcNum).Name), 1) & " has been killed by " & CheckGrammar(Trim$(Npc(aNpcNum).Name)) & "!", BrightRed)

        ' Set NPC target to 0
        MapNpc(mapNum).Npc(attacker).Target = 0
        MapNpc(mapNum).Npc(attacker).targetType = 0
        'reset the targetter for the player
        
        If MapNpc(mapNum).Npc(attacker).IsPet = YES Then
            TempPlayer(MapNpc(mapNum).Npc(attacker).PetData.Owner).Target = 0
            TempPlayer(MapNpc(mapNum).Npc(attacker).PetData.Owner).targetType = TARGET_TYPE_NONE
            
            PetOwner = MapNpc(mapNum).Npc(attacker).PetData.Owner
            EXP = Npc(MapNpc(mapNum).Npc(victim).num).EXP
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
                EXP = EXP * frmServer.txtEventoEXP.Text
            End If
            
            SendTarget PetOwner
            
            'Give the player the pet owner some experience from the kill
            'TempPlayer(PetOwner).GanhouEXP = YES
            'GivePlayerEXP PetOwner, EXP
            'If Player(PetOwner).Org > 0 Then
                'For i = 1 To Player_HighIndex
                    'If Player(i).Org = Player(PetOwner).Org Then
                        'If Not i = PetOwner Then
                            'If GetPlayerMap(i) = GetPlayerMap(PetOwner) Then
                                'TempPlayer(i).GanhouEXP = YES
                                'GivePlayerEXP i, EXP / 2
                            'End If
                        'End If
                    'End If
                'Next
            'Else
                'If TempPlayer(PetOwner).inParty > 0 Then
                    'Party_ShareExp TempPlayer(PetOwner).inParty, EXP, PetOwner
                'End If
            'End If
                      
        ElseIf MapNpc(mapNum).Npc(victim).IsPet = YES Then
            'Get the pet owners' index
            PetOwner = MapNpc(mapNum).Npc(victim).PetData.Owner
            
            Select Case GetPlayerClass(PetOwner)
                Case ITACHI, DEIDARA
                    SendAnimation mapNum, 73, MapNpc(mapNum).Npc(victim).X, MapNpc(mapNum).Npc(victim).Y
                    NpcAttackPlayer victim, attacker, GetNpcDamage(vNpcNum)
                Case KAKASHI
                    SendAnimation mapNum, 73, MapNpc(mapNum).Npc(victim).X, MapNpc(mapNum).Npc(victim).Y
                    NpcAttackPlayer victim, attacker, GetNpcDamage(vNpcNum)
                Case Else
            End Select
            
            'Set the NPC's target on the owner now
            MapNpc(mapNum).Npc(attacker).targetType = 1 'player
            MapNpc(mapNum).Npc(attacker).Target = PetOwner
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
        MapNpc(mapNum).Npc(victim).num = 0
        MapNpc(mapNum).Npc(victim).SpawnWait = GetTickCount
        MapNpc(mapNum).Npc(victim).Vital(Vitals.HP) = 0
               
        ' send npc death packet to map
        Set Buffer = New clsBuffer
        Buffer.WriteLong SNpcDead
        Buffer.WriteLong victim
        SendDataToMap mapNum, Buffer.ToArray()
        Set Buffer = Nothing
        
        If PetOwner > 0 Then
            PetFollowOwner PetOwner
        End If
    Else
        ' npc not dead, just do the damage
        MapNpc(mapNum).Npc(victim).Vital(Vitals.HP) = MapNpc(mapNum).Npc(victim).Vital(Vitals.HP) - Damage
       
        ' Say damage
        SendActionMsg mapNum, "-" & Damage, BrightRed, 1, (MapNpc(mapNum).Npc(victim).X * 32), (MapNpc(mapNum).Npc(victim).Y * 32)
        SendBlood mapNum, MapNpc(mapNum).Npc(victim).X, MapNpc(mapNum).Npc(victim).Y
    End If
    
    'Send both Npc's Vitals to the client
    SendMapNpcVitals mapNum, attacker
    SendMapNpcVitals mapNum, victim

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
        
    Case 42, 83 'Zabuza,Suigetsu
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
                NpcMagiaArea mapNum, mapNpcNum, 18 'Suishouha
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
        
    Case 115, 77, 97, 207, 118 'otsutsuki,Hiruko,Guardião Samurai, 'Akahoshi
        NpcMagiaReta mapNum, mapNpcNum, 96
    Case 74, 75 'hidans
        Select Case RAND(1, 4)
            Case 1
                NpcNormalMagic mapNum, mapNpcNum, 285
                SendActionMsg mapNum, Spell(285).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case 2
                NpcMagiaReta mapNum, mapNpcNum, 286
                SendActionMsg mapNum, Spell(286).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case 3
                NpcMagiaReta mapNum, mapNpcNum, 289
                SendActionMsg mapNum, Spell(289).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case 4
                NpcMagiaArea mapNum, mapNpcNum, 287
                SendActionMsg mapNum, Spell(287).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case Else
        End Select
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
        NpcNormalMagic mapNum, mapNpcNum, 254
    Case 125, 196 'Manda, manda
        NpcMagiaArea mapNum, mapNpcNum, 241
    Case 221, 68, 69, 70 'Kimimaru
        Select Case RAND(1, 3)
            Case 1
                NpcMagiaReta mapNum, mapNpcNum, 181
            Case 2
                NpcMagiaReta mapNum, mapNpcNum, 182
            Case 3
                NpcMagiaArea mapNum, mapNpcNum, 185
            Case Else
        End Select
    Case 220, 76 'Deidara
        Select Case RAND(1, 3)
            Case 1
                NpcMagiaReta mapNum, mapNpcNum, 170
                SendActionMsg mapNum, Spell(170).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case 2
                NpcMagiaArea mapNum, mapNpcNum, 169
                SendActionMsg mapNum, Spell(169).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
            Case 3
                SendActionMsg mapNum, Spell(171).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaArea mapNum, mapNpcNum, 171
            Case Else
        End Select
    Case 84 'sasuke
        Select Case RAND(1, 7)
            Case 1
                SendActionMsg mapNum, Spell(39).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaReta mapNum, mapNpcNum, 39
            Case 2
                SendActionMsg mapNum, Spell(41).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaReta mapNum, mapNpcNum, 41
            Case 3
                SendActionMsg mapNum, Spell(42).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaReta mapNum, mapNpcNum, 42
            Case 4
                SendActionMsg mapNum, Spell(43).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaReta mapNum, mapNpcNum, 43
            Case 5
                SendActionMsg mapNum, Spell(44).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcNormalMagic mapNum, mapNpcNum, 44
            Case 6
                SendActionMsg mapNum, Spell(45).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcNormalMagic mapNum, mapNpcNum, 45
            Case 7
                SendActionMsg mapNum, Spell(22).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaArea mapNum, mapNpcNum, 22
            Case Else
        End Select
    Case 81, 82, 86, 87, 88, 89, 97 'jutsu normal soh pra animação mesmo
        NpcMagiaReta mapNum, mapNpcNum, 253
    Case 92, 112, 102 'Kisame,tobirama 102
        Select Case RAND(1, 4)
            Case 1
                SendActionMsg mapNum, Spell(161).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaArea mapNum, mapNpcNum, 161
            Case 2
                SendActionMsg mapNum, Spell(164).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaReta mapNum, mapNpcNum, 164
            Case 3
                SendActionMsg mapNum, Spell(160).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcNormalMagic mapNum, mapNpcNum, 160
            Case 4
                SendActionMsg mapNum, Spell(162).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcNormalMagic mapNum, mapNpcNum, 162
            Case Else
        End Select
    Case 93, 94 'Itachi
        Select Case RAND(1, 5)
            Case 1
                SendActionMsg mapNum, Spell(177).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcNormalMagic mapNum, mapNpcNum, 177
            Case 2
                SendActionMsg mapNum, Spell(45).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcNormalMagic mapNum, mapNpcNum, 45
            Case 3
                SendActionMsg mapNum, Spell(176).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaArea mapNum, mapNpcNum, 176
            Case 4
                SendActionMsg mapNum, Spell(7).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaReta mapNum, mapNpcNum, 7
            Case 5
                SendActionMsg mapNum, Spell(10).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaReta mapNum, mapNpcNum, 10
            Case Else
        End Select
    Case 95 'Pain
        Select Case RAND(1, 4)
            Case 1
                SendActionMsg mapNum, Spell(207).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcNormalMagic mapNum, mapNpcNum, 207
            Case 2
                SendActionMsg mapNum, Spell(210).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcNormalMagic mapNum, mapNpcNum, 210
            Case 3
                SendActionMsg mapNum, Spell(208).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaArea mapNum, mapNpcNum, 208
            Case 4
                SendActionMsg mapNum, Spell(209).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaReta mapNum, mapNpcNum, 209
            Case Else
        End Select
    Case 98, 99 'Tobi
        Select Case RAND(1, 6)
            Case 1
                SendActionMsg mapNum, Spell(177).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcNormalMagic mapNum, mapNpcNum, 177
            Case 2
                SendActionMsg mapNum, Spell(45).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcNormalMagic mapNum, mapNpcNum, 45
            Case 3
                SendActionMsg mapNum, Spell(208).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaArea mapNum, mapNpcNum, 208
            Case 4
                SendActionMsg mapNum, Spell(14).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaArea mapNum, mapNpcNum, 14
            Case 5
                SendActionMsg mapNum, Spell(120).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaArea mapNum, mapNpcNum, 120
            Case 6
                SendActionMsg mapNum, Spell(10).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaReta mapNum, mapNpcNum, 10
            Case Else
        End Select
    Case 101 'Madara
        Select Case RAND(1, 3)
            Case 1
                SendActionMsg mapNum, Spell(212).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcNormalMagic mapNum, mapNpcNum, 212
            Case 2
                SendActionMsg mapNum, Spell(213).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaArea mapNum, mapNpcNum, 213
            Case 3
                SendActionMsg mapNum, Spell(214).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaReta mapNum, mapNpcNum, 214
            Case Else
        End Select
    Case 103 'Jiraya
        Select Case RAND(1, 3)
            Case 1
                SendActionMsg mapNum, Spell(188).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaArea mapNum, mapNpcNum, 188
            Case 2
                SendActionMsg mapNum, Spell(190).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaReta mapNum, mapNpcNum, 190
            Case 3
                SendActionMsg mapNum, Spell(29).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaReta mapNum, mapNpcNum, 29
            Case Else
        End Select
    Case 104 'Bee
        Select Case RAND(1, 4)
            Case 1
                SendActionMsg mapNum, Spell(235).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaArea mapNum, mapNpcNum, 235
            Case 2
                SendActionMsg mapNum, Spell(233).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaReta mapNum, mapNpcNum, 233
            Case 3
                SendActionMsg mapNum, Spell(236).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaReta mapNum, mapNpcNum, 236
            Case 4
                SendActionMsg mapNum, Spell(232).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaReta mapNum, mapNpcNum, 232
            Case Else
        End Select
    Case 106 'Darui
        Select Case RAND(1, 4)
            Case 1
                SendActionMsg mapNum, Spell(281).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaArea mapNum, mapNpcNum, 281
            Case 2
                SendActionMsg mapNum, Spell(279).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaReta mapNum, mapNpcNum, 279
            Case 3
                SendActionMsg mapNum, Spell(282).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaReta mapNum, mapNpcNum, 282
            Case 4
                SendActionMsg mapNum, Spell(278).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcNormalMagic mapNum, mapNpcNum, 278
            Case Else
        End Select
    Case 91 'Konan
        Select Case RAND(1, 3)
            Case 1
                SendActionMsg mapNum, Spell(269).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaArea mapNum, mapNpcNum, 269
            Case 2
                SendActionMsg mapNum, Spell(265).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaReta mapNum, mapNpcNum, 265
            Case 3
                SendActionMsg mapNum, Spell(268).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaReta mapNum, mapNpcNum, 268
                
            Case Else
        End Select
    
    Case 110 'DanZou
        Select Case RAND(1, 4)
            Case 1
                SendActionMsg mapNum, Spell(301).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaArea mapNum, mapNpcNum, 301
            Case 2
                SendActionMsg mapNum, Spell(302).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaReta mapNum, mapNpcNum, 302
            Case 3
                SendActionMsg mapNum, Spell(304).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaReta mapNum, mapNpcNum, 304
            Case 4
                SendActionMsg mapNum, Spell(303).Name, Red, 1, MapNpc(mapNum).Npc(mapNpcNum).X * 32, MapNpc(mapNum).Npc(mapNpcNum).Y * 32
                NpcMagiaArea mapNum, mapNpcNum, 303
                
            Case Else
        End Select
    
    Case 190 'kyuubi
        NpcMagiaReta mapNum, mapNpcNum, 10
        
    Case 191 'shukaku
        NpcMagiaArea mapNum, mapNpcNum, 14
        
    Case 192 'sanbi
        NpcMagiaArea mapNum, mapNpcNum, 18
        
    Case 193 'yonbi
        NpcMagiaReta mapNum, mapNpcNum, 23
    
    Case 194 'hachibi
        NpcMagiaReta mapNum, mapNpcNum, 234
        
    Case 195 'salamander
        NpcNormalMagic mapNum, mapNpcNum, 254
    
    Case 116 'gai
        Select Case RAND(1, 3)
            Case 1
                NpcMagiaArea mapNum, mapNpcNum, 318
            Case 2
                NpcMagiaReta mapNum, mapNpcNum, 320
            Case 3
                NpcMagiaReta mapNum, mapNpcNum, 321
            Case Else
                NpcMagiaReta mapNum, mapNpcNum, 321
        End Select
    
    Case 117 'mei
        Select Case RAND(1, 3)
            Case 1
                NpcMagiaArea mapNum, mapNpcNum, 328
            Case 2
                NpcMagiaReta mapNum, mapNpcNum, 326
            Case 3
                NpcMagiaReta mapNum, mapNpcNum, 329
            Case Else
                NpcMagiaReta mapNum, mapNpcNum, 326
        End Select
                
Case Else

End Select

End Sub

Public Function CanBerserkerAttack(ByVal mapNum As Long) As Boolean

Select Case mapNum
    Case 294, 295, 99, 69, 70, 71, 72, 54, 55, 56, 82, 83, 84, 85, 86, 298, 300, 98, 95, 293
        CanBerserkerAttack = False
    Case Else
        CanBerserkerAttack = True
End Select

End Function

Public Function IsVictimOverKilled(ByVal victim As Long) As Boolean
Dim i As Long

For i = 1 To MAX_PLAYERS
    If AntiFK(i) = GetPlayerName(victim) Then
        IsVictimOverKilled = True
        Exit Function
    End If
Next

For i = 1 To MAX_PLAYERS
    If AntiFK(i) = vbNullString Then
        AntiFK(i) = GetPlayerName(victim)
        Exit Function
    End If
Next

End Function

Public Function IsUpAlone(ByVal index As Long) As Boolean
If index < 1 Or index > MAX_PLAYERS Then Exit Function
If IsPlaying(index) = False Then Exit Function

Dim i As Long
Dim mapNum As Long

mapNum = GetPlayerMap(index)

For i = 1 To Player_HighIndex
    If i <> index Then
        If TempPlayer(index).inParty > 0 Then
            If TempPlayer(i).inParty = TempPlayer(index).inParty Then
                If mapNum = GetPlayerMap(i) Then
                    IsUpAlone = False
                    Exit Function
                End If
            End If
        End If
        
        If Player(index).Org > 0 Then
            If Player(i).Org = Player(index).Org Then
                If mapNum = GetPlayerMap(i) Then
                    IsUpAlone = False
                    Exit Function
                End If
            End If
        End If
    End If
Next

IsUpAlone = True

End Function
