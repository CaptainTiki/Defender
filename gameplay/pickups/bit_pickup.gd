extends Node3D
class_name BitPickup

const GRAVITY: float = -12.0
const LAND_Y: float = 0.06
const COLLECT_DIST: float = 0.5
const MAGNET_RADIUS: float = 3.75
const PULL_SPEED_MIN: float = 3.5
const PULL_SPEED_MAX: float = 22.0

@onready var _mesh: MeshInstance3D = $Mesh
@onready var _light: OmniLight3D = $Light

var _velocity: Vector3 = Vector3.ZERO
var _landed: bool = false
var _magnetized: bool = false
var _player: Node3D = null
var _bob_time: float = 0.0
var value: int = 1


func _ready() -> void:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(1.0, 0.88, 0.15, 1.0)
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.88, 0.15, 1.0)
	mat.emission_energy_multiplier = 3.5
	_mesh.material_override = mat
	_bob_time = randf() * TAU


func launch(vel: Vector3) -> void:
	_velocity = vel


func magnetize(player: Node3D) -> void:
	if _magnetized:
		return
	_magnetized = true
	_player = player


func _process(delta: float) -> void:
	if _magnetized and _player != null:
		_do_magnet(delta)
		return

	if not _landed:
		_velocity.y += GRAVITY * delta
		position += _velocity * delta
		rotation += Vector3(1.0, 0.7, 0.4).normalized() * 7.0 * delta
		if position.y <= LAND_Y:
			position.y = LAND_Y
			_velocity = Vector3.ZERO
			_landed = true
	else:
		_bob_time += delta
		position.y = LAND_Y + sin(_bob_time * 2.8) * 0.055
		rotation.y += delta * 1.6


func _do_magnet(delta: float) -> void:
	var to_player: Vector3 = _player.global_position - global_position
	var dist: float = to_player.length()
	if dist < COLLECT_DIST:
		_collect()
		return
	var t: float = 1.0 - clamp(dist / MAGNET_RADIUS, 0.0, 1.0)
	var speed: float = lerpf(PULL_SPEED_MIN, PULL_SPEED_MAX, t * t)
	global_position += to_player.normalized() * speed * delta
	rotation.y += delta * lerpf(3.0, 12.0, t)
	_light.light_energy = lerpf(1.5, 5.0, t)


func _collect() -> void:
	UpgradeManager.instance.add_bits(value)
	queue_free()
