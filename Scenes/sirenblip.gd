extends RigidBody2D
@onready var timer: Timer = $Timer
@onready var bliplight: PointLight2D = $PointLight2D

@export var speed = 50
@export var amplitude: float = 20.0
@export var frequency: float = 5.0


var direction = Vector2.RIGHT
var collision_count =0
var max_collision = 1
var time_passed:float =0.0
var origin: Vector2


var collided: bool

func spawn():
	pass
func _ready() -> void:
	origin = global_position
	add_to_group("enemyprojectiles")
	direction = Vector2.RIGHT.rotated(global_rotation)
	#linear_velocity = direction * speed
	collided = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _integrate_forces(state):
	pass
	
func _process(delta: float) -> void:
	time_passed += delta
	var forward_movement = direction.normalized() *speed * time_passed
	
	var perpendicular = Vector2(-direction.y, direction.x).normalized()
	var wave_offset = perpendicular  * sin(time_passed*frequency)*amplitude
	
	global_position = origin + forward_movement + wave_offset


#func _on_body_entered(body: Node) -> void:
	##check if the blip collides with the Tilemap. If so it disables the timer and slowly fades out
	#if body is TileMapLayer || body is TileMapLayer :
		#collided = true
		#linear_velocity = Vector2(0,0)
		#var color = bliplight.color
		#while color.a > 0:
			#color.a = move_toward(color.a, 0.0, 0.05) # adjust speed here
			#bliplight.color = color
			#await get_tree().create_timer(0.05).timeout
		#queue_free()

#func _on_timer_timeout() -> void:
	#if collided:
		#return
	#else:
		#var color = bliplight.color
		#while color.a > 0:
			#color.a = move_toward(color.a, 0.0, 0.05) # adjust speed here
			#bliplight.color = color
			#await get_tree().create_timer(0.1).timeout
		#queue_free()
