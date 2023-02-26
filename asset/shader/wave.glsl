extern number timer;
	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
	{
		vec2 pixel_position = texture_coords;
		pixel_position.x = pixel_position.x + sin(pixel_position.y * 8.0 + timer) * 0.04;
		return Texel(texture, pixel_position) * color;
	}