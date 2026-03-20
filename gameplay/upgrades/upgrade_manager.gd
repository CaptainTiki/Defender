extends Node
class_name UpgradeManager

static var instance: UpgradeManager

var player_data: PlayerData
var current_run: RunData

var bits: int:
	get: return player_data.bits
	set(value): player_data.bits = value

var purchased_ids: Array[String]:
	get: return player_data.purchased_upgrade_ids

var _stat_bonuses: Dictionary = {}


func _ready() -> void:
	UpgradeManager.instance = self
	continue_game()


func new_game() -> void:
	player_data = PlayerData.new()
	player_data.save()
	_stat_bonuses.clear()


func continue_game() -> void:
	player_data = PlayerData.load_or_create()
	_rebuild_bonuses_from_purchases()


func start_run() -> void:
	current_run = RunData.new()


func commit_run() -> void:
	if current_run == null:
		return
	player_data.commit_run(current_run)
	player_data.save()
	current_run = null


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
	player_data.save()
	return true


func get_bonus(stat: UpgradeData.EffectStat) -> float:
	return _stat_bonuses.get(stat, 0.0)


func add_bits(amount: int) -> void:
	player_data.bits += amount
	if current_run:
		current_run.bits_gathered += amount


func _apply_effect(data: UpgradeData) -> void:
	if data.effect_stat == UpgradeData.EffectStat.NONE:
		return
	var current: float = _stat_bonuses.get(data.effect_stat, 0.0)
	_stat_bonuses[data.effect_stat] = current + data.effect_value


func _rebuild_bonuses_from_purchases() -> void:
	_stat_bonuses.clear()
	for upgrade in UpgradeDatabase.get_all_upgrades():
		if not is_purchased(upgrade.id):
			continue
		if upgrade.effect_stat == UpgradeData.EffectStat.NONE:
			continue
		var current: float = _stat_bonuses.get(upgrade.effect_stat, 0.0)
		_stat_bonuses[upgrade.effect_stat] = current + upgrade.effect_value
