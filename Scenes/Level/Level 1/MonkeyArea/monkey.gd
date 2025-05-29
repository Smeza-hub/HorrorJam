extends Node2D
@onready var marker: Marker2D = $Marker2D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var collision_polygon_2d: CollisionPolygon2D = $Area2D/CollisionPolygon2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("head"):
		print("monkey")
		$Area2D.set_deferred("monitoring",false)
		var rock = area.get_tree().root.get_node("Main/Level/DisBlock")
		
		var collider = rock.get_node("CollisionPolygon2D")
		var collider2 = rock.get_node("CollisionPolygon2D2")
		
		
		var Music = area.get_tree().root.get_node("Main/Music")
		var tween = create_tween()
		tween.tween_property(Music, "volume_db", -20 , 15.0)
		Music.play()
		
		collider.set_deferred("disabled", true)
		collider2.set_deferred("disabled", true)
		rock.hide()
		var player = area.get_parent().get_parent()
		var camera = player.get_node("Camera2D")
		var direction = (marker.global_position - player.global_position).normalized()
		var zoom_tween = get_tree().create_tween()
		zoom_tween.tween_property(camera, "zoom", Vector2(1.5,1.5), 1.0)
		await get_tree().create_timer(1).timeout
		
		audio_stream_player.play()
		player.SPEED = 25
		player.MAX_SPEED = 45
		print("playing")
		await get_tree().create_timer(6).timeout
		var zoom_in_tween = get_tree().create_tween()
		zoom_in_tween.tween_property(camera, "zoom", Vector2(2.5, 2.5), 2.0)
		player.shaking = true
		$apesound.play()
		await audio_stream_player.finished
		player.shaking = false
		player.velocity += direction * 1000
		player.is_spinning = true
		await get_tree().create_timer(4).timeout
		rock.show()
		$Area2D.set_deferred("monitoring",true)
		collider.set_deferred("disabled", false)
		collider2.set_deferred("disabled", false)
		player.is_spinning = false
		player.SPEED = player.NORMAL_SPEED
		player.MAX_SPEED = 150
		print("done")
