extends Node3D
class_name GrenadeExplosion

const SHOCKWAVE_EXPAND_DURATION: float = 0.45
const FLASH_FADE_DURATION: float = 0.2

@onready var burst_particles: CPUParticles3D = $BurstParticles
@onready var debris_particles: CPUParticles3D = $DebrisParticles
@onready var shockwave_ring: MeshInstance3D = $ShockwaveRing
@onready var flash_light: OmniLight3D = $FlashLight

var _is_active: bool = false
var _ring_material: StandardMaterial3D
var _flash_initial_energy: float
var _active_tween: Tween


func _ready() -> void:
	_ring_material = shockwave_ring.get_surface_override_material(0).duplicate() as StandardMaterial3D
	shockwave_ring.set_surface_override_material(0, _ring_material)
	_flash_initial_energy = flash_light.light_energy
	visible = false


func is_active() -> bool:
	return _is_active


func activate(spawn_position: Vector3, explosion_radius: float) -> void:
	_is_active = true
	global_position = spawn_position
	visible = true

	burst_particles.restart()
	debris_particles.restart()

	_reset_visuals()
	_run_animations(explosion_radius)

	var cleanup_delay := maxf(burst_particles.lifetime, debris_particles.lifetime) + 0.1
	get_tree().create_timer(cleanup_delay).timeout.connect(deactivate, CONNECT_ONE_SHOT)


func deactivate() -> void:
	_is_active = false
	visible = false
	if _active_tween:
		_active_tween.kill()
	burst_particles.emitting = false
	debris_particles.emitting = false


func _reset_visuals() -> void:
	shockwave_ring.scale = Vector3.ZERO
	var start_color := _ring_material.albedo_color
	_ring_material.albedo_color = Color(start_color.r, start_color.g, start_color.b, 0.9)
	flash_light.light_energy = _flash_initial_energy


func _run_animations(explosion_radius: float) -> void:
	if _active_tween:
		_active_tween.kill()
	_active_tween = create_tween().set_parallel(true)

	_active_tween.tween_property(shockwave_ring, "scale",
		Vector3(explosion_radius, 1.0, explosion_radius), SHOCKWAVE_EXPAND_DURATION
	).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)

	var start_color := _ring_material.albedo_color
	_active_tween.tween_property(_ring_material, "albedo_color",
		Color(start_color.r, start_color.g, start_color.b, 0.0), SHOCKWAVE_EXPAND_DURATION
	).set_ease(Tween.EASE_IN)

	_active_tween.tween_property(flash_light, "light_energy", 0.0, FLASH_FADE_DURATION)
