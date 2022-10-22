shader_type canvas_item;

const float PI = 3.14159265;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void fragment()
{
	float wobble_intensity = 0.002;
	float grade_intensity = 0.5;
	float line_intensity = 2.;
	float vignette_intensity = 0.2;
    
    //  wobble
    vec2 wobbl = vec2(wobble_intensity * rand(vec2(TIME, UV.y)), 0.);
    
    //  band distortion
    float t_val = tan(0.25 * TIME + UV.y * PI * .67);
    vec2 tan_off = vec2(wobbl.x * min(0., t_val), 0.);
    
    //  chromab
    vec4 color1 = texture(SCREEN_TEXTURE, UV + wobbl + tan_off);
    vec4 color2 = texture(SCREEN_TEXTURE, (UV + (wobbl * 1.5) + (tan_off * 1.3)) * 1.005);
    //  combine + grade
    vec4 color = vec4(color2.rg, pow(color1.b, .67), 1.);
    color.rgb = mix(texture(iChannel0, UV + tan_off).rgb, color.rgb, grade_intensity);
    
    //  scanline sim
    float s_val = ((sin(2. * PI * UV.y + iTime * 20.) + sin(2. * PI * UV.y)) / 2.) * .015 * sin(iTime);
    color += s_val;
    
    //  noise lines
    float ival = iResolution.y / 4.;
    float r = rand(vec2(iTime, fragCoord.y));
    //  dirty hack to avoid conditional
    float on = floor(float(int(fragCoord.y + (iTime * r * 1000.)) % int(ival + line_intensity)) / ival);
	vec2 uv = mod(fragCoord , iChannelResolution[1].xy);
    float value = texture(iChannel1, uv / iResolution.xy).r;
    float wh = pow(value, 7.) * on;
    color = vec4(min(1., color.r + wh), 
                 min(1., color.g + wh),
                 min(1., color.b + wh), 1.);
    
    float vig = 1. - sin(PI * uv.x) * sin(PI * uv.y);
    
    COLOR = color - (vig * vignette_intensity);
}