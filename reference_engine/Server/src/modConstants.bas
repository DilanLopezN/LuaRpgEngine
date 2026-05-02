Attribute VB_Name = "modConstants"
Option Explicit

' API
Public Declare Sub CopyMemory Lib "Kernel32.dll" Alias "RtlMoveMemory" (Destination As Any, Source As Any, ByVal Length As Long)
Public Declare Function CallWindowProc Lib "user32" Alias "CallWindowProcA" (ByVal lpPrevWndFunc As Long, ByVal hWnd As Long, ByRef Msg() As Byte, ByVal wParam As Long, ByVal lParam As Long) As Long

Public ShutAll As Byte
Public ShutGlobal As Byte
Public Const MAX_CLASS_TEMP As Byte = 43

' path constants
Public Const ADMIN_LOG As String = "admin.log"
Public Const PLAYER_LOG As String = "player.log"

' Version constants
Public Const CLIENT_MAJOR As Long = 7
Public Const CLIENT_MINOR As Long = 0
Public Const CLIENT_REVISION As Long = 250
Public Const MAX_LINES As Long = 500 ' Used for frmServer.txtText

' ********************************************************
' * The values below must match with the client's values *
' ********************************************************
' General constants
Public Const RESET_LEVEL As Integer = 700
Public Const MAX_PLAYERS As Long = 200
Public Const MAX_ITEMS As Long = 255
Public Const MAX_NPCS As Long = 255
Public Const MAX_ANIMATIONS As Long = 255
Public Const MAX_INV As Long = 35
Public Const MAX_MAP_ITEMS As Long = 255
Public Const MAX_MAP_NPCS As Long = 30
Public Const MAX_SHOPS As Long = 50
Public Const MAX_PLAYER_SPELLS As Long = 35
Public Const MAX_SPELLS As Long = 350
Public Const MAX_TRADES As Long = 30
Public Const MAX_RESOURCES As Long = 100
Public Const MAX_LEVELS As Long = 10000
Public Const MAX_BANK As Long = 99
Public Const MAX_HOTBAR As Long = 12
Public Const MAX_PARTYS As Long = 150
Public Const MAX_PARTY_MEMBERS As Long = 4
Public Const MAX_QUESTS As Long = 255
Public Const MAX_PLAYER_PROJECTILES As Long = 20
Public Const MAX_ORGS As Byte = 50
Public Const MAX_ORG_MEMBERS As Byte = 16
Public Const MAX_LIMIT_TIP As Long = 500

' server-side stuff
Public Const ITEM_SPAWN_TIME As Long = 5000 ' 30 seconds
Public Const ITEM_DESPAWN_TIME As Long = 90000 ' 1:30 seconds
Public Const MAX_DOTS As Long = 30

' text color constants
Public Const Black As Byte = 0
Public Const Blue As Byte = 1
Public Const Green As Byte = 2
Public Const Cyan As Byte = 3
Public Const Red As Byte = 4
Public Const Magenta As Byte = 5
Public Const Brown As Byte = 6
Public Const Grey As Byte = 7
Public Const DarkGrey As Byte = 8
Public Const BrightBlue As Byte = 9
Public Const BrightGreen As Byte = 10
Public Const BrightCyan As Byte = 11
Public Const BrightRed As Byte = 12
Public Const Pink As Byte = 13
Public Const Yellow As Byte = 14
Public Const White As Byte = 15
Public Const SayColor As Byte = White
Public Const GlobalColor As Byte = BrightBlue
Public Const BroadcastColor As Byte = White
Public Const TellColor As Byte = BrightGreen
Public Const EmoteColor As Byte = BrightCyan
Public Const AdminColor As Byte = BrightCyan
Public Const HelpColor As Byte = BrightBlue
Public Const WhoColor As Byte = BrightBlue
Public Const JoinLeftColor As Byte = DarkGrey
Public Const NpcColor As Byte = Brown
Public Const AlertColor As Byte = Red
Public Const NewMapColor As Byte = BrightBlue

' Boolean constants
Public Const NO As Byte = 0
Public Const YES As Byte = 1

' String constants
Public Const NAME_LENGTH As Byte = 20
Public Const ACCOUNT_LENGTH As Byte = 12

' Sex constants
Public Const SEX_MALE As Byte = 0
Public Const SEX_FEMALE As Byte = 1

' Map constants
Public Const MAX_MAPS As Long = 300
Public Const MAX_MAPX As Byte = 19
Public Const MAX_MAPY As Byte = 14
Public Const MAP_MORAL_NONE As Byte = 0
Public Const MAP_MORAL_SAFE As Byte = 1

