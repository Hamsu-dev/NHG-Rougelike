class_name Enemy
extends CharacterBody2D


@export var max_speed = 40.0
@export var acceleration = 50.0

@onready var ray_cast_2d = $RayCast2D
@onready var fsm = $FiniteStateMachine as FiniteStateMachine
@onready var enemy_wander_state = $FiniteStateMachine/EnemyWanderState as EnemyWanderState
@onready var enemy_ambush_state = $FiniteStateMachine/EnemyAmbushState as EnemyAmbushState
@onready var enemy_shoot_state = $FiniteStateMachine/EnemyShootState as EnemyShootState
@onready var enemy_chase_state = $FiniteStateMachine/EnemyChaseState as EnemyChaseState
@onready var player = get_tree().get_nodes_in_group("Player")[0]
@onready var animation_director = $AnimationDirector as AnimationDirector


func _ready():
	enemy_shoot_state.out_of_range.connect(fsm.change_state.bind(enemy_wander_state))
	enemy_wander_state.found_player.connect(fsm.change_state.bind(enemy_shoot_state))

func _physics_process(delta):
	var direction_to_player = (player.global_position - global_position).normalized()
	ray_cast_2d.target_position = direction_to_player * 250 # Set this to your maximum detection range
	ray_cast_2d.force_raycast_update() # Make sure raycast updates in the physics step

	if ray_cast_2d.is_colliding():
		var colliding_with = ray_cast_2d.get_collider()
		var distance_to_player = global_position.distance_to(player.global_position)
		
		if colliding_with == player:
			if distance_to_player <= 50:
				fsm.change_state(enemy_ambush_state)
			elif distance_to_player <= 150 && distance_to_player > 50:
				fsm.change_state(enemy_shoot_state)
			elif distance_to_player <= 250 && distance_to_player > 150:
				# Player is within chasing range but outside of shooting range
				fsm.change_state(enemy_chase_state)
		else:
			# Something is obstructing the view of the player
			fsm.change_state(enemy_wander_state)
