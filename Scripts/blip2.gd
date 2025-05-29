extends RigidBody2D

@onready var bliplight: PointLight2D = $PointLight2D

@export var speed = 100
var direction = Vector2.RIGHT
var collision_count = 0
var max_collision = 1
var scream_strength: float

var collided: bool
var despawn_time 
var elapsed_time  

func spawn():
	pass

func _ready() -> void:
	add_to_group("projectiles")
	print(scream_strength)
	print(despawn_time)
	direction = Vector2.RIGHT.rotated(global_rotation)
	linear_velocity = direction * speed
	max_collision = round(scream_strength / 10)
	collided = false
	elapsed_time = 0.0 


func _process(delta: float) -> void:
	# If the projectile hasn't collided, track the elapsed time
	if !collided:
		elapsed_time += delta

		# If the projectile has existed for long enough, fade it out and destroy it
		if elapsed_time >= despawn_time:
			var color = bliplight.color
			# Smooth fade-out
			while color.a > 0:
				color.a = move_toward(color.a, 0.0, 0.05)  # adjust speed here
				bliplight.color = color
				await get_tree().create_timer(0.05).timeout
			queue_free()  # Delete the projectile when the fade is complete

func _on_body_entered(body: Node) -> void:
	# Check if the blip collides with the Tilemap. If so, disable the timer and slowly fade out
	if body is TileMapLayer || body is StaticBody2D || body is CharacterBody2D:
		collided = true
		if body.is_in_group("siren"):
			var target = get_node("/root/Main/Player")
			# body.aggro(target)  # You can uncomment this if you have the aggro logic in the other node
			body.is_attacking = true
			body.target = target
		linear_velocity = Vector2.ZERO  # Stop the projectile movement
		var color = bliplight.color
		# Fade out immediately on collision
		while color.a > 0:
			color.a = move_toward(color.a, 0.0, 0.05)  # adjust speed here
			bliplight.color = color
			await get_tree().create_timer(0.05).timeout
		queue_free()  # Delete the projectile after fading out