' Tile consants
Public Const TILE_TYPE_WALKABLE As Byte = 0
Public Const TILE_TYPE_BLOCKED As Byte = 1
Public Const TILE_TYPE_WARP As Byte = 2
Public Const TILE_TYPE_ITEM As Byte = 3
Public Const TILE_TYPE_NPCAVOID As Byte = 4
Public Const TILE_TYPE_KEY As Byte = 5
Public Const TILE_TYPE_KEYOPEN As Byte = 6
Public Const TILE_TYPE_RESOURCE As Byte = 7
Public Const TILE_TYPE_DOOR As Byte = 8
Public Const TILE_TYPE_NPCSPAWN As Byte = 9
Public Const TILE_TYPE_SHOP As Byte = 10
Public Const TILE_TYPE_BANK As Byte = 11
Public Const TILE_TYPE_HEAL As Byte = 12
Public Const TILE_TYPE_TRAP As Byte = 13
Public Const TILE_TYPE_SLIDE As Byte = 14
Public Const TILE_TYPE_ONCLICK As Byte = 15
Public Const TILE_TYPE_SCRIPT As Byte = 16

' Item constants
Public Const ITEM_TYPE_NONE As Byte = 0
Public Const ITEM_TYPE_WEAPON As Byte = 1
Public Const ITEM_TYPE_ARMOR As Byte = 2
Public Const ITEM_TYPE_HELMET As Byte = 3
Public Const ITEM_TYPE_SHIELD As Byte = 4
Public Const ITEM_TYPE_CONSUME As Byte = 5
Public Const ITEM_TYPE_KEY As Byte = 6
Public Const ITEM_TYPE_CURRENCY As Byte = 7
Public Const ITEM_TYPE_SPELL As Byte = 8
Public Const ITEM_TYPE_SCRIPT As Byte = 9

' Direction constants
Public Const DIR_UP As Byte = 0
Public Const DIR_DOWN As Byte = 1
Public Const DIR_LEFT As Byte = 2
Public Const DIR_RIGHT As Byte = 3

' Constants for player movement
Public Const MOVING_WALKING As Byte = 1
Public Const MOVING_RUNNING As Byte = 2

' Admin constants
Public Const ADMIN_MONITOR As Byte = 2
Public Const ADMIN_MAPPER As Byte = 3
Public Const ADMIN_DEVELOPER As Byte = 4
Public Const ADMIN_CREATOR As Byte = 5

' NPC constants
Public Const NPC_BEHAVIOUR_ATTACKONSIGHT As Byte = 0
Public Const NPC_BEHAVIOUR_ATTACKWHENATTACKED As Byte = 1
Public Const NPC_BEHAVIOUR_FRIENDLY As Byte = 2
Public Const NPC_BEHAVIOUR_SHOPKEEPER As Byte = 3
Public Const NPC_BEHAVIOUR_GUARD As Byte = 4
Public Const NPC_BEHAVIOUR_SUBORDINADO As Byte = 5
Public Const NPC_BEHAVIOUR_BOSS As Byte = 6

' Spell constants
Public Const SPELL_TYPE_DAMAGEHP As Byte = 0
Public Const SPELL_TYPE_DAMAGEMP As Byte = 1
Public Const SPELL_TYPE_HEALHP As Byte = 2
Public Const SPELL_TYPE_HEALMP As Byte = 3
Public Const SPELL_TYPE_WARP As Byte = 4
Public Const SPELL_TYPE_RETA As Byte = 5
Public Const SPELL_TYPE_SCRIPT As Byte = 6
Public Const SPELL_TYPE_PET As Byte = 7
Public Const SPELL_TYPE_AREA As Byte = 8

' Game editor constants
Public Const EDITOR_ITEM As Byte = 1
Public Const EDITOR_NPC As Byte = 2
Public Const EDITOR_SPELL As Byte = 3
Public Const EDITOR_SHOP As Byte = 4
Public Const EDITOR_QUEST As Byte = 5

' Target type constants
Public Const TARGET_TYPE_NONE As Byte = 0
Public Const TARGET_TYPE_PLAYER As Byte = 1
Public Const TARGET_TYPE_NPC As Byte = 2

' ********************************************
' Default starting location [Server Only]
Public START_MAP(1 To 4) As Long
Public START_X(1 To 4) As Long
Public START_Y(1 To 4) As Long

' Scrolling action message constants
Public Const ACTIONMSG_STATIC As Long = 0
Public Const ACTIONMSG_SCROLL As Long = 1
Public Const ACTIONMSG_SCREEN As Long = 2

' Quests constants
Public Const QUEST_TYPE_ITEM As Byte = 1
Public Const QUEST_TYPE_NPC As Byte = 2
Public Const QUEST_TYPE_TALKTO As Byte = 3
Public Const QUEST_TYPE_MAP As Byte = 4
Public Const QUEST_TYPE_LEVEL As Byte = 5
Public Const QUEST_TYPE_KILLPLAYER As Byte = 6
Public Const QUEST_TYPE_SPELL As Byte = 7

