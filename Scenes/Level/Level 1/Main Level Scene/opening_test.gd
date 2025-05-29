extends Node

@onready var fade: ColorRect = $Player/Fade
@onready var ui: CanvasLayer = $UI
@onready var ambience: AudioStreamPlayer = $Ambience
@onready var music: AudioStreamPlayer = $Music
var ambience_starting_volume = -12
var music_starting_volume = -20
@onready var end_2: CanvasLayer = $End2

var fade_out_tween: Tween
var fade_in_tween: Tween
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	end_2.hide()
	fade.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, 1.0)  # fade in
	ui.hide()
	music.stop()
	var player = $Player
	player.health_bar = $Bars/Health
	player.stamina_bar = $Bars/Stamina

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func play_sound_once(audio_stream: AudioStream, position: Vector2 = Vector2.ZERO):
	var sound = AudioStreamPlayer.new()
	sound.stream = audio_stream
	#sound.global_position = position
	sound.autoplay = false
	sound.bus = "SFX"  # Optional: choose your bus
	sound.volume_db = -6  # Optional: adjust volume
	sound.finished.connect(sound.queue_free)  # Auto cleanup
	add_child(sound)
	sound.play()



func _on_player_player_died() -> void:
	var tween = fade.fade_out(0.5)
	ui.show()
	for child in ui.get_children():
		child.show()
	#fade_audio_out()
func _on_player_player_respawn() -> void:
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, 1.0)  # fade in
	ui.hide()
	for child in ui.get_children():
		child.hide()
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy.has_method("respawn"):
			enemy.respawn()
	#fade_audio_in()
#func fade_audio_out():
	##if fade_out_tween:  
		##fade_out_tween.kill()  
	#fade_out_tween = create_tween()
	#fade_out_tween.tween_property(ambience, "volume_db", -80, 2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	#fade_out_tween.tween_property(music, "volume_db", -80,  2.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
#
#func fade_audio_in():
	#if fade_out_tween:
		#fade_out_tween.kill()
		#
	#fade_in_tween = create_tween()
	#fade_in_tween.tween_property(ambience, "volume_db", ambience_starting_volume, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	#fade_in_tween.tween_property(music, "volume_db", music_starting_volume, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _on_end_body_entered(body: Node2D) -> void:
	end_2.show()
