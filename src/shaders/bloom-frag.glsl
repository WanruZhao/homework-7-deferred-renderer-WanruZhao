#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform sampler2D u_frame2;
uniform float u_Time;

// Interpolation between color and greyscale over time on left half of screen
void main() {

	vec3 color1 = texture(u_frame, fs_UV).xyz;
	vec3 color2 = texture(u_frame2, fs_UV).xyz;
	vec3 color = vec3(1.0) - exp(- (color1 + color2) * 1.0);
	out_Col = vec4(color, 1.0); 
}
