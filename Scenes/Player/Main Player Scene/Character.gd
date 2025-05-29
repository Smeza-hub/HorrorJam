extends CharacterBody2D
# Signals
signal player_died
signal player_respawn

# Constants
const MAX_STAMINA: float = 5000.0
const MAX_HEALTH:float = 120.0
const ACCELERATION = 500
const ROTATION_SPEED = 2
const gravity = 10

# Node references
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
var stamina_bar: ProgressBar
var health_bar: ProgressBar
@onready var fade: ColorRect = $Fade
@onready var bodycol: CollisionShape2D = $bodycol
@onready var headtracker: Area2D = $Sprite2D/headtracker
@onready var camera: Camera2D = $Camera2D
@onready var timer: Timer = $Timer
@onready var headlamp: PointLight2D = $Sprite2D/headtracker/Headlamp
@onready var rand = RandomNumberGenerator.new()
@onready var drowning: AudioStreamPlayer = $Drowning
@onready var death: AudioStreamPlayer = $Death
@onready var monkey: AnimatedSprite2D = $PointLight2D/AnimatedSprite2D
@onready var chargeparticle: GPUParticles2D = %chargeparticle


# Exported scenes and values
@export var blood_scene: PackedScene
@export var blip: PackedScene
@export var blip_count: int = 1
@export_range(0, 360) var arc: float = 0

# Exported tuning parameters
@export var RANDOM_SHAKE_STRENGTH: float = 10.0
@export var SHAKE_DECAY_RATE: float = 5.0
@export var has_orb = false
@export var spirit_light = false
@export var headlamp_on = false

# Movement and control
var SPEED = 100.0
var MAX_SPEED = 150
var NORMAL_SPEED = 100
var is_sprinting = false
var is_dead: bool
var is_spinning: bool
var input_locked = false
var aligned = false

# Player state
var current_respawn_point: Node2D
var current_stamina: int
var current_health: int
var scream_charge = 0
var can_scream: bool

# Environmental state
var in_air_pocket = false
var air_surface_y = 0.0
var float_speed: float = -30.0

# Visual and audio effects
var lamp_broken = false
var shaking = false
var shake_strength: float = 0.0
var monkey_shake_strength: float = 0.0
var monkey_start_position 
var starting_camera_zoom = Vector2(2.5, 2.5)
var played_death_sound = false
var fade_tween: Tween

# -- Init --
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	monkey.modulate.a = 0
	monkey_start_position = monkey.position
	chargeparticle.modulate.a =0
	can_scream = true
	in_air_pocket = false
	current_respawn_point = get_parent().get_node("Spawn")
	print(current_respawn_point)
	current_stamina = MAX_STAMINA
	current_health = MAX_HEALTH
	rand.randomize()
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, 1.0)
	camera.zoom = starting_camera_zoom


# -- Main Loop --
func _physics_process(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0, 3.0)
	velocity.y = move_toward(velocity.y, gravity, 3.0)
	handle_animation()
	get_input(delta)
	move_and_slide()
	handle_stamina(delta)
	handle_health(delta)
	handle_spin(delta)
	shake_strength = lerp(shake_strength, 0.0, SHAKE_DECAY_RATE * delta)
	monkey_shake_strength = scream_charge *3 
	monkey.position = monkey_start_position + get_monkey_offset()
	monkey.rotation = -rotation + PI

	camera.offset = get_random_offset()
	if lamp_broken:
		headlamp.lampbroken = true
	if spirit_light:
		$PointLight2D.show()
	else:
		$PointLight2D.hide()
	if shaking:
		apply_shake(3)


