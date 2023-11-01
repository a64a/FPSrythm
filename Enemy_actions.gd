extends CharacterBody3D

@onready var eyes = $Eyes
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 10
@export var player_path : NodePath
@onready var nav_agent = $NavigationAgent3D
@onready var state_machine = $"RIG-enemy/Skeleton3D/enemy/AnimationPlayer/AnimationTree".get("parameters/playback")
@onready var blood = get_node("../Player/head/finger/Camera_new/crosshair/hurtbox/hurtcam")

enum {
	alert,
	idle,
	sleep,
	fighting,
}
enum {
	var1,
	var2,
}
var check
@onready var target = get_node("../Player/head")
var state = sleep
var counter = 0
const turn_speed = 15
var speed := 3.0
var i = 0
var player_hp = 2
signal dead
var last_hit_var
var hp = 10

func is_it(obj):
	return is_instance_valid(obj)

func _process(_delta):
	if global_position.distance_to(target.global_position) < 10:
		if state == sleep:
			state_machine.travel("enemy-wake-up")
		state = alert
		await get_tree().create_timer(1.4).timeout
	if is_in_range(2):
		state = fighting
	match state:
		alert:
			eyes.look_at(transform.origin + velocity, Vector3.UP)
			rotate_y(deg_to_rad(eyes.rotation.y * turn_speed))
			velocity = Vector3.ZERO
			nav_agent.set_target_position(target.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			if global_position.distance_to(target.global_position) > 2:
				velocity = (next_nav_point - global_transform.origin).normalized() * speed
				state_machine.travel("walk-forward-left")
		fighting:
			if last_hit_var == var2 or last_hit_var == null:
				if is_in_range(2):
					eyes.look_at(target.global_transform.origin, Vector3.UP)
					rotate_y(deg_to_rad(eyes.rotation.y * turn_speed))
					last_hit_var = var1
					state_machine.travel("shoot")
			elif last_hit_var == var1:
				if is_in_range(4) == true and last_hit_var == var1:
					eyes.look_at(target.global_transform.origin, Vector3(0.001, 0.0, 0.0))
					rotate_y(deg_to_rad(eyes.rotation.y * turn_speed))
					state_machine.travel("melee")
					last_hit_var = var2
			print("fighting")
			velocity = Vector3(0,0,0)
		idle:
			pass

func _physics_process(delta):
	if not is_on_floor(): #If is in the air, apply gravity
		velocity.y -= gravity * delta
	move_and_slide() # Initiate movement and velocity

func is_in_range(attack_range) -> bool:
	if global_position.distance_to(target.global_position) < attack_range:
		return true
	else:
		return false

func _on_enemy_drill():
	if is_in_range(2) == true:
		player_hp -= 1
		blood.visible = true
		await get_tree().create_timer(0.2).timeout
		blood.visible = false
		print(player_hp)
		if player_hp == 0:
			emit_signal("dead")


func _on_enemy_pull():
	if is_in_range(4) == true:
		player_hp -= 1
		blood.visible = true
		await get_tree().create_timer(0.2).timeout
		blood.visible = false
		print(player_hp)
		if player_hp == 0:
			emit_signal("dead")
