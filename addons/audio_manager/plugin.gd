@tool
extends EditorPlugin

const SettingsWindowMain := preload("res://addons/audio_manager/scenes/audio_manager_tab.tscn")

var _audiomanager_main: AudioManagerTab
var audio_item_inspector

func _enter_tree():
	_audiomanager_main = SettingsWindowMain.instantiate()
	_audiomanager_main.name = "AudioManager"
	EditorInterface.get_editor_main_screen().add_child(_audiomanager_main)
	_make_visible(false)
	
	# Inspector plugins
	audio_item_inspector = load("res://addons/audio_manager/scripts/audio_item_inspector_plugin.gd").new()
	add_inspector_plugin(audio_item_inspector)

func _exit_tree():
	if _audiomanager_main:
		_audiomanager_main.queue_free()
	remove_inspector_plugin(audio_item_inspector)

func _enable_plugin() -> void:
	add_autoload_singleton("AudioManager", "res://addons/audio_manager/AudioManager.gd")
	
func _disable_plugin() -> void:
	remove_autoload_singleton("AudioManager")

func _make_visible(visible: bool) -> void:
	if _audiomanager_main:
		_audiomanager_main.visible = visible
		if visible:
			_audiomanager_main.on_show_audiomanager_window()

func _has_main_screen() -> bool:
	return true

func _get_plugin_name() -> String:
	return "AudioManager"

func _get_plugin_icon() -> Texture2D:
	return null
