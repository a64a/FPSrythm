extends Marker3D



func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion:
		var xRot = clamp(rotation.x - event.relative.y /1000 * 5, -0.85, 1)
		var yRot = rotation.y - event.relative.x / 1000 * 5
		rotation = Vector3(xRot, yRot, 0)
