//SHADER ORIGINALY CREADED BY "FMS_Cat" FROM SHADERTOY
//PORTED AND MODIFYED TO GODOT BY AHOPNESS (@ahopness)
//LICENSE : CC0
//COMATIBLE WITH : GLES2, GLES3
//SHADERTOY LINK : https://www.shadertoy.com/view/XtBXDt

shader_type canvas_item;

//SHADER ORIGINALY CREADED BY "spl!te" FROM GITHUB FOR GODOT 2.1
//PORTED AND MODIFYED TO GODOT BY AHOPNESS (@ahopness)
//LICENSE : CC0
//COMATIBLE WITH : GLES2, GLES3
//GITHUB LINK : https://github.com/splite/Godot_Film_Grain_Shader
//ORIGINAL POST LINK : http://devlog-martinsh.blogspot.com/2013/05/image-imperfections-and-film-grain-post.html

uniform bool colored = false; //colored noise?
uniform float color_amount :hint_range(0, 1.3) = 0;
uniform float grain_amount :hint_range(0, 0.07) = 0.07; //grain amount
uniform float grain_size :hint_range(1, 3) = 1; //grain particle size (1.5 - 2.5)
uniform float lum_amount :hint_range(0, 2) = 1.3;

varying float time;

void vertex(){
	time = TIME;
}

//a random texture generator, but you can also use a pre-computed perturbation texture
vec4 rnm(vec2 tc) {
	float noise =  sin(dot(tc + vec2(time,time),vec2(12.9898,78.233))) * 43758.5453;
	float noiseR =  fract(noise)*2.0-1.0;
	float noiseG =  fract(noise*1.2154)*2.0-1.0; 
	float noiseB =  fract(noise*1.3453)*2.0-1.0;
	float noiseA =  fract(noise*1.3647)*2.0-1.0;
	return vec4(noiseR,noiseG,noiseB,noiseA);
}

float fade(float t) {
	return t*t*t*(t*(t*6.0-15.0)+10.0);
}

float pnoise3D(vec3 p){
	vec3 pi = 0.00390625*floor(p);
	pi = vec3(pi.x+0.001953125, pi.y+0.001953125, pi.z+0.001953125);
	vec3 pf = fract(p);     // Fractional part for interpolation
	
	// Noise contributions from (x=0, y=0), z=0 and z=1
	float perm00 = rnm(pi.xy).a ;
	vec3 grad000 = rnm(vec2(perm00, pi.z)).rgb * 4.0;
	grad000 = vec3(grad000.x - 1.0, grad000.y - 1.0, grad000.z - 1.0);
	float n000 = dot(grad000, pf);
	vec3 grad001 = rnm(vec2(perm00, pi.z + 0.00390625)).rgb * 4.0;
	grad001 = vec3(grad001.x - 1.0, grad001.y - 1.0, grad001.z - 1.0);
	float n001 = dot(grad001, pf - vec3(0.0, 0.0, 1.0));
	
	// Noise contributions from (x=0, y=1), z=0 and z=1
	float perm01 = rnm(pi.xy + vec2(0.0, 0.00390625)).a ;
	vec3 grad010 = rnm(vec2(perm01, pi.z)).rgb * 4.0;
	grad010 = vec3(grad010.x - 1.0, grad010.y - 1.0, grad010.z - 1.0);
	float n010 = dot(grad010, pf - vec3(0.0, 1.0, 0.0));
	vec3 grad011 = rnm(vec2(perm01, pi.z + 0.00390625)).rgb * 4.0;
	grad011 = vec3(grad011.x - 1.0, grad011.y - 1.0, grad011.z - 1.0);
	float n011 = dot(grad011, pf - vec3(0.0, 1.0, 1.0));
	
	// Noise contributions from (x=1, y=0), z=0 and z=1
	float perm10 = rnm(pi.xy + vec2(0.00390625, 0.0)).a ;
	vec3  grad100 = rnm(vec2(perm10, pi.z)).rgb * 4.0;
	grad100 = vec3(grad100.x - 1.0, grad100.y - 1.0, grad100.z - 1.0);
	float n100 = dot(grad100, pf - vec3(1.0, 0.0, 0.0));
	vec3  grad101 = rnm(vec2(perm10, pi.z + 0.00390625)).rgb * 4.0;
	grad101 = vec3(grad101.x - 1.0, grad101.y - 1.0, grad101.z - 1.0);
	float n101 = dot(grad101, pf - vec3(1.0, 0.0, 1.0));
	
	// Noise contributions from (x=1, y=1), z=0 and z=1
	float perm11 = rnm(pi.xy + vec2(0.00390625, 0.00390625)).a ;
	vec3  grad110 = rnm(vec2(perm11, pi.z)).rgb * 4.0;
	grad110 = vec3(grad110.x - 1.0, grad110.y - 1.0, grad110.z - 1.0);
	float n110 = dot(grad110, pf - vec3(1.0, 1.0, 0.0));
	vec3  grad111 = rnm(vec2(perm11, pi.z + 0.00390625)).rgb * 4.0;
	grad111 = vec3(grad111.x - 1.0, grad111.y - 1.0, grad111.z - 1.0);
	float n111 = dot(grad111, pf - vec3(1.0, 1.0, 1.0));
	
	// Blend contributions along x
	vec4 n_x = mix(vec4(n000, n001, n010, n011), vec4(n100, n101, n110, n111), fade(pf.x));
	
	// Blend contributions along y
	vec2 n_xy = mix(n_x.xy, n_x.zw, fade(pf.y));
	
	// Blend contributions along z
	float n_xyz = mix(n_xy.x, n_xy.y, fade(pf.z));
	
	// We're done, return the final noise value.
	return n_xyz;
}

