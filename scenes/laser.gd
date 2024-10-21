class_name LaserNode
extends Area2D

@export var max_length := 4096.0
@export var speed := 10000.0
@export var life_time := 0.15
@export var fade_time := 0.5
@export var rad_facing_direction := 0.0

var extension_time: float:
	get:
		return max_length / speed

var vec_facing_direction: Vector2:
	get:
		return Vector2(
			cos(rad_facing_direction),
			sin(rad_facing_direction)
		)


# Called when the node enters the scene tree for the first time.
func _ready():
	rotation = rad_facing_direction
	var laser_extend_tween = create_tween()
	laser_extend_tween.tween_property($Sprite2D, ':region_rect:size:x', max_length, extension_time)
	$LifeTimer.start(life_time)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	rotation = rad_facing_direction
	# Match the collision shape to the sprite
	$CollisionShape2D.shape.size.x = $Sprite2D.region_rect.size.x
	# The position of the collision shape is its center, so we need to adjust it
	$CollisionShape2D.position.x = $Sprite2D.position.x + $Sprite2D.region_rect.size.x / 2


func _on_life_timer_timeout():
	var laser_fade_tween = create_tween()
	laser_fade_tween.tween_property($Sprite2D, ':modulate:a', 0, fade_time)
	laser_fade_tween.connect("finished", _on_laser_fade_finished)


func _on_laser_fade_finished():
	queue_free()
