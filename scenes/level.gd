extends Node2D

@onready var _VIEWPORT_WIDTH := get_viewport().get_visible_rect().size.x
@onready var _VIEWPORT_HEIGHT := get_viewport().get_visible_rect().size.y
@onready var TOP_SPAWN_BOUNDS := Vector4(0, _VIEWPORT_WIDTH, -200, 0)
@onready var BOTTOM_SPAWN_BOUNDS := Vector4(0, _VIEWPORT_WIDTH, _VIEWPORT_HEIGHT, _VIEWPORT_HEIGHT + 200)
@onready var LEFT_SPAWN_BOUNDS := Vector4(-200, 0, 0, _VIEWPORT_HEIGHT)
@onready var RIGHT_SPAWN_BOUNDS := Vector4(_VIEWPORT_WIDTH, _VIEWPORT_WIDTH + 200, 0, _VIEWPORT_HEIGHT)
@onready var active_spawn_zones: Array[Vector4] = [TOP_SPAWN_BOUNDS]

# Loading child scenes
var meteor_scene: PackedScene = load("res://scenes/meteor.tscn")
var plasma_dart_scene: PackedScene = load("res://scenes/plasma_dart.tscn")
var laser_scene: PackedScene = load("res://scenes/laser.tscn")
var explosion_scene: PackedScene = load("res://scenes/explosion.tscn")

# Variables for difficulty and progression
var progression_time_previous := 0.0
var progression_time := 10.0
# var progression_time := 3.0 # When I need to test difficulties faster
const INITIAL_METEOR_SPAWN_RATE := 2.0
const FASTEST_METEOR_SPAWN_RATE := 0.15

# Called when the node enters the scene tree for the first time.
func _ready():
	# Reset the score to 0 to start a new game
	Global.base_score = 0
	Global.threat_level = 0
	# Start the timers at their default rates
	$Timers/DifficultyTimer.wait_time = progression_time
	$Timers/DifficultyTimer.start()
	$Timers/MeteorSpawnTimer.wait_time = INITIAL_METEOR_SPAWN_RATE
	$Timers/MeteorSpawnTimer.start()
	# Create stars to fill the background
	star_randomizer()
	# Always spawn one meteor immediately
	spawn_random_meteor()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_meteor_spawn_timer_timeout():
	spawn_random_meteor()

func _on_difficulty_timer_timeout():
	# Increase the difficulty level
	increase_difficulty()
	# Update the time until next difficulty increase
	# The timer follows a fibonnaci-based sequence (starting at 20: 0, 20, 20, 40, 60, 100, 160, ...)
	progression_time_previous = progression_time
	progression_time = progression_time_previous + progression_time
	$Timers/DifficultyTimer.wait_time = progression_time
	$Timers/DifficultyTimer.start()


func _on_player_primary_weapon(weapon_position: Vector2, vec_weapon_direction: Vector2):
	# Create a new plasma dart
	var new_plasma_dart := plasma_dart_scene.instantiate() as PlasmaDartNode
	# Configure position
	new_plasma_dart.position = weapon_position
	# Configure direction
	new_plasma_dart.rad_facing_direction = vec_weapon_direction.angle()
	# Add the plasma dart to the scene
	$PlasmaDarts.add_child(new_plasma_dart)


func _on_player_secondary_weapon(weapon_position: Vector2, vec_weapon_direction: Vector2):
	# Create a new laser
	var new_laser := laser_scene.instantiate() as LaserNode
	# Configure position
	new_laser.position = weapon_position
	# Configure direction
	new_laser.rad_facing_direction = vec_weapon_direction.angle()
	# Add the laser to the scene
	$PlasmaDarts.add_child(new_laser)


func _on_player_finished(_player: PlayerNode):
	#get_tree().reload_current_scene()
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	

func _on_meteor_destroyed(meteor: MeteorNode):
	increase_score(1)
	create_explosion(meteor.position, ExplosionNode.ExplosionType.METEOR)


func _on_bgm_warning_signal_finished():
	$BGM_Warning_Signal.volume_db = -80
	create_tween().tween_property($BGM_Warning_Signal, 'volume_db', -10, 2)


func create_explosion(explosion_position: Vector2, explosion_type: ExplosionNode.ExplosionType):
	var explosion := explosion_scene.instantiate() as ExplosionNode
	explosion.position = explosion_position
	explosion.explosion_type = explosion_type
	$Explosions.add_child(explosion)

func increase_difficulty():
	# Increase the difficulty level
	Global.threat_level += 1
	# Update the ThreatLevel UI Label
	$UI/CenterContainer/Label.text = "Threat Level\n" + str(Global.threat_level)
	$UI/MarginContainer/ScoreLabel.text = str(Global.get_score())

	# Calculate the spawn rate as a function of the difficulty level
	# Starting at 10.0, approaching 0.5 as difficulty increases but never reaching it
	# f(x) = 0.5 + 9.5 / (1 + x)
	# The "maximum difficulty" (in terms of speed) is effectively reached by Global.threat_level = 50, but it will always technically get a little faster
	# $Timers/MeteorSpawnTimer.wait_time = 0.5 + 9.5 / (1 + Global.threat_level)
	# Ignore all of that, this is better (but I'm leaving the comments for my future notes)
	
	# It is better because it is dynamic and easily updated
	$Timers/MeteorSpawnTimer.wait_time = FASTEST_METEOR_SPAWN_RATE + (INITIAL_METEOR_SPAWN_RATE - FASTEST_METEOR_SPAWN_RATE) / (1 + Global.threat_level)
	
	# Other difficulty adjustments (such as obstacle types) may be set based on predefined difficulty levels
	match Global.threat_level:
		2:
			active_spawn_zones = [TOP_SPAWN_BOUNDS, BOTTOM_SPAWN_BOUNDS]
		3:
			active_spawn_zones = [TOP_SPAWN_BOUNDS, BOTTOM_SPAWN_BOUNDS, LEFT_SPAWN_BOUNDS, RIGHT_SPAWN_BOUNDS]

func increase_score(points):
	Global.base_score += points
	$UI/MarginContainer/ScoreLabel.text = str(Global.get_score())


func spawn_random_meteor():
	# Create a new meteor
	var new_meteor := meteor_scene.instantiate() as MeteorNode
	# Choose a random spawn zone from the active spawn zones
	var spawn_zone := active_spawn_zones[randi() % active_spawn_zones.size()]
	# print("Spawn zone: ", spawn_zone[0], ", ", spawn_zone[1], ", ", spawn_zone[2], ", ", spawn_zone[3])
	# Configure random position
	new_meteor.set_random_position(spawn_zone[0], spawn_zone[1], spawn_zone[2], spawn_zone[3])

	# Configure random direction parameters
	match spawn_zone:
		# Top spawn zone
		TOP_SPAWN_BOUNDS:
			new_meteor.rad_min_random_direction = PI / 4
			new_meteor.rad_max_random_direction = 3 * PI / 4
		# Bottom spawn zone
		BOTTOM_SPAWN_BOUNDS:
			new_meteor.rad_min_random_direction = -3 * PI / 4
			new_meteor.rad_max_random_direction = - PI / 4
		# Left spawn zone
		LEFT_SPAWN_BOUNDS:
			new_meteor.rad_min_random_direction = 0
			new_meteor.rad_max_random_direction = PI
		# Right spawn zone
		RIGHT_SPAWN_BOUNDS:
			new_meteor.rad_min_random_direction = PI
			new_meteor.rad_max_random_direction = 2 * PI

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
