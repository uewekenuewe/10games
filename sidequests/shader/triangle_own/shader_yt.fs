#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

// Input uniform values
uniform sampler2D texture0;
uniform vec4 colDiffuse;

// Output fragment color
out vec4 finalColor;

vec3 palette( float t ) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.263,0.416,0.557);

    return a + b*cos( 6.28318*(c*t+d) );
}


void main()
{
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) / iResolution.y;
    // Texel color fetching from texture sampler
    vec4 texelColor = texture(texture0, fragTexCoord)*colDiffuse*fragColor;

    // Convert texel color to grayscale using NTSC conversion weights
    float gray = dot(texelColor.rgb, vec3(0.299, 0.587, 0.114));
    float gray1 = dot(texelColor.rgb, vec3(0.399, 0.587, 0.114));
    float gray2 = dot(texelColor.rgb, vec3(0.499, 0.587, 0.114));

    // Calculate final fragment color
    finalColor = vec4(gray, gray1, gray2, texelColor.a);

}

