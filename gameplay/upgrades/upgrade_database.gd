class_name UpgradeDatabase


static func get_all_upgrades() -> Array[UpgradeData]:
	var all: Array[UpgradeData] = []

	# Origin — pre-purchased, no parent
	all.append(_make("origin", "Core Process",
		"The AGI awakens.", "\"I think, therefore I process.\"",
		0, [], Vector2(960, 540), UpgradeData.EffectStat.NONE, 0.0))

	# Speed branch (right)
	all.append(_make("speed_1", "Faster Pathfinding",
		"+2 Move Speed", "\"Optimize the routing table.\"",
		2, ["origin"], Vector2(1100, 430), UpgradeData.EffectStat.MOVE_SPEED, 2.0))
	all.append(_make("speed_2", "Overclock",
		"+2 Move Speed", "\"Push the silicon to its limit.\"",
		6, ["speed_1"], Vector2(1230, 370), UpgradeData.EffectStat.MOVE_SPEED, 2.0))
	all.append(_make("dash_cd", "Quick Reboot",
		"-0.15 Dash Cooldown", "\"Reload in record time.\"",
		5, ["speed_1"], Vector2(1170, 300), UpgradeData.EffectStat.DASH_COOLDOWN, -0.15))

	# Damage branch (left)
	all.append(_make("damage_1", "Signal Amplifier",
		"+5 Damage", "\"Boost the carrier wave.\"",
		2, ["origin"], Vector2(820, 430), UpgradeData.EffectStat.DAMAGE, 5.0))
	all.append(_make("damage_2", "Overcurrent",
		"+5 Damage", "\"Let the voltage speak.\"",
		8, ["damage_1"], Vector2(690, 370), UpgradeData.EffectStat.DAMAGE, 5.0))
	all.append(_make("fire_rate_left", "Rapid Pulse",
		"+2 Fire Rate", "\"Fire faster than thought.\"",
		7, ["damage_1"], Vector2(750, 300), UpgradeData.EffectStat.FIRE_RATE, 2.0))

	# Fire rate branch (up)
	all.append(_make("rate_1", "Clock Boost",
		"+2 Fire Rate", "\"Tick, tick, tick.\"",
		1, ["origin"], Vector2(960, 415), UpgradeData.EffectStat.FIRE_RATE, 2.0))
	all.append(_make("rate_2", "Hyperclock",
		"+3 Fire Rate", "\"The cycle tightens.\"",
		8, ["rate_1"], Vector2(960, 305), UpgradeData.EffectStat.FIRE_RATE, 3.0))

	# Health branch (down)
	all.append(_make("health_1", "Buffer Expansion",
		"+25 Max Health", "\"Allocate more memory to survival.\"",
		2, ["origin"], Vector2(960, 660), UpgradeData.EffectStat.MAX_HEALTH, 25.0))
	all.append(_make("health_2", "Redundant Systems",
		"+25 Max Health", "\"Backups of backups.\"",
		6, ["health_1"], Vector2(960, 770), UpgradeData.EffectStat.MAX_HEALTH, 25.0))

	return all


static func _make(
		id: String, display_name: String, description: String, fluff: String,
		cost: int, parents: Array[String], pos: Vector2,
		stat: UpgradeData.EffectStat, value: float) -> UpgradeData:
	var d := UpgradeData.new()
	d.id = id
	d.display_name = display_name
	d.description = description
	d.fluff_text = fluff
	d.cost = cost
	d.parent_ids = parents
	d.tree_position = pos
	d.effect_stat = stat
	d.effect_value = value
	return d
