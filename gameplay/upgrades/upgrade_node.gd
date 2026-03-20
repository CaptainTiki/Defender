extends TextureButton
class_name UpgradeNode

signal hovered(data: UpgradeData, screen_position: Vector2)
signal unhovered
signal purchase_requested(data: UpgradeData)

enum State { HIDDEN, AVAILABLE, PURCHASED }

const RADIUS: float = 16.0
const COLOR_PURCHASED := Color(1.00, 0.85, 0.20, 1.0)
const COLOR_AVAILABLE := Color(0.40, 0.70, 1.00, 1.0)
const COLOR_UNAVAILABLE := Color(0.28, 0.28, 0.33, 0.75)
const COLOR_GLOW_PURCHASED := Color(1.00, 0.85, 0.20, 0.22)
const COLOR_GLOW_HOVER := Color(1.00, 1.00, 1.00, 0.18)

var upgrade_data: UpgradeData
var _state: State = State.HIDDEN


func setup(data: UpgradeData) -> void:
	upgrade_data = data
	custom_minimum_size = Vector2(RADIUS * 2.0, RADIUS * 2.0)
	size = Vector2(RADIUS * 2.0, RADIUS * 2.0)
	refresh()


func refresh() -> void:
	if upgrade_data == null:
		return
	if not UpgradeManager.instance.has_purchased_parent(upgrade_data):
		_set_state(State.HIDDEN)
	elif UpgradeManager.instance.is_purchased(upgrade_data.id):
		_set_state(State.PURCHASED)
	else:
		_set_state(State.AVAILABLE)


func _set_state(new_state: State) -> void:
	_state = new_state
	visible = _state != State.HIDDEN
	queue_redraw()


func _draw() -> void:
	var center := Vector2(RADIUS, RADIUS)
	var is_hovered := get_draw_mode() == DRAW_HOVER or get_draw_mode() == DRAW_HOVER_PRESSED
	var color: Color
	match _state:
		State.PURCHASED:
			color = COLOR_PURCHASED
			draw_circle(center, RADIUS + 6.0, COLOR_GLOW_PURCHASED)
			if is_hovered:
				draw_circle(center, RADIUS + 8.0, COLOR_GLOW_HOVER)
		State.AVAILABLE:
			var can_afford := UpgradeManager.instance.can_purchase(upgrade_data)
			color = COLOR_AVAILABLE if can_afford else COLOR_UNAVAILABLE
			if is_hovered:
				draw_circle(center, RADIUS + 6.0, COLOR_GLOW_HOVER)
	draw_circle(center, RADIUS, color)
	draw_arc(center, RADIUS - 1.0, 0.0, TAU, 48, color.lightened(0.35), 1.5)


func _pressed() -> void:
	purchase_requested.emit(upgrade_data)



func _on_focus_entered() -> void:
	_on_mouse_entered()

func _on_focus_exited() -> void:
	_on_mouse_exited()

func _on_mouse_entered() -> void:
	hovered.emit(upgrade_data, get_global_rect().get_center())

func _on_mouse_exited() -> void:
	unhovered.emit()
