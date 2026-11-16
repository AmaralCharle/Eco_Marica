shader_type spatial;
uniform vec4 tint : source_color = vec4(0.12,0.30,0.34,1.0);
void fragment() {
    float sky = smoothstep(0.10,0.95,1.0-UV.y);
    float reflection = 1.0-smoothstep(0.015,0.045,abs(UV.x+UV.y*0.55-0.58));
    ALBEDO = mix(tint.rgb,vec3(0.34,0.52,0.54),sky*0.38)+reflection*0.07;
    ROUGHNESS = 0.23;
    SPECULAR = 0.50;
    METALLIC = 0.12;
}
