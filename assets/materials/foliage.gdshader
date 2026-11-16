shader_type spatial;
render_mode cull_disabled;
uniform vec4 leaf_color : source_color = vec4(0.17, 0.47, 0.25, 1.0);
void vertex() {
    vec3 world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    float sway = sin(TIME * 1.15 + world.x * 0.63 + world.z * 0.48);
    VERTEX.x += sway * 0.045 * COLOR.a;
    VERTEX.z += cos(TIME * 0.85 + world.z * 0.5) * 0.025 * COLOR.a;
}
void fragment() { ALBEDO = leaf_color.rgb * COLOR.rgb; ROUGHNESS = 0.94; SPECULAR = 0.15; }
