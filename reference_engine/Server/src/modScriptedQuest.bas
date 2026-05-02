Attribute VB_Name = "modScriptedQuest"
Sub ScriptStartQuest(ByVal index As Long, ByVal Script As Long, ByVal QuestNum As Long)
Select Case Script
Case 0
Call PlayerMsg(index, "0 works", Blue)

Case 1 'Anko Quest
    PlayerWarp index, 97, 8, 5
Case 2
Call PlayerMsg(index, "2 works", BrightCyan)

Case Else
Call PlayerMsg(index, "YOU GOT RICK ROLLED", Red)
End Select
End Sub

Sub ScriptEndQuest(ByVal index As Long, ByVal Script As Long, ByVal QuestNum As Long)
Dim i As Byte
Dim n As Byte
Dim SpellOk As Byte
        
Select Case Script
    Case 1 'Saindo da missão Anko-Chunin
        For i = 1 To MAX_INV
            If GetPlayerInvItemNum(index, i) = 210 Or GetPlayerInvItemNum(index, i) = 211 Then
                TakeInvItem index, GetPlayerInvItemNum(index, i), GetPlayerInvItemValue(index, i)
                PlayerMsg index, "Opa, foi retirado os pergaminhos que tu ja tinha. Você precisa jogar limpo", BrightRed
            End If
        Next
        
        If frmServer.chkTorneioStatus.Value = NO Then 'acabou o tempo
            PlayerMsg index, "Acabou o tempo da fase da floresta. Seja mais rápido na próxima vez.", White
            Player(index).InTorneio = NO
            Atendimento index
            Exit Sub
        End If
        
        Select Case RAND(1, 2)
            Case 1
                GiveInvItem index, 210, 1, True
                PlayerMsg index, "Você possui o pergaminho da TERRA,precisa conseguir 1 pergaminho do CÉU para entrar no edificio Chunnin.", White
            Case 2
                GiveInvItem index, 211, 1, True
                PlayerMsg index, "Você possui o pergaminho da CÉU,precisa conseguir 1 pergaminho do TERRA para entrar no edificio Chunnin.", White
            Case Else
        End Select
        
        PlayerWarp index, 57, 12, 6
        Player(index).InTorneio = TORNEIO_CS
        Player(index).PKstate = 3
        SendPlayerData index

    Case 2 'Tornar Genin
        Player(index).Rank = RANK_GENIN
        PlayerMsg index, "Parabéns!Você é o mais novo genin.", BrightGreen
        GlobalMsg GetPlayerName(index) & " é o mais novo Genin!", BrightCyan
        SendPlayerData index

    Case 3 'Akatsuki
        If Player(index).Vila <> 0 And Player(index).Vila <> 6 Then
            Player(index).Rank = RANK_DESERTOR
            
            If RAND(1, 2) = 1 Then
                Player(index).Vila = NO
            Else
                Player(index).Vila = 6 'som
            End If
        Else
            If Player(index).Rank <> RANK_KAGE Then
                Player(index).Rank = RANK_DESERTOR
            End If
        End If
        
        Player(index).Org = ORG_AKATSUKI
        OrgJutsu index, ORG_AKATSUKI
        GlobalMsg GetPlayerName(index) & "  provou que merece entrar na Akatsuki!", Green
        SendPlayerData index
        SavePlayer index
    Case 4 'Taka
        
        If Player(index).Vila <> 0 And Player(index).Vila <> 6 Then
            Player(index).Rank = RANK_DESERTOR
            
            If RAND(1, 2) = 1 Then
                Player(index).Vila = NO
            Else
                Player(index).Vila = 6 'som
            End If
        Else
            If Player(index).Rank <> RANK_KAGE Then
                Player(index).Rank = RANK_DESERTOR
            End If
        End If
        
        Player(index).Org = ORG_TAKA
        OrgJutsu index, ORG_TAKA
        GlobalMsg GetPlayerName(index) & "  provou que merece entrar na Taka!", Green
        SendPlayerData index
        SavePlayer index
    Case 5 'Espadachins da Nevoa
        
        If Player(index).Vila <> 0 And Player(index).Vila <> 6 Then
            Player(index).Rank = RANK_DESERTOR
            
            If RAND(1, 2) = 1 Then
                Player(index).Vila = NO
            Else
                Player(index).Vila = 6 'som
            End If
        Else
            If Player(index).Rank <> RANK_KAGE Then
                Player(index).Rank = RANK_DESERTOR
            End If
        End If
        
        Player(index).Org = ORG_7ESPADACHINS
        OrgJutsu index, ORG_7ESPADACHINS
        GlobalMsg GetPlayerName(index) & "  provou que merece entrar nos Espadachins da Névoa!", Green
        SendPlayerData index
        SavePlayer index
    Case 6 'Hospital
        OrgJutsu index, ORG_HOSPITAL
        
        Player(index).Org = ORG_HOSPITAL
        GlobalMsg GetPlayerName(index) & "  provou que merece entrar para o Hospital!", BrightGreen
        SendPlayerData index
        SavePlayer index
    Case 7 'ANBU Raíz
        OrgJutsu index, ORG_ANBURAIZ
        
        Player(index).Org = ORG_ANBURAIZ
        GlobalMsg GetPlayerName(index) & "  provou que merece entrar para a ANBU Raíz!", BrightGreen
        SendPlayerData index
        SavePlayer index
    Case 8 'Polícia de Konoha
        OrgJutsu index, ORG_POLICIAKONOHA
    
        Player(index).Org = ORG_POLICIAKONOHA
        GlobalMsg GetPlayerName(index) & "  provou que merece entrar para a Polícia de Konoha!", BrightGreen
        SendPlayerData index
        SavePlayer index
    Case 9 'Guardiões
        OrgJutsu index, ORG_12GUARDIOES
        
        Player(index).Org = ORG_12GUARDIOES
        GlobalMsg GetPlayerName(index) & "  provou que merece entrar para os Guardiões!", BrightGreen
        SendPlayerData index
        SavePlayer index
    Case 10 'Jounin
        SetarRank index, RANK_JOUNIN
        PlayerMsg index, "Parabéns! Agora você é JOUNIN", BrightCyan
    Case 11 'ANBU
        SetarRank index, RANK_ANBU
        PlayerMsg index, "Parabéns! Agora você é ANBU", BrightCyan
    Case 12 'SANNIN
        SetarRank index, RANK_SANNIN
        PlayerMsg index, "Parabéns! Agora você é SANNIN", BrightCyan
        
