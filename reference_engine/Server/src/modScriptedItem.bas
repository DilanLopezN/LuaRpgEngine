Attribute VB_Name = "modScriptedItem"
Sub ScriptedItem(ByVal index As Long, ByVal Script As Long, ByVal itemNum As Long)
Dim mapNum, i, Alvo As Long
Dim AlvoType, X, Y As Byte
Dim Ele, Ele2 As String

AlvoType = TempPlayer(index).targetType
Alvo = TempPlayer(index).Target
mapNum = GetPlayerMap(index)
X = GetPlayerX(index)
Y = GetPlayerY(index)

Select Case Script
    Case 1 'Shuriken
        If TempPlayer(index).ArrowTime > 0 Then Exit Sub
        
        TempPlayer(index).ArrowTime = GetTickCount + 1000
        SendArrow index, 7, GetPlayerX(index), GetPlayerY(index), 4, RAND(1, GetPlayerDamage(index) / 10), 100, 29
                        
    
    Case 2 'Kunai
        If TempPlayer(index).ArrowTime > 0 Then Exit Sub
        
        TempPlayer(index).ArrowTime = GetTickCount + 2000
        SendArrow index, 1, GetPlayerX(index), GetPlayerY(index), 6, RAND(1, GetPlayerDamage(index) / 7), 100, 29
    
    
    Case 3 'Senbon
        If TempPlayer(index).ArrowTime > 0 Then Exit Sub
        
        TempPlayer(index).ArrowTime = GetTickCount + 1000
        SendArrow index, 13, GetPlayerX(index), GetPlayerY(index), 10, RAND(1, GetPlayerDamage(index) / 4), 100, 29
        
    Case 4 'Fuuma Shuriken
        If TempPlayer(index).ArrowTime > 0 Then Exit Sub
        
        TempPlayer(index).ArrowTime = GetTickCount + 2000
        SendArrow index, 9, GetPlayerX(index), GetPlayerY(index), 10, RAND(1, GetPlayerDamage(index) / 2), 100, 60
    
    Case 5 'Tarja Explosiva
        If TempPlayer(index).ArrowTime > 0 Then Exit Sub
        
        TempPlayer(index).ArrowTime = GetTickCount + 2000
        SendArrow index, 11, GetPlayerX(index), GetPlayerY(index), 10, RAND(1, GetPlayerDamage(index)), 100, 16
    
    Case 6 'Jutsus Katon
        For i = 1 To 5
            If Player(index).Elemento(i) = 1 Then 'Katon
                
                Select Case itemNum
                    Case 21
                        If Not HasSpell(index, 7) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 7
                            PlayerMsg index, "Jutsu aprendido!", BrightGreen
                        Else
                            PlayerMsg index, "Você ja tem esse jutsu!", BrightGreen
                        End If
                        
                        
                    Case 22
                        If Not HasSpell(index, 8) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 8
                            PlayerMsg index, "Jutsu aprendido!", BrightGreen
                        Else
                            PlayerMsg index, "Você ja tem esse jutsu!", BrightGreen
                        End If
                    Case 23
                        If Not HasSpell(index, 9) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 9
                            PlayerMsg index, "Jutsu aprendido!", BrightGreen
                        Else
                            PlayerMsg index, "Você ja tem esse jutsu!", BrightGreen
                        End If
                    Case 24
                        If Not HasSpell(index, 10) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 10
                            PlayerMsg index, "Jutsu aprendido!", BrightGreen
                        Else
                            PlayerMsg index, "Você ja tem esse jutsu!", BrightGreen
                        End If
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
                              
                Select Case itemNum
                    Case 26
                        If Not HasSpell(index, 11) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 11
                            PlayerMsg index, "Jutsu aprendido!", BrightGreen
                        Else
                            PlayerMsg index, "Você ja tem esse jutsu!", BrightGreen
                        End If
                            
                    Case 27
                        If Not HasSpell(index, 12) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 12
                            PlayerMsg index, "Jutsu aprendido!", BrightGreen
                        Else
                            PlayerMsg index, "Você ja tem esse jutsu!", BrightGreen
                        End If
                    Case 28
                        If Not HasSpell(index, 13) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 13
                            PlayerMsg index, "Jutsu aprendido!", BrightGreen
                        Else
                            PlayerMsg index, "Você ja tem esse jutsu!", BrightGreen
                        End If
                    Case 29
                        If Not HasSpell(index, 14) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 14
                            PlayerMsg index, "Jutsu aprendido!", BrightGreen
                        Else
                            PlayerMsg index, "Você ja tem esse jutsu!", BrightGreen
                        End If
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
                               
                Select Case itemNum
                    Case 31
                        If Not HasSpell(index, 15) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 15
                            PlayerMsg index, "Jutsu aprendido!", BrightGreen
                        Else
                            PlayerMsg index, "Você ja tem esse jutsu!", BrightGreen
                        End If
                    Case 32
                        If Not HasSpell(index, 16) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 16
                            PlayerMsg index, "Jutsu aprendido!", BrightGreen
                        Else
                            PlayerMsg index, "Você ja tem esse jutsu!", BrightGreen
                        End If
                    Case 33
                        If Not HasSpell(index, 17) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 17
                            PlayerMsg index, "Jutsu aprendido!", BrightGreen
                        Else
                            PlayerMsg index, "Você ja tem esse jutsu!", BrightGreen
                        End If
                    Case 34
                        If Not HasSpell(index, 18) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 18
                            PlayerMsg index, "Jutsu aprendido!", BrightGreen
                        Else
                            PlayerMsg index, "Você ja tem esse jutsu!", BrightGreen
                        End If
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
                              
                Select Case itemNum
                    Case 41
                        If Not HasSpell(index, 23) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 23
                            PlayerMsg index, "Jutsu aprendido!", BrightGreen
                        Else
                            PlayerMsg index, "Você ja tem esse jutsu!", BrightGreen
                        End If
                    Case 42
                        If Not HasSpell(index, 24) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 24
                            PlayerMsg index, "Jutsu aprendido!", BrightGreen
                        Else
                            PlayerMsg index, "Você ja tem esse jutsu!", BrightGreen
                        End If
                    Case 43
                        If Not HasSpell(index, 25) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 25
                            PlayerMsg index, "Jutsu aprendido!", BrightGreen
                        Else
                            PlayerMsg index, "Você ja tem esse jutsu!", BrightGreen
                        End If
                    Case 44
                        If Not HasSpell(index, 26) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 26
                            PlayerMsg index, "Jutsu aprendido!", BrightGreen
                        Else
                            PlayerMsg index, "Você ja tem esse jutsu!", BrightGreen
                        End If
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
                
                Select Case itemNum
                    Case 36
                        If Not HasSpell(index, 19) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 19
                            PlayerMsg index, "Jutsu aprendido!", BrightGreen
                        Else
                            PlayerMsg index, "Você ja tem esse jutsu!", BrightGreen
                        End If
                    Case 37
                        If Not HasSpell(index, 20) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 20
                            PlayerMsg index, "Jutsu aprendido!", BrightGreen
                        Else
                            PlayerMsg index, "Você ja tem esse jutsu!", BrightGreen
                        End If
                    Case 38
                        If Not HasSpell(index, 21) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 21
                            PlayerMsg index, "Jutsu aprendido!", BrightGreen
                        Else
                            PlayerMsg index, "Você ja tem esse jutsu!", BrightGreen
                        End If
                    Case 39
                        If Not HasSpell(index, 22) Then
                            SetPlayerSpell index, FindOpenSpellSlot(index), 22
                            PlayerMsg index, "Jutsu aprendido!", BrightGreen
                        Else
                            PlayerMsg index, "Você ja tem esse jutsu!", BrightGreen
                        End If
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
                PlayerUnequipItem index, i
            End If
        Next
        
        ResetarPontos index
        
        If CanTake(index, itemNum, 1) Then TakeItem index, itemNum, 1
        SavePlayer index
    
    Case 12 'Invitar Membro-Nukenin
    PlayerMsg index, "Item desativado", Pink
    Exit Sub
    
    If Not Player(index).Org = ORG_FREE Then Exit Sub
    
        If TempPlayer(index).Target > 0 Then
            If TempPlayer(index).targetType = TARGET_TYPE_PLAYER Then
                If Not Player(TempPlayer(index).Target).Org > 0 Then
                    If Not GetPlayerAccess(TempPlayer(index).Target) > 1 Or GetPlayerAccess(TempPlayer(index).Target) = ADMIN_CREATOR Then
                        'If GetPlayerLevel(TempPlayer(index).Target) >= 100 Then
                            PlayerMsg TempPlayer(index).Target, "Você entrou para a Laços Ninja", BrightCyan
                            GlobalMsg GetPlayerName(TempPlayer(index).Target) & " entrou para a Laços Ninja", BrightCyan
                            Player(TempPlayer(index).Target).Org = ORG_FREE
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
        PlayerMsg index, "Item desativado", Pink
        Exit Sub
    
        If Player(index).OrgAccess < 2 Then
            PlayerMsg index, "Você não tem acesso pra isso!", White
            Exit Sub
        End If
        
        If TempPlayer(index).Target > 0 Then
            If TempPlayer(index).targetType = TARGET_TYPE_PLAYER Then
                tirarOrgMembro index, TempPlayer(index).Target
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
    
    Case 15 'Invitar Membro-Esquadrão
        PlayerMsg index, "Item desativado", Pink
        Exit Sub
    
        If Player(index).OrgAccess < 2 Then
            PlayerMsg index, "Você não tem acesso pra isso!", White
            Exit Sub
        End If
    
        If TempPlayer(index).Target > 0 Then
            If TempPlayer(index).targetType = TARGET_TYPE_PLAYER Then
                setarOrgMembro index, TempPlayer(index).Target
            Else
                PlayerMsg index, "Selecione um PLAYER ", BrightRed
            End If
        Else
            PlayerMsg index, "Selecione o PLAYER que você quer na guild", BrightRed
        End If
        
    Case 16 'Botando classe
        If Alvo < 1 Then Exit Sub
        If Not AlvoType = TARGET_TYPE_PLAYER Then Exit Sub
        If IsNumeric(Item(itemNum).Desc) And Item(itemNum).Desc > Max_Classes Then
            PlayerMsg index, "Classe não existe!", Red
            Exit Sub
        End If
        
        If IsNumeric(Item(itemNum).Desc) Then
            SetarChar Alvo, Val(Item(itemNum).Desc)
        Else
            PlayerMsg index, "A descrição não é numerica..", Red
        End If
    Case 17 'Setar vila
        If Alvo < 1 Then Exit Sub
        If Not AlvoType = TARGET_TYPE_PLAYER Then Exit Sub
        If IsNumeric(Item(itemNum).Desc) = False Then
            PlayerMsg index, "Descrição errada=Vila de 1 a 5", White
            Exit Sub
        End If
        
        If Item(itemNum).Desc > 5 Then
            PlayerMsg index, "Vila não existe!(1 ao 5)", Red
            Exit Sub
        End If
        
        Player(Alvo).Vila = Item(itemNum).Desc
        
        SavePlayer Alvo
        SendPlayerData Alvo
        
    Case 18 'Setar elemento 2
        If Alvo < 1 Then Exit Sub
        If Not AlvoType = TARGET_TYPE_PLAYER Then Exit Sub
        If IsNumeric(Item(itemNum).Desc) = False Then
            PlayerMsg index, "Descrição errada=Elemento de 1 a 5", White
            Exit Sub
        End If
        
        If Item(itemNum).Desc > 5 Then
            PlayerMsg index, "Elemento não existe!(1 ao 5)", Red
            Exit Sub
        End If
        
        PlayerMsg index, "Antigo(2):" & GetElementName(Player(Alvo).Elemento(2)), White
        PlayerMsg Alvo, "Antigo(2):" & GetElementName(Player(Alvo).Elemento(2)), White
        
        Player(Alvo).Elemento(2) = Item(itemNum).Desc
        
        PlayerMsg index, "Novo(2):" & GetElementName(Player(Alvo).Elemento(2)), White
        PlayerMsg Alvo, "Novo(2):" & GetElementName(Player(Alvo).Elemento(2)), White
        
        SavePlayer Alvo
        SendPlayerData Alvo
        
    Case 19 'Setar elemento 3
        If Alvo < 1 Then Exit Sub
        If Not AlvoType = TARGET_TYPE_PLAYER Then Exit Sub
        If IsNumeric(Item(itemNum).Desc) = False Then
            PlayerMsg index, "Descrição errada=Elemento de 1 a 5", White
            Exit Sub
        End If
        
        If Item(itemNum).Desc > 5 Then
            PlayerMsg index, "Elemento não existe!(1 ao 5)", Red
            Exit Sub
        End If
        
        PlayerMsg index, "Antigo(3):" & GetElementName(Player(Alvo).Elemento(3)), White
        PlayerMsg Alvo, "Antigo(3):" & GetElementName(Player(Alvo).Elemento(3)), White
        
        Player(Alvo).Elemento(3) = Item(itemNum).Desc
        
        PlayerMsg index, "Novo(3):" & GetElementName(Player(Alvo).Elemento(3)), White
        PlayerMsg Alvo, "Novo(3):" & GetElementName(Player(Alvo).Elemento(3)), White
        
        SavePlayer Alvo
        SendPlayerData Alvo
    Case 20 'Mutar global por item
        If ShutGlobal = YES Then
            If ShutAll = NO Then
                frmServer.chkMuteAll.Value = YES
                GlobalMsg GetPlayerName(index) & ":Chat Global e Mapa mutados!", BrightRed
            Else
                frmServer.chkShutGlobal.Value = NO
                GlobalMsg GetPlayerName(index) & ":Chat Liberado!", BrightBlue
            End If
        Else
            frmServer.chkShutGlobal.Value = YES
            GlobalMsg GetPlayerName(index) & ":Chat Global mutado!", BrightRed
        End If
    Case 21 'Setar Nome
        Dim F As Long
        
        If IsPlaying(Alvo) = False Or AlvoType <> TARGET_TYPE_PLAYER Then
            PlayerMsg index, "Selecione um player!", Red
            Exit Sub
        End If
        
        If FindChar(Trim$(Item(itemNum).Desc)) Then
            PlayerMsg index, "Esse nick já está em uso. Indisponível!", BrightRed
            PlayerMsg Alvo, "Esse nick já está em uso. Escolha outro por favor!", BrightRed
            Exit Sub
        End If
        
        Player(Alvo).Name = Trim$(Item(itemNum).Desc)
        SendPlayerData Alvo
        
         ' Append name to file
        F = FreeFile
        Open App.Path & "\data\accounts\charlist.txt" For Append As #F
        Print #F, Trim$(Item(itemNum).Desc)
        Close #F
    Case 22 'Elemento 1
        TakeInvItem index, itemNum, 1
        ClearElementJutsus index, 1
        GiveElement index, 1
    Case 23 'Elemento 2
        If Player(index).Elemento(2) = NO Then
            PlayerMsg index, "Você não têm segundo elemento!", Red
            Exit Sub
        End If
        
        TakeInvItem index, itemNum, 1
        ClearElementJutsus index, 2
        GiveElement index, 2
    Case 24 'Elemento 3
        If Player(index).Elemento(3) = NO Then
            PlayerMsg index, "Você não têm terceiro elemento!", Red
            Exit Sub
        End If
        
        TakeInvItem index, itemNum, 1
        ClearElementJutsus index, 3
        GiveElement index, 3
    Case 25 'setarchar Naruto
        SetarChar index, NARUTO, itemNum
        
    Case 26 'setarchar sasuke
        SetarChar index, SASUKE, itemNum
        
    Case 27 'setarchar Sakura
        SetarChar index, SAKURA, itemNum
        
    Case 28 'setarchar ino
        SetarChar index, INO, itemNum
        
    Case 29 'setarchar shikamaru
        SetarChar index, SHIKAMARU, itemNum
        
    Case 30 'setarchar choujI
        SetarChar index, CHOUJI, itemNum
        
    Case 31 'setarchar Lee
        SetarChar index, LEE, itemNum
        
    Case 32 'setarchar Neji
        SetarChar index, NEJI, itemNum
        
    Case 33 'setarchar tenten
        SetarChar index, TENTEN, itemNum
        
    Case 34 'setarchar kiba
        SetarChar index, KIBA, itemNum
        
    Case 35 'setarchar shino
        SetarChar index, SHINO, itemNum
        
    Case 36 'setarchar gaara
        SetarChar index, GAARA, itemNum
        
    Case 37 'setarchar kankurou
        SetarChar index, KANKUROU, itemNum
        
    Case 38 'setarchar temari
        SetarChar index, TEMARI, itemNum
        
    Case 39 'setarchar hinata
        SetarChar index, HINATA, itemNum
        
    Case 40 'setarchar Sai
        SetarChar index, SAI, itemNum
        
    Case 41 'setarchar kisame
        SetarChar index, KISAME, itemNum
        
    Case 42 'setarchar deidara
        SetarChar index, DEIDARA, itemNum
        
    Case 43 'setarchar kimimaru
        SetarChar index, KIMIMARU, itemNum
        
    Case 44 'setarchar jiraya
        SetarChar index, JIRAYA, itemNum
        
    Case 45 'setarchar tsunade
        SetarChar index, TSUNADE, itemNum
        
    Case 46 'setarchar kakashi
        SetarChar index, KAKASHI, itemNum
        
    Case 47 'setarchar yondaime
        SetarChar index, YONDAIME, itemNum
        
    Case 48 'setarchar orochimaru
        SetarChar index, OROCHIMARU, itemNum
        
    Case 49 'setarchar tobi
        SetarChar index, TOBI, itemNum
        
    Case 50 'setarchar haku
        SetarChar index, HAKU, itemNum
        
    Case 51 'setarchar zabuza
        SetarChar index, ZABUZA, itemNum
        
    Case 52 'shutdown
        For i = 1 To Player_HighIndex
            SavePlayer i
            PlayerMsg i, "Sua conta foi salva!", BrightGreen
        Next
        
        isShuttingDown = True
    Case 53 'setarchar bee
        SetarChar index, BEE, itemNum
        
    Case 54 'sortear vila
        If Weekday(Now) = 7 Then
            If Hour(Now) = 18 Or Hour(Now) = 19 Then
                PlayerMsg index, "O sorteio de vila não pode ser usado nas 18 e 19 horas do sábado pra evitar que mudem de vila no ks.", BrightRed
                Exit Sub
            End If
        End If
        
        If Player(index).Rank = RANK_KAGE Then
            PlayerMsg index, "Kages não podem mudar de vila", BrightRed
            Exit Sub
        End If
        
        If Torneio > 0 Then
            PlayerMsg index, "Não pode usar nesse momento pois ta tendo evento/shiken", BrightRed
            Exit Sub
        End If
        
        If Player(index).Rank = RANK_DESERTOR Then
            If Player(index).Vila = 0 Then
                Player(index).Vila = 6
                PlayerMsg index, "Agora você é da vila do Som!", White
            Else
                Player(index).Vila = 0
                PlayerMsg index, "Agora você é da vila da Chuva!", White
            End If
        Else
            SortearVila index
        End If
        
        TakeInvItem index, itemNum, 1
    Case 55 'setarchar itachi
        SetarChar index, ITACHI, itemNum
        
    Case 56 'setarchar madara
        SetarChar index, MADARA, itemNum
        
    Case 57 'setarchar pain
        SetarChar index, PAIN, itemNum
        
    Case 58 'setarchar hashirama
        SetarChar index, HASHIRAMA, itemNum
        
    Case 59 'setarchar yamato
        SetarChar index, YAMATO, itemNum
        
    Case 60 'setarchar konan
        SetarChar index, KONAN, itemNum
    Case 61 'setarchar raikage
        SetarChar index, RAIKAGE, itemNum
    Case 62 'setarchar darui
        SetarChar index, DARUI, itemNum
    Case 63 'setarchar hidan
        SetarChar index, HIDAN, itemNum
    Case 64 'setarchar sasori
        SetarChar index, SASORI, itemNum
    Case 65 'setarchar danzou
        SetarChar index, DANZOU, itemNum
    Case 66 'criar org
        If GetPlayerAccess(index) < 3 Then Exit Sub
        
        If Trim$(Item(itemNum).Desc) < 13 Or Trim$(Item(itemNum).Desc) > 100 Then Exit Sub
        If TempPlayer(index).targetType <> TARGET_TYPE_PLAYER Then
            PlayerMsg index, "Selecione um player!", White
            Exit Sub
        End If
        
        If Org(Trim$(Item(itemNum).Desc)).orgCarregada = NO Then
            criarOrg TempPlayer(index).Target, Trim$(Item(itemNum).Desc)
            OrgJutsu TempPlayer(index).Target, ORG_ESQUADRAO
            PlayerMsg index, "Criada com sucesso!", BrightGreen
        End If
    Case 67 'tirarmembrosoffline
        If Player(index).OrgAccess < 2 Then Exit Sub
        
        tirarMembrosOffline index
    Case 68 'mostrar org
        If Player(index).Org < 13 Or Player(index).Org > 100 Then Exit Sub
        
        membrosOnlineOrg index
    
    Case 69 'kikar conta por alvo
        If GetPlayerAccess(index) < 2 Then Exit Sub
        If AlvoType <> TARGET_TYPE_PLAYER Then
            PlayerMsg index, "Selecione um player!", BrightCyan
            Exit Sub
        End If
        
        If IsPlaying(Alvo) = False Then
            PlayerMsg index, "Player ta off.", White
            Exit Sub
        End If
        
        AlertMsg Alvo, "Você foi kikado por:" & GetPlayerName(index)
    
    Case 70 'setar jutsu especial
        If GetPlayerAccess(index) < 3 Then Exit Sub
        
        If TempPlayer(index).targetType <> TARGET_TYPE_PLAYER Then
            PlayerMsg index, "Selecione um player!", White
            Exit Sub
        End If
        
        OrgJutsu TempPlayer(index).Target, ORG_ESQUADRAO
    
    Case 71 'setarchar yugito
        SetarChar index, YUGITO, itemNum
    
    Case 72 'transformar acesso org em sub lider
        If Alvo > 0 Then
            If AlvoType = TARGET_TYPE_PLAYER Then
                If Player(index).OrgAccess >= 3 Then
                    If Player(index).Org >= 13 And Player(index).Org < 100 Then
                        If Org(Player(index).Org).orgCarregada = YES Then
                            'For i = 2 To MAX_ORG_MEMBERS
                                'If Org(Player(index).Org).MembroAcesso(i) > 1 Then
                                    'PlayerMsg index, "Já existe um sub-líder, é o " & Trim$(Org(Player(index).Org).MembroNome(i)) & "!", White
                                    'Exit Sub
                                'End If
                            'Next
                            setarOrgAcesso index, Alvo, 2
                        Else
                            PlayerMsg index, "A org não ta carregada!", BrightRed
                        End If
                    Else
                        PlayerMsg index, "Org não ta certa..", BrightRed
                    End If
                Else
                    PlayerMsg index, "Você não é líder.", BrightRed
                End If
            Else
                PlayerMsg index, "Selecione um PLAYER!", BrightRed
            End If
        Else
            PlayerMsg index, "Selecione um jogador!", BrightRed
        End If
    Case 73 'mudar de lider
        Dim orgN As Long
        
        If GetPlayerAccess(index) < 3 Then Exit Sub
        
        If AlvoType <> TARGET_TYPE_PLAYER Then
            PlayerMsg index, "Selecione um player!", White
            Exit Sub
        End If
        
        If IsPlaying(Alvo) = False Then Exit Sub
        
        If Player(Alvo).Org > 0 Then
            PlayerMsg index, "Ele ja tem org!", BrightRed
            Exit Sub
        End If
        
        If IsNumeric(Trim$(Item(itemNum).Desc)) = False Then
            PlayerMsg index, "Coloque o numero da ORG na descrição!", BrightRed
            Exit Sub
        End If
        
        orgN = Trim$(Item(itemNum).Desc)
        
        If orgN < 13 Or orgN > 100 Then
            PlayerMsg index, "Coloque um numero de org válido.", BrightRed
            Exit Sub
        End If
        
        If Org(orgN).orgCarregada = NO Then
            PlayerMsg index, "Org não ta carregada!", BrightRed
            Exit Sub
        End If
        
        Player(Alvo).Org = orgN
        Player(Alvo).OrgAccess = 3
        
        Org(orgN).MembroLogin(1) = GetPlayerLogin(Alvo)
        Org(orgN).MembroNome(1) = GetPlayerName(Alvo)
        Org(orgN).MembroAcesso(1) = 3
        
        OrgJutsu Alvo, ORG_ESQUADRAO
        SavePlayer Alvo
        saveOrg orgN
        
        PlayerMsg index, "com sucesso!", BrightGreen
    Case 74 'setarchar tobirama
        SetarChar index, TOBIRAMA, itemNum
    Case 75 'inverter karma
        Player(index).Karma = Player(index).Karma * -1
        PlayerMsg index, "Seu karma foi invertido com sucesso!", BrightBlue
        TakeInvItem index, itemNum, 1
        SendPlayerData index
    Case 76 'setarchar gai
        SetarChar index, GAI, itemNum
    Case 77 'setarchar mei
        SetarChar index, MEI, itemNum
    Case 78 'resetar os bugados
        If Alvo < 1 Or Alvo > MAX_PLAYERS Or GetPlayerAccess(index) < ADMIN_CREATOR Then Exit Sub
    
        Player(Alvo).Restarted = NO
        RestartGameForPlayer (Alvo)
        
Case Else
Call PlayerMsg(index, "YOU GOT RICK ROLLED", Red)
End Select
End Sub
