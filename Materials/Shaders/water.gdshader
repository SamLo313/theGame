shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled;

// Color Uniforms
uniform vec4 deep_color : source_color = vec4(0.12, 0.43, 0.66, 0.72);
uniform vec4 shallow_color : source_color = vec4(0.31, 0.76, 0.85, 0.90);
uniform vec4 foam_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Reflection Settings
uniform sampler2D reflection_texture : hint_default_black, filter_linear_mipmap;
uniform float reflection_strength : hint_range(0.0, 1.0) = 0.35;
uniform float reflection_distortion : hint_range(0.0, 0.05) = 0.008;

// Wave & Glitter Settings
uniform sampler2D water_noise : hint_default_white, repeat_enable;
uniform float wave_scale = 0.034;
uniform vec2 wave_speed = vec2(0.006, 0.004);
uniform float color_steps = 3.0;

// Foam & Depth Settings
uniform float foam_depth = 0.6;
uniform sampler2D depth_texture : hint_depth_texture, filter_linear_mipmap;

// Utility function to quantize values into stepped bands
float quantize(float value, float levels) {
	float clamped = clamp(value, 0.0, 1.0);
	return floor(clamped * levels) / max(levels - 1.0, 1.0);
}

// Calculate animated noise waves
float wave_height(vec2 world_pos_xz, float time) {
	vec2 uvw = world_pos_xz * wave_scale;
	float n1 = texture(water_noise, uvw + time * wave_speed).r;
	float n2 = texture(water_noise, uvw * 1.9 - time * wave_speed * 0.7 + vec2(0.27, 0.61)).r;
	return n1 * 0.6 + n2 * 0.4;
}

void fragment() {
	// 1. World Position calculation for seamless tiling across meshes
	vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	// 2. Base Water Color (Quantized Noise)
	float waves = wave_height(world_pos.xz, TIME);
	float banded = quantize(waves, color_steps);
	vec3 col = mix(deep_color.rgb, shallow_color.rgb, banded);

	// 3. Planar Reflections (Inverted Y coordinate)
	vec2 refl_uv = vec2(SCREEN_UV.x, 1.0 - SCREEN_UV.y);
	
	// Add wave distortion
	refl_uv += (waves - 0.5) * reflection_distortion;
	vec3 reflection_col = texture(reflection_texture, refl_uv).rgb;
	
	// Mix reflection into base water color before glints and foam
	col = mix(col, reflection_col, reflection_strength);

	// 4. Glitter / Caustics Glint
	vec2 glint_uv = world_pos.xz * wave_scale * 2.3 + TIME * wave_speed * 1.6;
	float glint = texture(water_noise, glint_uv).r;
	glint = step(0.86, quantize(glint, 8.0));
	col = mix(col, foam_color.rgb, glint * 0.8);

	// 5. Edge Foam using Godot's Depth Texture
	float depth_raw = texture(depth_texture, SCREEN_UV).r;
	
	vec4 upos = INV_PROJECTION_MATRIX * vec4(SCREEN_UV * 2.0 - 1.0, depth_raw, 1.0);
	float scene_depth_z = -upos.z / upos.w;
	float fragment_depth_z = -VERTEX.z;
	
	float depth_delta = scene_depth_z - fragment_depth_z;

	vec2 foam_uv = world_pos.xz * 0.15 + TIME * wave_speed * 3.0;
	float foam_noise = texture(water_noise, foam_uv).r;
	float threshold = foam_depth * (0.6 + 0.5 * foam_noise);
	
	float foam = 1.0 - smoothstep(0.0, threshold, depth_delta);
	
	float foam_band = quantize(foam, 3.0);
	col = mix(col, foam_color.rgb, foam_band);

	// Output
	ALBEDO = col;
	ALPHA = mix(deep_color.a, shallow_color.a, foam_band);
	ROUGHNESS = 0.1;
	SPECULAR = 0.2;
}