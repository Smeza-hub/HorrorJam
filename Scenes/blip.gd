extends RigidBody2D
@onready var timer: Timer = $Timer
@onready var bliplight: PointLight2D = $PointLight2D

@export var speed = 100
var direction = Vector2.RIGHT
var collision_count =0
var max_collision = 1
var scream_strength:float

var collided: bool

func spawn():
	pass
func _ready() -> void:
	add_to_group("projectiles")
	direction = Vector2.RIGHT.rotated(global_rotation)
	linear_velocity = direction * speed
	timer.start((scream_strength/20))
	max_collision = round(scream_strength/10)
	collided = false
# Called every frame. 'delta' is the elapsed time since the previous frame.


func _on_body_entered(body: Node) -> void:
	#check if the blip collides with the Tilemap. If so it disables the timer and slowly fades out
	if body is TileMapLayer || body is StaticBody2D || body is CharacterBody2D:
		collided = true
		if body.has_method("aggro"):
			var target = get_node("/root/Main/Player")
			#body.aggro(target)
			body.is_attacking = true
			body.target = target
		linear_velocity = Vector2(0,0)
		var color = bliplight.color
		while color.a > 0:
			color.a = move_toward(color.a, 0.0, 0.05) # adjust speed here
			bliplight.color = color
			await get_tree().create_timer(0.05).timeout
		queue_free()
		
		
		
		


func _on_timer_timeout() -> void:
	if collided:
		return
	else:
		var color = bliplight.color
		while color.a > 0:
			color.a = move_toward(color.a, 0.0, 0.05) # adjust speed here
			bliplight.color = color
			await get_tree().create_timer(0.1).timeout
		queue_free()
