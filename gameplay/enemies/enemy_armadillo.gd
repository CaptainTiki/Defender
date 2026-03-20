extends Enemy
class_name EnemyArmadillo

const ROTATE_SPEED: float = 1.2
const RING_SPIN_SPEED: float = 0.9
const PREFERRED_DIST: float = 8.0
const MIN_DIST: float = 5.0
const FIRE_RANGE: float = 14.0
const FIRE_COOLDOWN: float = 0.45

@onready var _armor_ring: Node3D = $ArmorRing
@onready var _muzzle_left: Marker3D = $Mesh/MuzzleLeft
@onready var _muzzle_right: Marker3D = $Mesh/MuzzleRight

var _fire_timer: float = 1.0
var _next_muzzle: int = 0

func _ready() -> void:
	super._ready()
	move_speed = 1.5

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
	_armor_ring.rotation.y += RING_SPIN_SPEED * delta
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

	var target_angle := atan2(-flat_dir.x, -flat_dir.z)
	var angle_diff := wrapf(target_angle - mesh_node.rotation.y, -PI, PI)
	mesh_node.rotation.y += clamp(angle_diff, -ROTATE_SPEED * delta, ROTATE_SPEED * delta)

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
		_fire_next()


func _fire_next() -> void:
	if _player == null or not is_instance_valid(_player):
		return
	var muzzle := _muzzle_left if _next_muzzle == 0 else _muzzle_right
	_next_muzzle = (_next_muzzle + 1) % 2
	var dir := _player.global_position - muzzle.global_position
	dir.y = 0.0
	dir = dir.normalized()
	var proj: EnemyProjectile = Prefabs.enemy_projectile.instantiate()
	Level.instance.projectiles.add_child(proj)
	proj.global_position = muzzle.global_position
	proj.launch(dir)


func _apply_gravity_and_slide(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0.0
	move_and_slide()
