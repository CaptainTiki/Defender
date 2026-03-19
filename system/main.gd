extends Node3D
class_name Main

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MenuManager.instance.setup(%CanvasLayer)
	MenuManager.instance.show_menu(Menu.Type.MAIN)
