extends ColorRect

var current_tween: Tween = null

func fade_in(duration = 1.0) -> void:
	if current_tween:
		current_tween.kill()
	current_tween = create_tween()
	current_tween.tween_property(self, "modulate:a", 0.0, duration)

func fade_out(duration = 1.0) -> Tween:
	if current_tween:
		current_tween.kill()
	current_tween = create_tween()
	current_tween.tween_property(self, "modulate:a", 1.0, duration)
	return current_tween
