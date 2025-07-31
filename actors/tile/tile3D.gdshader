shader_type canvas_item;
uniform vec3 ground_col : source_color;
uniform vec3 wall_col : source_color;
uniform vec3 wall_col2 : source_color;

void vertex() {
}

void fragment() {
	bool is_black = all(equal(COLOR.rgb, vec3(0.0)));
	bool is_white = all(equal(COLOR.rgb, vec3(1.0)));

	COLOR.rgb = mix(COLOR.rgb, ground_col, float(is_black));
	COLOR.rgb = mix(COLOR.rgb, wall_col,   float(is_white));

	vec4 downPixel = texture(TEXTURE,vec2(UV.x, UV.y + TEXTURE_PIXEL_SIZE.y));
	bool is_down_black = all(equal(downPixel.rgb, vec3(0.0)));
	if (is_white && (is_down_black || downPixel.a == 0.0)) {
		COLOR.rgb = mix(COLOR.rgb, wall_col2, 1.0);
	}
}
