#version 330 core

in vec4 fragColor;
in vec2 fragTexCoord;

out vec4 FragColor;

void main() {
    vec2 uv = vec2(gl_FragCoord.x/1920,gl_FragCoord.y/1080);
    FragColor = vec4(uv,0.0,1.0);
}
