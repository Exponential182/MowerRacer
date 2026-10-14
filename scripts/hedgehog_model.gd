extends MeshInstance3D

@export var stiffness: float = 120.0
@export var damping: float = 12.0
@export var wobble_factor: float = 5.0
@export var speed_wobble_frequency: float = 4.0
@export var speed_wobble_amplitude: float = 0.015 # Reduced by 10x for a very subtle flutter
@export var max_offset: float = 0.25
@export var turn_bank_amount: float = 0.5 # How much the parent turns/leans on the Y axis when steering

var _velocity_x: float = 0.0
var _offset_x: float = 0.0
var _prev_parent_pos: Vector3 = Vector3.ZERO
var _smoothed_accel: Vector3 = Vector3.ZERO
var _character_body: Node = null
var _parent_node: Node3D = null

func _ready() -> void:
	_parent_node = get_parent() as Node3D
	if _parent_node:
		_character_body = _parent_node.get_parent()
		if _character_body:
			_prev_parent_pos = _character_body.global_position

func _physics_process(delta: float) -> void:
	if not _character_body or not _parent_node:
		return

	var current_parent_pos: Vector3 = _character_body.global_position
	var raw_world_accel: Vector3 = (current_parent_pos - _prev_parent_pos) / delta
	_prev_parent_pos = current_parent_pos

	var raw_local_accel: Vector3 = _character_body.global_transform.basis.inverse() * raw_world_accel
	_smoothed_accel = _smoothed_accel.lerp(raw_local_accel, 12.0 * delta)

	var speed_ratio: float = 0.0
	if "current_speed" in _character_body and "max_speed" in _character_body and _character_body.max_speed > 0:
		speed_ratio = clamp(_character_body.current_speed / _character_body.max_speed, 0.0, 1.0)

	# Read turning input (-1 for left, 1 for right)
	var turn_input: float = Input.get_axis("ui_left", "ui_right")

	# Speed-based wobble on the Y-axis (now heavily dialed down)
	var speed_wobble_y: float = sin(Time.get_ticks_msec() * 0.001 * speed_wobble_frequency) * speed_wobble_amplitude * speed_ratio

	# Spring physics on the mesh X-axis for localized jiggle
	var force_x: float = -_offset_x * stiffness - _velocity_x * damping - (_smoothed_accel.x * wobble_factor)
	_velocity_x += force_x * delta
	_offset_x += _velocity_x * delta
	_offset_x = clamp(_offset_x, -max_offset, max_offset)

	# Position the mesh locally for spring jiggle
	position = Vector3(_offset_x, 0.0, 0.0)
	
	# Apply Y-axis rotation to the parent node with inverted turn input (-turn_input)
	_parent_node.rotation.y = (-turn_input * turn_bank_amount) + speed_wobble_y
	$"../../Lawnmower_wheels/Cylinder".rotation.y = 45 +(-turn_input * turn_bank_amount) + speed_wobble_y
	$"../../Lawnmower_wheels/Cylinder_001".rotation.y = 45 +(-turn_input * turn_bank_amount) + speed_wobble_y
	# Squash and stretch mesh slightly during lateral movement
	scale = Vector3(
		1.0 - abs(_offset_x) * 0.3,
		1.0,
		1.0
	)
