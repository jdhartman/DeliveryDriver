shader_type spatial;
uniform sampler2D noise;
uniform sampler2D normalmap;
uniform float height_scale = 1.0;
uniform vec4 color : hint_color;

varying vec2 tex_position;

void vertex() {
	tex_position = VERTEX.xz / 2.0 + 0.5;
	float height = texture(noise, tex_position).x;
	VERTEX.y += height * height_scale - height_scale / 2.0;
}

void fragment() {
	NORMALMAP = texture(normalmap, tex_position).xyz;
	ALBEDO = vec3(color.x, color.y, color.z);
}