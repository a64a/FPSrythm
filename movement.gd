extends CharacterBody3D

@onready var camera_mount = $finger
@onready var state_machine = $finger/AnimationPlayer/AnimationTree.get("parameters/playback")
@export var muzzle_velocity = 25
@export var g = Vector3.DOWN * 20
@onready var BulletScene = load("res://Bullet.tscn")

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var sens = 0.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var Bullet

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		var xRot = clamp(rotation.x - event.relative.y /1000 * 5, -0.85, 1)
		var yRot = rotation.y - event.relative.x / 1000 * 5
		rotation = Vector3(xRot, yRot, 0)


func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if Input.is_action_just_pressed("shoot"):
		state_machine.travel("shoot")
		var bullet = BulletScene.instantiate()
		get_node("finger").add_child(bullet)
		bullet.position = get_node("finger/RIG-finger/Skeleton3D/finger2/muzzle").position
		await get_tree().create_timer(1).timeout
	else:
		state_machine.travel("idle")
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
			
	
	move_and_slide()
