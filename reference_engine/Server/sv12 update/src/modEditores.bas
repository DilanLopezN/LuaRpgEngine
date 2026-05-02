Attribute VB_Name = "modEditores"
Public Sub QuestEditorInit()
Dim i As Long
Dim SoundSet As Boolean

    If frmEditor_Quest.Visible = False Then Exit Sub
    EditorIndex = frmEditor_Quest.lstIndex.ListIndex + 1
    

    With Quest(EditorIndex)
        'Infos
        frmEditor_Quest.txtName.Text = Trim$(.Name)
        frmEditor_Quest.txtDesc.Text = Trim(.Desc)
        frmEditor_Quest.scrlTipo.Value = .Tipo
        frmEditor_Quest.txtMsg1.Text = Trim(.Msg(1))
        frmEditor_Quest.txtMsg2.Text = Trim(.Msg(2))
        frmEditor_Quest.txtMsg3.Text = Trim(.Msg(3))
        frmEditor_Quest.scrlStartScript.Value = .StartScript
        frmEditor_Quest.chckRep.Value = .Repetivel
        
        'Requerimentos
        frmEditor_Quest.txtLvlReq.Text = .ReqLevel
        frmEditor_Quest.scrlClassReq.Max = Max_Classes
        frmEditor_Quest.scrlClassReq.Value = .ReqClasse
        frmEditor_Quest.scrlVIP.Value = .ReqVIP
        frmEditor_Quest.scrlParty.Value = .ReqParty
        'Tarefas
        
        'Item
        frmEditor_Quest.scrlItem1.Value = .Item(1)
        frmEditor_Quest.scrlItem2.Value = .Item(2)
        frmEditor_Quest.scrlItem3.Value = .Item(3)
        frmEditor_Quest.scrlItem4.Value = .Item(4)
        frmEditor_Quest.scrlItem5.Value = .Item(5)
        frmEditor_Quest.scrlItem1Qnt = .ItemQnt(1)
        frmEditor_Quest.scrlItem2Qnt = .ItemQnt(2)
        frmEditor_Quest.scrlItem3Qnt = .ItemQnt(3)
        frmEditor_Quest.scrlItem4Qnt = .ItemQnt(4)
        frmEditor_Quest.scrlItem5Qnt = .ItemQnt(5)
        'NPC
        frmEditor_Quest.scrlNpc1 = .Npc(1)
        frmEditor_Quest.scrlNpc2 = .Npc(2)
        frmEditor_Quest.scrlNpc3 = .Npc(3)
        frmEditor_Quest.scrlNpc4 = .Npc(4)
        frmEditor_Quest.scrlNpc5 = .Npc(5)
        frmEditor_Quest.scrlNpc1Qnt = .NpcQnt(1)
        frmEditor_Quest.scrlNpc2Qnt = .NpcQnt(2)
        frmEditor_Quest.scrlNpc3Qnt = .NpcQnt(3)
        frmEditor_Quest.scrlNpc4Qnt = .NpcQnt(4)
        frmEditor_Quest.scrlNpc5Qnt = .NpcQnt(5)
        'EXTRAS
        frmEditor_Quest.scrlNeedLvl.Value = .NeedLevel
        frmEditor_Quest.scrlMAP.Value = .MAP
        frmEditor_Quest.scrlKillPlayerClass.Value = .KillPlayerClass
        frmEditor_Quest.scrlKillPlayerQnt.Value = .KillPlayerQnt
        frmEditor_Quest.scrlUsarSpell.Value = .UsarSpell
        frmEditor_Quest.scrlUsarSpellQnt.Value = .UsarSpellQnt
        
        'Recompensas
        'Itens
        frmEditor_Quest.scrlRecItem1.Value = .rItem(1)
        frmEditor_Quest.scrlRecItem2.Value = .rItem(2)
        frmEditor_Quest.scrlRecItem3.Value = .rItem(3)
        frmEditor_Quest.scrlRecItem4.Value = .rItem(4)
        frmEditor_Quest.scrlRecItem5.Value = .rItem(5)
        frmEditor_Quest.scrlRecItem1Qnt.Value = .rItemQnt(1)
        frmEditor_Quest.scrlRecItem2Qnt.Value = .rItemQnt(2)
        frmEditor_Quest.scrlRecItem3Qnt.Value = .rItemQnt(3)
        frmEditor_Quest.scrlRecItem4Qnt.Value = .rItemQnt(4)
        frmEditor_Quest.scrlRecItem5Qnt.Value = .rItemQnt(5)
        'Extras
        frmEditor_Quest.txtEXP.Text = .rEXP
        frmEditor_Quest.scrlRclass.Max = Max_Classes
        frmEditor_Quest.scrlRclass.Value = .rClasse
        frmEditor_Quest.scrlSprite.Value = .rSprite
        frmEditor_Quest.scrlSpell.Value = .rSpell
        frmEditor_Quest.scrlRscript.Value = .rEndScript
        frmEditor_Quest.scrlRank.Value = .rRank
        
        EditorIndex = frmEditor_Quest.lstIndex.ListIndex + 1
    End With

   
    Quest_Changed(EditorIndex) = True
    
End Sub

Public Sub QuestEditorOk()
Dim i As Long

    For i = 1 To MAX_QUESTS
        If Quest_Changed(i) Then
            Call SaveQuest(i)
        End If
    Next
    
    Unload frmEditor_Quest
    Editor = 0
    ClearChanged_Quest
    
End Sub

Public Sub QuestEditorCancel()
   
    Editor = 0
    Unload frmEditor_Quest
    ClearChanged_Quest
    ClearQuests
    LoadQuests
   
End Sub

Sub SaveQuests()
    Dim i As Long

    For i = 1 To MAX_QUESTS
        Call SaveQuest(i)
    Next

End Sub

Sub SaveQuest(ByVal AnimationNum As Long)
    Dim filename As String
    Dim F As Long
    filename = App.Path & "\data\Quests\Quest" & AnimationNum & ".dat"
    F = FreeFile
    Open filename For Binary As #F
        Put #F, , Quest(AnimationNum)
    Close #F
End Sub

Sub LoadQuests()
    Dim filename As String
    Dim i As Long
    Dim F As Long
    Dim sLen As Long
    
    Call CheckQuests

    For i = 1 To MAX_QUESTS
        filename = App.Path & "\data\Quests\Quest" & i & ".dat"
        F = FreeFile
        Open filename For Binary As #F
            Get #F, , Quest(i)
        Close #F
    Next

End Sub

Sub CheckQuests()
    Dim i As Long

    For i = 1 To MAX_QUESTS

        If Not FileExist("\Data\Quests\Quest" & i & ".dat") Then
            Call SaveQuest(i)
        End If

    Next

End Sub



Sub ClearQuests()
    Dim i As Long

    For i = 1 To MAX_QUESTS
        Call ClearQuest(i)
    Next
End Sub
