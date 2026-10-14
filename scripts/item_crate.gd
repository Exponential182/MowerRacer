extends Node3D

@onready var mesh = $Mesh

var possible_items = ["Cube", "Sphere"]



func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#mesh.rotation_degrees += Vector3(randi_range(0,2),randi_range(0,2),randi_range(0,2))
	mesh.rotation_degrees += Vector3(0.5,0.5,0)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		var random_item = randi_range(0,possible_items.size()-1)
		if not body.current_item:
			body.current_item = possible_items[random_item]
			body.update_item()
