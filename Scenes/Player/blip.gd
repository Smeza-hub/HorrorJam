extends RigidBody2D
@onready var timer: Timer = $Timer
@onready var bliplight: PointLight2D = $PointLight2D

@export var speed = 100
var direction = Vector2.RIGHT
var collision_count =0
var max_collision = 1
var scream_strength:float
@onready var sprite_2d: Sprite2D = $CanvasLayer/Sprite2D

var collided: bool

var despawn_time: float
var elapsed_time :float

func spawn():
	pass
func _ready() -> void:
	add_to_group("projectiles")
	direction = Vector2.RIGHT.rotated(global_rotation)
	sprite_2d.global_position = global_position
	linear_velocity = direction * speed
	collided = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	sprite_2d.global_position = global_position
	sprite_2d.global_rotation = global_rotation
	if !collided:
		elapsed_time += delta

		# If the projectile has existed for long enough, fade it out and destroy it
		if elapsed_time >= despawn_time:
			var alpha = sprite_2d.modulate.a
			while alpha > 0:
				alpha = move_toward(alpha, 0.0, 0.05) # adjust speed here
				sprite_2d.modulate.a = alpha
				await get_tree().create_timer(0.05).timeout
			queue_free()  # Delete the projectile when the fade is complete

func _on_body_entered(body: Node) -> void:
	#check if the blip collides with the Tilemap. If so it disables the timer and slowly fades out
	if body is TileMapLayer || body is StaticBody2D || body is CharacterBody2D:
		collided = true
		if body.is_in_group("siren"):
			var target = get_node("/root/Main/Player")
			#body.aggro(target)
			body.is_attacking = true
			body.target = target
		linear_velocity = Vector2(0,0)
		var alpha = sprite_2d.modulate.a
		while alpha > 0:
			alpha = move_toward(alpha, 0.0, 0.05) # adjust speed here
			sprite_2d.modulate.a = alpha
			await get_tree().create_timer(0.05).timeout
		queue_free()
		

#func _on_timer_timeout() -> void:
	#if collided:
		#return
	#else:
		#var alpha = sprite_2d.modulate.a
		#while alpha.a > 0:
			#alpha.a = move_toward(alpha, 0.0, 0.05) # adjust speed here
			#sprite_2d.modulate.a = alpha
			#await get_tree().create_timer(0.05).timeout
