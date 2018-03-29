#version 300 es
precision highp float;

#define EPS 0.0001
#define PI 3.1415962

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_gb0; // camera space normal and depth info
uniform sampler2D u_gb1; // mesh or background
uniform sampler2D u_gb2; // albedo

uniform float u_Time;

uniform mat4 u_View;
uniform vec4 u_CamPos;   
uniform mat4 u_ViewInv;

uniform vec2 u_Size;

const vec4 lightPos = vec4(100, 0, 0, 1);


// background reference: https://www.shadertoy.com/view/4tjGWy

float scaleTo1(float a) {
	return (a + 1.0) / 2.0;
}

float getColorSeed(vec2 uv, vec2 l, vec2 u) {
	vec2 p1 = vec2(scaleTo1(sin(u_Time * 0.05)), scaleTo1(sin(u_Time * 0.06)));
	vec2 p2 = vec2(scaleTo1(sin(u_Time * 0.08)), scaleTo1(sin(u_Time * 0.07)));
	p1 = (p1 * (u - l)) + l;
	p2 = (p2 * (u - l)) + l;

	return (scaleTo1(sin(length(p1 - uv))) + scaleTo1(sin(length(p2 - uv))) + scaleTo1(sin(uv.x / 2.0)) + scaleTo1(sin(uv.y / 5.0))) / 4.0;
}

float realCol(float l, float u, float v) {
	float halfrange = (u - l) / 2.0;
	v -= l;
	v -= halfrange;
	v = abs(v);
	v = halfrange - v;
	v = v / halfrange;
	v = clamp(v, 0.0, 1.0);
	return v;
}

vec3 getColor(float a) {
	return vec3(
		realCol(0.0, 0.9, 1.0 - a),
		realCol(0.2 ,0.8, 1.0 - a),
		realCol(0.3, 1.0, 1.0 - a)
	);
}

vec3 getUV(vec2 p, vec2 size) {
	vec3 res = vec3(0.0);
	vec2 r = vec2(p.x / u_Size.x, 1.0 - p.y / u_Size.y);
	res[2] = 1.0 - distance(r, vec2(0.5));

	r *= size;
	float ratio = u_Size.x / u_Size.y;
	r.x *= ratio;
	float width = size.x * ratio;

	res[0] = r.x - (width - size.x) / 2.0;
	res[1] = r.y;

	return res;
}

vec3 background(vec2 p) {
	vec2 lbound = vec2(0.0);
	vec2 ubound = vec2(20.0);

	vec3 uv = getUV(p, vec2(10.0));
	float amp = uv.z;
	vec2 pos = uv.xy;

	vec3 color = vec3(1.0);
	
	float size = 40.0 / u_Size.x * ubound.x;
	vec2 realUV = floor((pos / size) + 0.5) * size;

	float a = getColorSeed(realUV, lbound, ubound);
	color = getColor(a);

	float border = scaleTo1(cos(pos.x / size * 2.0 * PI));
	border = min(border, scaleTo1(cos(pos.y / size * 2.0 * PI)));
	border = pow(border, 0.1);
	color *= vec3(border) * 0.4;

	color *= ((amp + 0.1) * 2.0) - 0.3;
	color = clamp(color, vec3(0.0), vec3(1.0));

	return color;
}

void main() { 
	// read from GBuffers
	vec4 gb2 = texture(u_gb2, fs_UV);

	vec3 col = gb2.xyz;
	
	float back = texture(u_gb1, fs_UV).x;
	
	// calculate camera space position
	vec2 uv_ndc = fs_UV * 2.0 - 1.0;
	vec4 gb0 = texture(u_gb0, fs_UV);
	float t = gb0.w;
	vec4 ref = t * vec4(0, 0, 1.0, 0);
	vec4 v = vec4(0, 1, 0, 0) * t * tan(45.0 * PI / 180.0 / 2.0);
	vec4 u = vec4(1, 0, 0, 0) * t * 1.0 * tan(45.0 * PI / 180.0 / 2.0);
	vec4 pos_Cam = ref + uv_ndc.x * u + uv_ndc.y * v;

	// calculate world space position
	vec4 pos_World = u_ViewInv * pos_Cam + u_CamPos;

	// lambertian model
	vec4 normal = texture(u_gb0, fs_UV);
	float diffuseTerm = dot(normalize(vec3(normal)), normalize(vec3(lightPos - pos_World)));
	float ambientTerm = 0.1;

	float term = clamp(diffuseTerm, 0.0, 1.0) + ambientTerm;

	out_Col = vec4(col * term , 1.0);

	if(back < 0.5) {
		out_Col = vec4(background(gl_FragCoord.xy), 1.0);
	}
	

}