//2d coordinate orientation thing
vec2 coordRot(vec2 tc, float angle, vec2 screen_size){
	float aspect = screen_size.x/screen_size.y;
	float rotX = ((tc.x*2.0-1.0)*aspect*cos(angle)) - ((tc.y*2.0-1.0)*sin(angle));
	float rotY = ((tc.y*2.0-1.0)*cos(angle)) + ((tc.x*2.0-1.0)*aspect*sin(angle));
	rotX = ((rotX/aspect)*0.5+0.5);
	rotY = rotY*0.5+0.5;
	return vec2(rotX,rotY);
}

uniform float tape_wave_amount :hint_range (0, .04) = 0.003;
uniform float tape_crease_amount :hint_range (0, 15) = 2.5;
uniform float color_displacement :hint_range (0, 5) = 1;
uniform float lines_velocity :hint_range (0, 5) = 0.1;

const float PI = 3.14159265;

vec3 tex2D( sampler2D _tex, vec2 _p ){
	vec3 col = texture( _tex, _p ).xyz;
	if ( 0.5 < abs( _p.x - 0.5 ) ) {
		col = vec3( 0.1 );
	}
	return col;
}

float hash( vec2 _v ){
	return fract( sin( dot( _v, vec2( 89.44, 19.36 ) ) ) * 22189.22 );
}

float iHash( vec2 _v, vec2 _r ){
	float h00 = hash( vec2( floor( _v * _r + vec2( 0.0, 0.0 ) ) / _r ) );
	float h10 = hash( vec2( floor( _v * _r + vec2( 1.0, 0.0 ) ) / _r ) );
	float h01 = hash( vec2( floor( _v * _r + vec2( 0.0, 1.0 ) ) / _r ) );
	float h11 = hash( vec2( floor( _v * _r + vec2( 1.0, 1.0 ) ) / _r ) );
	vec2 ip = vec2( smoothstep( vec2( 0.0, 0.0 ), vec2( 1.0, 1.0 ), mod( _v*_r, 1. ) ) );
	return ( h00 * ( 1. - ip.x ) + h10 * ip.x ) * ( 1. - ip.y ) + ( h01 * ( 1. - ip.x ) + h11 * ip.x ) * ip.y;
}

