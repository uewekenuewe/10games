#version 330 core

in vec4 fragColor;
in vec2 fragTexCoord;


out vec4 FragColor;

uniform vec2 iResolution;

// Calculate Euclidean distance between two 2D points
float d(vec2 p0, vec2 p1) {
    return sqrt(pow(p0.x - p1.x, 2.0) + pow(p0.y - p1.y, 2.0));
}


void main() {

    // Convert pixel coordinates to a normalized space centered around the screen
    vec2 uv = (gl_FragCoord.xy - iResolution.xy * 0.5) / min(iResolution.x, iResolution.y) * 10.0;

    // Calculate distance from screen center
    float distance = d(vec2(0.0), uv);

    // Create concentric circles using banding based on distance
    float lev = step(0.5, fract(distance));

    // Set pixel color based on the level (black or white)
    FragColor = vec4(vec3(lev), 1.0);


}
