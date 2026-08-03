shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, specular_disabled, shadows_disabled;

// ── Noise / motion ───────────────────────────────────────────────
uniform sampler2D noise_texture : filter_nearest, repeat_enable;
uniform float noise_frequency : hint_range(0.005, 1.0) = 0.05;   // world -> UV. LOWER = bigger blobs
uniform vec2 scroll_speed = vec2(0.6, 0.3);                       // world units per second

// ── Pixelation ───────────────────────────────────────────────────
uniform float cloud_pixel_size : hint_range(0.05, 4.0) = 0.5;     // world units per cloud pixel. BIGGER = CHUNKIER

// ── Posterized bands ─────────────────────────────────────────────
uniform float cloud_coverage : hint_range(0.0, 1.0) = 0.5;        // lower = more cloud
uniform float cloud_steps : hint_range(2.0, 12.0, 1.0) = 4.0;     // number of grey levels
uniform float band_darkest : hint_range(0.0, 1.0) = 0.45;         // brightness of outermost band

// ── Appearance ───────────────────────────────────────────────────
uniform vec3 cloud_color : source_color = vec3(0.9, 0.9, 0.95);
uniform float cloud_opacity : hint_range(0.0, 1.0) = 0.85;
uniform float shadow_strength : hint_range(0.0, 1.0) = 0.7;

varying vec3 world_pos;


// Snapped world-space UV. Snaps position AND scroll onto the same grid
// so clouds move in discrete pixel jumps instead of sliding sub-pixel.
vec2 cloud_uv() {
	vec2 p = world_pos.xz + TIME * scroll_speed;
	p = floor(p / cloud_pixel_size) * cloud_pixel_size;
	return p * noise_frequency;
}

// 0.0 = clear sky, otherwise a stepped density band in (0, 1]
float cloud_band(vec2 uv) {
	float n = texture(noise_texture, uv).r;
	float t = (n - cloud_coverage) / max(1.0 - cloud_coverage, 0.001);
	if (t <= 0.0) {
		return 0.0;
	}
	float s = max(cloud_steps, 2.0);
	return ceil(clamp(t, 0.0, 1.0) * s) / s;   // ceil keeps the thinnest outer band visible
}


void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float band = cloud_band(cloud_uv());

	ALBEDO = cloud_color * mix(band_darkest, 1.0, band);
	ALPHA = band > 0.0 ? cloud_opacity : 0.0;   // binary alpha = hard pixel edges, no soft fringe

	ROUGHNESS = 1.0;
	METALLIC = 0.0;

	ALPHA_SCISSOR_THRESHOLD = 0.01;
}

void light() {
	float band = cloud_band(cloud_uv());
	float shade = 1.0 - (1.0 - band) * shadow_strength;
	DIFFUSE_LIGHT += LIGHT_COLOR * ATTENUATION * shade * max(0.0, dot(NORMAL, LIGHT));
}