extends CharacterBody2D

signal bullet_used

var speed = 100
var direction = Vector2.RIGHT
var lifetime = 2.0 # Bullet's lifetime in seconds
var timer = Timer.new()


func _ready():
	# Setup the timer for bullet's lifetime
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	timer.start()


func _physics_process(delta):
	var collision_info = move_and_collide(direction * speed * delta)
	if collision_info:
		bullet_expired()

func bullet_expired():
	bullet_used.emit(self)
	visible = false


func _on_timer_timeout():
	bullet_expired()
