Attribute VB_Name = "modTypes"
Option Explicit

' Public data structures
Public Map(1 To MAX_MAPS) As MapRec
Public MapCache(1 To MAX_MAPS) As Cache
Public TempTile(1 To MAX_MAPS) As TempTileRec
Public PlayersOnMap(1 To MAX_MAPS) As Long
Public ResourceCache(1 To MAX_MAPS) As ResourceCacheRec
Public Player(1 To MAX_PLAYERS) As PlayerRec
Public Bank(1 To MAX_PLAYERS) As BankRec
Public TempPlayer(1 To MAX_PLAYERS) As TempPlayerRec
Public Class() As ClassRec
Public Item(1 To MAX_ITEMS) As ItemRec
Public Npc(1 To MAX_NPCS) As NpcRec
Public MapItem(1 To MAX_MAPS, 1 To MAX_MAP_ITEMS) As MapItemRec
Public MapNpc(1 To MAX_MAPS) As MapDataRec
Public Shop(1 To MAX_SHOPS) As ShopRec
Public Spell(1 To MAX_SPELLS) As SpellRec
Public Resource(1 To MAX_RESOURCES) As ResourceRec
Public Animation(1 To MAX_ANIMATIONS) As AnimationRec
Public Party(1 To MAX_PARTYS) As PartyRec
Public Quest(1 To MAX_QUESTS) As QuestRec
Public TopLvl(1 To 20) As TopLvlRec
Public TopHero(1 To 10) As TopHeroRec
Public TopPK(1 To 10) As TopPkRec
Public TopPvP(1 To 10) As TopPvPRec
Public TopChar(1 To MAX_CLASS_TEMP) As TopCharRec
Public Arena(1 To 9) As ArenaRec
Public CharJutsus(1 To MAX_CLASS_TEMP) As CharJutsusRec
Public War As WarRec
Public Luta As LutaRec
Public TorneioData As TorneioDataRec
Public Org(1 To MAX_ORGS) As OrgRec
Public SemTip(1 To MAX_LIMIT_TIP) As String
Public Mutado(1 To MAX_PLAYERS) As String
Public PlayerBerserker(1 To MAX_PLAYERS) As String
Public AntiFK(1 To MAX_PLAYERS) As String

Public antiFkTimer As Long

Public Options As OptionsRec

Private Type OptionsRec
    Game_Name As String
    MOTD As String
    Port As Long
    Website As String
End Type

Public Type PartyRec
    Leader As Long
    Member(1 To MAX_PARTY_MEMBERS) As Long
    MemberCount As Long
End Type

Public Type PlayerInvRec
    num As Long
    Value As Long
End Type

Private Type Cache
    Data() As Byte
End Type

Private Type BankRec
    Item(1 To MAX_BANK) As PlayerInvRec
End Type

Public Type HotbarRec
    Slot As Long
    sType As Byte
End Type


Private Type QuestRec
     'Informações
    Name As String * NAME_LENGTH
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
    ReqVila As Byte
    ReqElemento As Byte
    'Tarefas
    Item(1 To 5) As Integer
    ItemQnt(1 To 5) As Long
    Npc(1 To 5) As Integer
    NpcQnt(1 To 5) As Long
    Map As Integer
    NeedLevel As Integer
    KillPlayerQnt As Long
    KillPlayerClass As Byte
    UsarSpell As Integer
    UsarSpellQnt As Integer
    'Recompensa
    rItem(1 To 5) As Integer
    rItemQnt(1 To 5) As Long
    rSpell As Integer
    rEXP As Long
    rSprite As Integer
    rClasse As Byte
    rRank As Byte
    rOrg As Byte
    rElemento As Byte
    'SCRIPT
    rEndScript As Integer
    'SERVER SIDE
    Status As Byte
    QuestNpc(1 To 10) As Integer
End Type

Public Type PetRec
    SpriteNum As Byte
    Name As String * 50
    Owner As Long
    
    PetLevel(1 To MAX_NPCS) As Byte
    PetNextLevel(1 To MAX_NPCS) As Long
    PetExp(1 To MAX_NPCS) As Long
    PetDamage(1 To MAX_NPCS) As Long
    PetHP(1 To MAX_NPCS) As Long
    PetMaxHP(1 To MAX_NPCS) As Long
    'PetSpell(1 To MAX_NPCS) As Integer
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
    Dias As String
    Data As String
End Type

