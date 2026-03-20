extends RefCounted
class_name DamageInfo

enum Type {
	PHYSICAL,
	PROJECTILE,
	ENERGY,
}

var amount: float = 0.0
var direction: Vector3 = Vector3.ZERO
var knockback: float = 10.0
var source: Node = null
var type: Type = Type.PROJECTILE
