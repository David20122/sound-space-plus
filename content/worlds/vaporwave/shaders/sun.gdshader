shader_type spatial;

uniform float time_float;

float saturate(float f) {
	return clamp(f, 0.0, 1.0);
}

void fragment() {
	vec2 pos = (UV - 0.5);
	float sunSize = 0.1;
	float sunSizeSqrt = sqrt(sunSize);
	float blendSunColor = (pos.y + sunSize * 2.5) / sunSizeSqrt;
	vec4 colorSun = vec4(mix(vec3(1, 0.85, 0.05), vec3(1, 0, 0.35), blendSunColor), 0);
	float sunRadius = dot(pos.xy, pos.xy);
	colorSun.a = 1.0 - step(0.05, sunRadius);
	float glowAlpha = pow(smoothstep(0.08, 0.045, sunRadius), 2);
	
	float barPos = pos.y + 0.1;
	float sunCutOut = 1.0 - saturate(smoothstep(0, 0.005, barPos) * smoothstep(1.0 - barPos * 9.0, 1.0 - barPos * 8.0, sin(barPos * 200.0 + time_float)));
	float sunCutOutSmooth = 1.0 - saturate(smoothstep(0, 0.05, barPos) * smoothstep(-1.0 - barPos * 8.0, 1.0 - barPos * 8.0, sin(barPos * 200.0 + time_float)));
	
	EMISSION.rgb = mix(vec3(0, 0, 0), colorSun.rgb, colorSun.a * sunCutOut);
	
	ALPHA = max(glowAlpha * sunCutOutSmooth, colorSun.a * sunCutOut);
}
