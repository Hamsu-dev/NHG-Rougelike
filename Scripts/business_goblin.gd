class_name Enemy
extends CharacterBody2D

@export var max_speed = 40.0
@export var acceleration = 50.0

@onready var ray_cast_2d = $RayCast2D
@onready var fsm = $FiniteStateMachine as FiniteStateMachine
@onready var enemy_wander_state = $FiniteStateMachine/EnemyWanderState as EnemyWanderState
@onready var enemy_chase_state = $FiniteStateMachine/EnemyChaseState as EnemyChaseState
@onready var enemy_ambush_state = $FiniteStateMachine/EnemyAmbushState as EnemyAmbushState
@onready var player = get_tree().get_nodes_in_group("Player")[0]
@onready var animation_director = $AnimationDirector as AnimationDirector


func _ready():
	enemy_ambush_state.woke_up.connect(fsm.change_state.bind(enemy_chase_state))
	enemy_chase_state.lost_player.connect(fsm.change_state.bind(enemy_wander_state))
	enemy_wander_state.found_player.connect(fsm.change_state.bind(enemy_chase_state))


func _physics_process(delta):
	var direction_to_player = (player.global_position - global_position).normalized()
	ray_cast_2d.target_position = direction_to_player * 50
