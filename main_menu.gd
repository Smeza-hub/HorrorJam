extends Node
@onready var color_rect: ColorRect = $ColorRect
#
#
## Called when the node enters the scene tree for the first time.
func _ready() -> void:
	color_rect.modulate.a = 0.0
	print(get_tree_string_pretty())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(color_rect.modulate.a)

func _on_start_pressed() -> void:
	var tween = color_rect.fade_out(1)
	tween.connect("finished", Callable(self, "_load_main_scene"))



func _on_exit_pressed() -> void:
	get_tree().quit()
func _load_main_scene():
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
