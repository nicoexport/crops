shader_type spatial;

uniform vec4[5] colors: source_color;

uniform int irrigation_level;

void vertex() {
}

void fragment() {
	int irrigation = clamp(irrigation_level - 1, 0, 4);
	ALBEDO = colors[irrigation].xyz;
}

