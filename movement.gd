extends CharacterBody3D

@onready var camera_mount = $finger
@onready var state_machine = $finger/AnimationPlayer/AnimationTree.get("parameters/playback")
@export var muzzle_velocity = 25
@export var g = Vector3.DOWN * 20
@onready var raycast = get_node("finger/RIG-finger/RayCast3D")
@onready var hole = preload("res://bullethole.tscn")

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var a
var _mass := .0
var _speed : Vector3

@export var sens = 0.5
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

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
	if Input.is_action_just_pressed("shoot"):
		raycast.add_exception(get_node("."))
		state_machine.travel("shoot")
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			var force := _mass * _speed.length()
			collider.emit_signal("apply_force", -self.transform.basis.z, force)
			print(collider)
			var b = hole.instantiate()
			get_tree().get_root().add_child(b)
			b.global_transform.origin = raycast.get_collision_point()
			var surface_dir_up = Vector3(0,1,0)
			var surface_dir_down = Vector3(0,-1,0)
			if raycast.get_collision_normal() == surface_dir_up:
				b.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.RIGHT)
			elif raycast.get_collision_normal() == surface_dir_down:
				b.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.RIGHT)
			else:
				b.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.DOWN)
	else:
		state_machine.travel("idle")
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	move_and_slide()
