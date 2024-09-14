@tool
extends Control
class_name AudioManagerTab

var default_icon = load("res://addons/audio_manager/assets/audio_icon.png")

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

var selected_audio_item:AudioItem:
	set(value):
		selected_audio_item = value
		if value:
			settings_root.show()
		else:
			settings_root.hide()

func _ready():
	settings_root.hide()
	default_folder_path.text = AudioManager.sounds_folder

func on_show_audiomanager_window():
	refresh_audiomanager_tab()

func refresh_audiomanager_tab():
	var file_list:Array[AudioItem] = AudioManager.get_all_audio_settings()
	var child_list:Array[Node] = button_list_root.get_children()
	
	button_list_root.clear()
	
	var i = 0
	for audio_file in file_list:
		button_list_root.add_item(audio_file.name, default_icon)
		button_list_root.set_item_tooltip(i, audio_file.resource_path)
		i += 1

func refresh_from_selected():
	if selected_audio_item:
		
		file_name_field.text = selected_audio_item.name
		volume_slider.set_value_no_signal(selected_audio_item.volume)
		pitch_slider.set_value_no_signal(selected_audio_item.pitch_variation)
		random_pitch_slider.set_value_no_signal(selected_audio_item.pitch_random)
		
		EditorInterface.edit_resource(selected_audio_item)
		
		file_list.clear()
		for f in selected_audio_item.audio_files:
			file_list.add_item(f.resource_path)
	else:
		printerr("[AudioManager] refresh_from_selected: selected_audio_item is NULL")
			
func save_selected_audio():
	ResourceSaver.save(selected_audio_item, selected_audio_item.resource_path)

func _on_audio_item_list_item_selected(index):
	var selected_item = button_list_root.get_item_text(index)
	selected_audio_item = AudioManager.get_audio_item(selected_item)
	refresh_from_selected()

func _on_volume_slider_value_changed(value):
	if selected_audio_item:
		selected_audio_item.volume = value
		save_selected_audio()

func _on_pitch_slider_value_changed(value):
	if selected_audio_item:
		selected_audio_item.pitch_variation = value
		save_selected_audio()

func _on_random_pitch_slider_value_changed(value):
	if selected_audio_item:
		selected_audio_item.pitch_random = value
		save_selected_audio()

func _on_add_file_button_down():	
	if selected_audio_item: 
		add_file_dialog.popup_centered(Vector2(500,500))
		
func _on_file_dialog_files_selected(paths):
	var old_array = selected_audio_item.audio_files
	for p in paths:
		var file_to_add = load(p)
		old_array.append(file_to_add)	
	selected_audio_item.audio_files = old_array	
	save_selected_audio()
	refresh_from_selected()
	
func _on_delete_selected_file_button_down():
	var old_array = selected_audio_item.audio_files
	if selected_audio_item and len(file_list.get_selected_items()) > 0:
		var files:Array[String]
		for i in file_list.get_selected_items():		
			var path_to_remove = file_list.get_item_text(i)
			for fi in range(old_array.size()-1, -1, -1):
				if old_array[fi].resource_path == path_to_remove: 
					old_array.remove_at(fi)
	selected_audio_item.audio_files = old_array
	save_selected_audio()
	refresh_from_selected()

func _on_file_name_text_submitted(new_text):
	
	new_text = validate_file_name(new_text)
	
	file_name_field.text = new_text
	if new_text == selected_audio_item.name: return
	
	var old_file_path = selected_audio_item.resource_path
	var new_file_path = old_file_path.replace(selected_audio_item.name, new_text)
	
	ResourceSaver.save(selected_audio_item, new_file_path)

	DirAccess.remove_absolute(old_file_path)
	AudioManagerTools.refresh_folders()
	refresh_audiomanager_tab()
	
func validate_file_name(file_name:String) -> String:
	var regex = RegEx.new()
	regex.compile("[a-zA-Z0-9_-]")
	var result:Array[RegExMatch] = regex.search_all(file_name)
	var final_text = ""
	for res in result:
		final_text += res.get_string()
	return final_text

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
		
	ResourceSaver.save(AudioItem.new(), file_path)
	refresh_audiomanager_tab()


func _on_button_button_down():
	var confirmation_dialog:ConfirmationDialog = ConfirmationDialog.new()
	confirmation_dialog.dialog_text = "Do you want to delete this item?"
	add_child(confirmation_dialog)
	
	confirmation_dialog.get_ok_button().button_down.connect(on_confirm_file_deletion)
	
	confirmation_dialog.popup_centered()
	
func on_confirm_file_deletion():
	DirAccess.remove_absolute(selected_audio_item.resource_path)
	AudioManagerTools.refresh_folders()
	refresh_audiomanager_tab()
	
	if file_list.item_count > 0:
		_on_audio_item_list_item_selected(0)
	else:
		settings_root.hide()


func _on_filter_text_changed(new_text:String):
	var current_files = AudioManager.sound_list
	button_list_root.clear()
	for f in current_files:
		if f.name.to_lower().contains(new_text.to_lower()) or new_text.dedent() == "":
			button_list_root.add_item(f.name, default_icon)
	
	if button_list_root.item_count > 0:
		button_list_root.select(0)


func _on_change_folder_path_pressed() -> void:
	select_folder_dialog.popup_centered(Vector2(500,500))


func _on_folder_dialog_dir_selected(dir: String) -> void:
	default_folder_path.text = dir
