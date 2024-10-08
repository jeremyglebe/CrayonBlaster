class_name ExplosionNode
extends Node2D

var sound_explode := load("res://audio/fx/explode.mp3")
var sound_long_explode := load("res://audio/fx/long_explode.mp3")

enum ExplosionType {
	METEOR,
	SHIP
}

signal explosion_finished(explosion)

@export var explosion_type := ExplosionType.METEOR

var _audio_finished := false
var _anim_finished := false

# Called when the node enters the scene tree for the first time.
func _ready():
	match explosion_type:
		ExplosionType.METEOR:
			$AudioStreamPlayer2D.stream = sound_explode
		ExplosionType.SHIP:
			$AudioStreamPlayer2D.stream = sound_long_explode
	$AudioStreamPlayer2D.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if _anim_finished and _audio_finished:
		explosion_finished.emit(self)
		queue_free()


func _on_animated_sprite_2d_animation_finished():
	_anim_finished = true


func _on_audio_stream_player_2d_finished():
	_audio_finished = true
