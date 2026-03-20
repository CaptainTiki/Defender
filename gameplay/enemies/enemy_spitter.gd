extends Enemy
class_name EnemySpitter

const PREFERRED_DIST: float = 12.5
const MIN_DIST: float = 8.5
const FIRE_RANGE: float = 16.0
const FIRE_COOLDOWN: float = 2.8
const FIRE_TELEGRAPH: float = 0.35

@onready var _spit_light: OmniLight3D = $SpitLight
@onready var _muzzle: Marker3D = %Muzzle

var _fire_timer: float = 1.5


func _ready() -> void:
	super._ready()
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.15, 0.85, 0.2, 1.0)
	mat.emission_enabled = true
	mat.emission = Color(0.15, 0.85, 0.2, 1.0)
	mat.emission_energy_multiplier = 1.4
	$Mesh/MeshInstance3D.material_override = mat


func _physics_process(delta: float) -> void:
	if _is_spawning:
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		else:
			velocity.y = 0.0
		move_and_slide()
		return

	if _player == null:
		_player = get_tree().get_first_node_in_group("player")

	_knockback = _knockback.move_toward(Vector3.ZERO, KNOCKBACK_DECAY * delta)
	_update_movement(delta)
	_update_fire(delta)


func _update_movement(delta: float) -> void:
	if _player == null:
		velocity.x = _knockback.x
		velocity.z = _knockback.z
		_apply_gravity_and_slide(delta)
		return

	var to_player := _player.global_position - global_position
	to_player.y = 0.0
	var dist := to_player.length()
	var flat_dir := to_player.normalized()

	# Always face the player
	mesh_node.rotation.y = atan2(-flat_dir.x, -flat_dir.z)

	var move_dir := Vector3.ZERO
	if dist > PREFERRED_DIST:
		move_dir = flat_dir
	elif dist < MIN_DIST:
		move_dir = -flat_dir

	velocity.x = move_dir.x * move_speed + _knockback.x
	velocity.z = move_dir.z * move_speed + _knockback.z
	_apply_gravity_and_slide(delta)


func _update_fire(delta: float) -> void:
	if _player == null:
		return
	var to_player := _player.global_position - global_position
	to_player.y = 0.0
	if to_player.length() > FIRE_RANGE:
		return
	_fire_timer -= delta
	if _fire_timer <= 0.0:
		_fire_timer = FIRE_COOLDOWN
		_telegraph_and_fire()


func _telegraph_and_fire() -> void:
	var tween := create_tween()
	tween.tween_property(_spit_light, "light_energy", 7.0, FIRE_TELEGRAPH)
	tween.tween_callback(_fire)
	tween.tween_property(_spit_light, "light_energy", 0.0, 0.12)


func _fire() -> void:
	if _player == null or not is_instance_valid(_player):
		return
	var dir := _player.global_position - global_position
	dir.y = 0.0
	dir = dir.normalized()
	var proj: EnemyProjectile = Prefabs.enemy_projectile.instantiate()
	Level.instance.projectiles.add_child(proj)
	proj.global_position = _muzzle.global_position
	proj.launch(dir)


func _apply_gravity_and_slide(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0.0
	move_and_slide()
