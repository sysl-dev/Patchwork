extern number timer;
	vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
	{
		vec2 pixel_position = texture_coords;
		vec2 p = vec2(floor(gl_FragCoord.x), floor(gl_FragCoord.y));
		float direction = 2.0 * (float(mod(p.y, 2.0) == 0.0)) + -1.0;
		float pixel_altx = sin(pixel_position.y * 8.0 + timer) * 0.04;
		float pixel_alty = sin(pixel_position.x * 8.0 + timer) * 0.04;
		pixel_position.x = pixel_position.x + (pixel_altx * direction);
		pixel_position.y = pixel_position.y + (pixel_alty * direction);
		return Texel(texture, pixel_position) * color;
		}