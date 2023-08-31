extends Node3D

signal pull
signal drill

func pull_attack():
	emit_signal("pull")
	print("a")

func drill_attack():
	emit_signal("drill")
	print("a")

func _physics_process(delta):
	drill_attack()
