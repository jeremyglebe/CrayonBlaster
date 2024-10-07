extends CharacterBody2D
class_name PlayerNode

var sound_explode := load("res://audio/fx/long_explode.mp3")
var sound_shot := load("res://audio/fx/shot.mp3")

signal game_over(player)
signal primary_weapon(weapon_position: Vector2, vec_weapon_direction: Vector2)

# Direction as radians, right is 0, increases clockwise
@export var rad_facing_direction := 3 * PI / 2
# Speed of controls for the ship
@export var forward_speed := 200.0 # pixels
@export var reverse_speed := 100.0 # pixels
@export var turn_speed := PI # radians
@export var strafe_speed := 75.0 # pixels

var primary_weapon_ready := true

var vec_facing_direction: Vector2:
	get:
		return Vector2(
			cos(rad_facing_direction),
			sin(rad_facing_direction)
		)

var vec_righthand_direction: Vector2:
	get:
		var rad_righthand_direction := rad_facing_direction + PI / 2
		return Vector2(
			cos(rad_righthand_direction),
			sin(rad_righthand_direction)
		)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Ship image matches the facing direction
	rotation = rad_facing_direction
	# Sets the direction and velocity from active controls
	control_step(delta)
	# Move the ship (w physics!)
	move_and_slide()


func _on_primary_refresh_timer_timeout():
	primary_weapon_ready = true


func _on_tree_exiting():
	game_over.emit(self)


func control_step(delta: float):
	# Reset velocity
	velocity = Vector2()
	# Forward
	if Input.is_action_pressed("forward"):
		velocity += vec_facing_direction * forward_speed * Input.get_action_strength("forward")
	# Reverse
	if Input.is_action_pressed("reverse"):
		velocity -= vec_facing_direction * reverse_speed * Input.get_action_strength("reverse")
	# Turning
	if Input.is_action_pressed("turn left"):
		rad_facing_direction -= turn_speed * delta * Input.get_action_strength("turn left")
	if Input.is_action_pressed("turn right"):
		rad_facing_direction += turn_speed * delta * Input.get_action_strength("turn right")
	# Strafing
	if Input.is_action_pressed("strafe left"):
		velocity -= vec_righthand_direction * strafe_speed * Input.get_action_strength("strafe left")
	if Input.is_action_pressed("strafe right"):
		velocity += vec_righthand_direction * strafe_speed * Input.get_action_strength("strafe right")
	# Shooting
	if Input.is_action_just_pressed("primary weapon"):
		emit_primary_weapon()


func emit_primary_weapon():
	if primary_weapon_ready:
		var vec_weapon_direction = vec_facing_direction
		primary_weapon.emit($WeaponStartMarker.global_position, vec_weapon_direction)
		play_sound(sound_shot)
		primary_weapon_ready = false
		$PrimaryRefreshTimer.start()


func play_sound(sound):
	if !$AudioStreamPlayer.playing:
		$AudioStreamPlayer.stream = sound
		$AudioStreamPlayer.play()
