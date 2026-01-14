shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back;

// Texture settings
uniform sampler2D albedo_texture : source_color, hint_default_white;
uniform vec4 albedo_tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// X-ray circle settings (updated by script)
uniform vec2 player_screen_pos;
uniform vec3 player_position;
uniform vec3 camera_forward;

// Circle appearance
uniform vec2 position_adjustment = vec2(0.0);
uniform float radius : hint_range(0.0, 0.5) = 0.15;
uniform float smoothness : hint_range(0.0, 0.2) = 0.05;

// Fluid wave effect
uniform float wave_count : hint_range(2.0, 12.0) = 5.0;
uniform float wave_strength : hint_range(0.0, 0.05) = 0.02;
uniform float flow_speed : hint_range(0.0, 2.0) = 0.6;

void fragment() {
    // Get texture color
    vec4 tex_color = texture(albedo_texture, UV);
    ALBEDO = tex_color.rgb * albedo_tint.rgb;

    float aspect_ratio = VIEWPORT_SIZE.x / VIEWPORT_SIZE.y;
    vec2 correction = vec2(aspect_ratio, 1.0);
    vec2 screen_uv = FRAGCOORD.xy / VIEWPORT_SIZE.xy;
    vec2 to_center = (screen_uv - player_screen_pos + position_adjustment) * correction;
    float dist = length(to_center);
    float angle = atan(to_center.y, to_center.x);
    float time = TIME * flow_speed;

    // Seamless waves
    float wave1 = sin(angle * wave_count + time);
    float wave2 = sin(angle * (wave_count - 1.0) - time * 0.7 + 1.5);
    float wave3 = cos(angle * (wave_count + 1.0) + time * 0.9 + 3.0);

    float wave = (wave1 + wave2 * 0.6 + wave3 * 0.4) * wave_strength;
    float fluid_radius = radius + wave;
    float circle_mask = smoothstep(fluid_radius + smoothness, fluid_radius - smoothness, dist);

    vec3 to_player = normalize(player_position - NODE_POSITION_WORLD);
    float facing = dot(to_player, camera_forward);

    if (facing < 0.0) {
        ALPHA = circle_mask;
    } else {
        ALPHA = 1.0;
    }
}