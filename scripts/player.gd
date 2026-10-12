extends CharacterBody3D

@export var max_speed: float = 15.0
@export var acceleration: float = 6.0
@export var deceleration: float = 8.0
@export var turn_speed: float = 2.5

var current_speed: float = 0.0

@onready var Speedometer = $"../CanvasLayer/Label"

func _physics_process(delta: float) -> void:
	# 1. Handle Steering (A/D or Left/Right arrows)
	# We scale steering by speed so the car doesn't spin in place when stopped
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
