extends CharacterBody3D
class_name Enemy

signal died
signal spawn_complete

const GRAVITY: float = -20.0
const KNOCKBACK_DECAY: float = 10.0
const DEBRIS_COUNT_MIN: int = 12
const DEBRIS_COUNT_MAX: int = 20
const BIT_COUNT_MIN: int = 1
const BIT_COUNT_MAX: int = 4
const MELEE_DAMAGE: float = 20.0
const MELEE_RANGE: float = 1.1
const MELEE_COOLDOWN: float = 0.5
const LUNGE_RANGE: float = 2.2
const LUNGE_FORCE: float = 16.0
const LUNGE_COOLDOWN: float = 1.5
const LUNGE_DECAY: float = 14.0

@export var move_speed: float = 5.25

@onready var health_component: HealthComponent = $Components/HealthComponent
@onready var mesh_node: Node3D = $Mesh

var _anim_player: AnimationPlayer = null
var _player: Node3D = null
var _knockback: Vector3 = Vector3.ZERO
var _lunge_velocity: Vector3 = Vector3.ZERO
var _lunge_timer: float = 0.0
var _is_spawning: bool = true
var _melee_timer: float = 0.0


func _ready() -> void:
	health_component.died.connect(_on_died)
	if has_node("AnimationPlayer"):
		_anim_player = get_node("AnimationPlayer")
		_anim_player.animation_finished.connect(_on_spawn_animation_finished)
		_anim_player.play("spawn_in")
	else:
		_is_spawning = false
		spawn_complete.emit()


func _on_spawn_animation_finished(anim_name: StringName) -> void:
	if anim_name != "spawn_in":
		return
	_is_spawning = false
	spawn_complete.emit()


func _physics_process(delta: float) -> void:
	if _is_spawning:
		if not is_on_floor():
			velocity.y += GRAVITY * delta
		else:
			velocity.y = 0.0
		move_and_slide()
		return

	if _player == null:
		_player = get_tree().get_first_node_in_group("player")

	var move_dir := Vector3.ZERO
	if _player != null:
		var to_player := _player.global_position - global_position
		to_player.y = 0.0
		if to_player.length_squared() > 0.25:
			move_dir = to_player.normalized()
			mesh_node.rotation.y = atan2(-move_dir.x, -move_dir.z)

	_knockback = _knockback.move_toward(Vector3.ZERO, KNOCKBACK_DECAY * delta)
	_lunge_velocity = _lunge_velocity.move_toward(Vector3.ZERO, LUNGE_DECAY * delta)
	_melee_timer = max(0.0, _melee_timer - delta)
	_lunge_timer = max(0.0, _lunge_timer - delta)

	if _player != null and _lunge_timer <= 0.0:
		var to_player_flat := _player.global_position - global_position
		to_player_flat.y = 0.0
		var dist := to_player_flat.length()
		if dist > MELEE_RANGE and dist <= LUNGE_RANGE:
			_lunge_velocity = to_player_flat.normalized() * LUNGE_FORCE
			_lunge_timer = LUNGE_COOLDOWN

	if _player != null and _melee_timer <= 0.0:
		var to_player := _player.global_position - global_position
		to_player.y = 0.0
		if to_player.length() <= MELEE_RANGE:
			_deal_melee_damage(to_player.normalized())

	velocity.x = move_dir.x * move_speed + _knockback.x + _lunge_velocity.x
	velocity.z = move_dir.z * move_speed + _knockback.z + _lunge_velocity.z

	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0.0

	move_and_slide()


func _deal_melee_damage(direction: Vector3) -> void:
	if not _player.has_method("take_damage"):
		return
	_melee_timer = MELEE_COOLDOWN
	var info := DamageInfo.new()
	info.amount = MELEE_DAMAGE
	info.direction = direction
	info.knockback = 8.0
	info.source = self
	info.type = DamageInfo.Type.PHYSICAL
	_player.take_damage(info)


func take_damage(info: DamageInfo) -> void:
	if _is_spawning or health_component.is_dead():
		return
	health_component.take_damage(info.amount)
	_spawn_damage_number(info.amount)
	if info.direction != Vector3.ZERO:
		_apply_knockback(info.direction, info.knockback)
		_spawn_hit_particles(info.direction)


func _apply_knockback(direction: Vector3, force: float) -> void:
	var flat_dir := Vector3(direction.x, 0.0, direction.z).normalized()
	_knockback = flat_dir * force


func _spawn_hit_particles(hit_direction: Vector3) -> void:
	var particles: CPUParticles3D = Prefabs.hit_particles.instantiate()
	Level.instance.vfx.add_child(particles)
	particles.global_position = global_position + Vector3(0.0, 1.0, 0.0)
	# Reflect back off the surface for a ricochet look
	particles.launch(-hit_direction)


func _spawn_damage_number(amount: float) -> void:
	var number: Node3D = Prefabs.damage_number.instantiate()
	Level.instance.vfx.add_child(number)
	number.global_position = global_position + Vector3(randf_range(-0.3, 0.3), 2.2, randf_range(-0.3, 0.3))
	number.display(amount)


func _on_died() -> void:
	died.emit()
	_spawn_death_debris()
	_spawn_bits()
	queue_free()


func _spawn_death_debris() -> void:
	var count := randi_range(DEBRIS_COUNT_MIN, DEBRIS_COUNT_MAX)
	var spawn_pos := global_position + Vector3(0.0, 1.0, 0.0)
	for i in count:
		var outward := Vector3(randf_range(-1.0, 1.0), randf_range(0.4, 1.0), randf_range(-1.0, 1.0)).normalized()
		Level.instance.debris_pool.acquire(spawn_pos, outward * randf_range(2.0, 6.0))


func _spawn_bits() -> void:
	var count := randi_range(BIT_COUNT_MIN, BIT_COUNT_MAX)
	var spawn_pos := global_position + Vector3(0.0, 0.3, 0.0)
	for i in count:
		var bit: BitPickup = Prefabs.bit_pickup.instantiate()
		Level.instance.pickups.add_child(bit)
		bit.global_position = spawn_pos
		var outward := Vector3(randf_range(-1.0, 1.0), randf_range(0.5, 1.0), randf_range(-1.0, 1.0)).normalized()
		bit.launch(outward * randf_range(2.0, 4.5))
