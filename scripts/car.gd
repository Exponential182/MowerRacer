extends RigidBody3D


# Balancing
var FLOAT_HEIGHT: float = 0.8 # NOTE: This isn't the actual value height
# This acts as an ideal spring. Height above ground is FLOAT_HEIGHT - disp
# disp = mass * 10 / (RAY_FORCE_STRENGTH * 4)
@onready var ray_fl: RayCast3D = $car/raycasts/front_left_cast
@onready var ray_fr: RayCast3D = $car/raycasts/front_right_cast
@onready var ray_rl: RayCast3D = $car/raycasts/rear_left_cast
@onready var ray_rr: RayCast3D = $car/raycasts/rear_right_cast
@onready var RAYCASTS = [ray_fl, ray_fr, ray_rl, ray_rr]


# Driving Control Parameters
var TOP_SPEED: float = 20.0
var RAY_FORCE_STRENGTH: float = 20.0
var RAY_FORCE_DAMPING: float = 8.0
# temp
var STEERING_TORQUE: float = 5.0
var LINEAR_POWER: float = 8.0
var GRIP: float = 1.0



func _physics_process(_delta):
	car_float()
	drive_rudimentary()


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


func drive_rudimentary():
	var steer = Input.get_axis("steer_right", "steer_left")

	apply_torque(global_basis.y * steer * STEERING_TORQUE)

	if Input.is_action_pressed("accelerate"):
		apply_central_force(-global_basis.z * LINEAR_POWER)
	if Input.is_action_pressed("brake"):
		apply_central_force(global_basis.z * LINEAR_POWER)

	
	var right_dir: Vector3 = global_basis.x
	var lateral_velocity: Vector3 = right_dir * linear_velocity.dot(right_dir)

	apply_central_impulse(-lateral_velocity * 0.95)


	
