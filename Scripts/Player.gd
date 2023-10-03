extends CharacterBody2D

@onready var sprite_2d = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var animation_tree = $AnimationTree

@export var Speed: int = 50
@export var Friction: float = 0.15
@export var Acceleration: int = 40

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength('right') - Input.get_action_strength('left')
	input_vector.y = Input.get_action_strength('down') - Input.get_action_strength('up')
	input_vector = input_vector.normalized()
	velocity = input_vector * Speed
	
	
	if input_vector == Vector2.ZERO:
		animation_tree.get("parameters/playback").travel("Idle")
	else:
		animation_tree.get("parameters/playback").travel("Run")
		move_and_slide()
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Run/blend_position", input_vector)
	
