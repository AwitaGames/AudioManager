@tool
extends Node

static var instance:Node
static var sound_list:Array[AudioItem] = []
static var audio_pool:Array[AudioPoolItem2D] = []
static var pool_item_scene:PackedScene = preload("res://addons/audio_manager/scenes/audio_pool_item.tscn")
const sounds_folder = "res://sounds" # This folder is created when scanning audio files; not recommended to modify

const INITIAL_POOL:int = 50

func _enter_tree():
	instance = self
	sound_list = get_all_audio_settings()
	
	if !Engine.is_editor_hint():
		for i in INITIAL_POOL:
			_create_pool_item()

## Plays a sound without world position. For positioned sound, use play_sound2D or play_sound3D
func play_sound(audio_name:String, delay: float = 0.0):
	var audio_item = get_audio_item(audio_name)	
	if audio_item == null: 
		printerr("[AudioManager] audio_item is null")
		return

	var audio_pool_item = _get_free_pool_item()
	audio_pool_item.play_audio(audio_item, delay)

## Plays a sound in the 2D world position, with an optional delay
func play_sound2D(audio_name:String, world_pos: Vector2, delay: float = 0.0):
	var audio_item = get_audio_item(audio_name)
	if audio_item == null: 
		printerr("[AudioManager] audio_item is null")
		return
	
	var audio_pool_item = _get_free_pool_item()
	audio_pool_item.play_audio2D(audio_item, world_pos, delay)

## Plays a sound in the 3D world position, with an optional delay
func play_sound3D(audio_name:String, world_pos: Vector3, delay: float = 0.0):
	var audio_item = get_audio_item(audio_name)
	if audio_item == null: 
		printerr("[AudioManager] audio_item is null")
		return
	
	var audio_pool_item = _get_free_pool_item()
	audio_pool_item.play_audio3D(audio_item, world_pos, delay)

static func _get_free_pool_item()->AudioPoolItem2D:
	for audio_pool_item in audio_pool:
		if not audio_pool_item.is_busy:
			return audio_pool_item
	return _create_pool_item()

static func _create_pool_item()->AudioPoolItem2D:
	var new_pool = pool_item_scene.instantiate() as AudioPoolItem2D
	instance.add_child(new_pool)
	audio_pool.append(new_pool)
	return new_pool
	
static func get_audio_item(audio_name:String) -> AudioItem:
	for audio_item in sound_list:
		if audio_item.name == audio_name:
			return audio_item
	printerr("[AudioManager] ", audio_name, " was not found")
	return null

static func get_all_audio_settings() -> Array[AudioItem]:
	var return_list:Array[AudioItem] = []
	var sound_list_raw:Array[String] = _get_all_files("res://", "tres")
	
	for file_path in sound_list_raw:
		var res:Resource = ResourceLoader.load(file_path, "", ResourceLoader.CACHE_MODE_REPLACE_DEEP) 

		if res is AudioItem:
			var resource_name = file_path.get_file().replace(".tres", "").replace(".remap", "")
			res.name = resource_name
			return_list.append(res as AudioItem)
			
	sound_list = return_list
	return return_list

static func _get_all_files(path: String, file_ext := "", files:Array[String] = []) -> Array[String]: #Loops through an entire directory recursively, and pulls the full file paths
	if Engine.is_editor_hint():
		if !DirAccess.dir_exists_absolute(path):
			DirAccess.make_dir_absolute(path)
			refresh_folders()

	var dir = DirAccess.open(path)
	
	if dir == null:
		printerr("[AudioManager] An error occurred when trying to access %s." % path)
		return files

	dir.list_dir_begin()

	var file_name = dir.get_next()

	while file_name != "":
		if dir.current_is_dir():
			files = _get_all_files(dir.get_current_dir() + "/" + file_name, file_ext, files)
		else:
			file_name = file_name.trim_suffix(".remap")
			if file_ext is String and not file_ext.is_empty():
				if file_name.get_extension() != file_ext:
					file_name = dir.get_next()
					continue
			files.append(dir.get_current_dir() + "/" + file_name)
		file_name = dir.get_next()
	
	return files
	
static func refresh_folders():
	if Engine.is_editor_hint():
		var editor_interface := Engine.get_singleton("EditorInterface")
		editor_interface.get_resource_filesystem().scan()
