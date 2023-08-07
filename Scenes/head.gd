extends CollisionShape3D


func _input(event):
	if event is InputEventMouseMotion:
		var xRot = clamp(rotation.x - event.relative.y /1000 * 5, -1.4, 1.2)
		rotation = Vector3(xRot, 0, 0)
