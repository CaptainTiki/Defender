extends Node
class_name GrenadeAbility

signal grenade_ready
signal grenade_used

@export var cooldown_duration: float = 5.0

var _cooldown_timer: float = 0.0


func _process(delta: float) -> void:
	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta
		if _cooldown_timer <= 0.0:
			grenade_ready.emit()


func can_throw() -> bool:
	return _cooldown_timer <= 0.0


func get_cooldown_ratio() -> float:
	return clampf(_cooldown_timer / cooldown_duration, 0.0, 1.0)


func throw_grenade(spawn_position: Vector3, target_position: Vector3) -> void:
	if not can_throw():
		return
	_cooldown_timer = cooldown_duration
	grenade_used.emit()
	var grenade: GrenadeProjectile = Prefabs.grenade_projectile.instantiate()
	Level.instance.projectiles.add_child(grenade)
	grenade.global_position = spawn_position
	grenade.lob(target_position)
