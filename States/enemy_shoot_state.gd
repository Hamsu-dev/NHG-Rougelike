class_name EnemyShootState
extends State

@export var actor: Enemy
@export var animator: AnimatedSprite2D
@export var vision_cast: RayCast2D

signal attack_finished
signal out_of_range

var is_attacking = false

func _ready() -> void:
	set_physics_process(false)

func _enter_state() -> void:
	set_physics_process(true)
	is_attacking = true
	shoot() # Call shoot once when entering the state

func _exit_state() -> void:
	set_physics_process(false)
	is_attacking = false

func _physics_process(delta) -> void:
	var direction_to_player = (actor.player.global_position - actor.global_position).normalized()
	# Update the enemy's visual direction based on the player's position
	actor.animation_director.look_in_direction_of(actor.player.global_position)
	var distance_to_player = actor.global_position.distance_to(actor.player.global_position)
	
	# If the player is in sight
	if vision_cast.is_colliding() and vision_cast.get_collider().is_in_group("Player"):
		shoot(direction_to_player)
	else:
		out_of_range.emit()

func shoot(direction: Vector2 = Vector2()) -> void:
	# Your shooting logic here, e.g., instantiate a bullet and set its direction
	actor.animation_director.play("shoot")
