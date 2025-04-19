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
	direction = Vector2.RIGHT.rotated(global_rotation)
	linear_velocity = direction * speed
	timer.start((scream_strength/20))
	print(scream_strength)
	max_collision = round(scream_strength/10)
	collided = false
	print(bliplight.color.a8)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _integrate_forces(state):
	pass
	
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node) -> void:
	#check if the blip collides with the Tilemap. If so it disables the timer and slowly fades out
	if body is TileMapLayer:
		collided = true
		linear_velocity = Vector2(0,0)
		var color = bliplight.color
		while color.a > 0:
			color.a = move_toward(color.a, 0.0, 0.05) # adjust speed here
			bliplight.color = color
			await get_tree().create_timer(0.05).timeout
		queue_free()
		
		
		
		
		#collision_count +=1

		#if collision_count >= max_collision:
			#print("collided")
			#var color = light.color
			#while color.a != 0:
				#color.a = move_toward(color.a,0,100)
				#light.color = color
				#await get_tree().create_timer(0.05).timeout
			#queue_free()


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
