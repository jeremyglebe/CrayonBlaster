extends Area2D
class_name MeteorNode

enum MeteorSpinDirection {
	NONE = 0,
	COUNTERCLOCKWISE = -1,
	CLOCKWISE = 1,
	RANDOM = 2,
}

signal destroyed(meteor)

@export var randomize_image := true
const IMAGE_INDEX_MIN := 1
const IMAGE_INDEX_MAX := 3

@export_group("Speed")
@export var speed := 100.0
@export var randomize_speed := true
@export var min_random_speed := 50.0
@export var max_random_speed := 150.0

@export_group("Direction")
@export var rad_direction := PI / 2
@export var randomize_direction := true
@export var rad_min_random_direction := PI / 4
@export var rad_max_random_direction := 3 * PI / 4
var vec_direction: Vector2:
	get:
		return Vector2(
			cos(rad_direction),
			sin(rad_direction)
		)

@export_group("Spin")
@export var enum_spin_direction := MeteorSpinDirection.RANDOM
@export var spin := 0.0
@export var randomize_spin := true
@export var min_random_spin := 0.5
@export var max_random_spin := 2.0


# Called when the node enters the scene tree for the first time.
func _ready():
	if randomize_image:
		$Sprite2D.texture = load("res://images/Meteors/Crayon_Meteor" + str(randi_range(IMAGE_INDEX_MIN, IMAGE_INDEX_MAX)) + ".png")
	if randomize_direction:
		rad_direction = randf_range(rad_min_random_direction, rad_max_random_direction)


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
	# Check if meteor is out of bounds, and delete if so
	check_delete()


func _on_body_entered(body: PhysicsBody2D):
	destroyed.emit(self)
	if body.name == "Player":
		(body as PlayerNode).on_damage(1)
	else:
		body.queue_free()
	queue_free()


func _on_area_entered(area):
	destroyed.emit(self)
	if area.is_in_group("solid_projectiles"):
		area.queue_free()
	queue_free()


func check_delete():
	# var sprite_height: float = $Sprite2D.get_rect().size.y * scale.y
	# var sprite_width: float = $Sprite2D.get_rect().size.x * scale.x
	# if position.y > get_viewport_rect().size.y + sprite_height:
	# 	queue_free()
	# 	return
	# if position.x < 0 - sprite_height:
	# 	queue_free()
	# 	return
	# if position.x > get_viewport_rect().size.x + sprite_height:
	# 	queue_free()
	# 	return
	# New method: Delete if the meteor is ever more than 400 pixels out of bounds
	if position.x < -400 or position.x > get_viewport_rect().size.x + 400 or position.y < -400 or position.y > get_viewport_rect().size.y + 400:
		queue_free()
		return


func do_move(delta: float):
	position += vec_direction * speed * delta


func do_spin(delta: float):
	if enum_spin_direction == MeteorSpinDirection.RANDOM:
		set_random_spin_direction()
	rotate(spin * delta * enum_spin_direction)


func set_random_position(min_x: float, max_x: float, min_y: float, max_y: float):
	# Bounds are adjusted by the size of the meteor
	var w: float = $Sprite2D.get_rect().size.x * scale.x
	var h: float = $Sprite2D.get_rect().size.y * scale.y
	# Random position selected within the bounds
	position.x = randf_range(min_x + w, max_x - w)
	position.y = randf_range(min_y + h, max_y - h)


func set_random_spin_direction():
	enum_spin_direction = MeteorSpinDirection.CLOCKWISE if randi() % 2 == 0 else MeteorSpinDirection.COUNTERCLOCKWISE
