extends CharacterBody2D
@onready var screamarea: Area2D = $screamarea
@onready var screamareacol: CollisionShape2D = $screamarea/screamareacol
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var marker_2d: Marker2D = $Marker2D
@onready var stamina: ProgressBar = $"../CanvasLayer2/Stamina"


@export var blip: PackedScene
@export var blip_count:int =1
@export_range(0,360) var arc: float = 0


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
func _ready():
	screamarea.hide()
	can_scream = true
	current_stamina = MAX_STAMINA
	stamina.max_value = MAX_STAMINA
func get_input(delta):
	var target_pos = get_global_mouse_position()
	var target_angle = (target_pos - global_position).angle()
	rotation = lerp_angle(rotation, target_angle, ROTATION_SPEED * delta)
	
	if Input.is_action_pressed("forward"):
		velocity = velocity.move_toward(transform.x * SPEED, ACCELERATION * delta)
		
		
	if Input.is_action_pressed("scream"):
		scream_charge += 1
		current_stamina -= 10
		print(scream_charge)
		print(current_stamina)
		$Camera2D.zoom = $Camera2D.zoom.move_toward(Vector2(3,3),0.01)
		
		
	if Input.is_action_just_released("scream"):
		screamarea.show()
		scream(scream_charge)
		scream_charge =0
		marker_2d.position = Vector2(100,100)
		$Camera2D.zoom = $Camera2D.zoom.move_toward(Vector2(2,2),0.05)
	elif Input.is_action_just_released("scream"):
		screamarea.hide()
	
func _physics_process(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0,3.0)
	velocity.y = move_toward(velocity.y, gravity,3.0)
	handle_animation()
	get_input(delta)
	move_and_slide()
	current_stamina -= 1
	stamina.value = current_stamina
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	
func handle_animation():
	if rotation < -1.5 || rotation > 1.5:
		$Sprite2D.flip_v = true
	else:
		$Sprite2D.flip_v = false
	if velocity.x != 0 ||velocity.y != gravity:
		$Sprite2D.speed_scale = move_toward($Sprite2D.speed_scale,2,1)
	else:
		$Sprite2D.speed_scale = move_toward($Sprite2D.speed_scale,1,2)
		
	
func scream(scream_power):
	if can_scream:
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
	
