shader_type canvas_item;

uniform vec4 color: source_color;
uniform float force: hint_range(0,1.0);
uniform sampler2D screen_texture: hint_screen_texture, repeat_disable;

void fragment() {
	vec4 s_color = texture(screen_texture, SCREEN_UV);
	COLOR = s_color;
}
