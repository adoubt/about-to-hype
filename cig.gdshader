shader_type spatial;

//uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float noiseForce : hint_range(0.0, 1.0) = 0.2;
uniform sampler2D noiseTexture;
uniform vec4 burnColor : source_color = vec4(1.0, 0.3, 0.0, 1.0);
uniform float borderWidth : hint_range(0.0, 0.5) = 0.1;
uniform float direction : hint_range(0.0, 360.0) = 180.0;
uniform sampler2D albedo_texture : source_color;

uniform float burn_axis : hint_range(0.0, 2.0) = 1.0;
uniform bool cylindrical_burn = true;
uniform float ash_alpha : hint_range(0.0, 1.0) = 0.3;
uniform vec3 ash_color : source_color = vec3(0.3, 0.3, 0.3);

varying vec3 world_position;
varying vec3 local_position;

void vertex() {
    world_position = VERTEX;
    local_position = VERTEX;
}

void fragment(){
    vec4 base_color = texture(albedo_texture, UV);
    
    float burn_progress;
    
    if (cylindrical_burn) {
        burn_progress = local_position.y;
    } else {
        if (burn_axis < 0.5) {
            burn_progress = local_position.x;
        } else if (burn_axis < 1.5) {
            burn_progress = local_position.y;
        } else {
            burn_progress = local_position.z;
        }
    }
    
    burn_progress = (burn_progress + 4.0) * 0.5;
    
    float noise_sample = texture(noiseTexture, UV).r;
    float burn_line = burn_progress + (noise_sample * noiseForce);
    
	float progress = 0.5 + 0.5 * sin(TIME * 2.0);
    bool is_burned = burn_line < progress;
    bool is_border = burn_line < (progress + borderWidth);
    
    vec3 final_albedo;
    float final_alpha;
    
    if (is_burned) {
        final_albedo = ash_color;
        final_alpha = ash_alpha;
    } else if (is_border) {
        float burn_mix = (progress + borderWidth - burn_line) / borderWidth;
        final_albedo = mix(base_color.rgb, burnColor.rgb, burn_mix);
        final_alpha = 1.0;
    } else {
        final_albedo = base_color.rgb;
        final_alpha = base_color.a;
    }
    
    ALBEDO = final_albedo;
    ALPHA = final_alpha;
    
    if (is_border && !is_burned) {
        float burn_mix = (progress + borderWidth - burn_line) / borderWidth;
        EMISSION = burnColor.rgb * burn_mix * 0.5;
    }
}