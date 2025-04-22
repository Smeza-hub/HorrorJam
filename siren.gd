extends CharacterBody2D
@export var blip: PackedScene
@export var blip_count:int = 1
@export_range(0,360) var arc: float = 0

@export var SPEED = 300.0
@export var ACCELERATION: int


var is_idle:bool
var is_attacking:bool
var can_sing:bool
func _ready() -> void:
	can_sing = true
func _physics_process(delta: float) -> void:
	move_and_slide()
	sing(delta)
	
func sing(delta):
	
	if can_sing:
		print("singing")
		can_sing = false
		for i in blip_count:
			var new_blip = blip.instantiate()
			new_blip.position = global_position
			var arc_rad = deg_to_rad(arc)
			var increment = arc_rad / (blip_count-1)
			new_blip.global_rotation = (
				global_rotation +
				increment*i -
				arc_rad/2
			)
			get_tree().root.call_deferred("add_child",new_blip)
		await get_tree().create_timer(1.6).timeout 
		print("done singing")
		can_sing = true
