extends Control
class_name MenuManager

static var instance : MenuManager

var menus : Dictionary[Menu.Type, Menu] = {}
var canvas : CanvasLayer = null


func _ready() -> void:
	MenuManager.instance = self
	init_menus()


func show_menu(menu : Menu.Type) -> void:
	menus[menu].show_menu()


func hide_menu(menu : Menu.Type) -> void:
	menus[menu].hide_menu()


func setup(canvaslayer : CanvasLayer) -> void:
	canvas = canvaslayer


func init_menus() -> void:
	_register_menu(Menu.Type.MAIN, Prefabs.mainmenu_screen)
	_register_menu(Menu.Type.UPGRADE, Prefabs.upgrade_screen)


func _register_menu(type: Menu.Type, prefab: PackedScene) -> void:
	var menu := prefab.instantiate() as Menu
	add_child.call_deferred(menu)
	menus.get_or_add(type, menu)
