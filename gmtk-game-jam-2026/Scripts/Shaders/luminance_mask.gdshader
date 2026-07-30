shader_type canvas_item;

uniform float luminance_cutoff: hint_range(0.0, 1.0) = 0.0;
uniform bool invert = false;
uniform sampler2D mask_texture: repeat_enable;
uniform vec4 display_color;

void fragment() {
	vec2 pixel_size = 1.0 / TEXTURE_PIXEL_SIZE * 500.0;
	vec2 pixel_coord = UV * pixel_size;
	vec2 repeated_uv = pixel_coord / vec2(256.0, 224.0);
	
	vec4 sample_color = texture(mask_texture, repeated_uv);
	float luminance = dot(sample_color.rgb, vec3(0.2126, 0.7152, 0.0722));
	
	//Añadimos tolerancia para evitar que la textura se rompa con el suavizado
	float tolerancia = 100.0;
	float luminance_solid = floor(luminance * tolerancia) / tolerancia;
	
	//Ponemos un orden en función de la posición a las piezas con misma luminosidad
	vec2 grid_pos = floor(repeated_uv);
	float posicion_desfase = (grid_pos.x + grid_pos.y * 3.0) * 0.02;
	float final_luminance = luminance_solid + posicion_desfase;
	final_luminance = clamp(final_luminance, 0.0, 1.0);
	
	bool filter = final_luminance > luminance_cutoff;
	if (invert) {
		filter = !filter;
	}
	
	if (filter) {
		COLOR = display_color;
	} else {
		COLOR = vec4(display_color.rgb, 0.0);
	}
}
