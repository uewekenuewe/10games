#version 330 core

in vec4 fragColor;
in vec2 fragTexCoord;

uniform vec2 iResolution;

out vec4 FragColor;

void main() {

    vec2 uv = vec2(gl_FragCoord.x/iResolution.x,gl_FragCoord.y/iResolution.y);
    uv.x = uv.x * 2 - 1.0;
    uv.y = uv.y * 2 - 1.0;
    float d = length(uv);


    FragColor = vec4(d,0.0,0.0,1.0);
}
