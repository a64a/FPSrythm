extends Control
@onready var fill = get_node("../Player/head/finger/Camera_new/crosshair/hurtbox")

func _ready():
	fill += SIZE_EXPAND_FILL
