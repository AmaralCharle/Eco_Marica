shader_type spatial;
render_mode cull_disabled;
uniform vec4 leaf_color : source_color = vec4(0.17, 0.47, 0.25, 1.0);
void vertex() {
    vec3 world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    VERTEX.x += sin(TIME * 1.3 + world.x * 0.6 + world.z * 0.4) * 0.035 * max(VERTEX.y, 0.0);
}
void fragment() { ALBEDO = leaf_color.rgb; ROUGHNESS = 0.95; }
