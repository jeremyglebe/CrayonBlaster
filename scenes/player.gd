extends CharacterBody2D
class_name PlayerNode

enum ShipState {
	Active,
	Recovery,
	Destroyed
}

const _ANIM_SPEED_MULTIPLIER := 3.0
const _DEFAULT_CUSTOM_BLEND := -1.0
const _PRIMARY_FLASH_LOOPS := 1
const _PRIMARY_FLASH_LOOP_TIME := 0.25
const _SECONDARY_FLASH_LOOPS := 3
const _SECONDARY_FLASH_LOOP_TIME := 0.35

var sound_shot := load("res://audio/fx/shot.mp3")
var sound_laser := load("res://audio/fx/laser.mp3")
var explosion_scene: PackedScene = load("res://scenes/explosion.tscn")

signal finished(player)
signal destroyed(player)
signal primary_weapon(weapon_position: Vector2, vec_weapon_direction: Vector2)
signal secondary_weapon(weapon_position: Vector2, vec_weapon_direction: Vector2)

# Direction as radians, right is 0, increases clockwise
@export var rad_facing_direction := 3 * PI / 2
# Speed of controls for the ship
@export var forward_speed := 200.0 # pixels
@export var reverse_speed := 100.0 # pixels
@export var turn_speed := PI # radians
@export var strafe_speed := 75.0 # pixels
# Ship Stats
@export var health := 3
@export var recovery_time := 1.0

var state := ShipState.Active
var primary_weapon_ready := true
var secondary_weapon_ready := true
var primary_flash_enabled := false
var secondary_flash_enabled := true

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
	get_tree().call_group("ui", "set_health", health)
	$Timers/RecoveryTimer.wait_time = recovery_time


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
	# Tween to flash purple when weapon is ready
	if primary_flash_enabled:
		var flash_tween = create_tween()
		flash_tween.set_loops(_PRIMARY_FLASH_LOOPS)
		flash_tween.tween_property($Sprite2D, 'modulate', Color(1, 0, 1, 1), _PRIMARY_FLASH_LOOP_TIME / 2)
		flash_tween.tween_property($Sprite2D, 'modulate', Color(1, 1, 1, 1), _PRIMARY_FLASH_LOOP_TIME / 2)


func _on_secondary_refresh_timer_timeout():
	secondary_weapon_ready = true
	# Tween to flash red when weapon is ready
	if secondary_flash_enabled:
		var flash_tween = create_tween()
		flash_tween.set_loops(_SECONDARY_FLASH_LOOPS)
		flash_tween.tween_property($Sprite2D, 'modulate', Color(1, 0, 0, 1), _SECONDARY_FLASH_LOOP_TIME / 2)
		flash_tween.tween_property($Sprite2D, 'modulate', Color(1, 1, 1, 1), _SECONDARY_FLASH_LOOP_TIME / 2)


func _on_recovery_timer_timeout():
	state = ShipState.Active
	$AnimationPlayer.stop()


func control_step(delta: float):
	# Reset velocity
	velocity = Vector2()
	if state != ShipState.Destroyed:
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
		if Input.is_action_just_pressed("secondary weapon"):
			emit_secondary_weapon()
		elif Input.is_action_just_pressed("primary weapon"):
			emit_primary_weapon()


func emit_primary_weapon():
	if primary_weapon_ready:
		var vec_weapon_direction = vec_facing_direction
		primary_weapon.emit($WeaponStartMarker.global_position, vec_weapon_direction)
		play_sound(sound_shot)
		primary_weapon_ready = false
		$Timers/PrimaryRefreshTimer.start()


func emit_secondary_weapon():
	if secondary_weapon_ready:
		var vec_weapon_direction = vec_facing_direction
		secondary_weapon.emit($WeaponStartMarker.global_position, vec_weapon_direction)
		play_sound(sound_laser)
		secondary_weapon_ready = false
		$Timers/SecondaryRefreshTimer.start()


func on_damage(damage_amount: int):
	if state == ShipState.Active:
		health -= damage_amount
		if health <= 0:
			on_destroyed()
		else:
			state = ShipState.Recovery
			$Timers/RecoveryTimer.start()
			$AnimationPlayer.play("flashing", _DEFAULT_CUSTOM_BLEND, _ANIM_SPEED_MULTIPLIER)
	get_tree().call_group("ui", "set_health", health)


func on_destroyed():
	state = ShipState.Destroyed
	destroyed.emit(self)
	# Turn invisible
	$Sprite2D.visible = false
	$Particles/LeftBoosterParticles.visible = false
	$Particles/RightBoosterParticles.visible = false
	# Stop colliding
	$CollisionPolygon2D.queue_free()
	# Create an explosion
	var explosion := explosion_scene.instantiate() as ExplosionNode
	explosion.explosion_type = ExplosionNode.ExplosionType.SHIP
	explosion.scale = Vector2(2.0, 2.0)
	explosion.explosion_finished.connect(on_finished)
	add_child(explosion)


func on_finished(_explosion: ExplosionNode):
	finished.emit(self)
	queue_free()


func play_sound(sound):
	if !$AudioStreamPlayer.playing:
		$AudioStreamPlayer.stream = sound
		$AudioStreamPlayer.play()
