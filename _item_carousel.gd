extends Control
class_name ItemCarousel

@export var items : Array[MowerItem]
@export var slot_size := Vector2(64, 64)
@export var spacing := 16.0
@export var slide_time := 0.2

var selected_index := 0
var slots : Array[TextureRect] = []
var slide := 0.0 # -1 = items moved one slot left, +1 = one slot right
var animating := false

const SLOT_RANGE := 2 # slots from -2..2: two extra rects sit off-screen for smooth sliding

func _ready() -> void:
	custom_minimum_size = Vector2((slot_size.x + spacing) * 3 - spacing, slot_size.y)
	clip_contents = true
	for k in range(-SLOT_RANGE, SLOT_RANGE + 1):
		var t := TextureRect.new()
		t.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		t.size = slot_size
		add_child(t)
		slots.append(t)
	
	var t := TextureRect.new()
	t.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	t.size = slot_size
	add_child(t)
	slots.append(t)
		
	refresh_textures()
	layout_slots()
	move(0)

func _process(_delta: float) -> void:
	if animating or !(get_viewport().gui_get_focus_owner() == self):
		return
	if Input.is_action_pressed("ui_left"):
		move(1)   # items slide left
	elif Input.is_action_pressed("ui_right"):
		move(-1)  # items slide right

func move(step: int) -> void:
	SfxManager.playfile(SfxManager.BLIP)
	
	animating = true
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	# step = +1 -> items travel left (slide goes to -1); step = -1 -> items travel right
	tween.tween_method(set_slide, 0.0, -float(step), slide_time)
	tween.finished.connect(func():
		selected_index = correct_index(selected_index + step)
		slide = 0.0
		refresh_textures()
		layout_slots()
		animating = false
	)

func set_slide(value: float) -> void:
	slide = value
	layout_slots()

func refresh_textures() -> void:
	for i in slots.size():
		var k := i - SLOT_RANGE
		slots[i].texture = items[correct_index(selected_index + k)].mower_item_icon

func layout_slots() -> void:
	var step := slot_size.x + spacing
	var center_x := size.x * 0.5
	for i in slots.size():
		var k := i - SLOT_RANGE
		var pos := float(k) + slide          # position relative to the center slot
		slots[i].position = Vector2(center_x + pos * step - slot_size.x * 0.5, 0)
		
		var dist := absf(pos)
		# center = 1.0, neighbours = 0.25, anything further fades out to 0
		var a := lerpf(1.0, 0.25, minf(dist, 1.0))
		if dist > 1.0:
			a = lerpf(0.25, 0.0, clampf(dist - 1.0, 0.0, 1.0))
		slots[i].modulate.a = a

func correct_index(_index: int) -> int:
	return posmod(_index, items.size())
