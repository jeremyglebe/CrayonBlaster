extends Node2D

@onready var _VIEWPORT_WIDTH := get_viewport().get_visible_rect().size.x
@onready var _VIEWPORT_HEIGHT := get_viewport().get_visible_rect().size.y
var score := 0

# Loading child scenes
var meteor_scene: PackedScene = load("res://scenes/meteor.tscn")
var plasma_dart_scene: PackedScene = load("res://scenes/plasma_dart.tscn")
const _PLASMA_DART_SCALE := 0.15
var explosion_scene: PackedScene = load("res://scenes/explosion.tscn")
const _EXPLOSION_SCALE := 3.0

# Called when the node enters the scene tree for the first time.
func _ready():
	star_randomizer()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_meteor_spawn_timer_timeout():
	spawn_random_meteor()


func _on_player_primary_weapon(weapon_position: Vector2, vec_weapon_direction: Vector2):
	# Create a new plasma dart
	var new_plasma_dart := plasma_dart_scene.instantiate() as PlasmaDartNode
	# Configure visual properties
	new_plasma_dart.scale = Vector2(_PLASMA_DART_SCALE, _PLASMA_DART_SCALE)
	# Configure position
	new_plasma_dart.position = weapon_position
	# Configure direction
	new_plasma_dart.rad_facing_direction = vec_weapon_direction.angle()
	# Add the plasma dart to the scene
	$PlasmaDarts.add_child(new_plasma_dart)


func _on_player_game_over(player: PlayerNode):
	create_explosion(player.position, ExplosionNode.ExplosionType.SHIP)


func _on_meteor_destroyed(meteor: MeteorNode):
	increase_score(1)
	create_explosion(meteor.position, ExplosionNode.ExplosionType.METEOR)


func _on_explosions_explosion_finished(explosion: ExplosionNode):
	match explosion.explosion_type:
		ExplosionNode.ExplosionType.METEOR:
			pass
		ExplosionNode.ExplosionType.SHIP:
			get_tree().reload_current_scene()


func _on_bgm_warning_signal_finished():
	$BGM_Warning_Signal.volume_db = -80
	create_tween().tween_property($BGM_Warning_Signal, 'volume_db', -10, 2)


func create_explosion(explosion_position: Vector2, explosion_type: ExplosionNode.ExplosionType):
	var explosion := explosion_scene.instantiate() as ExplosionNode
	explosion.scale = Vector2(_EXPLOSION_SCALE, _EXPLOSION_SCALE)
	explosion.position = explosion_position
	explosion.explosion_type = explosion_type
	explosion.explosion_finished.connect(_on_explosions_explosion_finished)
	$Explosions.add_child(explosion)


func increase_score(points):
	score += points
	$ScoreLabel.text = str(score)


func spawn_random_meteor():
	# Create a new meteor
	var new_meteor := meteor_scene.instantiate() as MeteorNode
	# Configure random position
	new_meteor.set_random_position(0, _VIEWPORT_WIDTH, -200, 0)
	# Callback for meteor.destroyed signal
	new_meteor.connect("destroyed", _on_meteor_destroyed)
	# Add the meteor to the scene
	$Meteors.add_child(new_meteor)


func star_randomizer():
	for star in $Stars.get_children():
		star.position = Vector2(randf_range(0, _VIEWPORT_WIDTH), randf_range(0, _VIEWPORT_HEIGHT))
		var star_scale := randf_range(0.05, 0.15)
		star.scale = Vector2(star_scale, star_scale)
		star.speed_scale = randf_range(0.5, 1.5)

