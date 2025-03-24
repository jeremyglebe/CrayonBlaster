extends Node

var base_score := 0
var threat_level := 0

func get_score() -> int:
  var threat_multiplier := 1.0 + (threat_level / 10.0)
  return int(base_score * threat_multiplier)