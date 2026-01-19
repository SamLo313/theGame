shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_disabled, shadows_disabled;

// Cloud appearance
uniform sampler2D noise_texture : filter_linear, repeat_enable;
uniform vec2 cloud_speed = vec2(0.02, 0.01);
uniform float cloud_scale = 2.0;
uniform float cloud_density = 0.5;
uniform float cloud_softness = 0.1;

// Shadow casting
uniform float shadow_strength = 0.7;
uniform vec3 cloud_color : source_color = vec3(0.9, 0.9, 0.95);
uniform float cloud_opacity = 0.85;

varying vec3 world_pos;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    // Use world position (XZ plane) instead of UVs for global noise
    vec2 uv = fract(world_pos.xz * cloud_scale + TIME * cloud_speed);
    
    // Sample noise texture (will tile seamlessly with repeat_enable)
    float noise = texture(noise_texture, uv).r;
    
    // Apply density threshold with soft edges
    float cloud_mask = smoothstep(cloud_density - cloud_softness, cloud_density + cloud_softness, noise);
    
    // Set albedo (cloud color) - darker for shadow casting
    ALBEDO = cloud_color;
    
    // Set alpha for transparency - clouds block light based on density
    ALPHA = cloud_mask * cloud_opacity;
    
    // Make clouds receive less light to darken them
    EMISSION = cloud_color * 0.3 * cloud_mask;
    
    ROUGHNESS = 1.0;
    METALLIC = 0.0;
    
    // This helps cast shadows
    ALPHA_SCISSOR_THRESHOLD = 0.1;
}

void light() {
    // Sample noise based on world position for consistent shadows
    vec2 uv = fract(world_pos.xz * cloud_scale + TIME * cloud_speed);
    float noise = texture(noise_texture, uv).r;
    float cloud_mask = smoothstep(cloud_density - cloud_softness, cloud_density + cloud_softness, noise);
    
    // Reduce light intensity based on cloud density
    float light_factor = 1.0 - (cloud_mask * shadow_strength);
    DIFFUSE_LIGHT = LIGHT_COLOR * ATTENUATION * light_factor * max(0.0, dot(NORMAL, LIGHT));
}