#class_name AudioDispatcher
extends Node

var currently_playing_audios : Dictionary = {}
var currently_ending_audios : Dictionary = {}

func _get_audio_stream(audio_name : StringName) -> AudioStream:
	return load("res://assets/audio/" + audio_name + "/randomizer.tres")

func _free_audioplayer(audio_name : String):
	if not currently_playing_audios.has(audio_name): return
	var stream = currently_playing_audios[audio_name]
	stream.queue_free()
	currently_playing_audios.erase(audio_name)
	currently_ending_audios.erase(audio_name)

func dispatch_audio(parent : Node, audio_name : StringName, bus : StringName = "Master") -> AudioStreamPlayer:
	var stream := AudioStreamPlayer.new()
	if currently_playing_audios.has(audio_name):
		stream = currently_playing_audios[audio_name]
		if currently_ending_audios.has(audio_name):
			currently_ending_audios[audio_name].kill()
	else:
		stream.stream = _get_audio_stream(audio_name)
		parent.add_child(stream)
	stream.play()
	stream.bus = bus
	stream.volume_db = 0
	stream.finished.connect(func(): _free_audioplayer(audio_name))
	return stream

func dispatch_3d_audio(parent : Node, audio_name : StringName, bus : StringName = "Master") -> AudioStreamPlayer3D:
	var stream := AudioStreamPlayer3D.new()
	if currently_playing_audios.has(audio_name):
		stream = currently_playing_audios[audio_name]
		if currently_ending_audios.has(audio_name):
			currently_ending_audios[audio_name].kill()
	else:
		stream.stream = _get_audio_stream(audio_name)
		currently_playing_audios[audio_name] = stream
		parent.add_child(stream)
	stream.play()
	stream.bus = bus
	stream.volume_db = 0
	stream.finished.connect(func(): _free_audioplayer(audio_name))
	return stream

func end(audio_name : StringName, fadeout_time : float = 0.0):
	if not currently_playing_audios.has(audio_name): return
	var stream = currently_playing_audios[audio_name]
	var tween = get_tree().create_tween()
	tween.tween_property(stream, "volume_db", -100, fadeout_time)
	tween.tween_callback(_free_audioplayer.bind(audio_name))
	currently_ending_audios[audio_name] = tween
