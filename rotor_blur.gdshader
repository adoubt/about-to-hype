shader_type spatial;

uniform float blur_intensity : hint_range(0.0, 1.0) = 0.5;
uniform vec4 tint_color : source_color = vec4(1.0, 1.0, 1.0, 0.1);

void fragment() {
    float dist = length(UV - vec2(0.5));
    float blur = smoothstep(blur_intensity, 0.5, dist);
    ALBEDO = tint_color.rgb;
    ALPHA = tint_color.a * blur;
}
