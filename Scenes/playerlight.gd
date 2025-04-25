extends PointLight2D

@export var target_node: NodePath
@export var spring_strength: float = 15     # Higher = snappier lower = floatier
@export var damping: float = 1             # Higher = less overshoot
@export var float_amplitude: float = 3.0      # How much the light floats around
@export var float_speed: float = 1.0          # How fast it floats

@export var flicker_enabled: bool = true
@export var flicker_intensity: float = 10   # Max variation in energy
@export var flicker_speed: float = 20.0      # How fast it flickers
@export var base_energy: float = 5.0         # The "normal" brightness

var flicker_noise := FastNoiseLite.new()

var velocity: Vector2 = Vector2.ZERO
var float_offset: Vector2 = Vector2.ZERO
var noise_time := 0.0
func _ready():
	flicker_noise.seed = randi()
	flicker_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	flicker_noise.frequency = 1.0  # You can tweak this later
func _process(delta):
	if get_parent().spirit_light:
		spirit_light(delta)
	else:
		hide()
func spirit_light(delta):
	if target_node == null:
		return

	var target = get_node(target_node)
	if target == null:
		return

	
	noise_time += delta * float_speed
	float_offset.x = sin(noise_time * 1.2) * float_amplitude
	float_offset.y = cos(noise_time * 0.9) * float_amplitude

	var target_pos = target.global_position + float_offset

	
	var direction = target_pos - global_position
	var acceleration = direction * spring_strength - velocity * damping

	velocity += acceleration * delta
	global_position += velocity * delta
	
	if flicker_enabled and self is Light2D:
		var flicker = flicker_noise.get_noise_1d(noise_time * flicker_speed) * flicker_intensity
		energy = base_energy + flicker
	
