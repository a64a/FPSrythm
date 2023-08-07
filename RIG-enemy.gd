extends Node3D

@onready var state_machine = $AnimationPlayer/AnimationTree.get("parameters/playback")
var health = 5

func _ready():
	state_machine.travel("appear-paint")
