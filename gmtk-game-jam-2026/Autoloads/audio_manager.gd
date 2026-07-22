extends Node

var active_music_stream:AudioStreamPlayer

@export var clips:Node
@export var one_shots:Node
@export var audio_one_shot_scene:PackedScene

func play(audio_name:String, pitch:float = 1, from_position:float=0.0,skip_restart:bool=false)->void:
	if skip_restart and active_music_stream and active_music_stream.name==audio_name:
		return
	active_music_stream=clips.get_node(audio_name)
	active_music_stream.play(from_position)
	active_music_stream.pitch_scale = pitch

func play_one_shot(audio_stream:AudioStream,volume_db:float=0.0,from_position:float=0.0)->AudioOneShot:
	var audio_one_shot:AudioOneShot=audio_one_shot_scene.instantiate()
	audio_stream.stream=audio_stream
	audio_one_shot.volume_db=volume_db
	audio_one_shot.from_position=from_position
	
	one_shots.add_child(audio_one_shot)
	return audio_one_shot

func stop() ->void:
	if active_music_stream && active_music_stream.playing:
		active_music_stream.stop()
	active_music_stream = null

func is_playing() -> bool:
	if !active_music_stream:
		return false
	return active_music_stream.playing
