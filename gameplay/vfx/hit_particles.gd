extends CPUParticles3D
class_name HitParticles


func _ready() -> void:
	finished.connect(queue_free)


func launch(hit_direction: Vector3) -> void:
	direction = hit_direction
	emitting = true
