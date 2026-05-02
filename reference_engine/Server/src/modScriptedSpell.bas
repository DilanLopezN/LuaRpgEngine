Attribute VB_Name = "modScriptedSpell"
Sub ScriptedSpell(ByVal index As Long, ByVal Script As Long, ByVal SpellNum As Long)
Dim i, mapNum, Alvo As Long
Dim AlvoType, OK As Byte
Dim X As Byte, Y As Byte

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
                    If GetPlayerMap(Alvo) > 0 And GetPlayerMap(Alvo) = GetPlayerMap(index) Then
                        SendAnimation mapNum, 1, GetPlayerX(index), GetPlayerY(index)
                        WarpBehind_Player index, TempPlayer(index).Target
                    Else
                        PlayerMsg index, "Seu alvo foi pra outro local", Red
                    End If
                    
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
                Case HINATA
                    SpawnPet index, mapNum, 127
                Case SAI
                    SpawnPet index, mapNum, 128
                Case YONDAIME
                    SpawnPet index, mapNum, 129
                Case KISAME
                    SpawnPet index, mapNum, 130
                Case KIMIMARU
                    SpawnPet index, mapNum, 131
                Case JIRAYA
                    SpawnPet index, mapNum, 132
                Case TSUNADE
                    SpawnPet index, mapNum, 133
                Case KAKASHI
                    SpawnPet index, mapNum, 134
                Case PAIN
                    SpawnPet index, mapNum, 135
                Case MADARA
                    SpawnPet index, mapNum, 136
                Case TOBI
                    SpawnPet index, mapNum, 137
                Case OROCHIMARU
                    SpawnPet index, mapNum, 138
                Case ITACHI
                    SpawnPet index, mapNum, 249
                Case DEIDARA
                    SpawnPet index, mapNum, 250
                Case HAKU
                    SpawnPet index, mapNum, 139
                Case ZABUZA
                    SpawnPet index, mapNum, 140
                Case BEE
                    SpawnPet index, mapNum, 141
                Case HASHIRAMA
                    SpawnPet index, mapNum, 142
                Case YAMATO
                    SpawnPet index, mapNum, 143
                Case KONAN
                    SpawnPet index, mapNum, 144
                Case RAIKAGE
                    SpawnPet index, mapNum, 145
                Case SASORI
                    SpawnPet index, mapNum, 146
                Case HIDAN
                    SpawnPet index, mapNum, 147
                Case DANZOU
                    SpawnPet index, mapNum, 148
                Case YUGITO
                    SpawnPet index, mapNum, 149
                Case TOBIRAMA
                    SpawnPet index, mapNum, 150
                Case GAI
                    SpawnPet index, mapNum, 151
                Case MEI
                    SpawnPet index, mapNum, 152
                    
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
            
            For i = 1 To 5
                If TempPlayer(index).Dojutsu(i) > 0 Then
                    TirarDojutsu index, i
                End If
            Next
                
                TempPlayer(index).Dojutsu(5) = GetTickCount + 60000
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
            If TempPlayer(index).Reflect > 0 Then Exit Sub
            
            For i = 1 To 5
                If TempPlayer(index).Dojutsu(i) > 0 Then
                    TirarDojutsu index, i
                End If
            Next
            TempPlayer(index).MySprite = GetPlayerSprite(index)
            'SetPlayerStat index, Stats.Intelligence, GetPlayerStat(index, Stats.Intelligence) + 30
            TempPlayer(index).Dojutsu(1) = GetTickCount + 60000
        Case 10 'Magenkyo Sharingan-Sasuke
            If TempPlayer(index).Henge > 0 Then Exit Sub
            If TempPlayer(index).Reflect > 0 Then Exit Sub
            
            For i = 1 To 5
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
                            PlayerAttackPlayer index, Alvo, GetSpellBaseStat(index, SpellNum) / 2.5, SpellNum
                            If GetPlayerClass(index) = SHIKAMARU Then
                                SendAnimation mapNum, 28, 0, 0, TARGET_TYPE_PLAYER, Alvo
                            ElseIf GetPlayerClass(index) = GAARA Then
                                SendAnimation mapNum, 55, 0, 0, TARGET_TYPE_PLAYER, Alvo
                            End If
                        End If
                    End If
                
                Case TARGET_TYPE_NPC
                    If MapNpc(mapNum).Npc(Alvo).StunDuration > 0 Then
                        If CanPlayerAttackNpc(index, Alvo, True) Then
                            PlayerAttackNpc index, Alvo, GetSpellBaseStat(index, SpellNum), SpellNum
                            If GetPlayerClass(index) = SHIKAMARU Then
                                SendAnimation mapNum, 28, 0, 0, TARGET_TYPE_NPC, Alvo
                            ElseIf GetPlayerClass(index) = GAARA Then
                                SendAnimation mapNum, 55, 0, 0, TARGET_TYPE_NPC, Alvo
                            End If
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
            If TempPlayer(index).Henge > 0 Then
                PlayerMsg index, "Henge está ativado..", BrightRed
                Exit Sub
            End If
            
            For i = 1 To 4
                If TempPlayer(index).Dojutsu(i) > 0 Then
                    TirarDojutsu index, i
                End If
            Next
            
            TempPlayer(index).MySprite = GetPlayerSprite(index)
            
            SetPlayerSprite index, 338
            
            SendPlayerData index
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
            TempPlayer(index).Dojutsu(1) = GetTickCount + 60000
            
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
        
            'If TempPlayer(index).Reflect > 0 Then
                'PlayerMsg index, "Susanoo já está ativado!", BrightRed
                'Exit Sub
            'End If
            
            If TempPlayer(index).Reflect <= 0 Then
                TempPlayer(index).MySprite = GetPlayerSprite(index)
            End If
            
            Select Case GetPlayerClass(index)
                Case KAKASHI
                    SetPlayerSprite index, 469
                Case SASUKE
                    Select Case GetPlayerLevel(index)
                        Case 0 To 499
                            SetPlayerSprite index, 165
                        Case 500 To 999
                            SetPlayerSprite index, 166
                        Case 1000 To 1499
                            SetPlayerSprite index, 321
                        Case 1500 To MAX_INTEGER
                            SetPlayerSprite index, 468
                        Case Else
                            SetPlayerSprite index, 165
                    End Select
                    
                Case ITACHI
                    Select Case GetPlayerLevel(index)
                        Case 0 To 499
                            SetPlayerSprite index, 470
                        Case 500 To 999
                            SetPlayerSprite index, 471
                        Case 1000 To 1499
                            SetPlayerSprite index, 472
                        Case 1500 To MAX_INTEGER
                            SetPlayerSprite index, 167
                        Case Else
                            SetPlayerSprite index, 470
                    End Select
                
                Case MADARA
                    Select Case GetPlayerLevel(index)
                        Case 0 To 499
                            SetPlayerSprite index, 464
                        Case 500 To 999
                            SetPlayerSprite index, 465
                        Case 1000 To 1499
                            SetPlayerSprite index, 466
                        Case 1500 To MAX_INTEGER
                            SetPlayerSprite index, 467
                        Case Else
                            SetPlayerSprite index, 464
                    End Select
                    
                Case Else
            End Select
            
            SendPlayerData index
            TempPlayer(index).Reflect = GetTickCount + 120000
        Case 26 'Arrow Sai-RAT
            SendArrow index, 14, GetPlayerX(index), GetPlayerY(index), 8, GetSpellBaseStat(index, SpellNum), 100, , SpellNum
        Case 27 'Arrow Sai-Snake
            SendArrow index, 15, GetPlayerX(index), GetPlayerY(index), 10, GetSpellBaseStat(index, SpellNum), 150, , SpellNum
        Case 28 'Kunai do Yondaime
            SendArrow index, 1, GetPlayerX(index), GetPlayerY(index), 20, GetPlayerDamage(index) / 2, 100, , , YES
        Case 29 'Yondaime-Cravar Destino
            TempPlayer(index).MapTeleport.X = GetPlayerX(index)
            TempPlayer(index).MapTeleport.Y = GetPlayerY(index)
            TempPlayer(index).MapTeleport.Ativo = YES
            PlayerMsg index, "Local gravado com sucesso!", Yellow
        Case 30 'Yondaime Ativar Teleporte
            If Alvo = index And AlvoType = TARGET_TYPE_PLAYER Then
                PlayerMsg index, "Não pode usar em você mesmo!", Red
                Exit Sub
            End If
            
            If TempPlayer(index).MapTeleport.Ativo = NO Then '
                For i = 1 To MAX_PLAYER_PROJECTILES
                    If TempPlayer(index).ProjecTile(i).Especial = YES Then
                        SendAnimation mapNum, 70, 0, 0, TARGET_TYPE_PLAYER, index
                        Player(index).X = TempPlayer(index).ProjecTile(i).X
                        Player(index).Y = TempPlayer(index).ProjecTile(i).Y
                        SendPlayerXYToMap index
                        ClearProjectile index, i
                        OK = YES
                        Exit For
                    End If
                Next
            Else 'Checa pela localidade memorizada
                If TempPlayer(index).MapTeleport.Ativo = YES Then
                    SendAnimation mapNum, 70, 0, 0, TARGET_TYPE_PLAYER, index
                    Player(index).X = TempPlayer(index).MapTeleport.X
                    Player(index).Y = TempPlayer(index).MapTeleport.Y
                    SendPlayerXYToMap index
                    OK = YES
                    TempPlayer(index).MapTeleport.Ativo = NO
                End If
            End If
            
            If OK = NO Then
                PlayerMsg index, "Não há nada pra se teleportar..", Red
            End If
        Case 31 'Yondaime Rasengan
            If Alvo = index And AlvoType = TARGET_TYPE_PLAYER Then
                PlayerMsg index, "Não pode usar em você mesmo!", Red
                Exit Sub
            End If
            
            If Alvo > 0 Then
                Select Case AlvoType
                    Case TARGET_TYPE_PLAYER
                        If CanPlayerAttackPlayer(index, Alvo, True) Then
                            WarpBehind_Player index, Alvo
                            PlayerAttackPlayer index, Alvo, GetSpellBaseStat(index, SpellNum) / 2.5
                            SendAnimation mapNum, 69, 0, 0, TARGET_TYPE_PLAYER, Alvo
                        End If
                    Case TARGET_TYPE_NPC
                        If CanPlayerAttackNpc(index, Alvo, True) Then
                            WarpBehind_Npc index, Alvo
                            PlayerAttackNpc index, Alvo, GetSpellBaseStat(index, SpellNum) / 2.5
                            SendAnimation mapNum, 69, 0, 0, TARGET_TYPE_NPC, Alvo
                        End If
                    Case Else
                End Select
            Else
                PlayerMsg index, "Selecione um alvo antes..", Red
                Exit Sub
            End If
        Case 32 'tubarão
            If TempPlayer(index).Henge > 0 Then
                PlayerMsg index, "Henge está ativado..", BrightRed
                Exit Sub
            End If
            
            For i = 1 To 5
                If TempPlayer(index).Dojutsu(i) > 0 Then
                    TirarDojutsu index, i
                End If
            Next
                
                TempPlayer(index).Dojutsu(5) = GetTickCount + 120000
                TempPlayer(index).MySprite = GetPlayerSprite(index)
                SetPlayerSprite index, 370
                SendPlayerData index
        Case 33 'Flecha deidara Spider
            SendArrow index, 17, GetPlayerX(index), GetPlayerY(index), 20, GetSpellBaseStat(index, SpellNum), 170, 72, SpellNum
        Case 34 'flecha Deidara Owl
            SendArrow index, 18, GetPlayerX(index), GetPlayerY(index), 20, GetSpellBaseStat(index, SpellNum), 100, 72, SpellNum
        Case 35 'Art is Boom ! deidara
            If GetPlayerVital(index, Vitals.HP) < 2 Then
                Call OnDeath(index)
                Exit Sub
            End If
            
            SetPlayerVital index, Vitals.HP, GetPlayerVital(index, Vitals.HP) / 2
            SendVital index, Vitals.HP
            MagiaArea index, SpellNum
        Case 36 'Itachi flecha corvo
            SendArrow index, 19, GetPlayerX(index), GetPlayerY(index), 15, GetSpellBaseStat(index, SpellNum), 100, 81, SpellNum, YES
        Case 37 'Itachi flecha Goukakyuu
            SendArrow index, 22, GetPlayerX(index), GetPlayerY(index), 20, GetSpellBaseStat(index, SpellNum), 100, 79, SpellNum
        Case 38 'Ataque susanoo do itachi
            If Not TempPlayer(index).Reflect > 0 Then
                PlayerMsg index, "Ative o susanoo antes!", Red
                Exit Sub
            End If
            
            MagiaReta index, SpellNum
        Case 39 'Flecha kaguya teshi sendan
            SendArrow index, 23, GetPlayerX(index), GetPlayerY(index), 15, GetSpellBaseStat(index, SpellNum), 25, , SpellNum
        Case 40 'Rasengan jiraya
            
            MagiaReta index, SpellNum
            
            Select Case GetPlayerDir(index)
                
                Case DIR_UP

                    If GetPlayerY(index) = 0 Then Exit Sub
                        X = GetPlayerX(index)
                        Y = GetPlayerY(index) - 1
                Case DIR_DOWN

                    If GetPlayerY(index) = Map(GetPlayerMap(index)).MaxY Then Exit Sub
                        X = GetPlayerX(index)
                        Y = GetPlayerY(index) + 1
                Case DIR_LEFT

                    If GetPlayerX(index) = 0 Then Exit Sub
                        X = GetPlayerX(index) - 1
                        Y = GetPlayerY(index)
                Case DIR_RIGHT

                    If GetPlayerX(index) = Map(GetPlayerMap(index)).MaxX Then Exit Sub
                        X = GetPlayerX(index) + 1
                        Y = GetPlayerY(index)
            End Select
            
            SendAnimation mapNum, 69, X, Y
        Case 41 'Rasengan FLECHA
            SendArrow index, 24, GetPlayerX(index), GetPlayerY(index), 10, GetSpellBaseStat(index, SpellNum), 100, 69, SpellNum
        Case 42 'Jutsu proibido da tsunade,recupera hp
            If GetPlayerVital(index, Vitals.mp) < GetPlayerMaxVital(index, Vitals.mp) / 2 Then
                PlayerMsg index, "Você precisa ter pelo menos metade de seu chakra total. No seu caso seria: " & GetPlayerMaxVital(index, Vitals.mp) / 2 & " de chakra!", Red
                Exit Sub
            End If
            
            If GetPlayerVital(index, Vitals.HP) > GetPlayerMaxVital(index, Vitals.HP) / 2 Then
                PlayerMsg index, "Esse é um jutsu pra ser usado em ultimo caso.Você precisa ter menos que a metade da vida total.", Red
                Exit Sub
            End If
            
            SetPlayerVital index, Vitals.HP, GetPlayerMaxVital(index, Vitals.HP) / 2
            SetPlayerVital index, Vitals.mp, 0
            SendVital index, Vitals.HP
            SendVital index, Vitals.mp
        Case 43 'Flecha tsunade super Punch
            SendArrow index, 25, GetPlayerX(index), GetPlayerY(index), 10, GetSpellBaseStat(index, SpellNum), 100, , SpellNum
        Case 44 'Kakashi Raykiri
            MagiaReta index, SpellNum
            
            If Alvo = index Then Exit Sub
            
            Select Case GetPlayerDir(index)
                
                Case DIR_UP

                    If GetPlayerY(index) = 0 Then Exit Sub
                        X = GetPlayerX(index)
                        Y = GetPlayerY(index) - 1
                Case DIR_DOWN

                    If GetPlayerY(index) = Map(GetPlayerMap(index)).MaxY Then Exit Sub
                        X = GetPlayerX(index)
                        Y = GetPlayerY(index) + 1
                Case DIR_LEFT

                    If GetPlayerX(index) = 0 Then Exit Sub
                        X = GetPlayerX(index) - 1
                        Y = GetPlayerY(index)
                Case DIR_RIGHT

                    If GetPlayerX(index) = Map(GetPlayerMap(index)).MaxX Then Exit Sub
                        X = GetPlayerX(index) + 1
                        Y = GetPlayerY(index)
            End Select
            
            SendAnimation mapNum, 87, X, Y
        Case 45 'Alvo kakashi attack
            If Alvo > 0 Then
                SendAnimation mapNum, 36, GetPlayerX(index), GetPlayerY(index)
                If AlvoType = TARGET_TYPE_PLAYER Then
                    WarpBehind_Player index, Alvo
                    TryPlayerAttackPlayer index, Alvo
                Else
                    WarpBehind_Npc index, Alvo
                    TryPlayerAttackNpc index, Alvo
                End If
            Else
                PlayerMsg index, "Selecione um alvo antes..", Red
            End If
        Case 46 'SharinganCopy
            If TempPlayer(index).SharinganCopy > 0 Then
                PlayerMsg index, "Sharingan copy já está ativado!", Red
                Exit Sub
            End If
            
            SendAnimation mapNum, 5, 0, 0, TARGET_TYPE_PLAYER, index
            TempPlayer(index).SharinganCopy = GetTickCount + 10000
        
        Case 47 'Puxar inimigo-Jutsu do PAIN
            If Map(mapNum).Moral = MAP_MORAL_SAFE Then
                PlayerMsg index, "Você está em uma zona segura. Com grandes poderes,há grandes responsabilidades ;] ", Red
                Exit Sub
            End If
            
            If Alvo > 0 Then
                If AlvoType = TARGET_TYPE_PLAYER Then
                    PuxarPlayer index, Alvo
                Else
                    PuxarNPC index, Alvo
                End If
            Else
                PlayerMsg index, "Selecione um alvo antes..", Red
            End If
        Case 48 'Reflect do Pain,danzoi iza
            If TempPlayer(index).Reflect > 0 Then
                If GetPlayerClass(index) = DANZOU Then
                    PlayerMsg index, "Izanagi já está ativado!", Grey
                    Exit Sub
                Else
                    PlayerMsg index, "Reflect já está ativado!", Grey
                    Exit Sub
                End If
            End If
            
            TempPlayer(index).Reflect = GetTickCount + 5000
        Case 49 'Kusanagi orochimaru
            SendArrow index, 21, GetPlayerX(index), GetPlayerY(index), 10, GetSpellBaseStat(index, SpellNum), 100, , SpellNum, YES
        Case 50 'Edo Tensei
            Select Case RAND(1, 3)
                Case 1
                    SpawnPet index, mapNum, 251
                Case 2
                    SpawnPet index, mapNum, 220
                Case 3
                    SpawnPet index, mapNum, 221
                Case Else
            End Select
        Case 51 'Sharingan Teleport
            TeleporteTobi index
        Case 52 'Teleporte no mapa
            If GetPlayerMap(index) = 57 Then Exit Sub
            If GetPlayerMap(index) = 62 Then Exit Sub
            If GetPlayerMap(index) = 63 Then Exit Sub
            If Map(mapNum).Moral = MAP_MORAL_SAFE Then Exit Sub
            
            SetPlayerX index, RAND(1, Map(mapNum).MaxX)
            SetPlayerY index, RAND(1, Map(mapNum).MaxY)
            SendPlayerXYToMap index
        Case 53 'KAI
            If Not GetPlayerVital(index, Vitals.mp) >= GetPlayerMaxVital(index, Vitals.mp) / 15 Then
                PlayerMsg index, "Você precisa de pelo menos " & GetPlayerMaxVital(index, Vitals.mp) / 15 & " de Chakra pra poder usar KAI!", Red
                Exit Sub
            End If
            
            SetPlayerVital index, Vitals.mp, GetPlayerVital(index, Vitals.mp) / 15
            MapMsg GetPlayerMap(index), GetPlayerName(index) & ":Kai!!", BrightBlue
            TempPlayer(index).StunTimer = NO
            TempPlayer(index).StunDuration = NO
            SendStunned index
        Case 54 'Liberar Chakra- Tirar o delay
            If Not GetPlayerVital(index, Vitals.mp) >= GetPlayerMaxVital(index, Vitals.mp) / 3 Then
                PlayerMsg index, "Você precisa de pelo menos 1/3 do seu Chakra total pra Liberar Chakra!", Red
                Exit Sub
            End If
            
            SetPlayerVital index, Vitals.mp, GetPlayerVital(index, Vitals.mp) / 2
            MapMsg GetPlayerMap(index), GetPlayerName(index) & ":Liberar Chakra!!", BrightBlue
            
            For i = 1 To MAX_DOTS
                With TempPlayer(index).DoT(i)
                    .Used = False
                    .Spell = 0
                    .Timer = 0
                    .Caster = 0
                    .StartTime = 0
                End With
            Next
        Case 55 'jutsu especial haku
        
            SendAnimation GetPlayerMap(index), 115, GetPlayerX(index), GetPlayerY(index)
            
            MagiaArea index, SpellNum
        Case 56 'modo bijuu bee
            If TempPlayer(index).Henge > 0 Then
                PlayerMsg index, "Henge está ativado..", BrightRed
                Exit Sub
            End If
        
            If TempPlayer(index).Reflect > 0 Then
                PlayerMsg index, "já está ativado!", BrightRed
                Exit Sub
            End If
            
            If TempPlayer(index).Dojutsu(4) > 0 Then
                PlayerMsg index, "já está ativado!", BrightRed
                Exit Sub
            End If
            
            TempPlayer(index).MySprite = GetPlayerSprite(index)
            
            SetPlayerSprite index, 318
            
            SendPlayerData index
            TempPlayer(index).Reflect = GetTickCount + 120000
            TempPlayer(index).Dojutsu(4) = GetTickCount + 120000
        Case 57 'konan asas
            If TempPlayer(index).Henge > 0 Then
                PlayerMsg index, "Henge está ativado..", BrightRed
                Exit Sub
            End If
            
            If TempPlayer(index).Dojutsu(4) > 0 Then
                PlayerMsg index, "já está ativado!", BrightRed
                Exit Sub
            End If
            
            TempPlayer(index).MySprite = GetPlayerSprite(index)
            
            SetPlayerSprite index, 361
            
            SendPlayerData index
            TempPlayer(index).Dojutsu(4) = GetTickCount + 120000
        Case 58 'rinnegan
            If TempPlayer(index).Henge > 0 Then
                PlayerMsg index, "Henge está ativado..", BrightRed
                Exit Sub
            End If
            
            For i = 1 To 5
                If TempPlayer(index).Dojutsu(i) > 0 Then
                    TirarDojutsu index, i
                End If
            Next
                
                TempPlayer(index).Dojutsu(5) = GetTickCount + 120000
                SendPlayerData index
        Case 59 'buff raikage
            If TempPlayer(index).Henge > 0 Then
                PlayerMsg index, "Henge está ativado..", BrightRed
                Exit Sub
            End If
            
            If TempPlayer(index).Reflect > 0 Then
                PlayerMsg index, "já está ativado!", BrightRed
                Exit Sub
            End If
            
            For i = 1 To 5
                If TempPlayer(index).Dojutsu(i) > 0 Then
                    TirarDojutsu index, i
                End If
            Next
                
                TempPlayer(index).Dojutsu(4) = GetTickCount + 120000
                TempPlayer(index).Reflect = GetTickCount + 120000
                TempPlayer(index).MySprite = GetPlayerSprite(index)
                SetPlayerSprite index, 372
                SendPlayerData index
        
        Case 60 'raikage direto punch
            MagiaReta index, 275
            WarpFrente index, GetPlayerDir(index), Spell(SpellNum).Dist
        
        Case 61 'Reflect do hidan
            If TempPlayer(index).Henge > 0 Then
                PlayerMsg index, "Henge está ativado..", BrightRed
                Exit Sub
            End If
            
            If TempPlayer(index).Reflect > 0 Then
                PlayerMsg index, "já está ativado!", BrightRed
                Exit Sub
            End If
            
            For i = 1 To 5
                If TempPlayer(index).Dojutsu(i) > 0 Then
                    TirarDojutsu index, i
                End If
            Next
                
                TempPlayer(index).Dojutsu(4) = GetTickCount + 5000
                TempPlayer(index).Reflect = GetTickCount + 5000
                TempPlayer(index).MySprite = GetPlayerSprite(index)
                SetPlayerSprite index, 391
                SendPlayerData index
        
        Case 62 'buff sasori
            If TempPlayer(index).Henge > 0 Then
                PlayerMsg index, "Henge está ativado..", BrightRed
                Exit Sub
            End If
            
            If TempPlayer(index).Reflect > 0 Then
                PlayerMsg index, "já está ativado!", BrightRed
                Exit Sub
            End If
            
            For i = 1 To 5
                If TempPlayer(index).Dojutsu(i) > 0 Then
                    TirarDojutsu index, i
                End If
            Next
                
                TempPlayer(index).Dojutsu(4) = GetTickCount + 120000
                TempPlayer(index).MySprite = GetPlayerSprite(index)
                SetPlayerSprite index, 398
                SendPlayerData index
        
        Case 63 'ataque frontal sasori
            MagiaReta index, 295
            WarpFrente index, GetPlayerDir(index), Spell(SpellNum).Dist
        Case 64 'ataque frontal yugitex
            MagiaReta index, 308
            WarpFrente index, GetPlayerDir(index), Spell(SpellNum).Dist
        Case 65 'buff yugito
            If TempPlayer(index).Henge > 0 Then
                PlayerMsg index, "Henge está ativado..", BrightRed
                Exit Sub
            End If
        
            If TempPlayer(index).Reflect > 0 Then
                PlayerMsg index, "já está ativado!", BrightRed
                Exit Sub
            End If
            
            If TempPlayer(index).Dojutsu(4) > 0 Then
                PlayerMsg index, "já está ativado!", BrightRed
                Exit Sub
            End If
            
            TempPlayer(index).MySprite = GetPlayerSprite(index)
            
            SetPlayerSprite index, 312
            
            SendPlayerData index
            TempPlayer(index).Reflect = GetTickCount + 120000
            TempPlayer(index).Dojutsu(4) = GetTickCount + 120000
        
        Case 66 'arrow yugito
            SendArrow index, 27, GetPlayerX(index), GetPlayerY(index), 10, GetSpellBaseStat(index, SpellNum), 100, , SpellNum, NO
        Case 67 'tobirama flying strike
            MagiaReta index, SpellNum
            WarpFrente index, GetPlayerDir(index), Spell(SpellNum).Dist
            
        Case 68 'summon bijuu
            If Player(index).Rank <> RANK_KAGE Then
                If GetPlayerClass(index) = TOBI Then
                    'se for tobi e não for kage, vai kyuubi
                    SpawnPet index, GetPlayerMap(index), 190
                    Exit Sub
                End If
                
                PlayerMsg index, "Jutsu usado apenas por kages ou tobis.", Red
                Exit Sub
            End If
            
            Select Case Player(index).Vila
                Case 0 'chuva
                    SpawnPet index, GetPlayerMap(index), 195
                Case 1 'konoha kyuubi
                    SpawnPet index, GetPlayerMap(index), 190
                Case 2 'kazekage shukaku
                    SpawnPet index, GetPlayerMap(index), 191
                Case 3 'mizukage sanbi/nibi
                    SpawnPet index, GetPlayerMap(index), 192
                Case 4 'tsuchikage yonbi
                    SpawnPet index, GetPlayerMap(index), 193
                Case 5 'raikage hachibi
                    SpawnPet index, GetPlayerMap(index), 194
                Case 6 'som
                    SpawnPet index, GetPlayerMap(index), 196
                    
                Case Else
                    PlayerMsg index, "Sua vila não existe: " & Player(index).Vila, Yellow
            End Select
        
        Case 69 'gai elbown
            MagiaReta index, 319
            WarpFrente index, GetPlayerDir(index), Spell(SpellNum).Dist
        
        Case 70 'gai death punch
            MagiaReta index, 323
            WarpFrente index, GetPlayerDir(index), Spell(SpellNum).Dist
            
        Case 71 'Buff Mei
            For i = 1 To 4
                If TempPlayer(index).Dojutsu(i) > 0 Then
                    TirarDojutsu index, i
                End If
            Next
            'SetPlayerStat index, Stats.Endurance, GetPlayerStat(index, Stats.Endurance) + 30
            'SetPlayerStat index, Stats.strength, GetPlayerStat(index, Stats.strength) + 30
            'SetPlayerStat index, Stats.Agility, GetPlayerStat(index, Stats.Agility) + 30
            TempPlayer(index).Dojutsu(3) = GetTickCount + 60000
            
