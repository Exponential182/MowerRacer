extends Node

const TRACK_1 = preload("uid://ee8lnqsolnim")
const TRACK_2 = preload("uid://ch8i1imawjrp5")
const TRACK_3 = preload("uid://deli4o2le6jjv")

var current_player : AudioStreamPlayer

const TRANSITION_DURATION := 0.5
const TRANSITION_END_VOLUME := -20
const TRANSITION_START_VOLUME := -80

func _ready() -> void:
	play_track(TRACK_1)

	
func play_track(_track):
	if current_player:
		current_player.queue_free()
	
	current_player = AudioStreamPlayer.new() 
	add_child(current_player)
	current_player.finished.connect(func():current_player.play())
	current_player.stream = _track
	current_player.play()
	current_player.volume_db = TRANSITION_START_VOLUME
	
	var t := create_tween().set_ease(Tween.EASE_OUT)
	t.tween_property(current_player,"volume_db",TRANSITION_END_VOLUME,TRANSITION_DURATION)
