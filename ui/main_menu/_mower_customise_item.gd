extends PanelContainer
class_name MowerCustomiseItem

var selected : bool = false

static var selected_mowers : Array[MowerCustomiseItem]
static var selected_wraps : Array[MowerCustomiseItem]
static var selected_paints : Array[MowerCustomiseItem]

@export var mower_customise_menu : MowerCustomiseMenu
@export var moweritem : MowerItem

@onready var _tex: TextureRect = $_tex

func _ready() -> void:
	if moweritem:
		_tex.texture = moweritem.mower_item_icon

func _process(delta: float) -> void:
	if moweritem:
		selected = false
		match moweritem.mower_item_type:
			MowerItem.MOWER_ITEM_TYPES.MOWER:
				if moweritem == GameStateManager.players[mower_customise_menu.player].player_mower_type:
					selected = true
			MowerItem.MOWER_ITEM_TYPES.PAINT:
				if moweritem == GameStateManager.players[mower_customise_menu.player].player_mower_color:
					selected = true
			MowerItem.MOWER_ITEM_TYPES.WRAP:
				if moweritem == GameStateManager.players[mower_customise_menu.player].player_mower_wrap:
					selected = true
	
	if selected:
		modulate.a = 0.25
	else:
		modulate.a = 1.0
	
	if mower_customise_menu.active:
		focus_mode = Control.FOCUS_ALL
	else:
		focus_mode = Control.FOCUS_NONE
		
