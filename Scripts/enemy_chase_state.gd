class_name EnemyChaseState
extends State

@export var actor: Enemy
@export var animator: AnimatedSprite2D
@export var vision_cast: RayCast2D

signal lost_player

func _ready() -> void:
	set_physics_process(false)

func _enter_state() -> void:
	set_physics_process(true)
	animator.play("move")

func _exit_state() -> void:
	set_physics_process(false)

func _physics_process(delta) -> void:
	animator.scale.x = -sign(actor.velocity.x)
	if animator.scale.x == 0.0: animator.scale.x = 1.0
	var direction_to_player = (actor.player.global_position - actor.global_position).normalized()
	actor.velocity = actor.velocity.move_toward(direction_to_player * actor.max_speed, actor.acceleration * delta)
	actor.move_and_slide()
	if not vision_cast.is_colliding() or (vision_cast.is_colliding() and not vision_cast.get_collider().is_in_group("Player")):
		lost_player.emit()

