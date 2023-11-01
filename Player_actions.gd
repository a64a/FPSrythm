extends CharacterBody3D

@onready var camera_mount = $head/finger
@onready var state_machine = $head/finger/AnimationPlayer/AnimationTree.get("parameters/playback")
@onready var ray1 = get_node("head/finger/RIG-finger/RayCast3D") 
@onready var ray2 = get_node("head/finger/RIG-finger/RayCast3D2")
@onready var hole = preload("res://Scenes/VFX/hole.tscn")
@onready var crosshair = get_node("head/finger/Camera_new/crosshair/CenterContainer/Sprite2D")
@onready var camera = get_node("head/finger/Camera_new")
@onready var guncam = get_node("head/finger/Camera_new/SubViewportContainer/SubViewport/Camera3D")
@onready var audio = get_node("../Music Player")
@onready var single_beat = preload("res://music + SFX/LMMS files/Single beat.wav")
@onready var head = $head
@export var sens = 0.5

var latest_beat_action = []
var state
var speed
var walk_speed = 5.0
var sprint_speed = 7.0
var jump_velocity = 4.6
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var counter = 0
var can_shoot = true
const BOB_FREQ = 1.8
const BOB_AMP = 0.03
var t_bob = 0.0


func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # Forces the mouse into the center

func timer(time):
	await get_tree().create_timer(time).timeout

func _process(_a):
	guncam.global_transform = camera.global_transform # Adds a viewport to the arms and anything held, as to not clip into walls

func create_beat_queue_system():
	if latest_beat_action.size() < 6:
		if Input.is_action_just_pressed("shoot"):
			latest_beat_action.append("shoot")
		if Input.is_action_just_pressed("punch"):
			latest_beat_action.append("punch")
	state_machine.travel("idle")

func use_beat_queue_system():
	if latest_beat_action.size() != 0 and latest_beat_action[0] != "":
		if can_shoot == true and latest_beat_action[0] == "shoot":
			if ray1.is_colliding() or ray2.is_colliding(): # Check whether to run distance_check
				can_shoot = false
				distance_check()
				await get_tree().create_timer(0.35).timeout # Waits to sync hud switch with animation and firing
				latest_beat_action.erase("shoot")
		elif latest_beat_action[0] == "punch":
			if 1 == 1:
				state_machine.travel("punch")
				latest_beat_action.erase("punch")

func check_on_beat(delta):
	counter += delta # Add count
	create_beat_queue_system()
	if counter >= 0.5: # Set a 120 bpm counter
		can_shoot = true
		print(latest_beat_action)
		audio.stream = single_beat # Set sound to play
		audio.play() # Play sound
		counter = 0 # Reset counter
		use_beat_queue_system()

func ray_check(no_ray): # Checks if any of the rays collides
	if no_ray == ray1: # Decides how much the function should wait before checking ray collision base on which finger fires
		await get_tree().create_timer(0.045).timeout
	else:
		await get_tree().create_timer(0.25).timeout
	no_ray.add_exception(get_node(".")) # Removes collision with player
	var collider = no_ray.get_collider() # Gets the colliding objects id
	var truth_check = is_instance_valid(collider) # Checks if the instance is valid
	if truth_check == true and collider.is_in_group("enemy"): # If instance is valind and in the group enemy, destroy it
		if collider.hp >= 1:
			collider.hp -= 1
			print("hit")
		else:
			collider.queue_free()
	else: # Otherwise add a bullet hole
		var b = hole.instantiate()
		get_tree().get_root().add_child(b)
		b.global_transform.origin = no_ray.get_collision_point()
		var surface_dir_up = Vector3(0,1,0)
		var surface_dir_down = Vector3(0,-1,0)
		if no_ray.get_collision_normal() == surface_dir_up: # If the colliders surface is a ceiling, lay flat in appropriate direction
			b.look_at(no_ray.get_collision_point() + no_ray.get_collision_normal(), Vector3.RIGHT)
		elif no_ray.get_collision_normal() == surface_dir_down: # If the colliders surface is a wall, lay flat in appropriate direction
			b.look_at(no_ray.get_collision_point() + no_ray.get_collision_normal(), Vector3.RIGHT)
		else: # Else, lay down ( for floors )
			b.look_at(no_ray.get_collision_point() + no_ray.get_collision_normal(), Vector3.DOWN)
		await get_tree().create_timer(0.145).timeout # Endlag, and to avoid animation cancelling
	can_shoot = false

func distance_check(): # Checks whether the collider is close enough to trigger the punch
	state_machine.travel("shoot") 
	if ray1.is_colliding():
		ray_check(ray1)
	if ray2.is_colliding():
		ray_check(ray2)
	can_shoot = false
	await get_tree().create_timer(0.35).timeout # Waits to sync hud switch with animation and firing
	return 0;

func _input(event):
	if event is InputEventMouseMotion: # If input is a mouse movement:
		var yRot = rotation.y - event.relative.x / 1000 * 5 # Rotate on y axis, x is placed individually in the head.gd script, as to not rotate the character
		rotation = Vector3(0, yRot, 0) # Rotate

func _physics_process(delta):
	check_on_beat(delta) # Moving this before the slow time command, puts the music out of the slow effect
	if Input.is_action_pressed("slow_time"): # If left single quote is held, slow time
		delta = (delta/2)
	else:
		delta = delta
	if not is_on_floor(): #If is in the air, apply gravity
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor(): # If space is pressed and isnt in the air, jump
		velocity.y = jump_velocity
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back") # Get absolute input direction
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() # Make that direction relative to ratation
	if Input.is_action_just_pressed("pause"):
		get_tree().change_scene_to_file("res://Scenes/Menus/menu.tscn") # Quit to main menu
	if Input.is_action_pressed("dash"):
		speed = sprint_speed # Change speed to sprint speed when sprinting
	else:
		speed = walk_speed # Else, dont sprint
	if is_on_floor(): # Slowing and speeding up
		if direction: # If there is a directional input, speed up
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 5.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 5.0)
		else: # Else slow down
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else: # If is in the air, keep direction and limit aerial movement
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)
	move_and_slide() # Initiate movement and velocity
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP + 2.25
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP - 0.05
	return pos


func _on_hydrant_dead():
		get_tree().change_scene_to_file("res://Scenes/Menus/menu.tscn") # Quit to main menu
