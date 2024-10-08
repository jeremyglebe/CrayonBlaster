class_name ExplosionNode
extends Node2D

var sound_explode := load("res://audio/fx/explode.mp3")
var sound_long_explode := load("res://audio/fx/long_explode.mp3")

enum ExplosionType {
	METEOR,
	SHIP
}

signal explosion_finished(object)

@export_enum("Meteor", "Ship") var explosion_type


# Called when the node enters the scene tree for the first time.
func _ready():
	match explosion_type:
		"Meteor":
			$AudioStreamPlayer2D.stream = sound_explode
		"Ship":
			$AudioStreamPlayer2D.stream = sound_long_explode
	$AudioStreamPlayer2D.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match explosion_type:
		"Meteor":
			pass
		"Ship":
			pass


func _on_animated_sprite_2d_animation_finished():
	queue_free()
