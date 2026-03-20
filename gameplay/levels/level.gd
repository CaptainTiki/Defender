extends Node3D
class_name Level

static var instance: Level

@onready var player_spawn: Node3D = $PlayerSpawn
@onready var enemies: Node3D = $Entities/Enemies
@onready var projectiles: Node3D = $Entities/Projectiles
@onready var pickups: Node3D = $Entities/Pickups
@onready var vfx: Node3D = $Entities/VFX
@onready var debris_pool: DebrisPool = $DebrisPool
@onready var explosion_pool: GrenadeExplosionPool = $ExplosionPool
@onready var wave_manager: WaveManager = $WaveManager


func _ready() -> void:
	Level.instance = self
	var player := _spawn_player()
	_run_level_intro(player)


func _spawn_player() -> Player:
	var player_instance: Player = Prefabs.player.instantiate()
	add_child(player_instance)
	player_instance.global_position = player_spawn.global_position
	return player_instance


func _run_level_intro(player: Player) -> void:
	player.begin_level_entry()
	CameraRig.zoom_far()
	await get_tree().create_timer(CameraRig.ZOOM_DURATION + 0.3).timeout
	CameraRig.zoom_close()
	player.heal_to_full(CameraRig.ZOOM_DURATION)
	await get_tree().create_timer(CameraRig.ZOOM_DURATION).timeout
	wave_manager.start_run()


func clear_wave() -> void:
	debris_pool.deactivate_all()
	explosion_pool.deactivate_all()
	_clear_container(enemies)
	_clear_container(projectiles)
	_clear_container(pickups)
	_clear_container(vfx)


func _clear_container(container: Node3D) -> void:
	for child in container.get_children():
		child.queue_free()
