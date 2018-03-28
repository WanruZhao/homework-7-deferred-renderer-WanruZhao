#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform float u_Time;


void main() {
	// TODO: proper tonemapping
	// This shader just clamps the input color to the range [0, 1]
	// and performs basic gamma correction.
	// It does not properly handle HDR values; you must implement that.

	vec3 texColor = texture(u_frame, fs_UV).xyz;
	// texColor = min(vec3(1.0), texColor);
	texColor *= 2.0;
	texColor = pow(texColor, vec3(1.0 / 2.2));
	out_Col = vec4(texColor, 1.0);
}
