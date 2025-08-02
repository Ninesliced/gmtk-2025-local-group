shader_type canvas_item;

uniform sampler2D ground_cols;
uniform int number_of_ground_cols = 4;
uniform sampler2D screen_texture: hint_screen_texture, repeat_disable;

uniform vec3 color_fill : source_color;
uniform float force: hint_range(0,1.0);

void vertex() {
}

bool match_color(vec3 color, vec3 target_color) {
	return distance(color, target_color) < 0.01;
}

void fragment() {
	COLOR = texture(screen_texture, SCREEN_UV);

	int ground_index = 0;

	for (int i = 0;  i < number_of_ground_cols; i++) {
		vec3 ground_col_i = texelFetch(ground_cols, ivec2(0, i), 0).rgb;
		ground_index += int(match_color(COLOR.rgb, ground_col_i)) * i;
	}

	vec3 new_ground_col = texelFetch(ground_cols, ivec2(1, ground_index), 0).rgb;
	vec3 new_wall_col = texelFetch(ground_cols, ivec2(0, ground_index), 0).rgb;
	vec3 new_wall2_col = texelFetch(ground_cols,ivec2(2, ground_index), 0).rgb;

	bool is_wall = match_color(COLOR.rgb, new_wall_col);

	vec4 downPixel = texture(screen_texture,vec2(SCREEN_UV.x, SCREEN_UV.y + SCREEN_PIXEL_SIZE.y * 20.0));

	bool is_down_ground = match_color(downPixel.rgb, new_ground_col);

	if (is_wall && (is_down_ground)) {
		COLOR.rgb = mix(COLOR.rgb, new_wall2_col, 1.0);
	}

	vec4 downPixel2 = texture(screen_texture,vec2(SCREEN_UV.x, SCREEN_UV.y + SCREEN_PIXEL_SIZE.y * 2.0));

	COLOR.rgb = mix(COLOR.rgb, new_wall2_col, 1.0 - downPixel2.a);

	vec4 s_color = texture(screen_texture, SCREEN_UV);
	COLOR.rgb = mix(COLOR.rgb, color_fill, force);
}
