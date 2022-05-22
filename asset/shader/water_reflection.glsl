extern float dt;
extern float spr_size;
vec4 effect(vec4 color, Image texture, vec2 uv, vec2 screen_coords)
{
	uv.x = uv.x + sin(uv.y * 32.0 + dt) * (0.020 * spr_size);
	float reflection_transparency = 0.7;
	return Texel(texture, uv) * color * vec4(1,1,1,reflection_transparency);
}
/* Water Reflection Shader / MIT */