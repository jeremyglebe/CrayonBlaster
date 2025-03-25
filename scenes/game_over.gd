extends Control

@export var title_scene: PackedScene = load("res://scenes/title_screen.tscn")

const HINT_MESSAGES = [
	"you'll receive a random hint message every time you \"game over\" (yes, this hint counts)",
	"your ship will flash red when your secondary weapon is ready",
	"meteors begin appearing from the bottom of the screen at Threat Level 2",
	"meteors will appear from the sides of the screen at Threat Level 3",
	"every time the Threat Level increases, meteors start spawning faster - but there is a limit!",
	"the secondary weapon pierces through multiple targets",
]

# Called when the node enters the scene tree for the first time.
func _ready():
	$CenterContainer/VBoxContainer/Label2.text = "SCORE: " + str(Global.get_score())
	$CenterContainer/VBoxContainer/HintLabel.text = "HINT: " + HINT_MESSAGES[randi() % HINT_MESSAGES.size()]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("accept"):
		get_tree().change_scene_to_packed(title_scene)
