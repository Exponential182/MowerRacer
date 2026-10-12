extends PanelContainer
class_name MowerCustomiseMenu

@export var player : int = 0
@export var active : bool = false

@onready var _cam: Camera3D = %_cam
@onready var _mesh_pivot: Node3D = %_mesh_pivot
@onready var _children: VBoxContainer = $VBoxContainer
@onready var _press_any_button: RichTextLabel = $_press_any_button


var time := 0.0
var phase_differance := 0.0

const SELECTED_CONTAINER = preload("uid://bb2hplx4whifj")
const EMPTY = preload("uid://cxjw8sqe1aa30")

func _ready() -> void:
	focus_mode = Control.FOCUS_NONE
	phase_differance = randf_range(-2*PI,2*PI)
	_mesh_pivot.rotation.y += phase_differance

func _process(delta: float) -> void:
	time += delta
	_mesh_pivot.rotation.y += delta
	_cam.look_at(_mesh_pivot.position)
	_cam.position.y = (sin(time + phase_differance)) * 2
	
	if active:
		add_theme_stylebox_override("panel",SELECTED_CONTAINER)
		_press_any_button.hide()
		_children.modulate.a = 1.0
		
	
	else:
		add_theme_stylebox_override("panel",EMPTY)
		_press_any_button.show()
		_children.modulate.a = 0.5
		
func focus():
	$VBoxContainer/HBoxContainer/_mower_customise_item.focus_mode = Control.FOCUS_ALL
	$VBoxContainer/HBoxContainer/_mower_customise_item.grab_focus()
	
	
