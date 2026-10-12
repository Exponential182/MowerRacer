extends Node

signal finished

const RAND_PITCH_AMMOUNT = 0.1

const BLIP = preload("uid://cwsq7vrmf40a5")

func playfile(_file : AudioStreamWAV, rand_pitch : bool = true):
	var s := AudioStreamPlayer.new()
	s.stream = _file
	if rand_pitch:
		s.pitch_scale = randf_range(-RAND_PITCH_AMMOUNT + 1,RAND_PITCH_AMMOUNT+1)
	add_child(s)
	s.play()
	await s.finished
	finished.emit()
	s.queue_free()
