#version 330 core

in vec4 fragColor;
in vec2 fragTexCoord;


out vec4 FragColor;

void main() {
    vec2 uv = vec2(gl_FragCoord.x/800,gl_FragCoord.y/600);
    FragColor = vec4(uv,0.0,1.0);
}
