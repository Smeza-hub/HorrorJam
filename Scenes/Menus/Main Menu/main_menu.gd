extends Node
@onready var color_rect: ColorRect = $ColorRect
#
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var someshit: AudioStreamPlayer = $someshit

## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color_rect.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(audio_stream_player,"volume_db",-12,1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(color_rect.modulate.a)

func _on_start_pressed() -> void:
	var tween = color_rect.fade_out(2)
	tween.parallel().tween_property(someshit,"volume_db",-80,2)
	tween.parallel().tween_property(audio_stream_player,"volume_db",-80,2)
	tween.connect("finished", Callable(self, "_load_main_scene"))



func _on_exit_pressed() -> void:
	get_tree().quit()
func _load_main_scene():
	get_tree().change_scene_to_file("res://Scenes/opening/video.tscn")


func _on_area_2d_body_entered(body: Node2D) -> void:
	var tween = color_rect.fade_out(2)
	tween.parallel().tween_property(someshit,"volume_db",-80,2)
	tween.parallel().tween_property(audio_stream_player,"volume_db",-80,2)
	tween.connect("finished", Callable(self, "_load_main_scene"))
