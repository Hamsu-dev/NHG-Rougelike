class_name Enemy
extends CharacterBody2D


@export var max_speed = 40.0
@export var acceleration = 50.0

@onready var ray_cast_2d = $RayCast2D
@onready var fsm = $FiniteStateMachine as FiniteStateMachine
@onready var enemy_wander_state = $FiniteStateMachine/EnemyWanderState as EnemyWanderState
@onready var enemy_ambush_state = $FiniteStateMachine/EnemyAmbushState as EnemyAmbushState
@onready var enemy_flame_thrower_state = $FiniteStateMachine/EnemyFlameThrowerState as EnemyFlameThrowerState
@onready var enemy_chase_state = $FiniteStateMachine/EnemyChaseState as EnemyChaseState
@onready var player = get_tree().get_nodes_in_group("Player")[0]
@onready var animation_director = $AnimationDirector as AnimationDirector

func _ready():
	enemy_flame_thrower_state.out_of_range.connect(fsm.change_state.bind(enemy_wander_state))
	enemy_wander_state.found_player.connect(fsm.change_state.bind(enemy_flame_thrower_state))


func _physics_process(delta):
	var direction_to_player = (player.global_position - global_position).normalized()


	# Ambush range
	ray_cast_2d.target_position = direction_to_player * 50
	ray_cast_2d.force_raycast_update()
	if ray_cast_2d.is_colliding() and ray_cast_2d.get_collider() == player:
		fsm.change_state(enemy_ambush_state)
		return # exit to prevent further checks

	# Shooting range
	ray_cast_2d.target_position = direction_to_player * 100
	ray_cast_2d.force_raycast_update()
	if ray_cast_2d.is_colliding() and ray_cast_2d.get_collider() == player:
		fsm.change_state(enemy_flame_thrower_state)
		return # exit to prevent further checks

	# Chasing range
	ray_cast_2d.target_position = direction_to_player * 200
	ray_cast_2d.force_raycast_update()
	if ray_cast_2d.is_colliding() and ray_cast_2d.get_collider() == player:
		fsm.change_state(enemy_chase_state)
		return

	# Wandering range
	ray_cast_2d.target_position = direction_to_player * 250
	ray_cast_2d.force_raycast_update()
	if ray_cast_2d.is_colliding():
		if ray_cast_2d.get_collider() == player:
			fsm.change_state(enemy_wander_state)
		else:
			# Something is obstructing the view of the player
			fsm.change_state(enemy_wander_state)


