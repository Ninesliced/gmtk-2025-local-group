shader_type canvas_item;

uniform sampler2D noise_texture : repeat_enable;
uniform sampler2D gradiant_texture : repeat_disable;
uniform sampler2D color_texture : repeat_disable;
const float speed = 0.8;
const float rate = 10.0;
void fragment() {
	vec4 noise_val = texture(noise_texture, vec2(UV.x+float(int(TIME*rate))/(rate*speed)), UV.y);
	vec4 gradiant_color = texture(gradiant_texture, UV);
	vec4 new_color = mix(noise_val, gradiant_color, 0.8);
	COLOR = vec4(new_color.rgb, float(COLOR.r > 0.5) * COLOR.a);
	COLOR = texture(color_texture, vec2(COLOR.r));


}
