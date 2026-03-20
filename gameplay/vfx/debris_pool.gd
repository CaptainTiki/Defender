extends Node3D
class_name DebrisPool

const POOL_SIZE: int = 80

var _chunks: Array[DebrisChunk] = []


func _ready() -> void:
	for i in POOL_SIZE:
		var chunk: DebrisChunk = Prefabs.death_debris.instantiate()
		add_child(chunk)
		chunk.deactivate()
		_chunks.append(chunk)


func acquire(start_position: Vector3, velocity: Vector3) -> void:
	for chunk in _chunks:
		if not chunk.is_active():
			chunk.activate(start_position, velocity)
			return
	# Pool exhausted — silently skip rather than stutter


func deactivate_all() -> void:
	for chunk in _chunks:
		chunk.deactivate()
