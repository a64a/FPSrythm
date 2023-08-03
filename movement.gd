extends CharacterBody3D

@onready var camera_mount = $finger
@onready var state_machine = $finger/AnimationPlayer/AnimationTree.get("parameters/playback")
@export var g = Vector3.DOWN * 20
@onready var ray1 = get_node("finger/RIG-finger/RayCast3D") 
@onready var ray2 = get_node("finger/RIG-finger/RayCast3D2")
@onready var hole = preload("res://bullethole.tscn")
@onready var crosshair = get_node("finger/Camera3D/crosshair/CenterContainer/Sprite2D")
@onready var weapon = get_node("finger/Camera3D/crosshair/CenterContainer/Weapon")
@onready var camera = get_node("finger/Camera3D")

var SPEED
var walk = 5.0
var sprint = 7.0
var JUMP_VELOCITY = 4.5
var shoot = true
var s = Vector2()
var ammo = 2
const freq = 2.0
const amp = 0.08
var t_bob = 0.0

@export var sens = 0.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func cooldowns():
	if shoot == false:
		s.x = 0.1
		s.y = 0.1
		crosshair.texture = load("res://assets/Barrier.png")
		crosshair.scale = s
		await get_tree().create_timer(1).timeout
		shoot = true
		crosshair.texture = load("res://.godot/imported/1022053-200.png-b3a218dc2025a6a90356d54d9a8a372d.s3tc.ctex")
		s.x = 0.25
		s.y = 0.25
		crosshair.scale = s
		weapon.texture = load("res://assets/unnamed.png")
	else:
		shoot = false


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
	if ray1.is_colliding():
		ray_check(ray1)
	if ray2.is_colliding():
		ray_check(ray2)
	weapon.texture = load(a)
	await get_tree().create_timer(0.35).timeout
	weapon.texture = load(b)
	shoot = false

func _input(event):
	if event is InputEventMouseMotion:
		var xRot = clamp(rotation.x - event.relative.y /1000 * 5, -1.5, 1)
		var yRot = rotation.y - event.relative.x / 1000 * 5
		rotation = Vector3(xRot, yRot, 0)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if Input.is_action_just_pressed("shoot") and shoot==true:
		state_machine.travel("shoot")
		if ray1.is_colliding() or ray2.is_colliding():
			collision_check("res://assets/IMG-0301.PNG", "res://assets/IMG-0300.PNG")
	elif Input.is_action_just_pressed("punch"):
		state_machine.travel("punch_left")
	elif Input.is_action_just_pressed("reload") and shoot==false:
		cooldowns()
	else:
		state_machine.travel("idle")
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
		
		t_bob += delta * velocity.length() * float(is_on_floor())
		camera.transform.origin * _headbob(t_bob)
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * freq) * amp
	pos.x = cos(time + freq / 2.0) * amp
	return pos

