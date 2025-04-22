extends Area2D
var surface_y

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("projectiles"):
		body.queue_free()
	
