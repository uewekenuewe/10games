#version 330

#ifdef GL_ES
percision medium float;
#endif

in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D texture0;
uniform float u_time;
uniform float u_aspect;
uniform vec2 u_mouse_pos;
uniform vec2 u_resolution;

out vec4 finalColor;

void main()
{
    vec2 st = fragTexCoord.xy / 0.5;
    //st.x *= u_resolution.x/u_resolution.y;
    //finalColor = vec4(1.0,0.5,0.0,1.0);
    finalColor = fragColor; // vec4(st,0.0,1.0);
    finalColor = vec4(1.0,0.5,0.0,1.0);
}

