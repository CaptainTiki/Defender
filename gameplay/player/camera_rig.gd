extends Node3D
class_name CameraRig

static var instance: CameraRig

const POS_FAR := Vector3(0.0, 15.0, 8.0)
const POS_CLOSE := Vector3(0.0, 9.0, 5.0)
const ZOOM_DURATION := 0.65
const SHAKE_INTENSITY: float = 0.35
const TRAUMA_DECAY: float = 2.8

@onready var camera: Camera3D = $Camera3D

var _tween: Tween
var _shake_trauma: float = 0.0


func _ready() -> void:
	CameraRig.instance = self
	# Always process so zoom tweens run even when Level is disabled
	process_mode = Node.PROCESS_MODE_ALWAYS
	camera.position = POS_CLOSE


func _process(delta: float) -> void:
	if _shake_trauma > 0.0:
		_shake_trauma = max(0.0, _shake_trauma - TRAUMA_DECAY * delta)
		var shake_amount := _shake_trauma * _shake_trauma * SHAKE_INTENSITY
		position = Vector3(
			randf_range(-1.0, 1.0) * shake_amount,
			0.0,
			randf_range(-1.0, 1.0) * shake_amount
		)
	else:
		position = Vector3.ZERO


static func shake(trauma: float) -> void:
	if instance:
		instance._shake_trauma = minf(instance._shake_trauma + trauma, 1.0)


static func zoom_far() -> void:
	if instance:
		instance._zoom_to(POS_FAR)


static func zoom_close() -> void:
	if instance:
		instance._zoom_to(POS_CLOSE)


func _zoom_to(target_pos: Vector3) -> void:
	if _tween:
		_tween.kill()
	# Scene-tree tween so it isn't bound to this node's process_mode
	_tween = get_tree().create_tween()
	_tween.set_ease(Tween.EASE_IN_OUT)
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.tween_property(camera, "position", target_pos, ZOOM_DURATION)
