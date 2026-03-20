extends Resource
class_name PlayerData

const SAVE_PATH := "user://player_data.tres"

# Spendable currency
@export var bits: int = 0

# Purchased upgrade IDs — "origin" is always pre-purchased
@export var purchased_upgrade_ids: Array[String] = ["origin"]

# Lifetime totals across all runs
@export var total_runs: int = 0
@export var total_kills: int = 0
@export var total_time_alive: float = 0.0
@export var total_bits_gathered: int = 0
@export var total_shots_fired: int = 0
@export var total_damage_dealt: float = 0.0
@export var total_damage_taken: float = 0.0


func commit_run(run: RunData) -> void:
	total_runs += 1
	total_kills += run.kills
	total_time_alive += run.time_alive
	total_bits_gathered += run.bits_gathered
	total_shots_fired += run.shots_fired
	total_damage_dealt += run.damage_dealt
	total_damage_taken += run.damage_taken
	# bits are already added incrementally during the run via add_bits()


func save() -> void:
	ResourceSaver.save(self, SAVE_PATH)


static func load_or_create() -> PlayerData:
	if ResourceLoader.exists(SAVE_PATH):
		return ResourceLoader.load(SAVE_PATH) as PlayerData
	return PlayerData.new()
