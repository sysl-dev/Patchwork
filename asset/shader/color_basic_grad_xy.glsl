      vec4 effect(vec4 color, Image texture, vec2 uv, vec2 screen_coords)
      {
        vec4 color1 = vec4(0.0,0.0,0.0,1.0);
        vec4 color2 = vec4(1.1,1.1,1.1,1.0);
        vec2 altux = uv;

        float max_color_count = 16.0;
        altux.x = altux.x * max_color_count;
        float final_mix1 = floor(altux.x) / max_color_count;

        altux.y = altux.y * max_color_count;
        float final_mix2 = floor(altux.y) / max_color_count;

        float final_mix = mix(final_mix1, final_mix2, 0.5);

        vec4 fcolor = mix(color1,color2,min(1.0, final_mix));

        return Texel(texture, uv) * mix(fcolor,color,0.75);
      }  