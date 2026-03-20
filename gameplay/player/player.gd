extends CharacterBody3D
class_name Player

const GRAVITY: float = -20.0
const GROUND_PLANE_Y: float = 0.0
const CURSOR_RANGE: float = 6.0
const KNOCKBACK_DECAY: float = 8.0
const HIT_INVINCIBILITY_DURATION: float = 0.5

@onready var movement_component: MovementComponent = $Components/MovementComponent
@onready var health_component: HealthComponent = $Components/HealthComponent
@onready var mesh_node: Node3D = $Mesh
@onready var _mesh_instance: MeshInstance3D = $Mesh/MeshInstance3D
@onready var weapon_slot: Node3D = $Mesh/WeaponSlot
@onready var cursor: Node3D = $Cursor
@onready var camera: Camera3D = $CameraRig/Camera3D
@onready var _magnet_area: Area3D = $MagnetArea
@onready var grenade_ability: GrenadeAbility = $GrenadeAbility

var aim_direction: Vector3 = Vector3(0.0, 0.0, -1.0)
var current_weapon: WeaponBase = null
var _is_using_controller: bool = false
var _knockback: Vector3 = Vector3.ZERO
var _invincibility_timer: float = 0.0
var _hit_material: StandardMaterial3D


func _ready() -> void:
	add_to_group("player")
	movement_component.dash_started.connect(_on_dash_started)
	movement_component.dash_finished.connect(_on_dash_finished)
	health_component.died.connect(_on_died)
	if UpgradeManager.instance:
		health_component.max_health += UpgradeManager.instance.get_bonus(UpgradeData.EffectStat.MAX_HEALTH)
	equip_weapon(Prefabs.weapon_base)
	_magnet_area.area_entered.connect(_on_magnet_area_entered)
	_setup_hit_material()


func _setup_hit_material() -> void:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.55, 0.85, 1.0, 1.0)
	mat.emission_enabled = true
	mat.emission = Color(0.55, 0.85, 1.0, 1.0)
	mat.emission_energy_multiplier = 1.2
	_mesh_instance.material_override = mat
	_hit_material = mat


func _process(_delta: float) -> void:
	_update_aim()
	_update_facing()
	_update_cursor()
	_handle_firing()


func _physics_process(delta: float) -> void:
	_invincibility_timer = max(0.0, _invincibility_timer - delta)
	_knockback = _knockback.move_toward(Vector3.ZERO, KNOCKBACK_DECAY * delta)

	var input_direction := _get_movement_input()
	var desired_velocity := movement_component.calculate_velocity(input_direction)
	velocity.x = desired_velocity.x + _knockback.x
	velocity.z = desired_velocity.z + _knockback.z

	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0.0

	move_and_slide()


func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or event is InputEventJoypadMotion:
		_is_using_controller = true
	elif event is InputEventKey or event is InputEventMouseMotion or event is InputEventMouseButton:
		_is_using_controller = false

	if event.is_action_pressed("dodge"):
		var dash_dir := _get_movement_input()
		if dash_dir == Vector3.ZERO:
			dash_dir = aim_direction
		movement_component.start_dash(dash_dir)

	if event.is_action_pressed("fire_secondary"):
		grenade_ability.throw_grenade(global_position, cursor.global_position)


func take_damage(info: DamageInfo) -> void:
	if _invincibility_timer > 0.0 or health_component.is_dead():
		return
	_invincibility_timer = HIT_INVINCIBILITY_DURATION
	health_component.take_damage(info.amount)
	if UpgradeManager.instance.current_run:
		UpgradeManager.instance.current_run.damage_taken += info.amount
	if info.direction != Vector3.ZERO:
		_apply_knockback(info.direction, info.knockback)
	_flash_hit()
	CameraRig.shake(0.45)


func _apply_knockback(direction: Vector3, force: float) -> void:
	var flat_dir := Vector3(direction.x, 0.0, direction.z).normalized()
	_knockback = flat_dir * force


func _flash_hit() -> void:
	var tween := create_tween()
	tween.tween_property(_hit_material, "albedo_color", Color(1.0, 0.2, 0.2, 1.0), 0.0)
	tween.tween_property(_hit_material, "albedo_color", Color(0.55, 0.85, 1.0, 1.0), 0.25)


func equip_weapon(weapon_scene: PackedScene) -> void:
	for child in weapon_slot.get_children():
		child.queue_free()
	current_weapon = null
	if weapon_scene:
		current_weapon = weapon_scene.instantiate()
		weapon_slot.add_child(current_weapon)


func _handle_firing() -> void:
	if current_weapon and Input.is_action_pressed("fire_primary"):
		current_weapon.fire(aim_direction)


func _get_movement_input() -> Vector3:
	var input_dir := Vector2(
		Input.get_axis("move_left", "move_right"),
		Input.get_axis("move_up", "move_down")
	)
	if input_dir.length_squared() > 1.0:
		input_dir = input_dir.normalized()
	return Vector3(input_dir.x, 0.0, input_dir.y)


func _update_aim() -> void:
	if _is_using_controller:
		var right_stick := Vector2(
			Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
			Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
		)
		if right_stick.length() > 0.2:
			aim_direction = Vector3(right_stick.x, 0.0, right_stick.y).normalized()
	else:
		var mouse_world_pos := _get_mouse_world_position()
		var to_mouse := mouse_world_pos - global_position
		to_mouse.y = 0.0
		if to_mouse.length_squared() > 0.01:
			aim_direction = to_mouse.normalized()


func _update_facing() -> void:
	if aim_direction != Vector3.ZERO:
		# atan2(-x, -z) maps aim_direction onto rotation.y such that local -Z faces aim_direction
		mesh_node.rotation.y = atan2(-aim_direction.x, -aim_direction.z)


func _update_cursor() -> void:
	cursor.global_position = global_position + aim_direction * CURSOR_RANGE
	cursor.global_position.y = 0.05


func _get_mouse_world_position() -> Vector3:
	var mouse_pos := get_viewport().get_mouse_position()
	var ray_origin := camera.project_ray_origin(mouse_pos)
	var ray_direction := camera.project_ray_normal(mouse_pos)

	if abs(ray_direction.y) < 0.001:
		return global_position

	var t := (GROUND_PLANE_Y - ray_origin.y) / ray_direction.y
	return ray_origin + ray_direction * t


func _on_magnet_area_entered(area: Area3D) -> void:
	var pickup := area.get_parent()
	if pickup is BitPickup:
		pickup.magnetize(self)


func _on_dash_started() -> void:
	pass


func _on_dash_finished() -> void:
	pass


func begin_level_entry() -> void:
	health_component.set_health(1.0)


func heal_to_full(duration: float) -> void:
	var tween := create_tween()
	tween.tween_method(
		health_component.set_health,
		health_component.current_health,
		health_component.max_health,
		duration
	)


func _on_died() -> void:
	set_physics_process(false)
	set_process(false)
	Engine.time_scale = 0.3
	CameraRig.zoom_close()
	get_tree().create_timer(1.0, true, false, true).timeout.connect(_on_death_linger_finished)


func _on_death_linger_finished() -> void:
	Engine.time_scale = 1.0
	UpgradeManager.instance.commit_run()
	if MenuManager.instance != null:
		MenuManager.instance.show_menu(Menu.Type.UPGRADE)
	else:
		get_tree().reload_current_scene()
