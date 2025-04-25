extends Node
@onready var fade: ColorRect = $Player/Fade
@onready var ui: CanvasLayer = $UI

func _ready() -> void:
	fade.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, 1.0)  # fade in
	ui.hide()


func _on_player_player_died() -> void:
	var tween = fade.fade_out(1)
	ui.show()
