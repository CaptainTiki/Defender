extends Node3D
class_name DamageNumber

const FLOAT_SPEED: float = 1.5
const LIFETIME: float = 1.2
const FADE_START_TIME: float = 0.5

@onready var label: Label3D = $Label3D

var _age: float = 0.0


func display(amount: float) -> void:
	label.text = str(int(amount))


func _process(delta: float) -> void:
	_age += delta
	position.y += FLOAT_SPEED * delta

	var time_left: float = LIFETIME - _age
	if time_left < FADE_START_TIME:
		label.modulate.a = time_left / FADE_START_TIME

	if _age >= LIFETIME:
		queue_free()
