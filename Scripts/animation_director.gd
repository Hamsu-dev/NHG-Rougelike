@icon("./animation_director.svg")

## Handles directed animations from an [code]AnimationPlayer[/code].
##
## Animations within the [code]AnimationPlayer[/code] will be matched against a list of suffixes
## to determine the desired direction: _down, _down_left, _left, _up_left, _up, _up_right, _right,
## and _down_right (eg. "walk_down" would result of a "down" direction being added to the "walk"
## key). Any or none of the suffixes can be used. For animations without suffixes, no
## directional information will be assumed and the animation will run as if it isn't meant to have
## a specific direction. Use [code]play("walk")[/code] (for example) and (assuming a current direction
## of "down") "walk_down" will play in the [code]AnimationPlayer[/code].
## [br][br]
## The [code]rotation[/code] property of the [code]AnimationDirector[/code] will also be set to
## match the current direction, with 0 being rotated to the right by default.
class_name AnimationDirector extends Node2D


signal direction_changed(direction: Vector2)

## The animation player to draw animations from.
@export var animation_player: AnimationPlayer
## The default animation to play.
@export var default_animation: String = "idle"
## The currently facing direction.
@export var direction: Vector2 = Vector2.RIGHT:

	set(value):
		value = value.normalized()
		# Update the animation direction and match progress.
		var next_animation: String = _get_raw_animation_name(self.current_animation, value)
		if next_animation != animation_player.assigned_animation:
			var animation_position: float = self.current_animation_position
			animation_player.play(next_animation)
			seek(animation_position)

		if direction != value:
			rotation = 0 if value == Vector2.RIGHT else PI
			direction = value
			direction_changed.emit(direction)
	get:
		return direction

## Adjust the play speed of animations.
var speed_scale:
	set(value):
		animation_player.speed_scale = value
	get:
		return animation_player.speed_scale

## The available animation. In the form of:
## [code]{ <base animation name>: { <Vector2 for direction>: <raw animation name> }}[/code].
## You probably won't need to use this directly.
var animations: Dictionary = {}

## The currently playing animation.
var current_animation: String:
	get:
		return _extract_raw_animation_details(animation_player.assigned_animation).base_animation_name

## The current animation position.
var current_animation_position: float:
	get:
		return animation_player.current_animation_position if animation_player.current_animation != "" else 0.0

# All available directions. Derived on ready and used to calculate directions from animations
var _all_directions: Dictionary = {}


func _ready() -> void:
	_all_directions = {
		left = Vector2.LEFT,
		right = Vector2.RIGHT
	}

	# Build a map of possible animation names and raw names for directions
	for raw_animation_name in animation_player.get_animation_list():
		# Turn something like "walk_down_left" into just "walk"
		var details: Dictionary = _extract_raw_animation_details(raw_animation_name)
		if not animations.has(details.base_animation_name):
			animations[details.base_animation_name] = {}

		# If the animation has a directional suffix then convert that string
		# into a Vector that we can compare it against.
		if details.suffix:
			var direction_for_suffix: Vector2 = _all_directions[details.suffix]
			animations[details.base_animation_name][direction_for_suffix] = raw_animation_name
		# Otherwise, it has no direction to just use zero
		else:
			animations[details.base_animation_name][Vector2.ZERO] = raw_animation_name

	play(default_animation)


### Helpers


## Check if an animation is available.
func has_animation(animation_name: String) -> bool:
	return animations.has(animation_name)


## See if a given animation is playing.
func is_playing_animation(animation_name: String) -> bool:
	return self.current_animation == animation_name


## Play an animation.
func play(animation_name: String, restart_if_same_animation: bool = false) -> void:
	var next_animation: String = _get_raw_animation_name(animation_name, direction)

	if self.current_animation == next_animation and not restart_if_same_animation: return

	if animation_player.has_animation(next_animation):
		animation_player.play(next_animation)


## Jump to a percentage of the total duration.
func seek(animation_position: float) -> void:
	animation_player.seek(animation_position)


## Look in the direction of a position.
func look_in_direction_of(next_position: Vector2) -> void:
	self.direction = owner.global_position.direction_to(next_position)


## Look in the direction of another node.
func look_in_direction_of_node(node: Node2D) -> void:
	if not is_instance_valid(node): return

	look_in_direction_of(node.global_position)


### Setup


# Get a playable animation name for a direction. Not to be called directly.
func _get_raw_animation_name(animation_name: String, direction: Vector2) -> String:
	var closest_direction: Vector2 = Vector2.ZERO
	var closest_distance: float = INF
	for available_direction in animations.get(animation_name, {}):
		var distance: float = direction.normalized().distance_squared_to(available_direction)
		if distance < closest_distance:
			closest_distance = distance
			closest_direction = available_direction

	return animations.get(animation_name, {}).get(closest_direction, animation_name)


# Split a raw animation name (one from an AnimationPlayer) into a base name and it's directional
# suffix. Not to be called directly.
func _extract_raw_animation_details(raw_animation_name: String) -> Dictionary:
	# See if it matches any known animations
	for available_direction in _all_directions.keys():
		if raw_animation_name.ends_with(available_direction):
			return {
				base_animation_name = raw_animation_name.replace("_" + available_direction, ""),
				suffix = available_direction
			}

	# It's probably a one shot so it has no directions
	return {
		base_animation_name = raw_animation_name,
		suffix = ""
	}
