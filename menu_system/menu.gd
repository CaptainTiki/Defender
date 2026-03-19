extends Control
class_name Menu

enum Type {TITLE, MAIN, SETTINGS, EXITCONFIRM, PAUSE}

func show_menu() -> void:
	set_process(true)
	show()

func hide_menu() -> void:
	set_process(false)
	hide()
