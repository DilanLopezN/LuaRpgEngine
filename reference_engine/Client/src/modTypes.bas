Attribute VB_Name = "modTypes"
Option Explicit

' Public data structures
Public MAP As MapRec
Public Bank As BankRec
Public TempTile() As TempTileRec
Public Player(1 To MAX_PLAYERS) As PlayerRec
Public Class() As ClassRec
Public Item(1 To MAX_ITEMS) As ItemRec
Public Npc(1 To MAX_NPCS) As NpcRec
Public MapItem(1 To MAX_MAP_ITEMS) As MapItemRec
Public MapNpc(1 To MAX_MAP_NPCS) As MapNpcRec
Public Shop(1 To MAX_SHOPS) As ShopRec
Public Spell(1 To MAX_SPELLS) As SpellRec
Public Resource(1 To MAX_RESOURCES) As ResourceRec
Public Animation(1 To MAX_ANIMATIONS) As AnimationRec
Public Quest(1 To MAX_QUESTS) As QuestRec
Public TopLvl(1 To 20) As TopLvlRec
Public TopHero(1 To 10) As TopHeroRec
Public TopPK(1 To 10) As TopPkRec
Public TopPvP(1 To 10) As TopPvPRec
Public TopChar(1 To MAX_CLASS_TEMP) As TopCharRec
Public ExameEscrito(1 To 30) As ExameEscritoRec
Public Arena(1 To 9) As arenaRec

' client-side stuff
Public ActionMsg(1 To MAX_BYTE) As ActionMsgRec
Public Blood(1 To MAX_BYTE) As BloodRec
Public AnimInstance(1 To MAX_BYTE) As AnimInstanceRec
Public MenuButton(1 To MAX_MENUBUTTONS) As ButtonRec
Public MainButton(1 To MAX_MAINBUTTONS) As ButtonRec
Public Party As PartyRec
Public SamePacket(1 To 10) As Long
Public SamePacketCount(1 To 10) As Long
Public SamePacketTmr As Long

' options
Public Options As OptionsRec

' Type recs
Private Type OptionsRec
    Game_Name As String
    SavePass As Byte
    Password As String * NAME_LENGTH
    Username As String * ACCOUNT_LENGTH
    IP As String
    Port As Long
    MenuMusic As String
    Music As Byte
    Sound As Byte
    Debug As Byte
    AutoTile As Byte
    NomeLevel As Byte
    Hotbar As Byte
    MsgPrivada As Byte
    Desafios As Byte
    WASD As Byte
    
End Type

Public Type PartyRec
    Leader As Long
    Member(1 To MAX_PARTY_MEMBERS) As Long
    MemberCount As Long
End Type

Public Type PlayerInvRec
    num As Long
    value As Long
End Type

Private Type BankRec
    Item(1 To MAX_BANK) As PlayerInvRec
End Type

Private Type SpellAnim
    spellnum As Long
    Timer As Long
    FramePointer As Long
End Type

Private Type QuestRec
     'Informações
    name As String * NAME_LENGTH
    Desc As String * 255
    Msg(1 To 3) As String * 255
    tipo As Byte
    Repetivel As Byte
    'Script
    StartScript As Integer
    'Requerimentos
    ReqParty As Byte 'Membros Party
    ReqLevel As Integer
    ReqClasse As Byte
    ReqVIP As Byte
    'Tarefas
    Item(1 To 5) As Integer
    ItemQnt(1 To 5) As Long
    Npc(1 To 5) As Integer
    NpcQnt(1 To 5) As Long
    MAP As Integer
    NeedLevel As Integer
    'Recompensa
    rItem(1 To 5) As Integer
    rItemQnt(1 To 5) As Long
    rSpell As Integer
    rEXP As Long
    rSprite As Integer
    rClasse As Byte
    'SCRIPT
    rEndScript As Integer
    'SERVER SIDE
    Status As Byte
    QuestNpc(1 To 10) As Integer
End Type

Public Type PetRec
    SpriteNum As Byte
    name As String * 50
    Owner As Long
End Type

Private Type VipRec
    VIP As Byte
    DiasVIP As String
    DataVIP As String
End Type

Private Type CTRec
    CT As Byte
    DiasCT As String
    DataCT As String
End Type

Private Type BanRec
    Ban As Byte
    dias As String
    data As String
End Type

Private Type PvPRec
    V As Long
    d As Long
End Type

Public Type ProjectileRec
    TravelTime As Long
    Direction As Long
    X As Long
    Y As Long
    Pic As Long
    Range As Long
    Damage As Long
    Speed As Long
    PassOver As Byte
End Type

