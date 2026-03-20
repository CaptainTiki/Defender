extends Node3D
class_name ArmorPlate

signal plate_destroyed(plate: ArmorPlate)

const PLATE_HP: float = 40.0
const FADE_DELAY: float = 0.4
const FADE_DURATION: float = 4.0

@onready var _mesh: MeshInstance3D = $Mesh

var _hp: float = PLATE_HP
var _alive: bool = true


func _ready() -> void:
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.9, 0.45, 0.05, 1.0)
	mat.emission_enabled = true
	mat.emission = Color(0.9, 0.45, 0.05, 1.0)
	mat.emission_energy_multiplier = 1.5
	_mesh.material_override = mat


func take_damage(info: DamageInfo) -> void:
	if not _alive:
		return
	_hp -= info.amount
	if _hp <= 0.0:
		_destroy()


func _destroy() -> void:
	_alive = false
	plate_destroyed.emit(self)
	_spawn_physics_shard()
	queue_free()


func _spawn_physics_shard() -> void:
	var center : Vector3 = get_parent().get_parent().global_position

	var rb := RigidBody3D.new()
	rb.collision_layer = 0
	Level.instance.vfx.add_child(rb)
	rb.global_transform = global_transform

	var mi := MeshInstance3D.new()
	mi.mesh = _mesh.mesh
	var fade_mat := StandardMaterial3D.new()
	fade_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fade_mat.albedo_color = Color(0.9, 0.45, 0.05, 1.0)
	fade_mat.emission_enabled = true
	fade_mat.emission = Color(0.9, 0.45, 0.05, 1.0)
	fade_mat.emission_energy_multiplier = 1.5
	fade_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mi.material_override = fade_mat
	rb.add_child(mi)

	var col := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.08, 0.65, 0.5)
	col.shape = box
	rb.add_child(col)

	var outward := Vector3(global_position.x - center.x, 0.0, global_position.z - center.z)
	if outward.length_squared() > 0.001:
		outward = outward.normalized()
	else:
		outward = Vector3(randf_range(-1.0, 1.0), 0.0, randf_range(-1.0, 1.0)).normalized()
	outward.y = randf_range(0.3, 0.7)
	rb.apply_central_impulse(outward * randf_range(4.0, 8.0))
	rb.apply_torque_impulse(Vector3(randf_range(-4.0, 4.0), randf_range(-2.0, 2.0), randf_range(-4.0, 4.0)))

	var tween := get_tree().create_tween()
	tween.tween_interval(FADE_DELAY)
	tween.tween_property(fade_mat, "albedo_color:a", 0.0, FADE_DURATION)
	tween.tween_callback(rb.queue_free)
