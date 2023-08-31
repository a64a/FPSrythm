extends RayCast3D

@onready var player = get_node("../../Player")

func _physics_process(delta):
	var collision_point = get_collision_point()
	var origin = self.global_transform.origin
	var distance = origin.distance_to(collision_point)
	if distance <= 1:
		print("a")
		player.global_position.y += 10
		if player.global_position.y > 9:
			print("b")
