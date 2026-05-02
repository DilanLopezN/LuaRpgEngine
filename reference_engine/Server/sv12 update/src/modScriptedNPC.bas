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

            If Torneio = "cs" Then
                
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
    
    If Player(index).Rank = RANK_KAGE Then Exit Sub
    
    If Player(index).Org > 0 Then
        PlayerMsg index, "Pra usar esse serviço,precisa estar sem Org!", BrightRed
        Exit Sub
    End If
    
    If Not Player(index).Vila = 0 Then
        PlayerMsg index, "Você não é desertor,suma maldito!", BrightRed
        Exit Sub
    End If
    
    Dim num As Byte
        If CanTake(index, 254, 5000) Then
             num = RAND(1, 5)
             If Not num = 0 Then
                Select Case num
                    Case 1 'Konoha
                        Player(index).Vila = 1
                        Player(index).Rank = RANK_JOUNIN
                        TakeItem index, 254, 5000
                        PlayerMsg index, "Agora você é da vila Konoha!", Green
                        PlayerMsg index, "Custou 5k cash!", White
                    Case 2 'Suna
                        Player(index).Vila = 2
                        Player(index).Rank = RANK_JOUNIN
                        TakeItem index, 254, 5000
                        PlayerMsg index, "Agora você é da vila Suna!", Green
                        PlayerMsg index, "Custou 5k cash!", White
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
                    Case 5 'Kumo
                        Player(index).Vila = 5
                        Player(index).Rank = RANK_JOUNIN
                        TakeItem index, 254, 5000
                        PlayerMsg index, "Agora você é da vila Kumo!", Green
                        PlayerMsg index, "Custou 5k cash!", White
                    Case Else
                        PlayerMsg index, "Operação falhou,tente denovo", BrightRed
                End Select
            Else
                PlayerMsg index, "Operação falhou,tente denovo", BrightRed
            End If
        Else
            PlayerMsg index, "Preciso de 5k CASH pra fazer algo :| ", BrightRed
        End If
        
    Case 7 'Itachi(Akatsuki)
        If TempPlayer(index).QuestAviso(NpcNum) = NO Then
            PlayerMsg index, "Para fazer o teste da Akatsuki,é cobrado 1k CASH!", BrightGreen
            PlayerMsg index, "Se você ainda quer fazê-lo,fale comigo denovo!", BrightGreen
            TempPlayer(index).QuestAviso(NpcNum) = YES
            Exit Sub
        End If
        
        TempPlayer(index).QuestAviso(NpcNum) = NO
        
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
        
        StartQuest index, 47, 226
    Case 8 'Sasuke(Taka)
        If TempPlayer(index).QuestAviso(NpcNum) = NO Then
            PlayerMsg index, "Para fazer o teste da Taka,é cobrado 1k CASH!", BrightGreen
            PlayerMsg index, "Se você ainda quer fazê-lo,fale comigo denovo!", BrightGreen
            TempPlayer(index).QuestAviso(NpcNum) = YES
            Exit Sub
        End If
        
        TempPlayer(index).QuestAviso(NpcNum) = NO
        
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
        StartQuest index, 48, 227
       
    Case 9 'Zabuza(espadachins)
        If TempPlayer(index).QuestAviso(NpcNum) = NO Then
            PlayerMsg index, "Para fazer o teste da Espadachins da Névoa,é cobrado 1k CASH!", BrightGreen
            PlayerMsg index, "Se você ainda quer fazê-lo,fale comigo denovo!", BrightGreen
            TempPlayer(index).QuestAviso(NpcNum) = YES
            Exit Sub
        End If
        
        TempPlayer(index).QuestAviso(NpcNum) = NO
        
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
        
        StartQuest index, 49, 228
        
    Case 10 'Sakura(hospital)
        If TempPlayer(index).QuestAviso(NpcNum) = NO Then
            PlayerMsg index, "Para fazer o teste do Hospital,é cobrado 5k CASH!", BrightGreen
            PlayerMsg index, "Se você ainda quer fazê-lo,fale comigo denovo!", BrightGreen
            TempPlayer(index).QuestAviso(NpcNum) = YES
            Exit Sub
        End If
        
        TempPlayer(index).QuestAviso(NpcNum) = NO
        
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
        
        StartQuest index, 50, 229
        
    Case 11 'Sai(anbu raiz)
        If TempPlayer(index).QuestAviso(NpcNum) = NO Then
            PlayerMsg index, "Para fazer o teste da ANBU Raíz,é cobrado 5k CASH!", BrightGreen
            PlayerMsg index, "Se você ainda quer fazê-lo,fale comigo denovo!", BrightGreen
            TempPlayer(index).QuestAviso(NpcNum) = YES
            Exit Sub
        End If
        
        TempPlayer(index).QuestAviso(NpcNum) = NO
        
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
        
        StartQuest index, 51, 230
       
    Case 12 'Policial
        If TempPlayer(index).QuestAviso(NpcNum) = NO Then
            PlayerMsg index, "Para fazer o teste dos Policiais de Konoha,é cobrado 1k CASH!", BrightGreen
            PlayerMsg index, "Se você ainda quer fazê-lo,fale comigo denovo!", BrightGreen
            TempPlayer(index).QuestAviso(NpcNum) = YES
            Exit Sub
        End If
        
        TempPlayer(index).QuestAviso(NpcNum) = NO
        
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
        
        StartQuest index, 52, 231
        
    Case 13 'Guardião
        If TempPlayer(index).QuestAviso(NpcNum) = NO Then
            PlayerMsg index, "Para fazer o teste dos Guardiões,é cobrado 5k CASH!", BrightGreen
            PlayerMsg index, "Se você ainda quer fazê-lo,fale comigo denovo!", BrightGreen
            TempPlayer(index).QuestAviso(NpcNum) = YES
            Exit Sub
        End If
        
        TempPlayer(index).QuestAviso(NpcNum) = NO
        
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
        
        StartQuest index, 53, 232
      
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

NpcNum = MAP(GetPlayerMap(index)).Npc(mapNpcNum)

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

