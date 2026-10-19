extends RigidBody3D


@onready var camera: Camera3D = $camera

# Vectors
@onready var forward: Vector3
@onready var sideways: Vector3


# Balancing
var FLOAT_HEIGHT: float = 0.8 # NOTE: This isn't the actual value height
# This acts as an ideal spring. Height above ground is FLOAT_HEIGHT - disp
# disp = mass * 10 / (RAY_FORCE_STRENGTH * # of rays)
@onready var ray_fl: RayCast3D = $mesh/raycasts/front_left_cast
@onready var ray_fr: RayCast3D = $mesh/raycasts/front_right_cast
@onready var ray_rl: RayCast3D = $mesh/raycasts/rear_left_cast
@onready var ray_rr: RayCast3D = $mesh/raycasts/rear_right_cast
@onready var RAYCASTS = [ray_fl, ray_fr, ray_rl, ray_rr]


# Driving Control Parameters
var TOP_SPEED: float = 20.0
var RAY_FORCE_STRENGTH: float = 20.0
var RAY_FORCE_DAMPING: float = 8.0
var MAX_ACCEL_FORCE: float = 5.0
var MAX_COAST_FORCE: float = 0.5
var SLIDE_CATCH_PERCENTAGE: float = 0.7
var ALIGNMENT_TORQUE_STRENGTH: float = 30.0
var ALIGNMENT_TORQUE_DAMPING: float = 6.0
var ALIGNMENT_TORQUE_MAX: float = 50.0 
var STEER_SPEED = PI / 3.0


func _physics_process(delta):
	var cam_forward = -camera.global_basis.z
	cam_forward.y = 0.0
	forward = cam_forward.normalized()

	var cam_sideways = -camera.global_basis.x
	cam_sideways.y = 0.0
	sideways = cam_sideways.normalized()
	
	car_float()
	steering(delta)

	camera_track()
	handle_movement(delta)


func get_point_velocity(point: Vector3) -> Vector3:
	return linear_velocity + angular_velocity.cross(point - to_global(self.center_of_mass))


func car_float():
	for ray: RayCast3D in RAYCASTS:
		if ray.is_colliding():
			var pos: Vector3 = ray.global_position
			var collision_point: Vector3 = ray.get_collision_point()
			
			var distance: float = pos.distance_to(collision_point)
			var spring_dist: float = FLOAT_HEIGHT - distance
			
			var point_velocity: Vector3 = get_point_velocity(pos)
			var relative_velocity: float = Vector3.UP.dot(point_velocity)
			
			var force_mag: float = max(spring_dist * RAY_FORCE_STRENGTH - relative_velocity * RAY_FORCE_DAMPING, 0)
			apply_force(Vector3.UP * force_mag, pos - self.global_position)


func steering(delta):
	var steer_input: float = Input.get_axis("steer_right", "steer_left")

	camera.rotation.y += steer_input * delta * STEER_SPEED


func camera_track():
	var target_cam_pos = global_position + (camera.global_basis.z * 4.0) + (Vector3.UP * 1.5)
	camera.global_position = camera.global_position.lerp(target_cam_pos, 0.2)


func handle_movement(delta):
	# Forward
	var speed_input: float = Input.get_axis("brake", "accelerate")
	var desired_speed: float = speed_input * TOP_SPEED

	var current_forward_speed: float = forward.dot(linear_velocity)
	var instant_match_accel: float = (desired_speed - current_forward_speed) / delta

	var accel_force: float = mass * instant_match_accel
	var max_force: float = MAX_ACCEL_FORCE if abs(speed_input) > 0.5 else MAX_COAST_FORCE
	var limited_force: float = clampf(accel_force, -max_force, max_force)

	apply_central_force(forward * limited_force)

	# DRIFTING CONTROLS
	# if speed_input < 0.05 and _drift_dir != 0:
	# 	_drift_dir = 0

	# Drift
	var current_sideways_speed: float = sideways.dot(linear_velocity)
	var instant_side_match_accel: float = (0.0 - current_sideways_speed) / delta

	var side_force: float = instant_side_match_accel * mass
	var limited_side_force: float = side_force * SLIDE_CATCH_PERCENTAGE

	apply_central_force(sideways * limited_side_force)
	
	# Car Posing
	var hovercraft_forward: Vector3 = -global_basis.z
	var hovercraft_flat_forward: Vector3 = Vector3(hovercraft_forward.x, 0.0, hovercraft_forward.z)

	# if _drift_dir != 0:
	# 	var steer_input: float = Input.get_axis("steer_right", "steer_left")
	# 	var input_angle: float = steer_input  * deg_to_rad(15.0)
	# 	forward = forward.rotated(Vector3.UP, deg_to_rad(35.0 * _drift_dir) + input_angle)
	# elif _state >= State.PosedCar:
	# 	forward = forward.rotated(Vector3.UP, camera._pose_angle * 1.5)

	var angle_offset = hovercraft_flat_forward.signed_angle_to(forward, Vector3.UP)
	var angular_velocity_to_vertical = angular_velocity.dot(Vector3.UP)
	var turn_force = (angle_offset * ALIGNMENT_TORQUE_STRENGTH) - (angular_velocity_to_vertical * ALIGNMENT_TORQUE_DAMPING)
	var turn_forge_mag = clamp(turn_force, -ALIGNMENT_TORQUE_MAX, ALIGNMENT_TORQUE_MAX)
	var upright_factor: float = clamp(-global_basis.z.dot(forward), 0.0, 1.0)

	apply_torque(global_basis.y * turn_forge_mag * upright_factor)
