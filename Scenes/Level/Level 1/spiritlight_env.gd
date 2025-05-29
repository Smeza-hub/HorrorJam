extends PointLight2D
@onready var point_light_2d: PointLight2D = $"."

var follow_duration = 2.0
var elapsed_time = 0.0

var start_position = Vector2()

var follow_target: Node2D = null
var is_following = false
var overlap_threshold = 35.0  # How close they need to be to count as overlapping

@export var flicker_enabled: bool = true
@export var flicker_intensity: float = 10   # Max variation in energy
@export var flicker_speed: float = 20.0      # How fast it flickers
@export var base_energy: float = 5.0    
var velocity: Vector2 = Vector2.ZERO
var float_offset: Vector2 = Vector2.ZERO
var noise_time := 0.0

var flicker_noise := FastNoiseLite.new()
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var flicker = flicker_noise.get_noise_1d(noise_time * flicker_speed) * flicker_intensity
	energy = base_energy + flicker
	if is_following and follow_target:
		# Smoothly move toward the target
		
		point_light_2d.global_position = point_light_2d.global_position.lerp(follow_target.global_position, 0.005)
		var player = follow_target.get_parent()
		player.SPEED = 15
		player.MAX_SPEED = 30
		# Check if they're close enough
		var distance = point_light_2d.global_position.distance_to(follow_target.global_position)
		if distance <= overlap_threshold:
			# Trigger only once
			$"../SpiritTouch".play()
			player.SPEED = player.NORMAL_SPEED
			player.MAX_SPEED = 150
			#follow_target.color.a = 0
			#follow_target.fade_in()
			player.spirit_light = true
			
			is_following = false
			queue_free()


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	pass # Replace with function body.


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		follow_target = body.get_node("PointLight2D")
		is_following = true
		body.has_orb = true
		$"../OrbAcquire".play()
		
