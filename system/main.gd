extends Node3D
class_name Main

static var instance: Main

enum StartupMode { TITLE_SCREEN, MAIN_MENU, NEW_GAME, CONTINUE_GAME }

@export var startup_mode: StartupMode = StartupMode.NEW_GAME


func _ready() -> void:
	Main.instance = self
	match startup_mode:
		StartupMode.TITLE_SCREEN:
			MenuManager.instance.setup(%CanvasLayer)
			MenuManager.instance.show_menu(Menu.Type.TITLE)
		StartupMode.MAIN_MENU:
			MenuManager.instance.setup(%CanvasLayer)
			MenuManager.instance.show_menu(Menu.Type.MAIN)
		StartupMode.NEW_GAME:
			UpgradeManager.instance.new_game()
			_start_level()
		StartupMode.CONTINUE_GAME:
			_start_level()


func _start_level() -> void:
	add_child(load("uid://cl3m0slok1wkd").instantiate())


func restart_level() -> void:
	for child in get_children():
		if child is Level:
			child.queue_free()
	await get_tree().process_frame
	_start_level()
