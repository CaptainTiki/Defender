extends Node
class_name UpgradeManager

static var instance: UpgradeManager

var bits: int = 100  # seeded for testing; real value comes from pickups
var purchased_ids: Array[String] = ["origin"]

var _stat_bonuses: Dictionary = {}


func _ready() -> void:
	UpgradeManager.instance = self


func is_purchased(id: String) -> bool:
	return purchased_ids.has(id)


func has_purchased_parent(data: UpgradeData) -> bool:
	if data.parent_ids.is_empty():
		return true
	for parent_id in data.parent_ids:
		if is_purchased(parent_id):
			return true
	return false


func can_purchase(data: UpgradeData) -> bool:
	if is_purchased(data.id):
		return false
	if bits < data.cost:
		return false
	return has_purchased_parent(data)


func purchase(data: UpgradeData) -> bool:
	if not can_purchase(data):
		return false
	bits -= data.cost
	purchased_ids.append(data.id)
	_apply_effect(data)
	return true


func get_bonus(stat: UpgradeData.EffectStat) -> float:
	return _stat_bonuses.get(stat, 0.0)


func add_bits(amount: int) -> void:
	bits += amount


func _apply_effect(data: UpgradeData) -> void:
	if data.effect_stat == UpgradeData.EffectStat.NONE:
		return
	var current: float = _stat_bonuses.get(data.effect_stat, 0.0)
	_stat_bonuses[data.effect_stat] = current + data.effect_value
