extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var shader_material := $Water_TextureRect.material as ShaderMaterial
	var viewport_texture := $MaskViewport.get_texture()
	shader_material.set_shader_parameter("mask_texture", viewport_texture)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
