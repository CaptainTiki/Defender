extends Enemy
class_name EnemyCharger

enum ChargeState { APPROACH, WINDUP, CHARGE, RECOVERY }

const APPROACH_SPEED: float = 2.0
const CHARGE_SPEED: float = 18.0
const WINDUP_TIME: float = 1.2
const CHARGE_TIME: float = 0.55
const RECOVERY_TIME: float = 0.75
const CHARGE_TRIGGER_DIST: float = 5.5

@onready var _charge_light: OmniLight3D = $ChargeLight

var _charge_state: ChargeState = ChargeState.APPROACH
var _charge_direction: Vector3 = Vector3.ZERO
var _state_timer: float = 0.0
var _windup_tween: Tween


func _ready() -> void:
	super._ready()
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.9, 0.15, 0.1, 1.0)
	mat.emission_enabled = true
	mat.emission = Color(0.9, 0.15, 0.1, 1.0)
	mat.emission_energy_multiplier = 1.5
	$Mesh/MeshInstance3D.material_override = mat

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

	_knockback = _knockback.move_toward(Vector3.ZERO, KNOCKBACK_DECAY * delta)

	match _charge_state:
		ChargeState.APPROACH: _do_approach(delta)
		ChargeState.WINDUP:   _do_windup(delta)
		ChargeState.CHARGE:   _do_charge(delta)
		ChargeState.RECOVERY: _do_recovery(delta)


func _do_approach(delta: float) -> void:
	if _player == null:
		_apply_gravity_and_slide(delta)
		return

	var to_player := _player.global_position - global_position
	to_player.y = 0.0
	var dist := to_player.length()

	if dist <= CHARGE_TRIGGER_DIST:
		_enter_windup()
		return

	var move_dir := to_player.normalized() if dist > 0.5 else Vector3.ZERO
	if move_dir != Vector3.ZERO:
		mesh_node.rotation.y = atan2(-move_dir.x, -move_dir.z)

	velocity.x = move_dir.x * APPROACH_SPEED + _knockback.x
	velocity.z = move_dir.z * APPROACH_SPEED + _knockback.z
	_apply_gravity_and_slide(delta)


func _enter_windup() -> void:
	_charge_state = ChargeState.WINDUP
	_state_timer = WINDUP_TIME
	velocity = Vector3.ZERO

	if _player:
		var to_player := _player.global_position - global_position
		to_player.y = 0.0
		if to_player.length_squared() > 0.01:
			_charge_direction = to_player.normalized()
			mesh_node.rotation.y = atan2(-_charge_direction.x, -_charge_direction.z)

	if _anim_player:
		_anim_player.play("windup")

	if _windup_tween:
		_windup_tween.kill()
	_windup_tween = create_tween().set_loops(0)
	_windup_tween.tween_property(_charge_light, "light_energy", 8.0, 0.18)
	_windup_tween.tween_property(_charge_light, "light_energy", 0.8, 0.22)


func _do_windup(delta: float) -> void:
	_state_timer -= delta
	if _state_timer <= 0.0:
		_enter_charge()
		return
	velocity.x = _knockback.x
	velocity.z = _knockback.z
	_apply_gravity_and_slide(delta)


func _enter_charge() -> void:
	_charge_state = ChargeState.CHARGE
	_state_timer = CHARGE_TIME

	if _windup_tween:
		_windup_tween.kill()

	if _anim_player:
		_anim_player.play("charge")

	var flash := create_tween()
	flash.tween_property(_charge_light, "light_energy", 12.0, 0.04)
	flash.tween_property(_charge_light, "light_energy", 0.0, CHARGE_TIME)


func _do_charge(delta: float) -> void:
	_state_timer -= delta
	if _state_timer <= 0.0:
		_enter_recovery()
		return
	velocity.x = _charge_direction.x * CHARGE_SPEED
	velocity.z = _charge_direction.z * CHARGE_SPEED
	_apply_gravity_and_slide(delta)


func _enter_recovery() -> void:
	if _anim_player:
		_anim_player.play("default")
	_charge_state = ChargeState.RECOVERY
	_state_timer = RECOVERY_TIME


func _do_recovery(delta: float) -> void:
	_state_timer -= delta
	if _state_timer <= 0.0:
		_charge_state = ChargeState.APPROACH
	velocity.x = move_toward(velocity.x, 0.0, CHARGE_SPEED * 4.0 * delta)
	velocity.z = move_toward(velocity.z, 0.0, CHARGE_SPEED * 4.0 * delta)
	_apply_gravity_and_slide(delta)


func _apply_gravity_and_slide(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0.0
	move_and_slide()
