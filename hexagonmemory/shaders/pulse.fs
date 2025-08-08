#version 330
uniform float time;
void main() {
    // Use time for effects, e.g., pulsating or animation
    gl_FragColor = vec4(sin(time), cos(time), 0.5, 1.0);
}