Private Type PvPRec
    V As Long
    D As Long
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
    Anim As Long
    IsSpell As Long
    Especial As Byte
    PassOver As Byte
End Type

Private Type PlayerRec
    ' Account
    Login As String * ACCOUNT_LENGTH
    Password As String * NAME_LENGTH
    
    ' General
    Name As String * ACCOUNT_LENGTH
    Sex As Byte
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
    
    Trans As Byte
    Voando As Byte
    
    QuestNum(1 To 10) As Integer
    QuestInfo(1 To 10) As QuestRec
    QuestCompleta(1 To MAX_QUESTS) As Integer
    
    ' Vitals
    Vital(1 To Vitals.Vital_Count - 1) As Long
    
    ' Stats
    Stat(1 To Stats.Stat_Count - 1) As Long
    POINTS As Long
    
    ' Worn equipment
    Equipment(1 To Equipment.Equipment_Count - 1) As Long
    
    ' Inventory
    Inv(1 To MAX_INV) As PlayerInvRec
    Spell(1 To MAX_PLAYER_SPELLS) As Long
    
    ' Hotbar
    Hotbar(1 To MAX_HOTBAR) As HotbarRec
    
    ' Position
    Map As Long
    X As Byte
    Y As Byte
    Dir As Byte
    
    Pet As PetRec
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
    Spec As Byte
    InTorneio As Byte
    Amigos(1 To 50) As String
    War As Byte
    WarPoints As Long
    Restarted As Byte
End Type

Public Type SpellBufferRec
    Spell As Long
    Timer As Long
    Target As Long
    tType As Byte
End Type

Public Type DoTRec
    Used As Boolean
    Spell As Long
    Timer As Long
    Caster As Long
    StartTime As Long
End Type

Private Type MapTeleportRec
    X As Byte
    Y As Byte
    Ativo As Byte
End Type

Public Type TempPlayerRec
    ' Non saved local vars
    Buffer As clsBuffer
    InGame As Boolean
    AttackTimer As Long
    DataTimer As Long
    DataBytes As Long
    DataPackets As Long
    targetType As Byte
    Target As Long
    GettingMap As Byte
    SpellCD(1 To MAX_PLAYER_SPELLS) As Long
    InShop As Long
    StunTimer As Long
    StunDuration As Long
    InBank As Boolean
    ' trade
    TradeRequest As Long
    InTrade As Long
    TradeOffer(1 To MAX_INV) As PlayerInvRec
    AcceptTrade As Boolean
    ' dot/hot
    DoT(1 To MAX_DOTS) As DoTRec
    HoT(1 To MAX_DOTS) As DoTRec
    ' spell buffer
    spellBuffer As SpellBufferRec
    ' regen
    stopRegen As Boolean
    stopRegenTimer As Long
    ' party
    inParty As Long
    partyInvite As Long
    Hit(1 To 2) As Byte
    HitQnt(1 To 2) As Long
    Aura As Long
    Kawarimi As Long
    TempPetSlot As Byte
    Dojutsu(1 To 5) As Long
    AndandoAgua As Byte
    Henge As Long
    MySprite As Long
    Reflect As Long
    LogTrain As Long
    ArrowTime As Long
    Mute As Byte
    MsgDelay As Long
    SpellDelay As Long
    ExpelDelay As Long
    'Aviso pras missões
    QuestAviso(1 To MAX_NPCS) As Byte
    'Checks contra HACK
    GanhouEXP As Byte
    SetExp As Byte
    SetPoints As Byte
    SetLevel As Byte
    '///////
    InArena As Byte
    AceitouDesafio As Byte
    ProjecTile(1 To MAX_PLAYER_PROJECTILES) As ProjectileRec
    MapTeleport As MapTeleportRec
    SharinganCopy As Long
    tmpSpell As Integer
    InChat As Long
    Contagem As Byte
    ExameEscrito As Byte
    KilledName As String * NAME_LENGTH
    KilledCount As Integer
    SemRoupa As Byte
    TempoTroca As Byte
    EquipTmr As Long
    npcsMortos As Long
    Lendario As Byte
    NoDamage As Long
    KarmaTradeIndex As Long
    KarmaTradeQnt As Long
    KarmaTradeOwner As Byte
    mutedPlayers(1 To 10) As String
    playerAttackerOrVictim As Long
    berserkerMode As Byte
    hitNpcPinhata As Byte
    hitNpcUp As Long
    firstLogin As Boolean
End Type

