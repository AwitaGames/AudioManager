@tool
extends EditorPlugin


func refresh_folders():
	get_editor_interface().get_resource_filesystem().scan()
