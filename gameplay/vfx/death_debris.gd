extends Node3D
class_name DebrisChunk

const GRAVITY: float = -15.0
const LAND_Y: float = 0.05
const FADE_DELAY: float = 1.0
const FADE_DURATION: float = 2.0

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D

var _velocity: Vector3 = Vector3.ZERO
var _landed: bool = false
var _land_timer: float = 0.0
var _is_active: bool = false
var _material: StandardMaterial3D


func _ready() -> void:
	_material = mesh_instance.material_override.duplicate()
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh_instance.material_override = _material


func is_active() -> bool:
	return _is_active


func activate(start_position: Vector3, velocity: Vector3) -> void:
	_is_active = true
	_landed = false
	_land_timer = 0.0
	_velocity = velocity
	visible = true
	global_position = start_position
	rotation = Vector3.ZERO
	var random_scale := randf_range(0.4, 2.0)
	scale = Vector3(random_scale, random_scale, random_scale)
	if _material:
		_material.albedo_color.a = 1.0


func deactivate() -> void:
	_is_active = false
	visible = false
	_velocity = Vector3.ZERO
	_landed = false
	_land_timer = 0.0
	if _material:
		_material.albedo_color.a = 1.0


func _process(delta: float) -> void:
	if not _is_active:
		return

	if not _landed:
		_velocity.y += GRAVITY * delta
		position += _velocity * delta
		# Tumble while airborne
		rotation += _velocity.normalized() * 5.0 * delta
		if position.y <= LAND_Y:
			position.y = LAND_Y
			_velocity = Vector3.ZERO
			_landed = true
	else:
		_land_timer += delta
		var fade_t: float = clamp((_land_timer - FADE_DELAY) / FADE_DURATION, 0.0, 1.0)
		_material.albedo_color.a = 1.0 - fade_t
		if _land_timer >= FADE_DELAY + FADE_DURATION:
			deactivate()
