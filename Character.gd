extends CharacterBody2D
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var stamina: ProgressBar = $"../CanvasLayer2/Stamina"
@onready var health: ProgressBar = $"../CanvasLayer2/Health"
@onready var bodycol: CollisionShape2D = $bodycol
@onready var headtracker: Area2D = $Sprite2D/headtracker
@onready var camera: Camera2D = $Camera2D


@export var blip: PackedScene
@export var blip_count:int =1
@export_range(0,360) var arc: float = 0

@export var RANDOM_SHAKE_STRENGTH: float =10.0
@export var SHAKE_DECAY_RATE: float = 5.0
@onready var rand = RandomNumberGenerator.new()


const MAX_STAMINA = 10000.0
const MAX_HEALTH = 100
const SPEED = 150.0
const ACCELERATION = 500
const ROTATION_SPEED = 2
const gravity = 10

var scream_charge:int
var current_stamina:int
var current_health:int

var can_scream: bool
var in_air_pocket:bool
var air_surface_y = 0.0
var float_speed:float = -30.0

var shake_strength: float= 0.0


func _ready():
	can_scream = true
	in_air_pocket = false
	current_stamina = MAX_STAMINA
	stamina.max_value = MAX_STAMINA
	current_health = MAX_HEALTH
	
	rand.randomize()
func get_input(delta):
	var target_pos = get_global_mouse_position()
	var target_angle = (target_pos - global_position).angle()
	rotation = lerp_angle(rotation, target_angle, ROTATION_SPEED * delta)
	
	if Input.is_action_pressed("forward"):
		velocity = velocity.move_toward(transform.x * SPEED, ACCELERATION * delta)
		
		
	if Input.is_action_pressed("scream"):
		scream_charge += 1
		if current_stamina > 0:
			current_stamina -= 10
		else:
			current_health -=10
		$Camera2D.zoom = $Camera2D.zoom.move_toward(Vector2(3,3),0.01)
		apply_shake()
		
	if Input.is_action_just_released("scream"):
		scream(scream_charge)
		scream_charge =0
		#marker_2d.position = Vector2(100,100)
		$Camera2D.zoom = Vector2(2,2)
	
	
func _physics_process(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0,3.0)
	velocity.y = move_toward(velocity.y, gravity,3.0)
	handle_animation()
	get_input(delta)
	move_and_slide()
	handle_stamina()
	handle_health()
	#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	shake_strength = lerp(shake_strength, 0.0, SHAKE_DECAY_RATE * delta)
	camera.offset = get_random_offset()
	
func handle_animation():
	
	var angle = rotation
	if angle < 0:
		angle += TAU  # TAU is 2*PI in Godot
	
	
	var segment = int(floor(angle / (PI / 8)))  # 16 total segments
	match segment:
		0,8: 
			switch_animation("swim_0")
		1,7,9,15: 
			switch_animation("swim_22")
		2,6,10,14: 
			switch_animation("swim_45")
		3,5,11,13: 
			switch_animation("swim_67")
		4,12: 
			switch_animation("swim_90")
		_: 
			switch_animation("swim_0") 
	match segment:
		0,1,15:
			sprite_2d.flip_v = false
			bodycol.rotation = deg_to_rad(73)
			headtracker.position.y = -47.5
		7,8,9:
			sprite_2d.flip_v = true
			bodycol.rotation = deg_to_rad(-73)
			headtracker.position.y = 20
		4,12:
			sprite_2d.flip_v = true
			bodycol.rotation = deg_to_rad(90)
			headtracker.position = Vector2(90,-12.15)
		10,11:
			sprite_2d.flip_h = true
			headtracker.position = Vector2(85,0)
		13,14:
			sprite_2d.flip_v = false
			headtracker.position = Vector2(85,-25)
		5,6:
			sprite_2d.flip_v = true
			
		2,3:
			sprite_2d.flip_v = false
			headtracker.position = Vector2(85,-25)
			
	if velocity.x != 0 ||velocity.y != gravity:
		$Sprite2D.speed_scale = move_toward($Sprite2D.speed_scale,2,1)
	else:
		$Sprite2D.speed_scale = move_toward($Sprite2D.speed_scale,1,2)
		
func handle_stamina():
	stamina.value = current_stamina
	if in_air_pocket:
		recover_stamina()
		velocity.y = move_toward(velocity.y, 0,3.0)
	else:
		current_stamina = move_toward(current_stamina, 0 , 10)

func handle_health():
	health.value = current_health
	if current_stamina <= 0 && !in_air_pocket:
		current_health -= 1 
	pass
	

func scream(scream_power):
	if in_air_pocket:
		return
	elif can_scream:
		for i in blip_count:
			var new_blip = blip.instantiate()
			new_blip.position = global_position
			new_blip.scream_strength = scream_power
			var arc_rad = deg_to_rad(arc)
			var increment = arc_rad / (blip_count-1)
			new_blip.global_rotation = (
				global_rotation +
				increment*i -
				arc_rad/2
			)
			get_tree().root.call_deferred("add_child",new_blip)
		can_scream = true


func recover_stamina():
	current_stamina = move_toward(current_stamina, MAX_STAMINA, 100)

func switch_animation(animation):
	var current_frame = sprite_2d.get_frame()
	var current_progress = sprite_2d.get_frame_progress()
	sprite_2d.play(animation)
	sprite_2d.set_frame_and_progress(current_frame, current_progress)
func apply_shake() -> void:
	shake_strength = RANDOM_SHAKE_STRENGTH
func get_random_offset() -> Vector2:
	return Vector2(
		rand.randf_range(-shake_strength, shake_strength),
		rand.randf_range(-shake_strength, shake_strength)
	)
func _on_headtracker_area_entered(area: Area2D) -> void:
	
	if area.name == "Airpocket":
		in_air_pocket = true
	


func _on_headtracker_area_exited(area: Area2D) -> void:
	if area.name == "Airpocket":
		in_air_pocket = false
	
