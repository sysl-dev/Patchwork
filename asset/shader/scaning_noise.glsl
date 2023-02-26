 // Created by Sheepolution -> Permission to use: "Ehm... not really. Just use it :) No need to credit me or anything."
 // https://love2d.org/forums/viewtopic.php?t=3733&start=290#p201412 
  extern number scan_y; // 0.0 - 0.1
  extern number scan_height; // Default 0.05 
  extern number scan_light; // default 1.5
  extern number scan_rnd;

  float rand(vec2 co, float v) {
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453 * v);
  }
  
  vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
  {
    vec4 finTex = Texel(texture, texture_coords);
    vec2 np = vec2(0.0,0.0);
    float a, b;

    if (texture_coords.y > scan_y && texture_coords.y < scan_y + scan_height) {
			finTex.r -= -scan_light + 1.0 + rand(texture_coords, scan_rnd);
			finTex.g -= -scan_light + 1.0 + rand(texture_coords, scan_rnd);
      finTex.b -= -scan_light + 1.0 + rand(texture_coords, scan_rnd);
		}

    return finTex * color;
  }