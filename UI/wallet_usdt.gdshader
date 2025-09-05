shader_type canvas_item;

// --- визуальные параметры
uniform vec4 color_a : source_color = vec4(0.031, 0.094, 0.302, 1.0);
uniform vec4 color_b : source_color = vec4(0.984, 0.8, 0.937, 1.0);
uniform float scale : hint_range(0.1, 10.0, 0.1) = 6.7;
uniform float speed : hint_range(0.0, 5.0, 0.01) = 0.38;
uniform float contrast : hint_range(0.1, 3.0, 0.01) = 0.48;
uniform float brightness : hint_range(-1.0, 1.0, 0.01) = -0.9;

// --- фрактальные параметры
uniform int octaves : hint_range(1, 6) = 1;
uniform float lacunarity : hint_range(1.0, 4.0, 0.1) = 2.0;
uniform float gain : hint_range(0.1, 1.0, 0.01) = 0.5;

// --- смешивание с текстурой
uniform bool use_texture = false;
uniform float texture_mix : hint_range(0.0, 1.0, 0.01) = 0.5;

// --- немного рандома
uniform float seed = 0.0;
uniform vec2 offset = vec2(0.0);

// --- вспомогательные функции
float hash21(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7)) + seed) * 43758.5453123);
}

float noise2d(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);

    float a = hash21(i + vec2(0.0, 0.0));
    float b = hash21(i + vec2(1.0, 0.0));
    float c = hash21(i + vec2(0.0, 1.0));
    float d = hash21(i + vec2(1.0, 1.0));

    float x1 = mix(a, b, u.x);
    float x2 = mix(c, d, u.x);
    return mix(x1, x2, u.y);
}

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 1.0;
    float frequency = 1.0;
    for (int i = 0; i < 6; i++) {
        if (i >= octaves) break;
        value += amplitude * noise2d(p * frequency);
        frequency *= lacunarity;
        amplitude *= gain;
    }
    return clamp(value, 0.0, 1.0);
}

void fragment() {
    vec2 uv = UV;
    vec2 centered = (uv - vec2(0.5)) * scale + offset;

    vec2 tmove = vec2(TIME * speed, TIME * speed * 0.6);
    float n = fbm(centered + tmove);
    float n2 = fbm((centered * 2.4) - tmove * 1.7) * 0.5;
    float v = clamp(n + n2, 0.0, 1.0);

    v = pow(v, 1.0 / max(0.0001, contrast));
    v += brightness;

    vec3 col = mix(color_a.rgb, color_b.rgb, v);
    vec4 final_color = vec4(col, 1.0);

    if (use_texture) {
        vec4 base = texture(TEXTURE, UV);
        final_color = mix(final_color, base, texture_mix);
    }

    COLOR = final_color;
}
