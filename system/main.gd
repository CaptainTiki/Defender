extends Node3D
class_name Main

enum StartupMode { TITLE_SCREEN, MAIN_MENU, DEBUG_LEVEL }

@export var startup_mode: StartupMode = StartupMode.MAIN_MENU


func _ready() -> void:
	match startup_mode:
		StartupMode.TITLE_SCREEN:
			MenuManager.instance.setup(%CanvasLayer)
			MenuManager.instance.show_menu(Menu.Type.TITLE)
		StartupMode.MAIN_MENU:
			MenuManager.instance.setup(%CanvasLayer)
			MenuManager.instance.show_menu(Menu.Type.MAIN)
		StartupMode.DEBUG_LEVEL:
			add_child(load("uid://cl3m0slok1wkd").instantiate())
