extends Node

var current_gun: Node2D

func _ready():
	current_gun = get_child(0)  # Assuming the first child is the gun. Adjust as necessary.
