extends Node3D
class_name WeaponBase

@export var fire_rate: float = 2.0
@export var damage: float = 10.0

@onready var fire_point: Marker3D = $FirePoint

var _fire_cooldown: float = 0.0


func _ready() -> void:
	if UpgradeManager.instance:
		damage += UpgradeManager.instance.get_bonus(UpgradeData.EffectStat.DAMAGE)
		fire_rate += UpgradeManager.instance.get_bonus(UpgradeData.EffectStat.FIRE_RATE)


func _process(delta: float) -> void:
	if _fire_cooldown > 0.0:
		_fire_cooldown -= delta


func fire(aim_direction: Vector3) -> void:
	if _fire_cooldown > 0.0:
		return
	_fire_cooldown = 1.0 / fire_rate
	if UpgradeManager.instance.current_run:
		UpgradeManager.instance.current_run.shots_fired += 1
	var projectile: Projectile = Prefabs.projectile_base.instantiate()
	Level.instance.projectiles.add_child(projectile)
	projectile.global_position = fire_point.global_position
	projectile.launch(aim_direction, damage)
