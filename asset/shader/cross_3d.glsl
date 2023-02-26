extern number timer;
  vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
  {
		vec2 pixel_position = texture_coords;
		vec2 p = vec2(floor(gl_FragCoord.x), floor(gl_FragCoord.y));
		float direction = 2.1 * (float(mod(p.y, 2.0) == 0.0)) + -1.0;
		float pixel_alt = sin(pixel_position.y * 8.0 + timer) * 0.04;
		pixel_position.x = pixel_position.x + (pixel_alt * direction);
		vec4 mix1 = Texel(texture, pixel_position);

		pixel_position = texture_coords;
		p = vec2(floor(gl_FragCoord.x), floor(gl_FragCoord.y));
		direction = 4.2 * (float(mod(p.y, 2.0) == 0.0)) + -1.0;
		pixel_alt = sin(pixel_position.y * 8.0 + timer + 0.2) * 0.04;
		pixel_position.x = pixel_position.x + (pixel_alt * direction);
    vec4 mix2 = Texel(texture, pixel_position);
    
    pixel_position = texture_coords;
		p = vec2(floor(gl_FragCoord.x), floor(gl_FragCoord.y));
		direction = 4.1 * (float(mod(p.y, 2.0) == 0.0)) + -1.0;
		pixel_alt = sin(pixel_position.y * 8.0 - timer + 0.1) * 0.04;
		pixel_position.x = pixel_position.x + (pixel_alt * direction);
    vec4 mix3 = Texel(texture, pixel_position);
    
    pixel_position = texture_coords;
		p = vec2(floor(gl_FragCoord.x), floor(gl_FragCoord.y));
		direction = 2.4 * (float(mod(p.y, 2.0) == 0.0)) + -1.0;
    pixel_alt = sin(pixel_position.y * 8.0 - timer + 0.3) * 0.04;
		pixel_position.x = pixel_position.x + (pixel_alt * direction);
		vec4 mix4 = Texel(texture, pixel_position);

    return (mix1 * 0.25 + mix2 * 0.25 + mix3 * 0.25 + mix4 * 0.25) * color;

  }