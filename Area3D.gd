extends Area3D

signal exploded

@export var muzzle_velocity = 25
@export var g = Vector3.DOWN * 20

var Bullet

var velocity = Vector3.ZERO


func _physics_process(delta):
	velocity += g * delta
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta
	
	if Input.is_action_just_pressed("shoot"):
		var b = Bullet.instance()
		owner.add_child(b)
		b.transform = $finger2.global_transform
		b.velocity = -b.transform.basis.z * b.muzzle_velocity

func _on_Shell_body_entered(body):
	emit_signal("exploded", transform.origin)
	queue_free()
