extends Area3D
class_name EnemyProjectile

const SPEED: float = 12.0
const LIFETIME: float = 15.0
const DAMAGE: float = 15.0

var _direction: Vector3 = Vector3.ZERO
var _timer: float = LIFETIME


func _ready() -> void:
	monitoring = false
	await get_tree().create_timer(0.08).timeout
	monitoring = true


func launch(direction: Vector3) -> void:
	_direction = direction


func _process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		queue_free()
		return
	global_position += _direction * SPEED * delta


func _on_body_entered(body: Node3D) -> void:
	if body.has_method("take_damage"):
		var info := DamageInfo.new()
		info.amount = DAMAGE
		info.direction = _direction
		info.knockback = 6.0
		info.source = self
		info.type = DamageInfo.Type.PROJECTILE
		body.take_damage(info)
	queue_free()
