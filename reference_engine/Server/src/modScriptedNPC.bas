Attribute VB_Name = "modScriptedNPC"
Sub ScriptedNpc(ByVal index As Long, ByVal Script As Long, ByVal mapNpcNum As Long)
'On Error Resume Next
Dim i, NpcNum As Long

NpcNum = MapNpc(GetPlayerMap(index)).Npc(mapNpcNum).num
If NpcNum < 1 Or NpcNum > MAX_NPCS Then Exit Sub

For i = 1 To 10
    If Player(index).QuestNum(i) > 0 Then
       If Player(index).QuestInfo(i).Status = 2 Then
          If Player(index).QuestInfo(i).QuestNpc(i) = NpcNum Then
             SendPicFala index, Quest(Player(index).QuestNum(i)).Msg(2), NpcNum
          End If
       End If
       
       If Player(index).QuestInfo(i).Status = 3 Then
          If Player(index).QuestInfo(i).QuestNpc(i) = NpcNum Then
             SendPicFala index, Quest(Player(index).QuestNum(i)).Msg(3), NpcNum
             QuestCompleta index, i
          End If
       End If
    End If
Next

Select Case Script
    Case 1 'Iruka,Teste genin,etc..
         StartQuest index, 1, NpcNum
         StartQuest index, 2, NpcNum
         StartQuest index, 3, NpcNum
         

    Case 2 'Missões-Kakashi
        'RankD
        StartQuest index, 6, 242
        StartQuest index, 7, 242
        StartQuest index, 8, 242
        StartQuest index, 9, 242
        StartQuest index, 10, 242
        StartQuest index, 11, 242
        StartQuest index, 12, 242
        StartQuest index, 13, 242
        StartQuest index, 14, 242
        StartQuest index, 15, 242
        StartQuest index, 16, 242
        'RankC
        StartQuest index, 18, 242
        StartQuest index, 19, 242
        StartQuest index, 20, 242
        StartQuest index, 21, 242
        StartQuest index, 22, 242
        StartQuest index, 23, 242
        StartQuest index, 24, 242
        StartQuest index, 25, 242
        StartQuest index, 26, 242
        StartQuest index, 27, 242
        StartQuest index, 28, 242
        'RankB
        StartQuest index, 30, 242
        StartQuest index, 31, 242
        StartQuest index, 32, 242
        StartQuest index, 33, 242
        StartQuest index, 34, 242
        StartQuest index, 35, 242
        StartQuest index, 36, 242
        StartQuest index, 37, 242
        StartQuest index, 38, 242
        StartQuest index, 39, 242
        StartQuest index, 40, 242
        StartQuest index, 41, 242
        StartQuest index, 42, 242
        StartQuest index, 43, 242
        StartQuest index, 44, 242
        StartQuest index, 45, 242
       
    
    Case 3 'Missões-Outras vilas
        'RankD
        StartQuest index, 6, 241
        StartQuest index, 7, 241
        StartQuest index, 8, 241
        StartQuest index, 9, 241
        StartQuest index, 10, 241
        StartQuest index, 11, 241
        StartQuest index, 12, 241
        StartQuest index, 13, 241
        StartQuest index, 14, 241
        StartQuest index, 15, 241
        StartQuest index, 16, 241
        'RankC
        StartQuest index, 18, 241
        StartQuest index, 19, 241
        StartQuest index, 20, 241
        StartQuest index, 21, 241
        StartQuest index, 22, 241
        StartQuest index, 23, 241
        StartQuest index, 24, 241
        StartQuest index, 25, 241
    
    Case 4 'Anko-Quest Chunin
            If Not Player(index).Rank = RANK_GENIN Then
                PlayerMsg index, "Apenas Gennin's!", Red
                Exit Sub
            End If
            
            If Torneio = TORNEIO_CS And frmServer.chkTorneioStatus.Value = YES Then
                
                If GetPlayerLevel(index) >= 100 Then
                    StartQuest index, 4
                Else
                    PlayerMsg index, "Você precisa ser no mínimo level 100!", BrightRed
                End If
            Else
                PlayerMsg index, "No momento não está tendo Chunin Shiken.", BrightRed
            End If
        
        
    Case 5 'Loja CASH
        SendOpenShop index, 10
        TempPlayer(index).InShop = 10
        PlayerMsg index, "Bem vindo!", BrightGreen
    Case 6 'Shinobi Corrupto
    
        If TempPlayer(index).QuestAviso(NpcNum) = NO Then
                PlayerMsg index, "Eu faço desertores voltar pra uma vila aleatória e como Jounin!", BrightGreen
                PlayerMsg index, "Para isso,cobro uma taxa de 5k CASH.Se você quizer ,vá em frente mas não terá reembolso!", BrightGreen
                TempPlayer(index).QuestAviso(NpcNum) = YES
                Exit Sub
        End If
        
        TempPlayer(index).QuestAviso(NpcNum) = NO
        
        If Player(index).Rank = RANK_KAGE Then
            PlayerMsg index, "Não é permitido com seu rank!Fale com ADM se quizer mesmo.", Red
            Exit Sub
        End If
        
        If Player(index).Vila <> 0 And Player(index).Vila <> 6 Then
            PlayerMsg index, "Você não é desertor,suma maldito!", BrightRed
            Exit Sub
        End If
        
        If Player(index).Org > 0 Then
            PlayerMsg index, "Pra usar esse serviço,precisa estar sem Org!", BrightRed
            Exit Sub
        End If
    
        If CanTake(index, 254, 5000) Then
            If Player(index).Elemento(2) = NO Then
                GiveElement index, 2
            End If
            
            Select Case RAND(1, 5)
                    Case 1 'Konoha
                        Player(index).Vila = 1
                        Player(index).Rank = RANK_JOUNIN
                        TakeItem index, 254, 5000
                        PlayerMsg index, "Agora você é da vila Konoha!", Green
                        PlayerMsg index, "Custou 5k cash!", White
                        SendPlayerData index
                    Case 2 'Suna
                        Player(index).Vila = 2
                        Player(index).Rank = RANK_JOUNIN
                        TakeItem index, 254, 5000
                        PlayerMsg index, "Agora você é da vila Suna!", Green
                        PlayerMsg index, "Custou 5k cash!", White
                        SendPlayerData index
                    Case 3 'Kiri
                        Player(index).Vila = 3
                        Player(index).Rank = RANK_JOUNIN
                        TakeItem index, 254, 5000
                        PlayerMsg index, "Agora você é da vila Kiri!", Green
                        PlayerMsg index, "Custou 5k cash!", White
                    Case 4 'Iwa
                        Player(index).Vila = 4
                        Player(index).Rank = RANK_JOUNIN
                        TakeItem index, 254, 5000
                        PlayerMsg index, "Agora você é da vila Iwa!", Green
                        PlayerMsg index, "Custou 5k cash!", White
                        SendPlayerData index
                    Case 5 'Kumo
                        Player(index).Vila = 5
                        Player(index).Rank = RANK_JOUNIN
                        TakeItem index, 254, 5000
                        PlayerMsg index, "Agora você é da vila Kumo!", Green
                        PlayerMsg index, "Custou 5k cash!", White
                        SendPlayerData index
                    Case Else
                        'Konoha
                        Player(index).Vila = 1
                        Player(index).Rank = RANK_JOUNIN
                        TakeItem index, 254, 5000
                        PlayerMsg index, "Agora você é da vila Konoha!", Green
                        PlayerMsg index, "Custou 5k cash!", White
                        SendPlayerData index
            End Select
        Else
            PlayerMsg index, "Preciso de 5k CASH pra fazer algo :| ", BrightRed
        End If
        
    Case 7 'Itachi(Akatsuki)
        If TempPlayer(index).QuestAviso(NpcNum) = NO Then
            PlayerMsg index, "Para fazer o teste da Akatsuki,é cobrado 5k CASH!", BrightGreen
            PlayerMsg index, "Se você ainda quer fazê-lo,fale comigo denovo!", BrightGreen
            TempPlayer(index).QuestAviso(NpcNum) = YES
            Exit Sub
        End If
        
        TempPlayer(index).QuestAviso(NpcNum) = NO
        
        If GetPlayerLevel(index) < 500 Then
            PlayerMsg index, "Apenas lvl 500+", BrightRed
            Exit Sub
        End If
        
        If Player(index).Org > 0 Then
            PlayerMsg index, "Pra fazer o teste,você não pode estar em uma org!", BrightRed
            Exit Sub
        End If
        
        For i = 1 To 10
            If Player(index).QuestNum(i) >= 47 And Player(index).QuestNum(i) <= 53 Then
                PlayerMsg index, "Você já está com um teste de Org ativado..", BrightRed
                Exit Sub
            End If
        Next
        
        For i = 1 To 10
            If Player(index).QuestNum(i) >= 108 And Player(index).QuestNum(i) <= 110 Then
                PlayerMsg index, "Você já está com um teste de RANK ativado..", BrightRed
                Exit Sub
            End If
        Next
        
        StartQuest index, 47, 226
    Case 8 'Sasuke(Taka)
        If TempPlayer(index).QuestAviso(NpcNum) = NO Then
            PlayerMsg index, "Para fazer o teste da Taka,é cobrado 5k CASH!", BrightGreen
            PlayerMsg index, "Se você ainda quer fazê-lo,fale comigo denovo!", BrightGreen
            TempPlayer(index).QuestAviso(NpcNum) = YES
            Exit Sub
        End If
        
        TempPlayer(index).QuestAviso(NpcNum) = NO
        
        If GetPlayerLevel(index) < 300 Then
            PlayerMsg index, "Apenas lvl 300+", BrightRed
            Exit Sub
        End If
        
        If Player(index).Org > 0 Then
            PlayerMsg index, "Pra fazer o teste,você não pode estar em uma org!", BrightRed
            Exit Sub
        End If
        
        For i = 1 To 10
            If Player(index).QuestNum(i) >= 47 And Player(index).QuestNum(i) <= 53 Then
                PlayerMsg index, "Você já está com um teste de Org ativado..", BrightRed
                Exit Sub
            End If
        Next
        
        For i = 1 To 10
            If Player(index).QuestNum(i) >= 108 And Player(index).QuestNum(i) <= 110 Then
                PlayerMsg index, "Você já está com um teste de RANK ativado..", BrightRed
                Exit Sub
            End If
        Next
        
        StartQuest index, 48, 227
       
    Case 9 'Zabuza(espadachins)
        If TempPlayer(index).QuestAviso(NpcNum) = NO Then
            PlayerMsg index, "Para fazer o teste da Espadachins da Névoa,é cobrado 5k CASH!", BrightGreen
            PlayerMsg index, "Se você ainda quer fazê-lo,fale comigo denovo!", BrightGreen
            TempPlayer(index).QuestAviso(NpcNum) = YES
            Exit Sub
        End If
        
        TempPlayer(index).QuestAviso(NpcNum) = NO
        
        If GetPlayerLevel(index) < 150 Then
            PlayerMsg index, "Apenas lvl 150+", BrightRed
            Exit Sub
        End If
        
        If Player(index).Org > 0 Then
            PlayerMsg index, "Pra fazer o teste,você não pode estar em uma org!", BrightRed
            Exit Sub
        End If
        
        For i = 1 To 10
            If Player(index).QuestNum(i) >= 47 And Player(index).QuestNum(i) <= 53 Then
                PlayerMsg index, "Você já está com um teste de Org ativado..", BrightRed
                Exit Sub
            End If
        Next
        
        For i = 1 To 10
            If Player(index).QuestNum(i) >= 108 And Player(index).QuestNum(i) <= 110 Then
                PlayerMsg index, "Você já está com um teste de RANK ativado..", BrightRed
                Exit Sub
            End If
        Next
        
        StartQuest index, 49, 228
        
    Case 10 'Sakura(hospital)
        If TempPlayer(index).QuestAviso(NpcNum) = NO Then
            PlayerMsg index, "Para fazer o teste do Hospital,é cobrado 5k CASH!", BrightGreen
            PlayerMsg index, "Se você ainda quer fazê-lo,fale comigo denovo!", BrightGreen
            TempPlayer(index).QuestAviso(NpcNum) = YES
            Exit Sub
        End If
        
        TempPlayer(index).QuestAviso(NpcNum) = NO
        
        If Player(index).Rank = RANK_DESERTOR Or Player(index).Vila = NO Then
            PlayerMsg index, "Desertores não podem participar!", Red
            Exit Sub
        End If
        
        If GetPlayerLevel(index) < 150 Then
            PlayerMsg index, "Apenas lvl 150+", BrightRed
            Exit Sub
        End If
        
        If Player(index).Org > 0 Then
            PlayerMsg index, "Pra fazer o teste,você não pode estar em uma org!", BrightRed
            Exit Sub
        End If
        
        For i = 1 To 10
            If Player(index).QuestNum(i) >= 47 And Player(index).QuestNum(i) <= 53 Then
                PlayerMsg index, "Você já está com um teste de Org ativado..", BrightRed
                Exit Sub
            End If
        Next
        
        For i = 1 To 10
            If Player(index).QuestNum(i) >= 108 And Player(index).QuestNum(i) <= 110 Then
                PlayerMsg index, "Você já está com um teste de RANK ativado..", BrightRed
                Exit Sub
            End If
        Next
        
        StartQuest index, 50, 229
        
    Case 11 'Sai(anbu raiz)
        If TempPlayer(index).QuestAviso(NpcNum) = NO Then
            PlayerMsg index, "Para fazer o teste da ANBU Raíz,é cobrado 5k CASH!", BrightGreen
            PlayerMsg index, "Se você ainda quer fazê-lo,fale comigo denovo!", BrightGreen
            TempPlayer(index).QuestAviso(NpcNum) = YES
            Exit Sub
        End If
        
        TempPlayer(index).QuestAviso(NpcNum) = NO
        
        If GetPlayerLevel(index) < 300 Then
            PlayerMsg index, "Apenas lvl 300+", BrightRed
            Exit Sub
        End If
        
        If Player(index).Rank = RANK_DESERTOR Or Player(index).Vila = NO Then
            PlayerMsg index, "Desertores não podem participar!", Red
            Exit Sub
        End If
        
        If Player(index).Org > 0 Then
            PlayerMsg index, "Pra fazer o teste,você não pode estar em uma org!", BrightRed
            Exit Sub
        End If
        
        For i = 1 To 10
            If Player(index).QuestNum(i) >= 47 And Player(index).QuestNum(i) <= 53 Then
                PlayerMsg index, "Você já está com um teste de Org ativado..", BrightRed
                Exit Sub
            End If
        Next
        
        For i = 1 To 10
            If Player(index).QuestNum(i) >= 108 And Player(index).QuestNum(i) <= 110 Then
                PlayerMsg index, "Você já está com um teste de RANK ativado..", BrightRed
                Exit Sub
            End If
        Next
        
        StartQuest index, 51, 230
       
    Case 12 'Policial
        If TempPlayer(index).QuestAviso(NpcNum) = NO Then
            PlayerMsg index, "Para fazer o teste dos Policiais de Konoha,precisa ser Uchiha e de Konoha.Não custa nada!", BrightGreen
            PlayerMsg index, "Se você ainda quer fazê-lo,fale comigo denovo!", BrightGreen
            TempPlayer(index).QuestAviso(NpcNum) = YES
            Exit Sub
        End If
        
        TempPlayer(index).QuestAviso(NpcNum) = NO
        
        If Player(index).Rank = RANK_DESERTOR Or Player(index).Vila = NO Then
            PlayerMsg index, "Desertores não podem participar!", Red
            Exit Sub
        End If
        
        If Player(index).Org > 0 Then
            PlayerMsg index, "Pra fazer o teste,você não pode estar em uma org!", BrightRed
            Exit Sub
        End If
        
        For i = 1 To 10
            If Player(index).QuestNum(i) >= 47 And Player(index).QuestNum(i) <= 53 Then
                PlayerMsg index, "Você já está com um teste de Org ativado..", BrightRed
                Exit Sub
            End If
        Next
        
        For i = 1 To 10
            If Player(index).QuestNum(i) >= 108 And Player(index).QuestNum(i) <= 110 Then
                PlayerMsg index, "Você já está com um teste de RANK ativado..", BrightRed
                Exit Sub
            End If
        Next
        
        StartQuest index, 52, 231
        
    Case 13 'Guardião
        If TempPlayer(index).QuestAviso(NpcNum) = NO Then
            PlayerMsg index, "Para fazer o teste dos Guardiões,é cobrado 5k CASH!", BrightGreen
            PlayerMsg index, "Se você ainda quer fazê-lo,fale comigo denovo!", BrightGreen
            TempPlayer(index).QuestAviso(NpcNum) = YES
            Exit Sub
        End If
        
        TempPlayer(index).QuestAviso(NpcNum) = NO
        
        If GetPlayerLevel(index) < 500 Then
            PlayerMsg index, "Apenas lvl 500+", BrightRed
            Exit Sub
        End If
        
        If Player(index).Rank = RANK_DESERTOR Or Player(index).Vila = NO Then
            PlayerMsg index, "Desertores não podem participar!", Red
            Exit Sub
        End If
        
        If Player(index).Org > 0 Then
            PlayerMsg index, "Pra fazer o teste,você não pode estar em uma org!", BrightRed
            Exit Sub
        End If
        
        For i = 1 To 10
            If Player(index).QuestNum(i) >= 47 And Player(index).QuestNum(i) <= 53 Then
                PlayerMsg index, "Você já está com um teste de Org ativado..", BrightRed
                Exit Sub
            End If
        Next
        
        For i = 1 To 10
            If Player(index).QuestNum(i) >= 108 And Player(index).QuestNum(i) <= 110 Then
                PlayerMsg index, "Você já está com um teste de RANK ativado..", BrightRed
                Exit Sub
            End If
        Next
        
        StartQuest index, 53, 232
      
    Case 14 'Laços Ninja
        If TempPlayer(index).QuestAviso(NpcNum) = NO Then
            PlayerMsg index, "Para fazer o teste da Laços Ninja,você precisa ser level 100.Não custa nada!", BrightGreen
            PlayerMsg index, "Se você ainda quer entrar,fale comigo denovo!", BrightGreen
            TempPlayer(index).QuestAviso(NpcNum) = YES
            Exit Sub
        End If
        
        TempPlayer(index).QuestAviso(NpcNum) = NO
        
        If Player(index).Org = ORG_FREE Then
            If Player(index).Resets > 0 And GetPlayerLevel(index) > 800 Then
                PlayerMsg index, "Você é muito forte para org Laços Ninja.", BrightRed
                Exit Sub
            End If
        End If
        
        If GetPlayerLevel(index) < 100 Then
            PlayerMsg index, "Apenas lvl 100+", BrightRed
            Exit Sub
        End If
        
        If Player(index).Org > 0 Then
            PlayerMsg index, "Pra fazer o teste,você não pode estar em uma org!", BrightRed
            Exit Sub
        End If
        
        If TempPlayer(index).inParty > 0 Then
            PlayerMsg index, "Pra fazer o teste,você não pode estar em grupo!", BrightRed
            Exit Sub
        End If
        
        For i = 1 To 10
            If Player(index).QuestNum(i) >= 47 And Player(index).QuestNum(i) <= 53 Then
                PlayerMsg index, "Você já está com um teste de Org ativado..", BrightRed
                Exit Sub
            End If
        Next
        
        Player(index).Org = ORG_FREE
        SendPlayerData index
        GlobalMsg GetPlayerName(index) & " entrou pra Laços Ninja.", Green
    Case 15 'Loja de armas
        SendOpenShop index, 3
        TempPlayer(index).InShop = 3
    Case 16 'Org do Bem
        If Player(index).Org <> ORG_HOSPITAL And Player(index).Org <> ORG_POLICIAKONOHA And Player(index).Org <> ORG_ANBURAIZ And Player(index).Org <> ORG_12GUARDIOES Then
            PlayerMsg index, "Pra fazer essas missões,não pode ser desertor e precisa ser de uma org passiva(menos Laços Ninja).", Grey
            Exit Sub
        End If
        
        StartQuest index, 55, NpcNum
        StartQuest index, 56, NpcNum 'Bem
        StartQuest index, 58, NpcNum
        StartQuest index, 59, NpcNum
        StartQuest index, 60, NpcNum 'Bem
        StartQuest index, 62, NpcNum
        StartQuest index, 63, NpcNum
        StartQuest index, 64, NpcNum 'bem
        StartQuest index, 66, NpcNum
        StartQuest index, 67, NpcNum
        StartQuest index, 68, NpcNum 'bem
        StartQuest index, 70, NpcNum
        StartQuest index, 71, NpcNum
        StartQuest index, 72, NpcNum
        StartQuest index, 73, NpcNum 'bem
        StartQuest index, 75, NpcNum
        StartQuest index, 76, NpcNum
        StartQuest index, 77, NpcNum 'bem
        StartQuest index, 79, NpcNum
        StartQuest index, 80, NpcNum
        StartQuest index, 81, NpcNum 'bem
        StartQuest index, 83, NpcNum
        StartQuest index, 84, NpcNum
        StartQuest index, 85, NpcNum 'bem
        StartQuest index, 87, NpcNum
        StartQuest index, 88, NpcNum
        StartQuest index, 89, NpcNum 'bem
        StartQuest index, 91, NpcNum
        StartQuest index, 92, NpcNum 'bem
        StartQuest index, 94, NpcNum
        StartQuest index, 95, NpcNum 'bem
        StartQuest index, 97, NpcNum
        StartQuest index, 98, NpcNum 'bem
        StartQuest index, 100, NpcNum
        StartQuest index, 101, NpcNum
        StartQuest index, 102, NpcNum
        StartQuest index, 103, NpcNum
        StartQuest index, 104, NpcNum
        StartQuest index, 105, NpcNum
        StartQuest index, 106, NpcNum
        
    Case 17 'Org do Mal
        If Player(index).Org <> ORG_7ESPADACHINS And Player(index).Org <> ORG_TAKA And Player(index).Org <> ORG_AKATSUKI Then
            PlayerMsg index, "Pra fazer essas missões,precisa ser desertor e ser de uma org desertora(menos Laços Ninja).", Grey
            Exit Sub
        End If
        
        StartQuest index, 55, NpcNum
        StartQuest index, 57, NpcNum 'Mal
        StartQuest index, 58, NpcNum
        StartQuest index, 59, NpcNum
        StartQuest index, 61, NpcNum 'Mal
        StartQuest index, 62, NpcNum
        StartQuest index, 63, NpcNum
        StartQuest index, 65, NpcNum 'mal
        StartQuest index, 66, NpcNum
        StartQuest index, 67, NpcNum
        StartQuest index, 69, NpcNum 'mal
        StartQuest index, 70, NpcNum
        StartQuest index, 71, NpcNum
        StartQuest index, 72, NpcNum
        StartQuest index, 74, NpcNum 'mal
        StartQuest index, 75, NpcNum
        StartQuest index, 76, NpcNum
        StartQuest index, 78, NpcNum 'mal
        StartQuest index, 79, NpcNum
        StartQuest index, 80, NpcNum
        StartQuest index, 82, NpcNum 'mal
        StartQuest index, 83, NpcNum
        StartQuest index, 84, NpcNum
        StartQuest index, 86, NpcNum 'mal
        StartQuest index, 87, NpcNum
        StartQuest index, 88, NpcNum
        StartQuest index, 90, NpcNum 'mal
        StartQuest index, 91, NpcNum
        StartQuest index, 93, NpcNum 'mal
        StartQuest index, 94, NpcNum
        StartQuest index, 96, NpcNum 'mal
        StartQuest index, 97, NpcNum
        StartQuest index, 99, NpcNum 'mal
        StartQuest index, 100, NpcNum
        StartQuest index, 101, NpcNum
        StartQuest index, 102, NpcNum
        StartQuest index, 103, NpcNum
        StartQuest index, 104, NpcNum
        StartQuest index, 105, NpcNum
        StartQuest index, 106, NpcNum
    Case 18 'Loja Troca Chars
        SendOpenShop index, 14
        TempPlayer(index).InShop = 14
    Case 19 'curar chakra e vida em troca de 10 ervas
        If TempPlayer(index).QuestAviso(NpcNum) = NO Then
            SendPicFala index, "Eu curo sua vida e chakra em troca de 10 ervas medicinais.Se quizer fazer a troca,fale comigo novamente.", 210
            TempPlayer(index).QuestAviso(NpcNum) = YES
            Exit Sub
        End If
        
        TempPlayer(index).QuestAviso(NpcNum) = NO
        
        If CanTake(index, 48, 10) = True Then
            TakeInvItem index, 48, 10
            SetPlayerVital index, Vitals.HP, GetPlayerMaxVital(index, Vitals.HP)
            SetPlayerVital index, Vitals.mp, GetPlayerMaxVital(index, Vitals.mp)
            SendVital index, Vitals.HP
            SendVital index, Vitals.mp
            SendInventory index
            PlayerMsg index, "Tudo ocorreu bem!", Pink
            SendAnimation GetPlayerMap(index), 49, NO, NO, TARGET_TYPE_PLAYER, index
        Else
            PlayerMsg index, "Você não têm as 10 ervas necessárias", BrightRed
        End If
    Case 20 'Graduação Ninja
        If TempPlayer(index).ExameEscrito = YES Then
            Exit Sub
        End If
        
        For i = 1 To 10
            If Player(index).QuestNum(i) >= 108 And Player(index).QuestNum(i) <= 110 Then
                PlayerMsg index, "Você já está com um teste de RANK ativado..", BrightRed
                Exit Sub
            End If
        Next
        
        Select Case Player(index).Rank
            Case RANK_ESTUDANTE
                SendPicFala index, "Para se tornar Gennin,fale com o Iruka e faça tudo oque ele lhe pedir :]", NO
            Case RANK_GENIN
                If Torneio <> TORNEIO_CS Or TorneioAtivo = NO Then
                    PlayerMsg index, "Não há Chunin Shiken ativo", BrightRed
                    Exit Sub
                End If
                
                If Torneio = TORNEIO_CS Then
                    If Player(index).InTorneio > 0 Then
                        PlayerMsg index, "Você já está em um torneio,negado!(Para sair vá em Extras>Sair Torneio)", BrightRed
                        Exit Sub
                    End If
                End If
                
                If GetPlayerLevel(index) < 100 Then
                    PlayerMsg index, "Apenas level 100+", BrightRed
                    Exit Sub
                End If
                
                SendPicFala index, "Para você passar no teste escrito,precisa acertar 5 das 10 questões!Boa sorte!!", NO
                SendExameEscrito index
            Case RANK_CHUNIN
                If GetPlayerLevel(index) < 250 Then
                    PlayerMsg index, "Apenas level 250+", BrightRed
                    Exit Sub
                End If
                
                SendPicFala index, "Para você passar no teste escrito,precisa acertar 7 das 10 questões!Boa sorte!!", NO
                SendExameEscrito index
            Case RANK_JOUNIN
                If GetPlayerLevel(index) < 400 Then
                    PlayerMsg index, "Apenas level 400+", BrightRed
                    Exit Sub
                End If
                
                SendPicFala index, "Para você passar no teste escrito,precisa acertar 10 das 15 questões!Boa sorte!!", NO
                SendExameEscrito index
            Case RANK_ANBU
                If GetPlayerLevel(index) < 600 Then
                    PlayerMsg index, "Apenas level 600+", BrightRed
                    Exit Sub
                End If
                
                SendPicFala index, "Para você passar no teste escrito,precisa acertar 15 das 20 questões!Boa sorte!!", NO
                SendExameEscrito index
            Case Else
                SendPicFala index, "Não há nada pra você aqui..", NO
        End Select
