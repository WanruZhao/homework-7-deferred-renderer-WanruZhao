#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform float u_Time;

// Render R, G, and B channels individually
void main() {
	// out_Col = vec4(texture(u_frame, fs_UV + vec2(0.33, 0.0)).r,
	// 							 texture(u_frame, fs_UV + vec2(0.0, -0.33)).g,
	// 							 texture(u_frame, fs_UV + vec2(-0.33, 0.0)).b,
	// 							 1.0);
 	// out_Col.rgb += texture(u_frame, fs_UV).xyz;

	vec3 color = texture(u_frame, fs_UV).xyz;
	// vec3 color2 = vec3(dot(color, vec3(0.2126, 0.7152, 0.0722)));
	// float t = sin(3.14 * u_Time) * 0.5 + 0.5;
	// t *= 1.0 - step(0.5, fs_UV.x);
	// color = mix(color, color2, smoothstep(0.0, 1.0, t));
	out_Col = vec4(color, 1.0);
}
