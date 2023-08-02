extends RigidBody3D

var velocity : float = 400.0
var a 

func _physics_process(delta):
	var forward_dir = global_transform.basis.z.normalized()
	global_translate(forward_dir * velocity * delta)

func _integrate_forces(_state):
	var collision = get_contact_count()
	if collision >= 1:
		queue_free()
		is_instance_valid(a)
		print(a)

func look_follow(state, current_transform, target_position):
	var up_dir = Vector3(0, 1, 0)
	var cur_dir = current_transform.basis * Vector3(0, 0, 1)
	var target_dir = (target_position - current_transform.origin).normalized()
	var rotation_angle = acos(cur_dir.x) - acos(target_dir.x)
	state.angular_velocity = up_dir * (rotation_angle / state.step)
