shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec4 albedo: source_color;
uniform sampler2D texture_albedo : source_color, filter_linear_mipmap, repeat_enable;

uniform sampler2D noise;
uniform float distortion_intensity = 0.1;

uniform vec2 distortion_tiling = vec2(1.0, 1.0);
uniform vec2 distortion_offset_speed;

void vertex() {
    // Called for every vertex the material is visible on.
    UV = UV;
}

void fragment() {
    // Called for every pixel the material is visible on.
    vec2 base_uv = UV;

    vec2 noise_uv = UV * distortion_tiling + distortion_offset_speed * TIME;
    float noise_tex = texture(noise, noise_uv).r;

    vec2 distortion_uv = base_uv + noise_tex * distortion_intensity;

    vec4 albedo_tex = texture(texture_albedo, distortion_uv);
    albedo_tex = COLOR;
    ALBEDO = albedo_tex.rgb;
	//albedo.rbg
    ALPHA = albedo.a;
	//albedo_tex.a


    }

//void light() {
//    // Called for every pixel for every light affecting the CanvasItem.
//    // Uncomment to replace the default light processing function with this one.
//}