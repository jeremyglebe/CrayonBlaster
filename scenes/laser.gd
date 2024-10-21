class_name LaserNode
extends Area2D

const LASER_MAX_SIZE = 4096
const LASER_EXTEND_TIME = 1

@export var rad_facing_direction := 0.0
var vec_facing_direction: Vector2:
	get:
		return Vector2(
			cos(rad_facing_direction),
			sin(rad_facing_direction)
		)


# Called when the node enters the scene tree for the first time.
func _ready():
	rotation = rad_facing_direction
	create_tween().tween_property($Sprite2D, ':region_rect:size:x', LASER_MAX_SIZE, LASER_EXTEND_TIME)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	rotation = rad_facing_direction
	# Match the collision shape to the sprite
	$CollisionShape2D.shape.size.x = $Sprite2D.region_rect.size.x
	# The position of the collision shape is its center, so we need to adjust it
	$CollisionShape2D.position.x = $Sprite2D.position.x + $Sprite2D.region_rect.size.x / 2
