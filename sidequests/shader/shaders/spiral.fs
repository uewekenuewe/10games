#version 330
uniform float time;
uniform vec2 iResolution;
out vec4 fragColor;

void main() {
    // Normalize UV coordinates to [-1, 1] with center at (0, 0)
    vec2 uv = (gl_FragCoord.xy / iResolution) * 2.0 - 1.0;
    
    // Adjust for aspect ratio
    uv.x *= iResolution.x/ iResolution.y;
    
    // Polar coordinates
    float r = length(uv); // Radius
    float theta = atan(uv.y, uv.x); // Angle
    
    // Spiral pattern with rotation over time
    float spiral = sin(10.0 * (r - 0.2 * time) + theta);
    
    // Smooth the spiral for a cleaner effect
    float pattern = smoothstep(0.0, 0.1, spiral);
    
    // Color based on pattern
    vec3 color = mix(vec3(0.0), vec3(1.0), pattern);
    
    fragColor = vec4(color, 1.0);
}
