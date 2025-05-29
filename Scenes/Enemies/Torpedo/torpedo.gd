extends CharacterBody2D


@export var blip: PackedScene
@export var target: CharacterBody2D
@export var blip_count:int = 1
@export_range(0,360) var arc: float = 0
@onready var timer: Timer = $Timer
@onready var point_light_2d: PointLight2D = $Eyes
@onready var eyes: PointLight2D = $Eyes
@onready var attack_sound: AudioStreamPlayer2D = $Attack
@onready var scan: AudioStreamPlayer2D = $Scan
@onready var torpedo_particle: GPUParticles2D = $"CanvasLayer/Torpedo Particle"

@export var SPEED = 600
@export var turn_speed = 100.0

@onready var spawn_position = global_position
@onready var spawn_rotation = rotation


var is_idle:bool
var is_attacking:bool
var is_singing: bool = false
var launched = false
var tracking_strength =0.1
var align_thresh = 0.1

var can_sing:bool
var power = 15
var knockback_strength = 300

var direction 
func _ready() -> void:
	
	can_sing = true
	is_attacking = false
func _physics_process(delta: float) -> void:
	torpedo_particle.global_position = global_position
	if is_attacking:
		aggro(target,delta)
		eyes.show()
		torpedo_particle.show()
	else:
		sing(delta)
		eyes.hide()
		torpedo_particle.hide()
	move_and_slide()
func sing(delta):
	if is_attacking or is_singing:
		return
	if can_sing:
		can_sing = false
		is_singing = true
		for i in blip_count:
			var new_blip = blip.instantiate()
			new_blip.position = global_position
			new_blip.enemy = self
			var arc_rad = deg_to_rad(arc)
			var increment = arc_rad / (blip_count-1)
			new_blip.global_rotation = (
				global_rotation +
				increment*i -
				arc_rad/2
			)
			get_tree().root.call_deferred("add_child",new_blip)
			scan.play()
		await get_tree().create_timer(6).timeout 
		can_sing = true
		is_singing = false
		
func aggro(target:CharacterBody2D,delta):
	direction = (target.global_position - global_position).angle()
	if not launched:
		rotation = lerp_angle(rotation, direction,delta*turn_speed)
		if abs(wrapf(direction - rotation, -PI, PI)) < align_thresh:
			launched = true
	else:
		rotation = lerp_angle(rotation, direction, delta * tracking_strength)
		if timer.time_left <= 0:
			timer.start(1)
		else:
			print(timer.time_left)
	var current_direction = Vector2.RIGHT.rotated(rotation)
	velocity = (current_direction*SPEED)
	
func respawn():
	can_sing = true
	is_attacking = false
	rotation = spawn_rotation
	global_position = spawn_position
	
func _on_timer_timeout() -> void:
	print("idle")
	await get_tree().create_timer(1).timeout
	launched = false
	is_attacking = false
	can_sing = true

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		velocity = Vector2.ZERO
		var knockback_dir = body.global_position - global_position
		#velocity = knockback_dir * knockback_strength
		print("hit player")
		body.damage(power,knockback_strength,knockback_dir)
		await get_tree().create_timer(1).timeout
		is_attacking = false
	else:
		velocity = Vector2.ZERO
		is_attacking = false
