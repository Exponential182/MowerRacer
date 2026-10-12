extends PanelContainer
class_name MowerCustomiseItem

@export var mower_customise_menu : MowerCustomiseMenu
@export var moweritem : MowerItem

@onready var _tex: TextureRect = $_tex

func _ready() -> void:
	if moweritem:
		_tex.texture = moweritem.mower_item_icon

func _process(delta: float) -> void:
	if mower_customise_menu.active:
		focus_mode = Control.FOCUS_ALL
	else:
		focus_mode = Control.FOCUS_NONE
		
