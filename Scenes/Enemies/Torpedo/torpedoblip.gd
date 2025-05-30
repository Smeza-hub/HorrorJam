extends RigidBody2D
@onready var timer: Timer = $Timer
@onready var bliplight: PointLight2D = $PointLight2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

@export var speed = 150
@export var amplitude: float = 20.0
@export var frequency: float = 5.0
@export var enemy: CharacterBody2D

var direction = Vector2.RIGHT
var collision_count =0
var max_collision = 1
var time_passed:float =0.0
var origin: Vector2 


var collided = false

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
	if !collided:
		var forward_movement = direction.normalized() *speed * time_passed
		var perpendicular = Vector2(-direction.y, direction.x).normalized()
		var wave_offset = perpendicular  * sin(time_passed*frequency)*amplitude
		global_position = origin + forward_movement + wave_offset


func _on_body_entered(body: Node) -> void:
	collision_shape_2d.call_deferred("set_disabled",true) 
	if body is TileMapLayer || body is StaticBody2D :
		collided = true
		linear_velocity = Vector2(0,0)
		var color = bliplight.color
		while color.a > 0:
			color.a = move_toward(color.a, 0.0, 0.05) # adjust speed here
			bliplight.color = color
			await get_tree().create_timer(0.05).timeout
		queue_free()
	elif body is CharacterBody2D:
		collided = true
		enemy.is_attacking = true
		enemy.target = body
		enemy.attack_sound.play()
		linear_velocity = Vector2(0,0)
		var color = bliplight.color
		while color.a > 0:
			color.a = move_toward(color.a, 0.0, 0.05) # adjust speed here
			bliplight.color = color
			await get_tree().create_timer(0.05).timeout
		queue_free()
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