float noise( vec2 _v ){
	float sum = 0.;
	for( float i=1.0; i<9.0; i++ ){
	sum += iHash( _v + vec2( i ), vec2( 2. * pow( 2., float( i ) ) ) ) / pow( 2., float( i ) );
	}
	return sum;
}

void fragment(){
	vec2 uv = FRAGCOORD.xy / (1.0 / SCREEN_PIXEL_SIZE).xy;
	vec2 uvn = uv;
	vec3 col = vec3( 0.0 );
	
	// tape wave
	uvn.x += ( noise( vec2( uvn.y, TIME ) ) - 0.5 )* 0.005;
	uvn.x += ( noise( vec2( uvn.y * 100.0, TIME * 10.0 ) ) - 0.5 ) * tape_wave_amount;
	
	// tape crease
	float tcPhase = clamp( ( sin( uvn.y * 8.0 - TIME * PI * 1.2 ) - 0.92 ) * noise( vec2( TIME ) ), 0.0, 0.01 ) * tape_crease_amount;
	float tcNoise = max( noise( vec2( uvn.y * 100.0, TIME * 10.0 ) ) - 0.5, 0.0 );
	uvn.x = uvn.x - tcNoise * tcPhase;
	
	// switching noise
	float snPhase = smoothstep( 0.03, 0.0, uvn.y );
	uvn.y += snPhase * 0.3;
	uvn.x += snPhase * ( ( noise( vec2( uv.y * 100.0, TIME * 10.0 ) ) - 0.5 ) * 0.2 );
	
	col = tex2D( SCREEN_TEXTURE, uvn );
	col *= 1.0 - tcPhase;
	col = mix(
		col,
		col.yzx,
		snPhase
	);
	
	// bloom
	for( float x = -4.0; x < 2.5; x += 1.0 ){
		col.xyz += vec3(
		tex2D( SCREEN_TEXTURE, uvn + vec2( x - 0.0, 0.0 ) * 0.007 ).x,
		tex2D( SCREEN_TEXTURE, uvn + vec2( x - color_displacement, 0.0 ) * 0.007 ).y,
		tex2D( SCREEN_TEXTURE, uvn + vec2( x - color_displacement * 2.0, 0.0 ) * 0.007 ).z
		) * 0.1;
	}
	
	// ac beat
	col *= 1.0 + clamp( noise( vec2( 0.0, uv.y + TIME * lines_velocity ) ) * 0.6 - 0.25, 0.0, 0.1 );
	
	vec2 screen_size = (1.0 / SCREEN_PIXEL_SIZE).xy;
	vec3 rotOffset = vec3(1.425,3.892,5.835); //rotation offset values	
	vec2 rotCoordsR = coordRot(UV, time + rotOffset.x, screen_size);
	vec3 noise = vec3(pnoise3D(vec3(rotCoordsR*vec2(screen_size.x/grain_size,screen_size.y/grain_size),0.0)));
	
	if (colored){
	    vec2 rotCoordsG = coordRot(UV, time + rotOffset.y, screen_size);
	    vec2 rotCoordsB = coordRot(UV, time + rotOffset.z, screen_size);
	    noise.g = mix(noise.r,pnoise3D(vec3(rotCoordsG*vec2(screen_size.x/grain_size,screen_size.y/grain_size),1.0)),color_amount);
	    noise.b = mix(noise.r,pnoise3D(vec3(rotCoordsB*vec2(screen_size.x/grain_size,screen_size.y/grain_size),2.0)),color_amount);
	}
	
	vec3 lumcoeff = vec3(0.299,0.587,0.114);
	float luminance = mix(0.0,dot(col, lumcoeff),lum_amount);
	float lum = smoothstep(0.2,0.0,luminance);
	lum += luminance;
	
	noise = mix(noise,vec3(0.0),pow(lum,2.0));
	col = (col*2.0)+noise*grain_amount;
	
	vec4 SRC_COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	
	COLOR = vec4(col,1.0) * SRC_COLOR;
}