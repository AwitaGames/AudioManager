@tool
extends Control
class_name AudioItemEditor

@export var settings_root:Control
@export var file_name_field:LineEdit
@export var volume_slider:HSlider
@export var pitch_slider:HSlider
@export var random_pitch_slider:HSlider
@export var file_list:ItemList
@export var add_file_dialog:FileDialog

var audio_manager_editor:AudioManagerTab
var selected_audio_item:AudioItem

#
#
# Management
#
#

func set_up(_audio_manager_tab:AudioManagerTab):
	audio_manager_editor = _audio_manager_tab

func select_file(file_path:String):
	if FileAccess.file_exists(file_path):
		selected_audio_item = ResourceLoader.load(file_path)
	refresh()

func deselect():
	selected_audio_item = null
	refresh()

func save_selected_audio():
	audio_manager_editor.save_audio_item(selected_audio_item)

func refresh():
	if selected_audio_item:
		file_name_field.text = selected_audio_item.name
		volume_slider.set_value_no_signal(selected_audio_item.volume)
		pitch_slider.set_value_no_signal(selected_audio_item.pitch_variation)
		random_pitch_slider.set_value_no_signal(selected_audio_item.pitch_random)
		
		EditorInterface.edit_resource(selected_audio_item)
		
		file_list.clear()
		for f in selected_audio_item.audio_files:
			file_list.add_item(f.resource_path)
		
		settings_root.visible = true
	else:
		settings_root.visible = false
		
#
#
# Audio Item Inputs
#
#
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

func _on_file_dialog_files_selected(paths):
	var old_array = selected_audio_item.audio_files
	for p in paths:
		var file_to_add = load(p)
		old_array.append(file_to_add)	
	selected_audio_item.audio_files = old_array	
	save_selected_audio()
	
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

func _on_file_name_text_submitted(new_text):
	
	new_text = audio_manager_editor.validate_file_name(new_text)
	
	file_name_field.text = new_text
	if new_text == selected_audio_item.name: return
	
	var old_path = selected_audio_item.resource_path
	var new_path = old_path.replace(selected_audio_item.name, new_text)
	
	audio_manager_editor.rename_file(selected_audio_item, old_path, new_path)

func _on_delete_item_button_button_down() -> void:
	if selected_audio_item:
		var confirmation_dialog:ConfirmationDialog = ConfirmationDialog.new()
		confirmation_dialog.dialog_text = "Do you want to delete this item?"
		add_child(confirmation_dialog)
		confirmation_dialog.get_ok_button().button_down.connect(on_confirm_file_deletion)
		confirmation_dialog.popup_centered()
		
func on_confirm_file_deletion():
	if selected_audio_item:
		audio_manager_editor.delete_audio_item(selected_audio_item.resource_path)

func _on_add_file_button_down():	
	if selected_audio_item: 
		add_file_dialog.popup_centered(Vector2(500,500))
