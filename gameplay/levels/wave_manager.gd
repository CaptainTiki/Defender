extends Node
class_name WaveManager

@export var spawn_radius: float = 11.0

# Initial burst to immediately populate the field
@export var initial_burst_count: int = 3
@export var initial_burst_interval: float = 0.4

# Ongoing pressure — interval shrinks over time
@export var spawn_interval_start: float = 3.5
@export var spawn_interval_min: float = 0.8
@export var spawn_interval_ramp_rate: float = 0.08  # seconds shaved per second of runtime

var _enemies_alive: int = 0
var _spawn_timer: float = 0.0
var _current_spawn_interval: float = 0.0
var _total_elapsed: float = 0.0
var _running: bool = false
var _burst_remaining: int = 0
var _burst_timer: float = 0.0


func _ready() -> void:
	call_deferred("_connect_upgrade_screen")


func _connect_upgrade_screen() -> void:
	if MenuManager.instance == null:
		return
	var upgrade_screen: Menu = MenuManager.instance.menus.get(Menu.Type.UPGRADE)
	if upgrade_screen and upgrade_screen.has_signal("upgrades_confirmed"):
		upgrade_screen.upgrades_confirmed.connect(_on_upgrades_confirmed)


func _on_upgrades_confirmed() -> void:
	get_tree().reload_current_scene()


func start_run() -> void:
	Engine.time_scale = 1.0
	CameraRig.zoom_far()
	_current_spawn_interval = spawn_interval_start
	_total_elapsed = 0.0
	_running = true
	_burst_remaining = initial_burst_count
	_burst_timer = 0.5


func _process(delta: float) -> void:
	if not _running:
		return

	_total_elapsed += delta
	_current_spawn_interval = maxf(spawn_interval_min, spawn_interval_start - _total_elapsed * spawn_interval_ramp_rate)

	# Initial burst: fire off the opening enemies in quick succession
	if _burst_remaining > 0:
		_burst_timer -= delta
		if _burst_timer <= 0.0:
			_spawn_enemy()
			_burst_remaining -= 1
			_burst_timer = initial_burst_interval
		return

	# Continuous pressure spawning
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_enemy()
		_spawn_timer = _current_spawn_interval


func _spawn_enemy() -> void:
	var spawn_pos := _random_spawn_position()

	var effect: SpawnEffect = Prefabs.spawn_effect.instantiate()
	Level.instance.vfx.add_child(effect)
	effect.global_position = spawn_pos

	var enemy: Enemy = _pick_enemy_prefab().instantiate()
	enemy.died.connect(_on_enemy_died)
	enemy.spawn_complete.connect(effect.finish)
	Level.instance.enemies.add_child(enemy)
	enemy.global_position = spawn_pos
	_enemies_alive += 1


func _pick_enemy_prefab() -> PackedScene:
	# Introduce enemy types gradually as pressure builds
	var charger_weight: float = clamp((_total_elapsed - 20.0) * 0.02, 0.0, 0.3)
	var spitter_weight: float = clamp((_total_elapsed - 40.0) * 0.015, 0.0, 0.2)
	var roll := randf()
	if roll < spitter_weight:
		return Prefabs.enemy_spitter
	if roll < spitter_weight + charger_weight:
		return Prefabs.enemy_charger
	return Prefabs.enemy_base


func _random_spawn_position() -> Vector3:
	var angle := randf() * TAU
	return Vector3(cos(angle) * spawn_radius, 0.0, sin(angle) * spawn_radius)


func _on_enemy_died() -> void:
	_enemies_alive -= 1
