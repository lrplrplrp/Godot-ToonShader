render_mode ambient_light_disabled;

uniform sampler2D base_tex;

group_uniforms color;
uniform float saturation : hint_range(0.0, 3.0) = 2.0;


group_uniforms shadow;
uniform float shadow_offset:hint_range(0.0, 1.0) = 0.5;
uniform float shadow_color_mix:hint_range(0.0, 1.0) = 0.5;
uniform vec3 shadow_color:source_color = vec3(0.);

#ifdef USE_FACE_SDF
	group_uniforms sdf_face;
	uniform sampler2D sdf_tex ;
	uniform vec3 head_forward = vec3(0.0,0.0,1.0);
	uniform vec3 head_right = vec3(1.0,0.0,0.0);
	uniform vec3 light_direction = vec3(0.0, -1.0, -0.0);
#endif

#ifdef USE_SPECULAR
	group_uniforms specular;
	uniform sampler2D spec_tex;
	uniform float specular_power : hint_range(0.0, 1.0) = 0.2;
#endif


#ifndef DISABLE_RIM
	group_uniforms rim;
	uniform float rim_power:hint_range(0.0, 1.0) = 0.001;
	uniform float rim_offset:hint_range(-90.0, 90.0) = -30.;
	uniform float rim_angle_range:hint_range(0.0, 1.0) = 0.8;
#endif
	
float sdf_face_shadow(float attenuation,float face_color){
	return clamp( attenuation * face_color - shadow_offset ,0.0 ,1.0);
}

float fresnel(vec3 view,vec3 normal,float amount){
	return pow(1.0 - clamp( dot( normalize(view), normalize(normal)) ,0.0 ,1.0), amount);
}

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
	float shadow;
	float rim = 0.0;
	#ifndef USE_FACE_SDF
		shadow = lambert_shadow(NORMAL,LIGHT,ATTENUATION);
	#endif
	
	#ifndef DISABLE_RIM
		float cy = cos(rim_offset*PI/180.);
		float sy = sin(rim_offset*PI/180.);
		mat3 my = mat3(
			vec3(cy,0, -sy),
			vec3(0,1,0),
			vec3(sy,0,cy)
		);
		rim = fresnel(VIEW * my,NORMAL,3.);
		rim = step(1.0 - rim_power,rim);
		rim *= 1. - dot(normalize(VIEW),normalize(LIGHT)) - rim_angle_range;
		rim = clamp(rim ,0,1);
	#endif
	
	#ifdef USE_FACE_SDF
		vec2 flipped_uv = vec2(1.0 - UV.x, UV.y);
		vec2 head_forwardRB = normalize(head_forward.rb);
		vec2 head_rightRB = normalize(head_right.rb);
		vec2 lightRB = normalize(light_direction.rb);
		
		float FdotL = dot(head_forwardRB,lightRB);
		
		float RdotL = dot(head_rightRB,lightRB);
		
		vec2 UVTOUSE = RdotL > 0.0 ? flipped_uv : UV;
		
		float angle = acos(RdotL);
		
		angle = angle / PI * 2.0;
		
		float angle1minus = 1.0 - angle;
		float angleminus1 = angle - 1.0;
		
		float ANGLETOUSE = RdotL > 0.0 ? angle1minus : angleminus1;
		float stepFunc = step(ANGLETOUSE, texture(sdf_tex, UVTOUSE).b);
		float resultForward = step(0.0,FdotL);
		vec3 shadowTexture = base_color.rgb * shadow_color.rgb;
		float face_color = stepFunc * resultForward;
		shadow = sdf_face_shadow(ATTENUATION ,face_color);
	#endif
	
	#ifdef USE_SPECULAR
		vec4 spec_color = texture(spec_tex,UV);
		SPECULAR_LIGHT += spec_color.a * (1. - smoothstep(0.2,0.4,fresnel(VIEW,NORMAL,1.))) * clamp(shadow,0.2,0.5);
	#endif
	
	shadow = step(shadow_offset ,shadow);
	vec3 diffuse_light = shadow * LIGHT_COLOR * base_color.rgb/ PI ;
	vec3 diffuse_shadow = LIGHT_COLOR * mix(base_color.rgb , shadow_color , shadow_color_mix)/ PI;
	DIFFUSE_LIGHT += mix(mix(diffuse_shadow,diffuse_light,shadow),LIGHT_COLOR,rim);
}
