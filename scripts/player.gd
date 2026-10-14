extends CharacterBody3D

@export var max_speed: float = 15.0
@export var acceleration: float = 6.0
@export var deceleration: float = 8.0
@export var turn_speed: float = 2.5

var current_speed: float = 0.0
var current_item = null

@onready var Speedometer = $"CanvasLayer/Label"
@onready var Item_display = $"CanvasLayer/Label2"
@onready var Item_spawn_position = $Item_spawn_pos
@onready var Cube = preload("res://prefabs/cube.tscn")

func _ready() -> void:
	self.add_to_group("player")
	
	
func _physics_process(delta: float) -> void:
	# 1. Handle Steering (A/D or Left/Right arrows)
	# We scale steering by speed so the car doesn't spin in place when stopped
	if Input.is_action_just_pressed("use") and current_item != null:
		use_item()
	var steering_input := Input.get_axis("ui_left", "ui_right")
	if steering_input != 0 and abs(current_speed) > 0.1:
		rotation.y -= steering_input * turn_speed * (current_speed / max_speed) * delta

	# 2. Handle Acceleration and Braking (W/S or Up/Down arrows)
	# ui_up / W moves forward, ui_down / S reverses or brakes
	var throttle_input := Input.get_axis("ui_down", "ui_up")
	if throttle_input != 0:
		current_speed += throttle_input * acceleration * delta
		current_speed = clamp(current_speed, -max_speed * 0.4, max_speed)
	else:
		# Natural drag/slowdown when no keys are pressed
		current_speed = move_toward(current_speed, 0, deceleration * delta)

	# 3. Apply gravity if the car is in the air (off ramps, etc.)
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 4. Move forward relative to where the car is facing (-Z is forward in Godot 3D)
	var forward_dir := -transform.basis.z
	velocity.x = forward_dir.x * current_speed
	velocity.z = forward_dir.z * current_speed
	
	Speedometer.text = "Speed: " + str(round(current_speed*10)/10)
	move_and_slide()
	
func use_item():
	if current_item == "Cube":
		var spawned_item = Cube.instantiate()
		get_node("/root/world/Items").add_child(spawned_item)
		spawned_item.position = Item_spawn_position.global_position
		spawned_item.rotation = self.rotation
	print(current_item)
	current_item = null
	update_item()
	
	
func update_item():
	if current_item == null:
		Item_display.text = "No Item"
	else:
		Item_display.text = current_item
