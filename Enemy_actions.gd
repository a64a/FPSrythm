extends CharacterBody3D

@onready var eyes = $Eyes
@onready var player = get_node("../../../Player")
@onready var nav: NavigationAgent3D = $NavigationAgent3D

var path = []
var path_node = 0
var accel = 20
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

enum {
	alert,
	idle,
}

var target 
var state

const turn_speed = 5
const speed = 10

func _on_aggro_range_body_entered(body):
	if body.is_in_group("Player"):
		state = alert
		target = body


func _on_aggro_range_body_exited(body):
	if body.is_in_group("Player"):
		state = idle

func _process(_delta):
	match state:
		alert:
			eyes.look_at(target.global_transform.origin, Vector3.UP)
			rotate_y(deg_to_rad(eyes.rotation.y * turn_speed))
		idle:
			pass

func _physics_process(delta):
	var direction = Vector3()
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	
	velocity = velocity.lerp(direction * speed, accel * delta)
	if Input.is_action_pressed("slow_time"): # If left single quote is held, slow time
		delta = (delta/2)
	else:
		delta = delta
	if not is_on_floor(): #If is in the air, apply gravity
		velocity.y -= gravity * delta
	move_and_slide()
