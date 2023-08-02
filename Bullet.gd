extends Area3D

var speed : float = 10.0

func _physics_process(delta):
	var forward_dir = global_transform.basis.z.normalized()
	global_translate(forward_dir * speed * delta)

func destroy():
	queue_free()

func _on_body_entered(_body):
	print("a")
