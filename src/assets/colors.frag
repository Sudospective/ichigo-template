#version 120

uniform vec2 resolution;
uniform float time;

void main()
{
  // Normalized pixel coordinates (from 0 to 1)
  vec2 uv = gl_FragCoord.xy/resolution.xy * 2.0;

  // Time varying pixel color
  vec3 col1 = 0.5 + 0.5*cos((time*0.5)+uv.xyx+vec3(0,2,4));
  vec3 col2 = 0.5 + 0.5*sin((time*0.5)+uv.yxy+vec3(2,4,0));
  vec3 col3 = 0.5 + 0.5*cos((time*0.5)+uv.xyx+vec3(4,0,2));
  
  float clamp1 = clamp(sin(time * 0.75) * 0.1 + 0.5, 0.0, 1.0);
  float clamp2 = clamp(cos(time * 0.25) * 0.1 + 0.5, 0.0, 1.0);

  // Output to screen
  gl_FragColor = vec4(mix(mix(col1, col2, clamp1), col3, clamp2),1.0);
}
