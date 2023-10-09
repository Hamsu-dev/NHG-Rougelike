extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var gun_manager = $GunManager

const MAX_SPEED = 100.0
const ACCELERATION = 1000.0
const FRICTION = 500.0
const GUN_RADIUS = 5.0

func _ready():
	self.z_index = 1

func _physics_process(delta: float) -> void:
	_handle_movement(delta)
	_handle_aiming()

func _handle_movement(delta):
	var input_direction = Vector2()
	if Input.is_action_pressed("left"):
		input_direction.x = -1
	elif Input.is_action_pressed("right"):
		input_direction.x = 1
	if Input.is_action_pressed("up"):
		input_direction.y = -1
	elif Input.is_action_pressed("down"):
		input_direction.y = 1

	input_direction = input_direction.normalized()
	var target_velocity = input_direction * MAX_SPEED

	if input_direction.length() > 0:
		velocity = velocity.move_toward(target_velocity, ACCELERATION * delta)
		animated_sprite_2d.play("Run")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		animated_sprite_2d.play("Idle")

	position += velocity * delta

func _handle_aiming():
	var dir_to_mouse = get_global_mouse_position() - global_position
	var gun_position_offset = dir_to_mouse.normalized() * GUN_RADIUS
	gun_manager.current_gun.global_position = global_position + gun_position_offset

	if dir_to_mouse.x < 0:
		gun_manager.current_gun.scale.y = -1  # Flip vertically when aiming left
		gun_manager.current_gun.rotation = dir_to_mouse.angle()
#		gun_manager.current_gun.z_index = -1  
	else:
		gun_manager.current_gun.scale.y = 1   # Reset to normal scale when aiming right
		gun_manager.current_gun.rotation = dir_to_mouse.angle()
#		gun_manager.current_gun.z_index = 1

	# Flipping the player sprite based on mouse direction.
	if dir_to_mouse.x > 0 and animated_sprite_2d.flip_h:
		animated_sprite_2d.flip_h = false
	elif dir_to_mouse.x < 0 and not animated_sprite_2d.flip_h:
		animated_sprite_2d.flip_h = true


