extends Resource
class_name UpgradeData

enum EffectStat { NONE, MOVE_SPEED, DAMAGE, FIRE_RATE, MAX_HEALTH, DASH_COOLDOWN }

@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var fluff_text: String = ""
@export var cost: int = 10
@export var parent_ids: Array[String] = []
@export var tree_position: Vector2 = Vector2.ZERO
@export var effect_stat: EffectStat = EffectStat.NONE
@export var effect_value: float = 0.0
