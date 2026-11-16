shader_type spatial;
uniform vec4 base_color : source_color = vec4(0.42, 0.56, 0.30, 1.0);
// 0 vegetation ground, 1 soil, 2 sand, 3 paving, 4 asphalt, 5 plaster, 6 timber, 7 roof.
uniform int surface_type = 0;
uniform float wetness : hint_range(0.0, 1.0) = 0.0;
varying vec3 world;
varying vec3 world_normal;
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float noise(vec2 p) {
    vec2 i = floor(p); vec2 f = fract(p); f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1,0)), f.x), mix(hash(i + vec2(0,1)), hash(i + vec2(1,1)), f.x), f.y);
}
void vertex() {
    world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    world_normal = normalize(MODEL_NORMAL_MATRIX * NORMAL);
}
void fragment() {
    vec2 uv = world.xz;
    if (abs(world_normal.y) < 0.5) { uv = abs(world_normal.x) > 0.5 ? world.zy : world.xy; }
    float broad = noise(uv * 0.32);
    float small = noise(uv * 7.0);
    vec3 color = base_color.rgb * (0.92 + broad * 0.13 + small * 0.035);
    float rough = 0.93;
    if (surface_type == 0) {
        color *= 0.93 + noise(uv * 1.2) * 0.13;
        color = mix(color,color*vec3(1.08,0.98,0.84),smoothstep(0.64,0.84,noise(uv*0.55))*0.28);
    } else if (surface_type == 1 || surface_type == 2) {
        color *= 0.96 + small * 0.055;
        if (surface_type == 2) { color += sin(uv.y * 5.0 + broad * 4.0) * 0.008; }
        float pebble = step(0.968,hash(floor(uv*12.0)));
        color += pebble*0.028;
    } else if (surface_type == 3) {
        vec2 tile = uv * vec2(1.25, 0.82);
        tile.x += mod(floor(tile.y), 2.0) * 0.5;
        vec2 f = fract(tile);
        float edge = min(min(f.x, 1.0-f.x), min(f.y, 1.0-f.y));
        color *= 0.92 + hash(floor(tile)) * 0.14;
        color *= mix(0.78, 1.0, smoothstep(0.007, 0.025, edge));
        color += smoothstep(0.025,0.030,edge)*(1.0-smoothstep(0.030,0.040,edge))*0.012;
        rough = 0.87;
    } else if (surface_type == 4) {
        color *= 0.96 + small * 0.07;
        float puddle = smoothstep(0.60, 0.77, broad) * wetness;
        color *= 1.0 - wetness * 0.13 - puddle * 0.06;
        rough = mix(0.91, 0.36, puddle);
        color += smoothstep(0.78,0.92,small)*0.012;
    } else if (surface_type == 5) {
        color *= 0.97 + noise(uv * 2.1) * 0.055;
        rough = 0.86;
    } else if (surface_type == 6) {
        float grain = sin(uv.y * 28.0 + noise(uv * vec2(4.0, 0.7)) * 6.0);
        color *= 0.92 + grain * 0.045 + hash(vec2(floor(uv.x * 4.0), 0.0)) * 0.12;
        rough = 0.76;
    } else if (surface_type == 7) {
        vec2 tile = fract(uv * vec2(3.3, 4.0));
        color *= 0.92 + sin(tile.x * 3.14159) * 0.10;
        color *= mix(0.76, 1.0, smoothstep(0.0, 0.055, tile.y));
        rough = 0.82;
    }
    ALBEDO = color; ROUGHNESS = clamp(rough+(small-0.5)*0.06,0.2,1.0); SPECULAR = 0.22;
}
