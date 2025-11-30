@tool
extends EditorInspectorPlugin

func _can_handle(object):
	return object is AudioItem

func _parse_property(
	object: Object,
	type: Variant.Type,
	name: String,
	hint: PropertyHint,
	hint_string: String,
	usage: int,
	wide: bool
) -> bool:
	if name != "bus":
		return false

	var custom = AudioBusSelectorProperty.new()
	custom.setup(object, name)
	add_property_editor(name, custom)

	return true
