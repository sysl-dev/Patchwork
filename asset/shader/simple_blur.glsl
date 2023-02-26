extern number blur_value;
  vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
  {
    vec4 sample_color = vec4(0.0);
    
    // sample colors around the pixel and blend it.
    sample_color += texture2D(texture, vec2(texture_coords.x, texture_coords.y - 5.0 * blur_value)) * 0.03;
    sample_color += texture2D(texture, vec2(texture_coords.x - 4.0 * blur_value, texture_coords.y)) * 0.05;
    sample_color += texture2D(texture, vec2(texture_coords.x, texture_coords.y - 3.0 * blur_value)) * 0.09;
    sample_color += texture2D(texture, vec2(texture_coords.x - 2.0 * blur_value, texture_coords.y)) * 0.12;
    sample_color += texture2D(texture, vec2(texture_coords.x - blur_value, texture_coords.y)) * 0.15;
    sample_color += texture2D(texture, vec2(texture_coords.x, texture_coords.y)) * 0.16;
    sample_color += texture2D(texture, vec2(texture_coords.x, texture_coords.y + blur_value)) * 0.15;
    sample_color += texture2D(texture, vec2(texture_coords.x + 2.0 * blur_value, texture_coords.y)) * 0.12;
    sample_color += texture2D(texture, vec2(texture_coords.x, texture_coords.y + 3.0 * blur_value)) * 0.09;
    sample_color += texture2D(texture, vec2(texture_coords.x + 4.0 * blur_value, texture_coords.y)) * 0.05;
    sample_color += texture2D(texture, vec2(texture_coords.x, texture_coords.y + 5.0 * blur_value)) * 0.03;

    return sample_color;
  }