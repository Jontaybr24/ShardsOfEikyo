shader_type canvas_item;

uniform float transparency = .5;
uniform vec4 tint = vec4(1.0);

void fragment() {
	vec4 center = texture(TEXTURE, UV);
	if (center.a != 0.0) {
		COLOR = vec4(center.rgb * tint.rgb, transparency);
		}
	else {		
		COLOR = vec4(center.rgb, 0);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