Private Type PlayerRec
    ' General
    name As String
    Class As Long
    Sprite As Long
    Level As Long
    EXP As Long
    Access As Byte
    PK As Byte
    
    VIP As Byte
    Rank As Byte
    Vila As Byte
    Elemento(1 To 5) As Byte
    Org As Byte
    OrgAccess As Byte
    
    trans As Byte
    Voando As Byte
    
    War As Byte
    
    QuestNum(1 To 10) As Integer
    QuestInfo(1 To 10) As QuestRec
    QuestCompleta(1 To MAX_QUESTS) As Integer
    
    ' Vitals
    Vital(1 To Vitals.Vital_Count - 1) As Long
    MaxVital(1 To Vitals.Vital_Count - 1) As Long
    ' Stats
    Stat(1 To Stats.Stat_Count - 1) As Long
    POINTS As Long
    ' Worn equipment
    Equipment(1 To Equipment.Equipment_Count - 1) As Long
    ' Position
    MAP As Long
    X As Byte
    Y As Byte
    Dir As Byte
    
    Pet As PetRec
    
    'Extras
    PKstate As Byte
    PKPoints As Long
    HeroPoints As Long
    VipData As VipRec
    CTdata As CTRec
    Invisivel As Byte
    Ban As BanRec
    Mute As Byte
    Resets As Integer
    SenhaSecreta As String
    Karma As Long
    PvP As PvPRec
    Lendario As Byte
    Berserker As Byte
        ' projectiles
    ProjecTile(1 To MAX_PLAYER_PROJECTILES) As ProjectileRec
    
    ' Client use only
    XOffset As Integer
    YOffset As Integer
    Moving As Byte
    Attacking As Byte
    AttackTimer As Long
    MapGetTimer As Long
    Step As Byte
    isFriend As Byte
    karmaTradeWarning As Boolean
End Type

Private Type TileDataRec
    X As Long
    Y As Long
    Tileset As Long
End Type

Public Type MapAnimRec 'animação
    Animation As Long
    Timer(0 To 1) As Long
    FrameIndex(0 To 1) As Long
End Type

Public Type TileRec
    layer(1 To MapLayer.Layer_Count - 1) As TileDataRec
    Type As Byte
    Data1 As Long
    Data2 As Long
    Data3 As Long
    DirBlock As Byte
    Animation As MapAnimRec 'animação
End Type

Private Type MapRec
    name As String * NAME_LENGTH
    Music As String * NAME_LENGTH
    
    Weather As Long 'temperatura
    
    Revision As Long
    Moral As Byte
    
    Up As Long
    Down As Long
    Left As Long
    Right As Long
    
    BootMap As Long
    BootX As Byte
    BootY As Byte
    
    MaxX As Byte
    MaxY As Byte
    
    Tile() As TileRec
    Npc(1 To MAX_MAP_NPCS) As Long
End Type

Private Type ClassRec
    name As String * NAME_LENGTH
    Stat(1 To Stats.Stat_Count - 1) As Byte
    MaleSprite() As Long
    FemaleSprite() As Long
    ' For client use
    Vital(1 To Vitals.Vital_Count - 1) As Long
End Type

Private Type ItemRec
    name As String * NAME_LENGTH
    Desc As String * 255
    Sound As String * NAME_LENGTH
    
    Pic As Long
    Type As Byte
    Data1 As Long
    Data2 As Long
    Data3 As Long
    ClassReq As Long
    AccessReq As Long
    LevelReq As Long
    Mastery As Byte
    Price As Long
    Add_Stat(1 To Stats.Stat_Count - 1) As Byte
    Rarity As Byte
    Speed As Long
    Handed As Long
    BindType As Byte
    Stat_Req(1 To Stats.Stat_Count - 1) As Byte
    Animation As Long
    Paperdoll As Long
    
    AddHP As Long
    AddMP As Long
    AddEXP As Long
    CastSpell As Long
    instaCast As Byte
    
    Script As Long
    StunDuration As Long
    ExpExtra As Long
    'ProjecTile As ProjectileRec
End Type

Private Type MapItemRec
    playerName As String
    num As Long
    value As Long
    Frame As Byte
    X As Byte
    Y As Byte
End Type

Private Type NpcRec
    name As String * NAME_LENGTH
    AttackSay As String * 100
    Sound As String * NAME_LENGTH
    
    Sprite As Long
    SpawnSecs As Long
    Behaviour As Byte
    Range As Byte
    DropChance As Long
    DropItem As Long
    DropItemValue As Long
    Stat(1 To Stats.Stat_Count - 1) As Byte
    HP As Long
    EXP As Long
    Animation As Long
    Damage As Long
    Level As Long
    'SCRIPT
    Script As Byte
    AttackScript As Byte
    OnSighScript As Byte
    SpellAnim As Integer
    SpellCD As Long
