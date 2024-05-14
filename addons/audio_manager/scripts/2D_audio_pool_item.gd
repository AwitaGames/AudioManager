extends Node
class_name AudioPoolItem2D

@export var player_normal:AudioStreamPlayer
@export var player_2D:AudioStreamPlayer2D
@export var player_3D:AudioStreamPlayer3D
@export var timer:Timer

@export var is_busy:bool = false

var current_player;

func play_audio(audio_item:AudioItem, delay: float = 0.0):
	is_busy = true
	current_player = player_normal
	setup_audio(player_normal, audio_item, delay)

func play_audio2D(audio_item:AudioItem, world_pos: Vector2, delay: float = 0.0):
	is_busy = true
	player_2D.position = world_pos
	current_player = player_2D
	setup_audio(player_2D, audio_item, delay)

func play_audio3D(audio_item:AudioItem, world_pos: Vector3, delay: float = 0.0):
	is_busy = true
	player_3D.position = world_pos
	current_player = player_3D
	setup_audio(player_3D, audio_item, delay)

func setup_audio(audio_stream, audio_item:AudioItem, delay: float):
	
	if len(audio_item.audio_files) == 0:
		return
		
	is_busy = true
		
	timer.wait_time = delay + 0.01
	timer.stop()
	
	var random_index = randi_range(0, len(audio_item.audio_files)-1)
	audio_stream.stream = audio_item.audio_files[random_index]
	audio_stream.volume_db = audio_item.volume
	audio_stream.pitch_scale = audio_item.pitch_variation
	if audio_item.pitch_random != 0:
		audio_stream.pitch_scale += randf_range(-audio_item.pitch_random, audio_item.pitch_random )

	var audio_length:float = audio_stream.stream.get_length()
	
	var finish_timer = get_tree().create_timer(audio_length + 0.5)
	
	finish_timer.timeout.connect(func():
		is_busy = false
	)
	
	if delay > 0.0:
		timer.start()
	else:
		_on_timer_timeout()

func _on_timer_timeout():
	current_player.play()
