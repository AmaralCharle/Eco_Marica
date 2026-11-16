shader_type spatial;
render_mode unshaded,cull_disabled;
uniform float rain_amount = 0.0;
varying float age;
void vertex() {
    vec3 world = (MODEL_MATRIX*vec4(VERTEX,1.0)).xyz;
    age = fract(TIME*1.4+world.x*0.17+world.z*0.31);
    VERTEX.xz *= 0.2+age*1.2;
}
void fragment() {
    ALBEDO = vec3(0.56,0.68,0.71);
    ALPHA = (1.0-age)*rain_amount*0.38;
}