Private Type TileDataRec
    X As Long
    Y As Long
    Tileset As Long
End Type

Private Type TileRec
    Layer(1 To MapLayer.Layer_Count - 1) As TileDataRec
    Type As Byte
    Data1 As Long
    Data2 As Long
    Data3 As Long
    DirBlock As Byte
    Animation As Long 'animação
End Type

Private Type MapRec
    Name As String * NAME_LENGTH
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
    Name As String * NAME_LENGTH
    Stat(1 To Stats.Stat_Count - 1) As Byte
    MaleSprite() As Long
    FemaleSprite() As Long
    
    startItemCount As Long
    StartItem() As Long
    StartValue() As Long
    
    startSpellCount As Long
    StartSpell() As Long
    
    Locked As Byte
End Type

Private Type ItemRec
    Name As String * NAME_LENGTH
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
    price As Long
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
    'Arrow As Long
End Type

Private Type MapItemRec
    num As Long
    Value As Long
    X As Byte
    Y As Byte
    ' ownership + despawn
    playerName As String
    playerTimer As Long
    canDespawn As Boolean
    despawnTimer As Long
End Type

Private Type NpcRec
    Name As String * NAME_LENGTH
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
    Target As Long
    targetType As Byte
    Vital(1 To Vitals.Vital_Count - 1) As Long
    X As Byte
    Y As Byte
    Dir As Byte
    ' For server use only
    SpawnWait As Long
    AttackTimer As Long
    StunDuration As Long
    StunTimer As Long
    ' regen
    stopRegen As Boolean
    stopRegenTimer As Long
    ' dot/hot
    DoT(1 To MAX_DOTS) As DoTRec
    HoT(1 To MAX_DOTS) As DoTRec
    
    'Pet Data
    IsPet As Byte
    PetData As PetRec
    NpcSpell As Long
End Type

Private Type TradeItemRec
    Item As Long
    ItemValue As Long
    costitem As Long
    costvalue As Long
End Type

Private Type ShopRec
    Name As String * NAME_LENGTH
    BuyRate As Long
    TradeItem(1 To MAX_TRADES) As TradeItemRec
End Type

Private Type SpellRec
    Name As String * NAME_LENGTH
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
    Map As Long
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
    DoorOpen() As Byte
    DoorTimer As Long
End Type

Private Type MapDataRec
    Npc() As MapNpcRec
End Type

Private Type MapResourceRec
    ResourceState As Byte
    ResourceTimer As Long
    X As Long
    Y As Long
    cur_health As Long
End Type

Private Type ResourceCacheRec
    Resource_Count As Long
    ResourceData() As MapResourceRec
End Type

Private Type ResourceRec
    Name As String * NAME_LENGTH
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

Private Type AnimationRec
    Name As String * NAME_LENGTH
    Sound As String * NAME_LENGTH
    
    Sprite(0 To 1) As Long
    Frames(0 To 1) As Long
    LoopCount(0 To 1) As Long
    LoopTime(0 To 1) As Long
End Type

Private Type TopLvlRec
    Nome As String
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
    D As String 'Derrotas
End Type

Private Type TopCharRec
    Char As String 'Nome do perso
    Nome As String 'nome do player
    Level As String 'Level do Player
End Type

Private Type ArenaRec
    Map As Long
    IsActive As Byte
    tipo As Byte '0=1x1,1=1x2,2=2x1,3=2x2
    p(1 To 2) As Long
    p2(1 To 2) As Long
    pResta As Byte
    p2Resta As Byte
    WaitTmr As Long
End Type

Private Type CharJutsusRec
    Level As Long
    JutsuNum(1 To MAX_PLAYER_SPELLS) As Long
End Type

Private Type LutaRec
    Player(1 To 3) As Long
    PlayerQnt As Long
End Type

Private Type TorneioDataRec
    Participante(1 To MAX_PLAYERS) As Long
    pTotal As Long
    pUsados(1 To MAX_PLAYERS) As Long
End Type

Private Type WarRec
    PlayerCount(1 To 2) As Long
    Killer(1 To 2) As Long
    Pts(1 To 2) As Long
End Type

Private Type OrgRec
    MembrosTotal As Byte
    orgCarregada As Byte
    MembroLogin(1 To 21) As String * ACCOUNT_LENGTH
    MembroNome(1 To 21) As String * ACCOUNT_LENGTH
    MembroAcesso(1 To 21) As Byte
End Type