Public Const RANK_ESTUDANTE As Byte = 1
Public Const RANK_GENIN As Byte = 2
Public Const RANK_CHUNIN As Byte = 3
Public Const RANK_JOUNIN As Byte = 4
Public Const RANK_ANBU As Byte = 5
Public Const RANK_SANNIN As Byte = 6
Public Const RANK_KAGE As Byte = 7
Public Const RANK_DESERTOR As Byte = 8

Public Const ORG_POLICIAKONOHA As Byte = 1
Public Const ORG_HOSPITAL As Byte = 2
Public Const ORG_TAKA As Byte = 3
Public Const ORG_AKATSUKI As Byte = 4
'Public Const ORG_ANBU As Byte = 5
Public Const ORG_ANBURAIZ As Byte = 6
Public Const ORG_7ESPADACHINS As Byte = 7
Public Const ORG_12GUARDIOES As Byte = 8
'Public Const ORG_ALIANÇA As Byte = 11
'Public Const ORG_NULA As Byte = 9
'Public Const ORG_RENEGADOS As Byte = 10
Public Const ORG_FREE As Byte = 12
Public Const ORG_ESQUADRAO As Byte = 13
Public Const ORG_RENEGADOS As Byte = 14

Public Const NARUTO As Byte = 1
Public Const SASUKE As Byte = 2
Public Const SAKURA As Byte = 3
Public Const INO As Byte = 4
Public Const SHIKAMARU As Byte = 5
Public Const CHOUJI As Byte = 6
Public Const LEE As Byte = 7
Public Const NEJI As Byte = 8
Public Const TENTEN As Byte = 9
Public Const KIBA As Byte = 10
Public Const SHINO As Byte = 11
Public Const GAARA As Byte = 12
Public Const KANKUROU As Byte = 13
Public Const TEMARI As Byte = 14
Public Const HINATA As Byte = 15
Public Const SAI As Byte = 16
Public Const YONDAIME As Byte = 17
Public Const KISAME As Byte = 18
Public Const DEIDARA As Byte = 19
Public Const ITACHI As Byte = 20
Public Const KIMIMARU As Byte = 21
Public Const JIRAYA As Byte = 22
Public Const TSUNADE As Byte = 23
Public Const KAKASHI As Byte = 24
Public Const PAIN As Byte = 25
Public Const MADARA As Byte = 26
Public Const TOBI As Byte = 27
Public Const OROCHIMARU As Byte = 28
Public Const HAKU As Byte = 29
Public Const ZABUZA As Byte = 30
Public Const BEE As Byte = 31
Public Const HASHIRAMA As Byte = 32
Public Const YAMATO As Byte = 33
Public Const KONAN As Byte = 34
Public Const RAIKAGE As Byte = 35
Public Const DARUI As Byte = 36
Public Const HIDAN As Byte = 37
Public Const SASORI As Byte = 38
Public Const DANZOU As Byte = 39
Public Const YUGITO As Byte = 40
Public Const TOBIRAMA As Byte = 41
Public Const GAI As Byte = 42
Public Const MEI As Byte = 43

Public Const TORNEIO_CS As Byte = 1
Public Const TORNEIO_POKEMON As Byte = 2
Public Const TORNEIO_DESAFIOS As Byte = 3
Public Const TORNEIO_SEMANAL As Byte = 4
Public Const TORNEIO_KAGE_KONOHA As Byte = 5
Public Const TORNEIO_KAGE_SUNA As Byte = 6
Public Const TORNEIO_KAGE_KIRI As Byte = 7
Public Const TORNEIO_KAGE_IWA As Byte = 8
Public Const TORNEIO_KAGE_KUMO As Byte = 9
Public Const TORNEIO_KAGE_CHUVA As Byte = 10
Public Const TORNEIO_LENDARIO As Byte = 11
Public Const TORNEIO_LUTA As Byte = 12
Public Const TORNEIO_KAGE_SOM As Byte = 13
Public Const TORNEIO_GUERRA As Byte = 14

Public Const CHAT_PEDIDO As Byte = 1
Public Const CHAT_RECUSADO As Byte = 2
Public Const CHAT_ACEITO As Byte = 3
Public Const CHAT_MSG As Byte = 4
Public Const CHAT_CLOSE As Byte = 5

'values
Public Const MAX_BYTE As Byte = 255
Public Const MAX_INTEGER As Integer = 32767
Public Const MAX_LONG As Long = 2147483647

' Do Events
Public Const nLng As Long = (&H80 Or &H1 Or &H4 Or &H20) + (&H8 Or &H40)
