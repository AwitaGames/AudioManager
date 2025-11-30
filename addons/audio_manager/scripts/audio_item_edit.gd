@tool
extends Control
class_name AudioItemEditor

@export var settings_root:Control
@export var file_name_field:LineEdit
@export var volume_slider:HSlider
@export var volume_value_label:Label
@export var pitch_slider:HSlider
@export var pitch_value_label:Label
@export var random_pitch_slider:HSlider
@export var random_pitch_value_label:Label
@export var audio_bus_selector:OptionButton
@export var file_list:ItemList
@export var add_file_dialog:FileDialog

var audio_manager_editor:AudioManagerTab
var selected_audio_path: String

#
#
# Management
#
#

func set_up(_audio_manager_tab:AudioManagerTab):
	audio_manager_editor = _audio_manager_tab

func select_file(file_path:String):
	if FileAccess.file_exists(file_path):
		selected_audio_path = file_path
	else:
		printerr("Audio item not found on path %s" % file_path)
	refresh()

func deselect():
	selected_audio_path = ""
	refresh()

func refresh():
	if selected_audio_path != "":
		var selected_audio_item := get_selected_audio_item()
		
		file_name_field.text = selected_audio_item.name
		volume_slider.set_value_no_signal(selected_audio_item.volume)
		volume_value_label.text = str(selected_audio_item.volume)
		pitch_slider.set_value_no_signal(selected_audio_item.pitch_variation)
		pitch_value_label.text = str(selected_audio_item.pitch_variation)
		random_pitch_slider.set_value_no_signal(selected_audio_item.pitch_random)
		random_pitch_value_label.text = str(selected_audio_item.pitch_random)
		_fill_audio_bus_selector(selected_audio_item.bus)
		
		EditorInterface.edit_resource(selected_audio_item)
		
		file_list.clear()
		for f in selected_audio_item.audio_files:
			file_list.add_item(f.resource_path)
		
		settings_root.visible = true
	else:
		settings_root.visible = false

func _fill_audio_bus_selector(current_bus: String):
	audio_bus_selector.clear()

	var bus_count := AudioServer.get_bus_count()
	var selected_index := 0

	for i in range(bus_count):
		var bus_name := AudioServer.get_bus_name(i)
		audio_bus_selector.add_item(bus_name)
		
		if bus_name == current_bus:
			selected_index = i

	audio_bus_selector.select(selected_index)
#
#
# Audio Item Inputs
#
#
func get_selected_audio_item() -> AudioItem:
	var audio_item := ResourceLoader.load(selected_audio_path) as AudioItem
	if audio_item:
		return audio_item
	else:
		return null

func save_audio_item(audio_item:AudioItem):
	ResourceSaver.save(audio_item, audio_item.resource_path)

func _on_volume_slider_value_changed(value):
	var selected_audio_item := get_selected_audio_item()
	if selected_audio_item:
		selected_audio_item.volume = value
		volume_value_label.text = str(value)
		save_audio_item(selected_audio_item)

func _on_pitch_slider_value_changed(value):
	var selected_audio_item := get_selected_audio_item()
	if selected_audio_item:
		selected_audio_item.pitch_variation = value
		pitch_value_label.text = str(value)
		save_audio_item(selected_audio_item)

func _on_random_pitch_slider_value_changed(value):
	var selected_audio_item := get_selected_audio_item()
	if selected_audio_item:
		selected_audio_item.pitch_random = value
		random_pitch_value_label.text = str(value)
		save_audio_item(selected_audio_item)

func _on_file_dialog_files_selected(paths):
	var selected_audio_item := get_selected_audio_item()
	# Array needs to be duplicated. If not duplicated and null array, it uses the default reference
	# of the class AudioItem, making it duplicate across all AudioItems.
	var old_array = selected_audio_item.audio_files.duplicate(true) 
	for p in paths:
		var file_to_add = load(p)
		old_array.append(file_to_add)
	selected_audio_item.audio_files = old_array
	save_audio_item(selected_audio_item)
	
func _on_delete_selected_file_button_down():
	var selected_audio_item := get_selected_audio_item()
	var old_array = selected_audio_item.audio_files
	if selected_audio_item and len(file_list.get_selected_items()) > 0:
		var files:Array[String]
		for i in file_list.get_selected_items():
			var path_to_remove = file_list.get_item_text(i)
			for fi in range(old_array.size()-1, -1, -1):
				if old_array[fi].resource_path == path_to_remove: 
					old_array.remove_at(fi)
	selected_audio_item.audio_files = old_array
	save_audio_item(selected_audio_item)

func _on_file_name_text_submitted(new_text):
	
	var selected_audio_item := get_selected_audio_item()
	new_text = audio_manager_editor.validate_file_name(new_text)
	
	file_name_field.text = new_text
	if new_text == selected_audio_item.name: return
	
	var old_path = selected_audio_item.resource_path
	var new_path = old_path.replace(selected_audio_item.name, new_text)
	
	save_audio_item(selected_audio_item)

func _on_delete_item_button_button_down() -> void:
	var selected_audio_item := get_selected_audio_item()
	if selected_audio_item:
		var confirmation_dialog:ConfirmationDialog = ConfirmationDialog.new()
		confirmation_dialog.dialog_text = "Do you want to delete this item?"
		add_child(confirmation_dialog)
		confirmation_dialog.get_ok_button().button_down.connect(func():
			audio_manager_editor.delete_audio_item(selected_audio_item.resource_path)
		)
		confirmation_dialog.popup_centered()

func _on_add_file_button_down():
	var selected_audio_item := get_selected_audio_item()
	if selected_audio_item: 
		add_file_dialog.popup_centered(Vector2(500,500))


func _on_audio_bus_selector_item_selected(index: int) -> void:
	var selected_audio_item := get_selected_audio_item()
	if selected_audio_item:
		selected_audio_item.bus = audio_bus_selector.get_item_text(index)
		save_audio_item(selected_audio_item)
