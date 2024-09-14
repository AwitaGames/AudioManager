@tool
extends Node

func refresh_folders():
	if Engine.is_editor_hint():
		var editor_interface := Engine.get_singleton("EditorInterface")
		editor_interface.get_resource_filesystem().scan()
