extends Sprite2D

var time := 0.0

func _ready() -> void:
	move()

func move():
	position.x = -72.0
	var t := create_tween()
	t.tween_property(self,"position:x",606.0,10)
	await t.finished
	move()
	

func _process(delta: float) -> void:
	time += delta
	
	skew = (sin(time*7)*2) * 0.05
	position.y = (sin(time*14)*2) + 241.0
	
	
