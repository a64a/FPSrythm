extends Node3D

@onready var state_machine = $RigidBody3D/AnimationPlayer/AnimationTree.get("parameters/playback")
var health = 5

func _ready():
	self.visible = false
	await get_tree().create_timer(1.35).timeout
	self.visible = true
	state_machine.travel("appear-paint")

func _process(delta):
	pass
