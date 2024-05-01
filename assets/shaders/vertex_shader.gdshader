shader_type spatial;

varying vec4 v_TexCoord;
varying vec4 v_Vars;
varying vec3 v_Position;

uniform sampler2D noise;
uniform float time_float;
uniform vec3 note_color_front;
uniform vec3 note_color_back;

float saturate(float f) {
	return clamp(f, 0.0, 1.0);
}

float fbm(vec2 x)
{
	float v = 0.0;
	float a = 0.5;
	vec2 shift = vec2(100);
	// Rotate to reduce axial bias
    mat2 rot = mat2(vec2(cos(0.5), sin(0.5)), vec2(-sin(0.5), cos(0.5)));
	for (int i = 0; i < 5; ++i) {
		v += a * texture(noise, x).r;
		x = (rot * x) * 2.0 + shift;
		a *= 0.5;
	}
	return v;
}


void vertex() {
	v_Vars = vec4(0.0);

	float speed = time_float * 2.0;
	vec3 localPos = VERTEX;
	vec2 gridPos = floor(UV * 50.0 + vec2(0, speed));
	
	float dampenDistance = abs(UV.x * 2.0 - 1.0);
	float fallOffSides = pow(1.05 - dampenDistance, 0.5);
	float fallOffCenter = (0.2 + 0.8 * pow(dampenDistance, 2.0));
	
	float speedFrac = mod(speed, 1) / 50.0;
	v_Vars.x = UV.y - speedFrac; // Scale along Y
	float dampenY = UV.y - speedFrac;
	float clipCenter = clamp(0.8 - dampenDistance, 0.0, 1.0);
	
	float offsetY = max(0.0, fbm(gridPos * 0.1) * 2.0 - clipCenter) * fallOffCenter * 10.0;
	float maskUVSmoothing = step(0.005, offsetY);
	offsetY = offsetY * fallOffSides * dampenY + pow(dampenDistance, 2.0) * 0.02;
	
	localPos.z -= speedFrac * 2.0;
	localPos.y += offsetY;

	VERTEX = localPos;
	
	v_TexCoord.xy = UV;
	v_TexCoord.zw = UV * 50.0;
	
	float dampenUVSmoothing = clamp(abs(UV.x - 0.5) * 2.0 + maskUVSmoothing, 0.0, 1.0); // Dampen to center
	v_Vars.yz = 0.45 - v_TexCoord.y * vec2(0.05, 0.75 - dampenUVSmoothing * 0.7);
}

void fragment() {

	vec3 dx = dFdx(VERTEX);
	vec3 dy = dFdy(VERTEX);
	vec3 n = normalize(cross(dy, dx));
	vec3 lightDir = normalize(vec3(0, -0.15, -2) - VERTEX);
	vec2 grid = abs(mod(v_TexCoord.zw, 1.0) - 0.5);
	vec2 gridBlend = smoothstep(v_Vars.yz, vec2(0.5), grid);
	float gridAlpha = gridBlend.x + gridBlend.y;
	
	gridBlend = smoothstep(vec2(0), vec2(1), grid);
	gridAlpha += (gridBlend.x + gridBlend.y) * saturate(0.3 - v_TexCoord.y);
	
	float alphaDistanceFade = smoothstep(1.0, 0.9, v_Vars.x);
	
	vec3 colorNear = note_color_front;
	vec3 colorFar = note_color_back;
	float colorDistanceBlend = pow(v_TexCoord.y, 0.8);
	
	float shadingNear = dot(vec3(0, 0, 1), n);
	float shadingFar = dot(lightDir, n);
	vec3 shadingColor = saturate(shadingNear) * note_color_front * (1.0 - colorDistanceBlend)
						+ saturate(shadingFar) * note_color_back;
	vec3 colorGrid = vec3(0.02, 0, 0.02) + shadingColor;
	
	vec3 resultColor = mix(colorGrid,
						mix(colorNear, colorFar, colorDistanceBlend),
						gridAlpha * alphaDistanceFade);

	ALBEDO = min(max(resultColor,0.0),1.0);
	ALPHA = alphaDistanceFade;
}

