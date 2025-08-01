#version 330 core

in vec4 fragColor;
in vec2 fragTexCoord;


out vec4 FragColor;


// signed distance to an equilateral triangle
// (r is hald the base)
float sdEquilateralTriangle( in vec2 p, in float r )
{
    const float k = sqrt(3.0);
    p.x = abs(p.x);
    p -= vec2(0.5,0.5*k)*max(p.x+k*p.y,0.0);
    p -= vec2(clamp(p.x,-r,r),-r/k );
    return length(p)*sign(-p.y);
}

// alternative - r is the bounding circle's radius
float sdEquilateralTriangle_2( in vec2 p, in float r )
{
    const float k = sqrt(3.0);
    p.x = abs(p.x);
    p -= vec2(0.5,0.5*k)*max(p.x+k*p.y,0.0);
    p -= vec2(clamp(p.x,-0.5*r*k,0.5*r*k),-0.5*r);
    return length(p)*sign(-p.y);
}

// not an SDF
float fEquilateralTriangle(  in vec2 p, in float r )
{
    const float k = sqrt(3.0);
    return -p.y + 0.5*k*max(abs(p.x)+k*p.y,0.0) - r/k;
}

void main() {
    vec2 iResolution = vec2(800.0,600.0);

	vec2 p = (2.0*gl_FragCoord.xy-iResolution.xy)/iResolution.y;
    //vec2 m = (2.0*iMouse.xy-iResolution.xy)/iResolution.y;
    vec2 m = (2.0*iResolution.xy)/iResolution.y;
    p *= 2.0;
    m *= 2.0;
    
	float d = sdEquilateralTriangle( p, 1.0 );

    vec3 col = (d>0.0) ? vec3(0.9,0.6,0.3) : vec3(0.65,0.85,1.0);
	col *= 1.0 - exp(-4.0*abs(d));
	col *= 0.8 + 0.2*cos(60.0*d);
	col = mix( col, vec3(1.0), 1.0-smoothstep(0.0,0.02,abs(d)) );

    //if( iMouse.z>0.001 )
    //{
    //d = sdEquilateralTriangle( m, 1.0 );
    //col = mix(col, vec3(1.0,1.0,0.0), 1.0-smoothstep(0.0, 0.01, abs(length(p-m)-abs(d))-0.005));
    //col = mix(col, vec3(1.0,1.0,0.0), 1.0-smoothstep(0.0, 0.01, length(p-m)-0.03));
    //}
    
	FragColor = vec4(col,1.0);}
