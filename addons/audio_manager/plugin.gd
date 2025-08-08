@tool
extends EditorPlugin

const SettingsWindowMain := preload("res://addons/audio_manager/scenes/audio_manager_tab.tscn")

var _audiomanager_main: AudioManagerTab

func _enter_tree():
	add_autoload_singleton("AudioManager", "res://addons/audio_manager/AudioManager.gd")
	_audiomanager_main = SettingsWindowMain.instantiate()
	_audiomanager_main.name = "AudioManager"
	get_editor_interface().get_editor_main_screen().add_child(_audiomanager_main)
	_make_visible(false)

func _exit_tree():
	remove_autoload_singleton("AudioManager")
	if _audiomanager_main:
		_audiomanager_main.queue_free()

func _has_main_screen() -> bool:
	return true

func _get_plugin_name() -> String:
	return "AudioManager"

func _make_visible(visible: bool) -> void:
	if _audiomanager_main:
		_audiomanager_main.visible = visible
		if visible:
			_audiomanager_main.on_show_audiomanager_window()

func _get_plugin_icon() -> Texture2D:
	return null
