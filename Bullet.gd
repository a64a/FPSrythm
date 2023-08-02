extends Area3D

var speed : float = 30.0
var damage : int = 1

func _physics_process(delta):
	var forward_dir = global_transform.basis.z.normalized()
	global_translate(forward_dir * speed * delta)

func destroy():
	queue_free()

func _on_body_entered(body):
	pass
