shader_type spatial;
render_mode blend_mix, diffuse_burley, specular_schlick_ggx;
//render_mode blend_mix, specular_schlick_ggx;
//,depth_draw_opaque,cull_back;
//,diffuse_burley,specular_schlick_ggx;
uniform sampler2D texture_albedo : hint_albedo;
uniform sampler2D texture_spec : hint_white;

uniform highp float metal_mult : hint_range(0,20);
uniform highp float rough_mult : hint_range(0,20);
uniform highp float spec_mult : hint_range(0,20);


void fragment() {
	//vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,UV);
	vec4 spec_tex = texture(texture_spec,UV);
	ALBEDO = albedo_tex.rgb;
	//ALBEDO = vec3(0.5, 0.5, 0.5);
	//ROUGHNESS = spec_tex.r * rough_mult;
	float spec = spec_tex.r * rough_mult;
	ROUGHNESS = 1.0 - spec;
	METALLIC = spec_tex.r * metal_mult;
	SPECULAR = spec_tex.r * spec_mult;
}
