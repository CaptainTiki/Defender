extends Node3D
class_name SpawnEffect

@onready var ring: MeshInstance3D = $Ring
@onready var light: OmniLight3D = $Light

var _material: StandardMaterial3D
var _pulse_tween: Tween


func _ready() -> void:
	_material = StandardMaterial3D.new()
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_material.albedo_color = Color(0.2, 0.85, 1.0, 1.0)
	_material.emission_enabled = true
	_material.emission = Color(0.2, 0.85, 1.0)
	_material.emission_energy_multiplier = 3.0
	ring.material_override = _material

	# Ring bursts in from nothing
	ring.scale = Vector3(0.05, 1.0, 0.05)
	var burst := get_tree().create_tween()
	burst.set_ease(Tween.EASE_OUT)
	burst.set_trans(Tween.TRANS_EXPO)
	burst.tween_property(ring, "scale", Vector3(1.0, 1.0, 1.0), 0.3)

	# Light pulses continuously until spawn is done
	_pulse_tween = get_tree().create_tween().set_loops(0)
	_pulse_tween.tween_property(light, "light_energy", 5.0, 0.18)
	_pulse_tween.tween_property(light, "light_energy", 1.2, 0.32)


func finish() -> void:
	if _pulse_tween:
		_pulse_tween.kill()
	var tween := get_tree().create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(ring, "scale", Vector3(1.8, 1.0, 1.8), 0.22)
	tween.tween_property(_material, "albedo_color:a", 0.0, 0.22)
	tween.tween_property(light, "light_energy", 0.0, 0.22)
	tween.chain().tween_callback(queue_free)
