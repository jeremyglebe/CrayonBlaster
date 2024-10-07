extends CharacterBody2D

# Direction as radians, right is 0, increases clockwise
@export var facing_direction := 3 * PI / 2
# Speed of controls for the ship
@export var forward_speed := 200.0 # pixels
@export var reverse_speed := 100.0 # pixels
@export var turn_speed := PI # radians
@export var strafe_speed := 125.0 # pixels


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Ship image matches the facing direction
	rotation = facing_direction
	# Sets the direction and velocity from active controls
	control_step(delta)
	# Move the ship (w physics!)
	move_and_slide()


func control_step(delta: float):
	# Reset velocity
	velocity = Vector2()
	# Forward
	if Input.is_action_pressed("forward"):
		velocity += get_facing_vector() * forward_speed
	# Reverse
	if Input.is_action_pressed("reverse"):
		velocity -= get_facing_vector() * reverse_speed
	# Turning
	if Input.is_action_pressed("turn left"):
		facing_direction -= turn_speed * delta
	if Input.is_action_pressed("turn right"):
		facing_direction += turn_speed * delta
	# Strafing
	if Input.is_action_pressed("strafe left"):
		velocity -= get_right_vector() * strafe_speed
	if Input.is_action_pressed("strafe right"):
		velocity += get_right_vector() * strafe_speed


func get_facing_vector() -> Vector2:
	return Vector2(
		cos(facing_direction),
		sin(facing_direction)
	)

func get_right_vector() -> Vector2:
	var right_angle := facing_direction + PI / 2
	return Vector2(
		cos(right_angle),
		sin(right_angle)
	)
