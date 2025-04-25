shader_type canvas_item;

uniform float time_speed = 1.0;
uniform float wave_amplitude = 5.0;
uniform float wave_frequency = 10.0;

void vertex() {
    // Time for animation
    float t = TIME * time_speed;

    // Apply sine wave to the vertical position (y-axis)
    // based on horizontal position (x)
    float wave = sin(UV.x * wave_frequency + t) * wave_amplitude;

    // Move vertex up/down
    VERTEX.y += wave;
}