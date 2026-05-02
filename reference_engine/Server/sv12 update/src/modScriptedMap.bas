Attribute VB_Name = "modScriptedMap"
Sub ScriptedClick(ByVal index As Long, ByVal Script As Long)
Select Case Script

    Case 1
        Call PlayerMsg(index, "1 works", BrightBlue)

    Case 2
        Call PlayerMsg(index, "2 works", BrightCyan)

    Case Else
        Call PlayerMsg(index, "YOU GOT RICK ROLLED", Red)
End Select
End Sub

Sub ScriptedTile(ByVal index As Long, ByVal Script As Long)
Dim i, mapNum As Long

mapNum = GetPlayerMap(index)

Select Case Script

    Case 1 'andar na agua Jutsu
        If TempPlayer(index).AndandoAgua = NO Then
            BlockPlayer index
            PlayerMsg index, "Você precisa ativar o Jutsu:Mizu no Kinobori!", BrightRed
        End If
        
    Case 2 'Entrando na academia
        Select Case Player(index).Vila
            Case 0 'Desertor-Chuva
                If GetPlayerMap(index) <> 173 Then
                    PlayerMsg index, "Não é a academia de sua vila.", BrightRed
                    Exit Sub
                End If
            Case 1 'Konoha
                If GetPlayerMap(index) <> 1 Then
                    PlayerMsg index, "Não é a academia de sua vila.", BrightRed
                    Exit Sub
                End If
            Case 2 'Suna
                If GetPlayerMap(index) <> 50 Then
                    PlayerMsg index, "Não é a academia de sua vila.", BrightRed
                    Exit Sub
                End If
            Case 3 'Mizu
                If GetPlayerMap(index) <> 34 Then
                    PlayerMsg index, "Não é a academia de sua vila.", BrightRed
                    Exit Sub
                End If
            Case 4 'Tsuchi
                If GetPlayerMap(index) <> 22 Then
                    PlayerMsg index, "Não é a academia de sua vila.", BrightRed
                    Exit Sub
                End If
            Case 5 'Kumo
                If GetPlayerMap(index) <> 151 Then
                    PlayerMsg index, "Não é a academia de sua vila.", BrightRed
                    Exit Sub
                End If
            Case Else
               
        End Select
            
        PlayerWarp index, 69, 10, 14
    
    Case 3 'Saindo da academia
        Select Case Player(index).Vila
            Case 0 'Desertor-Chuva
                PlayerWarp index, 173, 14, 9
            Case 1 'Konoha
                PlayerWarp index, 1, 13, 37
            Case 2 'Suna
                PlayerWarp index, 50, 7, 27
            Case 3 'Mizu
                PlayerWarp index, 34, 12, 11
            Case 4 'Tsuchi
                PlayerWarp index, 22, 11, 25
            Case 5 'Kumo
                PlayerWarp index, 151, 17, 11
            Case Else
                BlockPlayer index
        End Select
        
    Case 4 ' Shop JutsusElemental
        If GetPlayerLevel(index) < 10 Then
            PlayerMsg index, "Precisa ser no mínimo level 10.", BrightRed
            Exit Sub
        End If
        
        If Player(index).Elemento(2) > 0 Then
            Select Case Player(index).Elemento(2)
                    Case 1 'Fogo
                        SendOpenShop index, 4
                        TempPlayer(index).InShop = 4
                    Case 2 'Vento
                        SendOpenShop index, 5
                        TempPlayer(index).InShop = 5
                    Case 3 'Água
                        SendOpenShop index, 6
                        TempPlayer(index).InShop = 6
                    Case 4 'Terra
                        SendOpenShop index, 7
                        TempPlayer(index).InShop = 7
                    Case 5 'Raio
                        SendOpenShop index, 8
                        TempPlayer(index).InShop = 8
                    Case Else
                End Select
        Else
            Select Case Player(index).Elemento(1)
                Case 1 'Fogo
                    SendOpenShop index, 4
                    TempPlayer(index).InShop = 4
                Case 2 'Vento
                    SendOpenShop index, 5
                    TempPlayer(index).InShop = 5
                Case 3 'Água
                    SendOpenShop index, 6
                    TempPlayer(index).InShop = 6
                Case 4 'Terra
                    SendOpenShop index, 7
                    TempPlayer(index).InShop = 7
                Case 5 'Raio
                    SendOpenShop index, 8
                    TempPlayer(index).InShop = 8
                Case Else
            End Select
        End If
    
    Case 5 'Entrada Chunin
        If Torneio = "cs" Then
            If TempPlayer(index).InTorneio = YES Then
                If HasItem(index, 219) Then
                    PlayerMsg index, "Boa sorte!", BrightGreen
                Else
                    PlayerMsg index, "Você não está com o Pergaminho!", BrightRed
                    BlockPlayer index
                End If
            Else
                BlockPlayer index
                PlayerMsg index, "Onde pensa que vai?.-.", BrightRed
                PlayerMsg index, "Você precisa do 'Pergaminho(Chunin)' para passar", BrightRed
                PlayerMsg index, "Fale com o Inspetor Chunin e siga suas instruções!", White
            End If
        Else
            BlockPlayer index
            PlayerMsg index, "No momento não está tendo Chunin Shiken.", BrightRed
        End If
    
    Case 6 'Entrando na sala de Espera-CHUNIN
        If Not Torneio = "cs" Then
            PlayerMsg index, "O tempo pra esta fase do CS Acabou. Digite /atendimento e tente na próxima!", BrightRed
            Exit Sub
        End If
        
        If CanTake(index, 219, 2) Then
            TakeItem index, 219, 2
            PlayerWarp index, 98, 11, 14
            PlayerMsg index, "Parabéns!Agora espere o ADM para iniciarmos a fase 3!", BrightGreen
        Else
            PlayerMsg index, "Você ainda não tem os 2 pergaminhos(Chunin).Derrote inimigos para conseguí-los.", BrightRed
            BlockPlayer index
        End If
        
    Case 7 'Entrando área vip
        If Player(index).VipData.VIP < 1 Then
            BlockPlayer index
            PlayerMsg index, "Apenas membros VIP!", BrightRed
        Else
            PlayerWarp index, 82, 9, 13
            PlayerMsg index, "Bem vindo à area VIP!", BrightGreen
        End If
        
    Case 8 'Entrando akat
        If HasItem(index, 251) Then
            TakeItem index, 251, 1
            PlayerMsg index, "Você usou uma chave..", White
            PlayerWarp index, 175, 19, 14
        Else
            PlayerMsg index, "Você precisa de uma chave..", BrightRed
            BlockPlayer index
        End If
    Case 9 'Entrando oro esconderijo
        If HasItem(index, 253) Then
            TakeItem index, 253, 1
            PlayerMsg index, "Você usou uma chave..", White
            PlayerWarp index, 124, 2, 13
        Else
            PlayerMsg index, "Você precisa de uma chave..", BrightRed
            BlockPlayer index
        End If
    
        
    Case Else
        Call PlayerMsg(index, "YOU GOT RICK ROLLED", Red)
End Select
End Sub


