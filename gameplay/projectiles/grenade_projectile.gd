extends Node3D
class_name GrenadeProjectile

const EXPLOSION_RADIUS: float = 4.0
const EXPLOSION_DAMAGE: float = 25.0
const EXPLOSION_KNOCKBACK: float = 14.0

const LOB_ARC_HEIGHT: float = 2.0
const LOB_TRAVEL_DURATION: float = 0.45

const LAUNCH_SPEED: float = 18.0
const LAUNCH_GRAVITY: float = -16.0
const LAUNCH_INITIAL_ARC: float = 4.0

var _damage: float = EXPLOSION_DAMAGE
var _launch_velocity: Vector3 = Vector3.ZERO
var _is_launched: bool = false


# Called by GrenadeAbility — arcs to an exact world position.
func lob(target_position: Vector3) -> void:
	var start_position := global_position
	var tween := create_tween()
	tween.tween_method(
		func(travel_progress: float) -> void:
			var flat_position := start_position.lerp(target_position, travel_progress)
			var arc_offset := sin(travel_progress * PI) * LOB_ARC_HEIGHT
			global_position = Vector3(flat_position.x, flat_position.y + arc_offset, flat_position.z),
		0.0, 1.0, LOB_TRAVEL_DURATION
	)
	tween.tween_callback(_explode)


# Called by a grenade launcher weapon — travels in a direction with gravity and
# explodes when it hits the ground. No distance limit.
func launch(direction: Vector3, projectile_damage: float) -> void:
	_damage = projectile_damage
	var flat_dir := Vector3(direction.x, 0.0, direction.z).normalized()
	_launch_velocity = flat_dir * LAUNCH_SPEED + Vector3(0.0, LAUNCH_INITIAL_ARC, 0.0)
	_is_launched = true


func _process(delta: float) -> void:
	if not _is_launched:
		return
	_launch_velocity.y += LAUNCH_GRAVITY * delta
	global_position += _launch_velocity * delta
	if global_position.y <= 0.0:
		global_position.y = 0.0
		_explode()


func _explode() -> void:
	_is_launched = false
	for enemy in Level.instance.enemies.get_children():
		if not (enemy is Enemy):
			continue
		var to_enemy: Vector3 = enemy.global_position - global_position
		to_enemy.y = 0.0
		if to_enemy.length() > EXPLOSION_RADIUS:
			continue
		var outward_direction := to_enemy
		if outward_direction.length_squared() < 0.001:
			outward_direction = Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0))
		outward_direction = outward_direction.normalized()
		var damage_info := DamageInfo.new()
		damage_info.amount = _damage
		damage_info.direction = outward_direction
		damage_info.knockback = EXPLOSION_KNOCKBACK
		damage_info.source = self
		damage_info.type = DamageInfo.Type.ENERGY
		enemy.take_damage(damage_info)
	_spawn_explosion_vfx()
	queue_free()


func _spawn_explosion_vfx() -> void:
	Level.instance.explosion_pool.acquire(global_position, EXPLOSION_RADIUS)
