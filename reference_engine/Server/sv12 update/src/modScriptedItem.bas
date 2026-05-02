Attribute VB_Name = "modScriptedItem"
Sub ScriptedItem(ByVal index As Long, ByVal Script As Long, ByVal ItemNum As Long)
Dim mapNum, i, Alvo As Long
Dim AlvoType, X, Y As Byte

AlvoType = TempPlayer(index).targetType
Alvo = TempPlayer(index).Target
mapNum = GetPlayerMap(index)
X = GetPlayerX(index)
Y = GetPlayerY(index)

Select Case Script
    Case 1 'Shuriken
        If TempPlayer(index).ArrowTime > 0 Then Exit Sub
        
        TempPlayer(index).ArrowTime = GetTickCount + 1000
        SendArrow index, 7, 4, RAND(1, GetPlayerDamage(index) / 10), 100, 29
                        
    
    Case 2 'Kunai
        If TempPlayer(index).ArrowTime > 0 Then Exit Sub
        
        TempPlayer(index).ArrowTime = GetTickCount + 2000
        SendArrow index, 1, 6, RAND(1, GetPlayerDamage(index) / 7), 100, 29
    
    
    Case 3 'Senbon
        If TempPlayer(index).ArrowTime > 0 Then Exit Sub
        
        TempPlayer(index).ArrowTime = GetTickCount + 1000
        SendArrow index, 13, 10, RAND(1, GetPlayerDamage(index) / 4), 100, 29
        
    Case 4 'Fuuma Shuriken
        If TempPlayer(index).ArrowTime > 0 Then Exit Sub
        
        TempPlayer(index).ArrowTime = GetTickCount + 2000
        SendArrow index, 9, 10, RAND(1, GetPlayerDamage(index) / 2), 100, 60
    
    Case 5 'Tarja Explosiva
        If TempPlayer(index).ArrowTime > 0 Then Exit Sub
        
        TempPlayer(index).ArrowTime = GetTickCount + 2000
        SendArrow index, 11, 10, RAND(1, GetPlayerDamage(index)), 100, 16
    
    Case 6 'Jutsus Katon
        For i = 1 To 5
            If Player(index).Elemento(i) = 1 Then 'Katon
                
                Select Case ItemNum
                    Case 21
                        If Not HasSpell(index, 7) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 7
                        End If
                        
                        PlayerMsg index, "Jutsu aprendido!", BrightGreen
                    Case 22
                        If Not HasSpell(index, 8) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 8
                        End If
                        
                        PlayerMsg index, "Jutsu aprendido!", BrightGreen
                    Case 23
                        If Not HasSpell(index, 9) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 9
                        End If
                        
                        PlayerMsg index, "Jutsu aprendido!", BrightGreen
                    Case 24
                        If Not HasSpell(index, 10) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 10
                        End If
                        
                        PlayerMsg index, "Jutsu aprendido!", BrightGreen
                    Case Else
                End Select
                
                Exit For
            Else
                PlayerMsg index, "Você não é do Elemento Katon!", BrightRed
            End If
        Next
        
    Case 7 'Vento
        For i = 1 To 5
            If Player(index).Elemento(i) = 2 Then 'Vento
                              
                Select Case ItemNum
                    Case 26
                        If Not HasSpell(index, 11) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 11
                        End If
                        
                        PlayerMsg index, "Jutsu aprendido!", BrightGreen
                    Case 27
                        If Not HasSpell(index, 12) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 12
                        End If
                        
                        PlayerMsg index, "Jutsu aprendido!", BrightGreen
                    Case 28
                        If Not HasSpell(index, 13) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 13
                        End If
                        
                        PlayerMsg index, "Jutsu aprendido!", BrightGreen
                    Case 29
                        If Not HasSpell(index, 14) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 14
                        End If
                        
                        PlayerMsg index, "Jutsu aprendido!", BrightGreen
                    Case Else
                End Select
                
                Exit For
            Else
                PlayerMsg index, "Você não é do Elemento Fuuton!", BrightRed
            End If
        Next
        
    Case 8 'Agua
        For i = 1 To 5
            If Player(index).Elemento(i) = 3 Then 'Agua
                               
                Select Case ItemNum
                    Case 31
                        If Not HasSpell(index, 15) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 15
                        End If
                        
                        PlayerMsg index, "Jutsu aprendido!", BrightGreen
                    Case 32
                        If Not HasSpell(index, 16) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 16
                        End If
                        
                        PlayerMsg index, "Jutsu aprendido!", BrightGreen
                    Case 33
                        If Not HasSpell(index, 17) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 17
                        End If
                        
                        PlayerMsg index, "Jutsu aprendido!", BrightGreen
                    Case 34
                        If Not HasSpell(index, 18) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 18
                        End If
                        
                        PlayerMsg index, "Jutsu aprendido!", BrightGreen
                    Case Else
                End Select
                
                Exit For
            Else
                PlayerMsg index, "Você não é do Elemento Suiton!", BrightRed
            End If
        Next
        
    Case 9 'Terra
        For i = 1 To 5
            If Player(index).Elemento(i) = 4 Then 'Terra
                              
                Select Case ItemNum
                    Case 41
                        If Not HasSpell(index, 23) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 23
                        End If
                        
                        PlayerMsg index, "Jutsu aprendido!", BrightGreen
                    Case 42
                        If Not HasSpell(index, 24) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 24
                        End If
                        
                        PlayerMsg index, "Jutsu aprendido!", BrightGreen
                    Case 43
                        If Not HasSpell(index, 25) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 25
                        End If
                        
                        PlayerMsg index, "Jutsu aprendido!", BrightGreen
                    Case 44
                        If Not HasSpell(index, 26) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 26
                        End If
                        
                        PlayerMsg index, "Jutsu aprendido!", BrightGreen
                    Case Else
                End Select
                
                Exit For
            Else
                PlayerMsg index, "Você não é do Elemento Terra!", BrightRed
            End If
        Next
        
    Case 10 'Raio
        For i = 1 To 5
            If Player(index).Elemento(i) = 5 Then 'Raio
                
                Select Case ItemNum
                    Case 36
                        If Not HasSpell(index, 19) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 19
                        End If
                        
                        PlayerMsg index, "Jutsu aprendido!", BrightGreen
                    Case 37
                        If Not HasSpell(index, 20) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 20
                        End If
                        
                        PlayerMsg index, "Jutsu aprendido!", BrightGreen
                    Case 38
                        If Not HasSpell(index, 21) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 21
                        End If
                        
                        PlayerMsg index, "Jutsu aprendido!", BrightGreen
                    Case 39
                        If Not HasSpell(index, 22) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 22
                        End If
                        
                        PlayerMsg index, "Jutsu aprendido!", BrightGreen
                    Case Else
                End Select
                
                Exit For
            Else
                PlayerMsg index, "Você não é do Elemento Raio!", BrightRed
            End If
        Next
        
    Case 11 'Item reset
        For i = 1 To Equipment.Equipment_Count - 1
            If GetPlayerEquipment(index, i) > 0 Then
                PlayerMsg index, "Desequipe seus itens antes.", BrightRed
                Exit Sub
            End If
        Next
        
        i = GetPlayerStat(index, Stats.Agility) + GetPlayerStat(index, Stats.Endurance) + GetPlayerStat(index, Stats.Intelligence) + GetPlayerStat(index, Stats.strength) + GetPlayerStat(index, Stats.Willpower)
        PlayerMsg index, "Você resetou seus stats e agora têm " & i & " pontos para distribuir!", BrightGreen
        TempPlayer(index).SetPoints = YES
        SetPlayerPOINTS index, GetPlayerPOINTS(index) + i
        
        Dim u As Byte
            For u = 1 To Stats.Stat_Count - 1
                SetPlayerStat index, u, 1
            Next
        If CanTake(index, ItemNum, 1) Then TakeItem index, ItemNum, 1
        SavePlayer index
    
    Case 12 'Invitar Membro-Nukenin
    If Not Player(index).Org = ORG_UNDERWORLD Then Exit Sub
    
        If TempPlayer(index).Target > 0 Then
            If TempPlayer(index).targetType = TARGET_TYPE_PLAYER Then
                If Not Player(TempPlayer(index).Target).Org > 0 Then
                    If Not GetPlayerAccess(TempPlayer(index).Target) > 1 Or GetPlayerAccess(TempPlayer(index).Target) = ADMIN_CREATOR Then
                        'If GetPlayerLevel(TempPlayer(index).Target) >= 100 Then
                            PlayerMsg TempPlayer(index).Target, "Você entrou para a UnderWorld", BrightCyan
                            GlobalMsg GetPlayerName(TempPlayer(index).Target) & " entrou para a UnderWorld", BrightCyan
                            Player(TempPlayer(index).Target).Org = ORG_UNDERWORLD
                            SendPlayerData TempPlayer(index).Target
                            SavePlayer TempPlayer(index).Target
                        'Else
                            'PlayerMsg index, "Ele precisa ser pelo menos level 100!", BrightRed
                        'End If
                    Else
                        PlayerMsg index, "Ele não é player!", BrightRed
                    End If
                Else
                    PlayerMsg index, "O player já está em uma Organização!", BrightRed
                End If
            Else
                PlayerMsg index, "Selecione um PLAYER ", BrightRed
            End If
        Else
            PlayerMsg index, "Selecione o PLAYER que você quer na guild", BrightRed
        End If
    
    Case 13 'Expulsar Membro
    
        If TempPlayer(index).Target > 0 Then
            If TempPlayer(index).targetType = TARGET_TYPE_PLAYER Then
                If Player(TempPlayer(index).Target).Org = Player(index).Org Then
                    Player(TempPlayer(index).Target).Org = 0
                    PlayerMsg TempPlayer(index).Target, "Você foi expulso de sua Org!", BrightRed
                    SendPlayerData TempPlayer(index).Target
                    SavePlayer TempPlayer(index).Target
                Else
                    PlayerMsg index, "O membro precisa ser da SUA organização", BrightRed
                End If
            Else
                PlayerMsg index, "Selecione um PLAYER ", BrightRed
            End If
        Else
            PlayerMsg index, "Selecione o PLAYER que você quer na Org", BrightRed
        End If
        
    Case 14 'Invisivel
        If Player(index).Invisivel = YES Then
            Player(index).Invisivel = NO
            PlayerMsg index, "Modo Ninja desativado!", Green
        Else
            Player(index).Invisivel = YES
            PlayerMsg index, "Modo Ninja ativado!", BrightGreen
        End If
        SendPlayerData index
    
    Case 15 'Invitar Membro-Vector
    If Not Player(index).Org = ORG_VECTOR And GetPlayerAccess(index) < ADMIN_MONITOR Then Exit Sub
    
        If TempPlayer(index).Target > 0 Then
            If TempPlayer(index).targetType = TARGET_TYPE_PLAYER Then
                If Not Player(TempPlayer(index).Target).Org > 0 Then
                    If Not GetPlayerAccess(TempPlayer(index).Target) > 1 Or GetPlayerAccess(TempPlayer(index).Target) = ADMIN_CREATOR Then
                        'If GetPlayerLevel(TempPlayer(index).Target) >= 100 Then
                            PlayerMsg TempPlayer(index).Target, "Você entrou para a Vector Drawing Art", BrightCyan
                            GlobalMsg GetPlayerName(TempPlayer(index).Target) & " entrou para a Vector Drawing Art", BrightCyan
                            Player(TempPlayer(index).Target).Org = ORG_VECTOR
                            SendPlayerData TempPlayer(index).Target
                            SavePlayer TempPlayer(index).Target
                        'Else
                            'PlayerMsg index, "Ele precisa ser pelo menos level 100!", BrightRed
                        'End If
                    Else
                        PlayerMsg index, "Ele não é player!", BrightRed
                    End If
                Else
                    PlayerMsg index, "O player já está em uma Organização!", BrightRed
                End If
            Else
                PlayerMsg index, "Selecione um PLAYER ", BrightRed
            End If
        Else
            PlayerMsg index, "Selecione o PLAYER que você quer na guild", BrightRed
        End If
        
        
Case Else
Call PlayerMsg(index, "YOU GOT RICK ROLLED", Red)
End Select
End Sub
