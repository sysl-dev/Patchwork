vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
{
  vec4 final_image = Texel(texture, texture_coords);
  final_image = final_image * color;
  final_image.r = 1.0 - final_image.r;
  final_image.g = 1.0 - final_image.g;
  final_image.b = 1.0 - final_image.b;
	return final_image;
}