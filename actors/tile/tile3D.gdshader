shader_type canvas_item;
uniform vec3 ground_col : source_color;
uniform vec3 wall_col : source_color;
uniform vec3 wall_col2 : source_color;
uniform sampler2D screen_texture: hint_screen_texture, repeat_disable;

void vertex() {
}

void fragment() {
	COLOR = texture(screen_texture, SCREEN_UV);
	bool is_black = all(equal(COLOR.rgb, vec3(0.0)));
	bool is_white = all(equal(COLOR.rgb, vec3(1.0)));

	COLOR.rgb = mix(COLOR.rgb, ground_col, float(is_black));
	COLOR.rgb = mix(COLOR.rgb, wall_col,   float(is_white));

	vec4 downPixel = texture(screen_texture,vec2(SCREEN_UV.x, SCREEN_UV.y + SCREEN_PIXEL_SIZE.y * 1.0));
	bool is_down_black = all(equal(downPixel.rgb, vec3(0.0)));

	if (is_white && (is_down_black || downPixel.a == 0.0)) {
		COLOR.rgb = vec3(1.0 - downPixel.a);
	}
}
