#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;

// copy texture
void main() {
	
	out_Col = vec4(texture(u_frame, fs_UV).xyz, 1.0);
}
