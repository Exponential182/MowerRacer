extends PanelContainer
class_name MowerCustomiseMenu

@export var player : int = 0
@export var active : bool = false

@onready var _cam: Camera3D = %_cam
@onready var _mesh_pivot: Node3D = %_mesh_pivot
@onready var _children: VBoxContainer = $VBoxContainer
@onready var _press_any_button: RichTextLabel = $_press_any_button

@onready var _mower_item_carousel: Control = $VBoxContainer/HBoxContainer/_item_carousel
@onready var _paint_item_carousel: Control = $VBoxContainer/HBoxContainer2/_item_carousel
@onready var _wrap_item_carousel: Control = $VBoxContainer/HBoxContainer3/_item_carousel
@onready var _disabled_color: TextureRect = $_disabled_color
@onready var _player_name: Label = $VBoxContainer/_player_name

@onready var _cam_pivot: Node3D = %_cam_pivot

var time := 0.0
var phase_differance := 0.0

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	phase_differance = randf_range(-2*PI,2*PI)
	_mesh_pivot.rotation.y += phase_differance

func _process(delta: float) -> void:
	time += delta * 0.5
	_cam_pivot.rotation.y += delta * 0.25
	_cam.look_at(_mesh_pivot.position)
	_cam.position.y = 2 +  ((sin(time + phase_differance)+1)*2)
	_cam.position.z = 4 + ((sin(0.5*time + phase_differance)+1)/2)
	
	_player_name.text = GameStateManager.players[player].player_name
	
	if active:
		_press_any_button.hide()
		_disabled_color.hide()
		
	else:
		_press_any_button.show()
		_disabled_color.show()
		
	GameStateManager.players[player].player_mower_type = _mower_item_carousel.items[_mower_item_carousel.selected_index]
	GameStateManager.players[player].player_mower_color = _paint_item_carousel.items[_mower_item_carousel.selected_index]
	GameStateManager.players[player].player_mower_wrap = _wrap_item_carousel.items[_mower_item_carousel.selected_index]
		
func focus():
	active = true
	_mower_item_carousel.focus_mode = Control.FOCUS_ALL
	_paint_item_carousel.focus_mode = Control.FOCUS_ALL
	_wrap_item_carousel.focus_mode = Control.FOCUS_ALL
	_mower_item_carousel.grab_focus()
	print(player)
	
func unfocus():
	active = false
	_mower_item_carousel.focus_mode = Control.FOCUS_NONE
	_paint_item_carousel.focus_mode = Control.FOCUS_NONE
	_wrap_item_carousel.focus_mode = Control.FOCUS_NONE
	
	
