#define _PIXEL true;
extern Image fade;
extern float fade_percent;
extern vec4 fade_color;
vec4 effect(vec4 color, Image texture, vec2 uv, vec2 screen_coords)
{
    // Select the pixel from the image that matches where we are on the screen.
	vec4 color2 = Texel(fade, uv);

    // Todo, rewrite using below
    #ifdef _PIXEL
        if (color2.r > fade_percent) { 
            return Texel(texture, uv) * color;
        } else {
            return fade_color;
        }
    #endif

    #ifdef _SMOOTH
    /*Smooth Shading / EntranceJew#6969J*/
        vec4 return_color = mix(fade_color, Texel(texture, uv) * color, clamp(color2.r + fade_percent, 0.0, 1.0));
        return return_color;
    #endif

}
/* MIT LICENSE / SYSL 2021 */