shader_type spatial;
render_mode cull_disabled;
uniform vec4 shallow_color : source_color = vec4(0.16, 0.68, 0.69, 1.0);
uniform vec4 deep_color : source_color = vec4(0.06, 0.32, 0.46, 1.0);
varying vec3 world;
void vertex() { world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz; }
void fragment() {
    float ripple = sin(world.x * 2.2 + TIME * 0.8 + sin(world.z * 0.55)) * sin(world.z * 1.4 - TIME * 0.6);
    float foam = smoothstep(0.86, 1.0, ripple) * 0.24;
    ALBEDO = mix(deep_color.rgb, shallow_color.rgb, 0.58 + ripple * 0.15) + foam;
    ROUGHNESS = 0.3;
    METALLIC = 0.12;
    NORMAL = normalize(vec3(cos(world.x * 2.2 + TIME * 0.8) * 0.075, 1.0, sin(world.z * 1.4 - TIME * 0.6) * 0.075));
}
