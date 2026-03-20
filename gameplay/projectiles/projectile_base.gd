extends Area3D
class_name Projectile

@export var speed: float = 28.0
@export var lifetime: float = 6.0

var damage: float = 10.0

var _direction: Vector3 = Vector3.ZERO
var _active: bool = false
var _age: float = 0.0

func _ready() -> void:
	area_entered.connect(_on_area_entered)


func _process(delta: float) -> void:
	if not _active:
		return
	position += _direction * speed * delta
	_age += delta
	if _age >= lifetime:
		queue_free()


func launch(direction: Vector3, projectile_damage: float) -> void:
	_direction = direction.normalized()
	damage = projectile_damage
	_active = true


func _on_area_entered(area: Area3D) -> void:
	var parent := area.get_parent()
	if parent.has_method("take_damage"):
		var damage_info : DamageInfo = DamageInfo.new()
		damage_info.amount = damage
		damage_info.direction = _direction
		damage_info.knockback = 1.8
		damage_info.source = self
		damage_info.type = DamageInfo.Type.PROJECTILE
		parent.take_damage(damage_info)
		if UpgradeManager.instance.current_run:
			UpgradeManager.instance.current_run.damage_dealt += damage
	queue_free()
