extends PointLight2D

@export var target_node: NodePath
@export var spring_strength: float = 15     # Higher = snappier, lower = floatier
@export var damping: float = 1             # Higher = less overshoot
@export var float_amplitude: float = 3.0      # How much the light floats around
@export var float_speed: float = 1.0          # How fast it floats

var velocity: Vector2 = Vector2.ZERO
var float_offset: Vector2 = Vector2.ZERO
var noise_time := 0.0

func _process(delta):
	if target_node == null:
		return

	var target = get_node(target_node)
	if target == null:
		return

	# --- Floating wiggle (like a firefly or magical light) ---
	noise_time += delta * float_speed
	float_offset.x = sin(noise_time * 1.2) * float_amplitude
	float_offset.y = cos(noise_time * 0.9) * float_amplitude

	var target_pos = target.global_position + float_offset

	# --- Spring physics for momentum / overshoot effect ---
	var direction = target_pos - global_position
	var acceleration = direction * spring_strength - velocity * damping

	velocity += acceleration * delta
	global_position += velocity * delta
