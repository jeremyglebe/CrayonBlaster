extends CanvasLayer

static var heart_image = load("res://images/Crayon_Heart.png")


func set_health(amount: int):
	# clear current health icons
	$MarginContainer2/HeartContainer.get_children().map(
		func(child): child.queue_free()
	)
	# create correct amount of new health icons
	for i in amount:
		var heart = TextureRect.new()
		heart.texture = heart_image
		heart.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		$MarginContainer2/HeartContainer.add_child(heart)
