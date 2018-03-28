#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform float u_Threshold;
uniform vec2 u_Size;


// Interpolate between regular color and channel-swizzled color
// on right half of screen. Also scale color to range [0, 5].
void main() {
	// vec3 color = texture(u_frame, fs_UV).xyz;
	// float grey = 0.21 * color.x + 0.72 * color.y + 0.07 * color.z;
	// out_Col = vec4(vec3(grey), 1.0);

	float coefs[121] = float[](0.006849, 0.007239,0.007559, 0.007795, 0.007941, 0.00799,
					0.007941, 0.007795, 0.007559, 0.007239, 0.00684, 0.007239,
					0.007653, 0.00799, 0.00824, 0.008394, 0.008446, 0.008394,
					0.00824, 0.00799, 0.007653, 0.007239, 0.007559, 0.00799,
					0.008342, 0.008604, 0.008764, 0.008819, 0.008764, 0.008604,
					0.008342, 0.00799, 0.007559, 0.007795, 0.00824, 0.008604,
					0.008873, 0.009039, 0.009095, 0.009039, 0.008873, 0.008604,
					0.00824, 0.007795, 0.007941, 0.008394, 0.008764, 0.009039,
					0.009208, 0.009265, 0.009208, 0.009039, 0.008764, 0.008394,
					0.007941, 0.00799, 0.008446, 0.008819, 0.009095, 0.009265,
					0.009322, 0.009265, 0.009095, 0.008819, 0.008446, 0.00799,
					0.007941, 0.008394, 0.008764, 0.009039, 0.009208, 0.009265,
					0.009208, 0.009039, 0.008764, 0.008394, 0.007941, 0.007795,
					0.00824, 0.008604, 0.008873, 0.009039, 0.009095, 0.009039,
					0.008873, 0.008604, 0.00824, 0.007795, 0.007559, 0.00799,
					0.008342, 0.008604, 0.008764, 0.008819, 0.008764, 0.008604,
					0.008342, 0.00799, 0.007559, 0.007239, 0.007653, 0.00799,
					0.00824, 0.008394, 0.008446, 0.008394, 0.00824, 0.00799,
					0.007653, 0.007239, 0.006849, 0.007239, 0.007559, 0.007795,
					0.007941, 0.00799, 0.007941, 0.007795, 0.007559, 0.007239, 0.006849);

	int radius = 11;

	vec2 curCoord = gl_FragCoord.xy;
	vec3 sumColor = vec3(0.0);

	vec3 color = texture(u_frame, fs_UV).xyz;
	
	for(int i = - radius / 2; i <= radius / 2; i++) {
		for(int j = - radius / 2; j <= radius / 2; j++) {
			vec2 uv = vec2((curCoord[0] + float(i) * 2.16876) / u_Size[0],
					(curCoord[1] + float(j) * 2.3546) / u_Size[1]);
			vec3 originColor = texture(u_frame, uv).xyz;
			float grey = 0.21 * originColor.x + 0.72 * originColor.y + 0.07 * originColor.z;
			float maxV = max(originColor.x, max(originColor.y, originColor.z));
			if(maxV > u_Threshold) {
				sumColor += coefs[radius * (i + radius / 2) + (j + radius / 2)] * originColor;
			}
		}
	}


	out_Col = vec4(sumColor, 1.0);
}
