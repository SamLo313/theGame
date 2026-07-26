shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_disabled, shadows_disabled;

// Cloud appearance
uniform sampler2D noise_texture : filter_linear, repeat_enable;
uniform vec2 cloud_speed = vec2(0.02, 0.01);
uniform float cloud_scale = 2.0;
uniform float cloud_density = 0.5;
uniform float cloud_softness = 0.1;

// Shadow Control & Quantization
uniform float shadow_strength : hint_range(0.0, 1.0) = 0.7;
uniform float shadow_levels : hint_range(2.0, 16.0, 1.0) = 4.0; // Number of distinct shadow darkness steps
uniform bool enable_shadow_quantization = true;

// Cloud visual properties
uniform vec3 cloud_color : source_color = vec3(0.9, 0.9, 0.95);
uniform float cloud_opacity = 0.85;

varying vec3 world_pos;

// Quantization function
float quantize(float value, float levels) {
	float clamped = clamp(value, 0.0, 1.0);
	return floor(clamped * levels) / max(levels - 1.0, 1.0);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// Use world position (XZ plane) instead of UVs for global noise
	vec2 uv = fract(world_pos.xz * cloud_scale + TIME * cloud_speed);
	
	// Sample noise texture
	float noise = texture(noise_texture, uv).r;
	
	// Base density threshold
	float cloud_mask = smoothstep(cloud_density - cloud_softness, cloud_density + cloud_softness, noise);
	
	// Set albedo and alpha
	ALBEDO = cloud_color;
	ALPHA = cloud_mask * cloud_opacity;
	
	// Darken cloud interior slightly
	EMISSION = cloud_color * 0.3 * cloud_mask;
	
	ROUGHNESS = 1.0;
	METALLIC = 0.0;
	
	ALPHA_SCISSOR_THRESHOLD = 0.1;
}

void light() {
	// Sample noise based on world position for consistent shadows
	vec2 uv = fract(world_pos.xz * cloud_scale + TIME * cloud_speed);
	float noise = texture(noise_texture, uv).r;
	float cloud_mask = smoothstep(cloud_density - cloud_softness, cloud_density + cloud_softness, noise);
	
	// Calculate base shadow reduction factor (0.0 = full shadow, 1.0 = fully lit)
	float raw_shadow_factor = cloud_mask * shadow_strength;
	
	// Quantize ONLY the shadow strength factor
	float final_shadow_factor = enable_shadow_quantization ? 
		quantize(raw_shadow_factor, shadow_levels) : raw_shadow_factor;
	
	// Apply quantized shadow darkness to lighting
	float light_factor = 1.0 - final_shadow_factor;
	DIFFUSE_LIGHT = LIGHT_COLOR * ATTENUATION * light_factor * max(0.0, dot(NORMAL, LIGHT));
}