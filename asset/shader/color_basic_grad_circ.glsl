      vec4 effect(vec4 color, Image texture, vec2 uv, vec2 screen_coords)
      {
        vec4 color2 = vec4(1.0,0.0,0.0,1.0);
        vec4 color1 = vec4(0.0,1.0,0.0,1.0);

        // center 
        vec2 centeruv = uv;
        centeruv.x = centeruv.x - 0.5;
        centeruv.y = centeruv.y - 0.5;
        float color_value_z_o = length(centeruv);

        float max_color_count = 16.0;
        color_value_z_o = color_value_z_o * max_color_count;
        color_value_z_o = floor(color_value_z_o) / max_color_count;


        vec4 fcolor = mix(color1,color2,max(0.0,min(1.0, color_value_z_o)));

        return Texel(texture, uv) * mix(fcolor,color,0.0);
      }  