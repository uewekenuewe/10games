#version 330 core

in vec3 vertexPosition;
in vec3 vertexNormal;
in vec4 vertexColor;

uniform mat4 mvp;

// Output (to fragment shader)
out vec4 fragColor;

void main()
{
    fragColor = vertexColor;
    fragColor.a = 1.0; // Set alpha to 1.0 (fully opaque)
    gl_Position = mvp*vec4(vertexPosition, 1.0);
}
