extends CharacterBody2D
@export var blip: PackedScene
@export var target: CharacterBody2D
@export var blip_count:int = 1
@export_range(0,360) var arc: float = 0
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var timer: Timer = $Timer
@onready var point_light_2d: PointLight2D = $Eyes
@onready var attack_sound: AudioStreamPlayer2D = $Attack

@export var SPEED = 1.0
@export var turn_speed = 7.0
@export var ACCELERATION: int


@onready var spawn_position = global_position
@onready var spawn_rotation = rotation

var is_idle:bool
var is_attacking:bool
var can_sing:bool

var power = 15
var knockback_strength = 300

var direction 
func _ready() -> void:
	can_sing = true
	is_attacking = false
func _physics_process(delta: float) -> void:
	move_and_slide()
	if is_attacking:
		aggro(target,delta)
		can_sing = false
		if ray_cast_2d.is_colliding():
			if ray_cast_2d.get_collider() == target:
				timer.stop()
		if !ray_cast_2d.is_colliding() && timer.time_left <= 0:
			timer.start()
	else:
		point_light_2d.call_deferred("set_enabled", false)
		sing(delta)
		velocity = Vector2.ZERO
func sing(delta):
	
	if can_sing:
		can_sing = false
		for i in blip_count:
			var new_blip = blip.instantiate()
			new_blip.position = point_light_2d.global_position
			new_blip.enemy = self
			var arc_rad = deg_to_rad(arc)
			var increment = arc_rad / (blip_count-1)
			new_blip.global_rotation = (
				global_rotation +
				increment*i -
				arc_rad/2
			)
			get_tree().root.call_deferred("add_child",new_blip)
		await get_tree().create_timer(1.6).timeout 
		can_sing = true
		
func aggro(target:CharacterBody2D,delta):
	point_light_2d.call_deferred("set_enabled", true)
	direction = (target.global_position - global_position).angle()
	rotation = lerp_angle(rotation, direction,delta*turn_speed)
	var current_direction = Vector2.RIGHT.rotated(rotation)
	velocity = (current_direction*SPEED)
	print(target.position - position)
	play_attack_sound()
func respawn():
	can_sing = true
	is_attacking = false
	rotation = spawn_rotation
	global_position = spawn_position
func play_attack_sound():
	if attack_sound.playing:
		return
	else:
		attack_sound.play()
func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		print("hit player")
		var knockback_dir = body.global_position - global_position
		body.damage(power,knockback_strength,knockback_dir)


func _on_timer_timeout() -> void:
	print("idle")
	is_attacking = false
	can_sing = true
