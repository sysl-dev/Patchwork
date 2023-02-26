//Public domain:
//Created By 2017 by Matthias Richter <vrld@vrld.org>
//Modified by Systemlogoff
//system.shaders.pixelate:send("size",{math.floor(math.sin(next) * 24), math.floor(math.sin(next) * 24)})
    extern vec2 size;
    extern vec2 screen_size;
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
    {
      vec4 c = Texel(texture, texture_coords);
      float feedback = 0.0;
      // average pixel color over 5 samples
      vec2 scale = screen_size / size;
      texture_coords = floor(texture_coords * scale + vec2(0.5));
      vec4 meanc = Texel(texture, texture_coords/scale);
      return color * mix(1.0*meanc, c, feedback);
    }