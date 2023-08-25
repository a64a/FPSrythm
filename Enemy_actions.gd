extends CharacterBody3D

@onready var eyes = $Eyes
@onready var sight = get_node("aggro range")
@onready var ray = get_node("MovementCheck")
var path = []
var path_node = 0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

enum {
    alert,
    idle,
}
var check
var target 
var state
var counter = 0
const turn_speed = 15
const speed = 5

func _on_aggro_range_body_entered(body):
    if body.is_in_group("Player"):
        state = alert
        target = body


func _on_aggro_range_body_exited(body):
    if body.is_in_group("Player"):
        state = idle

func _process(delta):
    match state:
        alert:
            eyes.look_at(target.global_transform.origin, Vector3.UP)
            rotate_y(deg_to_rad(eyes.rotation.y * turn_speed))
            var collider = ray.get_collider()
            var truth_check = is_instance_valid(collider)
            if truth_check == true and is_on_floor() and collider.is_in_group("Player"): # Slowing and speeding up
                var origin = ray.global_transform.origin
                var collision_point = ray.get_collision_point()
                var distance = origin.distance_to(collision_point)
                var direction2 = (transform.basis * Vector3(0, 0, eyes.rotation.y)).normalized()
                print(distance)
                if distance > 1 and direction2:
                    velocity.x = lerp(velocity.x, -direction2.x * speed, delta * 5.0)
                    velocity.z = lerp(velocity.z, -direction2.z * speed, delta * 5.0)
                else:
                    velocity.x = 0
                    velocity.z = 0
        idle:
            pass

func _physics_process(delta):
    if Input.is_action_pressed("slow_time"): # If left single quote is held, slow time
        delta = (delta/2)
    else:
        delta = delta
    if not is_on_floor(): #If is in the air, apply gravity
        velocity.y -= gravity * delta
    move_and_slide() # Initiate movement and velocity
