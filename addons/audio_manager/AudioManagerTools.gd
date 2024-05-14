@tool
extends Node


func refresh_folders():
	EditorInterface.get_resource_filesystem().scan()
