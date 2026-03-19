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

func setup(canvaslayer : CanvasLayer) -> void:
	canvas = canvaslayer

func init_menus() -> void:
	var menu = Prefabs.mainmenu_screen.instantiate()
	add_child.call_deferred(menu)
	menus.get_or_add(Menu.Type.MAIN, menu)
