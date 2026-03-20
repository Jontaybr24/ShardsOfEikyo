shader_type canvas_item;

const float red_coeff = 0.2126;
const float green_coeff = 0.7152;
const float blue_coeff = 0.0722;

float lumin(vec4 c) {
    return c.r * red_coeff + c.g * green_coeff + c.b * blue_coeff;
}

float median(float a, float b, float c){	
    return max(min(a,b), min(max(a,b),c));
}

void fragment() {	
	vec4 center = texture(TEXTURE, UV);
    vec2 px = TEXTURE_PIXEL_SIZE; // 1 pixel in UV coordinates
	
    float t = lumin(texture(TEXTURE, UV + vec2(0.0, -px.y)));    // top
    float l  = lumin(texture(TEXTURE, UV + vec2(-px.x, 0.0)));   // left
    float c  = lumin(center);                                    // center
    float r  = lumin(texture(TEXTURE, UV + vec2(px.x, 0.0)));    // right
    float b  = lumin(texture(TEXTURE, UV + vec2(0.0, px.y)));    // bottom
    float tl = lumin(texture(TEXTURE, UV + vec2(-px.x, -px.y))); // top left
    float tr = lumin(texture(TEXTURE, UV + vec2(px.x, -px.y)));  // top right
    float bl = lumin(texture(TEXTURE, UV + vec2(-px.x, px.y)));  // bottom left
    float br = lumin(texture(TEXTURE, UV + vec2(px.x, px.y)));   // bottom right
	
	float m0 = median(t, tr, tl);
	float m1 = median(r, c, l);
	float m2 = median(b, br, bl);
	
	float med = median(m0, m1, m2);
	
	COLOR = vec4(med, med, med, center.a);
}
