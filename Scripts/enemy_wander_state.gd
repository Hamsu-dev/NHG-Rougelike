class_name EnemyWanderState
extends State

@export var actor: Enemy
@export var animator: AnimatedSprite2D
@export var vision_cast: RayCast2D

signal found_player

func _ready():
	set_physics_process(false)

func _enter_state() -> void:
	set_physics_process(true)
	animator.play("move")
	if actor.velocity == Vector2.ZERO:
		actor.velocity = Vector2.RIGHT.rotated(randf_range(0, TAU)) * actor.max_speed

func _exit_state() -> void:
	set_physics_process(false)

func _physics_process(delta):
	
	actor.velocity = actor.velocity.move_toward(actor.velocity.normalized() * actor.max_speed, actor.acceleration * delta)
	var collision = actor.move_and_collide(actor.velocity * delta)
	if collision:
		var bounce_velocity = actor.velocity.bounce(collision.get_normal())
		actor.velocity = bounce_velocity
	
	actor.animation_director.direction = Vector2.LEFT if actor.velocity.x < 0 else Vector2.RIGHT
	actor.animation_director.play("walk")
	
	if vision_cast.is_colliding():
		var colliding_body = vision_cast.get_collider()
		if colliding_body and colliding_body.is_in_group("Player"):
			found_player.emit()
