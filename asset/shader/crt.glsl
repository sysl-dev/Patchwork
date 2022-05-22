extern float distort;
extern float x_distort;
extern float y_distort;

vec4 effect(vec4 color, Image texture, vec2 uv, vec2 screen_coords)
{
    vec2 center_dot = vec2((uv.x - 0.5), (uv.y - 0.5));
    float distort_apply = dot(center_dot, center_dot) * distort;
    // Note, can change 1.0 in uv.x or y to lower the effect and do a rolling background effect.
    uv.x = (uv.x - center_dot.x * (x_distort + distort_apply) * distort_apply);
    uv.y = (uv.y - center_dot.y * (y_distort + distort_apply) * distort_apply);

	return Texel(texture, uv) * color;
}
/* CRT/ReverseCRT Shader / MIT */