class_name EnemyAmbushState
extends State

@export var actor: Enemy
@export var animator: AnimatedSprite2D
@export var vision_cast: RayCast2D

signal woke_up


func _ready():
	set_physics_process(false)


func _enter_state() -> void:
	set_physics_process(true)
	animator.play("idle")


func _exit_state() -> void:
	set_physics_process(false)


func _physics_process(delta):
	if vision_cast.is_colliding():
		var colliding_body = vision_cast.get_collider()
		if colliding_body and colliding_body.is_in_group("Player"):
			# Determine direction
			var direction_to_player = (actor.player.global_position - actor.global_position).normalized()
			actor.animation_director.direction = Vector2.LEFT if direction_to_player.x < 0 else Vector2.RIGHT
			actor.animation_director.play("wake") # "wake" should transition to the correct left or right based on AnimationDirector
			woke_up.emit()
