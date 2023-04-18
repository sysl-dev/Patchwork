    //local color_palette = Utilities.color.palette.create("asset/texture/system/palette/vanilla-milkshake-8x.png", 8)
    //color_limited_shader:send("color_palette", unpack(color_palette))
    //color_limited_shader:send("palette_size", 4)
    //Pixelscreen.shader_push(color_limited_shader)
    uniform vec3 color_palette[4];  // Set to size of palette
    uniform int palette_size; // Send matching
    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
    {
        vec4 texturecolor = Texel(tex, texture_coords);
        vec3 final_color = color_palette[0]; // Default black if no color found
        float min_diff = length(texturecolor.rgb - color_palette[0]);
        for(int i = 1; i < palette_size; i++)
        {
            float diff = length(texturecolor.rgb - color_palette[i]);
            if(diff < min_diff)
            {
                min_diff = diff;
                final_color = color_palette[i];
            }
        }
        return vec4(final_color, texturecolor.a) * color;
    }