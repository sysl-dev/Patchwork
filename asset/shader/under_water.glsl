    //under_water:send("intensity", 0.05)
    //under_water:send("speed", 4.0)
    //under_water:send("time", love.timer.getTime())
    //under_water:send("border_color", {0.0, 0.3, 0.5, 1.0}) 
    //under_water:send("border_width", 0.1) -- 10% of the screen width
    
    uniform float time;
    uniform float intensity;
    uniform float speed;
    uniform vec4 border_color;
    uniform float border_width;
    vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
    {
        float t = time * speed;
        float x = (texture_coords.x - 0.5) * (1.0 + intensity * sin(t)) + 0.5;
        float y = (texture_coords.y - 0.5) * (1.0 + intensity * cos(t)) + 0.5;
        vec4 texturecolor = Texel(tex, vec2(x, y));
        float border_distance = min(texture_coords.x, 1.0 - texture_coords.x);
        border_distance = min(border_distance, min(texture_coords.y, 1.0 - texture_coords.y));
        if (border_distance < border_width) {
            return mix(texturecolor, border_color, smoothstep(border_width, 0.0, border_distance)) * color;
        }
        return texturecolor * color;
    }