Attribute VB_Name = "modScriptedSpell"
Sub ScriptedSpell(ByVal index As Long, ByVal Script As Long, ByVal SpellNum As Long)
Dim i, mapNum, Alvo As Long
Dim AlvoType As Byte
mapNum = GetPlayerMap(index)
Alvo = TempPlayer(index).Target
AlvoType = TempPlayer(index).targetType

Select Case Script

     Case 1 'Kawarimi No Jutsu
        If GetPlayerMap(index) = 57 Or GetPlayerMap(index) = 62 Or GetPlayerMap(index) = 63 Then Exit Sub
        If Map(mapNum).Moral = MAP_MORAL_SAFE Then
            PlayerMsg index, "Você está em uma zona segura!", BrightRed
            Exit Sub
        End If
          If Not TempPlayer(index).Kawarimi > 0 Then
                 TempPlayer(index).Kawarimi = GetTickCount + 3000
                 PlayerMsg index, "Kawarimi no Jutsu Ativado!", BrightBlue
          End If

     Case 2 'Kage Buyou.Teleporta atraz do inimigo
        If GetPlayerMap(index) = 57 Or GetPlayerMap(index) = 62 Or GetPlayerMap(index) = 63 Then Exit Sub
        If Map(mapNum).Moral = MAP_MORAL_SAFE Then
            PlayerMsg index, "Você está em uma zona segura!", BrightRed
            Exit Sub
        End If
        
        If TempPlayer(index).Target = index Then
            PlayerMsg index, "Não pode selecionar você mesmo!", BrightRed
            Exit Sub
        End If
        
          If TempPlayer(index).Target > 0 Then
          
             'TempPlayer(index).Shunshin = GetTickCount + 1
             Select Case TempPlayer(index).targetType
                 Case TARGET_TYPE_PLAYER
                    SendAnimation mapNum, 1, GetPlayerX(index), GetPlayerY(index)
                    WarpBehind_Player index, TempPlayer(index).Target
                 
                 Case TARGET_TYPE_NPC
                    SendAnimation mapNum, 1, GetPlayerX(index), GetPlayerY(index)
                    WarpBehind_Npc index, TempPlayer(index).Target
                    
             End Select
            
    
          Else
            PlayerMsg index, "Selecione um Alvo antes..", BrightRed
          End If
          
        Case 3 'Mizu no Kinobori
            If TempPlayer(index).AndandoAgua = YES Then
                TempPlayer(index).AndandoAgua = NO
                PlayerMsg index, "Você desativou o Jutsu Mizu no Kinobori!", Cyan
            Else
                TempPlayer(index).AndandoAgua = YES
                PlayerMsg index, "Você ativou o Jutsu Mizu no Kinobori!", BrightCyan
            End If
            
        Case 4 'KageBunshin
            Select Case GetPlayerClass(index)
                Case 1
                    SpawnPet index, mapNum, 2
                Case 2
                    SpawnPet index, mapNum, 3
                Case 3
                    SpawnPet index, mapNum, 4
                Case 4
                    SpawnPet index, mapNum, 5
                Case 5
                    SpawnPet index, mapNum, 6
                Case 6
                    SpawnPet index, mapNum, 7
                Case 7
                    SpawnPet index, mapNum, 8
                Case 8
                    SpawnPet index, mapNum, 9
                Case 9
                    SpawnPet index, mapNum, 10
                Case 10
                    SpawnPet index, mapNum, 11
                Case 11
                    SpawnPet index, mapNum, 12
                Case 12
                    SpawnPet index, mapNum, 14
                Case 13
                    SpawnPet index, mapNum, 15
                Case 14
                    SpawnPet index, mapNum, 16
                Case Else
            End Select
        
        Case 5 'Henge no Jutsu(copiar sprite)
        
        If TempPlayer(index).Target > 0 Then
            Select Case TempPlayer(index).targetType
                Case TARGET_TYPE_PLAYER
                    If Not TempPlayer(index).Henge > 0 Then
                        If IsPlaying(TempPlayer(index).Target) Then
                            SetPlayerSprite index, GetPlayerSprite(TempPlayer(index).Target)
                            SendPlayerData index
                            TempPlayer(index).Henge = GetTickCount + 15000
                        End If
                    End If
                    
                Case TARGET_TYPE_NPC
                    If Not TempPlayer(index).Henge > 0 Then
                        If MapNpc(mapNum).Npc(TempPlayer(index).Target).num > 0 Then
                            SetPlayerSprite index, Npc(MapNpc(mapNum).Npc(TempPlayer(index).Target).num).Sprite
                            SendPlayerData index
                            TempPlayer(index).Henge = GetTickCount + 15000
                        End If
                    End If
                    
                Case Else
                    Exit Sub
            End Select
        Else
            PlayerMsg index, "Selecione um alvo primeiro..", BrightRed
        End If
        
        Case 6 'Modo Sage-Naruto
            If TempPlayer(index).Henge > 0 Then
                PlayerMsg index, "Henge está ativado..", BrightRed
                Exit Sub
            End If
            
            For i = 1 To 4
                If TempPlayer(index).Dojutsu(i) > 0 Then
                    TirarDojutsu index, i
                End If
            Next
                
                TempPlayer(index).Dojutsu(1) = GetTickCount + 60000
                TempPlayer(index).MySprite = GetPlayerSprite(index)
                SetPlayerSprite index, 8
                SendPlayerData index
            
            
        Case 7 'Sharingan nv1
            For i = 1 To 4
                If TempPlayer(index).Dojutsu(i) > 0 Then
                    TirarDojutsu index, i
                End If
            Next
            'SetPlayerStat index, Stats.Intelligence, GetPlayerStat(index, Stats.Intelligence) + 5
            TempPlayer(index).Dojutsu(1) = GetTickCount + 15000
            
        Case 8 'Shringan nv2
            For i = 1 To 4
                If TempPlayer(index).Dojutsu(i) > 0 Then
                    TirarDojutsu index, i
                End If
            Next
            'SetPlayerStat index, Stats.Intelligence, GetPlayerStat(index, Stats.Intelligence) + 15
            TempPlayer(index).Dojutsu(2) = GetTickCount + 30000
         
        Case 9 'Sharingan nv3
            If TempPlayer(index).Henge > 0 Then Exit Sub
            
            For i = 1 To 4
                If TempPlayer(index).Dojutsu(i) > 0 Then
                    TirarDojutsu index, i
                End If
            Next
            TempPlayer(index).MySprite = GetPlayerSprite(index)
            'SetPlayerStat index, Stats.Intelligence, GetPlayerStat(index, Stats.Intelligence) + 30
            TempPlayer(index).Dojutsu(1) = GetTickCount + 60000
        Case 10 'Magenkyo Sharingan-Sasuke
            If TempPlayer(index).Henge > 0 Then Exit Sub
            
            For i = 1 To 4
                If TempPlayer(index).Dojutsu(i) > 0 Then
                    TirarDojutsu index, i
                End If
            Next
            'SetPlayerStat index, Stats.Intelligence, GetPlayerStat(index, Stats.Intelligence) + 30
            'SetPlayerStat index, Stats.strength, GetPlayerStat(index, Stats.strength) + 30
            'SetPlayerStat index, Stats.Agility, GetPlayerStat(index, Stats.Agility) + 30
            TempPlayer(index).Dojutsu(2) = GetTickCount + 120000
        
        Case 11 'Chakra Enforce-Buff da Sakura
            If Not TempPlayer(index).Dojutsu(1) > 0 Then
                TempPlayer(index).Dojutsu(1) = GetTickCount + 60000
                PlayerMsg index, "Chakra Enforce ativado!", White
                'SetPlayerStat index, Stats.strength, GetPlayerStat(index, Stats.strength) + 45
                'SetPlayerStat index, Stats.Agility, GetPlayerStat(index, Stats.Agility) + 15
            Else
                PlayerMsg index, "Já está usando o Chakra Enforce.", Grey
            End If
            
        Case 12 'Reflect Yamanaka
            If Not TempPlayer(index).Reflect > 0 Then
                TempPlayer(index).Reflect = GetTickCount + 20000
            Else
                PlayerMsg index, "Jutsu já está ativado!", BrightRed
            End If
        
        Case 13 'yamanaka Pegar Infos
            If Not AlvoType = TARGET_TYPE_PLAYER Then Exit Sub
            If Not GetPlayerLevel(index) + 200 > GetPlayerLevel(Alvo) Then
                PlayerMsg index, "Você precisa ter uma diferença de no máximo 200 Levels!", BrightRed
                Exit Sub
            End If
            
            If Alvo > 0 Then
                PlayerMsg index, "Tai:" & GetPlayerStat(Alvo, Stats.strength) & ".Res:" & GetPlayerStat(Alvo, Stats.Endurance) & ".Nin:" & GetPlayerStat(Alvo, Stats.Intelligence) & ".Gen:" & GetPlayerStat(Alvo, Stats.Willpower) & ".Agi:" & GetPlayerStat(Alvo, Stats.Agility), BrightBlue
                PlayerMsg index, "Clãn:" & GetClassName(Alvo), BrightBlue
                
            Else
                PlayerMsg index, "Selecione um Alvo.", BrightRed
            End If
        
        Case 14 'Jutsu que o inimigo precisa estar Stunado
            If Not Alvo > 0 Then Exit Sub
            
            Select Case AlvoType
                Case TARGET_TYPE_PLAYER
                    If TempPlayer(Alvo).StunDuration > 0 Then
                        If CanPlayerAttackPlayer(index, Alvo, True) Then
                            PlayerAttackPlayer index, Alvo, GetSpellBaseStat(index, SpellNum), SpellNum
                        End If
                    End If
                
                Case TARGET_TYPE_NPC
                    If MapNpc(mapNum).Npc(Alvo).StunDuration > 0 Then
                        If CanPlayerAttackNpc(index, Alvo, True) Then
                            PlayerAttackNpc index, Alvo, GetSpellBaseStat(index, SpellNum), SpellNum
                        End If
                    End If
            End Select
            
        Case 15 'baika no Jutsu-Chouji
            For i = 1 To 4
                If TempPlayer(index).Dojutsu(i) > 0 Then
                    TirarDojutsu index, i
                End If
            Next
            'SetPlayerStat index, Stats.strength, GetPlayerStat(index, Stats.strength) + 5
            TempPlayer(index).Dojutsu(1) = GetTickCount + 15000

        Case 16 'Bubun Baika no Jutsu-Chouji
            For i = 1 To 4
                If TempPlayer(index).Dojutsu(i) > 0 Then
                    TirarDojutsu index, i
                End If
            Next
            'SetPlayerStat index, Stats.strength, GetPlayerStat(index, Stats.strength) + 15
            TempPlayer(index).Dojutsu(2) = GetTickCount + 30000
            
        Case 17 'Chou Baika no Jutsu-Chouji
            For i = 1 To 4
                If TempPlayer(index).Dojutsu(i) > 0 Then
                    TirarDojutsu index, i
                End If
            Next
            'SetPlayerStat index, Stats.Endurance, GetPlayerStat(index, Stats.Endurance) + 30
            'SetPlayerStat index, Stats.strength, GetPlayerStat(index, Stats.strength) + 30
            TempPlayer(index).Dojutsu(3) = GetTickCount + 60000
        
        Case 18 'Buff Lee
            For i = 1 To 4
                If TempPlayer(index).Dojutsu(i) > 0 Then
                    PlayerMsg index, "Você já está usando..", Grey
                    Exit Sub
                End If
            Next
            'SetPlayerStat index, Stats.Endurance, GetPlayerStat(index, Stats.Endurance) + 30
            'SetPlayerStat index, Stats.strength, GetPlayerStat(index, Stats.strength) + 30
            'SetPlayerStat index, Stats.Agility, GetPlayerStat(index, Stats.Agility) + 30
            TempPlayer(index).Dojutsu(1) = GetTickCount + 60000
            
        Case 19 'Byakugan nv 1
            For i = 1 To 4
                If TempPlayer(index).Dojutsu(i) > 0 Then
                    TirarDojutsu index, i
                End If
            Next
            'SetPlayerStat index, Stats.strength, GetPlayerStat(index, Stats.strength) + 15
            TempPlayer(index).Dojutsu(1) = GetTickCount + 15000
        
        Case 20 'Byakugan nv2
            For i = 1 To 4
                If TempPlayer(index).Dojutsu(i) > 0 Then
                    TirarDojutsu index, i
                End If
            Next
            'SetPlayerStat index, Stats.strength, GetPlayerStat(index, Stats.strength) + 30
            'SetPlayerStat index, Stats.Agility, GetPlayerStat(index, Stats.Agility) + 30
            TempPlayer(index).Dojutsu(2) = GetTickCount + 60000
            
        Case 21 'Buff Tenten
            For i = 1 To 4
                If TempPlayer(index).Dojutsu(i) > 0 Then
                    PlayerMsg index, "Você já está usando..", Grey
                    Exit Sub
                End If
            Next
            'SetPlayerStat index, Stats.strength, GetPlayerStat(index, Stats.strength) + 15
            'SetPlayerStat index, Stats.Agility, GetPlayerStat(index, Stats.Agility) + 15
            TempPlayer(index).Dojutsu(1) = GetTickCount + 15000
            
        Case 22 'Buff1 Inuzuka
            For i = 1 To 4
                If TempPlayer(index).Dojutsu(i) > 0 Then
                    TirarDojutsu index, i
                End If
            Next
            'SetPlayerStat index, Stats.strength, GetPlayerStat(index, Stats.strength) + 15
            TempPlayer(index).Dojutsu(1) = GetTickCount + 15000
            
        Case 23 'Buff2 Inuzuka
            For i = 1 To 4
                If TempPlayer(index).Dojutsu(i) > 0 Then
                    TirarDojutsu index, i
                End If
            Next
            'SetPlayerStat index, Stats.strength, GetPlayerStat(index, Stats.strength) + 30
            TempPlayer(index).Dojutsu(2) = GetTickCount + 30000
        
        Case 24 'Buff3 Inuzuka
            For i = 1 To 4
                If TempPlayer(index).Dojutsu(i) > 0 Then
                    TirarDojutsu index, i
                End If
            Next
            'SetPlayerStat index, Stats.Endurance, GetPlayerStat(index, Stats.Endurance) + 30
            'SetPlayerStat index, Stats.strength, GetPlayerStat(index, Stats.strength) + 30
            'SetPlayerStat index, Stats.Agility, GetPlayerStat(index, Stats.Agility) + 30
            TempPlayer(index).Dojutsu(3) = GetTickCount + 60000
            
        Case 25 'Buff Sasuke-Susanoo
            If TempPlayer(index).Henge > 0 Then
                PlayerMsg index, "Henge está ativado..", BrightRed
                Exit Sub
            End If
        
            If TempPlayer(index).Reflect > 0 Then
                PlayerMsg index, "Susanoo já está ativado!", BrightRed
                Exit Sub
            End If
            
            TempPlayer(index).MySprite = GetPlayerSprite(index)
            Select Case GetPlayerLevel(index)
                Case 280 To 500
                    SetPlayerSprite index, 165
                Case 501 To 749
                    SetPlayerSprite index, 165 'Ainda não tem a sprite do susanoo nv2
                Case 750 To MAX_INTEGER
                    SetPlayerSprite index, 166
                Case Else
                    SetPlayerSprite index, 165
            End Select
            SendPlayerData index
            TempPlayer(index).Reflect = GetTickCount + 120000
Case Else
Call PlayerMsg(index, "YOU GOT RICK ROLLED", Red)
End Select
End Sub
