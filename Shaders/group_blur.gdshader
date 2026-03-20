shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float blur_size = 2.0;
uniform int samples = 5;

void fragment() {
    vec2 texel = vec2(1.0 / float(textureSize(screen_texture, 0).x), 0.0) * blur_size;
    vec4 sum = texture(screen_texture, SCREEN_UV); // center pixel
    float count = 1.0;

    for (int i = 1; i <= samples; i++) {
        sum += texture(screen_texture, SCREEN_UV + vec2(texel.x * float(i), 0.0));
        sum += texture(screen_texture, SCREEN_UV - vec2(texel.x * float(i), 0.0));
        count += 2.0;
    }
	sum /= count;
	COLOR = sum;
}
