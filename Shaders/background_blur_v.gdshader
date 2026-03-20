shader_type canvas_item;

uniform float blur_size = 4.0; // in pixels
uniform int samples = 5;       // number of samples on each side

void fragment() {
    vec2 texel = vec2(0.0, 1.0 / float(textureSize(TEXTURE, 0).y)) * blur_size;
    vec4 sum = texture(TEXTURE, UV); // center pixel
    float count = 1.0;

    for (int i = 1; i <= samples; i++) {
        sum += texture(TEXTURE, UV + vec2(0.0, texel.y * float(i)));
        sum += texture(TEXTURE, UV - vec2(0.0, texel.y * float(i)));
        count += 2.0;
    }

    COLOR = sum / count;
}