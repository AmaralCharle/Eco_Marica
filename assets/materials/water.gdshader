shader_type spatial;
render_mode cull_disabled;
uniform vec4 shallow_color : source_color = vec4(0.28,0.65,0.58,1.0);
uniform vec4 deep_color : source_color = vec4(0.08,0.36,0.42,1.0);
uniform float half_width = 8.0;
uniform float center_x = 0.0;
uniform float flow_speed = 0.35;
uniform float shore_strength = 0.28;
varying vec3 world;
void vertex() {
    world = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz;
    // Movimento de superfície apenas; sem deslocar barco ou colisões.
    VERTEX.y += sin(world.x*1.7 + world.z*0.55 + TIME*flow_speed)*0.012;
}
void fragment() {
    float t = TIME*flow_speed;
    float wave = sin(world.x*1.7+world.z*0.55+t);
    float cross_wave = sin(world.z*2.3-world.x*0.85-t*1.15);
    float detail = sin(world.z*6.2+world.x*3.8+t*0.7+cross_wave*0.65);
    float shore_width = clamp(half_width*0.22,0.18,1.6);
    float edge = smoothstep(half_width-shore_width,half_width,abs(world.x-center_x));
    float glint = smoothstep(0.72,0.99,0.50*wave+0.32*cross_wave+0.18*detail);
    vec3 n_world = normalize(vec3(-cos(world.x*1.7+world.z*0.55+t)*0.075,1.0,-cos(world.z*2.3-world.x*0.85-t*1.15)*0.065));
    NORMAL = normalize(mat3(VIEW_MATRIX)*n_world);
    float fresnel = pow(1.0-max(dot(normalize(-VERTEX),NORMAL),0.0),3.0);
    vec3 color = mix(deep_color.rgb,shallow_color.rgb,0.32+wave*0.08+cross_wave*0.05+edge*shore_strength);
    color = mix(color,vec3(0.43,0.68,0.72),fresnel*0.30);
    color += vec3(0.23,0.28,0.22)*glint*0.48;
    float foam = edge*smoothstep(0.55,0.94,detail*0.4+cross_wave*0.6);
    ALBEDO = mix(color,vec3(0.73,0.85,0.75),foam*0.24);
    ROUGHNESS = 0.25;
    METALLIC = 0.0;
    SPECULAR = 0.48;
}
