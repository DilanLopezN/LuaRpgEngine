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
Select Case Script
Case 1 'Saindo da missão Anko-Chunin
PlayerWarp index, 57, 15, 4
TempPlayer(index).InTorneio = YES
Player(index).PKstate = 2
SendPlayerData index

Case 2 'Tornar Genin
Player(index).Rank = RANK_GENIN
PlayerMsg index, "Parabéns!Você é o mais novo genin.", BrightGreen
GlobalMsg GetPlayerName(index) & " é o mais novo Genin!", BrightCyan
SendPlayerData index

If Not HasSpell(index, 3) Then
    SetPlayerSpell index, FindOpenSpellSlot(index), 3
End If

    Case 3 'Akatsuki
        Player(index).Rank = RANK_DESERTOR
        Player(index).Vila = 0
        Player(index).Org = ORG_AKATSUKI
        GlobalMsg GetPlayerName(index) & "  provou que merece entrar na Akatsuki!", Green
        SendPlayerData index
        SavePlayer index
    Case 4 'Taka
        Player(index).Rank = RANK_DESERTOR
        Player(index).Vila = 0
        Player(index).Org = ORG_TAKA
        GlobalMsg GetPlayerName(index) & "  provou que merece entrar na Taka!", Green
        SendPlayerData index
        SavePlayer index
    Case 5 'Espadachins da Nevoa
        Player(index).Rank = RANK_DESERTOR
        Player(index).Vila = 0
        Player(index).Org = ORG_7ESPADACHINS
        GlobalMsg GetPlayerName(index) & "  provou que merece entrar nos Espadachins da Névoa!", Green
        SendPlayerData index
        SavePlayer index
    Case 6 'Hospital
        Player(index).Org = ORG_HOSPITAL
        GlobalMsg GetPlayerName(index) & "  provou que merece entrar para o Hospital!", BrightGreen
        SendPlayerData index
        SavePlayer index
    Case 7 'ANBU Raíz
        Player(index).Org = ORG_ANBURAIZ
        GlobalMsg GetPlayerName(index) & "  provou que merece entrar para a ANBU Raíz!", BrightGreen
        SendPlayerData index
        SavePlayer index
    Case 8 'Polícia de Konoha
        Player(index).Org = ORG_POLICIAKONOHA
        GlobalMsg GetPlayerName(index) & "  provou que merece entrar para a Polícia de Konoha!", BrightGreen
        SendPlayerData index
        SavePlayer index
    Case 9 'Guardiões
        Player(index).Org = ORG_12GUARDIOES
        GlobalMsg GetPlayerName(index) & "  provou que merece entrar para os Guardiões!", BrightGreen
        SendPlayerData index
        SavePlayer index
        
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
        
        If Not CanTake(index, 254, 1000) Then
            PlayerMsg index, "Precisa de 1000 CASH!", BrightRed
            CheckCanStartQuest = False
        Else
            TakeInvItem index, 254, 1000
        End If
        
    Case 50 'Hospital
        If Not Player(index).Rank > RANK_GENIN And Not Player(index).Rank = RANK_DESERTOR Then
            PlayerMsg index, "Precisa ser no Mínimo Chunin!", BrightRed
            CheckCanStartQuest = False
            Exit Function
        End If
        
        If Not CanTake(index, 254, 5000) Then
            PlayerMsg index, "Precisa de 5000 CASH!", BrightRed
            CheckCanStartQuest = False
        Else
            TakeInvItem index, 254, 5000
        End If
    Case 51 'Anbu RAÍZ
        If Not Player(index).Rank = RANK_ANBU Then
            PlayerMsg index, "Precisa ser ANBU!", BrightRed
            CheckCanStartQuest = False
            Exit Function
        End If
        
        If Not CanTake(index, 254, 5000) Then
            PlayerMsg index, "Precisa de 5000 CASH!", BrightRed
            CheckCanStartQuest = False
        Else
            TakeInvItem index, 254, 5000
        End If
    Case 52 'Policia Konoha!
        If Not Player(index).Rank > RANK_CHUNIN Then
            PlayerMsg index, "Precisa ser no Mínimo Jounin!", BrightRed
            CheckCanStartQuest = False
            Exit Function
        End If
        
        If Not GetPlayerClass(index) = 2 Then
            PlayerMsg index, "Apenas Uchihas!", BrightRed
            CheckCanStartQuest = False
            Exit Function
        End If
        
        If Not Player(index).Vila = 1 Then
            PlayerMsg index, "Apenas de Konoha!", BrightRed
            CheckCanStartQuest = False
            Exit Function
        End If
        
        If Not CanTake(index, 254, 1000) Then
            PlayerMsg index, "Precisa de 1000 CASH!", BrightRed
            CheckCanStartQuest = False
        Else
            TakeInvItem index, 254, 1000
        End If
    Case 49 'Espadachins da Nevoa
        If Not Player(index).Rank > RANK_GENIN Then
            PlayerMsg index, "Precisa ser no Mínimo Chunin!", BrightRed
            CheckCanStartQuest = False
            Exit Function
        End If
        
        If Not Player(index).Vila = 3 Then
            PlayerMsg index, "Precisa ser de Kiri!", BrightRed
            CheckCanStartQuest = False
            Exit Function
        End If
        
        If Not CanTake(index, 254, 1000) Then
            PlayerMsg index, "Precisa de 1000 CASH!", BrightRed
            CheckCanStartQuest = False
            Exit Function
        Else
            TakeInvItem index, 254, 1000
        End If
    Case 53 'Guardiões
        If Not Player(index).Rank > RANK_JOUNIN Then
            PlayerMsg index, "Precisa ser ANBU!", BrightRed
            CheckCanStartQuest = False
            Exit Function
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

