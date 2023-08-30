extends CharacterBody3D

@onready var eyes = $Eyes
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var player_path : NodePath
@onready var nav_agent = $NavigationAgent3D
#@onready var state_machine = get_node("RIG-enemy/Skeleton3D/enemy/AnimationPlayer/AnimationTree").get("parameters/playback")

enum {
	alert,
	idle,
}
var check
@onready var target = get_node("../Player/head")
var state
var counter = 0
const turn_speed = 15
var speed := 3.0

func _process(delta):
	if global_position.distance_to(target.global_position) < 10:
		state = alert
	match state:
		alert:
			eyes.look_at(transform.origin + velocity, Vector3.UP)
			rotate_y(deg_to_rad(eyes.rotation.y * turn_speed))
			velocity = Vector3.ZERO
			nav_agent.set_target_position(target.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			if global_position.distance_to(target.global_position) > 1.5:
				velocity = (next_nav_point - global_transform.origin).normalized() * speed
				#state_machine.travel("walk_left")
		idle:
			pass

func _physics_process(delta):
	if not is_on_floor(): #If is in the air, apply gravity
		velocity.y -= gravity * delta
	move_and_slide() # Initiate movement and velocity
