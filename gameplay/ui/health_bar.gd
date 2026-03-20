extends Control
class_name HealthBar

const FILL_COLOR_NORMAL: Color = Color(0.2, 1.0, 0.45, 1.0)
const FILL_COLOR_HIT: Color = Color(1.0, 0.25, 0.25, 1.0)

@onready var background: ColorRect = $Background
@onready var fill: ColorRect = $Background/Fill


func _ready() -> void:
	await get_tree().process_frame
	var player := get_tree().get_first_node_in_group("player") as Player
	if player:
		player.health_component.health_changed.connect(_on_health_changed)
		_set_fill_ratio(player.health_component.current_health / player.health_component.max_health)


func _on_health_changed(current_health: float, max_health: float) -> void:
	_set_fill_ratio(current_health / max_health)
	_pulse()


func _set_fill_ratio(ratio: float) -> void:
	fill.size.x = ratio * background.size.x


func _pulse() -> void:
	var tween := create_tween().set_parallel(true)
	tween.tween_property(fill, "color", FILL_COLOR_HIT, 0.0)
	tween.tween_property(fill, "color", FILL_COLOR_NORMAL, 0.3)
	tween.tween_property(self, "scale", Vector2(1.0, 1.12), 0.0)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2).set_ease(Tween.EASE_OUT)
