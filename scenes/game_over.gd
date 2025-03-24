extends Control

@export var title_scene: PackedScene = load("res://scenes/title_screen.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	$CenterContainer/VBoxContainer/Label2.text = "SCORE: " + str(Global.get_score())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("accept"):
		get_tree().change_scene_to_packed(title_scene)