Case Else
    Call PlayerMsg(index, "YOU GOT RICK ROLLED", Red)
End Select
End Sub

Sub NpcAttack(ByVal index As Long, ByVal Script As Long, ByVal NpcNum As Long)
Select Case Script
   Case 1
        MapNpc(GetPlayerMap(index)).Npc(NpcNum).X = GetPlayerX(index) - 1
        MapNpc(GetPlayerMap(index)).Npc(NpcNum).Y = GetPlayerY(index) - 1
        SendMapNpcsToMap GetPlayerMap(index)
   Case 2
        Call PlayerMsg(index, "1 works", BrightBlue)

   Case 3
        Call PlayerMsg(index, "2 works", BrightCyan)

Case Else
   Call PlayerMsg(index, "YOU GOT RICK ROLLED", Red)
End Select
End Sub

Sub NpcOnSigh(ByVal index As Long, ByVal Script As Long, ByVal mapNpcNum As Byte)
Dim NpcNum As Long

NpcNum = Map(GetPlayerMap(index)).Npc(mapNpcNum)

Select Case Script
   Case 1
        If RAND(1, 50) = 1 Then
            NpcWarpBehind mapNpcNum, index
        End If
   Case 2
        If RAND(1, 30) = 1 Then
            NpcWarpBehind mapNpcNum, index
        End If

   Case 3
        If RAND(1, 15) = 1 Then
            NpcWarpBehind mapNpcNum, index
        End If
        
    Case 4
        If RAND(1, 10) = 1 Then
            NpcWarpBehind mapNpcNum, index
        End If
        
    Case 5
        If RAND(1, 8) = 1 Then
            NpcWarpBehind mapNpcNum, index
        End If
    
    Case 6
        If RAND(1, 5) = 1 Then
            NpcWarpBehind mapNpcNum, index
        End If
        
    Case 7
        If RAND(1, 4) = 1 Then
            NpcWarpBehind mapNpcNum, index
        End If
    Case 8
        If RAND(1, 3) = 1 Then
            NpcWarpBehind mapNpcNum, index
        End If
    
    Case 9
        If RAND(1, 2) = 1 Then
            NpcWarpBehind mapNpcNum, index
        End If
    Case 10
        If RAND(1, 1) = 1 Then
            NpcWarpBehind mapNpcNum, index
        End If
        
Case Else
   Call PlayerMsg(index, "YOU GOT RICK ROLLED", Red)
End Select
End Sub

