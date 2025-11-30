@tool
extends Control
class_name AudioManagerTab

const USER_SETTINGS_PATH = "res://addons/audio_manager/user_settings.tres"

var default_icon = load("res://addons/audio_manager/assets/audio_icon.png")

@export var audio_manager : AudioManager
@export var editor_audio_pool_item : AudioPoolItem2D

@export var button_list_root:ItemList
@export var button_scene:PackedScene = preload("res://addons/audio_manager/scenes/audio_item_button.tscn")

@export var create_input:LineEdit
@export var default_folder_path:LineEdit

@export var settings_root:Control
@export var file_name_field:LineEdit
@export var volume_slider:HSlider
@export var pitch_slider:HSlider
@export var random_pitch_slider:HSlider
@export var file_list:ItemList
@export var add_file_dialog:FileDialog
@export var select_folder_dialog:FileDialog

@export var audio_item_editor:AudioItemEditor
var audio_manager_settings: AudioManagerSettings
	
func _enter_tree() -> void:
	load_user_settings()

func _ready():
	settings_root.hide()
	default_folder_path.text = audio_manager_settings.default_folder
	audio_item_editor.set_up(self)

func _process(delta: float) -> void:
	pass

func on_show_audiomanager_window():
	refresh_audiomanager_tab()

# 
#
# Data Management
#
#
func load_user_settings():
	if ResourceLoader.exists(USER_SETTINGS_PATH):
		audio_manager_settings = ResourceLoader.load(USER_SETTINGS_PATH)
	else:
		audio_manager_settings = AudioManagerSettings.new()
		ResourceSaver.save(audio_manager_settings, USER_SETTINGS_PATH)
		
func save_user_settings():
	ResourceSaver.save(audio_manager_settings, USER_SETTINGS_PATH)

#
#
# UTILS
#
#
func verify_folder_path(path:String):
	if not DirAccess.dir_exists_absolute(path):
		var err := DirAccess.make_dir_recursive_absolute(path)
		if err != OK:
			push_error("Cannot create folder: %s" % path)
			return false
		return true
		
func refresh_audiomanager_tab():
	var file_list:Array[AudioItem] = audio_manager.get_all_audio_settings()
	var child_list:Array[Node] = button_list_root.get_children()
	
	button_list_root.clear()
	
	var i = 0
	for audio_file in file_list:
		button_list_root.add_item(audio_file.name, default_icon)
		button_list_root.set_item_tooltip(i, audio_file.resource_path)
		button_list_root.set_item_metadata(i, audio_file.resource_path)
		i += 1

func refresh():
	# If something is selected, keep after refresh
	var selected_items := button_list_root.get_selected_items()
	var selected_idx := -1
	if selected_items and selected_items.size() > 0:
		selected_idx = selected_items[0]
		
	audio_item_editor.refresh()
	_refresh_folders()
	refresh_audiomanager_tab()
	
	if selected_idx > -1:
		_on_audio_item_list_item_selected(selected_idx)
		return
		
	if selected_idx < 0 and file_list.item_count > 0:
		_on_audio_item_list_item_selected(0)
		return
	
	audio_item_editor.deselect()
	
func _refresh_folders():
	if Engine.is_editor_hint():
		var editor_interface := Engine.get_singleton("EditorInterface")
		editor_interface.get_resource_filesystem().scan()
#
#
# ACTIONS
#
#
func create_new_audio_item(file_path:String):
	ResourceSaver.save(AudioItem.new(), file_path)
	refresh()
	audio_item_editor.select_file(file_path)

func _on_play_item_button_pressed() -> void:
	var selected_audio_item := audio_item_editor.get_selected_audio_item()
	if selected_audio_item:
		editor_audio_pool_item.play_audio(selected_audio_item)

func delete_audio_item(file_path:String):
	# Remove from memory
	audio_item_editor.deselect()
	EditorInterface.edit_resource(Resource.new())
	#Delete file
	DirAccess.remove_absolute(file_path)
	#Refresh
	refresh()

#
#
# DIALOGS
#
#

# Open dialog to change folder
func _on_change_folder_path_pressed() -> void:
	select_folder_dialog.popup_centered(Vector2(500,500))
# On select folder change
func _on_folder_dialog_dir_selected(dir: String) -> void:
	if verify_folder_path(dir):
		audio_manager_settings.default_folder = dir
		default_folder_path.text = audio_manager_settings.default_folder
		save_user_settings()
		_refresh_folders()
	
func _on_create_file_button_button_down():
	var file_name = validate_file_name(create_input.text)
	
	if file_name == "":
		var dialog = AcceptDialog.new()
		dialog.dialog_text = "Please use the input to set a name for the file"
		add_child(dialog)
		dialog.popup_centered()
		return
		
	var file_path = default_folder_path.text + "/" + file_name + ".tres" 
	if FileAccess.file_exists(file_path):
		var dialog = AcceptDialog.new()
		dialog.dialog_text = "The file already exists"
		add_child(dialog)
		dialog.popup_centered()
		return
	
	var dir_path := default_folder_path.text
	if not DirAccess.dir_exists_absolute(dir_path):
		var err := DirAccess.make_dir_recursive_absolute(dir_path)
		if err != OK:
			push_error("Cannot create folder: %s" % dir_path)
			return err
	
	create_new_audio_item(file_path)
#
#
# INPUT
#
#
func _on_audio_item_list_item_selected(index):
	var selected_item = button_list_root.get_item_text(index)
	audio_item_editor.select_file(button_list_root.get_item_metadata(index))

func _on_filter_text_changed(new_text:String):
	var current_files = audio_manager.sound_list
	button_list_root.clear()
	for f in current_files:
		if f.name.to_lower().contains(new_text.to_lower()) or new_text.dedent() == "":
			button_list_root.add_item(f.name, default_icon)
	
	if button_list_root.item_count > 0:
		button_list_root.select(0)


func validate_file_name(file_name:String) -> String:
	var regex = RegEx.new()
	regex.compile("[a-zA-Z0-9_-]")
	var result:Array[RegExMatch] = regex.search_all(file_name)
	var final_text = ""
	for res in result:
		final_text += res.get_string()
	return final_text
