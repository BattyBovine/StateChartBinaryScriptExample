# ----------------------------------------------------------------------------------- #
# -------------- FEEL FREE TO USE IN ANY PROJECT, COMMERCIAL OR NON-COMMERCIAL ------ #
# ---------------------- 3D PLATFORMER CONTROLLER BY SD STUDIOS --------------------- #
# ---------------------------- ATTRIBUTION NOT REQUIRED ----------------------------- #
# ----------------------------------------------------------------------------------- #

class_name PlayerCharacter
extends CharacterBody3D

# ---------- VARIABLES ---------- #

@export_category("Animation")
@export var player_rotation_speed : float = 36.0

var max_movement_speed : float = 7.5

# Onready Variables
@onready var model : Node3D = $Gobot
@onready var skeleton : Skeleton3D = $Gobot/Skeleton3D
@onready var animation_tree : AnimationTree = $Gobot/AnimationTree
@onready var state_chart : StateChart = $StateChart


# ---------- FUNCTIONS ---------- #

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta:float):
	_player_animations(_delta)


func _walking_physics_process(_delta:float) -> void:
	velocity.y -= 0.1
	
	move_and_slide()
	_movement_speed_change("walk", Vector2(velocity.x, velocity.z).length())
	if not is_on_floor():
		state_chart.send_event("fall")

func _falling_physics_process(_delta:float) -> void:
	velocity.y -= 9.8 * _delta
	
	move_and_slide()
	if is_on_floor():
		state_chart.send_event("walk")


func _input(_event:InputEvent):
	var lateral_movement : Vector2 = Input.get_vector("move_right", "move_left", "move_back", "move_forward")
	lateral_movement *= max_movement_speed
	velocity.x = lateral_movement.x
	velocity.z = lateral_movement.y
	
	if _event.is_action_pressed("jump"):
		state_chart.send_event("jump")
	
	if _event.is_action_pressed("pause"):
		get_tree().quit()


func _is_moving():
	return (abs(velocity.z) + abs(velocity.x)) > 0.0


func _on_grounded_state_entered() -> void:
	pass

func _on_jumping_state_entered() -> void:
	velocity.y = 5.0

# Handle player Animations
func _player_animations(_delta:float):
	# Player rotation
	if _is_moving():
		var pif : float = Engine.get_physics_interpolation_fraction()
		model.global_rotation.y = lerp_angle(model.global_rotation.y, Vector2(velocity.z, velocity.x).angle(), player_rotation_speed * _delta * pif)


func _on_state_changed(state:StringName):
	animation_tree["parameters/playback"].travel(state)
	
	match state:
		"jump":
			var tween = get_tree().create_tween()
			tween.tween_property(model, "scale", Vector3(1,1,1), 0.2)

func _movement_speed_change(state, speed):
	animation_tree["parameters/" + state + "/blend_position"] = speed


# Input handlers
func _on_ui_pause_pressed():
	get_tree().quit()

func _on___DEBUG_unlock_mouse_pressed():
	if(Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
