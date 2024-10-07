extends Node2D

# Viewport
var _VIEWPORT_WIDTH: float

# Meteors
var meteor_scene: PackedScene = load("res://scenes/meteor.tscn")
const _METEOR_SCALE := 0.25

# Called when the node enters the scene tree for the first time.
func _ready():
	_VIEWPORT_WIDTH = get_viewport().get_visible_rect().size.x


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_meteor_spawn_timer_timeout():
	spawn_random_meteor()

func spawn_random_meteor():
	# Create a new meteor
	var new_meteor := meteor_scene.instantiate() as MeteorNode
	# Configure visual properties
	new_meteor.scale = Vector2(_METEOR_SCALE, _METEOR_SCALE)
	# Configure random position
	new_meteor.set_random_position(0, _VIEWPORT_WIDTH, -200, 0)
	# Add the meteor to the scene
	$Meteors.add_child(new_meteor)
