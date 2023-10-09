extends Node2D

@onready var current_gun = $BaseGun
@onready var player: Node = get_parent()

const GUN_RADIUS: float = 10.0


func _process(delta):
	_position_and_orient_gun_to_mouse()


func _position_and_orient_gun_to_mouse():
	var mouse_position: Vector2 = get_global_mouse_position()
	var direction_to_mouse: Vector2 = (mouse_position - global_position).normalized()
	
	# Calculate the gun's position within the circular range
	var gun_position = global_position + direction_to_mouse * GUN_RADIUS
	current_gun.global_position = gun_position
	current_gun.look_at(mouse_position)
	
	# Adjust the sprite scaling based on the mouse position relative to the gun sprite
	if mouse_position.x < current_gun.global_position.x:
		current_gun.scale = Vector2(1, -1)
	elif mouse_position.x > current_gun.global_position.x:
		current_gun.scale = Vector2(1, 1)
