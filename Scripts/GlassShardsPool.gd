extends Node

@export var shard_scene: PackedScene
@export var pool_size: int = 500

var pool: Array[RigidBody3D] = []
var available: Array[RigidBody3D] = []

func _ready():
	for i in range(pool_size):
		var rb: RigidBody3D = shard_scene.instantiate()
		rb.name = "Shard_%d" % i
		rb.visible = false
		rb.freeze = true
		rb.sleeping = true
		add_child(rb)
		pool.append(rb)
		available.append(rb)

func get_free_shard() -> RigidBody3D:
	if available.size() == 0:
		return null
	var rb = available.pop_back()
	rb.visible = true
	rb.freeze = false
	rb.sleeping = false
	#rb.mode = RigidBody3D.MODE_RIGID
	rb.mass = 0.1
	return rb

func return_shard(rb: RigidBody3D):
	rb.freeze = true
	rb.sleeping = true
	rb.visible = false
	rb.linear_velocity = Vector3.ZERO
	rb.angular_velocity = Vector3.ZERO
	rb.global_transform = Transform3D.IDENTITY
	if rb.get_child_count() > 0:
		var mesh = rb.get_child(0)
		rb.remove_child(mesh)
		mesh.queue_free()
	available.append(rb)
