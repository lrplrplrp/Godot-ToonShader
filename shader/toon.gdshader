shader_type spatial;
render_mode ambient_light_disabled;

uniform sampler2D base_tex;

group_uniforms color;
uniform float saturation : hint_range(0.0, 3.0) = 2.0;


group_uniforms shadow;
uniform float shadow_offset:hint_range(0.0, 1.0) = 0.5;
uniform float shadow_color_mix:hint_range(0.0, 1.0) = 0.5;
uniform vec3 shadow_color:source_color = vec3(0.);

float lambert_shadow(vec3 normal,vec3 light,float attenuation){
	return clamp(dot(normal,light) * attenuation ,0.0 ,1.0) ;
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 base_color = texture(base_tex,UV);
	float luminance = dot(base_color.rgb, vec3(0.299, 0.587, 0.114)); 
    vec3 gray = vec3(luminance); 
    base_color.rgb = mix(gray, base_color.rgb, saturation); 
	ALBEDO = base_color.rgb;
}

void light() {
	vec4 base_color = texture(base_tex,UV);
	float shadow = lambert_shadow(NORMAL,LIGHT,ATTENUATION);
	
	shadow = step(shadow_offset ,shadow);
	vec3 diffuse_light = shadow * LIGHT_COLOR * base_color.rgb/ PI ;
	vec3 diffuse_shadow = LIGHT_COLOR * mix(base_color.rgb , shadow_color , shadow_color_mix)/ PI;
	DIFFUSE_LIGHT += mix(diffuse_shadow,diffuse_light,shadow);
}
