extends Node3D

signal drill
signal pull

func drill_attack():
	emit_signal("drill")
	print("a")

func pull_attack():
	emit_signal("pull")
	print("a")
