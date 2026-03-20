extends Node
class_name MovementComponent

signal dash_started
signal dash_finished

@export var move_speed: float = 5.3
@export var dash_speed: float = 24.0
@export var dash_duration: float = 0.15
@export var dash_cooldown: float = 0.6

var is_dashing: bool = false

var _dash_timer: float = 0.0
var _cooldown_timer: float = 0.0
var _dash_direction: Vector3 = Vector3.ZERO


func _process(delta: float) -> void:
	if is_dashing:
		_dash_timer -= delta
		if _dash_timer <= 0.0:
			is_dashing = false
			dash_finished.emit()

	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta


func can_dash() -> bool:
	return not is_dashing and _cooldown_timer <= 0.0


func start_dash(direction: Vector3) -> void:
	if not can_dash():
		return
	is_dashing = true
	_dash_timer = dash_duration
	_cooldown_timer = dash_cooldown
	_dash_direction = direction.normalized()
	dash_started.emit()


func calculate_velocity(input_direction: Vector3) -> Vector3:
	if is_dashing:
		return _dash_direction * dash_speed
	return input_direction * move_speed
