@tool
extends EditorProperty
class_name AudioBusSelectorProperty

var option_button := OptionButton.new()
var edited_object
var edited_property

func _init():
	add_child(option_button)
	option_button.item_selected.connect(_on_item_selected)
	option_button.size_flags_horizontal = SIZE_EXPAND_FILL

func setup(object, property_name):
	edited_object = object
	edited_property = property_name

	option_button.clear()
	var bus_count = AudioServer.get_bus_count()
	for i in range(bus_count):
		var name = AudioServer.get_bus_name(i)
		option_button.add_item(name, i)

	var current = object.get(property_name)
	if current != "":
		for i in range(option_button.item_count):
			if option_button.get_item_text(i) == current:
				option_button.select(i)
				break

func _on_item_selected(index):
	var value = option_button.get_item_text(index)
	emit_changed(edited_property, value)