# -- Input --
func get_input(delta):
	if input_locked:
		return
	var target_pos = get_global_mouse_position()
	var target_angle = (target_pos - global_position).angle()
	rotation = lerp_angle(rotation, target_angle, ROTATION_SPEED * delta)

	if Input.is_action_pressed("forward"):
		if is_sprinting:
			velocity = velocity.move_toward(transform.x * MAX_SPEED, ACCELERATION * delta)
		else:
			velocity = velocity.move_toward(transform.x * SPEED, ACCELERATION * delta)

	if Input.is_action_pressed("scream"):
		if has_orb:
			if scream_charge <= 100:
				print(scream_charge)
				scream_charge += 40 * delta
				monkey.modulate.a = min(0.4,scream_charge/100)
				chargeparticle.modulate.a =min(1,scream_charge/90)
				monkey.offset = get_random_offset()
				if current_stamina > 0:
					current_stamina -= 1 * delta
				else:
					current_health -= 10 * delta
			$Camera2D.zoom = $Camera2D.zoom.move_toward(Vector2(3, 3), (($Camera2D.zoom - Vector2(3, 3)).length()/2.5)*delta)
			apply_shake(RANDOM_SHAKE_STRENGTH)

	if Input.is_action_just_released("scream"):
		if has_orb:
			print(scream_charge)
			scream(scream_charge)
			scream_charge = 0
			$Camera2D.zoom = starting_camera_zoom
			
			if fade_tween and fade_tween.is_running():
				fade_tween.kill()
			
			fade_tween = create_tween()
			fade_tween.tween_property(monkey, "modulate:a", 0.0, 0.3)
			fade_tween.parallel().tween_property(chargeparticle,"modulate:a", 0.0, 0.3)
	if Input.is_action_pressed("sprint"):
		is_sprinting = true
		$Camera2D.zoom = $Camera2D.zoom.move_toward(Vector2(2.7, 2.7), 0.01)
	if Input.is_action_just_released("sprint"):
		is_sprinting = false
		$Camera2D.zoom = $Camera2D.zoom.move_toward(starting_camera_zoom, 0.01)
# -- Animation --
func handle_animation():
	if is_dead:
		sprite_2d.pause()
		return

	var angle = rotation
	if angle < 0:
		angle += TAU
	var segment = int(snapped(angle, PI / 8) / (PI / 8)) % 16


	match segment:
		0, 8:
			switch_animation("swim_0")
		1, 7, 9, 15:
			switch_animation("swim_22")
		2, 6, 10, 14:
			switch_animation("swim_45")
		3, 5, 11, 13:
			switch_animation("swim_67")
		4, 12:
			switch_animation("swim_90")
		_:
			switch_animation("swim_0")

	match segment:
		0, 1, 15:
			sprite_2d.flip_v = false
			bodycol.rotation = deg_to_rad(73)
			headtracker.position.y = -47.5
		7, 8, 9:
			sprite_2d.flip_v = true
			bodycol.rotation = deg_to_rad(-73)
			headtracker.position.y = 20
		4, 12:
			sprite_2d.flip_v = true
			bodycol.rotation = deg_to_rad(90)
			headtracker.position = Vector2(90, -12.15)
		10, 11:
			sprite_2d.flip_h = true
			headtracker.position = Vector2(85, 0)
		13, 14:
			sprite_2d.flip_v = false
			headtracker.position = Vector2(85, -25)
		5, 6:
			sprite_2d.flip_v = true
		2, 3:
			sprite_2d.flip_v = false
			headtracker.position = Vector2(85, -25)

	if velocity.x != 0 or velocity.y != gravity:
		$Sprite2D.speed_scale = move_toward($Sprite2D.speed_scale, 2, 1)
	else:
		$Sprite2D.speed_scale = move_toward($Sprite2D.speed_scale, 1, 2)


# -- Stamina & Health --
func handle_stamina(delta):
	if !lamp_broken:
		return
	if stamina_bar:
			stamina_bar.value = current_stamina
			stamina_bar.max_value = MAX_STAMINA
	if in_air_pocket:
		recover_stamina()
		drowning.stop()
		print("airpocket")
		velocity.y = move_toward(velocity.y, 0, 3.0)
	elif is_sprinting:
		current_stamina -= 2 * delta
	else:
		current_stamina -= 2 * delta

