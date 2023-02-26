 // Created by Sheepolution -> Permission to use: "Ehm... not really. Just use it :) No need to credit me or anything."
 // https://love2d.org/forums/viewtopic.php?t=3733&start=290#p201412

  extern number power;

  vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
  {
    vec2 rgb_dir_r = vec2(1,0);
    vec2 rgb_dir_g = vec2(0,1);
    vec2 rgb_dir_b = vec2(-1,-1);
    vec4 finTex = Texel(texture, texture_coords);
    vec2 np = vec2(0,0);
    float a, b;

    a = 0.0025 * power;
    finTex.r = 	texture2D(texture, vec2(texture_coords.x + a * rgb_dir_r[0], texture_coords.y + a * rgb_dir_r[1])).r;
    finTex.g = texture2D(texture, vec2(texture_coords.x + a * rgb_dir_g[0], texture_coords.y + a * rgb_dir_g[1])).g;
    finTex.b = 	texture2D(texture, vec2(texture_coords.x + a * rgb_dir_b[0], texture_coords.y + a * rgb_dir_b[1])).b;

    return finTex * color;
  }