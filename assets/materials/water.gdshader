shader_type spatial;
render_mode cull_disabled;
uniform vec4 shallow_color : source_color = vec4(0.20, 0.57, 0.54, 1.0);
uniform vec4 deep_color : source_color = vec4(0.065, 0.29, 0.36, 1.0);
uniform float half_width = 8.0;
uniform float center_x = 0.0;
uniform float flow_speed = 0.35;
uniform float shore_strength = 0.24;
varying vec3 world;
void vertex() { world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
    float t = TIME * flow_speed;
    float wave = sin(world.x * 0.85 + world.z * 0.40 + t);
    float fine = sin(world.z * 3.2 - world.x * 0.6 - t * 1.6 + wave * 0.55);
    float edge = smoothstep(half_width - 1.3, half_width, abs(world.x - center_x));
    float glint = smoothstep(0.93, 1.0, fine) * (0.4 + 0.6 * wave);
    ALBEDO = mix(deep_color.rgb, shallow_color.rgb, 0.32 + 0.24 * wave + edge * shore_strength);
    ALBEDO += vec3(0.13, 0.18, 0.16) * glint * 0.36;
    ALBEDO = mix(ALBEDO, vec3(0.72, 0.82, 0.69), edge * smoothstep(0.74, 1.0, fine) * 0.24);
    vec3 n_world = normalize(vec3(-cos(world.x * 0.85 + world.z * 0.4 + t) * 0.045, 1.0, -cos(world.z * 3.2 - t * 1.6 + wave * 0.55) * 0.035));
    NORMAL = normalize(mat3(VIEW_MATRIX) * n_world);
    ROUGHNESS = 0.38;
    METALLIC = 0.0;
    SPECULAR = 0.32;
}
