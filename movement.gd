extends CharacterBody3D

@onready var camera_mount = $head/finger
@onready var state_machine = $head/finger/AnimationPlayer/AnimationTree.get("parameters/playback")
@onready var ray1 = get_node("head/finger/RIG-finger/RayCast3D") 
@onready var ray2 = get_node("head/finger/RIG-finger/RayCast3D2")
@onready var hole = preload("res://Scenes/bullethole.tscn")
@onready var crosshair = get_node("head/finger/Camera3D/crosshair/CenterContainer/Sprite2D")
@onready var weapon = get_node("head/finger/Camera3D/crosshair/Container/Weapon")
@onready var camera = get_node("head/finger/Camera3D")
@onready var guncam = get_node("head/finger/Camera3D/SubViewportContainer/SubViewport/Camera3D")
@onready var _original_camera_translation: Vector3 = camera.transform.origin

@export var g = Vector3.DOWN * 20
@export var sens = 0.5

var _delta := 0.0
var SPEED
var walk = 5.0
var sprint = 7.0
var JUMP_VELOCITY = 4.5
var can_shoot = true
var hud_scale = Vector2()
var ammo = 2
var t_bob = 0.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var seconds_since_last_beat = 0
var bpm = 120 #beats per minute (określa tempo)
var current_frame_is_on_beat = false

var last_beat_action_pressed = "none"
var was_shift_pressed_on_last_action = false
var seconds_since_last_action_press = 0

const freq = 2.0
const amp = 0.08

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(_delta):
	guncam.global_transform = camera.global_transform

func cooldowns():
#	if can_shoot == false:
		scale.x = 0.1
		scale.y = 0.1
		crosshair.texture = load("res://assets/Barrier.png")
		crosshair.scale = hud_scale
		await get_tree().create_timer(1).timeout
		crosshair.texture = load("res://.godot/imported/1022053-200.png-b3a218dc2025a6a90356d54d9a8a372d.s3tc.ctex")
		hud_scale.x = 0.25
		hud_scale.y = 0.25
		crosshair.scale = hud_scale
		weapon.texture = load("res://assets/unnamed.png")
		can_shoot = true
	#else:
		#can_shoot = false

func ray_check(no_ray):
	ammo -= 1
	if no_ray == ray1:
		await get_tree().create_timer(0.045).timeout
	else:
		await get_tree().create_timer(0.25).timeout
	no_ray.add_exception(get_node("."))
	var collider = no_ray.get_collider()
	var truth_check = is_instance_valid(collider)
	if truth_check == true and collider.is_in_group("enemy"):
		collider.queue_free()
	else:
		var b = hole.instantiate()
		get_tree().get_root().add_child(b)
		b.global_transform.origin = no_ray.get_collision_point()
		var surface_dir_up = Vector3(0,1,0)
		var surface_dir_down = Vector3(0,-1,0)
		if no_ray.get_collision_normal() == surface_dir_up:
			b.look_at(no_ray.get_collision_point() + no_ray.get_collision_normal(), Vector3.RIGHT)
		elif no_ray.get_collision_normal() == surface_dir_down:
			b.look_at(no_ray.get_collision_point() + no_ray.get_collision_normal(), Vector3.RIGHT)
		else:
			b.look_at(no_ray.get_collision_point() + no_ray.get_collision_normal(), Vector3.DOWN)
		await get_tree().create_timer(0.145).timeout

func collision_check(a, b):
	var origin = ray1.global_transform.origin
	var collision_point = ray1.get_collision_point()
	var distance1 = origin.distance_to(collision_point)
	origin = ray2.global_transform.origin
	collision_point = ray2.get_collision_point()
	var distance2 = origin.distance_to(collision_point)
	if distance1 < 1 or distance2 < 1:
		state_machine.travel("punch left")
	else:
		can_shoot = false
		state_machine.travel("shoot")
		if ray1.is_colliding():
			ray_check(ray1)
		if ray2.is_colliding():
			ray_check(ray2)
		weapon.texture = load(a)
		await get_tree().create_timer(0.35).timeout
		weapon.texture = load(b)

func _input(event):
	if event is InputEventMouseMotion:
		var yRot = rotation.y - event.relative.x / 1000 * 5
		rotation = Vector3(0, yRot, 0)
		
func update_beat_timer_and_check_if_frame_is_on_beat(delta): #Sprawdza czy aktualna klatka fizyki jest na rytmie (umożliwia strzelanie itd)
	seconds_since_last_beat =+ delta
	
	if(seconds_since_last_beat > (60/bpm) ):
		seconds_since_last_beat =- (60/bpm)
		current_frame_is_on_beat = true
	

func fall_if_mid_air(delta):
	if not is_on_floor(): 
		velocity.y -= gravity * delta

func jump_if_pressed():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

var input_dir #kierunek ruchu chodzenia (osobne wektory)
var direction #zsumowane wektory ruchu chodzenia (xyz od -1 do 1)

func set_wasd_movement_direction():
	input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
func shoot_gun_if_last_action_press_is_shoot():
	if(last_beat_action_pressed == "shoot"):
		if ray1.is_colliding() or ray2.is_colliding():
			collision_check("res://assets/IMG-0301.PNG", "res://assets/IMG-0300.PNG")
		
func reload_if_last_action_press_is_reload():
	if(last_beat_action_pressed == "reload"):
		state_machine.travel("pause")
		cooldowns()
		await get_tree().create_timer(1).timeout
		return 0
		
func pause_if_last_action_press_is_pause():
	if(last_beat_action_pressed == "pause"):
		get_tree().change_scene_to_file("res://Scenes/menu.tscn")
		
func check_last_beat_action_press(delta): 
	if Input.is_action_just_pressed("shoot") and can_shoot==true:
		last_beat_action_pressed = "shoot"
		seconds_since_last_action_press = 0
	elif Input.is_action_just_pressed("reload"):
		last_beat_action_pressed = "reload"
		seconds_since_last_action_press = 0
	else:
		if(current_frame_is_on_beat):
			state_machine.travel("idle")
		
	seconds_since_last_action_press = seconds_since_last_action_press + delta
	if (seconds_since_last_action_press > 0.15):
		last_beat_action_pressed = "none"

func set_velocity_if_on_floor_and_check_if_sprint(delta):
	if Input.is_action_pressed("dash"):
		SPEED = sprint
	else:
		SPEED = walk 
		
	if is_on_floor():
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 3.0)
	
func _physics_process(delta):
	fall_if_mid_air(delta)
	jump_if_pressed()
	set_wasd_movement_direction()
	update_beat_timer_and_check_if_frame_is_on_beat(delta)
	check_last_beat_action_press(delta) #checks which beat action (only shoot, reload) was pressed last and how long ago
	#beat actions are the ones that only trigger on beat
	
	if (current_frame_is_on_beat):
		shoot_gun_if_last_action_press_is_shoot()
		reload_if_last_action_press_is_reload()
		current_frame_is_on_beat = false
	
	
	pause_if_last_action_press_is_pause()
	set_velocity_if_on_floor_and_check_if_sprint(delta)
	
	move_and_slide()
	
	_delta += delta
	var input := Vector2.ZERO
	var camera_bob = floor(abs(input.x) + abs(input.y)) * _delta * 15
	var target_camera_translation := _original_camera_translation + Vector3.UP * sin(camera_bob) * 0.5
	camera.transform.origin = camera.transform.origin.lerp(target_camera_translation, delta)
