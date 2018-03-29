#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform vec2 u_Size;
uniform float u_Radius;
uniform float u_Level;

void main() {

    vec2 curCoord = gl_FragCoord.xy;



    int intensityCount[10];
    float aveR[10];
    float aveG[10];
    float aveB[10];

    for(int i = 0; i < 10; i++) {
        intensityCount[i] = 0;
        aveR[i] = 0.0;
        aveG[i] = 0.0;
        aveB[i] = 0.0;
    }

    int r = int(u_Radius);

    for(int i = -r; i <= r; i++) {
        for(int j = -r; j <= r; j++) {
            vec3 col = texture(u_frame, (curCoord + vec2(i, j)) / u_Size).xyz;
            int inten = int((col.r + col.b + col.g) / 3.0 * float(u_Level));
            inten = min(inten, 10);
            intensityCount[inten]++;
            aveR[inten] += col.r;
            aveG[inten] += col.g;
            aveB[inten] += col.b;
        }
    }

    int curMax = 0;
    int maxIdx = 0;
    for(int i = 0; i < 10; i++) {
        if(intensityCount[i] > curMax) {
            curMax = intensityCount[i];
            maxIdx = i;
        }
    }

    out_Col = vec4(aveR[maxIdx] / float(curMax),  aveG[maxIdx] / float(curMax), aveB[maxIdx] /float(curMax), 1.0);
    // // out_Col = texture(u_frame, fs_UV);
    // // vec4 c = texture(u_frame, fs_UV);
    // // out_Col = vec4((c.r + c.g + c.b) / 3.0);
    // // out_Col = vec4(float(curMax) / 256.0);

    // vec3 mean[4] = vec3[](
    //     vec3(0.0),
    //     vec3(0.0),
    //     vec3(0.0),
    //     vec3(0.0)
    // );

    // vec3 sigma[4] = vec3[](
    //     vec3(0.0),
    //     vec3(0.0),
    //     vec3(0.0),
    //     vec3(0.0)
    // );

    // vec2 start[4] = vec2[](
    //     vec2(-float(u_Radius), float(u_Radius)),
    //     vec2(-float(u_Radius), 0.0),
    //     vec2(0.0, -float(u_Radius)),
    //     vec2(0.0)
    // );

    // vec2 pos;
    // vec3 col = vec3(0.0);

    // for(int k = 0; k < 4; k++) {
    //     for(int i = 0; i <= int(u_Radius); i++) {
    //         for(int j = 0; j < int(u_Radius); j++) {
    //             pos = vec2(i, j) + curCoord + start[k];
    //             col = texture(u_frame, pos / u_Size).xyz;
    //             mean[k] += col;
    //             sigma[k] += col * col;
    //         }
    //     }
    // }

    // float sigma2 = 0.0;
    // float n = pow(float(u_Radius) + 1.0, 2.0);

    // float minS = u_Level;

    // out_Col = texture(u_frame, fs_UV);

    // for(int i = 0; i < 4; i++) {
    //     mean[i] /= n;
    //     sigma[i] = abs(sigma[i] / n - mean[i] * mean[i]);
    //     sigma2 = sigma[i].r + sigma[i].g + sigma[i].b;
    //     if(sigma2 < minS) {
    //         minS = sigma2;
    //         out_Col = vec4(mean[i], 1.0);
    //     }
    // }

}
