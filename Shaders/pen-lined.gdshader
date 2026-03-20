shader_type canvas_item;

const float red_coeff = 0.2126;
const float green_coeff = 0.7152;
const float blue_coeff = 0.0722;

// Edge intensity scaling
uniform float sensitivity = 0.03;
uniform float Sobel_sensitivity = 0.15;
uniform float Strength = 1.0;

uniform sampler2D NOISE_TEXTURE;
uniform sampler2D PAPER_TEXTURE;

float lumin(vec4 c) {
    return c.r * red_coeff + c.g * green_coeff + c.b * blue_coeff;
}

bool transparent_neighbor(vec4 p){
	if (p.a == 0.0) return true;
	return false;
}


void fragment() {
	vec4 center = texture(TEXTURE, UV);

    // Offsets for neighbors
    vec2 px = TEXTURE_PIXEL_SIZE; // 1 pixel in UV coordinates

    float t = lumin(texture(TEXTURE, UV + vec2(0.0, -px.y)));    // top
    float l  = lumin(texture(TEXTURE, UV + vec2(-px.x, 0.0)));   // left
    float c  = lumin(texture(TEXTURE, UV));                      // center
    float r  = lumin(texture(TEXTURE, UV + vec2(px.x, 0.0)));    // right
    float b  = lumin(texture(TEXTURE, UV + vec2(0.0, px.y)));    // bottom
    float tl = lumin(texture(TEXTURE, UV + vec2(-px.x, -px.y))); // top left
    float tr = lumin(texture(TEXTURE, UV + vec2(px.x, -px.y)));  // top right
    float bl = lumin(texture(TEXTURE, UV + vec2(-px.x, px.y)));  // bottom left
    float br = lumin(texture(TEXTURE, UV + vec2(px.x, px.y)));   // bottom right

	//float Dx = r - l;
	//float Dy = t - b;
	float sX = tl + 2.0 * l + bl - tr - 2.0 * r - br;
	float sY = tl + 2.0 * t + tr - bl - 2.0 * b - br;
	float sobel_edge = length(vec2(sX, sY));

    //float edge = sqrt(Dx*Dx + Dy*Dy);
	float n = texture(NOISE_TEXTURE, UV*5.0).r; // tiling noise
	//float threshold = sensitivity + n*0.05;
	float sobel_threshold = Sobel_sensitivity + n*0.05;

	if(sobel_edge > sobel_threshold){
		COLOR = vec4(0, 0, 0, center.a);
	} else {
		vec4 new_color = ((vec4(c, c, c, center.a) + texture(PAPER_TEXTURE, UV)) / 2.0);
		new_color = vec4(new_color.rgb, center.a);
		COLOR = mix(center, new_color, Strength);
	}
}
