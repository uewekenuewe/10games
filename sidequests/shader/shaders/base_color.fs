#version 330 core

in vec4 fragColor;
in vec2 fragTexCoord;

uniform vec2 iResolution;

out vec4 FragColor;

void main() {
    //vec2 uv = vec2(gl_FragCoord.x/100,gl_FragCoord.y/100);
    vec2 uv = vec2(gl_FragCoord.x/iResolution.x,gl_FragCoord.y/iResolution.y);
    FragColor = vec4(uv,0.0,1.0);
}
