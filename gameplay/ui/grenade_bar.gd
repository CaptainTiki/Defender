extends Control
class_name GrenadeBar

const FILL_COLOR_READY: Color = Color(0.2, 1.0, 0.45, 1.0)
const FILL_COLOR_COOLDOWN: Color = Color(0.15, 0.45, 0.25, 1.0)
const FILL_COLOR_READY_FLASH: Color = Color(0.8, 1.0, 0.85, 1.0)

@onready var background: ColorRect = $Background
@onready var fill: ColorRect = $Background/Fill

var _grenade_ability: GrenadeAbility = null
var _is_on_cooldown: bool = false


func _ready() -> void:
	await get_tree().process_frame
	var player := get_tree().get_first_node_in_group("player") as Player
	if not player:
		return
	_grenade_ability = player.grenade_ability
	_grenade_ability.grenade_used.connect(_on_grenade_used)
	_grenade_ability.grenade_ready.connect(_on_grenade_ready)
	_set_fill_ratio(1.0)


func _process(_delta: float) -> void:
	if not _is_on_cooldown or not _grenade_ability:
		return
	_set_fill_ratio(1.0 - _grenade_ability.get_cooldown_ratio())


func _set_fill_ratio(ratio: float) -> void:
	fill.size.x = ratio * background.size.x


func _on_grenade_used() -> void:
	_is_on_cooldown = true
	fill.color = FILL_COLOR_COOLDOWN
	_set_fill_ratio(0.0)


func _on_grenade_ready() -> void:
	_is_on_cooldown = false
	_set_fill_ratio(1.0)
	var tween := create_tween()
	tween.tween_property(fill, "color", FILL_COLOR_READY_FLASH, 0.0)
	tween.tween_property(fill, "color", FILL_COLOR_READY, 0.3)
