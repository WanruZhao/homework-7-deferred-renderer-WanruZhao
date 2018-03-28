#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform float u_Time;
uniform vec2 u_Size;
uniform int u_Radius;
uniform int u_Level;

// copy texture
void main() {
    // int radius = 7;
    // int intensityLevel = 20;

    vec2 curCoord = gl_FragCoord.xy;

    int intensityCount[256];
    float aveR[256];
    float aveG[256];
    float aveB[256];

    for(int i = 0; i < 256; i++) {
        intensityCount[i] = 0;
        aveR[i] = 0.0;
        aveG[i] = 0.0;
        aveB[i] = 0.0;
    }

    for(int i = -u_Radius; i <= u_Radius; i++) {
        for(int j = -u_Radius; j <= u_Radius; j++) {
            vec3 col = texture(u_frame, (curCoord + vec2(i, j)) / u_Size).xyz;
            int inten = int((col.r + col.b + col.g) / 3.0 * float(u_Level));
            intensityCount[inten]++;
            aveR[inten] += col.r;
            aveG[inten] += col.g;
            aveB[inten] += col.b;
        }
    }

    int curMax = 0;
    int maxIdx = 0;
    for(int i = 0; i < 256; i++) {
        if(intensityCount[i] > curMax) {
            curMax = intensityCount[i];
            maxIdx = i;
        }
    }

    out_Col = vec4(aveR[maxIdx] / float(curMax), aveG[maxIdx] / float(curMax), aveB[maxIdx] /float(curMax), 1.0);

}
