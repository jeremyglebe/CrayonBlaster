extends Area2D
class_name PlasmaDartNode

@export var speed := 500.0
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
	$Sprite2D.scale = Vector2(0, 0)
	var tween = create_tween()
	tween.tween_property($Sprite2D, 'scale', Vector2(1, 1), 0.35)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation = rad_facing_direction
	position += vec_facing_direction * speed * delta


func check_delete():
	var sprite_height: float = $Sprite2D.get_rect().size.y * scale.y
	var sprite_width: float = $Sprite2D.get_rect().size.x * scale.x
	if position.y < 0 - sprite_height:
		queue_free()
		return
	if position.y > get_viewport_rect().size.y + sprite_height:
		queue_free()
		return
	if position.x < 0 - sprite_width:
		queue_free()
		return
	if position.x > get_viewport_rect().size.x + sprite_width:
		queue_free()
		return
