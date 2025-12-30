shader_type canvas_item;

// Shader that makes bright green (chroma key) pixels transparent
// Used for sprites with green screen backgrounds

uniform float tolerance : hint_range(0.0, 1.0) = 0.3;
uniform vec3 key_color : source_color = vec3(0.0, 1.0, 0.0);

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);

	// Calculate distance from key color
	float dist = distance(tex_color.rgb, key_color);

	// If close to key color, make transparent
	if (dist < tolerance) {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	} else {
		COLOR = tex_color;
	}
}
