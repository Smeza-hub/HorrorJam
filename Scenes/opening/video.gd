extends Node
@onready var point_light_2d_2: PointLight2D = $PointLight2D2

var tween_in_progress = false  # Flag to track if the tween is still running

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var tween = create_tween()
	tween.tween_property(point_light_2d_2, "energy", 1, 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Check if the tween is in progress and if the energy has reached 0
	if tween_in_progress and point_light_2d_2.energy <= 0:
		# Once the energy is 0, change the scene
		change_scene()
		tween_in_progress = false  # Reset the flag after the scene change

# Called when the video stream finishes
func _on_video_stream_player_finished() -> void:
	var tween = create_tween()
	tween.tween_property(point_light_2d_2, "energy", 0, 1)
	
	# Set the flag to indicate the tween is in progress
	tween_in_progress = true

func change_scene():
	get_tree().change_scene_to_file("res://Scenes/test/opening_test.tscn")
