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
			create_pool_item()
	
func play_sound(audio_name:String, delay: float = 0.0):
	var audio_item = get_audio_item(audio_name)	
	if audio_item == null: 
		printerr("[AudioManager] audio_item is null")
		return

	var audio_pool_item = get_free_pool_item()
	audio_pool_item.play_audio(audio_item, delay)

func play_sound2D(audio_name:String, world_pos: Vector2, delay: float = 0.0):
	var audio_item = get_audio_item(audio_name)
	if audio_item == null: 
		printerr("[AudioManager] audio_item is null")
		return
	
	var audio_pool_item = get_free_pool_item()
	audio_pool_item.play_audio2D(audio_item, world_pos, delay)

func play_sound3D(audio_name:String, world_pos: Vector3, delay: float = 0.0):
	var audio_item = get_audio_item(audio_name)
	if audio_item == null: 
		printerr("[AudioManager] audio_item is null")
		return
	
	var audio_pool_item = get_free_pool_item()
	audio_pool_item.play_audio3D(audio_item, world_pos, delay)
	
static func get_free_pool_item()->AudioPoolItem2D:
	for audio_pool_item in audio_pool:
		if not audio_pool_item.is_busy:
			return audio_pool_item
	return create_pool_item()
	
static func create_pool_item()->AudioPoolItem2D:
	print("creating pool item")
	var new_pool = pool_item_scene.instantiate() as AudioPoolItem2D
	instance.add_child(new_pool)
	audio_pool.append(new_pool)
	return new_pool
	
static func get_audio_item(audio_name:String) -> AudioItem:
	for audio_item in sound_list:
		if audio_item.name == audio_name:
			return audio_item
	print("[ERROR][AudioManager] ", audio_name, " was not found")
	return null

static func get_all_audio_settings() -> Array[AudioItem]:
	
	var return_list:Array[AudioItem] = []
	var sound_list_raw:Array[String] = _get_all_files(sounds_folder, "tres")
	
	for file_path in sound_list_raw:
		var res:Resource = load(file_path) 

		if res is AudioItem:
			var resource_name = file_path.get_file().replace(".tres", "")
			res.name = resource_name
			res.file_path = file_path
			return_list.append(res as AudioItem)
			
	sound_list = return_list
	return return_list

static func _get_all_files(path: String, file_ext := "", files:Array[String] = []) -> Array[String]: #Loops through an entire directory recursively, and pulls the full file paths
	if Engine.is_editor_hint():
		if !DirAccess.dir_exists_absolute(path):
			DirAccess.make_dir_absolute(path)
			AudioManagerTools.refresh_folders()

	var dir = DirAccess.open(path)
	
	if dir == null:
		print("An error occurred when trying to access %s." % path)
		return files

	dir.list_dir_begin()

	var file_name = dir.get_next()

	while file_name != "":
		if dir.current_is_dir():
			files = _get_all_files(dir.get_current_dir() + "/" + file_name, file_ext, files)
		else:
			if file_ext is String and not file_ext.is_empty() and file_name.get_extension() != file_ext:
				file_name = dir.get_next()
				continue

			files.append(dir.get_current_dir() + "/" + file_name)

		file_name = dir.get_next()
	
	return files
