shader_type spatial;
render_mode blend_add, unshaded;
//,depth_draw_opaque,cull_back;
//,diffuse_burley,specular_schlick_ggx;
uniform sampler2D texture_albedo : hint_albedo;
//uniform highp vec4 albedo : hint_color;


void fragment() {
	vec2 base_uv = UV;
	//vec4 albedo_tex = texture(texture_albedo,base_uv) * albedo;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	albedo_tex *= COLOR;
	ALBEDO = albedo_tex.rgb;
	ALPHA = albedo_tex.a;
}