End Type

Private Type MapNpcRec
    num As Long
    target As Long
    TargetType As Byte
    Vital(1 To Vitals.Vital_Count - 1) As Long
    MAP As Long
    X As Byte
    Y As Byte
    Dir As Byte
    ' Client use only
    XOffset As Long
    YOffset As Long
    Moving As Byte
    Attacking As Byte
    AttackTimer As Long
    Step As Byte
       'Pet Data
    IsPet As Byte
    PetData As PetRec
End Type

Private Type TradeItemRec
    Item As Long
    ItemValue As Long
    CostItem As Long
    CostValue As Long
End Type

Private Type ShopRec
    name As String * NAME_LENGTH
    BuyRate As Long
    TradeItem(1 To MAX_TRADES) As TradeItemRec
End Type

Private Type SpellRec
    name As String * NAME_LENGTH
    Desc As String * 255
    Sound As String * NAME_LENGTH
    
    Type As Byte
    MPCost As Long
    LevelReq As Long
    AccessReq As Long
    ClassReq As Long
    CastTime As Long
    CDTime As Long
    Icon As Long
    MAP As Long
    X As Long
    Y As Long
    Dir As Byte
    Vital As Long
    Duration As Long
    Interval As Long
    Range As Byte
    IsAoE As Boolean
    AoE As Long
    CastAnim As Long
    SpellAnim As Long
    StunDuration As Long
    'SPELLRETA
    Dist As Byte
    Expelir As Byte
    Multipla As Byte
    RetaAnim(1 To 4) As Long
    MultiAnim As Byte
    'ARROW
    'Arrow As Long
    'Script
    Script As Long
    'Stats Baseados
    BaseStat As Byte
    ReqTrans As Byte
    ReqDojutsu As Byte
    ReqVila As Byte
    IsPush As Byte
    PetNum As Long
End Type

Private Type TempTileRec
    DoorOpen As Byte
    DoorFrame As Byte
    DoorTimer As Long
    DoorAnimate As Byte ' 0 = nothing| 1 = opening | 2 = closing
End Type

Public Type MapResourceRec
    X As Long
    Y As Long
    ResourceState As Byte
End Type

Private Type ResourceRec
    name As String * NAME_LENGTH
    SuccessMessage As String * NAME_LENGTH
    EmptyMessage As String * NAME_LENGTH
    Sound As String * NAME_LENGTH
    
    ResourceType As Byte
    ResourceImage As Long
    ExhaustedImage As Long
    ItemReward As Long
    ToolRequired As Long
    health As Long
    RespawnTime As Long
    Walkthrough As Boolean
    Animation As Long
End Type

Private Type ActionMsgRec
    message As String
    Created As Long
    Type As Long
    color As Long
    Scroll As Long
    X As Long
    Y As Long
    Timer As Long
End Type

Private Type BloodRec
    Sprite As Long
    Timer As Long
    X As Long
    Y As Long
End Type

Private Type AnimationRec
    name As String * NAME_LENGTH
    Sound As String * NAME_LENGTH
    
    Sprite(0 To 1) As Long
    Frames(0 To 1) As Long
    LoopCount(0 To 1) As Long
    loopTime(0 To 1) As Long
End Type

Private Type AnimInstanceRec
    Animation As Long
    X As Long
    Y As Long
    ' used for locking to players/npcs
    LockIndex As Long
    LockType As Byte
    ' timing
    Timer(0 To 1) As Long
    ' rendering check
    Used(0 To 1) As Boolean
    ' counting the loop
    LoopIndex(0 To 1) As Long
    FrameIndex(0 To 1) As Long
End Type

Public Type HotbarRec
    Slot As Long
    sType As Byte
End Type

Public Type ButtonRec
    filename As String
    state As Byte
End Type

Type DropRec 'temperatura
    X As Long
    Y As Long
    ySpeed As Long 'weather
    xSpeed As Long
    Init As Boolean
End Type

Private Type TopLvlRec
    Nome As String * NAME_LENGTH
    Nivel As Long
End Type

Private Type TopHeroRec
    Nome As String
    Pts As String
End Type

Private Type TopPkRec
    Nome As String
    Pts As String
End Type

Private Type TopPvPRec
    Nome As String
    V As String 'Vitorias
    d As String 'Derrotas
End Type


Private Type TopCharRec
    Char As String 'Nome do perso
    Nome As String 'nome do player
    Level As Long 'Level do Player
End Type

Private Type ExameEscritoRec
    Pergunta As String * 255
    Resposta(1 To 4) As String * 255
    RespostaCerta As String * 255
    Usado As Byte
End Type

Private Type arenaRec
    Nome As String
    Ocupada As Byte
End Type
