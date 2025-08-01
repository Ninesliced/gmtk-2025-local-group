shader_type canvas_item;

uniform sampler2D dissolve_texture : source_color;
uniform float v : hint_range(0,1);
uniform float burn_size: hint_range(0.0, 1.0, 0.01);
uniform vec4 burn_color: source_color;

void fragment(){
    vec4 main_texture = texture(TEXTURE, UV);
    vec4 noise_texture = texture(dissolve_texture, vec2(UV.x*8.0,UV.y));
	COLOR = mix(main_texture, burn_color, float(noise_texture.r > v));
	COLOR = mix(COLOR, vec4(0.0), float(noise_texture.r > v + burn_size));

}