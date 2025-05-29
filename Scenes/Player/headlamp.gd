extends PointLight2D
@export var target_node: NodePath
@export var flicker_enabled: bool = true
@export var flicker_intensity: float = 100   # Max variation in energy
@export var flicker_speed: float = 20.0      # How fast it flickers
var base_energy: float = energy         # The "normal" brightness
@onready var player: CharacterBody2D = $"../../.."

var lampbroken = false

var flicker_noise := FastNoiseLite.new()

var velocity: Vector2 = Vector2.ZERO
var float_offset: Vector2 = Vector2.ZERO
var noise_time := 0.0

func _ready() -> void:
	energy = base_energy
	if player.headlamp_on:
		show()
	else:
		hide()
func lamp_break(): 
	await get_tree().create_timer(4).timeout
	var darkness = get_node("/root/Main/shadow")
	darkness.color = Color(0,0,0)
	hide()

func _process(delta: float) -> void:
	if lampbroken:
		energy = randf_range(0.1,base_energy)
		lamp_break()
