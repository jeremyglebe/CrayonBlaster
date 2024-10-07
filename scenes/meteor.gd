extends Area2D
class_name MeteorNode

enum MeteorSpinDirection {
	CLOCKWISE,
	COUNTERCLOCKWISE,
	RANDOM,
	NONE,
}

@export var randomize_image := true
const IMAGE_INDEX_MIN := 1
const IMAGE_INDEX_MAX := 2

@export_group("Speed")
@export var speed := 100.0
@export var randomize_speed := true
@export var min_random_speed := 50.0
@export var max_random_speed := 150.0

@export_group("Spin")
@export var spin_direction := MeteorSpinDirection.RANDOM
@export var spin := 0.0
@export var randomize_spin := true
@export var min_random_spin := 0.5
@export var max_random_spin := 2.0

# Called when the node enters the scene tree for the first time.
func _ready():
	if randomize_image:
		$Sprite2D.texture = load("res://images/Cutout_Meteor" + str(randi_range(IMAGE_INDEX_MIN, IMAGE_INDEX_MAX)) + ".png")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	# Move
	if randomize_speed:
		speed = randf_range(min_random_speed, max_random_speed)
		randomize_speed = false
	do_move(delta)
	# Spin
	if randomize_spin:
		spin = randf_range(min_random_spin, max_random_spin)
		randomize_spin = false
	do_spin(delta)


func _on_body_entered(body):
	print("Meteor collided with", body)


func do_move(delta: float):
	position.y += speed * delta

func do_spin(delta: float):
	match spin_direction:
		MeteorSpinDirection.CLOCKWISE:
			rotate(spin * delta)
		MeteorSpinDirection.COUNTERCLOCKWISE:
			rotate(-spin * delta)
		MeteorSpinDirection.RANDOM:
			set_random_spin_direction()
			rotate(spin * delta)
		MeteorSpinDirection.NONE:
			pass

func set_random_position(min_x: float, max_x: float, min_y: float, max_y: float):
	# Bounds are adjusted by the size of the meteor
	var w: float = $Sprite2D.get_rect().size.x * scale.x
	var h: float = $Sprite2D.get_rect().size.y * scale.y
	# Random position selected within the bounds
	position.x = randf_range(min_x + w, max_x - w)
	position.y = randf_range(min_y + h, max_y - h)

func set_random_spin_direction():
	spin_direction = MeteorSpinDirection.CLOCKWISE if randi() % 2 == 0 else MeteorSpinDirection.COUNTERCLOCKWISE
