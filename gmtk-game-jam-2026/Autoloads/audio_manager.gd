extends Node

var active_music_stream:AudioStreamPlayer

@export var clips:Node
@export var one_shots:Node
@export var audio_one_shot_scene:PackedScene

## Plays an audio registered in the Audio Manager.
## skip_restart will not stop the current audio if audio_name is the same as the one being currently played.
func play(audio_name:String, pitch:float = 1, from_position:float=0.0,skip_restart:bool=false)->void:
	if skip_restart and active_music_stream and active_music_stream.name==audio_name:
		return
		
	# if clip doesn't exist warns and returns
	if(!clips.has_node(audio_name)):
		push_warning("No se ha encontrado el clip \"" + str(audio_name) + "\".")
		return
		
	active_music_stream=clips.get_node(audio_name)
	active_music_stream.play(from_position)
	active_music_stream.pitch_scale = pitch

## Plays an audio once, and eliminates it after it ends.
func play_one_shot(audio_stream:AudioStream,volume_db:float=0.0,from_position:float=0.0)->AudioOneShot:
	var audio_one_shot:AudioOneShot=audio_one_shot_scene.instantiate()
	audio_stream.stream=audio_stream
	audio_one_shot.volume_db=volume_db
	audio_one_shot.from_position=from_position
	
	one_shots.add_child(audio_one_shot)
	return audio_one_shot

## Stops the current audio clip. If there is no audio clip playing, it does nothing.
func stop() ->void:
	if active_music_stream && active_music_stream.playing:
		active_music_stream.stop()
	active_music_stream = null

## Returns true if there is an audio clip playing
func is_playing() -> bool:
	if !active_music_stream:
		return false
	return active_music_stream.playing
