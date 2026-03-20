extends Node3D
class_name GrenadeExplosionPool

const POOL_SIZE: int = 3

var _explosions: Array[GrenadeExplosion] = []


func _ready() -> void:
	for i in POOL_SIZE:
		var explosion: GrenadeExplosion = Prefabs.grenade_explosion.instantiate()
		add_child(explosion)
		_explosions.append(explosion)


func acquire(spawn_position: Vector3, explosion_radius: float) -> void:
	for explosion in _explosions:
		if not explosion.is_active():
			explosion.activate(spawn_position, explosion_radius)
			return
	# Pool exhausted — silently skip rather than stutter


func deactivate_all() -> void:
	for explosion in _explosions:
		explosion.deactivate()