Case Else
Call PlayerMsg(index, "YOU GOT RICK ROLLED", Red)
End Select
End Sub

Public Sub TeleporteTobi(ByVal index As Long)
If index < 1 Or index > MAX_PLAYERS Then Exit Sub
If Player(index).InTorneio > 0 Then Exit Sub

Dim Mapa As Long

Mapa = RAND(1, MAX_MAPS)

If Mapa < 1 Or Mapa > MAX_MAPS Then Exit Sub

If Trim$(Map(Mapa).Name) = vbNullString Then
    TeleporteTobi index
    Exit Sub
End If

Select Case Mapa
    Case 100, 98, 95, 296, 297, 298, 299, 300, 294, 94 'torneios
        TeleporteTobi index
        Exit Sub
    Case 82, 83, 84, 85, 86, 154, 155, 156, 221, 222, 223 'area vip
        TeleporteTobi index
        Exit Sub
    Case 198, 72, 195 'atendimento vip
        TeleporteTobi index
        Exit Sub
    Case 295 'ct
        TeleporteTobi index
        Exit Sub
    Case 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68 'CS
        TeleporteTobi index
        Exit Sub
    Case 229, 230, 231, 232, 233, 234, 235, 236, 237, 238 'desafios
        TeleporteTobi index
        Exit Sub
    Case Else
        PlayerWarp index, Mapa, RAND(1, Map(Mapa).MaxX), RAND(1, Map(Mapa).MaxY)
End Select

End Sub
