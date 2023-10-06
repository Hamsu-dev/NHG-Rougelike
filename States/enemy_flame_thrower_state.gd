class_name EnemyShootState
extends State

@export var actor: Enemy
@export var animator: AnimatedSprite2D
@export var vision_cast: RayCast2D
@export var bullet_speed = 100.0 

@onready var bullet_scene = preload("res://Scenes/bullet.tscn")
@onready var shoot_timer = $ShootTimer

signal attack_finished
signal out_of_range

var is_attacking = false
var bullets_in_burst = 3
var bullets_fired = 0
var bullet_queue: Array = []
var MAX_BULLETS = 50 # Maximum number of bullets you want to store in the queue. Adjust as needed.

func _ready() -> void:
	set_physics_process(false)
	shoot_timer.timeout.connect(_on_shoot_timer_timeout)
	# Pre-instantiate some bullets and add them to the queue
	for i in range(MAX_BULLETS):
		var bullet = bullet_scene.instantiate()
		bullet.bullet_used.connect(_on_bullet_used)
		bullet.visible = false # Hide them initially
#		get_tree().current_scene.add_child(bullet)
		call_deferred("add_bullet_to_scene", bullet)
		bullet_queue.append(bullet)


func add_bullet_to_scene(bullet):
	get_tree().current_scene.add_child(bullet)
	bullet_queue.append(bullet)


func _enter_state() -> void:
	set_physics_process(true)
	is_attacking = true
	shoot_timer.start() # Call shoot once when entering the state

func _exit_state() -> void:
	set_physics_process(false)
	is_attacking = false
	shoot_timer.stop() 


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

func shoot(direction: Vector2 = Vector2()):
	var spread_angle = deg_to_rad(randf_range(-10, 10))
	var spread_direction = direction.rotated(spread_angle)

	var bullet
	if bullet_queue.size() > 0:
		bullet = bullet_queue.pop_front() # Get a bullet from the queue
	else:
		# If no bullets are available in the queue, instantiate a new one
		bullet = bullet_scene.instantiate()
		bullet.bullet_used.connect(_on_bullet_used)
		get_tree().current_scene.add_child(bullet)

	bullet.visible = true
	bullet.direction = spread_direction
	bullet.speed = bullet_speed
	bullet.global_position = actor.global_position + actor.animation_director.direction * 16 + Vector2(0, -6)
	actor.animation_director.play("shoot")


func _on_bullet_used(bullet):
	# When a bullet is used up, just hide it and add it back to the queue for reuse
	if bullet and bullet.is_inside_tree():
		bullet.visible = false
		bullet_queue.append(bullet)


func _on_shoot_timer_timeout():
	shoot_timer.start()
	shoot()