Case Else
Call PlayerMsg(index, "YOU GOT RICK ROLLED", Red)
End Select
End Sub

Public Function CheckCanStartQuest(ByVal index As Long, ByVal QuestNum As Long) As Boolean
CheckCanStartQuest = True
If index < 1 Or index > MAX_PLAYERS Then Exit Function
If QuestNum < 1 Or QuestNum > MAX_QUESTS Then Exit Function

Select Case QuestNum
    Case 1, 2, 3 'Test Genin
        If Not Player(index).Rank = RANK_ESTUDANTE Then
            CheckCanStartQuest = False
            PlayerMsg index, "Você precisa ser Estudante.", BrightRed
            Exit Function
        End If
    
    Case 4 'Test Chunin
        If Not Player(index).Rank = RANK_GENIN Then
            CheckCanStartQuest = False
            PlayerMsg index, "Você precisa ser Genin.", BrightRed
            Exit Function
        End If
    
    Case 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16 'Genin
        If Not Player(index).Rank >= RANK_GENIN And Not Player(index).Rank = RANK_DESERTOR Then
            PlayerMsg index, "Precisa ser no mínimo Genin.", BrightRed
            CheckCanStartQuest = False
            Exit Function
        End If
        
    Case 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28 'Chunin
        If Not Player(index).Rank >= RANK_CHUNIN And Not Player(index).Rank = RANK_DESERTOR Then
            PlayerMsg index, "Precisa ser no mínimo Chunin.", BrightRed
            CheckCanStartQuest = False
            Exit Function
        End If
    
    Case 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45
        If Not Player(index).Rank >= RANK_JOUNIN And Not Player(index).Rank = RANK_DESERTOR Then
            PlayerMsg index, "Precisa ser no mínimo Jounin.", BrightRed
            CheckCanStartQuest = False
            Exit Function
        End If
    Case 47, 48 'Akatsuki/Taka
        If Not Player(index).Rank > RANK_GENIN Then
            PlayerMsg index, "Precisa ser no Mínimo Chunin!", BrightRed
            CheckCanStartQuest = False
            Exit Function
        End If
        
        If Player(index).Vila <> 0 And Player(index).Vila <> 6 Then
            PlayerMsg index, "Kages passivos não podem!", BrightRed
            Exit Function
        End If
        
        If Not CanTake(index, 254, 5000) Then
            PlayerMsg index, "Precisa de 5000 CASH!", BrightRed
            CheckCanStartQuest = False
            Exit Function
        Else
            TakeInvItem index, 254, 5000
        End If
        
    Case 50 'Hospital
        If Player(index).Rank = RANK_DESERTOR Then
                PlayerMsg index, "Precisa ser no Mínimo Chunin ou ter pelo menos lvl 700+ e não ser desertor!", BrightRed
                CheckCanStartQuest = False
                Exit Function
            End If
            
        If Player(index).Vila = 0 Or Player(index).Vila = 6 Then
            PlayerMsg index, "Desertores não podem!", BrightRed
            Exit Function
        End If
        
        If Not Player(index).Rank > RANK_GENIN Then
            If GetPlayerLevel(index) < 700 Then
                PlayerMsg index, "Precisa ser no Mínimo Chunin ou ter pelo menos lvl 700+ e não ser desertor!", BrightRed
                CheckCanStartQuest = False
                Exit Function
            End If
        End If
        
        If Not CanTake(index, 254, 5000) Then
            PlayerMsg index, "Precisa de 5000 CASH!", BrightRed
            CheckCanStartQuest = False
        Else
            TakeInvItem index, 254, 5000
        End If
    Case 51 'Anbu RAÍZ
        If Not Player(index).Rank >= RANK_CHUNIN Then
            PlayerMsg index, "Precisa ser no mínimo Chunin!", BrightRed
            CheckCanStartQuest = False
            Exit Function
        End If
        
        If Player(index).Vila = 0 Or Player(index).Vila = 6 Then
            PlayerMsg index, "Desertores não podem!", BrightRed
            Exit Function
        End If
        
        If Not CanTake(index, 254, 5000) Then
            PlayerMsg index, "Precisa de 5000 CASH!", BrightRed
            CheckCanStartQuest = False
        Else
            TakeInvItem index, 254, 5000
        End If
    Case 52 'Policia Konoha!
        If Player(index).Rank = RANK_DESERTOR Then
                PlayerMsg index, "Precisa ser no Mínimo Chunin ou ter pelo menos lvl 500+ e não ser desertor!", BrightRed
                CheckCanStartQuest = False
                Exit Function
            End If
        
        If Player(index).Vila = 0 Or Player(index).Vila = 6 Then
            PlayerMsg index, "Desertores não podem!", BrightRed
            Exit Function
        End If
        
        If Not Player(index).Rank > RANK_GENIN Then
            If GetPlayerLevel(index) < 500 Then
                PlayerMsg index, "Precisa ser no Mínimo Chunin ou ter pelo menos lvl 500+ e não ser desertor!", BrightRed
                CheckCanStartQuest = False
                Exit Function
            End If
        End If
        
        If Not GetPlayerClass(index) = SASUKE And Not GetPlayerClass(index) = ITACHI And Not GetPlayerClass(index) = MADARA And Not GetPlayerClass(index) = TOBI Then
            PlayerMsg index, "Apenas Uchihas!", BrightRed
            CheckCanStartQuest = False
            Exit Function
        End If
        
        If Not Player(index).Vila = 1 Then
            PlayerMsg index, "Apenas de Konoha!", BrightRed
            CheckCanStartQuest = False
            Exit Function
        End If
        
    Case 49 'Espadachins da Nevoa
        If Not Player(index).Rank > RANK_GENIN Then
            PlayerMsg index, "Precisa ser no Mínimo Chunin!", BrightRed
            CheckCanStartQuest = False
            Exit Function
        End If
        
        If Player(index).Vila <> 0 And Player(index).Vila <> 6 Then
            PlayerMsg index, "Kages passivos não podem!", BrightRed
            Exit Function
        End If
        
        If Not Player(index).Vila = 3 Then
            PlayerMsg index, "Precisa ser de Kiri!", BrightRed
            CheckCanStartQuest = False
            Exit Function
        End If
        
        If Not CanTake(index, 254, 5000) Then
            PlayerMsg index, "Precisa de 5000 CASH!", BrightRed
            CheckCanStartQuest = False
            Exit Function
        Else
            TakeInvItem index, 254, 5000
        End If
    Case 53 'Guardiões
        If Player(index).Rank = RANK_DESERTOR Then
            PlayerMsg index, "Precisa ser no Mínimo Chunin ou resetado e não ser desertor!", BrightRed
            CheckCanStartQuest = False
            Exit Function
        End If
        
        If Player(index).Vila = 0 Or Player(index).Vila = 6 Then
            PlayerMsg index, "Desertores não podem!", BrightRed
            Exit Function
        End If
        
        If Not Player(index).Rank > RANK_GENIN Then
            If GetPlayerLevel(index) < 1000 And Player(index).Resets = NO Then
                PlayerMsg index, "Precisa ser no Mínimo Chunin ou ser resetado e não ser desertor!", BrightRed
                CheckCanStartQuest = False
                Exit Function
            End If
        End If
        
        If Not CanTake(index, 254, 5000) Then
            PlayerMsg index, "Precisa de 5000 CASH!", BrightRed
            CheckCanStartQuest = False
        Else
            TakeInvItem index, 254, 5000
        End If
    
    Case Else
End Select
End Function