func handle_health(delta):
	if health_bar:
		health_bar.value = current_health
	if current_stamina <= 0 and not in_air_pocket:
		current_health -= 0.1 * delta
		#if !drowning.playing:
			#drowning.play()
		
	if current_health <= 0:
		is_dead = true
		input_locked = true
		print("Emitting player_died")
		emit_signal("player_died")
		$PointLight2D.hide()
		if death.playing ||  played_death_sound:
			return
		else:
			death.play()
			played_death_sound = true
func recover_stamina():
	current_stamina = move_toward(current_stamina, MAX_STAMINA, 100)


# -- Scream --
func scream(scream_power):
	if in_air_pocket:
		return
	elif can_scream:
		for i in blip_count:
			var new_blip = blip.instantiate()
			new_blip.position = headtracker.global_position
			new_blip.position += velocity * 0.1
			new_blip.despawn_time = max(0.4, scream_power * 0.03)
			new_blip.speed = max(150, scream_charge * 2)

			var arc_rad = deg_to_rad(arc)
			var increment = arc_rad / (blip_count - 1)
			var angle = global_rotation + increment * i - arc_rad / 2
			new_blip.global_rotation = angle

			var direction = Vector2.RIGHT.rotated(angle)
			var inherited_speed = velocity.dot(direction)
			new_blip.speed = clamp(new_blip.speed + (inherited_speed / 3.5), 1, 1000000)

			get_tree().root.call_deferred("add_child", new_blip)
			$Scream.volume_db = lerp(-42, -34, clamp(scream_charge / 100.0, 0.0, 1.0))
			$Scream.play()
		can_scream = true


# -- Damage & Respawn --
func damage(damage: int, knockback_strength: int, knockback_dir := Vector2.ZERO):
	current_health -= damage
	velocity = knockback_dir.normalized() * knockback_strength
	input_locked = true
	timer.start(0.2)
	apply_shake(2)
	spawn_blood_particles(knockback_dir)
	$AudioStreamPlayer2D.play()

func spawn_blood_particles(direction: Vector2):
	var blood_instance = blood_scene.instantiate()
	blood_instance.global_position = headtracker.global_position
	blood_instance.rotation = direction.angle()
	get_tree().current_scene.add_child(blood_instance)
	blood_instance.restart()

func respawn():
	is_dead = false
	input_locked = false
	played_death_sound = false
	global_position = current_respawn_point.global_position
	print("Emitting player_respawn")
	emit_signal("player_respawn")
	current_health = MAX_HEALTH
	current_stamina = MAX_STAMINA


# -- Camera & Effects --
func apply_shake(shakepower) -> void:
	shake_strength = shakepower

func handle_spin(delta):
	if is_spinning:
		input_locked = true
		$Camera2D.ignore_rotation = false
		var angular_velocity = 5
		rotation += angular_velocity * delta
		apply_shake(RANDOM_SHAKE_STRENGTH)
	elif not is_dead:
		input_locked = false
		var cam = $Camera2D
		var target_rotation = -rotation
		cam.ignore_rotation = true

func get_random_offset() -> Vector2:
	return Vector2(
		rand.randf_range(-shake_strength, shake_strength),
		rand.randf_range(-shake_strength, shake_strength)
	)
func get_monkey_offset() -> Vector2:
	return Vector2(
		rand.randf_range(-monkey_shake_strength, monkey_shake_strength),
		rand.randf_range(-monkey_shake_strength, monkey_shake_strength)
	)


# -- Utility --
func switch_animation(animation):
	var current_frame = sprite_2d.get_frame()
	var current_progress = sprite_2d.get_frame_progress()
	sprite_2d.play(animation)
	sprite_2d.set_frame_and_progress(current_frame, current_progress)


# -- Signals --
func _on_headtracker_area_entered(area: Area2D) -> void:
	if area.is_in_group("airpocket"):
		in_air_pocket = true

func _on_headtracker_area_exited(area: Area2D) -> void:
	if area.is_in_group("airpocket"):
		in_air_pocket = false

func _on_timer_timeout():
	if not is_dead:
		input_locked = false
func showcase_sonar():
	input_locked = true
	var hold_timer = Timer.new()
	var is_holding = false
	var mouse_held_duration = 2.5  # Time to hold in seconds
